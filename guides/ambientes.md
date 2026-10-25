# Ambientes

Todo o estado da biblioteca vive no `%Nfse.Client{}`: certificado, ambiente, tempo de espera e opções do Req. Não há processo, `Application` nem configuração global, então vários emitentes convivem no mesmo node com um cliente cada.

```elixir
{:ok, client} =
  Nfse.Client.new(
    certificate: certificate,
    environment: :restricted
  )
```

## Produção restrita e produção

| `environment` | Sefin | ADN | Valor de `tpAmb` |
|---|---|---|---|
| `:restricted` | `https://sefin.producaorestrita.nfse.gov.br/API/SefinNacional` | `https://adn.producaorestrita.nfse.gov.br` | `2` |
| `:production` | `https://sefin.nfse.gov.br/SefinNacional` | `https://adn.nfse.gov.br` | `1` |

A produção restrita é o ambiente de testes da Receita. Os documentos emitidos ali não têm validade jurídica. Comece por ela e só troque para `:production` com o fluxo completo (emitir, conferir, cancelar, importar) funcionando.

O ambiente do cliente decide o `tpAmb` da DPS. Você pode omitir `tp_amb`; se informar um valor diferente do ambiente do cliente, `Nfse.DPS.build/2` devolve o erro `:environment` antes de assinar, para que um documento de produção nunca vá para a produção restrita, nem o contrário.

```elixir
Nfse.Client.tp_amb(client)
#=> "2"
```

O caminho da Sefin na produção restrita (`/API/SefinNacional`, como no portal gov.br, ou `/SefinNacional`) ainda depende da execução contra o ambiente real. Veja a seção "Rodando contra a produção restrita" do README.

## Tempo de espera

`receive_timeout` vale por requisição e o padrão é `60_000` milissegundos. A emissão é síncrona: a Sefin assina, numera e devolve a nota na mesma resposta, então um prazo curto demais aumenta os casos de resultado incerto, tratados em [Conferir após timeout](conferir-apos-timeout.md).

```elixir
{:ok, client} =
  Nfse.Client.new(
    certificate: certificate,
    environment: :production,
    receive_timeout: 90_000
  )
```

## Opções do Req

`req_options` é repassado ao Req e vence os padrões da biblioteca. Serve, por exemplo, para registrar métricas ou apontar um `Req.Test` nos testes do seu sistema:

```elixir
{:ok, client} =
  Nfse.Client.new(
    certificate: certificate,
    environment: :restricted,
    req_options: [plug: {Req.Test, MeuApp.NfseStub}]
  )
```

Dois cuidados:

  * `retry:` informado ali não religa o reenvio de uma escrita. A política de `POST` da biblioteca vale sempre, porque repetir uma emissão pode duplicar a nota fiscal.
  * Um `finch: [name: MeuFinch]` substitui o pool inteiro. Quem faz isso precisa iniciar o próprio Finch com o certificado em `conn_opts: [transport_opts: [cert: ..., key: ...]]`, senão o mTLS não acontece.
