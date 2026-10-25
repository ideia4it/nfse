# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCInfNFSe do
  @moduledoc """
  Tipo `TCInfNFSe` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `x_loc_emi` | `xLocEmi` | `TSDesc150` | 1 | Descrição do código do IBGE do município emissor da NFS-e. |
  | `x_loc_prestacao` | `xLocPrestacao` | `TSDesc150` | 1 | Descrição do local da prestação do serviço. |
  | `n_nf_se` | `nNFSe` | `TSNNFSe` | 1 | Número sequencial por tipo de emitente da NFS-e. A Sefin Nacional NFS-e irá gerar o número da NFS-e de forma sequencial por emitente. Por se tratar de um ambiente altamente transacional, a Sefin Nacional NFS-e não irá reutilizar números inutilizados durante a geração da NFS-e. |
  | `c_loc_incid` | `cLocIncid` | `TSCodMunIBGE` | 0..1 | O código de município utilizado pelo Sistema Nacional NFS-e é o código definido para cada município pertencente ao ""Anexo V – Tabela de Código de Municípios do IBGE"", que consta ao final do Manual de Orientação ao Contribuinte do ISSQN para a Sefin Nacional NFS-e. O município de incidência do ISSQN é determinado automaticamente pelo sistema, conforme regras do aspecto espacial da lei complementar federal (LC 116/03) que são válidas para todos os municípios. http://www.planalto.gov.br/ccivil_03/Leis/LCP/Lcp116.htm |
  | `x_loc_incid` | `xLocIncid` | `TSDesc150` | 0..1 | A descrição do código de município utilizado pelo Sistema Nacional NFS-e é o nome de cada município pertencente ao "Anexo V – Tabela de Código de Municípios do IBGE", que consta ao final do Manual de Orientação ao Contribuinte do ISSQN para a Sefin Nacional NFS-e. |
  | `x_trib_nac` | `xTribNac` | `TSDesc600` | 1 | Descrição do código de tributação nacional do ISSQN. |
  | `x_trib_mun` | `xTribMun` | `TSDesc600` | 0..1 | Descrição do código de tributação municipal do ISSQN. |
  | `x_nbs` | `xNBS` | `TSDesc600` | 0..1 | Descrição do código da NBS. |
  | `ver_aplic` | `verAplic` | `TSVerAplic` | 1 | Versão do aplicativo que gerou a NFS-e |
  | `amb_ger` | `ambGer` | `TSAmbGeradorNFSe` | 1 | Ambiente gerador da NFS-e |
  | `tp_emis` | `tpEmis` | `TSTipoEmissao` | 1 | Processo de Emissão da DPS: 1 - Emissão com aplicativo do contribuinte (via Web Service); 2 - Emissão com aplicativo disponibilizado pelo fisco (Web); 3 - Emissão com aplicativo disponibilizado pelo fisco (App); |
  | `proc_emi` | `procEmi` | `TSProcEmissao` | 0..1 | Processo de Emissão da DPS: 1 - Emissão com aplicativo do contribuinte (via Web Service); 2 - Emissão com aplicativo disponibilizado pelo fisco (Web); 3 - Emissão com aplicativo disponibilizado pelo fisco (App); |
  | `c_stat` | `cStat` | `TStat` | 1 | Código do Status da mensagem |
  | `dh_proc` | `dhProc` | `TSDateTimeUTC` | 1 | Data/Hora da validação da DPS e geração da NFS-e. Data e hora no formato UTC (Universal Coordinated Time):AAAA-MM-DDThh:mm:ssTZD |
  | `n_df_se` | `nDFSe` | `TSNDFSe` | 1 | Número sequencial do documento gerado por ambiente gerador de DFSe do múnicípio. |
  | `emit` | `emit` | `Nfse.Schema.V1_00.TCEmitente` | 1 | Grupo de informações da DPS relativas ao emitente da NFS-e |
  | `valores` | `valores` | `Nfse.Schema.V1_00.TCValoresNFSe` | 1 | Grupo de valores referentes ao Serviço Prestado |
  | `dps` | `DPS` | `Nfse.Schema.V1_00.TCDPS` | 1 | Grupo de informações da DPS relativas ao serviço prestado |
  | `id` | `Id`, atributo | `TSIdNFSe` | 1 |  |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCDPS, TCEmitente, TCValoresNFSe}

  defstruct [
    :x_loc_emi,
    :x_loc_prestacao,
    :n_nf_se,
    :c_loc_incid,
    :x_loc_incid,
    :x_trib_nac,
    :x_trib_mun,
    :x_nbs,
    :ver_aplic,
    :amb_ger,
    :tp_emis,
    :proc_emi,
    :c_stat,
    :dh_proc,
    :n_df_se,
    :emit,
    :valores,
    :dps,
    :id
  ]

  @type t :: %__MODULE__{
          x_loc_emi: String.t() | nil,
          x_loc_prestacao: String.t() | nil,
          n_nf_se: String.t() | nil,
          c_loc_incid: String.t() | nil,
          x_loc_incid: String.t() | nil,
          x_trib_nac: String.t() | nil,
          x_trib_mun: String.t() | nil,
          x_nbs: String.t() | nil,
          ver_aplic: String.t() | nil,
          amb_ger: String.t() | nil,
          tp_emis: String.t() | nil,
          proc_emi: String.t() | nil,
          c_stat: String.t() | nil,
          dh_proc: DateTime.t() | nil,
          n_df_se: String.t() | nil,
          emit: TCEmitente.t() | nil,
          valores: TCValoresNFSe.t() | nil,
          dps: TCDPS.t() | nil,
          id: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []

  def __schema__(:attributes),
    do: [%Field{name: :id, xml: "Id", type: {:simple, "TSIdNFSe"}, min: 1, max: 1}]

  def __schema__(:fields),
    do: [
      %Field{name: :x_loc_emi, xml: "xLocEmi", type: {:simple, "TSDesc150"}, min: 1, max: 1},
      %Field{
        name: :x_loc_prestacao,
        xml: "xLocPrestacao",
        type: {:simple, "TSDesc150"},
        min: 1,
        max: 1
      },
      %Field{name: :n_nf_se, xml: "nNFSe", type: {:simple, "TSNNFSe"}, min: 1, max: 1},
      %Field{
        name: :c_loc_incid,
        xml: "cLocIncid",
        type: {:simple, "TSCodMunIBGE"},
        min: 0,
        max: 1
      },
      %Field{name: :x_loc_incid, xml: "xLocIncid", type: {:simple, "TSDesc150"}, min: 0, max: 1},
      %Field{name: :x_trib_nac, xml: "xTribNac", type: {:simple, "TSDesc600"}, min: 1, max: 1},
      %Field{name: :x_trib_mun, xml: "xTribMun", type: {:simple, "TSDesc600"}, min: 0, max: 1},
      %Field{name: :x_nbs, xml: "xNBS", type: {:simple, "TSDesc600"}, min: 0, max: 1},
      %Field{name: :ver_aplic, xml: "verAplic", type: {:simple, "TSVerAplic"}, min: 1, max: 1},
      %Field{name: :amb_ger, xml: "ambGer", type: {:simple, "TSAmbGeradorNFSe"}, min: 1, max: 1},
      %Field{name: :tp_emis, xml: "tpEmis", type: {:simple, "TSTipoEmissao"}, min: 1, max: 1},
      %Field{name: :proc_emi, xml: "procEmi", type: {:simple, "TSProcEmissao"}, min: 0, max: 1},
      %Field{name: :c_stat, xml: "cStat", type: {:simple, "TStat"}, min: 1, max: 1},
      %Field{name: :dh_proc, xml: "dhProc", type: {:simple, "TSDateTimeUTC"}, min: 1, max: 1},
      %Field{name: :n_df_se, xml: "nDFSe", type: {:simple, "TSNDFSe"}, min: 1, max: 1},
      %Field{name: :emit, xml: "emit", type: {:complex, TCEmitente}, min: 1, max: 1},
      %Field{name: :valores, xml: "valores", type: {:complex, TCValoresNFSe}, min: 1, max: 1},
      %Field{name: :dps, xml: "DPS", type: {:complex, TCDPS}, min: 1, max: 1}
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
