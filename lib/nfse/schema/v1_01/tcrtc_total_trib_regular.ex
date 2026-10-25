# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCTotalTribRegular do
  @moduledoc """
  Tipo `TCRTCTotalTribRegular` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `p_aliq_efe_reg_ibsuf` | `pAliqEfeRegIBSUF` | `TSDec2V2` | 1 | Alíquota efetiva de tributação regular do IBS estadual |
  | `v_trib_reg_ibsuf` | `vTribRegIBSUF` | `TSDec15V2` | 1 | Valor da tributação regular do IBS estadual vTribRegIBSUF = vBC x pAliqEfeRegIBSUF |
  | `p_aliq_efe_reg_ibs_mun` | `pAliqEfeRegIBSMun` | `TSDec2V2` | 1 | Alíquota efetiva de tributação regular do IBS municipal |
  | `v_trib_reg_ibs_mun` | `vTribRegIBSMun` | `TSDec15V2` | 1 | Valor da tributação regular do IBS municipal vTribRegIBSMun = vBC x pAliqEfeRegIBSMun |
  | `p_aliq_efe_reg_cbs` | `pAliqEfeRegCBS` | `TSDec2V2` | 1 | Alíquota efetiva de tributação regular da CBS |
  | `v_trib_reg_cbs` | `vTribRegCBS` | `TSDec15V2` | 1 | Valor da tributação regular da CBS vTribRegCBS = vBC x pAliqEfeRegCBS |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [
    :p_aliq_efe_reg_ibsuf,
    :v_trib_reg_ibsuf,
    :p_aliq_efe_reg_ibs_mun,
    :v_trib_reg_ibs_mun,
    :p_aliq_efe_reg_cbs,
    :v_trib_reg_cbs
  ]

  @type t :: %__MODULE__{
          p_aliq_efe_reg_ibsuf: Decimal.t() | nil,
          v_trib_reg_ibsuf: Decimal.t() | nil,
          p_aliq_efe_reg_ibs_mun: Decimal.t() | nil,
          v_trib_reg_ibs_mun: Decimal.t() | nil,
          p_aliq_efe_reg_cbs: Decimal.t() | nil,
          v_trib_reg_cbs: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :p_aliq_efe_reg_ibsuf,
        xml: "pAliqEfeRegIBSUF",
        type: {:simple, "TSDec2V2"},
        min: 1,
        max: 1
      },
      %Field{
        name: :v_trib_reg_ibsuf,
        xml: "vTribRegIBSUF",
        type: {:simple, "TSDec15V2"},
        min: 1,
        max: 1
      },
      %Field{
        name: :p_aliq_efe_reg_ibs_mun,
        xml: "pAliqEfeRegIBSMun",
        type: {:simple, "TSDec2V2"},
        min: 1,
        max: 1
      },
      %Field{
        name: :v_trib_reg_ibs_mun,
        xml: "vTribRegIBSMun",
        type: {:simple, "TSDec15V2"},
        min: 1,
        max: 1
      },
      %Field{
        name: :p_aliq_efe_reg_cbs,
        xml: "pAliqEfeRegCBS",
        type: {:simple, "TSDec2V2"},
        min: 1,
        max: 1
      },
      %Field{
        name: :v_trib_reg_cbs,
        xml: "vTribRegCBS",
        type: {:simple, "TSDec15V2"},
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
