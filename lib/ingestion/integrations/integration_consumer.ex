defmodule Ingestion.Integrations.IntegrationConsumer do
  use GenStage
  require Logger

  def start_link(integration, id) do
    GenStage.start_link(__MODULE__, integration, name: String.to_atom("IntegrationConsumer#{integration}#{id}"))
  end

  def init(integration) do
    Logger.info("#{__MODULE__} init")
    producer =
      case integration do
        "redis" ->
          :redisproducer
        "api" ->
          :apiproducer
      end
    sub_opts = [{producer, min_demand: 0, max_demand: 1}]
    {:consumer, integration, subscribe_to: sub_opts}
  end

  def handle_events(events, _from, integration) do
    Enum.each(events, fn %{project_name: name, ingestion_list: ingestion_list} = _event ->

      updates =
        case integration do
          "redis" ->
            Ingestion.Integrations.IntegrationHelperFunctions.fetch_from_redis(name, ingestion_list)
          "api" ->
            Ingestion.Integrations.IntegrationHelperFunctions.grab_api_results(name, ingestion_list)
          _ ->
            Logger.warning("#{__MODULE__} integration of type #{inspect(integration)} not supported")
            nil
        end
      case updates do
        nil ->
          nil
        _ ->
          :ets.insert(:updates, {name, updates})
      end
    end)
    {:noreply, [], integration}
  end
end
