defmodule Nfse.DPSTest do
  use ExUnit.Case, async: true

  import Nfse.DpsFixtures

  alias Nfse.{Certificate, Client, DPS, Error, Signature, Xmllint}

  @nfse "http://www.sped.fazenda.gov.br/nfse"
  @dsig "http://www.w3.org/2000/09/xmldsig#"

  setup_all do
    pfx = File.read!(Path.expand("../fixtures/certificates/modern.pfx", __DIR__))
    {:ok, certificate} = Certificate.from_pfx(pfx, "senha-de-teste")
    {:ok, client} = Client.new(certificate: certificate, environment: :restricted)
    %{client: client}
  end

  test "fills versao and tpAmb from the client and signs infDPS", %{client: client} do
    assert {:ok, %{xml: xml, id: id}} = DPS.build(struct!(DPS, studio_ana_dps()), client)

    assert id == "DPS292740821122233300018100001000000000000042"
    assert String.starts_with?(xml, ~s(<DPS xmlns="#{@nfse}" versao="1.01"><infDPS Id="#{id}">))
    assert xml =~ "<tpAmb>2</tpAmb>"
    assert xml =~ ~s(</infDPS><Signature xmlns="#{@dsig}">)
    Xmllint.validate!(xml, "test/support/xsd_patched/DPS_v1.01.xsd")

    # A assinatura RSA é determinística: a DPS inteira é a raiz em volta do infDPS e da assinatura
    # daqueles mesmos bytes, sem reescrita depois de assinar.
    [inf_dps] = Regex.run(~r{<infDPS .*</infDPS>}, xml)
    signature = Signature.sign(inf_dps, id, client.certificate, Signature.default_algorithm())
    assert xml == ~s(<DPS xmlns="#{@nfse}" versao="1.01">) <> inf_dps <> signature <> "</DPS>"
  end

  test "takes the issuer inscription from the actor named by tpEmit", %{client: client} do
    freelancer_prest = %{cpf: "52998224725", reg_trib: studio_ana_dps().prest.reg_trib}
    studio_ana = %{cnpj: "11222333000181", x_nome: "Studio Ana"}

    issued_by_taker =
      Map.merge(studio_ana_dps(), %{tp_emit: 2, prest: freelancer_prest, toma: studio_ana})

    assert {:ok, %{id: "DPS2927408" <> "2" <> "11222333000181" <> "00001" <> _n_dps}} =
             DPS.build(issued_by_taker, client)

    issued_by_intermediary =
      studio_ana_dps()
      |> Map.merge(%{tp_emit: 3, prest: freelancer_prest, interm: studio_ana})
      |> Map.delete(:toma)

    assert {:ok, %{id: "DPS2927408" <> "2" <> "11222333000181" <> "00001" <> _n_dps}} =
             DPS.build(issued_by_intermediary, client)
  end

  test "builds the id from the CPF of a freelancer who issues with a person certificate" do
    pfx = File.read!(Path.expand("../fixtures/certificates/cpf.pfx", __DIR__))
    {:ok, certificate} = Certificate.from_pfx(pfx, "senha-de-teste")
    {:ok, freelancer} = Client.new(certificate: certificate, environment: :restricted)

    issued_by_freelancer =
      Map.merge(studio_ana_dps(), %{
        prest: %{cpf: "52998224725", reg_trib: studio_ana_dps().prest.reg_trib},
        toma: %{cnpj: "11222333000181", x_nome: "Studio Ana"}
      })

    assert {:ok, %{id: id}} = DPS.build(issued_by_freelancer, freelancer)
    assert id == "DPS2927408" <> "1" <> "00052998224725" <> "00001" <> "000000000000042"
  end

  test "refuses an issuer without the CNPJ or CPF the id needs", %{client: client} do
    without_taker = studio_ana_dps() |> Map.put(:tp_emit, 2) |> Map.delete(:toma)

    assert {:error, %Error{kind: :validation, details: [%{path: "toma", error: :required}]}} =
             DPS.build(without_taker, client)

    for foreign_taker <- [
          %{nif: "123456789", x_nome: "Ana Souza"},
          %{c_nao_nif: 1, x_nome: "Ana Souza"}
        ] do
      issued_by_foreign_taker = Map.merge(studio_ana_dps(), %{tp_emit: 2, toma: foreign_taker})

      assert {:error, %Error{kind: :validation, details: [%{path: "toma", error: :inscription}]}} =
               DPS.build(issued_by_foreign_taker, client)
    end
  end

  test "refuses a tpAmb that contradicts the client environment", %{client: client} do
    assert {:error, %Error{kind: :validation, details: [%{path: "tp_amb", error: :environment}]}} =
             DPS.build(Map.put(studio_ana_dps(), :tp_amb, "1"), client)

    assert {:ok, %{xml: xml}} = DPS.build(Map.put(studio_ana_dps(), :tp_amb, 2), client)
    assert xml =~ "<tpAmb>2</tpAmb>"
  end

  test "returns every schema error before signing", %{client: client} do
    # Uma chave que não assina faz o build levantar se ele chegar à assinatura.
    client_that_cannot_sign = put_in(client.certificate.key, :unusable)

    attrs =
      studio_ana_dps()
      |> Map.delete(:serv)
      |> Map.put(:id, "DPS292740821122233300018100001000000000000042")
      |> put_in([:toma, :cpf], "5299822472X")

    assert {:error, %Error{kind: :validation, details: details} = error} =
             DPS.build(attrs, client_that_cannot_sign)

    assert Exception.message(error) =~ "não passou na validação"

    assert Enum.sort_by(details, & &1.path) == [
             %{path: "id", error: :unknown_field},
             %{path: "serv", error: :required},
             %{path: "toma.cpf", error: :pattern}
           ]
  end
end
