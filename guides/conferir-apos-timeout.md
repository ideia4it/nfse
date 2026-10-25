# Conferir após timeout

A Sefin emite a nota dentro da própria requisição. Se a resposta não chega (timeout, conexão fechada, 5xx), você não sabe se a nota existe. Reenviar a DPS às cegas pode duplicar a nota fiscal, e por isso a biblioteca não faz isso.

## O que a biblioteca repete sozinha

Uma escrita (`Nfse.issue/2`, `Nfse.issue_by_court_order/2`, `Nfse.register_event/2`, `Nfse.cancel/3`) só é repetida quando o pedido nunca saiu da máquina:

  * `:nxdomain`, `:econnrefused`, `:ehostunreach` e `:enetunreach`
  * as recusas do pool HTTP/2 que acontecem antes de transmitir (`:unprocessed` e `:pool_not_available`)

Timeout, conexão fechada e qualquer resposta HTTP, 5xx inclusive, nunca são repetidos. Voltam como `%Nfse.Error{kind: :timeout | :transport | :server}`, com o `dps_id` da DPS que ficou incerta.

As leituras (`fetch/2`, `dps_issued?/2`, `fetch_access_key/2`, `distribution/3` e as consultas de parâmetros) repetem as falhas transitórias (408, 429, 500, 502, 503, 504, timeout, conexão recusada ou fechada) e o `:nxdomain`.

## O laço de conferência

Depois de um erro incerto, pergunte à Sefin se ela conhece a DPS antes de qualquer reenvio. Dê alguns segundos entre as perguntas: a Sefin pode ainda estar processando a requisição que você deu por perdida.

```elixir
defmodule MeuApp.Emissao do
  @uncertain [:timeout, :transport, :server]

  def issue_confirming(client, dps) do
    case Nfse.issue(client, dps) do
      {:error, %Nfse.Error{kind: kind, dps_id: dps_id}} when kind in @uncertain ->
        confirm(client, dps_id)

      other ->
        other
    end
  end

  defp confirm(client, dps_id, attempts_left \\ 5, wait_ms \\ 3_000) do
    case Nfse.dps_issued?(client, dps_id) do
      {:ok, true} ->
        with {:ok, access_key} <- Nfse.fetch_access_key(client, dps_id),
             {:ok, document} <- Nfse.fetch(client, access_key) do
          {:ok, {:recovered, document}}
        end

      {:ok, false} when attempts_left > 1 ->
        Process.sleep(wait_ms)
        confirm(client, dps_id, attempts_left - 1, wait_ms)

      {:ok, false} ->
        {:ok, {:not_issued, dps_id}}

      {:error, %Nfse.Error{}} = error ->
        error
    end
  end
end
```

Os resultados:

| Retorno | Significado |
|---|---|
| `{:ok, %Nfse.Issued{}}` | emitida na primeira tentativa |
| `{:ok, {:recovered, %Nfse.Document{}}}` | a resposta se perdeu, mas a nota existe; guarde `document.access_key` e `document.xml` |
| `{:ok, {:not_issued, dps_id}}` | a Sefin não conhece a DPS depois das tentativas |
| `{:error, %Nfse.Error{}}` | recusa de negócio ou falha da própria conferência |

Em `{:not_issued, dps_id}` reenvie a mesma DPS, com o mesmo `n_dps`, para que o `Id` seja o mesmo e a Sefin possa reconhecer uma duplicata. Gerar um `n_dps` novo para repetir a emissão é o que cria duas notas.

## Quando a conferência também falha

Se `dps_issued?/2` volta com `{:error, _}`, o resultado continua incerto. Guarde o `dps_id` num registro de pendências e confira de novo mais tarde, por um job seu. Um evento (`register_event/2` ou `cancel/3`) se confere com `Nfse.fetch_event/4`, pelo tipo e pela sequência, antes de qualquer reenvio.

## Separe o que é incerto do que é recusa

Um `:rejected` (400) é uma resposta completa da Sefin: a nota não foi emitida e a mensagem diz por quê. Só `:timeout`, `:transport` e `:server` pedem conferência, e é por isso que `Nfse.Error` só mostra "Confira a DPS ... antes de reenviar." nesses três.
