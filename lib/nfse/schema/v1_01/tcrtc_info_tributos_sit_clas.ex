# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCInfoTributosSitClas do
  @moduledoc """
  Tipo `TCRTCInfoTributosSitClas` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `cst` | `CST` | `TSRTCCodSitTrib` | 1 | Código de Situação Tributária do IBS e da CBS |
  | `c_class_trib` | `cClassTrib` | `TSRTCCodClassTrib` | 1 | Código de Classificação Tributária do IBS e da CBS |
  | `c_cred_pres` | `cCredPres` | `TSRTCCodCredPres` | 0..1 | Código e Classificação do Crédito Presumido: IBS e CBS |
  | `g_trib_regular` | `gTribRegular` | `Nfse.Schema.V1_01.TCRTCInfoTributosTribRegular` | 0..1 | Grupo de informações da Tributação Regular |
  | `g_dif` | `gDif` | `Nfse.Schema.V1_01.TCRTCInfoTributosDif` | 0..1 | Grupo de informações relacionadas ao diferimento para IBS e CBS |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCRTCInfoTributosDif, TCRTCInfoTributosTribRegular}

  defstruct [:cst, :c_class_trib, :c_cred_pres, :g_trib_regular, :g_dif]

  @type t :: %__MODULE__{
          cst: String.t() | nil,
          c_class_trib: String.t() | nil,
          c_cred_pres: String.t() | nil,
          g_trib_regular: TCRTCInfoTributosTribRegular.t() | nil,
          g_dif: TCRTCInfoTributosDif.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :cst, xml: "CST", type: {:simple, "TSRTCCodSitTrib"}, min: 1, max: 1},
      %Field{
        name: :c_class_trib,
        xml: "cClassTrib",
        type: {:simple, "TSRTCCodClassTrib"},
        min: 1,
        max: 1
      },
      %Field{
        name: :c_cred_pres,
        xml: "cCredPres",
        type: {:simple, "TSRTCCodCredPres"},
        min: 0,
        max: 1
      },
      %Field{
        name: :g_trib_regular,
        xml: "gTribRegular",
        type: {:complex, TCRTCInfoTributosTribRegular},
        min: 0,
        max: 1
      },
      %Field{name: :g_dif, xml: "gDif", type: {:complex, TCRTCInfoTributosDif}, min: 0, max: 1}
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
