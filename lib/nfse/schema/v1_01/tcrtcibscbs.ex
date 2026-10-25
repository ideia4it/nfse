# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCIBSCBS do
  @moduledoc """
  Tipo `TCRTCIBSCBS` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `c_localidade_incid` | `cLocalidadeIncid` | `TSCodMunIBGE` | 1 | Código IBGE da localidade de incidência do IBS/CBS (local da operação) |
  | `x_localidade_incid` | `xLocalidadeIncid` | `TSDesc600` | 1 | Nome da localidade de incidência do IBS/CBS |
  | `p_redutor` | `pRedutor` | `TSDec2V2` | 0..1 | Percentual de redução de aliquota em compra governamental |
  | `valores` | `valores` | `Nfse.Schema.V1_01.TCRTCValoresIBSCBS` | 1 | Grupo de valores brutos referentes ao IBS/CBS |
  | `tot_cibs` | `totCIBS` | `Nfse.Schema.V1_01.TCRTCTotalCIBS` | 1 | Grupo de Totalizadores |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCRTCTotalCIBS, TCRTCValoresIBSCBS}

  defstruct [:c_localidade_incid, :x_localidade_incid, :p_redutor, :valores, :tot_cibs]

  @type t :: %__MODULE__{
          c_localidade_incid: String.t() | nil,
          x_localidade_incid: String.t() | nil,
          p_redutor: Decimal.t() | nil,
          valores: TCRTCValoresIBSCBS.t() | nil,
          tot_cibs: TCRTCTotalCIBS.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :c_localidade_incid,
        xml: "cLocalidadeIncid",
        type: {:simple, "TSCodMunIBGE"},
        min: 1,
        max: 1
      },
      %Field{
        name: :x_localidade_incid,
        xml: "xLocalidadeIncid",
        type: {:simple, "TSDesc600"},
        min: 1,
        max: 1
      },
      %Field{name: :p_redutor, xml: "pRedutor", type: {:simple, "TSDec2V2"}, min: 0, max: 1},
      %Field{
        name: :valores,
        xml: "valores",
        type: {:complex, TCRTCValoresIBSCBS},
        min: 1,
        max: 1
      },
      %Field{name: :tot_cibs, xml: "totCIBS", type: {:complex, TCRTCTotalCIBS}, min: 1, max: 1}
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
