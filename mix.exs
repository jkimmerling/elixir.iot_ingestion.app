defmodule Ingestion.MixProject do
  use Mix.Project

  def project do
    [
      app: :ingestion,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Ingestion.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:gen_stage, "~> 1.2.1"},
      {:redix, "~> 1.2"},
      {:json, "~> 1.4"},
      {:req, "~> 0.3.10"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.0"},
      {:hackney, "~> 1.15"},
      {:sweet_xml, "~> 0.6"},
      {:jason, "~> 1.1"},
      {:observer_cli, "~> 1.7"}
    ]
  end
end
