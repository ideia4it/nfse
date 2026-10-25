# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCInfoIBSCBS do
  @moduledoc """
  Tipo `TCRTCInfoIBSCBS` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `fin_nf_se` | `finNFSe` | `TSRTCFinNFSe` | 1 | Indicador da finalidade da emissão de NFS-e |
  | `ind_final` | `indFinal` | `TSRTCIndFinal` | 0..1 | Indica operação de uso ou consumo pessoal (art. 57) |
  | `c_ind_op` | `cIndOp` | `TSRTCCodIndOp` | 1 | Código indicador da operação de fornecimento, conforme tabela "código indicador de operação" |
  | `tp_oper` | `tpOper` | `TSRTCTpOper` | 0..1 | Tipo de Operação com Entes Governamentais ou outros serviços sobre bens imóveis |
  | `g_ref_nf_se` | `gRefNFSe` | `Nfse.Schema.V1_01.TCInfoRefNFSe` | 0..1 | Grupo de NFS-e referenciadas |
  | `tp_ente_gov` | `tpEnteGov` | `TSRTCTpEnteGov` | 0..1 | Tipo de ente governamental |
  | `ind_dest` | `indDest` | `TSRTCIndDest` | 1 | A respeito do Destinatário dos serviços |
  | `dest` | `dest` | `Nfse.Schema.V1_01.TCRTCInfoDest` | 0..1 | Grupo de informações relativas ao Destinatário |
  | `imovel` | `imovel` | `Nfse.Schema.V1_01.TCRTCInfoImovel` | 0..1 | Grupo de informações de operações relacionadas a bens imóveis, exceto obras |
  | `valores` | `valores` | `Nfse.Schema.V1_01.TCRTCInfoValoresIBSCBS` | 1 | Grupo de informações relativas aos valores do serviço prestado para IBS e CBS |
  """

  alias Nfse.Schema.{Field, Runtime}

  alias Nfse.Schema.V1_01.{
    SimpleTypes,
    TCInfoRefNFSe,
    TCRTCInfoDest,
    TCRTCInfoImovel,
    TCRTCInfoValoresIBSCBS
  }

  defstruct [
    :fin_nf_se,
    :ind_final,
    :c_ind_op,
    :tp_oper,
    :g_ref_nf_se,
    :tp_ente_gov,
    :ind_dest,
    :dest,
    :imovel,
    :valores
  ]

  @type t :: %__MODULE__{
          fin_nf_se: String.t() | nil,
          ind_final: String.t() | nil,
          c_ind_op: String.t() | nil,
          tp_oper: String.t() | nil,
          g_ref_nf_se: TCInfoRefNFSe.t() | nil,
          tp_ente_gov: String.t() | nil,
          ind_dest: String.t() | nil,
          dest: TCRTCInfoDest.t() | nil,
          imovel: TCRTCInfoImovel.t() | nil,
          valores: TCRTCInfoValoresIBSCBS.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :fin_nf_se, xml: "finNFSe", type: {:simple, "TSRTCFinNFSe"}, min: 1, max: 1},
      %Field{name: :ind_final, xml: "indFinal", type: {:simple, "TSRTCIndFinal"}, min: 0, max: 1},
      %Field{name: :c_ind_op, xml: "cIndOp", type: {:simple, "TSRTCCodIndOp"}, min: 1, max: 1},
      %Field{name: :tp_oper, xml: "tpOper", type: {:simple, "TSRTCTpOper"}, min: 0, max: 1},
      %Field{
        name: :g_ref_nf_se,
        xml: "gRefNFSe",
        type: {:complex, TCInfoRefNFSe},
        min: 0,
        max: 1
      },
      %Field{
        name: :tp_ente_gov,
        xml: "tpEnteGov",
        type: {:simple, "TSRTCTpEnteGov"},
        min: 0,
        max: 1
      },
      %Field{name: :ind_dest, xml: "indDest", type: {:simple, "TSRTCIndDest"}, min: 1, max: 1},
      %Field{name: :dest, xml: "dest", type: {:complex, TCRTCInfoDest}, min: 0, max: 1},
      %Field{name: :imovel, xml: "imovel", type: {:complex, TCRTCInfoImovel}, min: 0, max: 1},
      %Field{
        name: :valores,
        xml: "valores",
        type: {:complex, TCRTCInfoValoresIBSCBS},
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
