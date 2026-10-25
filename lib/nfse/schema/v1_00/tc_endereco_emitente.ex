# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCEnderecoEmitente do
  @moduledoc """
  Tipo `TCEnderecoEmitente` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `x_lgr` | `xLgr` | `TSLogradouro` | 1 | Tipo e nome do logradouro da localização do imóvel |
  | `nro` | `nro` | `TSNumeroEndereco` | 1 | Número do imóvel |
  | `x_cpl` | `xCpl` | `TSComplementoEndereco` | 0..1 | Complemento do endereço |
  | `x_bairro` | `xBairro` | `TSBairro` | 1 | Bairro |
  | `c_mun` | `cMun` | `TSCodMunIBGE` | 1 | Código do município, conforme Tabela do IBGE |
  | `uf` | `UF` | `TSUF` | 1 | Sigla da unidade da federação do município do endereço do emitente. |
  | `cep` | `CEP` | `TSCEP` | 1 | Número do CEP |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.SimpleTypes

  defstruct [:x_lgr, :nro, :x_cpl, :x_bairro, :c_mun, :uf, :cep]

  @type t :: %__MODULE__{
          x_lgr: String.t() | nil,
          nro: String.t() | nil,
          x_cpl: String.t() | nil,
          x_bairro: String.t() | nil,
          c_mun: String.t() | nil,
          uf: String.t() | nil,
          cep: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :x_lgr, xml: "xLgr", type: {:simple, "TSLogradouro"}, min: 1, max: 1},
      %Field{name: :nro, xml: "nro", type: {:simple, "TSNumeroEndereco"}, min: 1, max: 1},
      %Field{name: :x_cpl, xml: "xCpl", type: {:simple, "TSComplementoEndereco"}, min: 0, max: 1},
      %Field{name: :x_bairro, xml: "xBairro", type: {:simple, "TSBairro"}, min: 1, max: 1},
      %Field{name: :c_mun, xml: "cMun", type: {:simple, "TSCodMunIBGE"}, min: 1, max: 1},
      %Field{name: :uf, xml: "UF", type: {:simple, "TSUF"}, min: 1, max: 1},
      %Field{name: :cep, xml: "CEP", type: {:simple, "TSCEP"}, min: 1, max: 1}
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
