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
            c_serv: %{c_trib_nac: "010401", x_desc_serv: "Corte de cabelo"}
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
      #=> {:ok, %{xml: "<DPS xmlns=...", id: "DPS292740821122233300018100001000000000000042"}}
  """

  alias Nfse.{Client, Error, Identifiers, Signature}
  alias Nfse.Schema.V1_01.{TCDPS, TCInfDPS}

  @version "1.01"
  @root_opening_tag ~s(<DPS xmlns="http://www.sped.fazenda.gov.br/nfse" versao="#{@version}">)

  # A validação do TCInfDPS exige o Id, e o Id só sai dos campos já convertidos e validados
  # (`n_dps: 42` vira "42"). Este Id provisório, válido no padrão, deixa a primeira validação rodar
  # e é trocado pelo calculado antes de assinar.
  @provisional_id "DPS" <> String.duplicate("0", 42)

  @issuers %{"1" => :prest, "2" => :toma, "3" => :interm}

  defstruct Enum.map(TCInfDPS.__schema__(:fields), & &1.name)

  @type t :: %__MODULE__{}

  @type built :: %{xml: binary(), id: String.t()}

  @doc """
  Calcula `Id`, `versao` e `tpAmb`, valida, assina e devolve o XML da DPS com o `Id`.
  """
  @spec build(t() | map(), Client.t()) :: {:ok, built()} | {:error, Error.t()}
  def build(%__MODULE__{} = dps, %Client{} = client), do: build(Map.from_struct(dps), client)

  def build(attrs, %Client{} = client) when is_map(attrs) do
    with {:ok, inf_dps} <- inf_dps(attrs, client),
         {:ok, dps} <- TCDPS.new(%{versao: @version, inf_dps: inf_dps}) do
      {:ok, %{xml: signed_xml(dps.inf_dps, client.certificate), id: dps.inf_dps.id}}
    end
  end

  defp inf_dps(attrs, client) do
    caller_errors = id_errors(attrs) ++ Client.environment_errors(attrs, client)

    attrs
    |> Map.merge(%{tp_amb: Client.tp_amb(client), id: @provisional_id})
    |> TCInfDPS.new()
    |> put_dps_id()
    |> case do
      {:ok, inf_dps} when caller_errors == [] -> {:ok, inf_dps}
      {:ok, _inf_dps} -> {:error, %Error{kind: :validation, details: caller_errors}}
      {:error, errors} -> {:error, %Error{kind: :validation, details: caller_errors ++ errors}}
    end
  end

  defp id_errors(attrs) do
    if Map.has_key?(attrs, :id), do: [%{path: "id", error: :unknown_field}], else: []
  end

  defp put_dps_id({:error, %Error{details: errors}}), do: {:error, errors}

  defp put_dps_id({:ok, inf_dps}) do
    with {:ok, inscription} <- issuer_inscription(inf_dps) do
      id = Identifiers.dps_id(inf_dps.c_loc_emi, inscription, inf_dps.serie, inf_dps.n_dps)
      {:ok, %{inf_dps | id: id}}
    end
  end

  defp issuer_inscription(inf_dps) do
    issuer = Map.fetch!(@issuers, inf_dps.tp_emit)

    case Map.fetch!(inf_dps, issuer) do
      nil -> {:error, [%{path: Atom.to_string(issuer), error: :required}]}
      %{cnpj: cnpj} when is_binary(cnpj) -> {:ok, {:cnpj, cnpj}}
      %{cpf: cpf} when is_binary(cpf) -> {:ok, {:cpf, cpf}}
      _foreign_issuer -> {:error, [%{path: Atom.to_string(issuer), error: :inscription}]}
    end
  end

  # A raiz é escrita em volta dos bytes assinados, e não pelo TCDPS.encode: a assinatura só vale
  # para os bytes exatos que ela digeriu.
  defp signed_xml(inf_dps, certificate) do
    inf_dps_xml = inf_dps |> TCInfDPS.encode("infDPS") |> IO.iodata_to_binary()

    signature =
      Signature.sign(inf_dps_xml, inf_dps.id, certificate, Signature.default_algorithm())

    IO.iodata_to_binary([@root_opening_tag, inf_dps_xml, signature, "</DPS>"])
  end
end
