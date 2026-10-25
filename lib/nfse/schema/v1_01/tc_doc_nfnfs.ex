# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCDocNFNFS do
  @moduledoc """
  Tipo `TCDocNFNFS` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `n_nfs` | `nNFS` | `TSNum7Dig` | 1 | Número da Nota Fiscal NF ou NFS |
  | `mod_nfs` | `modNFS` | `TSNum15Dig` | 1 | Modelo da Nota Fiscal NF ou NFS |
  | `serie_nfs` | `serieNFS` | `TSSerieNFNFS` | 1 | Série Nota Fiscal NF ou NFS |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:n_nfs, :mod_nfs, :serie_nfs]

  @type t :: %__MODULE__{
          n_nfs: String.t() | nil,
          mod_nfs: String.t() | nil,
          serie_nfs: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :n_nfs, xml: "nNFS", type: {:simple, "TSNum7Dig"}, min: 1, max: 1},
      %Field{name: :mod_nfs, xml: "modNFS", type: {:simple, "TSNum15Dig"}, min: 1, max: 1},
      %Field{name: :serie_nfs, xml: "serieNFS", type: {:simple, "TSSerieNFNFS"}, min: 1, max: 1}
    ]

  @doc """
  Converte `attrs` (mapa, lista de palavras-chave ou o próprio struct, também nos campos
  aninhados) neste struct e valida o resultado. As regras estão em `Nfse.Schema.Runtime`.
  """
  @spec new(map() | keyword() | t()) :: {:ok, t()} | {:error, Nfse.Error.t()}
  def new(attrs), do: Runtime.new(__MODULE__, attrs)

  @doc "Valida o struct contra o XSD e devolve cada erro com o caminho do campo."
  @spec validate(t()) :: :ok | {:error, Nfse.Error.t()}
  def validate(struct), do: Runtime.validate(__MODULE__, struct)

  @doc """
  Escreve o struct já validado como o elemento `tag`, na forma canônica. Os `extra_attributes`,
  como as declarações de namespace, saem antes dos atributos do struct.
  """
  @spec encode(t(), String.t(), [Runtime.attribute()]) :: iodata()
  def encode(struct, tag, extra_attributes \\ []),
    do: Runtime.encode(__MODULE__, struct, tag, extra_attributes)

  @doc "Lê o elemento, na árvore do `Saxy.SimpleForm`, como este struct e valida o resultado."
  @spec decode(Saxy.SimpleForm.t()) :: {:ok, t()} | {:error, Nfse.Error.t()}
  def decode(element), do: Runtime.decode(__MODULE__, element)
end
