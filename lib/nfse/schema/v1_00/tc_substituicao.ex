# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCSubstituicao do
  @moduledoc """
  Tipo `TCSubstituicao` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `ch_substda` | `chSubstda` | `TSChaveNFSe` | 1 | Chave de acesso da NFS-e a ser substituída |
  | `c_motivo` | `cMotivo` | `TSCodJustSubst` | 1 | Código de justificativa para substituição de NFS-e: 01 - Desenquadramento de NFS-e do Simples Nacional; 02 - Enquadramento de NFS-e no Simples Nacional; 03 - Inclusão Retroativa de Imunidade/Isenção para NFS-e; 04 - Exclusão Retroativa de Imunidade/Isenção para NFS-e; 05 - Rejeição de NFS-e pelo tomador ou pelo intermediário se responsável pelo recolhimento do tributo; 99 - Outros; |
  | `x_motivo` | `xMotivo` | `TSMotivo` | 0..1 | Descrição do motivo da substituição da NFS-e |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.SimpleTypes

  defstruct [:ch_substda, :c_motivo, :x_motivo]

  @type t :: %__MODULE__{
          ch_substda: String.t() | nil,
          c_motivo: String.t() | nil,
          x_motivo: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :ch_substda, xml: "chSubstda", type: {:simple, "TSChaveNFSe"}, min: 1, max: 1},
      %Field{name: :c_motivo, xml: "cMotivo", type: {:simple, "TSCodJustSubst"}, min: 1, max: 1},
      %Field{name: :x_motivo, xml: "xMotivo", type: {:simple, "TSMotivo"}, min: 0, max: 1}
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
