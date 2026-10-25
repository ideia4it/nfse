# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCLocPrest do
  @moduledoc """
  Tipo `TCLocPrest` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `c_loc_prestacao` | `cLocPrestacao` | `TSCodMunIBGE` | 0..1, escolha 1 | Código do município onde o serviço foi prestado (tabela do IBGE) |
  | `c_pais_prestacao` | `cPaisPrestacao` | `TSCodPaisISO` | 0..1, escolha 1 | Código do país onde o serviço foi prestado (Tabela de Países ISO) |

  Escolha 1: no máximo um entre `c_loc_prestacao` e `c_pais_prestacao`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.SimpleTypes

  defstruct [:c_loc_prestacao, :c_pais_prestacao]

  @type t :: %__MODULE__{c_loc_prestacao: String.t() | nil, c_pais_prestacao: String.t() | nil}

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :c_loc_prestacao,
        xml: "cLocPrestacao",
        type: {:simple, "TSCodMunIBGE"},
        min: 0,
        max: 1,
        choice: 0
      },
      %Field{
        name: :c_pais_prestacao,
        xml: "cPaisPrestacao",
        type: {:simple, "TSCodPaisISO"},
        min: 0,
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
