defmodule Ingestion.PortfolioRepo do
  use Ecto.Repo,
    otp_app: :ingestion,
    adapter: Ecto.Adapters.Postgres
end
