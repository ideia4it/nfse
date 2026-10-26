defmodule Nfse.SefinTest do
  use ExUnit.Case, async: true

  import Nfse.DpsFixtures

  alias Nfse.{Codec, Document, DPS, Error, Issued, SefinStub}

  @dps_id "DPS292740821122233300018100001000000000000042"

  defp client(context), do: SefinStub.client(context.test)

  defp dps, do: struct!(DPS, studio_ana_dps())

  test "issues a DPS and returns the key, the parsed NFS-e and the raw XML", context do
    xml = SefinStub.fixture_xml("1.01")
    key = SefinStub.access_key()

    Req.Test.stub(context.test, fn conn ->
      assert conn.method == "POST"
      assert conn.request_path =~ "/nfse"
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      %{"dpsXmlGZipB64" => packed} = Jason.decode!(body)

      assert {:ok, ~s(<?xml version="1.0" encoding="UTF-8"?><DPS xmlns=) <> _} =
               Codec.unpack(packed)

      conn
      |> Plug.Conn.put_status(201)
      |> Req.Test.json(%{
        "tipoAmbiente" => 2,
        "versaoAplicativo" => "SefinNac_Pre_1.0.0",
        "dataHoraProcessamento" => "2026-11-03T10:00:05-03:00",
        "idDps" => @dps_id,
        "chaveAcesso" => key,
        "nfseXmlGZipB64" => Codec.pack(xml),
        "alertas" => [%{"codigo" => "A0001", "descricao" => "Aviso", "complemento" => nil}]
      })
    end)

    assert {:ok, %Issued{} = issued} = Nfse.issue(client(context), dps())
    assert issued.access_key == key
    assert issued.dps_id == @dps_id
    assert %Nfse.Schema.V1_01.TCNFSe{} = issued.nfse
    assert issued.xml == xml
    assert issued.alerts == [%{code: "A0001", description: "Aviso", complement: nil}]
    assert issued.processed_at == ~U[2026-11-03 13:00:05Z]
  end

  test "reads a PascalCase success answer and an unparseable processing time", context do
    xml = SefinStub.fixture_xml("1.01")

    Req.Test.stub(context.test, fn conn ->
      conn
      |> Plug.Conn.put_status(201)
      |> Req.Test.json(%{
        "IdDps" => @dps_id,
        "ChaveAcesso" => SefinStub.access_key(),
        "NfseXmlGZipB64" => Codec.pack(xml),
        "DataHoraProcessamento" => "2026-11-03T10:00:05",
        "Alertas" => [%{"Codigo" => "A0002", "Descricao" => "Outro aviso"}]
      })
    end)

    assert {:ok, %Issued{processed_at: nil, alerts: [%{code: "A0002"}]}} =
             Nfse.issue(client(context), dps())
  end

  test "returns the Sefin rejection codes with the dps_id", context do
    Req.Test.stub(context.test, fn conn ->
      conn
      |> Plug.Conn.put_status(400)
      |> Req.Test.json(%{"erros" => [%{"Codigo" => "E0063", "Descricao" => "Recusada"}]})
    end)

    assert {:error, %Error{kind: :rejected, messages: [%{code: "E0063"}], dps_id: @dps_id}} =
             Nfse.issue(client(context), dps())
  end

  test "sends a timed-out issue only once and hands back the dps_id", context do
    {count, calls} = SefinStub.count_calls()

    Req.Test.stub(context.test, fn conn ->
      count.()
      Req.Test.transport_error(conn, :timeout)
    end)

    assert {:error, %Error{kind: :timeout, dps_id: @dps_id}} = Nfse.issue(client(context), dps())
    assert calls.() == 1
  end

  test "sends a 503 issue only once", context do
    {count, calls} = SefinStub.count_calls()

    Req.Test.stub(context.test, fn conn ->
      count.()
      conn |> Plug.Conn.put_status(503) |> Req.Test.json(%{})
    end)

    assert {:error, %Error{kind: :server, dps_id: @dps_id}} = Nfse.issue(client(context), dps())
    assert calls.() == 1
  end

  test "hands back an uncertain error with the dps_id when the issued answer is not JSON",
       context do
    Req.Test.stub(context.test, fn conn ->
      conn
      |> Plug.Conn.put_resp_content_type("application/json")
      |> Plug.Conn.send_resp(201, ~s({"chaveAcesso": "2222))
    end)

    assert {:error, %Error{kind: :unexpected, status: 201, dps_id: @dps_id} = error} =
             Nfse.issue(client(context), dps())

    assert %{access_key: nil, xml: nil, reason: %Error{details: {:invalid_json, _reason}}} =
             error.details

    assert Exception.message(error) =~ "Confira a DPS #{@dps_id} antes de reenviar."
  end

  test "keeps the access key and the status when the issued XML cannot be unpacked", context do
    key = SefinStub.access_key()

    Req.Test.stub(context.test, fn conn ->
      conn
      |> Plug.Conn.put_status(201)
      |> Req.Test.json(%{"chaveAcesso" => key, "nfseXmlGZipB64" => "não é base64"})
    end)

    assert {:error, %Error{kind: :unexpected, status: 201, dps_id: @dps_id} = error} =
             Nfse.issue(client(context), dps())

    assert %{access_key: ^key, xml: nil, reason: %Error{details: :invalid_envelope}} =
             error.details

    assert Exception.message(error) =~ "Confira a DPS #{@dps_id} antes de reenviar."
  end

  test "keeps the XML and the status when the issued answer has no access key", context do
    xml = SefinStub.fixture_xml("1.01")

    Req.Test.stub(context.test, fn conn ->
      conn |> Plug.Conn.put_status(201) |> Req.Test.json(%{"nfseXmlGZipB64" => Codec.pack(xml)})
    end)

    assert {:error, %Error{kind: :unexpected, status: 201, dps_id: @dps_id, details: details}} =
             Nfse.issue(client(context), dps())

    assert %{access_key: nil, xml: ^xml, reason: %Error{details: {:missing_field, "chaveAcesso"}}} =
             details
  end

  test "hands back the key and the XML of an issued invoice that breaks the schema", context do
    key = SefinStub.access_key()

    xml =
      "1.01"
      |> SefinStub.fixture_xml()
      |> String.replace("<nDFSe>42</nDFSe>", "<nDFSe>0</nDFSe>")

    Req.Test.stub(context.test, fn conn ->
      conn
      |> Plug.Conn.put_status(201)
      |> Req.Test.json(%{"chaveAcesso" => key, "nfseXmlGZipB64" => Codec.pack(xml)})
    end)

    assert {:error, %Error{kind: :unexpected, status: 201, dps_id: @dps_id, details: details}} =
             Nfse.issue(client(context), dps())

    assert %{access_key: ^key, xml: ^xml, reason: %Error{kind: :validation} = reason} = details
    assert reason.details == [%{path: "inf_nfse.n_dfse", error: :pattern}]
  end

  test "tells whether a DPS became an invoice", context do
    Req.Test.stub(context.test, fn conn ->
      assert conn.method == "HEAD"
      status = if String.ends_with?(conn.request_path, @dps_id), do: 200, else: 404
      Plug.Conn.send_resp(conn, status, "")
    end)

    assert {:ok, true} = Nfse.dps_issued?(client(context), @dps_id)
    assert {:ok, false} = Nfse.dps_issued?(client(context), "DPS000")
  end

  test "reports a failed DPS conference as an error", context do
    Req.Test.stub(context.test, fn conn -> Plug.Conn.send_resp(conn, 403, "") end)

    assert {:error, %Error{kind: :forbidden}} = Nfse.dps_issued?(client(context), @dps_id)
  end

  test "recovers the access key of an issued DPS", context do
    key = SefinStub.access_key()

    Req.Test.stub(context.test, fn conn ->
      if String.ends_with?(conn.request_path, @dps_id) do
        Req.Test.json(conn, %{"chaveAcesso" => key})
      else
        conn |> Plug.Conn.put_status(404) |> Req.Test.json(%{})
      end
    end)

    assert {:ok, ^key} = Nfse.fetch_access_key(client(context), @dps_id)
    assert {:error, %Error{kind: :not_found}} = Nfse.fetch_access_key(client(context), "DPS000")
  end

  test "fetches an invoice by key and reads version 1.00 too", context do
    xml = SefinStub.fixture_xml("1.00")
    key = SefinStub.access_key()

    Req.Test.stub(context.test, fn conn ->
      assert String.ends_with?(conn.request_path, "/nfse/" <> key)
      Req.Test.json(conn, %{"chaveAcesso" => key, "nfseXmlGZipB64" => Codec.pack(xml)})
    end)

    assert {:ok, %Document{access_key: ^key, xml: ^xml, nfse: %Nfse.Schema.V1_00.TCNFSe{}}} =
             Nfse.fetch(client(context), key)
  end

  test "hands back the XML of a fetched invoice that breaks the schema", context do
    key = SefinStub.access_key()

    xml =
      "1.01"
      |> SefinStub.fixture_xml()
      |> String.replace("<nDFSe>42</nDFSe>", "<nDFSe>0</nDFSe>")

    Req.Test.stub(context.test, fn conn ->
      Req.Test.json(conn, %{"chaveAcesso" => key, "nfseXmlGZipB64" => Codec.pack(xml)})
    end)

    assert {:error, %Error{kind: :unexpected, status: 200, details: details}} =
             Nfse.fetch(client(context), key)

    assert %{access_key: ^key, xml: ^xml, reason: %Error{kind: :validation}} = details
  end

  test "refuses an NFS-e of an unsupported version or broken XML" do
    assert {:error, %Error{kind: :unexpected, details: {:unsupported_version, "9.99"}}} =
             Nfse.Sefin.decode_nfse(~s(<NFSe xmlns="x" versao="9.99"/>))

    assert {:error, %Error{kind: :unexpected}} = Nfse.Sefin.decode_nfse("<NFSe")
  end

  test "never touches the network when the DPS is invalid", context do
    Req.Test.stub(context.test, fn _conn -> flunk("the network must not be touched") end)

    invalid = struct!(DPS, put_in(studio_ana_dps(), [:toma], %{cpf: "52998224725"}))

    assert {:error, %Error{kind: :validation, dps_id: nil}} =
             Nfse.issue(client(context), invalid)
  end
end
