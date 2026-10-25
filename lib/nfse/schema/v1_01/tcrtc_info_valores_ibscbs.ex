# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCInfoValoresIBSCBS do
  @moduledoc """
  Tipo `TCRTCInfoValoresIBSCBS` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `g_ree_rep_res` | `gReeRepRes` | `Nfse.Schema.V1_01.TCRTCInfoReeRepRes` | 0..1 | Grupo de informações relativas a valores incluídos neste documento e recebidos por motivo de estarem relacionadas a operações de terceiros, objeto de reembolso, repasse ou ressarcimento pelo recebedor, já tributados e aqui referenciados |
  | `trib` | `trib` | `Nfse.Schema.V1_01.TCRTCInfoTributosIBSCBS` | 1 | Grupo de informações relacionados aos tributos IBS e CBS |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCRTCInfoReeRepRes, TCRTCInfoTributosIBSCBS}

  defstruct [:g_ree_rep_res, :trib]

  @type t :: %__MODULE__{
          g_ree_rep_res: TCRTCInfoReeRepRes.t() | nil,
          trib: TCRTCInfoTributosIBSCBS.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :g_ree_rep_res,
        xml: "gReeRepRes",
        type: {:complex, TCRTCInfoReeRepRes},
        min: 0,
        max: 1
      },
      %Field{name: :trib, xml: "trib", type: {:complex, TCRTCInfoTributosIBSCBS}, min: 1, max: 1}
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
