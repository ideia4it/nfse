# Nfse

Biblioteca Elixir para a NFS-e Nacional, pública no GitHub: nada de certificado real, senha ou documento de contribuinte em código, teste, fixture ou doc. Só cliente: nenhum schema de banco, contexto, worker ou rota. Quem liga a biblioteca a uma funcionalidade é o app que a consome.

## Comandos

```bash
mix deps.get
mix precommit      # compile --warnings-as-errors + format + credo --strict + test
```

## Regras

- Toda função pública devolve `{:ok, _}` ou `{:error, %Nfse.Error{}}`, exceto `stream_distribution/2`, que levanta `Nfse.Error`
- Sem `Application`, sem processo e sem `Application.get_env`: tudo passa por `%Nfse.Client{}`
- Dependências de runtime: só `req`, `decimal` e `saxy`
- Nunca edite `lib/nfse/schema/`: rode `mix nfse.gen`
- Nunca edite `priv/xsd/`
- HTTP nos testes só por `Req.Test`, passado em `req_options: [plug: {Req.Test, stub_name}]`, nunca Mimic
- Teste é jornada, um por fluxo, com nome em inglês no estilo BDD; testes de um módulo ficam no arquivo de teste dele
- Exemplos e fixtures usam a empresa fictícia "Studio Ana" e o CNPJ de teste `11222333000181`
- `@moduledoc`, `@doc`, comentários, README e guias em pt-BR; identificadores em inglês, exceto os campos da spec, que usam o nome do XSD em snake_case (`cLocEmi` vira `c_loc_emi`). Comentário só para o porquê. Nunca use travessão. Comentário que começa com "Todo" dispara o `TagTODO` do Credo: escreva "Cada", "A tabela inteira"
- Commits no estilo conventional, em pt-BR
- Push, PR e `mix hex.publish` só por ordem explícita
