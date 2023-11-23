defmodule Ingestion.DatabaseTables.ProjectReadings do
  use Ecto.Schema

  schema "readings" do
    field :point_id, :integer
    field :point_name, :string
    field :point_path, :string
    field :point_value, :string
    field :creation_time, :string
  end
end
