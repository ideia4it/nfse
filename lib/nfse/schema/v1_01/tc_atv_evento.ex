# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCAtvEvento do
  @moduledoc """
  Tipo `TCAtvEvento` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `x_nome` | `xNome` | `TSDesc255` | 1 | Descrição do evento Artístico, Cultural, Esportivo, etc |
  | `dt_ini` | `dtIni` | `TSData` | 1 | Data de início da atividade de evento. Ano, Mês e Dia (AAAA-MM-DD) |
  | `dt_fim` | `dtFim` | `TSData` | 1 | Data de fim da atividade de evento. Ano, Mês e Dia (AAAA-MM-DD) |
  | `id_atv_evt` | `idAtvEvt` | `TSIdeEvento` | 1, escolha 1 | Identificação da Atividade de Evento (código identificador de evento determinado pela Administração Tributária Municipal) |
  | `end` | `end` | `Nfse.Schema.V1_01.TCEnderecoSimples` | 1, escolha 1 | Grupo de informações relativas ao endereço da atividade, evento ou local do serviço prestado |

  Escolha 1: exatamente um entre `id_atv_evt` e `end`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCEnderecoSimples}

  defstruct [:x_nome, :dt_ini, :dt_fim, :id_atv_evt, :end]

  @type t :: %__MODULE__{
          x_nome: String.t() | nil,
          dt_ini: Date.t() | nil,
          dt_fim: Date.t() | nil,
          id_atv_evt: String.t() | nil,
          end: TCEnderecoSimples.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :x_nome, xml: "xNome", type: {:simple, "TSDesc255"}, min: 1, max: 1},
      %Field{name: :dt_ini, xml: "dtIni", type: {:simple, "TSData"}, min: 1, max: 1},
      %Field{name: :dt_fim, xml: "dtFim", type: {:simple, "TSData"}, min: 1, max: 1},
      %Field{
        name: :id_atv_evt,
        xml: "idAtvEvt",
        type: {:simple, "TSIdeEvento"},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :end,
        xml: "end",
        type: {:complex, TCEnderecoSimples},
        min: 1,
        max: 1,
        choice: 0
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
