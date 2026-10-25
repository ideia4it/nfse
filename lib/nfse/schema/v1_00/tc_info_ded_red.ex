# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCInfoDedRed do
  @moduledoc """
  Tipo `TCInfoDedRed` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `p_dr` | `pDR` | `TSDec3V2` | 1, escolha 1 | Valor percentual padrão para dedução/redução do valor do serviço |
  | `v_dr` | `vDR` | `TSDec15V2` | 1, escolha 1 | Valor monetário padrão para dedução/redução do valor do serviço |
  | `documentos` | `documentos` | `Nfse.Schema.V1_00.TCListaDocDedRed` | 1, escolha 1 | Grupo de informações de documento utilizado para Dedução/Redução do valor do serviço |

  Escolha 1: exatamente um entre `p_dr`, `v_dr` e `documentos`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCListaDocDedRed}

  defstruct [:p_dr, :v_dr, :documentos]

  @type t :: %__MODULE__{
          p_dr: Decimal.t() | nil,
          v_dr: Decimal.t() | nil,
          documentos: TCListaDocDedRed.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :p_dr, xml: "pDR", type: {:simple, "TSDec3V2"}, min: 1, max: 1, choice: 0},
      %Field{name: :v_dr, xml: "vDR", type: {:simple, "TSDec15V2"}, min: 1, max: 1, choice: 0},
      %Field{
        name: :documentos,
        xml: "documentos",
        type: {:complex, TCListaDocDedRed},
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
