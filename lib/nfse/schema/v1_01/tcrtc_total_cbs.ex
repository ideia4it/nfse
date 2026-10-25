# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCTotalCBS do
  @moduledoc """
  Tipo `TCRTCTotalCBS` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `g_cbs_cred_pres` | `gCBSCredPres` | `Nfse.Schema.V1_01.TCRTCTotalCBSCredPres` | 0..1 | Grupo de valores referentes ao crédito presumido para CBS |
  | `v_dif_cbs` | `vDifCBS` | `TSDec15V2` | 0..1 | Total do Diferimento CBS vDifCBS = vCBS x pDifCBS |
  | `v_cbs` | `vCBS` | `TSDec15V2` | 1 | Total valor da CBS da União vCBS = vBC x (pCBS ou pAliqEfetCBS) |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCRTCTotalCBSCredPres}

  defstruct [:g_cbs_cred_pres, :v_dif_cbs, :v_cbs]

  @type t :: %__MODULE__{
          g_cbs_cred_pres: TCRTCTotalCBSCredPres.t() | nil,
          v_dif_cbs: Decimal.t() | nil,
          v_cbs: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :g_cbs_cred_pres,
        xml: "gCBSCredPres",
        type: {:complex, TCRTCTotalCBSCredPres},
        min: 0,
        max: 1
      },
      %Field{name: :v_dif_cbs, xml: "vDifCBS", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
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
