import Config

config :ingestion, Ingestion.ProjectsRepo,
  database: "projects",
  username: "postgres",
  password: System.get_env("DBPASS"),
  hostname: System.get_env("DBHOST"),
  log: false

config :ingestion, Ingestion.PortfolioRepo,
  database: "portfolio",
  username: "postgres",
  password: System.get_env("DBPASS"),
  hostname: System.get_env("DBHOST"),
  log: false


config :ingestion,
    ecto_repos: [Ingestion.PortfolioRepo, Ingestion.ProjectsRepo]
