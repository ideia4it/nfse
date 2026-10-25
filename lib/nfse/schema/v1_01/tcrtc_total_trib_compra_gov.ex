# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCTotalTribCompraGov do
  @moduledoc """
  Tipo `TCRTCTotalTribCompraGov` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `p_ibsuf` | `pIBSUF` | `TSDec2V2` | 1 | Alíquota do IBS de competência do Estado |
  | `v_ibsuf` | `vIBSUF` | `TSDec15V2` | 1 | Valor do Tributo do IBS da UF calculado |
  | `p_ibs_mun` | `pIBSMun` | `TSDec2V2` | 1 | Alíquota do IBS de competência do Município |
  | `v_ibs_mun` | `vIBSMun` | `TSDec15V2` | 1 | Valor do Tributo do IBS do Município calculado |
  | `p_cbs` | `pCBS` | `TSDec2V2` | 1 | Alíquota da CBS |
  | `v_cbs` | `vCBS` | `TSDec15V2` | 1 | Valor do Tributo da CBS calculado |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:p_ibsuf, :v_ibsuf, :p_ibs_mun, :v_ibs_mun, :p_cbs, :v_cbs]

  @type t :: %__MODULE__{
          p_ibsuf: Decimal.t() | nil,
          v_ibsuf: Decimal.t() | nil,
          p_ibs_mun: Decimal.t() | nil,
          v_ibs_mun: Decimal.t() | nil,
          p_cbs: Decimal.t() | nil,
          v_cbs: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :p_ibsuf, xml: "pIBSUF", type: {:simple, "TSDec2V2"}, min: 1, max: 1},
      %Field{name: :v_ibsuf, xml: "vIBSUF", type: {:simple, "TSDec15V2"}, min: 1, max: 1},
      %Field{name: :p_ibs_mun, xml: "pIBSMun", type: {:simple, "TSDec2V2"}, min: 1, max: 1},
      %Field{name: :v_ibs_mun, xml: "vIBSMun", type: {:simple, "TSDec15V2"}, min: 1, max: 1},
      %Field{name: :p_cbs, xml: "pCBS", type: {:simple, "TSDec2V2"}, min: 1, max: 1},
      %Field{name: :v_cbs, xml: "vCBS", type: {:simple, "TSDec15V2"}, min: 1, max: 1}
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
