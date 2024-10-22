defmodule Basket.MixProject do
  use Mix.Project

  def project do
    [
      app: :basket,
      version: "0.2.1",
      elixir: "~> 1.16.0",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: Mix.compilers(),
      deps: deps(),
      test_coverage: [summary: [threshold: 0]],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      dialyzer: [
        plt_add_apps: [:mix, :ex_unit],
        check_plt: true
      ],
      releases: [
        basket: [
          applications: [
            opentelemetry_exporter: :permanent,
            # Let OTel crash without taking the app down too.
            opentelemetry: :temporary,
            basket: :permanent
          ]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Basket.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:opentelemetry_exporter, "~> 1.8"},
      {:opentelemetry, "~> 1.4"},
      {:opentelemetry_api, "~> 1.3"},
      {:opentelemetry_liveview, "~> 1.0.0-rc.4"},
      {:opentelemetry_phoenix, "~> 1.2"},
      {:phoenix, "~> 1.7.14"},
      {:phoenix_ecto, "~> 4.6"},
      {:ecto_sql, "~> 3.11"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.3.1"},
      {:phoenix_live_reload, "~> 1.5", only: :dev},
      {:phoenix_live_view, "~> 0.20.17"},
      {:floki, ">= 0.36.2", only: :test},
      {:phoenix_live_dashboard, "~> 0.7"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.16"},
      {:finch, "~> 0.18"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.1"},
      {:gettext, "~> 0.24"},
      {:jason, "~> 1.4.1"},
      {:dns_cluster, "~> 0.1.3"},
      {:plug_cowboy, "~> 2.7"},
      {:excoveralls, "~> 0.18", only: :test},
      {:sobelow, "~> 0.13.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4.3", runtime: false},
      {:mix_audit, "~> 2.1.3", runtime: false},
      {:pow, "~> 1.0.38"},
      {:websockex, "~> 0.4.3"},
      {:httpoison, "~> 2.2.1"},
      {:cachex, "~> 3.6"},
      {:mox, "1.1.0", only: :test},
      {:test_server, "~> 0.1", only: :test},
      {:ex_machina, "~> 2.8.0", only: :test},
      {:oban, "~> 2.17"},
      {:html_entities, "~> 0.5.2"},
      {:html_sanitize_ex, "~> 1.4"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "npm.install": ["cmd cd assets && npm install"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": [
        "npm.install",
        "tailwind.install --if-missing",
        "esbuild.install --if-missing"
      ],
      "assets.build": ["tailwind default", "esbuild default"],
      "assets.deploy": ["tailwind default --minify", "esbuild default --minify", "phx.digest"]
    ]
  end
end
