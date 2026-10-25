# Emitir uma NFS-e

A emissão é síncrona: `Nfse.issue/2` monta, valida e assina a DPS, envia a `POST /nfse` e devolve a NFS-e calculada pela Sefin na mesma chamada.

O exemplo abaixo emite o corte de cabelo de R$ 49,90 do "Studio Ana", prestadora do Simples Nacional em Salvador, para uma cliente pessoa física.

```elixir
dps = %Nfse.DPS{
  dh_emi: DateTime.truncate(DateTime.utc_now(), :second),
  ver_aplic: "studio-ana-1.0",
  serie: "1",
  n_dps: 42,
  d_compet: Date.utc_today(),
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
}

case Nfse.issue(client, dps) do
  {:ok, %Nfse.Issued{} = issued} ->
    issued.access_key
    #=> "29274082211222333000181000000000000126110000000001"
    issued.dps_id
    #=> "DPS292740821122233300018100001000000000000042"

  {:error, %Nfse.Error{kind: :rejected, messages: messages}} ->
    messages

  {:error, %Nfse.Error{kind: kind, dps_id: dps_id}} when kind in [:timeout, :transport, :server] ->
    {:incerto, dps_id}
end
```

Guarde `issued.access_key` e `issued.xml` na hora. O `xml` é a NFS-e exatamente como a Sefin a devolveu, e é ele que você distribui ao tomador. `issued.nfse` traz o mesmo documento lido, e `issued.alerts` os avisos da Sefin, que não impedem a emissão.

## Como os campos são escritos

Os campos seguem o nome do XSD em `snake_case`, com as siglas NFSe, DFSe, NFe e DFe contadas como uma palavra só: `cLocEmi` vira `c_loc_emi` e `infNFSe` vira `inf_nfse`. Cada grupo aninhado aceita um mapa com as mesmas chaves, e a tabela de campos de cada módulo está em `Nfse.Schema.V1_01`.

Você não preenche:

  * o `Id` da DPS, que `Nfse.DPS.build/2` calcula a partir do município, da inscrição de quem emite, da série e do `n_dps`
  * a `versao`, sempre `"1.01"`
  * o `tp_amb`, que vem do ambiente do cliente

O `n_dps` é a sequência da sua empresa. Escolha-o antes de enviar e guarde-o: o `Id` da DPS sai dele, e é pelo `Id` que se confere uma emissão incerta.

Dinheiro é sempre `Decimal`. Um valor com mais de duas casas (`Decimal.new("49.905")`) volta como erro `:fraction_digits`, nunca arredondado, e `Decimal.new("49.9")` sai como `49.90`.

## Erros antes da rede

Um documento que não passa no schema volta como `%Nfse.Error{kind: :validation}`, sem tocar a rede e sem assinar. Todos os erros vêm juntos, cada um com o caminho do campo:

```elixir
{:error, %Nfse.Error{kind: :validation, details: details}} =
  Nfse.issue(client, %{dps | toma: %{cpf: "52998224725", x_nome: "Ana Souza", cpf_: "1"}})

details
#=> [%{path: "toma.cpf_", error: :unknown_field}]
```

Uma chave desconhecida num mapa aninhado nunca é descartada em silêncio. Texto fora do Latin-1 (emoji, aspas curvas, reticências) num campo derivado de `TSString`, como `ver_aplic`, também volta como erro `:pattern` com o caminho do campo. Já `x_nome` e `x_desc_serv` não têm esse padrão no XSD e a biblioteca o segue: se a Sefin aceita emoji nesses campos, só a execução contra a produção restrita mostra (veja o README).

## Erros da Sefin

| `kind` | Significado | O que fazer |
|---|---|---|
| `:rejected` | 400, regra de negócio. `messages` traz o código (`E....`) e a descrição | corrigir o dado e emitir de novo |
| `:forbidden` | 403, certificado ou ator sem acesso | conferir o certificado e o CNPJ |
| `:timeout`, `:transport`, `:server` | sem resposta ou 5xx; **a nota pode ter sido emitida** | conferir, sem reenviar: [Conferir após timeout](conferir-apos-timeout.md) |
| `:unexpected` | a resposta não pôde ser lida | ver abaixo |

Todo erro de `Nfse.issue/2` posterior à montagem da DPS traz o `dps_id`.

Uma resposta 201 cujo XML não passa na leitura estrita volta como `:unexpected`, nunca como `:validation`, porque a nota existe. Nesse caso `details` traz `access_key`, `xml` e o motivo em `reason`; guarde a chave e o XML antes de investigar.

```elixir
{:error, %Nfse.Error{kind: :unexpected, details: %{access_key: access_key, xml: xml}}} =
  Nfse.issue(client, dps)
```

## Consultar uma nota

```elixir
{:ok, %Nfse.Document{} = document} = Nfse.fetch(client, access_key)
document.nfse.inf_nfse.n_nfse
```

## Emissão por decisão judicial

Quando uma decisão administrativa ou judicial manda desviar das regras de validação, `Nfse.issue_by_court_order/2` envia a NFS-e inteira, montada e assinada por `Nfse.NFSe.build/2`, a `POST /decisao-judicial/nfse`. O município precisa cadastrar a decisão, com o número do processo, e autorizar o contribuinte antes; a responsabilidade por cada campo é de quem emite.

```elixir
Nfse.issue_by_court_order(client, %Nfse.NFSe{
  x_loc_emi: "Salvador",
  x_loc_prestacao: "Salvador",
  n_nfse: 1,
  c_loc_incid: "2927408",
  x_loc_incid: "Salvador",
  x_trib_nac: "Barbearia, cabeleireiros, manicuros, pedicuros e congêneres.",
  ver_aplic: "studio-ana-1.0",
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
  dps: %{inf_dps: inf_dps}
})
```

Aqui `inf_dps` são os campos da DPS do exemplo acima, como mapa. Este fluxo não pôde ser provado contra a Sefin sem a autorização de um município: veja "O que não está confirmado" em `Nfse.NFSe`. A escrita sai uma única vez e valem as mesmas regras de [Conferir após timeout](conferir-apos-timeout.md).
