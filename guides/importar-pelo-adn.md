# Importar notas pelo ADN

O ADN entrega a quem tem um CNPJ todo documento fiscal em que ele aparece (notas emitidas, notas recebidas e eventos como o cancelamento) numa fila numerada por NSU, em lotes de até 50. É o caminho para importar para o seu sistema as notas emitidas fora dele, e para saber dos cancelamentos feitos no portal.

## O cursor de NSU é seu

A biblioteca não guarda estado. `Nfse.distribution/3` lê os documentos **depois** do NSU pedido e devolve o `next_nsu`, que é o ponto de partida da próxima chamada. Guarde o último `next_nsu` no seu banco, junto do CNPJ, e continue dele.

```elixir
defmodule MeuApp.ImportacaoAdn do
  def import_batch(client, cursor) do
    case Nfse.distribution(client, cursor) do
      {:ok, %Nfse.Distribution{status: :documents} = batch} ->
        Enum.each(batch.documents, &store/1)
        {:more, batch.next_nsu}

      {:ok, %Nfse.Distribution{status: :no_documents}} ->
        {:done, cursor}

      {:error, %Nfse.Error{} = error} ->
        {:error, error, cursor}
    end
  end

  def import_all(client, cursor) do
    case import_batch(client, cursor) do
      {:more, next_cursor} ->
        save_cursor(next_cursor)
        import_all(client, next_cursor)

      other ->
        other
    end
  end

  defp store(%Nfse.DistributedDocument{error: nil} = document) do
    {document.nsu, document.type, document.access_key, document.xml}
  end

  defp store(%Nfse.DistributedDocument{error: %Nfse.Error{}} = document) do
    {document.nsu, :unreadable, document.access_key, document.xml}
  end

  defp save_cursor(_nsu), do: :ok
end
```

Grave o cursor só depois de gravar o lote. Se o processo cair no meio, o lote é lido de novo e a gravação precisa ser idempotente: use o NSU ou a chave de acesso como chave única.

## O fim da fila

Quando não há mais nada depois do NSU, o ADN responde `NENHUM_DOCUMENTO_LOCALIZADO`, às vezes com status 404. A biblioteca devolve isso como sucesso, `{:ok, %Nfse.Distribution{status: :no_documents, documents: []}}`, e nunca como erro. Agende a próxima rodada para mais tarde, a partir do mesmo cursor.

## Percorrendo com `stream_distribution/3`

Se preferir consumir documento a documento, `Nfse.stream_distribution/3` percorre os lotes e termina sozinho no fim da fila:

```elixir
client
|> Nfse.stream_distribution(cursor)
|> Stream.filter(&(&1.type == :nfse))
|> Enum.each(&MeuApp.Notas.import/1)
```

Ao contrário das outras funções, o stream **levanta** `Nfse.Error` quando um lote falha. Proteja o laço com `try`/`rescue` se o processo não puder cair e, depois de uma falha, retome pelo último cursor que você gravou. Como o stream entrega documentos e não lotes, o cursor a guardar é o maior `nsu` já tratado:

```elixir
last_nsu =
  client
  |> Nfse.stream_distribution(cursor)
  |> Enum.reduce(cursor, fn document, _last_nsu ->
    MeuApp.Notas.import(document)
    document.nsu
  end)
```

## O que vem em cada documento

`%Nfse.DistributedDocument{}` traz:

| Campo | Conteúdo |
|---|---|
| `nsu` | posição na fila |
| `access_key` | chave de acesso da nota |
| `type` | `:nfse`, `:evento`, `:dps`, `:pedido_registro_evento`, `:cnc`, `:nenhum` ou `:unknown` |
| `event_type` | como `"CANCELAMENTO"`; `nil` nas notas |
| `xml` | o documento como o ADN o entregou |
| `document` | o mesmo documento lido, só para `:nfse` e `:evento` |
| `error` | a falha de leitura, quando houve |
| `generated_at` | `DateTime`, ou `NaiveDateTime` quando o ADN não informa o fuso |

## Documento ilegível não derruba o lote

Um documento que não se consegue ler (base64 ou gzip inválido, versão desconhecida, XML malformado) volta com `document: nil`, o motivo em `error` e o `xml` bruto quando houve algum. O lote continua e o NSU avança, então uma nota estranha não trava a importação. Guarde o `xml` bruto e o `nsu` para investigar depois:

```elixir
for %Nfse.DistributedDocument{error: %Nfse.Error{} = error} = document <- batch.documents do
  MeuApp.Pendencias.registrar(document.nsu, document.access_key, document.xml, error)
end
```

## Consultar os eventos de uma nota

```elixir
{:ok, documents} = Nfse.events(client, access_key)
```

Outro CNPJ da mesma raiz do certificado se consulta com a opção `:cnpj_consulta`:

```elixir
Nfse.distribution(client, cursor, cnpj_consulta: "11222333000262")
```

O formato da resposta de `events/2` ainda não foi visto de verdade: veja o README.
