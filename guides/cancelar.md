# Cancelar e registrar eventos

Cancelamento e manifestações são eventos da NFS-e, registrados em `POST /nfse/{chave}/eventos` com um pedido assinado pelo certificado do cliente.

## Cancelar

`Nfse.cancel/3` registra o evento `101101`:

```elixir
case Nfse.cancel(client, access_key,
       c_motivo: 1,
       x_motivo: "Nota emitida com o valor do serviço errado"
     ) do
  {:ok, %Nfse.Event{} = event} ->
    event.xml

  {:error, %Nfse.Error{kind: :rejected, messages: messages}} ->
    messages
end
```

Opções:

| Opção | Conteúdo |
|---|---|
| `:c_motivo` | `1` erro na emissão, `2` serviço não prestado, `9` outros. Obrigatória |
| `:x_motivo` | explicação de 15 a 255 caracteres. Obrigatória |
| `:ver_aplic` | versão do seu aplicativo. Por padrão, `"nfse-"` seguido da versão da biblioteca |

O autor do evento é o dono do certificado do cliente. `event.xml` é o evento como a Sefin o devolveu, e `event.evento` é o mesmo documento lido.

A Sefin recusa o cancelamento fora das regras do município (prazo e situação da nota, por exemplo) com `:rejected` e o código `E....` em `messages`.

## Conferir um evento

Como na emissão, o registro de um evento sai uma única vez. Num `:timeout` ou `:server` o resultado é incerto, e a conferência é `Nfse.fetch_event/4`, com o tipo do evento (seis dígitos) e o número de sequência:

```elixir
case Nfse.fetch_event(client, access_key, "101101", 1) do
  {:ok, %Nfse.Event{} = event} -> {:cancelada, event.xml}
  {:error, %Nfse.Error{kind: :not_found}} -> :nao_registrado
  {:error, %Nfse.Error{}} = error -> error
end
```

Chave, tipo e sequência malformados voltam como `%Nfse.Error{kind: :validation}` nos caminhos `access_key`, `tipo_evento` e `n_seq_evento`, sem rede. O formato da resposta de `fetch_event/4` ainda não foi visto de verdade: veja "O que ainda não está confirmado" no README.

Para listar todos os eventos de uma nota pelo ADN, use `Nfse.events/2`:

```elixir
{:ok, documents} = Nfse.events(client, access_key)
Enum.map(documents, & &1.event_type)
#=> ["CANCELAMENTO"]
```

## Outros eventos

`Nfse.register_event/2` aceita qualquer evento que o contribuinte pode registrar. Exatamente um campo `e<código>` vai preenchido, e é ele que define o tipo. A tabela completa está em `Nfse.PedidoEvento`.

| Código | Campo | Evento |
|---|---|---|
| `101101` | `e101101` | Cancelamento de NFS-e |
| `101103` | `e101103` | Solicitação de análise fiscal para cancelamento |
| `202201` | `e202201` | Confirmação do prestador |
| `203202` | `e203202` | Confirmação do tomador |
| `204203` | `e204203` | Confirmação do intermediário |
| `202205` | `e202205` | Rejeição do prestador |
| `203206` | `e203206` | Rejeição do tomador |
| `204207` | `e204207` | Rejeição do intermediário |
| `205208` | `e205208` | Anulação da rejeição |

Uma manifestação do tomador, assinada com o certificado dele, fica assim:

```elixir
Nfse.register_event(tomador_client, %{
  ch_nfse: access_key,
  ver_aplic: "studio-ana-1.0",
  e203202: %{x_desc: "Manifestação de NFS-e - Confirmação do Tomador"}
})
```

O `cnpj_autor` (ou `cpf_autor`) e o `dh_evento` saem do certificado do cliente e da hora atual quando você não os informa.
