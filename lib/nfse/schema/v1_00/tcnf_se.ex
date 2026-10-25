# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCNFSe do
  @moduledoc """
  Tipo `TCNFSe` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `inf_nf_se` | `infNFSe` | `Nfse.Schema.V1_00.TCInfNFSe` | 1 |  |
  | `signature` | `Signature` | `ds:Signature` | 1 | Assinatura digital XMLDSig do documento, guardada como o XML do elemento. |
  | `versao` | `versao`, atributo | `TVerNFSe` | 1 |  |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCInfNFSe}

  defstruct [:inf_nf_se, :signature, :versao]

  @type t :: %__MODULE__{
          inf_nf_se: TCInfNFSe.t() | nil,
          signature: String.t() | nil,
          versao: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []

  def __schema__(:attributes),
    do: [%Field{name: :versao, xml: "versao", type: {:simple, "TVerNFSe"}, min: 1, max: 1}]

  def __schema__(:fields),
    do: [
      %Field{name: :inf_nf_se, xml: "infNFSe", type: {:complex, TCInfNFSe}, min: 1, max: 1},
      %Field{name: :signature, xml: "Signature", type: :signature, min: 1, max: 1}
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
