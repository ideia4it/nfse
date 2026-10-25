# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCServ do
  @moduledoc """
  Tipo `TCServ` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `loc_prest` | `locPrest` | `Nfse.Schema.V1_00.TCLocPrest` | 1 | Grupo de informações relativas ao local da prestação do serviço |
  | `c_serv` | `cServ` | `Nfse.Schema.V1_00.TCCServ` | 1 | Grupo de informações relativas ao código do serviço prestado |
  | `com_ext` | `comExt` | `Nfse.Schema.V1_00.TCComExterior` | 0..1 | Grupo de informações relativas à exportação/importação de serviço prestado |
  | `lsadppu` | `lsadppu` | `Nfse.Schema.V1_00.TCLocacaoSublocacao` | 0..1 | Grupo de informações relativas a atividades de Locação, sublocação, arrendamento, direito de passagem ou permissão de uso, compartilhado ou não, de ferrovia, rodovia, postes, cabos, dutos e condutos de qualquer natureza |
  | `obra` | `obra` | `Nfse.Schema.V1_00.TCInfoObra` | 0..1 | Grupo de informações do DPS relativas à serviço de obra |
  | `atv_evento` | `atvEvento` | `Nfse.Schema.V1_00.TCAtvEvento` | 0..1 | Grupo de informações do DPS relativas à Evento |
  | `expl_rod` | `explRod` | `Nfse.Schema.V1_00.TCExploracaoRodoviaria` | 0..1 | Grupo de informações relativas a pedágio |
  | `info_compl` | `infoCompl` | `Nfse.Schema.V1_00.TCInfoCompl` | 0..1 | Grupo de informações complementares disponível para todos os serviços prestados |
  """

  alias Nfse.Schema.{Field, Runtime}

  alias Nfse.Schema.V1_00.{
    SimpleTypes,
    TCAtvEvento,
    TCComExterior,
    TCCServ,
    TCExploracaoRodoviaria,
    TCInfoCompl,
    TCInfoObra,
    TCLocacaoSublocacao,
    TCLocPrest
  }

  defstruct [:loc_prest, :c_serv, :com_ext, :lsadppu, :obra, :atv_evento, :expl_rod, :info_compl]

  @type t :: %__MODULE__{
          loc_prest: TCLocPrest.t() | nil,
          c_serv: TCCServ.t() | nil,
          com_ext: TCComExterior.t() | nil,
          lsadppu: TCLocacaoSublocacao.t() | nil,
          obra: TCInfoObra.t() | nil,
          atv_evento: TCAtvEvento.t() | nil,
          expl_rod: TCExploracaoRodoviaria.t() | nil,
          info_compl: TCInfoCompl.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :loc_prest, xml: "locPrest", type: {:complex, TCLocPrest}, min: 1, max: 1},
      %Field{name: :c_serv, xml: "cServ", type: {:complex, TCCServ}, min: 1, max: 1},
      %Field{name: :com_ext, xml: "comExt", type: {:complex, TCComExterior}, min: 0, max: 1},
      %Field{
        name: :lsadppu,
        xml: "lsadppu",
        type: {:complex, TCLocacaoSublocacao},
        min: 0,
        max: 1
      },
      %Field{name: :obra, xml: "obra", type: {:complex, TCInfoObra}, min: 0, max: 1},
      %Field{name: :atv_evento, xml: "atvEvento", type: {:complex, TCAtvEvento}, min: 0, max: 1},
      %Field{
        name: :expl_rod,
        xml: "explRod",
        type: {:complex, TCExploracaoRodoviaria},
        min: 0,
        max: 1
      },
      %Field{name: :info_compl, xml: "infoCompl", type: {:complex, TCInfoCompl}, min: 0, max: 1}
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
