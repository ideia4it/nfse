defmodule Nfse.SignatureTest do
  use ExUnit.Case, async: true

  import Nfse.DpsFixtures

  alias Nfse.Certificate
  alias Nfse.Schema.V1_01.{TCDPS, TCInfDPS}
  alias Nfse.Signature
  alias Nfse.Xmllint

  @moduletag :tmp_dir

  @nfse "http://www.sped.fazenda.gov.br/nfse"
  @dsig "http://www.w3.org/2000/09/xmldsig#"
  @dps_id "DPS292740821122233300018100001000000000000042"

  setup_all do
    pfx = File.read!(Path.expand("../fixtures/certificates/modern.pfx", __DIR__))
    {:ok, certificate} = Certificate.from_pfx(pfx, "senha-de-teste")
    %{certificate: certificate}
  end

  test "signs infDPS with the inherited namespace in the digest and openssl verifies it", %{
    certificate: certificate,
    tmp_dir: tmp_dir
  } do
    inf_dps = studio_ana_inf_dps_with_escaped_text()
    element = encode_inf_dps(inf_dps)

    signature = Signature.sign(element, @dps_id, certificate, Signature.default_algorithm())

    {:ok, dps} = TCDPS.new(%{versao: "1.01", inf_dps: inf_dps, signature: signature})
    xml = dps |> TCDPS.encode("DPS", [{"xmlns", @nfse}]) |> IO.iodata_to_binary()

    # A Signature vai logo depois do infDPS, como irmã dentro da DPS, e o infDPS chega à Sefin com
    # os mesmos bytes que entraram no digest.
    assert xml == ~s(<DPS xmlns="#{@nfse}" versao="1.01">#{element}#{signature}</DPS>)
    Xmllint.validate!(xml, "test/support/xsd_patched/DPS_v1.01.xsd")

    # O infDPS herda o namespace da DPS sem declará-lo, e a C14N inclusiva o escreve no topo da
    # subárvore que digere. O digest dos bytes literais seria outro.
    canonical_inf_dps = element |> with_nfse_namespace() |> Xmllint.canonicalize!()
    assert digest_value(signature) == Base.encode64(:crypto.hash(:sha, canonical_inf_dps))
    refute digest_value(signature) == Base.encode64(:crypto.hash(:sha, element))

    assert signature =~
             ~s(<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></CanonicalizationMethod>)

    assert signature =~
             ~s(<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></SignatureMethod>)

    assert signature =~ ~s(<Reference URI="##{@dps_id}">)

    assert signature =~
             ~s(<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></Transform>)

    assert signature =~
             ~s(<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod>)

    assert Base.decode64!(read(signature, "X509Certificate")) == certificate.certificate

    assert {"Verified OK\n", 0} = verify_with_openssl(signature, "-sha1", certificate, tmp_dir)
  end

  test "uses SHA-256 in every algorithm URI when asked", %{
    certificate: certificate,
    tmp_dir: tmp_dir
  } do
    element = encode_inf_dps(studio_ana_inf_dps_with_escaped_text())

    signature = Signature.sign(element, @dps_id, certificate, :rsa_sha256)

    assert signature =~
             ~s(<SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"></SignatureMethod>)

    assert signature =~
             ~s(<DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"></DigestMethod>)

    refute signature =~ ~r/#(rsa-)?sha1"/

    canonical_inf_dps = element |> with_nfse_namespace() |> Xmllint.canonicalize!()
    assert digest_value(signature) == Base.encode64(:crypto.hash(:sha256, canonical_inf_dps))

    assert {"Verified OK\n", 0} = verify_with_openssl(signature, "-sha256", certificate, tmp_dir)
  end

  test "refuses an element that is not canonical", %{certificate: certificate} do
    # Cada um destes daria uma assinatura sobre bytes que a Sefin não canonicaliza, e a resposta
    # seria só "assinatura inválida", dias depois.
    for {element, id, message} <- [
          {~s(<infDPS Id="DPS1">\n  <tpAmb>2</tpAmb>\n</infDPS>), "DPS1", ~r/espaço entre tags/},
          {~s(<infDPS Id="DPS1"><tpAmb/></infDPS>), "DPS1", ~r/abreviad/},
          {~s(<infDPS xmlns="#{@nfse}" Id="DPS1"><tpAmb>2</tpAmb></infDPS>), "DPS1",
           ~r/elemento a assinar declara um namespace/},
          {~s(<infDPS xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" Id="DPS1"></infDPS>),
           "DPS1", ~r/elemento a assinar declara um namespace/},
          {~s(<infNFSe Id="NFS1"><DPS xmlns="#{@nfse}" versao="1.01"></DPS></infNFSe>), "NFS1",
           ~r/descendente/},
          {~s(<?xml version="1.0" encoding="UTF-8"?><infDPS Id="DPS1"></infDPS>), "DPS1",
           ~r/tag de abertura/}
        ] do
      assert_raise ArgumentError, message, fn ->
        Signature.sign(element, id, certificate, :rsa_sha1)
      end
    end

    # Texto só de espaço numa folha é valor que o escritor do leiaute produz, não indentação.
    leaf_with_whitespace = ~s(<infDPS Id="DPS1"><xDescServ> </xDescServ></infDPS>)

    assert Signature.sign(leaf_with_whitespace, "DPS1", certificate, :rsa_sha1) =~
             "<SignatureValue>"
  end

  test "refuses an element whose Id does not match", %{certificate: certificate} do
    assert_raise ArgumentError, ~r/Id="DPS2"/, fn ->
      Signature.sign(
        ~s(<infDPS Id="DPS1"><tpAmb>2</tpAmb></infDPS>),
        "DPS2",
        certificate,
        :rsa_sha1
      )
    end

    # A Reference aponta para o atributo `Id`, com I maiúsculo, que é o que o leiaute declara.
    assert_raise ArgumentError, ~r/Id="DPS1"/, fn ->
      Signature.sign(
        ~s(<infDPS id="DPS1"><tpAmb>2</tpAmb></infDPS>),
        "DPS1",
        certificate,
        :rsa_sha1
      )
    end
  end

  # O "&" escapado e os acentos põem o escaping do escritor dentro do que é digerido.
  defp studio_ana_inf_dps_with_escaped_text do
    {:ok, inf_dps} =
      studio_ana_inf_dps()
      |> put_in([:serv, :c_serv, :x_desc_serv], "Corte & escova d'água")
      |> TCInfDPS.new()

    inf_dps
  end

  defp encode_inf_dps(inf_dps), do: inf_dps |> TCInfDPS.encode("infDPS") |> IO.iodata_to_binary()

  defp with_nfse_namespace(element),
    do: String.replace(element, "<infDPS ", ~s(<infDPS xmlns="#{@nfse}" ), global: false)

  defp digest_value(signature), do: read(signature, "DigestValue")

  defp read(signature, tag) do
    [_, value] = Regex.run(~r{<#{tag}>(.*)</#{tag}>}Us, signature)
    value
  end

  # O SignedInfo herda o namespace da Signature, e é a forma canônica com ele que o RSA assina. A
  # chave pública sai do certificado pelo próprio openssl, para a conferência não passar pelo
  # código da biblioteca.
  defp verify_with_openssl(signature, digest_option, certificate, tmp_dir) do
    certificate_path = Path.join(tmp_dir, "certificate.der")
    public_key_path = Path.join(tmp_dir, "public_key.pem")
    signed_info_path = Path.join(tmp_dir, "signed_info.xml")
    signature_value_path = Path.join(tmp_dir, "signature_value.bin")

    File.write!(certificate_path, certificate.certificate)

    File.write!(
      signed_info_path,
      Xmllint.canonicalize!(
        ~s(<SignedInfo xmlns="#{@dsig}">#{read(signature, "SignedInfo")}</SignedInfo>)
      )
    )

    File.write!(signature_value_path, Base.decode64!(read(signature, "SignatureValue")))

    {_output, 0} =
      System.cmd("openssl", [
        "x509",
        "-inform",
        "DER",
        "-in",
        certificate_path,
        "-pubkey",
        "-noout",
        "-out",
        public_key_path
      ])

    System.cmd(
      "openssl",
      [
        "dgst",
        digest_option,
        "-verify",
        public_key_path,
        "-signature",
        signature_value_path,
        signed_info_path
      ],
      stderr_to_stdout: true
    )
  end
end
