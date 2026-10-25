defmodule Nfse.Certificate do
  @moduledoc """
  Certificado A1 (um `.pfx` PKCS#12) aberto nas peças em DER que `:ssl` e `:public_key` pedem,
  mais o que a biblioteca precisa saber dele: CNPJ ou CPF, validade e `clientAuth`.

  O OTP não tem leitor de PKCS#12 (`:public_key` não exporta um, e `PFX` é um tipo indefinido em
  `OTP-PUB-KEY` e `PKCS-FRAME`), então `from_pfx/3` chama `openssl pkcs12`. Duas regras tornam
  isso seguro, e nenhuma é opcional:

    * o bundle entra pelo stdin do processo filho, nunca por arquivo temporário, porque o
      arquivo guardaria a chave privada sem cifra;
    * a senha entra por variável de ambiente do filho, nunca por `argv`, porque o `argv` é
      legível por qualquer usuário no `ps`.

  A maior parte dos A1 da ICP-Brasil ainda é exportada com `PBE-SHA1-RC2-40`, que o OpenSSL 3
  moveu para o provider legacy. A primeira tentativa vai sem `-legacy` e só então repete com ele:
  um export moderno custa uma chamada e um antigo custa duas. O motivo da ordem é que o openssl
  se recusa a rodar quando não consegue carregar um provider pedido na linha de comando, então
  começar por `-legacy` perderia os bundles modernos em todo host sem o pacote.

  Em produção esse provider vem no pacote `openssl-provider-legacy`. Sem ele, todo certificado
  real falha ao abrir enquanto os fixtures no Mac do desenvolvedor continuam funcionando, por
  isso `:legacy_provider_missing` é um erro próprio e não `:invalid_file`. Um subprocesso que
  nunca responde recebe o mesmo tratamento e volta como `:timeout`, e um host sem o executável
  `openssl` no `PATH` volta como `:openssl_missing`: nenhum dos três é problema do arquivo, e
  mandar exportar o certificado de novo levaria a pessoa atrás da coisa errada.

  Os erros são `%Nfse.Error{kind: :certificate}` e `details` é um destes:

  | `details` | Quando |
  |---|---|
  | `:invalid_password` | a senha não abre o bundle |
  | `:invalid_file` | o arquivo não é um PKCS#12 completo, ou falta chave ou folha |
  | `:legacy_provider_missing` | o bundle usa cifra legada e o openssl não tem o provider |
  | `:openssl_missing` | o executável `openssl` não está no `PATH` |
  | `:timeout` | o openssl não respondeu dentro do prazo |
  | `:unsupported_key` | a chave não é RSA, e a assinatura da DPS exige RSA |
  """

  alias Nfse.Error

  require Record

  Record.defrecordp(
    :rsa_private_key,
    :RSAPrivateKey,
    Record.extract(:RSAPrivateKey, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecordp(
    :otp_certificate,
    :OTPCertificate,
    Record.extract(:OTPCertificate, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecordp(
    :otp_tbs_certificate,
    :OTPTBSCertificate,
    Record.extract(:OTPTBSCertificate, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecordp(
    :otp_subject_public_key_info,
    :OTPSubjectPublicKeyInfo,
    Record.extract(:OTPSubjectPublicKeyInfo, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecordp(
    :validity,
    :Validity,
    Record.extract(:Validity, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  Record.defrecordp(
    :x509_extension,
    :Extension,
    Record.extract(:Extension, from_lib: "public_key/include/OTP-PUB-KEY.hrl")
  )

  # OIDs do DOC-ICP-04: 2.16.76.1.3.3 é o CNPJ da pessoa jurídica e 2.16.76.1.3.1 traz a data
  # de nascimento (8 dígitos) seguida do CPF (11) do titular pessoa física.
  @cnpj_oid {2, 16, 76, 1, 3, 3}
  @cpf_oid {2, 16, 76, 1, 3, 1}
  @subject_alt_name_oid {2, 5, 29, 17}
  @extended_key_usage_oid {2, 5, 29, 37}
  @client_auth_oid {1, 3, 6, 1, 5, 5, 7, 3, 2}

  @default_timeout :timer.seconds(15)

  @derive {Inspect, only: [:cnpj, :cpf, :not_before, :not_after, :client_auth]}
  @enforce_keys [:certificate, :key, :chain, :not_before, :not_after, :client_auth]
  defstruct [:certificate, :key, :chain, :cnpj, :cpf, :not_before, :not_after, :client_auth]

  @type t :: %__MODULE__{
          certificate: binary(),
          key: {:RSAPrivateKey, binary()},
          chain: [binary()],
          cnpj: String.t() | nil,
          cpf: String.t() | nil,
          not_before: DateTime.t(),
          not_after: DateTime.t(),
          client_auth: boolean()
        }

  @doc """
  Abre `bundle` com `password`.

  A folha é escolhida casando a chave pública de cada certificado com a chave privada: a ordem
  dentro de um `.pfx` não é especificada, e pegar o primeiro certificado devolve uma
  intermediária com frequência suficiente para importar.

  ## Opções

    * `:timeout` - prazo em milissegundos para a chamada inteira, incluindo a repetição com
      `-legacy`. Padrão: `15_000`.
  """
  @spec from_pfx(binary(), String.t(), timeout: pos_integer()) ::
          {:ok, t()} | {:error, Error.t()}
  def from_pfx(bundle, password, opts \\ []) when is_binary(bundle) and is_binary(password) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)

    with :ok <- validate_der(bundle),
         {:ok, pem} <- openssl(bundle, password, deadline(timeout)),
         {:ok, certificates, key} <- parse_pem(pem),
         {:ok, leaf, chain} <- split_leaf(certificates, key) do
      from_der(leaf, key, chain)
    else
      {:error, %Error{}} = error -> error
      {:error, details} -> certificate_error(details)
    end
  end

  @doc """
  Monta o certificado a partir de peças em DER que o chamador já tem, sem passar pelo openssl.
  """
  @spec from_der(binary(), {:RSAPrivateKey, binary()}, [binary()]) ::
          {:ok, t()} | {:error, Error.t()}
  def from_der(certificate, {:RSAPrivateKey, _der} = key, chain)
      when is_binary(certificate) and is_list(chain) do
    with {:ok, tbs} <- decode_tbs(certificate),
         validity(notBefore: not_before, notAfter: not_after) =
           otp_tbs_certificate(tbs, :validity),
         {:ok, not_before} <- to_datetime(not_before),
         {:ok, not_after} <- to_datetime(not_after) do
      cnpj = cnpj(tbs)

      {:ok,
       %__MODULE__{
         certificate: certificate,
         key: key,
         chain: chain,
         cnpj: cnpj,
         cpf: if(is_nil(cnpj), do: cpf(tbs)),
         not_before: not_before,
         not_after: not_after,
         client_auth: client_auth?(tbs)
       }}
    else
      :error -> certificate_error(:invalid_file)
    end
  end

  @doc "Diz se `now` já passou do fim da validade."
  @spec expired?(t(), DateTime.t()) :: boolean()
  def expired?(%__MODULE__{not_after: not_after}, %DateTime{} = now),
    do: DateTime.compare(now, not_after) == :gt

  defp certificate_error(details), do: {:error, %Error{kind: :certificate, details: details}}

  # Um prazo para a chamada inteira e não um por invocação do openssl: a repetição com -legacy
  # dobraria o que o chamador foi avisado para esperar.
  defp deadline(timeout), do: System.monotonic_time(:millisecond) + timeout

  defp time_left(deadline), do: max(deadline - System.monotonic_time(:millisecond), 0)

  # Um PKCS#12 é uma única SEQUENCE em DER, então o tamanho dele é conhecido de antemão.
  # Conferir aqui transforma um upload truncado em erro imediato, em vez de esperar o prazo
  # inteiro para o openssl desistir de uma sequência que nunca termina.
  defp validate_der(<<0x30, 0x80, _::binary>>), do: {:error, :invalid_file}

  defp validate_der(<<0x30, length, rest::binary>>) when length < 0x80,
    do: check_length(byte_size(rest), length)

  defp validate_der(<<0x30, header, rest::binary>>) when header > 0x80 do
    size_bytes = header - 0x80

    case rest do
      <<length::big-size(size_bytes)-unit(8), content::binary>> ->
        check_length(byte_size(content), length)

      _ ->
        {:error, :invalid_file}
    end
  end

  defp validate_der(_bundle), do: {:error, :invalid_file}

  defp check_length(size, size), do: :ok
  defp check_length(_size, _length), do: {:error, :invalid_file}

  defp openssl(bundle, password, deadline) do
    case run(bundle, password, deadline, false) do
      {:error, :unsupported_cipher} -> retry_with_legacy(bundle, password, deadline)
      result -> result
    end
  end

  # A primeira tentativa já leu o arquivo o bastante para nomear a cifra que não abriu, então
  # um arquivo ilegível aqui é sobre o próprio -legacy, num openssl que não conhece a opção.
  defp retry_with_legacy(bundle, password, deadline) do
    case run(bundle, password, deadline, true) do
      {:error, reason} when reason in [:invalid_file, :unsupported_cipher] ->
        {:error, :invalid_file}

      result ->
        result
    end
  end

  defp run(bundle, password, deadline, legacy?) do
    case System.find_executable("openssl") do
      nil -> {:error, :openssl_missing}
      executable -> run(executable, bundle, password, deadline, legacy?)
    end
  end

  defp run(executable, bundle, password, deadline, legacy?) do
    {passin, env} = password_argument(password)
    args = ["pkcs12", "-in", "/dev/stdin", "-passin", passin, "-nodes"]

    port =
      Port.open({:spawn_executable, executable}, [
        :binary,
        :exit_status,
        :stderr_to_stdout,
        :hide,
        args: if(legacy?, do: args ++ ["-legacy"], else: args),
        env: env
      ])

    # Sem EOF: o openssl para de ler quando o tamanho do cabeçalho DER é atingido, e uma porta
    # Erlang não consegue fechar só o stdin do filho.
    Port.command(port, bundle)

    collect(port, [], deadline)
  end

  # Port.open descarta uma variável de ambiente com valor em charlist vazia, então a senha
  # vazia viaja como `pass:`. Senha vazia não é segredo mesmo.
  #
  # String.to_charlist/1 e não :binary.bin_to_list/1: o Erlang recodifica o ambiente para a
  # codificação nativa, e bytes que já são UTF-8 transformam "ção" em mojibake e o openssl em
  # "Mac verify error".
  defp password_argument(""), do: {"pass:", []}

  defp password_argument(password),
    do: {"env:PFX_PASSWORD", [{~c"PFX_PASSWORD", String.to_charlist(password)}]}

  defp collect(port, acc, deadline) do
    receive do
      {^port, {:data, data}} ->
        collect(port, [data | acc], deadline)

      {^port, {:exit_status, 0}} ->
        {:ok, IO.iodata_to_binary(Enum.reverse(acc))}

      {^port, {:exit_status, _status}} ->
        {:error, classify(IO.iodata_to_binary(Enum.reverse(acc)))}
    after
      time_left(deadline) -> abandon(port)
    end
  end

  # A porta pode morrer entre o prazo estourar e esta linha, e fechar uma porta que já foi
  # embora levanta. O que ela mandou antes disso fica na caixa de mensagens do chamador, e uma
  # mensagem que ninguém casa lá pode derrubar o processo dele.
  defp abandon(port) do
    try do
      Port.close(port)
    rescue
      ArgumentError -> :ok
    end

    drain(port)

    {:error, :timeout}
  end

  defp drain(port) do
    receive do
      {^port, _message} -> drain(port)
    after
      0 -> :ok
    end
  end

  defp classify(output) do
    downcased = String.downcase(output)

    cond do
      downcased =~ "mac verify error" -> :invalid_password
      downcased =~ "invalid password" -> :invalid_password
      downcased =~ "mac verify failure" -> :invalid_password
      downcased =~ "unable to load provider" -> :legacy_provider_missing
      downcased =~ "rc2" or downcased =~ "rc4" -> :unsupported_cipher
      downcased =~ "unsupported" -> :unsupported_cipher
      true -> :invalid_file
    end
  end

  # O openssl escreve "MAC verified OK" no stderr, que stderr_to_stdout mistura com o PEM.
  # pem_decode/1 ignora o que não é bloco blindado.
  defp parse_pem(pem) do
    entries = :public_key.pem_decode(pem)
    certificates = for {:Certificate, der, :not_encrypted} <- entries, do: der

    case Enum.find_value(entries, &private_key/1) do
      nil -> {:error, :invalid_file}
      {:error, :unsupported_key} = error -> error
      key -> {:ok, certificates, key}
    end
  end

  # O OpenSSL 3 escreve a chave em PKCS#8 ("PRIVATE KEY"), os mais velhos em PKCS#1
  # ("RSA PRIVATE KEY"). Desembrulhar o PKCS#8 aqui deixa quem vem depois assumir um formato só,
  # porque :public_key.sign/3 pede o record RSAPrivateKey.
  defp private_key({:PrivateKeyInfo, _der, :not_encrypted} = entry) do
    entry
    |> :public_key.pem_entry_decode()
    |> rsa_key()
  end

  defp private_key({:RSAPrivateKey, der, :not_encrypted}), do: {:RSAPrivateKey, der}
  defp private_key(_entry), do: nil

  # Um bag PKCS#8 também carrega chave EC ou Ed25519. O bundle é válido, só não serve para
  # assinar a DPS. Recodificar como RSAPrivateKey levanta, e a mensagem da exceção escreveria
  # a chave privada decodificada no Logger e no rastreador de erros.
  defp rsa_key(rsa_private_key() = key),
    do: {:RSAPrivateKey, :public_key.der_encode(:RSAPrivateKey, key)}

  defp rsa_key(_key), do: {:error, :unsupported_key}

  defp split_leaf(certificates, {:RSAPrivateKey, der}) do
    rsa_private_key(modulus: modulus, publicExponent: public_exponent) =
      :public_key.der_decode(:RSAPrivateKey, der)

    public_key = {:RSAPublicKey, modulus, public_exponent}

    case Enum.split_with(certificates, &(public_key_of(&1) == public_key)) do
      {[leaf], chain} -> {:ok, leaf, chain}
      _ -> {:error, :invalid_file}
    end
  end

  defp public_key_of(der) do
    der
    |> tbs()
    |> otp_tbs_certificate(:subjectPublicKeyInfo)
    |> otp_subject_public_key_info(:subjectPublicKey)
  end

  defp tbs(der), do: der |> :public_key.pkix_decode_cert(:otp) |> otp_certificate(:tbsCertificate)

  defp decode_tbs(der) do
    {:ok, tbs(der)}
  rescue
    _ -> :error
  end

  # O servidor da Sefin responde 403 sem dizer o motivo para certificado sem a extensão
  # clientAuth, então vale recusar o certificado antes de ir à rede.
  defp client_auth?(tbs) do
    case find_extension(tbs, @extended_key_usage_oid) do
      nil -> false
      usages -> @client_auth_oid in usages
    end
  end

  defp cnpj(tbs), do: tbs |> other_name_digits(@cnpj_oid) |> take_cnpj()

  defp cpf(tbs), do: tbs |> other_name_digits(@cpf_oid) |> take_cpf()

  defp take_cnpj(digits) do
    case Regex.run(~r/\d{14}/, digits) do
      [cnpj] -> cnpj
      _ -> nil
    end
  end

  # Posições 9 a 19 do valor: antes vêm os 8 dígitos da data de nascimento.
  defp take_cpf(digits) do
    case Regex.run(~r/\d{19,}/, digits) do
      [run] -> binary_part(run, 8, 11)
      _ -> nil
    end
  end

  # O CNPJ não está no subject: a ICP-Brasil o põe num otherName do subjectAltName. As
  # autoridades divergem no tipo de string desse valor, então pegamos os bytes crus e deixamos
  # as regex acharem os dígitos, que ignoram o envelope DER.
  #
  # A tag do otherName não é casada porque o OTP 28 decodifica como :"INSTANCE OF" o que até o
  # OTP 27 vinha como :AnotherName.
  defp other_name_digits(tbs, oid) do
    with names when is_list(names) <- find_extension(tbs, @subject_alt_name_oid),
         {:otherName, {_tag, ^oid, value}} <-
           Enum.find(names, &match?({:otherName, {_tag, ^oid, _value}}, &1)) do
      raw_value(value)
    else
      _ -> ""
    end
  end

  defp raw_value(value) when is_binary(value), do: der_content(value)
  defp raw_value(value) when is_list(value), do: List.to_string(value)
  defp raw_value(_value), do: ""

  # Sem tirar o cabeçalho, o byte de tamanho do DER pode ser um dígito ASCII e entrar no CPF.
  defp der_content(<<_tag, length, content::binary-size(length)>>) when length < 0x80, do: content

  defp der_content(<<_tag, 0x81, length, content::binary-size(length)>>), do: content

  defp der_content(value), do: value

  defp find_extension(tbs, oid) do
    tbs
    |> otp_tbs_certificate(:extensions)
    |> List.wrap()
    |> Enum.find_value(fn
      x509_extension(extnID: ^oid, extnValue: value) -> value
      _ -> nil
    end)
  end

  # Certificados usam UTCTime (YYMMDDHHMMSSZ) até 2049 e GeneralizedTime (YYYYMMDDHHMMSSZ)
  # depois. O que nenhum dos dois formatos cobre vira erro, e não exceção dentro do upload.
  defp to_datetime({:utcTime, value}),
    do: value |> IO.chardata_to_string() |> with_century() |> parse_datetime()

  defp to_datetime({:generalTime, value}),
    do: value |> IO.chardata_to_string() |> parse_datetime()

  defp to_datetime(_value), do: :error

  # RFC 5280: ano de dois dígitos de 50 em diante é 19xx, abaixo disso 20xx.
  defp with_century(<<year::binary-2, _rest::binary>> = value) when year >= "50",
    do: "19" <> value

  defp with_century(value), do: "20" <> value

  defp parse_datetime(
         <<year::binary-4, month::binary-2, day::binary-2, hour::binary-2, minute::binary-2,
           second::binary-2, "Z">>
       ) do
    with {:ok, date} <- Date.from_iso8601("#{year}-#{month}-#{day}"),
         {:ok, time} <- Time.from_iso8601("#{hour}:#{minute}:#{second}"),
         {:ok, datetime} <- DateTime.new(date, time, "Etc/UTC") do
      {:ok, datetime}
    else
      _ -> :error
    end
  end

  defp parse_datetime(_value), do: :error
end
