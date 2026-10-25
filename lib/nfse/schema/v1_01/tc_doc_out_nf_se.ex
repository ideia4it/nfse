# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCDocOutNFSe do
  @moduledoc """
  Tipo `TCDocOutNFSe` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `c_mun_nf_se_mun` | `cMunNFSeMun` | `TSCodMunIBGE` | 1 | Código Município emissor da nota eletrônica municipal (Tabela do IBGE) |
  | `n_nf_se_mun` | `nNFSeMun` | `TSNum15Dig` | 1 | Número da nota eletrônica municipal |
  | `c_verif_nf_se_mun` | `cVerifNFSeMun` | `TSCodVerificacao` | 1 | Código de Verificação da nota eletrônica municipal |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:c_mun_nf_se_mun, :n_nf_se_mun, :c_verif_nf_se_mun]

  @type t :: %__MODULE__{
          c_mun_nf_se_mun: String.t() | nil,
          n_nf_se_mun: String.t() | nil,
          c_verif_nf_se_mun: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :c_mun_nf_se_mun,
        xml: "cMunNFSeMun",
        type: {:simple, "TSCodMunIBGE"},
        min: 1,
        max: 1
      },
      %Field{name: :n_nf_se_mun, xml: "nNFSeMun", type: {:simple, "TSNum15Dig"}, min: 1, max: 1},
      %Field{
        name: :c_verif_nf_se_mun,
        xml: "cVerifNFSeMun",
        type: {:simple, "TSCodVerificacao"},
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
