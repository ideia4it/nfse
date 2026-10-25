# Nfse

Cliente Elixir para a NFS-e Nacional: emite, consulta e cancela a nota pela Sefin Nacional, assina a DPS com o certificado A1 do emitente, importa documentos pelo ADN e lê os parâmetros municipais.

Só depende de `req`, `decimal` e `saxy`. Não há processo, `Application` nem configuração global: tudo passa por um `%Nfse.Client{}`.

## Instalação

```elixir
def deps do
  [
    {:nfse, "~> 0.1.0"}
  ]
end
```

Requer Elixir 1.15 e OTP 26 ou mais novos. O `openssl` do sistema precisa estar instalado, porque é ele que abre o `.pfx`. Veja o guia [Certificado digital](guides/certificado.md).

## Exemplo

Emissão do corte de cabelo de R$ 49,90 do "Studio Ana", prestadora do Simples Nacional em Salvador, na produção restrita:

```elixir
{:ok, certificate} =
  "certificado.pfx"
  |> File.read!()
  |> Nfse.Certificate.from_pfx(System.fetch_env!("NFSE_PFX_PASSWORD"))

{:ok, client} = Nfse.Client.new(certificate: certificate, environment: :restricted)

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

{:ok, issued} = Nfse.issue(client, dps)

issued.access_key
issued.xml
```

Os campos seguem o nome do XSD em `snake_case`, com as siglas NFSe, DFSe, NFe e DFe contadas como uma palavra só (`infNFSe` vira `inf_nfse`). Toda função pública devolve `{:ok, _}` ou `{:error, %Nfse.Error{}}`, com uma exceção: `Nfse.stream_distribution/3` levanta `Nfse.Error`.

## Guias

  * [Certificado digital](guides/certificado.md)
  * [Ambientes](guides/ambientes.md)
  * [Emitir uma NFS-e](guides/emitir.md)
  * [Conferir após timeout](guides/conferir-apos-timeout.md)
  * [Cancelar e registrar eventos](guides/cancelar.md)
  * [Importar notas pelo ADN](guides/importar-pelo-adn.md)
  * [Parâmetros municipais](guides/parametros-municipais.md)

## O que a biblioteca cobre

  * Montagem, validação contra o schema e assinatura da DPS (leiaute 1.01), com o `Id` calculado
  * Emissão síncrona (`Nfse.issue/2`) e por decisão administrativa ou judicial (`Nfse.issue_by_court_order/2`)
  * Consulta de NFS-e, conferência de uma DPS pelo `Id` e busca da chave de acesso
  * Cancelamento e demais eventos do contribuinte (`Nfse.cancel/3`, `Nfse.register_event/2`, `Nfse.fetch_event/4`)
  * Distribuição de documentos pelo ADN, com cursor de NSU, `stream_distribution/3` e leitura dos eventos de uma nota
  * Parâmetros municipais do ADN: convênio, alíquotas, regimes especiais, retenções e benefícios
  * Leitura estrita de NFS-e e eventos nos leiautes 1.00 e 1.01
  * Reenvio seguro: uma escrita só é repetida quando o pedido nunca saiu da máquina; o resto volta com o `dps_id` para conferir (veja [Conferir após timeout](guides/conferir-apos-timeout.md))

## O que fica de fora

  * As APIs de cada município. Esta biblioteca fala só com o sistema nacional.
  * A geração do DANFSe (o PDF da nota). Para isso existe a biblioteca [`nfse_danfse`](https://github.com/ideia4it/nfse_danfse).
  * As operações de alteração dos parâmetros municipais (`POST .../{idManut}`), que pertencem ao município.

## O que ainda não está confirmado

Estes pontos dependem da execução contra a produção restrita, descrita na próxima seção, e estão também nas seções "O que não está confirmado" de cada módulo:

  * O caminho da Sefin na produção restrita: `/API/SefinNacional`, como no portal gov.br, ou `/SefinNacional`.
  * A assinatura da DPS em RSA-SHA1 ou RSA-SHA256.
  * Se o ME/EPP do Simples Nacional informa `pAliq`.
  * A série da DPS com `^` ou `$`, que o padrão do XSD permite ao pé da letra.
  * Emoji no `xNome`. O XSD não tem o padrão Latin-1 nesse campo e a biblioteca o segue; se a Sefin recusa, a recusa chega como `:rejected`.
  * Campos de texto só com espaços em branco.
  * O formato da resposta de `GET /nfse/{chave}/eventos/{tipo}/{sequência}` (`Nfse.fetch_event/4`), documentado com o mesmo campo `eventoXmlGZipB64` do registro, e o de `GET /contribuintes/NFSe/{chave}/Eventos` (`Nfse.events/2`).
  * O fluxo de decisão judicial, que só se prova com um município que cadastre a decisão e autorize o contribuinte. Dentro dele, o `nDFSe` `"0"` que o manual exige e o padrão do XSD recusa (`[1-9]{1}[0-9]{0,12}`): a biblioteca segue o manual.
  * As chaves `beneficio` e `regimesEspeciais` dos parâmetros municipais, que o swagger não mostra.

## Rodando contra a produção restrita

A suíte `test/restricted/journey_test.exs` conversa com a produção restrita da Sefin e do ADN, onde os documentos não têm validade jurídica, usando um certificado ICP-Brasil A1 de verdade. Ela fica fora do `mix test` e precisa de três variáveis de ambiente:

| Variável | Conteúdo |
|---|---|
| `NFSE_PFX_PATH` | caminho do arquivo `.pfx` do emitente |
| `NFSE_PFX_PASSWORD` | senha do `.pfx` |
| `NFSE_C_LOC_EMI` | código IBGE de sete dígitos do município do emitente |

```bash
NFSE_PFX_PATH=/caminho/certificado.pfx NFSE_PFX_PASSWORD=... NFSE_C_LOC_EMI=2927408 mix test --only restricted
```

O CNPJ do emitente sai do certificado. Sem as variáveis, a suíte falha e diz quais faltam. Cada execução emite e cancela uma nota de teste; o tomador é fictício.
