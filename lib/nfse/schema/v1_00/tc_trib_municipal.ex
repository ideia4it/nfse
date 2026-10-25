# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCTribMunicipal do
  @moduledoc """
  Tipo `TCTribMunicipal` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `trib_issqn` | `tribISSQN` | `TSTribISSQN` | 1 | Tributação do ISSQN sobre o serviço prestado: 1 - Operação tributável; 2 - Exportação de serviço; 3 - Não Incidência; 4 - Imunidade; |
  | `c_pais_result` | `cPaisResult` | `TSCodPaisISO` | 0..1 | Código do país onde se verficou o resultado da prestação do serviço para o caso de Exportação de Serviço.(Tabela de Países ISO) |
  | `bm` | `BM` | `Nfse.Schema.V1_00.TCBeneficioMunicipal` | 0..1 | Tributação do ISSQN sobre o serviço prestado: 1 - Operação tributável; 2 - Exportação de serviço; 3 - Não Incidência; 4 - Imunidade; |
  | `exig_susp` | `exigSusp` | `Nfse.Schema.V1_00.TCExigSuspensa` | 0..1 | Informações para a suspensão da Exigibilidade do ISSQN |
  | `tp_imunidade` | `tpImunidade` | `TSTipoImunidadeISSQN` | 0..1 | Identificação da Imunidade do ISSQN – somente para o caso de Imunidade: 0 - Imunidade (tipo não informado na nota de origem); 1 - Patrimônio, renda ou serviços, uns dos outros (CF88, Art 150, VI, a); 2 - Templos de qualquer culto (CF88, Art 150, VI, b); 3 - Patrimônio, renda ou serviços dos partidos políticos, inclusive suas fundações, das entidades sindicais dos trabalhadores, das instituições de educação e de assistência social, sem fins lucrativos, atendidos os requisitos da lei (CF88, Art 150, VI, c); 4 - Livros, jornais, periódicos e o papel destinado a sua impressão (CF88, Art 150, VI, d); |
  | `p_aliq` | `pAliq` | `TSDec1V2` | 0..1 | Valor da alíquota (%) do serviço prestado relativo ao município sujeito ativo (município de incidência) do ISSQN. Se o município de incidência pertence ao Sistema Nacional NFS-e a alíquota estará parametrizada e, portanto, será fornecida pelo sistema. Se o município de incidência não pertence ao Sistema Nacional NFS-e a alíquota não estará parametrizada e, por isso, deverá ser fornecida pelo emitente. |
  | `tp_ret_issqn` | `tpRetISSQN` | `TSTipoRetISSQN` | 1 | Tipo de retencao do ISSQN: 1 - Não Retido; 2 - Retido pelo Tomador; 3 - Retido pelo Intermediario; |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCBeneficioMunicipal, TCExigSuspensa}

  defstruct [:trib_issqn, :c_pais_result, :bm, :exig_susp, :tp_imunidade, :p_aliq, :tp_ret_issqn]

  @type t :: %__MODULE__{
          trib_issqn: String.t() | nil,
          c_pais_result: String.t() | nil,
          bm: TCBeneficioMunicipal.t() | nil,
          exig_susp: TCExigSuspensa.t() | nil,
          tp_imunidade: String.t() | nil,
          p_aliq: Decimal.t() | nil,
          tp_ret_issqn: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :trib_issqn, xml: "tribISSQN", type: {:simple, "TSTribISSQN"}, min: 1, max: 1},
      %Field{
        name: :c_pais_result,
        xml: "cPaisResult",
        type: {:simple, "TSCodPaisISO"},
        min: 0,
        max: 1
      },
      %Field{name: :bm, xml: "BM", type: {:complex, TCBeneficioMunicipal}, min: 0, max: 1},
      %Field{name: :exig_susp, xml: "exigSusp", type: {:complex, TCExigSuspensa}, min: 0, max: 1},
      %Field{
        name: :tp_imunidade,
        xml: "tpImunidade",
        type: {:simple, "TSTipoImunidadeISSQN"},
        min: 0,
        max: 1
      },
      %Field{name: :p_aliq, xml: "pAliq", type: {:simple, "TSDec1V2"}, min: 0, max: 1},
      %Field{
        name: :tp_ret_issqn,
        xml: "tpRetISSQN",
        type: {:simple, "TSTipoRetISSQN"},
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
