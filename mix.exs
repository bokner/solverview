defmodule SolverView.MixProject do
  use Mix.Project

  def project do
    [
      app: :solverview,
      version: "0.1.0",
      elixir: "~> 1.13",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      docs: docs(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SolverView.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:solverl, git: "https://github.com/bokner/solverl.git"},
      {:color_stream, "~> 0.0.1"},
      {:phoenix_live_view, "~> 0.14.0"},
      {:floki, ">= 0.0.0", only: :test},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.2"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end





  defp copy_doc_assets(_) do
    File.mkdir_p("doc/doc_assets/readme")
    File.cp_r("doc_assets/readme", "doc/doc_assets/readme", fn _source, _destination ->
      true
    end)
    File.cp("README.md", "doc")
  end

  defp docs() do
    [
      main: "readme",
      formatter_opts: [gfm: true],
      extras: [
        "README.md",
      ]
    ]
  end


  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [docs: ["docs", &copy_doc_assets/1],
      setup: ["deps.get", "cmd npm install --prefix assets"]
    ]
  end
end
