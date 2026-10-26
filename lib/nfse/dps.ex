defmodule Nfse.DPS do
  @moduledoc """
  A DPS (Declaração de Prestação de Serviço) que vira NFS-e, montada a partir dos campos que quem
  emite preenche.

  Os campos do struct são os elementos do `Nfse.Schema.V1_01.TCInfDPS`, com os mesmos nomes e as
  mesmas regras de conversão: cada grupo aninhado aceita o struct gerado ou um mapa com as mesmas
  chaves. `build/2` aceita o struct ou um mapa com essas chaves.

  ## O que `build/2` calcula

    * `Id` do `infDPS`, com 45 caracteres: `"DPS"`, `c_loc_emi`, o tipo da inscrição federal
      (`"1"` para CPF, `"2"` para CNPJ), o CNPJ ou CPF com 14 dígitos, a `serie` com 5 e o `n_dps`
      com 15, completados com zeros à esquerda só dentro do `Id`. A inscrição é a de quem emite,
      conforme `tp_emit`: `"1"` o prestador (`prest`), `"2"` o tomador (`toma`) e `"3"` o
      intermediário (`interm`)
    * `versao` da raiz, sempre `"1.01"`
    * `tp_amb`, a partir do ambiente do cliente. Pode ser omitido; se vier, precisa ser o do
      cliente, para que um documento de produção nunca vá à produção restrita, nem o contrário

  Depois valida, assina o `infDPS` com o certificado do cliente e devolve o XML canônico, pronto
  para enviar, com o `Id`, que serve para conferir a DPS na Sefin. Nada é reescrito entre assinar e
  devolver.

  ## Erros

  Os erros voltam juntos, como `%Nfse.Error{kind: :validation}`, antes de qualquer assinatura. Além
  dos erros do schema, descritos em `Nfse.Schema.Runtime`:

  | Caminho | Erro | Quando |
  |---|---|---|
  | `id` | `:unknown_field` | o chamador passou `id`, que é sempre calculado |
  | `tp_amb` | `:environment` | `tp_amb` diferente do ambiente do cliente |
  | `prest`, `toma` ou `interm` | `:required` | o grupo de quem emite, conforme `tp_emit`, está ausente |
  | `prest`, `toma` ou `interm` | `:inscription` | quem emite não tem CNPJ nem CPF (usa `nif` ou `c_nao_nif`) |

  ## Exemplo

      Nfse.DPS.build(
        %Nfse.DPS{
          dh_emi: ~U[2026-11-03 13:00:00Z],
          ver_aplic: "nfse-0.1.0",
          serie: "1",
          n_dps: 42,
          d_compet: ~D[2026-11-03],
          tp_emit: 1,
          c_loc_emi: "2927408",
          prest: %{
            cnpj: "11222333000181",
            reg_trib: %{op_simp_nac: 3, reg_ap_trib_sn: 1, reg_esp_trib: 0}
          },
          toma: %{cpf: "52998224725", x_nome: "Ana Souza"},
          serv: %{
            loc_prest: %{c_loc_prestacao: "2927408"},
            c_serv: %{c_trib_nac: "060101", x_desc_serv: "Corte de cabelo"}
          },
          valores: %{
            v_serv_prest: %{v_serv: Decimal.new("49.90")},
            trib: %{
              trib_mun: %{trib_issqn: 1, tp_ret_issqn: 1},
              tot_trib: %{p_tot_trib_sn: Decimal.new("6.00")}
            }
          }
        },
        client
      )
      #=> {:ok, %{xml: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><DPS xmlns=...", id: "DPS292740821122233300018100001000000000000042"}}
  """

  alias Nfse.{Client, Error, Identifiers, Root}
  alias Nfse.Schema.V1_01.{TCDPS, TCInfDPS}

  # O tipo de inscrição "1" deixa o Id provisório válido também no padrão da NT 009.
  @computed %{id: "DPS0000000" <> "1" <> String.duplicate("0", 34)}

  @issuers %{"1" => :prest, "2" => :toma, "3" => :interm}

  defstruct Enum.map(TCInfDPS.__schema__(:fields), & &1.name)

  @type t :: %__MODULE__{}

  @type built :: %{xml: binary(), id: String.t()}

  @doc """
  Calcula `Id`, `versao` e `tpAmb`, valida, assina e devolve o XML da DPS com o `Id`.
  """
  @spec build(t() | map(), Client.t()) :: {:ok, built()} | {:error, Error.t()}
  def build(dps, %Client{} = client) when is_map(dps) do
    with {:ok, inf_dps} <- inf_dps(Root.to_attrs(dps), client),
         {:ok, dps} <- TCDPS.new(%{versao: Root.version(), inf_dps: inf_dps}) do
      {:ok,
       %{xml: Root.signed_xml(dps.inf_dps, "infDPS", "DPS", client.certificate), id: inf_dps.id}}
    end
  end

  @doc false
  @spec prepare(map(), Client.t()) :: {map(), [Root.detail()]}
  def prepare(attrs, %Client{} = client), do: Root.prepare(TCInfDPS, attrs, client, @computed)

  @doc false
  @spec put_id(TCInfDPS.t()) :: {:ok, TCInfDPS.t()} | {:error, [Root.detail()]}
  def put_id(inf_dps) do
    with {:ok, inscription} <- issuer_inscription(inf_dps) do
      id = Identifiers.dps_id(inf_dps.c_loc_emi, inscription, inf_dps.serie, inf_dps.n_dps)
      {:ok, %{inf_dps | id: id}}
    end
  end

  @doc false
  @spec issuer_inscription(TCInfDPS.t()) ::
          {:ok, Identifiers.inscription()} | {:error, [Root.detail()]}
  def issuer_inscription(inf_dps) do
    issuer = Map.fetch!(@issuers, inf_dps.tp_emit)

    case Map.fetch!(inf_dps, issuer) do
      nil -> {:error, [%{path: Atom.to_string(issuer), error: :required}]}
      %{cnpj: cnpj} when is_binary(cnpj) -> {:ok, {:cnpj, cnpj}}
      %{cpf: cpf} when is_binary(cpf) -> {:ok, {:cpf, cpf}}
      _foreign_issuer -> {:error, [%{path: Atom.to_string(issuer), error: :inscription}]}
    end
  end

  defp inf_dps(attrs, client), do: Root.build_inf(TCInfDPS, attrs, client, @computed, &put_id/1)
end
