defmodule Ingestion.ProjectInfo do
  use GenServer

  require Ecto.Query

  # API

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def projects_list() do
    GenServer.call(__MODULE__, {:get_projects})
  end

  def projects_list_names() do
    GenServer.call(__MODULE__, {:get_project_names}, 50_000)
  end

  def projects_list_for_integration(integration) do
    GenServer.call(__MODULE__, {:get_integration_projects, integration}, 50_000)
  end

  # Callbacks

  def init(_init_arg) do
    state = return_projects()
    {:ok, state}
  end

  def handle_call({:get_project_names}, _from, state) do
    project_names =
      state
      |> Enum.map(fn x ->
        x.project_name
      end)
    {:reply, project_names, state}
  end

  def handle_call({:get_projects}, _from, state) do
    {:reply, state, state}
  end


  def handle_call({:get_integration_projects, integration}, _from, state) do
    integration_projects =
      state
      |> Enum.filter(fn project -> project.integration_type == integration end)
    {:reply, integration_projects, state}
  end

  def handle_cast({:update_projects}, _state) do
    new_state = return_projects()
    {:noreply, new_state}
  end


  # Helper functions

  def return_projects() do
    get_projects()
    |> Enum.map(fn %{__meta__: _, id: _, project_name: name, integration_type: integration_type} -> %{project_name: name, integration_type: integration_type, ingestion_list: get_points(name)} end)
  end

  def get_projects() do
    Ecto.Query.from(Ingestion.DatabaseTables.ProjectList)
    |> Ingestion.PortfolioRepo.all()
  end

  def get_points(project_name) do
    Ecto.Query.from(Ingestion.DatabaseTables.ProjectPoints)
    |> Ingestion.ProjectsRepo.all(prefix: project_name)
    |> Enum.map(fn %{__meta__: _, id: id, point_name: name, point_path: point_path, point_type: _} -> %{id: id, point_name: name, point_path: point_path} end)
  end
end
