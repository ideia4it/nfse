defmodule Nfse.CertificateTest do
  use ExUnit.Case, async: true

  alias Nfse.Certificate
  alias Nfse.Error

  @fixtures Path.expand("../fixtures/certificates", __DIR__)
  @password "senha-de-teste"

  defp fixture(name), do: File.read!(Path.join(@fixtures, name))

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
end
