defmodule Ingestion.IntegrationSupervisor do
  use Supervisor

  def start_link(init_args \\ []) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do

    producers = Enum.map(["redis", "api"], fn integration ->
      %{
        id: "IntegrationProducer#{integration}",
        start: {
          Ingestion.Integrations.IntegrationProducer,
          :start_link,
          [integration]
        }
      }
    end)

    consumers = Enum.map(["redis", "api"], fn integration ->
      Enum.map(1..System.schedulers, fn id ->
        %{
          id: "IntegrationConsumer#{integration}#{id}",
          start: {
            Ingestion.Integrations.IntegrationConsumer,
            :start_link,
            [integration, id]
          }
        }
      end)
    end)


    Supervisor.init(producers ++ consumers |> List.flatten(), strategy: :one_for_one)
  end
end
