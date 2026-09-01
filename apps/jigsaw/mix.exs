defmodule Jigsaw.MixProject do
  use Mix.Project

  def project do
    [
      app: :jigsaw,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),

      # Docs
      name: "Jigsaw",
      source_url: "https://github.com/W3NDO/jigsaw/tree/main/apps/jigsaw",
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:phoenix, "~> 1.8"},
      {:phoenix_live_view, "~> 1.1.0"},
      {:floki, "~> 0.38", only: :test},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false, warn_if_outdated: true}
    ]
  end

  defp docs do
    [
      main: "readme",
      logo: "./images/jigsaw_logo.png",
      extras: ["README.md"]
    ]
  end

  defp description do
    "Jigsaw is a proof of concept for a layout tiling library for Phoenix LiveView. The layout is currently generated with a variant the binary space partitioning algorithm. Built with and for Elixir and Phoenix LiveView."
  end

  defp package() do
    [
      licenses: ["AGPL-3.0-or-later"],
      links: %{"Github" => "https://github.com/W3NDO/jigsaw/tree/main/apps/jigsaw"}
    ]
  end
end
