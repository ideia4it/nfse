# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCTribTotal do
  @moduledoc """
  Tipo `TCTribTotal` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `v_tot_trib` | `vTotTrib` | `Nfse.Schema.V1_00.TCTribTotalMonet` | 1, escolha 1 | Valor monetário total aproximado dos tributos, em conformidade com o artigo 1o da Lei no 12.741/2012 |
  | `p_tot_trib` | `pTotTrib` | `Nfse.Schema.V1_00.TCTribTotalPercent` | 1, escolha 1 | Valor percentual total aproximado dos tributos, em conformidade com o artigo 1o da Lei no 12.741/2012 |
  | `ind_tot_trib` | `indTotTrib` | `TSTipoIndTotTrib` | 1, escolha 1 | Indicador de informação de valor total de tributos. Possui valor fixo igual a zero (indTotTrib=0). Não informar nenhum valor estimado para os Tributos (Decreto 8.264/2014). 0 - Não; |
  | `p_tot_trib_sn` | `pTotTribSN` | `TSDec2V2` | 1, escolha 1 | Valor percentual aproximado do total dos tributos da alíquota do Simples Nacional (%) |

  Escolha 1: exatamente um entre `v_tot_trib`, `p_tot_trib`, `ind_tot_trib` e `p_tot_trib_sn`.
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.{SimpleTypes, TCTribTotalMonet, TCTribTotalPercent}

  defstruct [:v_tot_trib, :p_tot_trib, :ind_tot_trib, :p_tot_trib_sn]

  @type t :: %__MODULE__{
          v_tot_trib: TCTribTotalMonet.t() | nil,
          p_tot_trib: TCTribTotalPercent.t() | nil,
          ind_tot_trib: String.t() | nil,
          p_tot_trib_sn: Decimal.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: [%{index: 0, min: 1}]
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :v_tot_trib,
        xml: "vTotTrib",
        type: {:complex, TCTribTotalMonet},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :p_tot_trib,
        xml: "pTotTrib",
        type: {:complex, TCTribTotalPercent},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :ind_tot_trib,
        xml: "indTotTrib",
        type: {:simple, "TSTipoIndTotTrib"},
        min: 1,
        max: 1,
        choice: 0
      },
      %Field{
        name: :p_tot_trib_sn,
        xml: "pTotTribSN",
        type: {:simple, "TSDec2V2"},
        min: 1,
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
