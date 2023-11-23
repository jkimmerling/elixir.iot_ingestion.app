defmodule Ingestion.Persistence.PersistenceSupervisor do
  use Supervisor

  def start_link(init_args \\ []) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  def init(_init_arg) do
    producers = [
      %{
        id: :persistence_producer,
        start: {
          Ingestion.Persistence.PersistenceProducer,
          :start_link,
          []
        }
      }
    ]

    # consumers = Enum.map(1..div(System.schedulers, 2), fn id ->
    consumers = Enum.map(1..System.schedulers, fn id ->
      %{
        id: "PersistenceConsumer#{id}",
        start: {
          Ingestion.Persistence.PersistenceConsumer,
          :start_link,
          ["PersistenceConsumer#{id}"]
        }
      }
    end)


    #   [
    #     %{
    #     id: :persistence_consumer_a,
    #     start: {
    #       Ingestion.Persistence.PersistenceConsumer,
    #       :start_link,
    #       []
    #     }
    #   },
    #   %{
    #     id: :persistence_consumer_b,
    #     start: {
    #       Ingestion.Persistence.PersistenceConsumer,
    #       :start_link,
    #       []
    #     }
    #   },
    #   %{
    #     id: :persistence_consumer_c,
    #     start: {
    #       Ingestion.Persistence.PersistenceConsumer,
    #       :start_link,
    #       []
    #     }
    #   },
    #   %{
    #     id: :persistence_consumer_d,
    #     start: {
    #       Ingestion.Persistence.PersistenceConsumer,
    #       :start_link,
    #       []
    #     }
    #   },
    #   %{
    #     id: :persistence_consumer_e,
    #     start: {
    #       Ingestion.Persistence.PersistenceConsumer,
    #       :start_link,
    #       []
    #     }
    #   },
    #   %{
    #     id: :persistence_consumer_f,
    #     start: {
    #       Ingestion.Persistence.PersistenceConsumer,
    #       :start_link,
    #       []
    #     }
    #   },
    #   %{
    #     id: :persistence_consumer_g,
    #     start: {
    #       Ingestion.Persistence.PersistenceConsumer,
    #       :start_link,
    #       []
    #     }
    #   },
    #   %{
    #     id: :persistence_consumer_h,
    #     start: {
    #       Ingestion.Persistence.PersistenceConsumer,
    #       :start_link,
    #       []
    #     }
    #   },

    # ]

    Supervisor.init(producers ++ consumers, strategy: :one_for_one)
  end
end
