# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCValoresIBSCBS do
  @moduledoc """
  Tipo `TCRTCValoresIBSCBS` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `v_bc` | `vBC` | `TSDec15V2` | 1 | Valor da base de cálculo (BC) do IBS/CBS antes das reduções para cálculo do tributo bruto vBC = vServ - descIncond – vCalcReeRepRes – vISSQN – vPIS - vCOFINS (até 2026) ou vBC = vServ - descIncond – vCalcReeRepRes – vISSQN (até 2032) |
  | `v_calc_ree_rep_res` | `vCalcReeRepRes` | `TSDec15V2` | 0..1 | Valor monetário (R$) total relativo ao fornecimento próprio de bens materiais ou relacionados a operações de terceiros, objeto de reembolso, repasse ou ressarcimento pelo recebedor, já tributados e aqui referenciados e que não integram da base de cálculo (BC) do ISSQN, do IBS e da CBS. |
  | `uf` | `uf` | `Nfse.Schema.V1_01.TCRTCValoresIBSCBSUF` | 1 | Grupo de Informações relativas aos valores do IBS Estadual |
  | `mun` | `mun` | `Nfse.Schema.V1_01.TCRTCValoresIBSCBSMun` | 1 | Grupo de Informações relativas aos valores do IBS Municipal |
  | `fed` | `fed` | `Nfse.Schema.V1_01.TCRTCValoresIBSCBSFed` | 1 | Grupo de Informações relativas aos valores da CBS |
  """

  alias Nfse.Schema.{Field, Runtime}

  alias Nfse.Schema.V1_01.{
    SimpleTypes,
    TCRTCValoresIBSCBSFed,
    TCRTCValoresIBSCBSMun,
    TCRTCValoresIBSCBSUF
  }

  defstruct [:v_bc, :v_calc_ree_rep_res, :uf, :mun, :fed]

  @type t :: %__MODULE__{
          v_bc: Decimal.t() | nil,
          v_calc_ree_rep_res: Decimal.t() | nil,
          uf: TCRTCValoresIBSCBSUF.t() | nil,
          mun: TCRTCValoresIBSCBSMun.t() | nil,
          fed: TCRTCValoresIBSCBSFed.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :v_bc, xml: "vBC", type: {:simple, "TSDec15V2"}, min: 1, max: 1},
      %Field{
        name: :v_calc_ree_rep_res,
        xml: "vCalcReeRepRes",
        type: {:simple, "TSDec15V2"},
        min: 0,
        max: 1
      },
      %Field{name: :uf, xml: "uf", type: {:complex, TCRTCValoresIBSCBSUF}, min: 1, max: 1},
      %Field{name: :mun, xml: "mun", type: {:complex, TCRTCValoresIBSCBSMun}, min: 1, max: 1},
      %Field{name: :fed, xml: "fed", type: {:complex, TCRTCValoresIBSCBSFed}, min: 1, max: 1}
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
