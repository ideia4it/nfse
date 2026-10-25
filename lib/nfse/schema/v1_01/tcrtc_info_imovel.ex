# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCInfoImovel do
  @moduledoc """
  Tipo `TCRTCInfoImovel` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `insc_imob_fisc` | `inscImobFisc` | `TSInscImobFisc` | 0..1 | Inscrição imobiliária fiscal (código fornecido pela Prefeitura Municipal para a identificação da obra ou para fins de recolhimento do IPTU) |
  | `c_cib` | `cCIB` | `TSCodCIB` | 1, escolha 1 | Código do Cadastro Imobiliário Brasileiro - CIB |
  | `end` | `end` | `Nfse.Schema.V1_01.TCEnderObraEvento` | 1, escolha 1 | Grupo de informações do endereço da obra do serviço prestado |

  Escolha 1: exatamente um entre `c_cib` e `end`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCEnderObraEvento}

  defstruct [:insc_imob_fisc, :c_cib, :end]

  @type t :: %__MODULE__{
          insc_imob_fisc: String.t() | nil,
          c_cib: String.t() | nil,
          end: TCEnderObraEvento.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :insc_imob_fisc,
        xml: "inscImobFisc",
        type: {:simple, "TSInscImobFisc"},
        min: 0,
        max: 1
      },
      %Field{name: :c_cib, xml: "cCIB", type: {:simple, "TSCodCIB"}, min: 1, max: 1, choice: 0},
      %Field{
        name: :end,
        xml: "end",
        type: {:complex, TCEnderObraEvento},
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
