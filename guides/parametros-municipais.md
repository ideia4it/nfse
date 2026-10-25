# Parâmetros municipais

Cada município configura o sistema nacional do seu jeito: se aderiu ao convênio, que alíquota de ISS vale para cada serviço, que regimes especiais e retenções existem. O ADN publica essa configuração e `Nfse` a expõe em leituras que devolvem o objeto de dentro da resposta, com as chaves da API como vieram.

Os parâmetros ajudam a preencher a DPS sem tentativa e erro, em especial `c_trib_nac` e a alíquota.

## Convênio do município

```elixir
{:ok, agreement} = Nfse.municipal_agreement(client, "2927408")
```

O código do município é o de sete dígitos do IBGE (`2927408` é Salvador).

## Alíquota de um serviço

O código do serviço é o `c_trib_nac` completo, com nove dígitos: `01.04.01.000`. A biblioteca aceita com ou sem pontos e monta o formato que a API exige. A competência é um `Date`.

```elixir
{:ok, rate} = Nfse.rate(client, "2927408", "010401000", ~D[2026-11-01])

{:ok, history} = Nfse.rate_history(client, "2927408", "01.04.01.000")
```

## Regimes especiais, retenções e benefícios

```elixir
{:ok, regimes} = Nfse.special_regimes(client, "2927408", "01.04.01.000", ~D[2026-11-01])

{:ok, withholdings} = Nfse.withholdings(client, "2927408", ~D[2026-11-01])

{:ok, benefit} = Nfse.benefit(client, "2927408", "0000001", ~D[2026-11-01])
```

## Erros

Argumentos malformados voltam como `%Nfse.Error{kind: :validation}` antes da rede, com cada caminho (`c_mun`, `c_serv`, `competencia`, `n_beneficio`):

```elixir
{:error, %Nfse.Error{kind: :validation, details: details}} =
  Nfse.rate(client, "292740", "0104", "2026-11-01")

details
#=> [
#=>   %{path: "c_mun", error: :pattern},
#=>   %{path: "c_serv", error: :length},
#=>   %{path: "competencia", error: :type}
#=> ]
```

Quando o município não tem o dado, o ADN responde 404 com uma `mensagem`, que vira `%Nfse.Error{kind: :not_found}` com o texto em `messages`:

```elixir
case Nfse.rate(client, "2927408", "01.04.01.000", ~D[2026-11-01]) do
  {:ok, rate} -> rate
  {:error, %Nfse.Error{kind: :not_found, messages: [%{description: description}]}} -> description
end
```

Uma resposta 200 sem o objeto esperado é `:unexpected`.

## O que fica de fora

As operações de alteração (`POST .../{idManut}`) pertencem ao próprio município e não existem na biblioteca. As chaves `beneficio` e `regimesEspeciais` da resposta são suposições, já que o swagger não as mostra e nenhuma resposta com sucesso foi vista (veja `Nfse.Parametros`).
