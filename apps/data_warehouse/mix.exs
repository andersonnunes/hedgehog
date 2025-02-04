defmodule DataWarehouse.MixProject do
  use Mix.Project

  def project do
    [
      app: :data_warehouse,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {DataWarehouse.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.10"},
      {:ecto_enum, "~> 1.4"},
      {:phoenix_pubsub, "~> 2.1"},
      {:postgrex, "~> 0.17.1"},
      {:core, in_umbrella: true}
    ]
  end
end
