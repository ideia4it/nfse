# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCTribTotalPercent do
  @moduledoc """
  Tipo `TCTribTotalPercent` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `p_tot_trib_fed` | `pTotTribFed` | `TSDec3V2` | 1 | Valor percentual total aproximado dos tributos federais (%). |
  | `p_tot_trib_est` | `pTotTribEst` | `TSDec3V2` | 1 | Valor percentual total aproximado dos tributos estaduais (%). |
  | `p_tot_trib_mun` | `pTotTribMun` | `TSDec3V2` | 1 | Valor percentual total aproximado dos tributos municipais (%). |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.SimpleTypes

  defstruct [:p_tot_trib_fed, :p_tot_trib_est, :p_tot_trib_mun]

  @type t :: %__MODULE__{
          p_tot_trib_fed: Decimal.t() | nil,
          p_tot_trib_est: Decimal.t() | nil,
          p_tot_trib_mun: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :p_tot_trib_fed,
        xml: "pTotTribFed",
        type: {:simple, "TSDec3V2"},
        min: 1,
        max: 1
      },
      %Field{
        name: :p_tot_trib_est,
        xml: "pTotTribEst",
        type: {:simple, "TSDec3V2"},
        min: 1,
        max: 1
      },
      %Field{
        name: :p_tot_trib_mun,
        xml: "pTotTribMun",
        type: {:simple, "TSDec3V2"},
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
