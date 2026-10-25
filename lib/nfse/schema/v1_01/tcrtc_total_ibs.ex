# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRTCTotalIBS do
  @moduledoc """
  Tipo `TCRTCTotalIBS` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `v_ibs_tot` | `vIBSTot` | `TSDec15V2` | 1 | Valor total do IBS. vIBSTot = vIBSUF + vIBSMun |
  | `g_ibs_cred_pres` | `gIBSCredPres` | `Nfse.Schema.V1_01.TCRTCTotalIBSCredPres` | 0..1 | Grupo de valores referentes ao crédito presumido para IBS |
  | `g_ibsuf_tot` | `gIBSUFTot` | `Nfse.Schema.V1_01.TCRTCTotalIBSUF` | 1 | Grupo de valores referentes ao IBS Estadual |
  | `g_ibs_mun_tot` | `gIBSMunTot` | `Nfse.Schema.V1_01.TCRTCTotalIBSMun` | 1 | Grupo de valores referentes ao IBS Municipal |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.{SimpleTypes, TCRTCTotalIBSCredPres, TCRTCTotalIBSMun, TCRTCTotalIBSUF}

  defstruct [:v_ibs_tot, :g_ibs_cred_pres, :g_ibsuf_tot, :g_ibs_mun_tot]

  @type t :: %__MODULE__{
          v_ibs_tot: Decimal.t() | nil,
          g_ibs_cred_pres: TCRTCTotalIBSCredPres.t() | nil,
          g_ibsuf_tot: TCRTCTotalIBSUF.t() | nil,
          g_ibs_mun_tot: TCRTCTotalIBSMun.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :v_ibs_tot, xml: "vIBSTot", type: {:simple, "TSDec15V2"}, min: 1, max: 1},
      %Field{
        name: :g_ibs_cred_pres,
        xml: "gIBSCredPres",
        type: {:complex, TCRTCTotalIBSCredPres},
        min: 0,
        max: 1
      },
      %Field{
        name: :g_ibsuf_tot,
        xml: "gIBSUFTot",
        type: {:complex, TCRTCTotalIBSUF},
        min: 1,
        max: 1
      },
      %Field{
        name: :g_ibs_mun_tot,
        xml: "gIBSMunTot",
        type: {:complex, TCRTCTotalIBSMun},
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
