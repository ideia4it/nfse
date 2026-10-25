# Gerado por `mix nfse.gen` a partir de tiposEventos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCInfPedReg do
  @moduledoc """
  Tipo `TCInfPedReg` do leiaute 1.01, em `tiposEventos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `tp_amb` | `tpAmb` | `TSTipoAmbiente` | 1 | Tipo de ambiente: 1 - Produção; 2 - Homologação; |
  | `ver_aplic` | `verAplic` | `TSVerAplic` | 1 | Versão do aplicativo que gerou o pedido de registro de evento |
  | `dh_evento` | `dhEvento` | `TSDateTimeUTC` | 1 | Data e hora do evento no formato AAAA-MM-DDThh:mm:ssTZD (UTC - Universal Coordinated Time, onde TZD pode ser -02:00 (Fernando de Noronha), -03:00 (Brasília) ou -04:00 (Manaus), no horário de verão serão -01:00, -02:00 e -03:00. Ex.: 2010-08-19T13:00:15-03:00. |
  | `cnpj_autor` | `CNPJAutor` | `TSCNPJ` | 1, escolha 1 | Número de inscrição federal (CNPJ) do autor do evento. CNPJ do autor do evento (parte interessada ou pessoa que figure na NFS-e. O autor do evento não é o procurador) |
  | `cpf_autor` | `CPFAutor` | `TSCPF` | 1, escolha 1 | Número de inscrição federal (CPF) do autor do evento. CPF do autor do evento (parte interessada ou pessoa que figure na NFS-e como prestador, tomador, intermediário. O autor do evento poderá ser o procurador) |
  | `ch_nfse` | `chNFSe` | `TSChaveNFSe` | 1 | Identificador da NFS-e à qual o evento será vinculado |
  | `e101101` | `e101101` | `Nfse.Schema.V1_01.TE101101` | 1, escolha 2 | Evento de cancelamento |
  | `e105102` | `e105102` | `Nfse.Schema.V1_01.TE105102` | 1, escolha 2 | Evento de cancelamento por substituição |
  | `e101103` | `e101103` | `Nfse.Schema.V1_01.TE101103` | 1, escolha 2 | Solicitação de Análise Fiscal para Cancelamento de NFS-e |
  | `e105104` | `e105104` | `Nfse.Schema.V1_01.TE105104` | 1, escolha 2 | Cancelamento de NFS-e Deferido por Análise Fiscal |
  | `e105105` | `e105105` | `Nfse.Schema.V1_01.TE105105` | 1, escolha 2 | Cancelamento de NFS-e Indeferido por Análise Fiscal |
  | `e202201` | `e202201` | `Nfse.Schema.V1_01.TE202201` | 1, escolha 2 | Confirmação do Prestador |
  | `e203202` | `e203202` | `Nfse.Schema.V1_01.TE203202` | 1, escolha 2 | Confirmação do Tomador |
  | `e204203` | `e204203` | `Nfse.Schema.V1_01.TE204203` | 1, escolha 2 | Confirmação do Intermediário |
  | `e205204` | `e205204` | `Nfse.Schema.V1_01.TE205204` | 1, escolha 2 | Confirmação Tácita |
  | `e202205` | `e202205` | `Nfse.Schema.V1_01.TE202205` | 1, escolha 2 | Rejeição do Prestador |
  | `e203206` | `e203206` | `Nfse.Schema.V1_01.TE203206` | 1, escolha 2 | Rejeição do Tomador |
  | `e204207` | `e204207` | `Nfse.Schema.V1_01.TE204207` | 1, escolha 2 | Rejeição do Intermediário |
  | `e205208` | `e205208` | `Nfse.Schema.V1_01.TE205208` | 1, escolha 2 | Anulação da Rejeição |
  | `e305101` | `e305101` | `Nfse.Schema.V1_01.TE305101` | 1, escolha 2 | Cancelamento de NFS-e por Ofício |
  | `e305102` | `e305102` | `Nfse.Schema.V1_01.TE305102` | 1, escolha 2 | Bloqueio de NFS-e por Ofício |
  | `e305103` | `e305103` | `Nfse.Schema.V1_01.TE305103` | 1, escolha 2 | Desbloqueio de NFS-e por Ofício |
  | `id` | `Id`, atributo | `TSIdPedRegEvt` | 1 |  |

  Escolha 1: exatamente um entre `cnpj_autor` e `cpf_autor`.

  Escolha 2: exatamente um entre `e101101`, `e105102`, `e101103`, `e105104`, `e105105`, `e202201`, `e203202`, `e204203`, `e205204`, `e202205`, `e203206`, `e204207`, `e205208`, `e305101`, `e305102` e `e305103`.
  """

  alias Nfse.Schema.{Field, Runtime}

  alias Nfse.Schema.V1_01.{
    SimpleTypes,
    TE101101,
    TE101103,
    TE105102,
    TE105104,
    TE105105,
    TE202201,
    TE202205,
    TE203202,
    TE203206,
    TE204203,
    TE204207,
    TE205204,
    TE205208,
    TE305101,
    TE305102,
    TE305103
  }

  defstruct [
    :tp_amb,
    :ver_aplic,
    :dh_evento,
    :cnpj_autor,
    :cpf_autor,
    :ch_nfse,
    :e101101,
    :e105102,
    :e101103,
    :e105104,
    :e105105,
    :e202201,
    :e203202,
    :e204203,
    :e205204,
    :e202205,
    :e203206,
    :e204207,
    :e205208,
    :e305101,
    :e305102,
    :e305103,
    :id
  ]

  @type t :: %__MODULE__{
          tp_amb: String.t() | nil,
          ver_aplic: String.t() | nil,
          dh_evento: DateTime.t() | nil,
          cnpj_autor: String.t() | nil,
          cpf_autor: String.t() | nil,
          ch_nfse: String.t() | nil,
          e101101: TE101101.t() | nil,
          e105102: TE105102.t() | nil,
          e101103: TE101103.t() | nil,
          e105104: TE105104.t() | nil,
          e105105: TE105105.t() | nil,
          e202201: TE202201.t() | nil,
          e203202: TE203202.t() | nil,
          e204203: TE204203.t() | nil,
          e205204: TE205204.t() | nil,
          e202205: TE202205.t() | nil,
          e203206: TE203206.t() | nil,
          e204207: TE204207.t() | nil,
          e205208: TE205208.t() | nil,
          e305101: TE305101.t() | nil,
          e305102: TE305102.t() | nil,
          e305103: TE305103.t() | nil,
          id: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}, %{index: 1, min: 1}]

  def __schema__(:attributes),
    do: [%Field{name: :id, xml: "Id", type: {:simple, "TSIdPedRegEvt"}, min: 1, max: 1}]

  def __schema__(:fields),
    do: [
      %Field{name: :tp_amb, xml: "tpAmb", type: {:simple, "TSTipoAmbiente"}, min: 1, max: 1},
      %Field{name: :ver_aplic, xml: "verAplic", type: {:simple, "TSVerAplic"}, min: 1, max: 1},
      %Field{name: :dh_evento, xml: "dhEvento", type: {:simple, "TSDateTimeUTC"}, min: 1, max: 1},
      %Field{
        name: :cnpj_autor,
        xml: "CNPJAutor",
        type: {:simple, "TSCNPJ"},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :cpf_autor,
        xml: "CPFAutor",
        type: {:simple, "TSCPF"},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{name: :ch_nfse, xml: "chNFSe", type: {:simple, "TSChaveNFSe"}, min: 1, max: 1},
      %Field{
        name: :e101101,
        xml: "e101101",
        type: {:complex, TE101101},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e105102,
        xml: "e105102",
        type: {:complex, TE105102},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e101103,
        xml: "e101103",
        type: {:complex, TE101103},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e105104,
        xml: "e105104",
        type: {:complex, TE105104},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e105105,
        xml: "e105105",
        type: {:complex, TE105105},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e202201,
        xml: "e202201",
        type: {:complex, TE202201},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e203202,
        xml: "e203202",
        type: {:complex, TE203202},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e204203,
        xml: "e204203",
        type: {:complex, TE204203},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e205204,
        xml: "e205204",
        type: {:complex, TE205204},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e202205,
        xml: "e202205",
        type: {:complex, TE202205},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e203206,
        xml: "e203206",
        type: {:complex, TE203206},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e204207,
        xml: "e204207",
        type: {:complex, TE204207},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e205208,
        xml: "e205208",
        type: {:complex, TE205208},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e305101,
        xml: "e305101",
        type: {:complex, TE305101},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e305102,
        xml: "e305102",
        type: {:complex, TE305102},
        min: 1,
        max: 1,
        choice: 1
      },
      %Field{
        name: :e305103,
        xml: "e305103",
        type: {:complex, TE305103},
        min: 1,
        max: 1,
        choice: 1
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
