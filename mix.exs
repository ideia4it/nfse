defmodule Nfse.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/ideia4it/nfse"

  @guides ~w(
    guides/certificado.md
    guides/ambientes.md
    guides/emitir.md
    guides/conferir-apos-timeout.md
    guides/cancelar.md
    guides/importar-pelo-adn.md
    guides/parametros-municipais.md
  )

  def project do
    [
      app: :nfse,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: "Cliente Elixir para a NFS-e Nacional.",
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  def cli do
    [preferred_envs: [precommit: :test]]
  end

  def application do
    [extra_applications: [:logger, :public_key, :crypto, :ssl]]
  end

  defp elixirc_paths(:dev), do: ["lib", "dev"]
  defp elixirc_paths(:test), do: ["lib", "dev", "test/support"]
  defp elixirc_paths(_env), do: ["lib"]

  defp deps do
    [
      {:req, "~> 0.5"},
      {:decimal, "~> 2.0 or ~> 3.0"},
      {:saxy, "~> 1.5"},
      {:plug, "~> 1.0", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      precommit: [
        "compile --warnings-as-errors",
        "format --check-formatted",
        "credo --strict",
        "test"
      ]
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(lib priv mix.exs README.md LICENSE CHANGELOG.md)
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: ["README.md" | @guides] ++ ["CHANGELOG.md"],
      groups_for_extras: [Guias: ~r/^guides\//],
      filter_modules: &published_module?/2,
      groups_for_modules: [
        "Leiaute 1.00": ~r/^Nfse\.Schema\.V1_00\./,
        "Leiaute 1.01": ~r/^Nfse\.Schema\.V1_01\./,
        Internos: [
          Nfse.Signature,
          Nfse.Identifiers,
          Nfse.Root,
          Nfse.Schema.Runtime,
          Nfse.Schema.Xml,
          Nfse.Schema.SimpleType,
          Nfse.Codec,
          Nfse.Response
        ]
      ]
    ]
  end

  # O gerador vive em dev/ e é compilado em :dev, mas não faz parte do pacote publicado.
  defp published_module?(module, _metadata) do
    name = inspect(module)
    name != "Mix.Tasks.Nfse.Gen" and not String.starts_with?(name, "Nfse.Gen.")
  end
end
