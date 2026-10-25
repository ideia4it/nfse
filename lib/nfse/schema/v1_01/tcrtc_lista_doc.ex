# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCListaDoc do
  @moduledoc """
  Tipo `TCRTCListaDoc` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `d_fe_nacional` | `dFeNacional` | `Nfse.Schema.V1_01.TCRTCListaDocDFe` | 1, escolha 1 | Grupo de informações de documentos fiscais eletrônicos que se encontram no repositório nacional |
  | `doc_fiscal_outro` | `docFiscalOutro` | `Nfse.Schema.V1_01.TCRTCListaDocFiscalOutro` | 1, escolha 1 | Grupo de informações de documento fiscais, eletrônicos ou não, que não se encontram no repositório nacional |
  | `doc_outro` | `docOutro` | `Nfse.Schema.V1_01.TCRTCListaDocOutro` | 1, escolha 1 | Grupo de informações de documento não fiscal. |
  | `fornec` | `fornec` | `Nfse.Schema.V1_01.TCRTCListaDocFornec` | 0..1 | Grupo de informações do fornecedor do documento referenciado |
  | `dt_emi_doc` | `dtEmiDoc` | `TSData` | 1 | Data da emissão do documento dedutível Ano, mês e dia (AAAA-MM-DD) |
  | `dt_comp_doc` | `dtCompDoc` | `TSData` | 1 | Data da competência do documento dedutível Ano, mês e dia (AAAA-MM-DD) |
  | `tp_ree_rep_res` | `tpReeRepRes` | `TSRTCTpReeRepRes` | 1 | Tipo de valor incluído neste documento, recebido por motivo de estarem relacionadas a operações de terceiros, objeto de reembolso, repasse ou ressarcimento pelo recebedor, já tributados e aqui referenciados |
  | `x_tp_ree_rep_res` | `xTpReeRepRes` | `TSDesc150` | 0..1 | Descrição do reembolso ou ressarcimento quando a opção é "99 – Outros reembolsos ou ressarcimentos recebidos por valores pagos relativos a operações por conta e ordem de terceiro" |
  | `vlr_ree_rep_res` | `vlrReeRepRes` | `TSDec15V2` | 1 | Valor monetário (total ou parcial, conforme documento informado) utilizado para não inclusão na base de cálculo do ISS e do IBS e da CBS da NFS-e que está sendo emitida (R$) |

  Escolha 1: exatamente um entre `d_fe_nacional`, `doc_fiscal_outro` e `doc_outro`.
  """

  alias Nfse.Schema.{Field, Runtime}

  alias Nfse.Schema.V1_01.{
    SimpleTypes,
    TCRTCListaDocDFe,
    TCRTCListaDocFiscalOutro,
    TCRTCListaDocFornec,
    TCRTCListaDocOutro
  }

  defstruct [
    :d_fe_nacional,
    :doc_fiscal_outro,
    :doc_outro,
    :fornec,
    :dt_emi_doc,
    :dt_comp_doc,
    :tp_ree_rep_res,
    :x_tp_ree_rep_res,
    :vlr_ree_rep_res
  ]

  @type t :: %__MODULE__{
          d_fe_nacional: TCRTCListaDocDFe.t() | nil,
          doc_fiscal_outro: TCRTCListaDocFiscalOutro.t() | nil,
          doc_outro: TCRTCListaDocOutro.t() | nil,
          fornec: TCRTCListaDocFornec.t() | nil,
          dt_emi_doc: Date.t() | nil,
          dt_comp_doc: Date.t() | nil,
          tp_ree_rep_res: String.t() | nil,
          x_tp_ree_rep_res: String.t() | nil,
          vlr_ree_rep_res: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :d_fe_nacional,
        xml: "dFeNacional",
        type: {:complex, TCRTCListaDocDFe},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :doc_fiscal_outro,
        xml: "docFiscalOutro",
        type: {:complex, TCRTCListaDocFiscalOutro},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :doc_outro,
        xml: "docOutro",
        type: {:complex, TCRTCListaDocOutro},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{name: :fornec, xml: "fornec", type: {:complex, TCRTCListaDocFornec}, min: 0, max: 1},
      %Field{name: :dt_emi_doc, xml: "dtEmiDoc", type: {:simple, "TSData"}, min: 1, max: 1},
      %Field{name: :dt_comp_doc, xml: "dtCompDoc", type: {:simple, "TSData"}, min: 1, max: 1},
      %Field{
        name: :tp_ree_rep_res,
        xml: "tpReeRepRes",
        type: {:simple, "TSRTCTpReeRepRes"},
        min: 1,
        max: 1
      },
      %Field{
        name: :x_tp_ree_rep_res,
        xml: "xTpReeRepRes",
        type: {:simple, "TSDesc150"},
        min: 0,
        max: 1
      },
      %Field{
        name: :vlr_ree_rep_res,
        xml: "vlrReeRepRes",
        type: {:simple, "TSDec15V2"},
        min: 1,
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
