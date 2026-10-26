defmodule Nfse.NFSe do
  @moduledoc """
  A NFS-e inteira da emissão por decisão administrativa ou judicial, montada por quem emite.

  No fluxo normal, a Sefin recebe a DPS e calcula o resto da nota. Quando uma decisão
  administrativa ou judicial manda desviar das regras de validação, o contribuinte monta a NFS-e
  completa: a DPS e os campos que a plataforma geraria, como o local de incidência, a alíquota e os
  valores calculados. A Sefin faz só validações mínimas, e a responsabilidade por cada campo é do
  contribuinte, ainda que contrarie as regras de negócio da plataforma. O fluxo só funciona depois
  que o município cadastra a decisão, com o número do processo, e autoriza o contribuinte a usá-lo.

  A nota se envia com `Nfse.issue_by_court_order/2`. Os valores fixos e as regras de preenchimento
  vêm do "Manual de Contribuintes, Emissão por Decisão Administrativa ou Judicial" (v1.0, de
  26/01/2026).

  ## Campos

  Os campos do struct são os elementos do `Nfse.Schema.V1_01.TCInfNFSe`, menos os que o manual
  fixa e `build/2` preenche, mais `c_num`, com as mesmas regras de conversão. `dps` é a DPS embutida
  como `%{inf_dps: inf_dps}`, em que `inf_dps` tem os campos de `Nfse.DPS`. `build/2` aceita o
  struct ou um mapa com essas chaves.

  O manual destaca:

    * `n_nfse` é numerado pelo contribuinte, em sequência, sem coincidir com NFS-e existente
    * `x_loc_emi` e `x_loc_prestacao` são os nomes dos municípios de `c_loc_emi` e
      `c_loc_prestacao` da DPS, e `x_trib_nac` a descrição do `c_trib_nac`
    * `c_loc_incid` segue a decisão; se ela não trata do local de incidência, segue a LC 116/2003
    * a alíquota do ISSQN é obrigatória quando se aplica, ainda que a DPS normal a dispense

  ## O que `build/2` calcula

    * `Id` do `infNFSe`, com 53 caracteres: `"NFS"` e a chave de acesso, que junta o `c_loc_emi`
      da DPS, o ambiente gerador, o tipo e o número da inscrição de quem emite (o ator de `tp_emit`,
      como em `Nfse.DPS`), o `n_nfse` com 13 dígitos, o ano e o mês do `dh_emi` como `YYMM`, o
      `c_num` e o dígito verificador em módulo 11
    * `c_num`, quando não vem: nove dígitos sorteados com `:crypto.strong_rand_bytes/1`. O código
      precisa ser imprevisível, porque a chave de acesso dá acesso à nota; quem o informa deve
      sorteá-lo da mesma forma
    * os valores que o manual fixa: `c_stat` `"102"`, `amb_ger` `"2"`, `tp_emis` `"1"`, `n_dfse`
      `"0"` e `dh_proc` igual ao `dh_emi` da DPS
    * na DPS embutida, o `Id`, a `versao` e o `tp_amb`, como em `Nfse.DPS`. A DPS vai sem
      assinatura própria
    * `versao` da raiz, sempre `"1.01"`

  Depois valida, assina o `infNFSe` com o certificado do cliente e devolve o XML canônico, pronto
  para enviar, com o `Id`, a chave de acesso e o `Id` da DPS. Nada é reescrito entre assinar e
  devolver.

  Com o `c_num` sorteado, cada chamada gera outra chave. Quem precisa conferir pela chave um envio
  que ficou sem resposta informa o `c_num` e o guarda antes de enviar.

  ## Erros

  Os erros da nota e os da DPS embutida voltam juntos, como `%Nfse.Error{kind: :validation}`,
  antes de qualquer assinatura. Além dos erros do schema, descritos em `Nfse.Schema.Runtime`, e dos
  de `Nfse.DPS` (com o caminho começando em `dps.inf_dps`):

  | Caminho | Erro | Quando |
  |---|---|---|
  | `id`, `c_stat`, `amb_ger`, `tp_emis`, `n_dfse` ou `dh_proc` | `:unknown_field` | o chamador preencheu um campo que `build/2` calcula |
  | `c_num` | `:type` ou `:pattern` | `c_num` que não é uma string de nove dígitos |
  | `dps.versao` ou `dps.signature` | `:unknown_field` | o chamador preencheu a versão ou a assinatura da DPS embutida |

  ## Exemplo

      Nfse.NFSe.build(
        %Nfse.NFSe{
          x_loc_emi: "Salvador",
          x_loc_prestacao: "Salvador",
          n_nfse: 1,
          c_loc_incid: "2927408",
          x_loc_incid: "Salvador",
          x_trib_nac: "Barbearia, cabeleireiros, manicuros, pedicuros e congêneres.",
          ver_aplic: "nfse-0.1.0",
          emit: %{
            cnpj: "11222333000181",
            x_nome: "Studio Ana",
            ender_nac: %{
              x_lgr: "Rua das Flores",
              nro: "100",
              x_bairro: "Centro",
              c_mun: "2927408",
              uf: "BA",
              cep: "40000000"
            }
          },
          valores: %{
            v_bc: Decimal.new("49.90"),
            p_aliq_aplic: Decimal.new("2.00"),
            v_issqn: Decimal.new("1.00"),
            v_liq: Decimal.new("49.90")
          },
          dps: %{inf_dps: dps}
        },
        client
      )
      #=> {:ok, %{xml: "<?xml version=\"1.0\" encoding=\"UTF-8\"?><NFSe xmlns=...", id: "NFS2927408221122233300018100000000000012611...",
      #=>         access_key: "2927408221122233300018100000000000012611...",
      #=>         dps_id: "DPS292740821122233300018100001000000000000042"}}

  Aqui `dps` são os campos do exemplo de `Nfse.DPS`.

  ## O que não está confirmado

  A produção restrita não prova este fluxo sem que um município cadastre uma decisão e autorize o
  contribuinte. Até lá, ficam por confirmar:

    * a DPS embutida sem assinatura própria, com só o `infNFSe` assinado (a assinatura é opcional
      no `TCDPS`)
    * o município da chave de acesso como o `c_loc_emi` da DPS
    * o AnoMes da chave como o `YYMM` do `dh_emi` na hora de Brasília, a mesma que vai no XML
    * o `nDFSe` `"0"`, que o manual exige e o padrão do `TSNDFSe` no XSD 1.01 recusa
      (`[1-9]{1}[0-9]{0,12}`). A biblioteca segue o manual. Se a Sefin devolver a nota com o
      `nDFSe` `"0"`, a leitura estrita falha e `Nfse.issue_by_court_order/2` devolve `:unexpected`
      com a chave de acesso e o XML em `details`
  """

  alias Nfse.{Client, DPS, Error, Identifiers, Root}
  alias Nfse.Schema.SimpleType
  alias Nfse.Schema.V1_01.{TCDPS, TCInfNFSe}

  # O id, o dh_proc e o n_dfse são provisórios, válidos no schema e trocados depois da validação: o
  # Id e o dhProc saem da DPS já convertida, e o nDFSe "0" do manual não passa no padrão do XSD.
  @computed %{
    id: "NFS" <> String.duplicate("0", 50),
    dh_proc: ~U[2026-01-01 00:00:00Z],
    n_dfse: "1",
    c_stat: "102",
    amb_ger: "2",
    tp_emis: "1"
  }

  @n_dfse_by_manual "0"

  @dps_computed %{versao: Root.version(), signature: nil}

  defstruct (Enum.map(TCInfNFSe.__schema__(:fields), & &1.name) -- Map.keys(@computed)) ++
              [:c_num]

  @type t :: %__MODULE__{}

  @type built :: %{xml: binary(), id: String.t(), access_key: String.t(), dps_id: String.t()}

  @doc """
  Calcula a chave de acesso, o `Id` e os campos que o manual fixa, valida, assina e devolve o XML
  da NFS-e com o `Id`, a chave de acesso e o `Id` da DPS embutida.
  """
  @spec build(t() | map(), Client.t()) :: {:ok, built()} | {:error, Error.t()}
  def build(nfse, %Client{} = client) when is_map(nfse) do
    {c_num, attrs} = nfse |> Root.to_attrs() |> Map.pop(:c_num)

    with {:ok, inf_nfse} <- inf_nfse(attrs, c_num, client) do
      "NFS" <> access_key = inf_nfse.id

      {:ok,
       %{
         xml: Root.signed_xml(inf_nfse, "infNFSe", "NFSe", client.certificate),
         id: inf_nfse.id,
         access_key: access_key,
         dps_id: inf_nfse.dps.inf_dps.id
       }}
    end
  end

  defp inf_nfse(attrs, c_num, client) do
    {attrs, dps_errors} = prepare_dps(attrs, client)
    {attrs, caller_errors} = Root.prepare(TCInfNFSe, attrs, client, @computed)
    {c_num, c_num_errors} = checked_c_num(c_num)

    Root.validate(
      TCInfNFSe,
      attrs,
      caller_errors ++ c_num_errors ++ dps_errors,
      &put_computed(&1, c_num)
    )
  end

  defp prepare_dps(%{dps: dps} = attrs, client) when is_map(dps) do
    {dps_attrs, dps_errors} = Root.prepare(TCDPS, Root.to_attrs(dps), client, @dps_computed)
    {inf_dps, inf_dps_errors} = prepare_inf_dps(Map.get(dps_attrs, :inf_dps), client)

    {Map.put(attrs, :dps, Map.put(dps_attrs, :inf_dps, inf_dps)),
     within("dps", dps_errors ++ within("inf_dps", inf_dps_errors))}
  end

  defp prepare_dps(attrs, _client), do: {attrs, []}

  defp prepare_inf_dps(inf_dps, client) when is_map(inf_dps),
    do: DPS.prepare(Root.to_attrs(inf_dps), client)

  defp prepare_inf_dps(inf_dps, _client), do: {inf_dps, []}

  # Um c_num inválido volta como nil, para a chave ainda ser montada com um sorteado enquanto o erro
  # do chamador segue junto com os do schema.
  defp checked_c_num(nil), do: {nil, []}

  defp checked_c_num(c_num) when is_binary(c_num) do
    if c_num =~ ~r/\A\d{9}\z/,
      do: {c_num, []},
      else: {nil, [%{path: "c_num", error: :pattern}]}
  end

  defp checked_c_num(_c_num), do: {nil, [%{path: "c_num", error: :type}]}

  defp put_computed(%TCInfNFSe{dps: dps} = inf_nfse, c_num) do
    case DPS.put_id(dps.inf_dps) do
      {:ok, inf_dps} ->
        {:ok,
         %{
           inf_nfse
           | id: "NFS" <> access_key(inf_nfse, inf_dps, c_num || random_c_num()),
             dh_proc: inf_dps.dh_emi,
             n_dfse: @n_dfse_by_manual,
             dps: %{dps | inf_dps: inf_dps}
         }}

      {:error, errors} ->
        {:error, within("dps.inf_dps", errors)}
    end
  end

  defp access_key(inf_nfse, inf_dps, c_num) do
    {:ok, inscription} = DPS.issuer_inscription(inf_dps)

    Identifiers.access_key(
      inf_dps.c_loc_emi,
      inf_nfse.amb_ger,
      inscription,
      inf_nfse.n_nfse,
      Calendar.strftime(SimpleType.brasilia_wall_clock(inf_dps.dh_emi), "%y%m"),
      c_num
    )
  end

  # Nunca :rand: o cNum é o que impede adivinhar a chave de acesso, que dá acesso à nota.
  defp random_c_num do
    <<number::64>> = :crypto.strong_rand_bytes(8)

    number
    |> rem(1_000_000_000)
    |> Integer.to_string()
    |> String.pad_leading(9, "0")
  end

  defp within(parent_path, errors),
    do: Enum.map(errors, &%{&1 | path: parent_path <> "." <> &1.path})
end
