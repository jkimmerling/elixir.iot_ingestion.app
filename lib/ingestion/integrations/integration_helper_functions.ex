defmodule Ingestion.Integrations.IntegrationHelperFunctions do
  require Logger

  def fetch_from_redis(name, ingestion_list) do
    {:ok, conn} = Redix.start_link(System.get_env("REDISHOST"))
    {:ok, redis_entry} = Redix.command(conn, ["GET", name])
    Redix.command(conn, ["DEL", name])
    Redix.stop(conn)
    case redis_entry do
      nil ->
        nil
      _ ->
        {:ok, updates} = redis_entry |> JSON.decode()
        atom_updates = Enum.map(updates, fn update ->
          Map.new(update, fn {k, v} -> {String.to_atom(k), v} end)
        end)
        formatted_updates =
          Enum.reduce(atom_updates, %{}, fn  x, acc ->
            Map.put(acc, x.path, x)
          end)
        output = Enum.map(ingestion_list, fn x ->
          update = get_in(formatted_updates, [x.point_path])
          combined_results = Map.merge(x, update)
          %{id: id, point_name: name, point_path: path, value: value} = combined_results
          %{point_id: id, point_name: name, point_path: path, point_value: value, creation_time: DateTime.to_string(DateTime.utc_now())}
        end)
        output
    end
  end

  def grab_api_results(name, ingestion_list) do
    {:ok, updates} = Req.get!(System.get_env("APIHOST") <> name).body |> JSON.decode()
    atom_updates = Enum.map(updates["#{name}"], fn update ->
      Map.new(update, fn {k, v} -> {String.to_atom(k), v} end)
    end)
    formatted_updates =
      Enum.reduce(atom_updates, %{}, fn  x, acc ->
        Map.put(acc, x.path, x)
    end)
    output = Enum.map(ingestion_list, fn x ->
      update = get_in(formatted_updates, [x.point_path])
      combined_results = Map.merge(x, update)
      %{id: id, point_name: name, point_path: path, value: value} = combined_results
      %{point_id: id, point_name: name, point_path: path, point_value: value, creation_time: DateTime.to_string(DateTime.utc_now())}
    end)
    output
  end

end
