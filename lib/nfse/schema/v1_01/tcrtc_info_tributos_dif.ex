# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCInfoTributosDif do
  @moduledoc """
  Tipo `TCRTCInfoTributosDif` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `p_dif_uf` | `pDifUF` | `TSDec3V2` | 1 | Percentual de diferimento para o IBS estadual |
  | `p_dif_mun` | `pDifMun` | `TSDec3V2` | 1 | Percentual de diferimento para o IBS municipal |
  | `p_dif_cbs` | `pDifCBS` | `TSDec3V2` | 1 | Percentual de diferimento para a CBS |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:p_dif_uf, :p_dif_mun, :p_dif_cbs]

  @type t :: %__MODULE__{
          p_dif_uf: Decimal.t() | nil,
          p_dif_mun: Decimal.t() | nil,
          p_dif_cbs: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :p_dif_uf, xml: "pDifUF", type: {:simple, "TSDec3V2"}, min: 1, max: 1},
      %Field{name: :p_dif_mun, xml: "pDifMun", type: {:simple, "TSDec3V2"}, min: 1, max: 1},
      %Field{name: :p_dif_cbs, xml: "pDifCBS", type: {:simple, "TSDec3V2"}, min: 1, max: 1}
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
