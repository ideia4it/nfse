# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCValoresNFSe do
  @moduledoc """
  Tipo `TCValoresNFSe` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `v_calc_dr` | `vCalcDR` | `TSDec15V2` | 0..1 | Valor monetário (R$) de dedução/redução da base de cálculo (BC) do ISSQN. |
  | `tp_bm` | `tpBM` | `TBMISSQN` | 0..1 | Tipo Benefício Municipal (BM): 1) Isenção; 2) Redução da BC em 'ppBM' %; 3) Redução da BC em R$ 'vInfoBM'; 4) Alíquota Diferenciada de 'aliqDifBM' %; |
  | `v_calc_bm` | `vCalcBM` | `TSDec15V2` | 0..1 | Valor monetário (R$) do percentual de redução da base de cálculo (BC) do ISSQN devido a um benefício municipal (BM). |
  | `v_bc` | `vBC` | `TSDec15V2` | 0..1 | Valor da Base de Cálculo do ISSQN (R$) = Valor do Serviço - Desconto Incondicionado - Deduções/Reduções - Benefício Municipal vBC = vServ - descIncond - (vDR ou vCalcDR + vCalcReeRepRes) - (vRedBCBM ou VCalcBM) |
  | `p_aliq_aplic` | `pAliqAplic` | `TSDec1V2` | 0..1 | Alíquota aplicada sobre a base de cálculo para apuração do ISSQN. |
  | `v_issqn` | `vISSQN` | `TSDec15V2` | 0..1 | Valor do ISSQN (R$) = Valor da Base de Cálculo x Alíquota ISSQN = vBC x pAliqAplic |
  | `v_total_ret` | `vTotalRet` | `TSDec15V2` | 0..1 | Valor total das retenções de tributos da NFS-e. Valor total de retenções (R$) = Σ(vRetCP + vRetIRRF+ vRetCSLL + ISSQN*) |
  | `v_liq` | `vLiq` | `TSDec15V2` | 1 | Valor líquido da NFS-e. Valor líquido (R$) = Valor do serviço - Desconto condicionado - Desconto incondicionado - Valores retidos |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:v_calc_dr, :tp_bm, :v_calc_bm, :v_bc, :p_aliq_aplic, :v_issqn, :v_total_ret, :v_liq]

  @type t :: %__MODULE__{
          v_calc_dr: Decimal.t() | nil,
          tp_bm: String.t() | nil,
          v_calc_bm: Decimal.t() | nil,
          v_bc: Decimal.t() | nil,
          p_aliq_aplic: Decimal.t() | nil,
          v_issqn: Decimal.t() | nil,
          v_total_ret: Decimal.t() | nil,
          v_liq: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :v_calc_dr, xml: "vCalcDR", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
      %Field{name: :tp_bm, xml: "tpBM", type: {:simple, "TBMISSQN"}, min: 0, max: 1},
      %Field{name: :v_calc_bm, xml: "vCalcBM", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
      %Field{name: :v_bc, xml: "vBC", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
      %Field{name: :p_aliq_aplic, xml: "pAliqAplic", type: {:simple, "TSDec1V2"}, min: 0, max: 1},
      %Field{name: :v_issqn, xml: "vISSQN", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
      %Field{name: :v_total_ret, xml: "vTotalRet", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
      %Field{name: :v_liq, xml: "vLiq", type: {:simple, "TSDec15V2"}, min: 1, max: 1}
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
