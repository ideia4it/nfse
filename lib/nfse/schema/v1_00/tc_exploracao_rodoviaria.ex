# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.00.xsd. Não edite.
defmodule Nfse.Schema.V1_00.TCExploracaoRodoviaria do
  @moduledoc """
  Tipo `TCExploracaoRodoviaria` do leiaute 1.00, em `tiposComplexos_v1.00.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `categ_veic` | `categVeic` | `TSCategVeic` | 1 | Categorias de veículos para cobrança: 00 - Categoria de veículos (tipo não informado na nota de origem) 01 - Automóvel, caminhonete e furgão; 02 - Caminhão leve, ônibus, caminhão trator e furgão; 03 - Automóvel e caminhonete com semireboque; 04 - Caminhão, caminhão-trator, caminhão-trator com semi-reboque e ônibus; 05 - Automóvel e caminhonete com reboque; 06 - Caminhão com reboque; 07 - Caminhão trator com semi-reboque; 08 - Motocicletas, motonetas e bicicletas motorizadas; 09 - Veículo especial; 10 - Veículo Isento; |
  | `n_eixos` | `nEixos` | `TSNumEixos` | 1 | Número de eixos para fins de cobrança |
  | `rodagem` | `rodagem` | `TSRodagem` | 1 | Tipo de rodagem |
  | `sentido` | `sentido` | `TSSentido` | 1 | Placa do veículo |
  | `placa` | `placa` | `TSPlaca` | 1 | Placa do veículo |
  | `cod_acesso_ped` | `codAcessoPed` | `TSCodAcessoPed` | 1 | Código de acesso gerado automaticamente pelo sistema emissor da concessionária. |
  | `cod_contrato` | `codContrato` | `TSCodContrato` | 1 | Código de contrato gerado automaticamente pelo sistema nacional no cadastro da concessionária. |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_00.SimpleTypes

  defstruct [:categ_veic, :n_eixos, :rodagem, :sentido, :placa, :cod_acesso_ped, :cod_contrato]

  @type t :: %__MODULE__{
          categ_veic: String.t() | nil,
          n_eixos: String.t() | nil,
          rodagem: String.t() | nil,
          sentido: String.t() | nil,
          placa: String.t() | nil,
          cod_acesso_ped: String.t() | nil,
          cod_contrato: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.00"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{name: :categ_veic, xml: "categVeic", type: {:simple, "TSCategVeic"}, min: 1, max: 1},
      %Field{name: :n_eixos, xml: "nEixos", type: {:simple, "TSNumEixos"}, min: 1, max: 1},
      %Field{name: :rodagem, xml: "rodagem", type: {:simple, "TSRodagem"}, min: 1, max: 1},
      %Field{name: :sentido, xml: "sentido", type: {:simple, "TSSentido"}, min: 1, max: 1},
      %Field{name: :placa, xml: "placa", type: {:simple, "TSPlaca"}, min: 1, max: 1},
      %Field{
        name: :cod_acesso_ped,
        xml: "codAcessoPed",
        type: {:simple, "TSCodAcessoPed"},
        min: 1,
        max: 1
      },
      %Field{
        name: :cod_contrato,
        xml: "codContrato",
        type: {:simple, "TSCodContrato"},
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
