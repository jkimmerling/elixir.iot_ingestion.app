defmodule Ingestion.Persistence.PersistenceProducer do
  use GenStage
  require Logger


  def start_link(init_args \\ []) do
    GenStage.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    Logger.info("#{__MODULE__} init")
    project_names = Ingestion.ProjectInfo.projects_list_names()
    {:producer,
     %{project_names: project_names,
     s3_total_insert_time: 0,
     db_total_insert_time: 0,
     start_time: DateTime.to_unix(DateTime.utc_now())
     }}
  end


  @impl true
  def handle_demand(demand, %{project_names: []} = state) do
      start_time = handle_queue_reset(state)
      refreshed_projects = Ingestion.ProjectInfo.projects_list_names()
      {pushed_projects, remaining_projects} = split_by_demand(refreshed_projects, demand)

      {:noreply,
        pushed_projects,
        %{
          project_names: remaining_projects,
          s3_total_insert_time: 0,
          db_total_insert_time: 0,
          start_time: start_time
        }
      }
  end
  def handle_demand(demand, %{project_names: projects} = state) do
    {pushed_projects, remaining_projects} = split_by_demand(projects, demand)
    {:noreply, pushed_projects, %{state | project_names: remaining_projects}}
  end

  @impl true
  def handle_info(
    {:metrics, %{s3_time: s3_time, db_time: db_time}},
    %{s3_total_insert_time: s3_total_insert_time, db_total_insert_time: db_total_insert_time} = state
    ) do

    {:noreply,[],
      %{
        state | s3_total_insert_time: s3_total_insert_time + s3_time,
        db_total_insert_time: db_total_insert_time + db_time
      }
    }
  end

  # Helper functions

  def handle_queue_reset(state) do
    report_metrics(state)
    :timer.sleep(:timer.seconds(5))
    start_time = DateTime.to_unix(DateTime.utc_now())
    start_time
  end

  def report_metrics(
    %{
      start_time:  start_time,
      s3_total_insert_time: s3_total_insert_time,
      db_total_insert_time: db_total_insert_time
    } = _state) do
    Logger.info("#{__MODULE__} Finished storing data, delaying 5 seconds")
    Logger.info("#{__MODULE__} Total DB insertion time: #{db_total_insert_time / 1_000_000}")
    Logger.info("#{__MODULE__} Total s3 insertion time: #{s3_total_insert_time / 1_000_000}")
    Logger.info("#{__MODULE__} Total persistence cycle time: #{DateTime.to_unix(DateTime.utc_now()) - start_time}")
  end

  def split_by_demand(projects, demand) do
    demand_split_projects = Enum.split(projects, demand)
    pushed_projects = demand_split_projects |> elem(0)
    remaining_projects = demand_split_projects |> elem(1)
    {pushed_projects, remaining_projects}
  end

end
