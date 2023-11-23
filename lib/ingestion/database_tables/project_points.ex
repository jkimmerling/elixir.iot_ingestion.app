defmodule Ingestion.DatabaseTables.ProjectPoints do
  use Ecto.Schema

  schema "points" do
    field :point_name, :string
    field :point_path, :string
    field :point_type, :string
  end
end
