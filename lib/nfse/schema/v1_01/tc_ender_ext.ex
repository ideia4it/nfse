# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCEnderExt do
  @moduledoc """
  Tipo `TCEnderExt` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `c_pais` | `cPais` | `TSCodPaisISO` | 1 | Código do país (Tabela de Países ISO) |
  | `c_end_post` | `cEndPost` | `TSCodigoEndPostal` | 1 | Código alfanumérico do Endereçamento Postal no exterior do prestador do serviço. |
  | `x_cidade` | `xCidade` | `TSCidade` | 1 | Nome da cidade no exterior do prestador do serviço. |
  | `x_est_prov_reg` | `xEstProvReg` | `TSEstadoProvRegiao` | 1 | Estado, província ou região da cidade no exterior do prestador do serviço. |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:c_pais, :c_end_post, :x_cidade, :x_est_prov_reg]

  @type t :: %__MODULE__{
          c_pais: String.t() | nil,
          c_end_post: String.t() | nil,
          x_cidade: String.t() | nil,
          x_est_prov_reg: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :c_pais, xml: "cPais", type: {:simple, "TSCodPaisISO"}, min: 1, max: 1},
      %Field{
        name: :c_end_post,
        xml: "cEndPost",
        type: {:simple, "TSCodigoEndPostal"},
        min: 1,
        max: 1
      },
      %Field{name: :x_cidade, xml: "xCidade", type: {:simple, "TSCidade"}, min: 1, max: 1},
      %Field{
        name: :x_est_prov_reg,
        xml: "xEstProvReg",
        type: {:simple, "TSEstadoProvRegiao"},
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
