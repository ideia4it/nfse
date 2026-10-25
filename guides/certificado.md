# Certificado digital

A NFS-e Nacional autentica quem chama por mTLS, com o certificado A1 da ICP-Brasil do emitente, e a mesma chave assina a DPS. A biblioteca lê o arquivo `.pfx` em memória e guarda o resultado em `%Nfse.Certificate{}`.

## Abrindo o `.pfx`

```elixir
bundle = File.read!("certificado.pfx")

{:ok, certificate} = Nfse.Certificate.from_pfx(bundle, System.fetch_env!("NFSE_PFX_PASSWORD"))

certificate.cnpj
#=> "11222333000181"
certificate.not_after
#=> ~U[2027-03-01 12:00:00Z]
certificate.client_auth
#=> true
```

O CNPJ (ou o CPF, no certificado de pessoa física) sai do certificado. A senha vem do ambiente ou de um cofre de segredos, nunca do código.

`Nfse.Certificate.from_pfx/3` chama o `openssl pkcs12` do sistema, porque o OTP não lê PKCS#12. O arquivo e a senha seguem para o processo filho pelo `stdin` e por variável de ambiente, nunca por arquivo temporário nem por argumento de linha de comando.

## Erros

Todo erro é um `%Nfse.Error{kind: :certificate}` e o motivo fica em `details`:

| `details` | Quando |
|---|---|
| `:invalid_password` | a senha não abre o arquivo |
| `:invalid_file` | o arquivo não é um PKCS#12 completo, ou falta a chave ou o certificado |
| `:legacy_provider_missing` | o arquivo usa cifra antiga e o `openssl` do servidor não tem o provider legacy |
| `:timeout` | o `openssl` não respondeu a tempo |
| `:unsupported_key` | a chave não é RSA |
| `:expired` | o certificado venceu (devolvido por `Nfse.Client.new/1`) |
| `:missing_client_auth` | o certificado não serve para autenticar o cliente (devolvido por `Nfse.Client.new/1`) |

```elixir
case Nfse.Certificate.from_pfx(bundle, password) do
  {:ok, certificate} -> certificate
  {:error, %Nfse.Error{kind: :certificate, details: :invalid_password}} -> :senha_errada
  {:error, %Nfse.Error{kind: :certificate, details: :legacy_provider_missing}} -> :instalar_provider
  {:error, %Nfse.Error{kind: :certificate, details: other}} -> {:certificado_invalido, other}
end
```

## Servidor sem o provider legacy

A maioria dos A1 ainda é exportada com a cifra `PBE-SHA1-RC2-40`, que o OpenSSL 3 trouxe para o provider legacy. Instale o pacote que o contém (`openssl-provider-legacy`). Sem ele, o certificado real falha com `:legacy_provider_missing` enquanto um arquivo de teste moderno continua abrindo, o que engana quem só testa no próprio computador.

Se o seu certificado já vem em cifra moderna, nada disso é preciso. Quem tem as peças em DER pode usar `Nfse.Certificate.from_der/3` e dispensar o `openssl`.

## Validade

`Nfse.Client.new/1` recusa, antes de qualquer chamada de rede, o certificado vencido e o que não traz a extensão `clientAuth`. A Sefin responde 403 sem explicação a esse segundo caso, e por isso a verificação acontece cedo. `Nfse.Certificate.expired?/2` ajuda a avisar o cliente da renovação antes do vencimento:

```elixir
Nfse.Certificate.expired?(certificate, DateTime.add(DateTime.utc_now(), 30, :day))
#=> false
```
