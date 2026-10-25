# Gerado por `mix nfse.gen` a partir de tiposEventos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TE205208 do
  @moduledoc """
  Tipo `TE205208` do leiaute 1.01, em `tiposEventos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `x_desc` | `xDesc` | `TE205208.xDesc` | 1 | Descrição do evento: "Manifestação de NFS-e - Anulação da Rejeição". |
  | `cpf_ag_trib` | `CPFAgTrib` | `TSCPF` | 1 | CPF do agente da administração tributária municipal que efetuou o anulação da manifestação de rejeição da NFS-e |
  | `id_ev_manif_rej` | `idEvManifRej` | `TSIdNumEvento` | 1 | Referência ao "id" do Evento de Manifestação de NFS-e - Rejeição, que originou o presente evento de anulação |
  | `x_motivo` | `xMotivo` | `TSMotivo` | 1 | Descrição para explicitar o motivo indicado neste evento |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:x_desc, :cpf_ag_trib, :id_ev_manif_rej, :x_motivo]

  @type t :: %__MODULE__{
          x_desc: String.t() | nil,
          cpf_ag_trib: String.t() | nil,
          id_ev_manif_rej: String.t() | nil,
          x_motivo: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :x_desc, xml: "xDesc", type: {:simple, "TE205208.xDesc"}, min: 1, max: 1},
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
