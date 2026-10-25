# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCTribFederal do
  @moduledoc """
  Tipo `TCTribFederal` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `piscofins` | `piscofins` | `Nfse.Schema.V1_01.TCTribOutrosPisCofins` | 0..1 | Grupo de informações dos tributos PIS/COFINS |
  | `v_ret_cp` | `vRetCP` | `TSDec15V2` | 0..1 | Valor monetário do CP(R$). |
  | `v_ret_irrf` | `vRetIRRF` | `TSDec15V2` | 0..1 | Valor monetário do IRRF (R$). |
  | `v_ret_csll` | `vRetCSLL` | `TSDec15V2` | 0..1 | Valor monetário do CSLL (R$). |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCTribOutrosPisCofins}

  defstruct [:piscofins, :v_ret_cp, :v_ret_irrf, :v_ret_csll]

  @type t :: %__MODULE__{
          piscofins: TCTribOutrosPisCofins.t() | nil,
          v_ret_cp: Decimal.t() | nil,
          v_ret_irrf: Decimal.t() | nil,
          v_ret_csll: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :piscofins,
        xml: "piscofins",
        type: {:complex, TCTribOutrosPisCofins},
        min: 0,
        max: 1
      },
      %Field{name: :v_ret_cp, xml: "vRetCP", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
      %Field{name: :v_ret_irrf, xml: "vRetIRRF", type: {:simple, "TSDec15V2"}, min: 0, max: 1},
      %Field{name: :v_ret_csll, xml: "vRetCSLL", type: {:simple, "TSDec15V2"}, min: 0, max: 1}
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
