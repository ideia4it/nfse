# Gerado por `mix nfse.gen` a partir de tiposCnc_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCInfCNC do
  @moduledoc """
  Tipo `TCInfCNC` do leiaute 1.01, em `tiposCnc_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `tp_amb` | `tpAmb` | `TSTipoAmbiente` | 1 | Identificação do Ambiente: 1 - Produção; 2 - Homologação |
  | `dh_geracao_arquivo` | `dhGeracaoArquivo` | `TSDateTimeUTC` | 1 | Data e hora da geração do arquivo CNC. Data e hora no formato UTC (Universal Coordinated Time): AAAA-MM-DDThh:mm:ssTZD |
  | `ver_aplic` | `verAplic` | `TSVerAplic` | 1 | Versão do aplicativo que gerou Informações para cadastramento de novos contribuintes CNC |
  | `contribuintes_cnc` | `contribuintesCnc` | `Nfse.Schema.V1_01.TCInfCNCContribuintesCnc` | 1 |  |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCInfCNCContribuintesCnc}

  defstruct [:tp_amb, :dh_geracao_arquivo, :ver_aplic, :contribuintes_cnc]

  @type t :: %__MODULE__{
          tp_amb: String.t() | nil,
          dh_geracao_arquivo: DateTime.t() | nil,
          ver_aplic: String.t() | nil,
          contribuintes_cnc: TCInfCNCContribuintesCnc.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :tp_amb, xml: "tpAmb", type: {:simple, "TSTipoAmbiente"}, min: 1, max: 1},
      %Field{
        name: :dh_geracao_arquivo,
        xml: "dhGeracaoArquivo",
        type: {:simple, "TSDateTimeUTC"},
        min: 1,
        max: 1
      },
      %Field{name: :ver_aplic, xml: "verAplic", type: {:simple, "TSVerAplic"}, min: 1, max: 1},
      %Field{
        name: :contribuintes_cnc,
        xml: "contribuintesCnc",
        type: {:complex, TCInfCNCContribuintesCnc},
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
