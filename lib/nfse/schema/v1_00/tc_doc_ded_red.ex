# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCDocDedRed do
  @moduledoc """
  Tipo `TCDocDedRed` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `ch_nf_se` | `chNFSe` | `TSChaveNFSe` | 1, escolha 1 | Chave de Acesso da NFS-e (Padrão Nacional) |
  | `ch_n_fe` | `chNFe` | `TSChaveNFe` | 1, escolha 1 | Chave de Acesso da NF-e |
  | `nf_se_mun` | `NFSeMun` | `Nfse.Schema.V1_00.TCDocOutNFSe` | 1, escolha 1 | Grupo de informações de Outras NFS-e (Padrão anterior de NFS-e) |
  | `nfnfs` | `NFNFS` | `Nfse.Schema.V1_00.TCDocNFNFS` | 1, escolha 1 | Grupo de informações de NF ou NFS (Modelo não eletrônico) |
  | `n_doc_fisc` | `nDocFisc` | `TSDesc255` | 1, escolha 1 | Número de documento fiscal |
  | `n_doc` | `nDoc` | `TSDesc255` | 1, escolha 1 | Número de documento não fiscal |
  | `tp_ded_red` | `tpDedRed` | `TSIdeDedRed` | 1 | Identificação da Dedução/Redução: 1 – Alimentação e bebidas/frigobar; 2 – Materiais; 3 – Produção externa; 4 – Reembolso de despesas; 5 – Repasse consorciado; 6 – Repasse plano de saúde; 7 – Serviços; 8 – Subempreitada de mão de obra; 9 - Profissional parceiro; 99 – Outras deduções; |
  | `x_desc_out_ded` | `xDescOutDed` | `TSDescOutDedRed` | 0..1 | Descrição da Dedução/Redução quando a opção é "99 – Outras Deduções" |
  | `dt_emi_doc` | `dtEmiDoc` | `xs:date` | 1 | Data da emissão do documento dedutível. Ano, mês e dia (AAAA-MM-DD) |
  | `v_dedutivel_redutivel` | `vDedutivelRedutivel` | `TSDec15V2` | 1 | Valor monetário total dedutível/redutível no documento informado (R$). Este é o valor total no documento informado que é passível de dedução/redução. |
  | `v_deducao_reducao` | `vDeducaoReducao` | `TSDec15V2` | 1 | Valor monetário utilizado para dedução/redução do valor do serviço da NFS-e que está sendo emitida (R$). Deve ser menor ou igual ao valor deduzível/redutível (vDedutivelRedutivel). |
  | `fornec` | `fornec` | `Nfse.Schema.V1_00.TCInfoPessoa` | 0..1 | Grupo de informações do Fornecedor em Deduções de Serviços |

  Escolha 1: exatamente um entre `ch_nf_se`, `ch_n_fe`, `nf_se_mun`, `nfnfs`, `n_doc_fisc` e `n_doc`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCDocNFNFS, TCDocOutNFSe, TCInfoPessoa}

  defstruct [
    :ch_nf_se,
    :ch_n_fe,
    :nf_se_mun,
    :nfnfs,
    :n_doc_fisc,
    :n_doc,
    :tp_ded_red,
    :x_desc_out_ded,
    :dt_emi_doc,
    :v_dedutivel_redutivel,
    :v_deducao_reducao,
    :fornec
  ]

  @type t :: %__MODULE__{
          ch_nf_se: String.t() | nil,
          ch_n_fe: String.t() | nil,
          nf_se_mun: TCDocOutNFSe.t() | nil,
          nfnfs: TCDocNFNFS.t() | nil,
          n_doc_fisc: String.t() | nil,
          n_doc: String.t() | nil,
          tp_ded_red: String.t() | nil,
          x_desc_out_ded: String.t() | nil,
          dt_emi_doc: Date.t() | nil,
          v_dedutivel_redutivel: Decimal.t() | nil,
          v_deducao_reducao: Decimal.t() | nil,
          fornec: TCInfoPessoa.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :ch_nf_se,
        xml: "chNFSe",
        type: {:simple, "TSChaveNFSe"},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :ch_n_fe,
        xml: "chNFe",
        type: {:simple, "TSChaveNFe"},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :nf_se_mun,
        xml: "NFSeMun",
        type: {:complex, TCDocOutNFSe},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{name: :nfnfs, xml: "NFNFS", type: {:complex, TCDocNFNFS}, min: 1, max: 1, choice: 0},
      %Field{
        name: :n_doc_fisc,
        xml: "nDocFisc",
        type: {:simple, "TSDesc255"},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{name: :n_doc, xml: "nDoc", type: {:simple, "TSDesc255"}, min: 1, max: 1, choice: 0},
      %Field{name: :tp_ded_red, xml: "tpDedRed", type: {:simple, "TSIdeDedRed"}, min: 1, max: 1},
      %Field{
        name: :x_desc_out_ded,
        xml: "xDescOutDed",
        type: {:simple, "TSDescOutDedRed"},
        min: 0,
        max: 1
      },
      %Field{name: :dt_emi_doc, xml: "dtEmiDoc", type: {:simple, "xs:date"}, min: 1, max: 1},
      %Field{
        name: :v_dedutivel_redutivel,
        xml: "vDedutivelRedutivel",
        type: {:simple, "TSDec15V2"},
        min: 1,
        max: 1
      },
      %Field{
        name: :v_deducao_reducao,
        xml: "vDeducaoReducao",
        type: {:simple, "TSDec15V2"},
        min: 1,
        max: 1
      },
      %Field{name: :fornec, xml: "fornec", type: {:complex, TCInfoPessoa}, min: 0, max: 1}
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
