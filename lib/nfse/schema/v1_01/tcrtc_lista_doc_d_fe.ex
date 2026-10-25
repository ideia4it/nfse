# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCListaDocDFe do
  @moduledoc """
  Tipo `TCRTCListaDocDFe` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `tipo_chave_d_fe` | `tipoChaveDFe` | `TSRTCTipoChaveDFe` | 1 | Documento fiscal a que se refere a chaveDfe que seja um dos documentos do Repositório Nacional |
  | `x_tipo_chave_d_fe` | `xTipoChaveDFe` | `TSDesc255` | 0..1 | Descrição da DF-e a que se refere a chaveDfe que seja um dos documentos do Repositório Nacional Deve ser preenchido apenas quando "tipoChaveDFe = 9 (Outro)" |
  | `chave_d_fe` | `chaveDFe` | `TSRTCChaveDFe` | 1 | Chave do Documento Fiscal eletrônico do repositório nacional referenciado para os casos de operações já tributadas |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:tipo_chave_d_fe, :x_tipo_chave_d_fe, :chave_d_fe]

  @type t :: %__MODULE__{
          tipo_chave_d_fe: String.t() | nil,
          x_tipo_chave_d_fe: String.t() | nil,
          chave_d_fe: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :tipo_chave_d_fe,
        xml: "tipoChaveDFe",
        type: {:simple, "TSRTCTipoChaveDFe"},
        min: 1,
        max: 1
      },
      %Field{
        name: :x_tipo_chave_d_fe,
        xml: "xTipoChaveDFe",
        type: {:simple, "TSDesc255"},
        min: 0,
        max: 1
      },
      %Field{name: :chave_d_fe, xml: "chaveDFe", type: {:simple, "TSRTCChaveDFe"}, min: 1, max: 1}
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
