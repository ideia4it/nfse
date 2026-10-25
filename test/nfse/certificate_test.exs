defmodule Nfse.CertificateTest do
  # Síncrono porque dois testes trocam variáveis de ambiente da VM inteira: o PATH, para tirar o
  # openssl do alcance, e o OPENSSL_MODULES, para tirar o provider legacy.
  #
  # A tag :openssl3 marca o que depende dos providers do OpenSSL 3 em diante: o provider legacy
  # ausente e a cifra que nenhum provider abre (o LibreSSL recusa o bundle sem MAC como senha
  # errada antes de chegar à cifra). O test_helper.exs a exclui com LibreSSL ou OpenSSL 1.1.
  use ExUnit.Case, async: false

  alias Nfse.Certificate
  alias Nfse.Error

  require Record

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

  @fixtures Path.expand("../fixtures/certificates", __DIR__)
  @password "senha-de-teste"

  defp fixture(name), do: File.read!(Path.join(@fixtures, name))

  defp put_env_until_exit(name, value) do
    previous = System.get_env(name)

    on_exit(fn ->
      if previous, do: System.put_env(name, previous), else: System.delete_env(name)
    end)

    System.put_env(name, value)
  end

  # Autoassinado por fora da ICP-Brasil: sem extendedKeyUsage e sem subjectAltName.
  defp self_signed(opts \\ []) do
    %{cert: der, key: key} =
      :public_key.pkix_test_root_cert(~c"Studio Ana", [{:key, {:rsa, 2048, 65_537}} | opts])

    {der, key}
  end

  defp der_key(key), do: {:RSAPrivateKey, :public_key.der_encode(:RSAPrivateKey, key)}

  test "opens a legacy RC2 bundle and reads the CNPJ from the ICP-Brasil otherName" do
    assert {:ok, certificate} = Certificate.from_pfx(fixture("legacy.pfx"), @password)

    assert %Certificate{cnpj: "11222333000181", cpf: nil, client_auth: true, chain: []} =
             certificate

    assert is_binary(certificate.certificate)
    assert {:RSAPrivateKey, key_der} = certificate.key
    assert is_binary(key_der)
    assert DateTime.compare(certificate.not_before, certificate.not_after) == :lt
    refute Certificate.expired?(certificate, DateTime.utc_now())
  end

  test "opens modern, empty-password and accented-password bundles" do
    assert {:ok, %{cnpj: "11222333000181"}} =
             Certificate.from_pfx(fixture("modern.pfx"), @password)

    assert {:ok, %{cnpj: "11222333000181"}} = Certificate.from_pfx(fixture("no_password.pfx"), "")

    assert {:ok, %{cnpj: "11222333000181"}} =
             Certificate.from_pfx(fixture("accent.pfx"), "sen#a-com-acentuação")
  end

  test "reads the CPF of a person certificate" do
    assert {:ok, %{cpf: "52998224725", cnpj: nil}} =
             Certificate.from_pfx(fixture("cpf.pfx"), @password)
  end

  test "refuses a wrong password without leaking it" do
    wrong_password = "errada-9731"

    assert {:error, %Error{kind: :certificate, details: :invalid_password} = error} =
             Certificate.from_pfx(fixture("legacy.pfx"), wrong_password)

    refute inspect(error) =~ wrong_password
    refute Exception.message(error) =~ wrong_password
  end

  test "tells a missing openssl apart from an unreadable file" do
    put_env_until_exit("PATH", Path.join(System.tmp_dir!(), "nfse-without-openssl"))

    assert {:error, %Error{kind: :certificate, details: :openssl_missing}} =
             Certificate.from_pfx(fixture("modern.pfx"), @password)
  end

  test "refuses a truncated bundle at once" do
    truncated = binary_part(fixture("legacy.pfx"), 0, 100)

    assert {:error, %Error{kind: :certificate, details: :invalid_file}} =
             Certificate.from_pfx(truncated, @password)
  end

  test "refuses an elliptic curve key" do
    assert {:error, %Error{kind: :certificate, details: :unsupported_key} = error} =
             Certificate.from_pfx(fixture("ec.pfx"), @password)

    refute inspect(error) =~ "PrivateKey"
  end

  test "tells an expired certificate apart" do
    assert {:ok, certificate} = Certificate.from_pfx(fixture("expired.pfx"), @password)

    assert Certificate.expired?(certificate, ~U[2026-10-25 00:00:00Z])
    refute Certificate.expired?(certificate, ~U[2020-06-01 00:00:00Z])
  end

  test "reports a certificate without clientAuth and rebuilds from DER pieces" do
    assert {:ok, %{client_auth: false} = opened} =
             Certificate.from_pfx(fixture("no_client_auth.pfx"), @password)

    assert {:ok, ^opened} = Certificate.from_der(opened.certificate, opened.key, opened.chain)

    assert {:error, %Error{kind: :certificate, details: :invalid_file}} =
             Certificate.from_der("not a certificate", opened.key, [])
  end

  @tag :openssl3
  test "tells a missing legacy provider apart from an unreadable file" do
    # Um diretório de módulos sem o provider legacy é o host sem o pacote openssl-provider-legacy.
    put_env_until_exit("OPENSSL_MODULES", Path.join(System.tmp_dir!(), "nfse-without-legacy"))

    assert {:error, %Error{kind: :certificate, details: :legacy_provider_missing}} =
             Certificate.from_pfx(fixture("legacy.pfx"), @password)
  end

  @tag :openssl3
  test "refuses a bundle whose cipher not even the legacy provider opens" do
    assert {:error, %Error{kind: :certificate, details: :invalid_file}} =
             Certificate.from_pfx(fixture("unknown_cipher.pfx"), @password)
  end

  test "gives up on an openssl that does not answer in time" do
    # Um milissegundo é menos do que o openssl leva só para subir.
    assert {:error, %Error{kind: :certificate, details: :timeout}} =
             Certificate.from_pfx(fixture("modern.pfx"), @password, timeout: 1)
  end

  test "refuses the certificate alone, in PEM or DER, uploaded in place of the .pfx" do
    {:ok, %Certificate{certificate: der}} = Certificate.from_pfx(fixture("modern.pfx"), @password)
    pem = :public_key.pem_encode([{:Certificate, der, :not_encrypted}])

    for upload <- [pem, der] do
      assert {:error, %Error{kind: :certificate, details: :invalid_file}} =
               Certificate.from_pfx(upload, @password)
    end
  end

  test "refuses a bundle without the private key or without the certificate of the key" do
    for name <- ["no_key.pfx", "key_only.pfx"] do
      assert {:error, %Error{kind: :certificate, details: :invalid_file}} =
               Certificate.from_pfx(fixture(name), @password)
    end
  end

  test "builds from DER pieces a certificate issued outside ICP-Brasil" do
    {der, key} = self_signed()

    assert {:ok, %Certificate{cnpj: nil, cpf: nil, client_auth: false}} =
             Certificate.from_der(der, der_key(key), [])
  end

  test "reads a validity that starts before 2000 and ends after 2049" do
    {der, key} = self_signed(validity: {{1999, 12, 31}, {2050, 1, 1}})

    assert {:ok, certificate} = Certificate.from_der(der, der_key(key), [])
    assert DateTime.to_date(certificate.not_before) == ~D[1999-12-31]
    assert DateTime.to_date(certificate.not_after) == ~D[2050-01-01]
  end

  test "refuses a certificate whose validity is not written the way RFC 5280 asks" do
    {der, key} = self_signed()
    tbs = der |> :public_key.pkix_decode_cert(:otp) |> otp_certificate(:tbsCertificate)
    without_seconds = {:Validity, {:utcTime, ~c"2601010000Z"}, {:utcTime, ~c"2701010000Z"}}

    malformed =
      tbs |> otp_tbs_certificate(validity: without_seconds) |> :public_key.pkix_sign(key)

    assert {:error, %Error{kind: :certificate, details: :invalid_file}} =
             Certificate.from_der(malformed, der_key(key), [])
  end
end
