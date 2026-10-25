# Gerado por `mix nfse.gen` a partir de tiposEventos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCInfEvento do
  @moduledoc """
  Tipo `TCInfEvento` do leiaute 1.00, em `tiposEventos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `ver_aplic` | `verAplic` | `TSVerAplic` | 0..1 | Versão do aplicativo que gerou o pedido do evento. |
  | `amb_ger` | `ambGer` | `TSAmbGeradorEvt` | 1 | Ambiente gerador do evento |
  | `n_seq_evento` | `nSeqEvento` | `TSNum3Dig` | 1 | Sequencial do evento para o mesmo tipo de evento. Para maioria dos eventos nSeqEvento=1. Nos casos em que possa existir mais de um evento do mesmo tipo o ambiente gerador deverá numerar de forma sequencial. |
  | `dh_proc` | `dhProc` | `TSDateTimeUTC` | 1 | Data/Hora do registro do evento. Data e hora no formato UTC (Universal Coordinated Time): AAAA-MM-DDThh:mm:ssTZD" |
  | `n_dfse` | `nDFSe` | `TSNumDFe` | 1 | Ambiente gerador do evento |
  | `ped_reg_evento` | `pedRegEvento` | `Nfse.Schema.V1_00.TCPedRegEvt` | 1 | Leiaute do pedido de registro do evento gerado pelo autor do evento |
  | `id` | `Id`, atributo | `TSIdEvento` | 1 |  |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCPedRegEvt}

  defstruct [:ver_aplic, :amb_ger, :n_seq_evento, :dh_proc, :n_dfse, :ped_reg_evento, :id]

  @type t :: %__MODULE__{
          ver_aplic: String.t() | nil,
          amb_ger: String.t() | nil,
          n_seq_evento: String.t() | nil,
          dh_proc: DateTime.t() | nil,
          n_dfse: String.t() | nil,
          ped_reg_evento: TCPedRegEvt.t() | nil,
          id: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []

  def __schema__(:attributes),
    do: [%Field{name: :id, xml: "Id", type: {:simple, "TSIdEvento"}, min: 1, max: 1}]

  def __schema__(:fields),
    do: [
      %Field{name: :ver_aplic, xml: "verAplic", type: {:simple, "TSVerAplic"}, min: 0, max: 1},
      %Field{name: :amb_ger, xml: "ambGer", type: {:simple, "TSAmbGeradorEvt"}, min: 1, max: 1},
      %Field{
        name: :n_seq_evento,
        xml: "nSeqEvento",
        type: {:simple, "TSNum3Dig"},
        min: 1,
        max: 1
      },
      %Field{name: :dh_proc, xml: "dhProc", type: {:simple, "TSDateTimeUTC"}, min: 1, max: 1},
      %Field{name: :n_dfse, xml: "nDFSe", type: {:simple, "TSNumDFe"}, min: 1, max: 1},
      %Field{
        name: :ped_reg_evento,
        xml: "pedRegEvento",
        type: {:complex, TCPedRegEvt},
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
