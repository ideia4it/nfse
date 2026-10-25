# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCInfoPessoa do
  @moduledoc """
  Informações das pessoas envolvidas na NFS-e. Pode ser o tomador, o intermediário ou o fornecedor (dedução/redução)

  Tipo `TCInfoPessoa` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `cnpj` | `CNPJ` | `TSCNPJ` | 1, escolha 1 | Número do CNPJ |
  | `cpf` | `CPF` | `TSCPF` | 1, escolha 1 | Número do CPF |
  | `nif` | `NIF` | `TSNIF` | 1, escolha 1 | Número de Identificação Fiscal fornecido por órgão de administração tributária no exterior |
  | `c_nao_nif` | `cNaoNIF` | `TSCodNaoNIF` | 1, escolha 1 | Motivo para não informação do NIF: 0 - Não informado na nota de origem; 1 - Dispensado do NIF; 2 - Não exigência do NIF; |
  | `caepf` | `CAEPF` | `TSCAEPF` | 0..1 | Número do Cadastro de Atividade Econômica da Pessoa Física (CAEPF) |
  | `im` | `IM` | `TSInscMun` | 0..1 | Número da inscrição municipal |
  | `x_nome` | `xNome` | `TSNomeRazaoSocial` | 1 | Nome/Nome Empresarial |
  | `end` | `end` | `Nfse.Schema.V1_00.TCEndereco` | 0..1 | Dados de endereço |
  | `fone` | `fone` | `TSTelefone` | 0..1 | Número do telefone do prestador: Preencher com o Código DDD + número do telefone. Nas operações com exterior é permitido informar o código do país + código da localidade + número do telefone) |
  | `email` | `email` | `TSEmail` | 0..1 | E-mail |

  Escolha 1: exatamente um entre `cnpj`, `cpf`, `nif` e `c_nao_nif`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCEndereco}

  defstruct [:cnpj, :cpf, :nif, :c_nao_nif, :caepf, :im, :x_nome, :end, :fone, :email]

  @type t :: %__MODULE__{
          cnpj: String.t() | nil,
          cpf: String.t() | nil,
          nif: String.t() | nil,
          c_nao_nif: String.t() | nil,
          caepf: String.t() | nil,
          im: String.t() | nil,
          x_nome: String.t() | nil,
          end: TCEndereco.t() | nil,
          fone: String.t() | nil,
          email: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :cnpj, xml: "CNPJ", type: {:simple, "TSCNPJ"}, min: 1, max: 1, choice: 0},
      %Field{name: :cpf, xml: "CPF", type: {:simple, "TSCPF"}, min: 1, max: 1, choice: 0},
      %Field{name: :nif, xml: "NIF", type: {:simple, "TSNIF"}, min: 1, max: 1, choice: 0},
      %Field{
        name: :c_nao_nif,
        xml: "cNaoNIF",
        type: {:simple, "TSCodNaoNIF"},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{name: :caepf, xml: "CAEPF", type: {:simple, "TSCAEPF"}, min: 0, max: 1},
      %Field{name: :im, xml: "IM", type: {:simple, "TSInscMun"}, min: 0, max: 1},
      %Field{name: :x_nome, xml: "xNome", type: {:simple, "TSNomeRazaoSocial"}, min: 1, max: 1},
      %Field{name: :end, xml: "end", type: {:complex, TCEndereco}, min: 0, max: 1},
      %Field{name: :fone, xml: "fone", type: {:simple, "TSTelefone"}, min: 0, max: 1},
      %Field{name: :email, xml: "email", type: {:simple, "TSEmail"}, min: 0, max: 1}
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
