# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCLocacaoSublocacao do
  @moduledoc """
  Tipo `TCLocacaoSublocacao` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `categ` | `categ` | `TSCategoriaServico` | 1 | Categoria do serviço |
  | `objeto` | `objeto` | `TCObjetoLocacao` | 1 | Tipo de objetos da locação, sublocação, arrendamento, direito de passagem ou permissão de uso |
  | `extensao` | `extensao` | `TSExtensaoTotal` | 1 | Extensão total da ferrovia, rodovia, cabos, dutos ou condutos |
  | `n_postes` | `nPostes` | `TSNumeroPostes` | 1 | Número total de postes |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.SimpleTypes

  defstruct [:categ, :objeto, :extensao, :n_postes]

  @type t :: %__MODULE__{
          categ: String.t() | nil,
          objeto: String.t() | nil,
          extensao: String.t() | nil,
          n_postes: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :categ, xml: "categ", type: {:simple, "TSCategoriaServico"}, min: 1, max: 1},
      %Field{name: :objeto, xml: "objeto", type: {:simple, "TCObjetoLocacao"}, min: 1, max: 1},
      %Field{
        name: :extensao,
        xml: "extensao",
        type: {:simple, "TSExtensaoTotal"},
        min: 1,
        max: 1
      },
      %Field{name: :n_postes, xml: "nPostes", type: {:simple, "TSNumeroPostes"}, min: 1, max: 1}
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
