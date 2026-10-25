# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCInfoValores do
  @moduledoc """
  Tipo `TCInfoValores` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `v_serv_prest` | `vServPrest` | `Nfse.Schema.V1_00.TCVServPrest` | 1 | Grupo de informações relativas aos valores do serviço prestado |
  | `v_desc_cond_incond` | `vDescCondIncond` | `Nfse.Schema.V1_00.TCVDescCondIncond` | 0..1 | Grupo de informações relativas aos descontos condicionados e incondicionados |
  | `v_ded_red` | `vDedRed` | `Nfse.Schema.V1_00.TCInfoDedRed` | 0..1 | Grupo de informações relativas ao valores para dedução/redução do valor da base de cálculo (valor do serviço) |
  | `trib` | `trib` | `Nfse.Schema.V1_00.TCInfoTributacao` | 1 | Grupo de informações relacionados aos tributos relacionados ao serviço prestado |
  """

  alias Nfse.Schema.{Field, Runtime}

  alias Nfse.Schema.V1_00.{
    SimpleTypes,
    TCInfoDedRed,
    TCInfoTributacao,
    TCVDescCondIncond,
    TCVServPrest
  }

  defstruct [:v_serv_prest, :v_desc_cond_incond, :v_ded_red, :trib]

  @type t :: %__MODULE__{
          v_serv_prest: TCVServPrest.t() | nil,
          v_desc_cond_incond: TCVDescCondIncond.t() | nil,
          v_ded_red: TCInfoDedRed.t() | nil,
          trib: TCInfoTributacao.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :v_serv_prest,
        xml: "vServPrest",
        type: {:complex, TCVServPrest},
        min: 1,
        max: 1
      },
      %Field{
        name: :v_desc_cond_incond,
        xml: "vDescCondIncond",
        type: {:complex, TCVDescCondIncond},
        min: 0,
        max: 1
      },
      %Field{name: :v_ded_red, xml: "vDedRed", type: {:complex, TCInfoDedRed}, min: 0, max: 1},
      %Field{name: :trib, xml: "trib", type: {:complex, TCInfoTributacao}, min: 1, max: 1}
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
