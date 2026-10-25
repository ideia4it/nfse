# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCRegTrib do
  @moduledoc """
  Tipo `TCRegTrib` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `op_simp_nac` | `opSimpNac` | `TSOpSimpNac` | 1 | Situação perante o Simples Nacional: 1 - Não Optante; 2 - Optante - Microempreendedor Individual (MEI); 3 - Optante - Microempresa ou Empresa de Pequeno Porte (ME/EPP); |
  | `reg_ap_trib_sn` | `regApTribSN` | `TSRegimeApuracaoSimpNac` | 0..1 | Opção para que o contribuinte optante pelo Simples Nacional ME/EPP (opSimpNac = 3) possa indicar, ao emitir o documento fiscal, em qual regime de apuração os tributos federais e municipal estão inseridos, caso tenha ultrapassado algum sublimite ou limite definido para o Simples Nacional. 1 – Regime de apuração dos tributos federais e municipal pelo SN; 2 – Regime de apuração dos tributos federais pelo SN e ISSQN por fora do SN conforme respectiva legislação municipal do tributo; 3 – Regime de apuração dos tributos federais e municipal por fora do SN conforme respectivas legislações federal e municipal de cada tributo; |
  | `reg_esp_trib` | `regEspTrib` | `TSRegEspTrib` | 1 | Tipos de Regimes Especiais de Tributação: 0 - Nenhum; 1 - Ato Cooperado (Cooperativa); 2 - Estimativa; 3 - Microempresa Municipal; 4 - Notário ou Registrador; 5 - Profissional Autônomo; 6 - Sociedade de Profissionais; 9 - Outros; |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [:op_simp_nac, :reg_ap_trib_sn, :reg_esp_trib]

  @type t :: %__MODULE__{
          op_simp_nac: String.t() | nil,
          reg_ap_trib_sn: String.t() | nil,
          reg_esp_trib: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :op_simp_nac,
        xml: "opSimpNac",
        type: {:simple, "TSOpSimpNac"},
        min: 1,
        max: 1
      },
      %Field{
        name: :reg_ap_trib_sn,
        xml: "regApTribSN",
        type: {:simple, "TSRegimeApuracaoSimpNac"},
        min: 0,
        max: 1
      },
      %Field{
        name: :reg_esp_trib,
        xml: "regEspTrib",
        type: {:simple, "TSRegEspTrib"},
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
