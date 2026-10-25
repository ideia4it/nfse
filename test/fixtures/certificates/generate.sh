#!/usr/bin/env bash
# Regenera os certificados descartáveis, no formato do A1, usados nos testes de Nfse.Certificate.
#
#   ./test/fixtures/certificates/generate.sh
#
# São autoassinados e existem para cobrir as codificações e os estados que se comportam
# diferente na prática:
#
#   modern.pfx          AES-256-CBC. Como é um certificado emitido hoje.
#   legacy.pfx          PBE-SHA1-RC2-40. Como ainda é a maioria dos A1 da ICP-Brasil, e o que
#                       precisa do provider legacy do openssl para abrir.
#   no_password.pfx     Senha vazia, que o openssl recebe por `pass:` e não pela variável de ambiente.
#   accent.pfx          Senha com acento, que quebra se a senha for convertida byte a byte.
#   ec.pfx              Chave de curva elíptica. Um bundle válido que a biblioteca não sabe usar
#                       para assinar, então tem que ser recusado.
#   expired.pfx         Validade inteira no passado. As datas são fixas, não relativas, para o
#                       fixture continuar vencido não importa quando for lido.
#   cpf.pfx             Certificado de pessoa física: otherName 2.16.76.1.3.1 com a data de
#                       nascimento e o CPF (DOC-ICP-04), sem CNPJ.
#   no_client_auth.pfx  extendedKeyUsage sem clientAuth, que o servidor recusa com 403 sem dizer
#                       o motivo.
#   no_key.pfx          Só o certificado, sem a chave privada.
#   key_only.pfx        Só a chave privada, sem o certificado dela.
#   unknown_cipher.pfx  Chave cifrada com um algoritmo que nenhum provider do openssl conhece,
#                       nem o legacy: o OID do AES-256-CBC trocado por um que não existe. Vai sem
#                       MAC, porque o MAC cobre o OID trocado e a falha viraria de senha.
#   outside_icp.pfx     clientAuth sem o otherName da ICP-Brasil, como o de uma autoridade de fora
#                       dela: não traz CNPJ nem CPF.
#
# expired.pfx precisa de -not_before/-not_after, que chegaram no OpenSSL 3.5. Os outros
# funcionam em qualquer OpenSSL a partir do 1.1.

set -euo pipefail

cd "$(dirname "$0")"

CNPJ="11222333000181"
CPF="52998224725"
SUBJECT="/C=BR/O=ICP-Brasil/OU=Certificado PJ A1/CN=STUDIO ANA TESTES LTDA:${CNPJ}"
PASSWORD="senha-de-teste"

write_config() {
  local common_name=$1 extended_key_usage=$2 other_name=$3
  cat >openssl.cnf <<CNF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no

[dn]
CN = ${common_name}

[ext]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = ${extended_key_usage}
subjectAltName = @san

[san]
otherName = ${other_name}
email = fiscal@studioana.test
CNF
}

write_config "STUDIO ANA TESTES LTDA:${CNPJ}" "clientAuth, emailProtection" \
  "2.16.76.1.3.3;FORMAT:UTF8,UTF8String:${CNPJ}"

openssl req -x509 -newkey rsa:2048 -nodes -days 7300 -sha256 \
  -subj "$SUBJECT" -config openssl.cnf -extensions ext \
  -keyout key.pem -out cert.pem 2>/dev/null

export_pfx() {
  local out=$1 password=$2
  shift 2
  openssl pkcs12 -export -inkey key.pem -in cert.pem \
    -name "STUDIO ANA TESTES LTDA:${CNPJ}" \
    -passout "pass:${password}" -out "$out" "$@" 2>/dev/null
}

export_pfx modern.pfx "$PASSWORD" -certpbe AES-256-CBC -keypbe AES-256-CBC -macalg sha256
export_pfx legacy.pfx "$PASSWORD" -certpbe PBE-SHA1-RC2-40 -keypbe PBE-SHA1-3DES -macalg sha1 -legacy
export_pfx no_password.pfx ""
export_pfx accent.pfx "sen#a-com-acentuação"
export_pfx no_key.pfx "$PASSWORD" -nokeys
export_pfx key_only.pfx "$PASSWORD" -nocerts

export_pfx unknown_cipher.pfx "$PASSWORD" -certpbe AES-256-CBC -keypbe AES-256-CBC -nomac
perl -0777 -pi -e 's/\x06\x09\x60\x86\x48\x01\x65\x03\x04\x01\x2a/\x06\x09\x60\x86\x48\x01\x65\x03\x04\x01\x7f/g' \
  unknown_cipher.pfx

openssl req -x509 -newkey ec -pkeyopt ec_paramgen_curve:prime256v1 -nodes -days 7300 -sha256 \
  -subj "$SUBJECT" -config openssl.cnf -extensions ext \
  -keyout key.pem -out cert.pem 2>/dev/null

export_pfx ec.pfx "$PASSWORD"

# Válido durante 2020 inteiro e só. Um A1 dura um ano, então é assim que fica um real que
# ninguém renovou.
openssl req -x509 -newkey rsa:2048 -nodes -sha256 \
  -not_before 20200101000000Z -not_after 20201231235959Z \
  -subj "$SUBJECT" -config openssl.cnf -extensions ext \
  -keyout key.pem -out cert.pem 2>/dev/null

export_pfx expired.pfx "$PASSWORD"

# Nascimento (8 dígitos) e CPF (11), seguidos do preenchimento de NIS, RG e órgão emissor.
write_config "ANA TESTE:${CPF}" "clientAuth, emailProtection" \
  "2.16.76.1.3.1;FORMAT:UTF8,UTF8String:01011990${CPF}00000000000000000000000000000"

openssl req -x509 -newkey rsa:2048 -nodes -days 7300 -sha256 \
  -subj "/C=BR/O=ICP-Brasil/OU=Certificado PF A1/CN=ANA TESTE:${CPF}" \
  -config openssl.cnf -extensions ext -keyout key.pem -out cert.pem 2>/dev/null

export_pfx cpf.pfx "$PASSWORD"

write_config "STUDIO ANA TESTES LTDA:${CNPJ}" "emailProtection" \
  "2.16.76.1.3.3;FORMAT:UTF8,UTF8String:${CNPJ}"

openssl req -x509 -newkey rsa:2048 -nodes -days 7300 -sha256 \
  -subj "$SUBJECT" -config openssl.cnf -extensions ext \
  -keyout key.pem -out cert.pem 2>/dev/null

export_pfx no_client_auth.pfx "$PASSWORD"

cat >openssl.cnf <<CNF
[req]
distinguished_name = dn
x509_extensions = ext
prompt = no

[dn]
CN = STUDIO ANA TESTES LTDA

[ext]
keyUsage = critical, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, emailProtection
subjectAltName = email:fiscal@studioana.test
CNF

openssl req -x509 -newkey rsa:2048 -nodes -days 7300 -sha256 \
  -subj "/C=BR/O=Studio Ana/CN=STUDIO ANA TESTES LTDA" -config openssl.cnf -extensions ext \
  -keyout key.pem -out cert.pem 2>/dev/null

export_pfx outside_icp.pfx "$PASSWORD"

rm -f key.pem cert.pem openssl.cnf

printf '%s\n' "Gerados:"
for f in modern.pfx legacy.pfx no_password.pfx accent.pfx ec.pfx expired.pfx cpf.pfx \
  no_client_auth.pfx no_key.pfx key_only.pfx unknown_cipher.pfx outside_icp.pfx; do
  printf '  %-20s %6s bytes\n' "$f" "$(wc -c <"$f" | tr -d ' ')"
done
