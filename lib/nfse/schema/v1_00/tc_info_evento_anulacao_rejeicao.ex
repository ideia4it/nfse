# Gerado por `mix nfse.gen` a partir de tiposEventos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCInfoEventoAnulacaoRejeicao do
  @moduledoc """
  Tipo `TCInfoEventoAnulacaoRejeicao` do leiaute 1.00, em `tiposEventos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `cpf_ag_trib` | `CPFAgTrib` | `TSCPF` | 1 | CPF do agente da administração tributária municipal que efetuou o anulação da manifestação de rejeição da NFS-e. |
  | `id_ev_manif_rej` | `idEvManifRej` | `TSIdNumEvento` | 1 | Referência ao Id da "Manifestação de rejeição da NFS-e" que originou o presente evento de anulação. |
  | `x_motivo` | `xMotivo` | `TSMotivo` | 1 | Descrição para explicitar o motivo da anluação |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.SimpleTypes

  defstruct [:cpf_ag_trib, :id_ev_manif_rej, :x_motivo]

  @type t :: %__MODULE__{
          cpf_ag_trib: String.t() | nil,
          id_ev_manif_rej: String.t() | nil,
          x_motivo: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :cpf_ag_trib, xml: "CPFAgTrib", type: {:simple, "TSCPF"}, min: 1, max: 1},
      %Field{
        name: :id_ev_manif_rej,
        xml: "idEvManifRej",
        type: {:simple, "TSIdNumEvento"},
        min: 1,
        max: 1
      },
      %Field{name: :x_motivo, xml: "xMotivo", type: {:simple, "TSMotivo"}, min: 1, max: 1}
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
