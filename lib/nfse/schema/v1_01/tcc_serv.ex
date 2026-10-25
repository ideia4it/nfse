# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCCServ do
  @moduledoc """
  Tipo `TCCServ` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `c_trib_nac` | `cTribNac` | `TSCodTribNac` | 1 | Código de tributação nacional do ISSQN, nos termos da LC 116/2003, conforme aba MUN.INCID_INFO.SERV. do ANEXO I Regra de formação - 6 dígitos numéricos sendo: 2 para Item (LC 116/2003), 2 para Subitem (LC 116/2003) e 2 para Desdobro Nacional |
  | `c_trib_mun` | `cTribMun` | `TCCodTribMun` | 0..1 | Código de tributação municipal do ISSQN |
  | `x_desc_serv` | `xDescServ` | `TSDesc2000` | 1 | Descrição completa do serviço prestado |
  | `c_nbs` | `cNBS` | `TSCodNBS` | 0..1 | Código NBS correspondente ao serviço prestado, seguindo a versão 2.0, conforme Anexo B |
  | `c_int_contrib` | `cIntContrib` | `TSCodigoInternoContribuinte` | 0..1 | Código interno do contribuinte |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:c_trib_nac, :c_trib_mun, :x_desc_serv, :c_nbs, :c_int_contrib]

  @type t :: %__MODULE__{
          c_trib_nac: String.t() | nil,
          c_trib_mun: String.t() | nil,
          x_desc_serv: String.t() | nil,
          c_nbs: String.t() | nil,
          c_int_contrib: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :c_trib_nac, xml: "cTribNac", type: {:simple, "TSCodTribNac"}, min: 1, max: 1},
      %Field{name: :c_trib_mun, xml: "cTribMun", type: {:simple, "TCCodTribMun"}, min: 0, max: 1},
      %Field{name: :x_desc_serv, xml: "xDescServ", type: {:simple, "TSDesc2000"}, min: 1, max: 1},
      %Field{name: :c_nbs, xml: "cNBS", type: {:simple, "TSCodNBS"}, min: 0, max: 1},
      %Field{
        name: :c_int_contrib,
        xml: "cIntContrib",
        type: {:simple, "TSCodigoInternoContribuinte"},
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
