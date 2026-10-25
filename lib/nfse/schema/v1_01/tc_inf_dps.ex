# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCInfDPS do
  @moduledoc """
  Tipo `TCInfDPS` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `tp_amb` | `tpAmb` | `TSTipoAmbiente` | 1 | Identificação do Ambiente: 1 - Produção; 2 - Homologação |
  | `dh_emi` | `dhEmi` | `TSDateTimeUTC` | 1 | Data e hora da emissão do DPS. Data e hora no formato UTC (Universal Coordinated Time): AAAA-MM-DDThh:mm:ssTZD |
  | `ver_aplic` | `verAplic` | `TSVerAplic` | 1 | Versão do aplicativo que gerou o DPS |
  | `serie` | `serie` | `TSSerieDPS` | 1 | Número do equipamento emissor do DPS ou série do DPS |
  | `n_dps` | `nDPS` | `TSNumDPS` | 1 | Número do DPS |
  | `d_compet` | `dCompet` | `TSData` | 1 | Data em que se iniciou a prestação do serviço: Dia, mês e ano (AAAAMMDD) |
  | `tp_emit` | `tpEmit` | `TSEmitenteDPS` | 1 | Emitente da DPS: 1 - Prestador; 2 - Tomador; 3 - Intermediário |
  | `c_motivo_emis_ti` | `cMotivoEmisTI` | `TSMotivoEmisTI` | 0..1 | Motivo da Emissão da DPS pelo Tomador/Intermediário: 1 - Importação de Serviço; 2 - Tomador/Intermediário obrigado a emitir NFS-e por legislação municipal; 3 - Tomador/Intermediário emitindo NFS-e por recusa de emissão pelo prestador; 4 - Tomador/Intermediário emitindo por rejeitar a NFS-e emitida pelo prestador; |
  | `ch_nf_se_rej` | `chNFSeRej` | `TSChaveNFSe` | 0..1 | Chave de Acesso da NFS-e rejeitada pelo Tomador/Intermediário. |
  | `c_loc_emi` | `cLocEmi` | `TSCodMunIBGE` | 1 | O código de município utilizado pelo Sistema Nacional NFS-e é o código definido para cada município pertencente ao ""Anexo V – Tabela de Código de Municípios do IBGE"", que consta ao final do Manual de Orientação ao Contribuinte do ISSQN para a Sefin Nacional NFS-e. O município emissor da NFS-e é aquele município em que o emitente da DPS está cadastrado e autorizado a "emitir uma NFS-e", ou seja, emitir uma DPS para que o sistema nacional valide as informações nela prestadas e gere a NFS-e correspondente para o emitente. Para que o sistema nacional emita a NFS-e o município emissor deve ser conveniado e estar ativo no sistema nacional. Além disso o convênio do município deve permitir que os contribuintes do município utilize os emissores públicos do Sistema Nacional NFS-e |
  | `subst` | `subst` | `Nfse.Schema.V1_01.TCSubstituicao` | 0..1 | Dados da NFS-e a ser substituída |
  | `prest` | `prest` | `Nfse.Schema.V1_01.TCInfoPrestador` | 1 | Grupo de informações do DPS relativas ao Prestador de Serviços |
  | `toma` | `toma` | `Nfse.Schema.V1_01.TCInfoPessoa` | 0..1 | Grupo de informações do DPS relativas ao Tomador de Serviços |
  | `interm` | `interm` | `Nfse.Schema.V1_01.TCInfoPessoa` | 0..1 | Grupo de informações do DPS relativas ao Intermediário de Serviços |
  | `serv` | `serv` | `Nfse.Schema.V1_01.TCServ` | 1 | Grupo de informações do DPS relativas ao Serviço Prestado |
  | `valores` | `valores` | `Nfse.Schema.V1_01.TCInfoValores` | 1 | Grupo de informações relativas à valores do serviço prestado |
  | `ibscbs` | `IBSCBS` | `Nfse.Schema.V1_01.TCRTCInfoIBSCBS` | 0..1 | Grupo de informações declaradas pelo emitente referentes ao IBS e à CBS |
  | `id` | `Id`, atributo | `TSIdDPS` | 1 |  |
  """

  alias Nfse.Schema.{Field, Runtime}

  alias Nfse.Schema.V1_01.{
    SimpleTypes,
    TCInfoPessoa,
    TCInfoPrestador,
    TCInfoValores,
    TCRTCInfoIBSCBS,
    TCServ,
    TCSubstituicao
  }

  defstruct [
    :tp_amb,
    :dh_emi,
    :ver_aplic,
    :serie,
    :n_dps,
    :d_compet,
    :tp_emit,
    :c_motivo_emis_ti,
    :ch_nf_se_rej,
    :c_loc_emi,
    :subst,
    :prest,
    :toma,
    :interm,
    :serv,
    :valores,
    :ibscbs,
    :id
  ]

  @type t :: %__MODULE__{
          tp_amb: String.t() | nil,
          dh_emi: DateTime.t() | nil,
          ver_aplic: String.t() | nil,
          serie: String.t() | nil,
          n_dps: String.t() | nil,
          d_compet: Date.t() | nil,
          tp_emit: String.t() | nil,
          c_motivo_emis_ti: String.t() | nil,
          ch_nf_se_rej: String.t() | nil,
          c_loc_emi: String.t() | nil,
          subst: TCSubstituicao.t() | nil,
          prest: TCInfoPrestador.t() | nil,
          toma: TCInfoPessoa.t() | nil,
          interm: TCInfoPessoa.t() | nil,
          serv: TCServ.t() | nil,
          valores: TCInfoValores.t() | nil,
          ibscbs: TCRTCInfoIBSCBS.t() | nil,
          id: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []

  def __schema__(:attributes),
    do: [%Field{name: :id, xml: "Id", type: {:simple, "TSIdDPS"}, min: 1, max: 1}]

  def __schema__(:fields),
    do: [
      %Field{name: :tp_amb, xml: "tpAmb", type: {:simple, "TSTipoAmbiente"}, min: 1, max: 1},
      %Field{name: :dh_emi, xml: "dhEmi", type: {:simple, "TSDateTimeUTC"}, min: 1, max: 1},
      %Field{name: :ver_aplic, xml: "verAplic", type: {:simple, "TSVerAplic"}, min: 1, max: 1},
      %Field{name: :serie, xml: "serie", type: {:simple, "TSSerieDPS"}, min: 1, max: 1},
      %Field{name: :n_dps, xml: "nDPS", type: {:simple, "TSNumDPS"}, min: 1, max: 1},
      %Field{name: :d_compet, xml: "dCompet", type: {:simple, "TSData"}, min: 1, max: 1},
      %Field{name: :tp_emit, xml: "tpEmit", type: {:simple, "TSEmitenteDPS"}, min: 1, max: 1},
      %Field{
        name: :c_motivo_emis_ti,
        xml: "cMotivoEmisTI",
        type: {:simple, "TSMotivoEmisTI"},
        min: 0,
        max: 1
      },
      %Field{
        name: :ch_nf_se_rej,
        xml: "chNFSeRej",
        type: {:simple, "TSChaveNFSe"},
        min: 0,
        max: 1
      },
      %Field{name: :c_loc_emi, xml: "cLocEmi", type: {:simple, "TSCodMunIBGE"}, min: 1, max: 1},
      %Field{name: :subst, xml: "subst", type: {:complex, TCSubstituicao}, min: 0, max: 1},
      %Field{name: :prest, xml: "prest", type: {:complex, TCInfoPrestador}, min: 1, max: 1},
      %Field{name: :toma, xml: "toma", type: {:complex, TCInfoPessoa}, min: 0, max: 1},
      %Field{name: :interm, xml: "interm", type: {:complex, TCInfoPessoa}, min: 0, max: 1},
      %Field{name: :serv, xml: "serv", type: {:complex, TCServ}, min: 1, max: 1},
      %Field{name: :valores, xml: "valores", type: {:complex, TCInfoValores}, min: 1, max: 1},
      %Field{name: :ibscbs, xml: "IBSCBS", type: {:complex, TCRTCInfoIBSCBS}, min: 0, max: 1}
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
