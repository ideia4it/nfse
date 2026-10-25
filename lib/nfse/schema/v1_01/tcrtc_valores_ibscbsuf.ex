# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCValoresIBSCBSUF do
  @moduledoc """
  Tipo `TCRTCValoresIBSCBSUF` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `p_ibsuf` | `pIBSUF` | `TSDec2V2` | 1 | Alíquota da UF para IBS da localidade de incidência parametrizada no sistema |
  | `p_red_aliq_uf` | `pRedAliqUF` | `TSDec3V2` | 0..1 | Percentual de redução de alíquota estadual |
  | `p_aliq_efet_uf` | `pAliqEfetUF` | `TSDec2V2` | 1 | pAliqEfetUF = pIBSUF x (1 - pRedAliqUF) x (1 - pRedutor) Se pRedAliqUF não for informado na DPS, então pAliqEfetUF é a própria pIBSUF |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:p_ibsuf, :p_red_aliq_uf, :p_aliq_efet_uf]

  @type t :: %__MODULE__{
          p_ibsuf: Decimal.t() | nil,
          p_red_aliq_uf: Decimal.t() | nil,
          p_aliq_efet_uf: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :p_ibsuf, xml: "pIBSUF", type: {:simple, "TSDec2V2"}, min: 1, max: 1},
      %Field{
        name: :p_red_aliq_uf,
        xml: "pRedAliqUF",
        type: {:simple, "TSDec3V2"},
        min: 0,
        max: 1
      },
      %Field{
        name: :p_aliq_efet_uf,
        xml: "pAliqEfetUF",
        type: {:simple, "TSDec2V2"},
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
