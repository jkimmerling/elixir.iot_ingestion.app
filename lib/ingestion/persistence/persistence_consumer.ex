defmodule Ingestion.Persistence.PersistenceConsumer do
  use GenStage
  require Logger

  def start_link(name) do
    initial_state = []
    GenStage.start_link(__MODULE__, initial_state, name: String.to_atom(name))
  end

  def init(initial_state) do
    Logger.info("#{__MODULE__} init")
    sub_opts = [{Ingestion.Persistence.PersistenceProducer, min_demand: 0, max_demand: 1}]
    {:consumer, initial_state, subscribe_to: sub_opts}
  end

  def handle_events(events, _from, state) do
    Enum.each(events, fn name ->
      updates = :ets.lookup(:updates, name)
      case updates == [] do
        false ->
          :ets.delete(:updates, name)
          s3_time = :timer.tc(fn -> store_in_s3(name, updates) end) |> elem(0)
          db_time = :timer.tc(fn -> store_in_db(name, updates) end) |> elem(0)
          send(Ingestion.Persistence.PersistenceProducer, {:metrics, %{s3_time: s3_time, db_time: db_time}})
        true ->
          nil
      end
    end)
    {:noreply, [], state}
  end

  def store_in_db(project_name, updates) do
    Ingestion.ProjectsRepo.insert_all(Ingestion.DatabaseTables.ProjectReadings, updates |> hd |> elem(1), prefix: project_name)
  end

  def store_in_s3(project_name, updates) do
    file_name = "#{DateTime.to_unix(DateTime.utc_now())}.json"
    {:ok, json_updates} = updates |> hd |> JSON.encode
    ExAws.S3.put_object("elixir-ingestion", "#{project_name}/#{file_name}", json_updates)
    |> ExAws.request!(region: "us-east-2")
  end
end
