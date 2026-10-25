# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCInfoCompl do
  @moduledoc """
  Tipo `TCInfoCompl` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `id_doc_tec` | `idDocTec` | `TSDRT` | 0..1 | Identificador de Documento de Responsabilidade Técnica: ART, RRT, DRT, Outros. |
  | `doc_ref` | `docRef` | `TSDesc255` | 0..1 | Chave da nota, número identificador da nota, número do contrato ou outro identificador de documento emitido pelo prestador de serviços, que subsidia a emissão dessa nota pelo tomador do serviço ou intermediário (preenchimento obrigatório caso a nota esteja sendo emitida pelo Tomador ou intermediário do serviço). |
  | `x_inf_comp` | `xInfComp` | `TSDescInfCompl` | 0..1 | Informações complementares |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.SimpleTypes

  defstruct [:id_doc_tec, :doc_ref, :x_inf_comp]

  @type t :: %__MODULE__{
          id_doc_tec: String.t() | nil,
          doc_ref: String.t() | nil,
          x_inf_comp: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :id_doc_tec, xml: "idDocTec", type: {:simple, "TSDRT"}, min: 0, max: 1},
      %Field{name: :doc_ref, xml: "docRef", type: {:simple, "TSDesc255"}, min: 0, max: 1},
      %Field{
        name: :x_inf_comp,
        xml: "xInfComp",
        type: {:simple, "TSDescInfCompl"},
        min: 0,
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
