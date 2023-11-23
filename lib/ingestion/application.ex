defmodule Ingestion.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    :ets.new(:updates, [:set, :public, :named_table])

    children = [
      Ingestion.PortfolioRepo,
      Ingestion.ProjectsRepo,
      Ingestion.ProjectInfo,
      Ingestion.IntegrationSupervisor,
      Ingestion.Persistence.PersistenceSupervisor

    ]

    opts = [strategy: :one_for_one, name: Ingestion.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
