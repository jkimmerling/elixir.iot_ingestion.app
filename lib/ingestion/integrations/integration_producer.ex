defmodule Ingestion.Integrations.IntegrationProducer do
  use GenStage
  require Logger

  def start_link(integration \\ []) do
    GenStage.start_link(__MODULE__, integration, name: String.to_atom("#{integration}producer"))
  end

  def init(integration) do
    Logger.info("#{__MODULE__} init")
    projects = Ingestion.ProjectInfo.projects_list_for_integration(integration)
    {:producer, %{integration: integration, projects: projects, number_of_projects: length(projects), start_time: DateTime.to_unix(DateTime.utc_now())}}
  end


  def handle_demand(demand, %{integration: integration, projects: []} = state) do
    start_time = handle_queue_reset(state)
    refreshed_projects = Ingestion.ProjectInfo.projects_list_for_integration(integration)
    {pushed_projects, remaining_projects} = split_by_demand(refreshed_projects, demand)
    {:noreply, pushed_projects, %{state | start_time: start_time, projects: remaining_projects, number_of_projects: length(refreshed_projects)}}
  end
  def handle_demand(demand, %{projects: projects} = state) do
    {pushed_projects, remaining_projects} = split_by_demand(projects, demand)
    {:noreply, pushed_projects, %{state | projects: remaining_projects}}
  end

  def handle_info(:refresh_projects, %{integration: integration} = state) do
    refreshed_projects = Ingestion.ProjectInfo.projects_list_for_integration(integration)
    {:noreply, [], %{state | projects: refreshed_projects}}
  end

  # Helper Functions

  def handle_queue_reset(state) do
    delay = 30
    duration =
      case report_metrics(state) do
        x when x <= delay ->
          Logger.info("#{__MODULE__} delaying #{delay - x} until next cycle")
          x
        _ ->
          delay
      end
    :timer.sleep(:timer.seconds(delay - duration))
    start_time = DateTime.to_unix(DateTime.utc_now())
    start_time
  end

  def report_metrics(%{integration: integration, number_of_projects: number_of_projects, start_time:  start_time} = _state) do
    Logger.info("#{__MODULE__} Completed ingestion from all #{number_of_projects} #{integration} projects")
    Logger.info("#{__MODULE__} Total #{integration} ingestion cycle time: #{DateTime.to_unix(DateTime.utc_now()) - start_time}")
    DateTime.to_unix(DateTime.utc_now()) - start_time
  end

  def split_by_demand(projects, demand) do
    demand_split_projects = Enum.split(projects, demand)
    pushed_projects = demand_split_projects |> elem(0)
    remaining_projects = demand_split_projects |> elem(1)
    {pushed_projects, remaining_projects}
  end

end
