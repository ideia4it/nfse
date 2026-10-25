# Gerado por `mix nfse.gen` a partir de tiposCnc_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCInfCNC do
  @moduledoc """
  Tipo `TCInfCNC` do leiaute 1.00, em `tiposCnc_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `c_mun` | `cMun` | `TSCodMunIBGE` | 1 | Código do Municipio |
  | `cnpj_mun` | `cnpjMun` | `TSCNPJ` | 1 | CNPJ do Municipio |
  | `cpf_ag_trib` | `CPFAgTrib` | `TSCPF` | 1 | CPF do agente tributário |
  | `tp_amb` | `tpAmb` | `TSTipoAmbiente` | 1 | Identificação do Ambiente: 1 - Produção; 2 - Homologação |
  | `ver_aplic` | `verAplic` | `TSVerAplic` | 1 | Versão do aplicativo que gerou Informações para cadastramento de novos contribuintes CNC |
  | `inf_contrib` | `infContrib` | `Nfse.Schema.V1_00.TCInfoContribuinteCNC` | 1 | Grupo de informações cadastramento de novo contribuinte CNC |
  | `id` | `Id`, atributo | `TSIdCNC` | 1 |  |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCInfoContribuinteCNC}

  defstruct [:c_mun, :cnpj_mun, :cpf_ag_trib, :tp_amb, :ver_aplic, :inf_contrib, :id]

  @type t :: %__MODULE__{
          c_mun: String.t() | nil,
          cnpj_mun: String.t() | nil,
          cpf_ag_trib: String.t() | nil,
          tp_amb: String.t() | nil,
          ver_aplic: String.t() | nil,
          inf_contrib: TCInfoContribuinteCNC.t() | nil,
          id: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []

  def __schema__(:attributes),
    do: [%Field{name: :id, xml: "Id", type: {:simple, "TSIdCNC"}, min: 1, max: 1}]

  def __schema__(:fields),
    do: [
      %Field{name: :c_mun, xml: "cMun", type: {:simple, "TSCodMunIBGE"}, min: 1, max: 1},
      %Field{name: :cnpj_mun, xml: "cnpjMun", type: {:simple, "TSCNPJ"}, min: 1, max: 1},
      %Field{name: :cpf_ag_trib, xml: "CPFAgTrib", type: {:simple, "TSCPF"}, min: 1, max: 1},
      %Field{name: :tp_amb, xml: "tpAmb", type: {:simple, "TSTipoAmbiente"}, min: 1, max: 1},
      %Field{name: :ver_aplic, xml: "verAplic", type: {:simple, "TSVerAplic"}, min: 1, max: 1},
      %Field{
        name: :inf_contrib,
        xml: "infContrib",
        type: {:complex, TCInfoContribuinteCNC},
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
