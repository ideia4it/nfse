# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCInfoTributacao do
  @moduledoc """
  Tipo `TCInfoTributacao` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `trib_mun` | `tribMun` | `Nfse.Schema.V1_01.TCTribMunicipal` | 1 | Grupo de informações relacionados ao Imposto Sobre Serviços de Qualquer Natureza - ISSQN |
  | `trib_fed` | `tribFed` | `Nfse.Schema.V1_01.TCTribFederal` | 0..1 | Grupo de informações de outros tributos relacionados ao serviço prestado |
  | `tot_trib` | `totTrib` | `Nfse.Schema.V1_01.TCTribTotal` | 1 | Grupo de informações para totais aproximados dos tributos relacionados ao serviço prestado |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCTribFederal, TCTribMunicipal, TCTribTotal}

  defstruct [:trib_mun, :trib_fed, :tot_trib]

  @type t :: %__MODULE__{
          trib_mun: TCTribMunicipal.t() | nil,
          trib_fed: TCTribFederal.t() | nil,
          tot_trib: TCTribTotal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :trib_mun, xml: "tribMun", type: {:complex, TCTribMunicipal}, min: 1, max: 1},
      %Field{name: :trib_fed, xml: "tribFed", type: {:complex, TCTribFederal}, min: 0, max: 1},
      %Field{name: :tot_trib, xml: "totTrib", type: {:complex, TCTribTotal}, min: 1, max: 1}
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
