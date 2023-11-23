defmodule Ingestion.DatabaseTables.ProjectList do
  use Ecto.Schema

  @schema_prefix "portfolio_stats"

  schema "project_list" do
    field :project_name, :string
    field :integration_type, :string
  end
end
