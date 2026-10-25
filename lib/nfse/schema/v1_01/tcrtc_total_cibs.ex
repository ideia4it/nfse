# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCTotalCIBS do
  @moduledoc """
  Tipo `TCRTCTotalCIBS` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `v_tot_nf` | `vTotNF` | `TSDec15V2` | 1 | Valor Total da NF considerando os impostos por fora: IBS e CBS O IBS e a CBS são por fora, por isso seus valores devem ser adicionados ao valor total da NF vTotNF = vLiq (em 2026) vTotNF = vLiq + vCBS + vIBSTot (a partir de 2027) |
  | `g_ibs` | `gIBS` | `Nfse.Schema.V1_01.TCRTCTotalIBS` | 1 | Grupo de valores referentes ao IBS |
  | `g_cbs` | `gCBS` | `Nfse.Schema.V1_01.TCRTCTotalCBS` | 1 | Grupo de valores referentes à CBS |
  | `g_trib_regular` | `gTribRegular` | `Nfse.Schema.V1_01.TCRTCTotalTribRegular` | 0..1 | Grupo de informações de tributação regular |
  | `g_trib_compra_gov` | `gTribCompraGov` | `Nfse.Schema.V1_01.TCRTCTotalTribCompraGov` | 0..1 | Grupo de informações da composição do valor do IBS e da CBS em compras governamentais |
  """

  alias Nfse.Schema.{Field, Runtime}

  alias Nfse.Schema.V1_01.{
    SimpleTypes,
    TCRTCTotalCBS,
    TCRTCTotalIBS,
    TCRTCTotalTribCompraGov,
    TCRTCTotalTribRegular
  }

  defstruct [:v_tot_nf, :g_ibs, :g_cbs, :g_trib_regular, :g_trib_compra_gov]

  @type t :: %__MODULE__{
          v_tot_nf: Decimal.t() | nil,
          g_ibs: TCRTCTotalIBS.t() | nil,
          g_cbs: TCRTCTotalCBS.t() | nil,
          g_trib_regular: TCRTCTotalTribRegular.t() | nil,
          g_trib_compra_gov: TCRTCTotalTribCompraGov.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :v_tot_nf, xml: "vTotNF", type: {:simple, "TSDec15V2"}, min: 1, max: 1},
      %Field{name: :g_ibs, xml: "gIBS", type: {:complex, TCRTCTotalIBS}, min: 1, max: 1},
      %Field{name: :g_cbs, xml: "gCBS", type: {:complex, TCRTCTotalCBS}, min: 1, max: 1},
      %Field{
        name: :g_trib_regular,
        xml: "gTribRegular",
        type: {:complex, TCRTCTotalTribRegular},
        min: 0,
        max: 1
      },
      %Field{
        name: :g_trib_compra_gov,
        xml: "gTribCompraGov",
        type: {:complex, TCRTCTotalTribCompraGov},
        min: 0,
        max: 1
      }
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
