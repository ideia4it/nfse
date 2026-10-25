# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCEndereco do
  @moduledoc """
  Tipo `TCEndereco` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `end_nac` | `endNac` | `Nfse.Schema.V1_01.TCEnderNac` | 1, escolha 1 | Grupo de informações específicas de endereço nacional |
  | `end_ext` | `endExt` | `Nfse.Schema.V1_01.TCEnderExt` | 1, escolha 1 | Grupo de informações específicas de endereço no exterior |
  | `x_lgr` | `xLgr` | `TSLogradouro` | 1 | Tipo e nome do logradouro da localização do imóvel |
  | `nro` | `nro` | `TSNumeroEndereco` | 1 | Número do imóvel |
  | `x_cpl` | `xCpl` | `TSComplementoEndereco` | 0..1 | Complemento do endereço |
  | `x_bairro` | `xBairro` | `TSBairro` | 1 | Bairro |

  Escolha 1: exatamente um entre `end_nac` e `end_ext`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCEnderExt, TCEnderNac}

  defstruct [:end_nac, :end_ext, :x_lgr, :nro, :x_cpl, :x_bairro]

  @type t :: %__MODULE__{
          end_nac: TCEnderNac.t() | nil,
          end_ext: TCEnderExt.t() | nil,
          x_lgr: String.t() | nil,
          nro: String.t() | nil,
          x_cpl: String.t() | nil,
          x_bairro: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :end_nac,
        xml: "endNac",
        type: {:complex, TCEnderNac},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :end_ext,
        xml: "endExt",
        type: {:complex, TCEnderExt},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{name: :x_lgr, xml: "xLgr", type: {:simple, "TSLogradouro"}, min: 1, max: 1},
      %Field{name: :nro, xml: "nro", type: {:simple, "TSNumeroEndereco"}, min: 1, max: 1},
      %Field{name: :x_cpl, xml: "xCpl", type: {:simple, "TSComplementoEndereco"}, min: 0, max: 1},
      %Field{name: :x_bairro, xml: "xBairro", type: {:simple, "TSBairro"}, min: 1, max: 1}
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
