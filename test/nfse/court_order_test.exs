defmodule Nfse.CourtOrderTest do
  use ExUnit.Case, async: true

  import Nfse.DpsFixtures

  alias Nfse.{Codec, DPS, Error, Identifiers, Issued, NFSe, SefinStub, Xmllint}
  alias Nfse.Schema.V1_01.TCDPS

  @nfse "http://www.sped.fazenda.gov.br/nfse"
  @dps_id "DPS292740821122233300018100001000000000000042"

  defp client(context), do: SefinStub.client(context.test)

  defp court_order_nfse do
    %{
      x_loc_emi: "Salvador",
      x_loc_prestacao: "Salvador",
      n_nfse: 1,
      c_loc_incid: "2927408",
      x_loc_incid: "Salvador",
      x_trib_nac: "Barbearia, cabeleireiros, manicuros, pedicuros e congêneres.",
      ver_aplic: "nfse-0.1.0",
      emit: %{
        cnpj: "11222333000181",
        x_nome: "Studio Ana",
        ender_nac: %{
          x_lgr: "Rua das Flores",
          nro: "100",
          x_bairro: "Centro",
          c_mun: "2927408",
          uf: "BA",
          cep: "40000000"
        }
      },
      valores: %{
        v_bc: Decimal.new("49.90"),
        p_aliq_aplic: Decimal.new("2.00"),
        v_issqn: Decimal.new("1.00"),
        v_liq: Decimal.new("49.90")
      },
      dps: %{inf_dps: put_in(studio_ana_dps(), [:serv, :c_serv, :c_trib_nac], "060101")}
    }
  end

  test "fills the court order fields the manual fixes", context do
    assert {:ok,
            %{xml: xml, id: "NFS" <> access_key = id, access_key: access_key, dps_id: @dps_id}} =
             NFSe.build(struct!(NFSe, court_order_nfse()), client(context))

    assert String.starts_with?(xml, ~s(<NFSe xmlns="#{@nfse}" versao="1.01"><infNFSe Id="#{id}">))
    assert xml =~ "<ambGer>2</ambGer><tpEmis>1</tpEmis><cStat>102</cStat>"
    assert xml =~ "<dhProc>2026-11-03T13:00:00+00:00</dhProc><nDFSe>0</nDFSe>"
    assert xml =~ "<dhEmi>2026-11-03T13:00:00+00:00</dhEmi>"
    assert xml =~ ~s(<DPS versao="1.01"><infDPS Id="#{@dps_id}"><tpAmb>2</tpAmb>)
    assert [_only_the_invoice_signature] = Regex.scan(~r/<Signature /, xml)
    assert xml =~ ~r{</infNFSe><Signature xmlns="http://www.w3.org/2000/09/xmldsig#">.*</NFSe>$}

    # O manual manda nDFSe 0, que o padrão do TSNDFSe recusa; o resto do documento segue o XSD.
    Xmllint.validate!(
      String.replace(xml, "<nDFSe>0</nDFSe>", "<nDFSe>1</nDFSe>"),
      "test/support/xsd_patched/NFSe_v1.01.xsd"
    )

    assert "2927408" <>
             "2" <> "2" <> "11222333000181" <> "0000000000001" <> "2611" <> c_num_and_dv =
             access_key

    assert c_num_and_dv =~ ~r/^\d{10}$/
    assert Identifiers.check_digit(String.slice(access_key, 0, 49)) == String.last(access_key)

    assert {:ok, %{access_key: another_key}} = NFSe.build(court_order_nfse(), client(context))
    assert another_key != access_key

    assert {:ok, %{access_key: chosen_key}} =
             NFSe.build(Map.put(court_order_nfse(), :c_num, "123456789"), client(context))

    assert chosen_key ==
             Identifiers.access_key(
               "2927408",
               "2",
               {:cnpj, "11222333000181"},
               "1",
               "2611",
               "123456789"
             )
  end

  test "sends the whole signed NFS-e and returns the issued invoice", context do
    xml = SefinStub.fixture_xml("1.01")
    key = SefinStub.access_key()

    Req.Test.stub(context.test, fn conn ->
      assert conn.method == "POST"
      assert String.ends_with?(conn.request_path, "/decisao-judicial/nfse")
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      %{"xmlGZipB64" => packed} = Jason.decode!(body)
      assert {:ok, "<NFSe xmlns=" <> _ = sent} = Codec.unpack(packed)
      assert sent =~ "<Signature"

      conn
      |> Plug.Conn.put_status(201)
      |> Req.Test.json(%{
        "dataHoraProcessamento" => "2026-11-03T10:00:05-03:00",
        "idDps" => @dps_id,
        "chaveAcesso" => key,
        "nfseXmlGZipB64" => Codec.pack(xml)
      })
    end)

    with_generated_structs =
      Map.update!(court_order_nfse(), :dps, fn %{inf_dps: inf_dps} ->
        %TCDPS{inf_dps: struct!(DPS, inf_dps)}
      end)

    assert {:ok, %Issued{} = issued} =
             Nfse.issue_by_court_order(client(context), with_generated_structs)

    assert issued.access_key == key
    assert issued.dps_id == @dps_id
    assert %Nfse.Schema.V1_01.TCNFSe{} = issued.nfse
    assert issued.xml == xml
    assert issued.processed_at == ~U[2026-11-03 13:00:05Z]
  end

  test "refuses an invalid invoice with every error at once, before the network", context do
    Req.Test.stub(context.test, fn _conn -> flunk("the network must not be touched") end)

    invalid =
      court_order_nfse()
      |> Map.delete(:x_loc_emi)
      |> Map.merge(%{c_stat: "100", c_num: "12"})
      |> put_in([:dps, :inf_dps, :toma, :cpf], "5299822472X")
      |> put_in([:dps, :inf_dps, :tp_amb], "1")
      |> put_in([:dps, :inf_dps, :id], @dps_id)

    assert {:error, %Error{kind: :validation, details: details}} =
             Nfse.issue_by_court_order(client(context), invalid)

    assert Enum.sort_by(details, & &1.path) == [
             %{path: "c_num", error: :pattern},
             %{path: "c_stat", error: :unknown_field},
             %{path: "dps.inf_dps.id", error: :unknown_field},
             %{path: "dps.inf_dps.toma.cpf", error: :pattern},
             %{path: "dps.inf_dps.tp_amb", error: :environment},
             %{path: "x_loc_emi", error: :required}
           ]

    for {c_num, error} <- [{123_456_789, :type}, {"12345678X", :pattern}] do
      assert {:error, %Error{kind: :validation, details: [%{path: "c_num", error: ^error}]}} =
               Nfse.issue_by_court_order(
                 client(context),
                 Map.put(court_order_nfse(), :c_num, c_num)
               )
    end
  end

  test "refuses an embedded DPS whose issuer has no CNPJ or CPF", context do
    without_taker =
      court_order_nfse()
      |> put_in([:dps, :inf_dps, :tp_emit], 2)
      |> update_in([:dps, :inf_dps], &Map.delete(&1, :toma))

    assert {:error,
            %Error{kind: :validation, details: [%{path: "dps.inf_dps.toma", error: :required}]}} =
             NFSe.build(without_taker, client(context))
  end
end
