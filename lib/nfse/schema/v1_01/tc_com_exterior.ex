# Gerado por `mix nfse.gen` a partir de tiposComplexos_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.TCComExterior do
  @moduledoc """
  Tipo `TCComExterior` do leiaute 1.01, em `tiposComplexos_v1.01.xsd`.

  | Campo | XML | Tipo | Ocorrência | Descrição |
  |---|---|---|---|---|
  | `md_prestacao` | `mdPrestacao` | `TSModoPrestacao` | 1 | Modo de Prestação: 0 - Desconhecido (tipo não informado na nota de origem); 1 - Transfronteiriço; 2 - Consumo no Brasil; 3 - Movimento Temporário de Pessoas Físicas; 4 - Consumo no Exterior; |
  | `vinc_prest` | `vincPrest` | `TSVincPrest` | 1 | Vínculo entre as partes no negócio: 0 - Sem vínculo com o Tomador/Prestador 1 - Controlada; 2 - Controladora; 3 - Coligada; 4 - Matriz; 5 - Filial ou sucursal; 6 - Outro vínculo; 9 - Desconhecido (tipo não informado na nota de origem); |
  | `tp_moeda` | `tpMoeda` | `TSCodMoeda` | 1 | Identifica a moeda da transação comercial |
  | `v_serv_moeda` | `vServMoeda` | `TSDec15V2` | 1 | Valor do serviço prestado expresso em moeda estrangeira especificada em tpmoeda |
  | `mec_af_comex_p` | `mecAFComexP` | `TSMecAFComExPrest` | 1 | Mecanismo de apoio/fomento ao Comércio Exterior utilizado pelo prestador do serviço: 00 - Desconhecido (tipo não informado na nota de origem); 01 - Nenhum; 02 - ACC - Adiantamento sobre Contrato de Câmbio – Redução a Zero do IR e do IOF; 03 - ACE – Adiantamento sobre Cambiais Entregues - Redução a Zero do IR e do IOF; 04 - BNDES-Exim Pós-Embarque – Serviços; 05 - BNDES-Exim Pré-Embarque - Serviços; 06 - FGE - Fundo de Garantia à Exportação; 07 - PROEX - EQUALIZAÇÃO 08 - PROEX - Financiamento; |
  | `mec_af_comex_t` | `mecAFComexT` | `TSMecAFComExToma` | 1 | Mecanismo de apoio/fomento ao Comércio Exterior utilizado pelo tomador do serviço: 00 - Desconhecido (tipo não informado na nota de origem); 01 - Nenhum; 02 - Adm. Pública e Repr. Internacional; 03 - Alugueis e Arrend. Mercantil de maquinas, equip., embarc. e aeronaves; 04 - Arrendamento Mercantil de aeronave para empresa de transporte aéreo público; 05 - Comissão a agentes externos na exportação; 06 - Despesas de armazenagem, mov. e transporte de carga no exterior; 07 - Eventos FIFA (subsidiária); 08 - Eventos FIFA; 09 - Fretes, arrendamentos de embarcações ou aeronaves e outros; 10 - Material Aeronáutico; 11 - Promoção de Bens no Exterior; 12 - Promoção de Dest. Turísticos Brasileiros; 13 - Promoção do Brasil no Exterior; 14 - Promoção Serviços no Exterior; 15 - RECINE; 16 - RECOPA; 17 - Registro e Manutenção de marcas, patentes e cultivares; 18 - REICOMP; 19 - REIDI; 20 - REPENEC; 21 - REPES; 22 - RETAERO; 23 - RETID; 24 - Royalties, Assistência Técnica, Científica e Assemelhados; 25 - Serviços de avaliação da conformidade vinculados aos Acordos da OMC; 26 - ZPE; |
  | `mov_temp_bens` | `movTempBens` | `TSMovTempBens` | 1 | Vínculo da Operação à Movimentação Temporária de Bens: 0 - Desconhecido (tipo não informado na nota de origem); 1 - Não; 2 - Vinculada - Declaração de Importação; 3 - Vinculada - Declaração de Exportação; |
  | `n_di` | `nDI` | `TSNumDocImport` | 0..1 | Número da Declaração de Importação (DI/DSI/DA/DRI-E) averbado |
  | `n_re` | `nRE` | `TSNumRegExport` | 0..1 | Número do Registro de Exportação (RE) averbado |
  | `mdic` | `mdic` | `TSEnvMDIC` | 1 | Compartilhar as informações da NFS-e gerada a partir desta DPS com a Secretaria de Comércio Exterior: 0 - Não enviar para o MDIC; 1 - Enviar para o MDIC; |
  """

  alias Nfse.Schema.{Field, Runtime}
  alias Nfse.Schema.V1_01.SimpleTypes

  defstruct [
    :md_prestacao,
    :vinc_prest,
    :tp_moeda,
    :v_serv_moeda,
    :mec_af_comex_p,
    :mec_af_comex_t,
    :mov_temp_bens,
    :n_di,
    :n_re,
    :mdic
  ]

  @type t :: %__MODULE__{
          md_prestacao: String.t() | nil,
          vinc_prest: String.t() | nil,
          tp_moeda: String.t() | nil,
          v_serv_moeda: Decimal.t() | nil,
          mec_af_comex_p: String.t() | nil,
          mec_af_comex_t: String.t() | nil,
          mov_temp_bens: String.t() | nil,
          n_di: String.t() | nil,
          n_re: String.t() | nil,
          mdic: String.t() | nil
        }

  @doc false
  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: SimpleTypes
  def __schema__(:choices), do: []
  def __schema__(:attributes), do: []

  def __schema__(:fields),
    do: [
      %Field{
        name: :md_prestacao,
        xml: "mdPrestacao",
        type: {:simple, "TSModoPrestacao"},
        min: 1,
        max: 1
      },
      %Field{name: :vinc_prest, xml: "vincPrest", type: {:simple, "TSVincPrest"}, min: 1, max: 1},
      %Field{name: :tp_moeda, xml: "tpMoeda", type: {:simple, "TSCodMoeda"}, min: 1, max: 1},
      %Field{
        name: :v_serv_moeda,
        xml: "vServMoeda",
        type: {:simple, "TSDec15V2"},
        min: 1,
        max: 1
      },
      %Field{
        name: :mec_af_comex_p,
        xml: "mecAFComexP",
        type: {:simple, "TSMecAFComExPrest"},
        min: 1,
        max: 1
      },
      %Field{
        name: :mec_af_comex_t,
        xml: "mecAFComexT",
        type: {:simple, "TSMecAFComExToma"},
        min: 1,
        max: 1
      },
      %Field{
        name: :mov_temp_bens,
        xml: "movTempBens",
        type: {:simple, "TSMovTempBens"},
        min: 1,
        max: 1
      },
      %Field{name: :n_di, xml: "nDI", type: {:simple, "TSNumDocImport"}, min: 0, max: 1},
      %Field{name: :n_re, xml: "nRE", type: {:simple, "TSNumRegExport"}, min: 0, max: 1},
      %Field{name: :mdic, xml: "mdic", type: {:simple, "TSEnvMDIC"}, min: 1, max: 1}
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
