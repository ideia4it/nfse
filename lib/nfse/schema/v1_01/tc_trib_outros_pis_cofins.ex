# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCTribOutrosPisCofins do
  @moduledoc """
  Tipo `TCTribOutrosPisCofins` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `cst` | `CST` | `TSTipoCST` | 1 | Código de Situação Tributária do PIS/COFINS (CST): 00 - Nenhum; 01 - Operação Tributável com Alíquota Básica; 02 - Operação Tributável com Alíquota Diferenciada; 03 - Operação Tributável com Alíquota por Unidade de Medida de Produto; 04 - Operação Tributável monofásica - Revenda a Alíquota Zero; 05 - Operação Tributável por Substituição Tributária; 06 - Operação Tributável a Alíquota Zero; 07 - Operação Isenta da Contribuição; 08 - Operação sem Incidência da Contribuição; 09 - Operação com Suspensão da Contribuição; 49 - Outras Operações de Saída; 50 - Operação com Direito a Crédito – Vinculada Exclusivamente a Receita Tributada no Mercado Interno; 51 - Operação com Direito a Crédito – Vinculada Exclusivamente a Receita Não-Tributada no Mercado Interno; 52 - Operação com Direito a Crédito – Vinculada Exclusivamente a Receita de Exportação; 53 - Operação com Direito a Crédito – Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno; 54 - Operação com Direito a Crédito – Vinculada a Receitas Tributadas no Mercado Interno e de Exportação; 55 - Operação com Direito a Crédito – Vinculada a Receitas Não Tributadas no Mercado Interno e de Exportação; 56 - Operação com Direito a Crédito – Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno e de Exportação; 60 - Crédito Presumido – Operação de Aquisição Vinculada Exclusivamente a Receita Tributada no Mercado Interno; 61 - Crédito Presumido – Operação de Aquisição Vinculada Exclusivamente a Receita Não-Tributada no Mercado Interno; 62 - Crédito Presumido – Operação de Aquisição Vinculada Exclusivamente a Receita de Exportação; 63 - Crédito Presumido – Operação de Aquisição Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno; 64 - Crédito Presumido – Operação de Aquisição Vinculada a Receitas Tributadas no Mercado Interno e de Exportação; 65 - Crédito Presumido – Operação de Aquisição Vinculada a Receitas Não-Tributadas no Mercado Interno e de Exportação; 66 - Crédito Presumido – Operação de Aquisição Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno e de Exportação; 67 - Crédito Presumido – Outras Operações; 70 - Operação de Aquisição sem Direito a Crédito; 71 - Operação de Aquisição com Isenção; 72 - Operação de Aquisição com Suspensão; 73 - Operação de Aquisição a Alíquota Zero; 74 - Operação de Aquisição sem Incidência da Contribuição; 75 - Operação de Aquisição por Substituição Tributária; 98 - Outras Operações de Entrada; 99 - Outras Operações; |
  | `v_bc_pis_cofins` | `vBCPisCofins` | `TSDec15V2` | 0..1 | Valor da Base de Cálculo do PIS/COFINS, relativo à apuração própria (R$). |
  | `p_aliq_pis` | `pAliqPis` | `TSDec2V2` | 0..1 | Alíquota do PIS, relativa à apuração própria (%). |
  | `p_aliq_cofins` | `pAliqCofins` | `TSDec2V2` | 0..1 | Alíquota da COFINS, relativa à apuração própria (%). |
  | `v_pis` | `vPis` | `TSDec15V2` | 0..1 | Valor do débito de PIS apuração própria (R$). |
  | `v_cofins` | `vCofins` | `TSDec15V2` | 0..1 | Valor do débito de COFINS apuração própria (R$). |
  | `tp_ret_pis_cofins` | `tpRetPisCofins` | `TSTipoRetPISCofins` | 0..1 | Tipo de retenção do PIS/COFINS: 0 - PIS/COFINS/CSLL Não Retidos; 1 - PIS/COFINS Retidos; 2 - PIS/COFINS Não Retidos; 3 - PIS/COFINS/CSLL Retidos; 4 - PIS/COFINS Retidos, CSLL Não Retido; 5 - PIS Retido, COFINS/CSLL Não Retido; 6 - COFINS Retido, PIS/CSLL Não Retido; 7 - PIS Não Retido, COFINS/CSLL Retidos; 8 - PIS/COFINS Não Retidos, CSLL Retido; 9 - COFINS Não Retido, PIS/CSLL Retidos; |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [
    :cst,
    :v_bc_pis_cofins,
    :p_aliq_pis,
    :p_aliq_cofins,
    :v_pis,
    :v_cofins,
    :tp_ret_pis_cofins
  ]

  @type t :: %__MODULE__{
          cst: String.t() | nil,
          v_bc_pis_cofins: Decimal.t() | nil,
          p_aliq_pis: Decimal.t() | nil,
          p_aliq_cofins: Decimal.t() | nil,
          v_pis: Decimal.t() | nil,
          v_cofins: Decimal.t() | nil,
          tp_ret_pis_cofins: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :cst, xml: "CST", type: {:simple, "TSTipoCST"}, min: 1, max: 1},
      %Field{
        name: :v_bc_pis_cofins,
        xml: "vBCPisCofins",
        type: {:simple, "TSDec15V2"},
        min: 0,
        max: 1
      },
      %Field{name: :p_aliq_pis, xml: "pAliqPis", type: {:simple, "TSDec2V2"}, min: 0, max: 1},
      %Field{
        name: :p_aliq_cofins,
        xml: "pAliqCofins",
        type: {:simple, "TSDec2V2"},
        min: 0,
        max: 1
      },
      %Field{name: :v_pis, xml: "vPis", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
      %Field{name: :v_cofins, xml: "vCofins", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
      %Field{
        name: :tp_ret_pis_cofins,
        xml: "tpRetPisCofins",
        type: {:simple, "TSTipoRetPISCofins"},
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
