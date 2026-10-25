# Gerado por `mix nfse.gen` a partir de tiposCnc_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCInfoContribuinteCNC do
  @moduledoc """
  Informações para cadastramento de novos contribuintes CNC

  Tipo `TCInfoContribuinteCNC` do leiaute 1.00, em `tiposCnc_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `cnpj` | `CNPJ` | `TSCNPJ` | 1, escolha 1 | Número do CNPJ do contribuinte. |
  | `cpf` | `CPF` | `TSCPF` | 1, escolha 1 | Número do CPF do contribuinte. |
  | `im` | `IM` | `TSInscMun` | 1 | Número da inscrição municipal |
  | `d_im` | `dIM` | `TSDataCNC` | 1 | Data da Inscrição Municipal: Dia, mês e ano (AAAAMMDD) |
  | `x_fantasia` | `xFantasia` | `TSNomeFantasia` | 0..1 | Nome fantasia do contribuinte. |
  | `ender` | `ender` | `Nfse.Schema.V1_00.TCEnderContribuinteCNC` | 0..1 | Grupo de informações do endereço do contribuinte do CNC |
  | `fone` | `fone` | `TSTelefone` | 0..1 | Número do telefone do prestador: Preencher com o Código DDD + número do telefone. Nas operações com exterior é permitido informar o código do país + código da localidade + número do telefone) |
  | `email` | `email` | `TSEmail` | 0..1 | Endereço de e-mail para contato com o contribuinte |
  | `d_aut_emiss` | `dAutEmiss` | `TSDataCNC` | 1 | Data de autorização de uso dos emissores públicos: Dia, mês e ano (AAAAMMDD) |
  | `c_stat_emiss` | `cStatEmiss` | `TSSituacaoEmissaoNFSE` | 1 | Situação Emissão NFS-e: 0 - Não Habilitado; 1 - Habilitado; |
  | `c_sit_cnc` | `cSitCNC` | `TSSituacaoCadastroContribuinteCNC` | 1 | Identificação da situação do cadastro do contribuinte |
  | `x_sit_cad_mun` | `xSitCadMun` | `TSSituacaoCadastroContribuinte` | 0..1 | Identificação da situação do cadastro do contribuinte |
  | `x_motivo_sit_cad_mun` | `xMotivoSitCadMun` | `TSMotivoSituacaoCadastroContribuinte` | 0..1 | Motivo pelo qual o contribuinte se enquadra na situação informada |

  Escolha 1: exatamente um entre `cnpj` e `cpf`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCEnderContribuinteCNC}

  defstruct [
    :cnpj,
    :cpf,
    :im,
    :d_im,
    :x_fantasia,
    :ender,
    :fone,
    :email,
    :d_aut_emiss,
    :c_stat_emiss,
    :c_sit_cnc,
    :x_sit_cad_mun,
    :x_motivo_sit_cad_mun
  ]

  @type t :: %__MODULE__{
          cnpj: String.t() | nil,
          cpf: String.t() | nil,
          im: String.t() | nil,
          d_im: String.t() | nil,
          x_fantasia: String.t() | nil,
          ender: TCEnderContribuinteCNC.t() | nil,
          fone: String.t() | nil,
          email: String.t() | nil,
          d_aut_emiss: String.t() | nil,
          c_stat_emiss: String.t() | nil,
          c_sit_cnc: String.t() | nil,
          x_sit_cad_mun: String.t() | nil,
          x_motivo_sit_cad_mun: String.t() | nil
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
      %Field{name: :im, xml: "IM", type: {:simple, "TSInscMun"}, min: 1, max: 1},
      %Field{name: :d_im, xml: "dIM", type: {:simple, "TSDataCNC"}, min: 1, max: 1},
      %Field{
        name: :x_fantasia,
        xml: "xFantasia",
        type: {:simple, "TSNomeFantasia"},
        min: 0,
        max: 1
      },
      %Field{
        name: :ender,
        xml: "ender",
        type: {:complex, TCEnderContribuinteCNC},
        min: 0,
        max: 1
      },
      %Field{name: :fone, xml: "fone", type: {:simple, "TSTelefone"}, min: 0, max: 1},
      %Field{name: :email, xml: "email", type: {:simple, "TSEmail"}, min: 0, max: 1},
      %Field{name: :d_aut_emiss, xml: "dAutEmiss", type: {:simple, "TSDataCNC"}, min: 1, max: 1},
      %Field{
        name: :c_stat_emiss,
        xml: "cStatEmiss",
        type: {:simple, "TSSituacaoEmissaoNFSE"},
        min: 1,
        max: 1
      },
      %Field{
        name: :c_sit_cnc,
        xml: "cSitCNC",
        type: {:simple, "TSSituacaoCadastroContribuinteCNC"},
        min: 1,
        max: 1
      },
      %Field{
        name: :x_sit_cad_mun,
        xml: "xSitCadMun",
        type: {:simple, "TSSituacaoCadastroContribuinte"},
        min: 0,
        max: 1
      },
      %Field{
        name: :x_motivo_sit_cad_mun,
        xml: "xMotivoSitCadMun",
        type: {:simple, "TSMotivoSituacaoCadastroContribuinte"},
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
