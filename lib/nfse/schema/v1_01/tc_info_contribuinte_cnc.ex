# Gerado por `mix nfse.gen` a partir de tiposCnc_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCInfoContribuinteCNC do
  @moduledoc """
  Informações para cadastramento de novos contribuintes CNC

  Tipo `TCInfoContribuinteCNC` do leiaute 1.01, em `tiposCnc_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `cnpj` | `CNPJ` | `TSCNPJ` | 1, escolha 1 | Número do CNPJ |
  | `cpf` | `CPF` | `TSCPF` | 1, escolha 1 | Número do CPF |
  | `im` | `IM` | `TSInscMun` | 0..1 | Número da inscrição municipal |
  | `d_inscricao_municipal` | `dInscricaoMunicipal` | `TSData` | 1 | Data da Inscrição Municipal: Dia, mês e ano (AAAAMMDD) |
  | `ender_contribuinte_cnc` | `enderContribuinteCNC` | `Nfse.Schema.V1_01.TCEnderContribuinteCNC` | 1 | Grupo de informações do endereço do contribuinte do CNC |
  | `fone` | `fone` | `TSTelefone` | 0..1 | Número do telefone do prestador: Preencher com o Código DDD + número do telefone. Nas operações com exterior é permitido informar o código do país + código da localidade + número do telefone) |
  | `email` | `email` | `TSEmail` | 0..1 | Endereço de e-mail para contato com o contribuinte |
  | `reg_esp_trib_contribuinte_cnc` | `regEspTribContribuinteCNC` | `TSRegEspTrib` | 1 | Tipos de Regimes Especiais de Tributação: 0 - Nenhum; 1 - Ato Cooperado (Cooperativa); 2 - Estimativa; 3 - Microempresa Municipal; 4 - Notário ou Registrador; 5 - Profissional Autônomo; 6 - Sociedade de Profissionais; |
  | `situacao_cadastro_contribuinte` | `situacaoCadastroContribuinte` | `TSSituacaoCadastroContribuinte` | 0..1 | Identificação da situação do cadastro do contribuinte |
  | `motivo_situacao_cadastro_contribuinte` | `motivoSituacaoCadastroContribuinte` | `TSMotivoSituacaoCadastroContribuinte` | 0..1 | Motivo pelo qual o contribuinte se enquadra na situação informada |
  | `situacao_emissao_nfse` | `situacaoEmissaoNFSE` | `TSSituacaoEmissaoNFSE` | 1 | Situação Emissão NFS-e: 0 - Não Habilitado; 1 - Habilitado; |

  Escolha 1: exatamente um entre `cnpj` e `cpf`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCEnderContribuinteCNC}

  defstruct [
    :cnpj,
    :cpf,
    :im,
    :d_inscricao_municipal,
    :ender_contribuinte_cnc,
    :fone,
    :email,
    :reg_esp_trib_contribuinte_cnc,
    :situacao_cadastro_contribuinte,
    :motivo_situacao_cadastro_contribuinte,
    :situacao_emissao_nfse
  ]

  @type t :: %__MODULE__{
          cnpj: String.t() | nil,
          cpf: String.t() | nil,
          im: String.t() | nil,
          d_inscricao_municipal: Date.t() | nil,
          ender_contribuinte_cnc: TCEnderContribuinteCNC.t() | nil,
          fone: String.t() | nil,
          email: String.t() | nil,
          reg_esp_trib_contribuinte_cnc: String.t() | nil,
          situacao_cadastro_contribuinte: String.t() | nil,
          motivo_situacao_cadastro_contribuinte: String.t() | nil,
          situacao_emissao_nfse: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :cnpj, xml: "CNPJ", type: {:simple, "TSCNPJ"}, min: 1, max: 1, choice: 0},
      %Field{name: :cpf, xml: "CPF", type: {:simple, "TSCPF"}, min: 1, max: 1, choice: 0},
      %Field{name: :im, xml: "IM", type: {:simple, "TSInscMun"}, min: 0, max: 1},
      %Field{
        name: :d_inscricao_municipal,
        xml: "dInscricaoMunicipal",
        type: {:simple, "TSData"},
        min: 1,
        max: 1
      },
      %Field{
        name: :ender_contribuinte_cnc,
        xml: "enderContribuinteCNC",
        type: {:complex, TCEnderContribuinteCNC},
        min: 1,
        max: 1
      },
      %Field{name: :fone, xml: "fone", type: {:simple, "TSTelefone"}, min: 0, max: 1},
      %Field{name: :email, xml: "email", type: {:simple, "TSEmail"}, min: 0, max: 1},
      %Field{
        name: :reg_esp_trib_contribuinte_cnc,
        xml: "regEspTribContribuinteCNC",
        type: {:simple, "TSRegEspTrib"},
        min: 1,
        max: 1
      },
      %Field{
        name: :situacao_cadastro_contribuinte,
        xml: "situacaoCadastroContribuinte",
        type: {:simple, "TSSituacaoCadastroContribuinte"},
        min: 0,
        max: 1
      },
      %Field{
        name: :motivo_situacao_cadastro_contribuinte,
        xml: "motivoSituacaoCadastroContribuinte",
        type: {:simple, "TSMotivoSituacaoCadastroContribuinte"},
        min: 0,
        max: 1
      },
      %Field{
        name: :situacao_emissao_nfse,
        xml: "situacaoEmissaoNFSE",
        type: {:simple, "TSSituacaoEmissaoNFSE"},
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
