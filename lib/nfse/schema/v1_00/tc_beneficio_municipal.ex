# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCBeneficioMunicipal do
  @moduledoc """
  Tipo `TCBeneficioMunicipal` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `tp_bm` | `tpBM` | `TSOpTipoBM` | 1 | Identificação da Lei parametrizada pelo município que define o benefício. Trata-se de um identificador único que foi gerado pelo Sistema Nacional no momento em que o município de incidência do ISSQN incluiu o benefício no sistema. Tem a seguinte regra de formação: 7 dígitos com o código IBGE do município + 4 dígitos com número sequencial. Deve ser obtido da parametrização do município de incidência do ISSQN. |
  | `n_bm` | `nBM` | `TSNumBeneficioMunicipal` | 1 | Identificador do benefício municipal parametrizado pelo município. |
  | `v_red_bcbm` | `vRedBCBM` | `TSDec15V2` | 0..1, escolha 1 | Valor monetário informado pelo emitente para redução da base de cálculo (BC) do ISSQN devido a um Benefício Municipal (BM). |
  | `p_red_bcbm` | `pRedBCBM` | `TSDec3V2` | 0..1, escolha 1 | Valor percentual informado pelo emitente para redução da base de cálculo (BC) do ISSQN devido a um Benefício Municipal (BM). |

  Escolha 1: no máximo um entre `v_red_bcbm` e `p_red_bcbm`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.SimpleTypes

  defstruct [:tp_bm, :n_bm, :v_red_bcbm, :p_red_bcbm]

  @type t :: %__MODULE__{
          tp_bm: String.t() | nil,
          n_bm: String.t() | nil,
          v_red_bcbm: Decimal.t() | nil,
          p_red_bcbm: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :tp_bm, xml: "tpBM", type: {:simple, "TSOpTipoBM"}, min: 1, max: 1},
      %Field{name: :n_bm, xml: "nBM", type: {:simple, "TSNumBeneficioMunicipal"}, min: 1, max: 1},
      %Field{
        name: :v_red_bcbm,
        xml: "vRedBCBM",
        type: {:simple, "TSDec15V2"},
        min: 0,
        max: 1,
        choice: 0
      },
      %Field{
        name: :p_red_bcbm,
        xml: "pRedBCBM",
        type: {:simple, "TSDec3V2"},
        min: 0,
        max: 1,
        choice: 0
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
