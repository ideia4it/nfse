defmodule Nfse.EventsTest do
  use ExUnit.Case, async: true

  alias Nfse.{Codec, Error, Event, PedidoEvento, SefinStub}
  alias Nfse.Schema.V1_01.TCEvento

  @key SefinStub.access_key()
  @reason "Emitida com valor errado"

  defp client(context), do: SefinStub.client(context.test)

  defp stub_event_answer(context) do
    Req.Test.stub(context.test, fn conn ->
      conn
      |> Plug.Conn.put_status(201)
      |> Req.Test.json(%{"eventoXmlGZipB64" => Codec.pack(SefinStub.event_xml(@key))})
    end)
  end

  test "cancels an invoice and reads the generated event", context do
    Req.Test.stub(context.test, fn conn ->
      assert conn.method == "POST"
      assert conn.request_path =~ "/nfse/#{@key}/eventos"
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      %{"pedidoRegistroEventoXmlGZipB64" => packed} = Jason.decode!(body)
      assert {:ok, "<pedRegEvento xmlns=" <> _ = request} = Codec.unpack(packed)
      assert request =~ "<xDesc>Cancelamento de NFS-e</xDesc>"
      assert request =~ "<cMotivo>1</cMotivo>"
      assert request =~ "<verAplic>nfse-"

      conn
      |> Plug.Conn.put_status(201)
      |> Req.Test.json(%{"eventoXmlGZipB64" => Codec.pack(SefinStub.event_xml(@key))})
    end)

    assert {:ok, %Event{access_key: @key, evento: %TCEvento{} = evento, xml: xml}} =
             Nfse.cancel(client(context), @key, c_motivo: 1, x_motivo: @reason)

    assert evento.inf_evento.n_seq_evento == "1"
    assert xml == SefinStub.event_xml(@key)
  end

  test "lets the caller name the application version of a cancellation", context do
    Req.Test.stub(context.test, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      %{"pedidoRegistroEventoXmlGZipB64" => packed} = Jason.decode!(body)
      assert {:ok, request} = Codec.unpack(packed)
      assert request =~ "<verAplic>studio-ana-2</verAplic>"

      conn
      |> Plug.Conn.put_status(201)
      |> Req.Test.json(%{"EventoXmlGZipB64" => Codec.pack(SefinStub.event_xml(@key))})
    end)

    assert {:ok, %Event{}} =
             Nfse.cancel(client(context), @key,
               c_motivo: 9,
               x_motivo: @reason,
               ver_aplic: "studio-ana-2"
             )
  end

  test "registers an event and reads the generated evento", context do
    stub_event_answer(context)

    pedido = %PedidoEvento{
      ch_nfse: @key,
      ver_aplic: "nfse-0.1.0",
      e101101: %{x_desc: "Cancelamento de NFS-e", c_motivo: 2, x_motivo: @reason}
    }

    assert {:ok, %Event{evento: %TCEvento{}}} = Nfse.register_event(client(context), pedido)
  end

  test "refuses a short reason before any request", context do
    Req.Test.stub(context.test, fn _conn -> flunk("nothing may reach the network") end)

    assert {:error, %Error{kind: :validation, details: [%{path: "e101101.x_motivo"}]}} =
             Nfse.cancel(client(context), @key, c_motivo: 1, x_motivo: "erro")
  end

  test "reads the single erro object of an event rejection", context do
    Req.Test.stub(context.test, fn conn ->
      conn |> Plug.Conn.put_status(400) |> Req.Test.json(%{"erro" => %{"codigo" => "E1235"}})
    end)

    assert {:error, %Error{kind: :rejected, messages: [%{code: "E1235"}]}} =
             Nfse.cancel(client(context), @key, c_motivo: 1, x_motivo: @reason)
  end

  test "registers an event only once on timeout", context do
    {count, calls} = SefinStub.count_calls()

    Req.Test.stub(context.test, fn conn ->
      count.()
      Req.Test.transport_error(conn, :timeout)
    end)

    assert {:error, %Error{kind: :timeout}} =
             Nfse.cancel(client(context), @key, c_motivo: 1, x_motivo: @reason)

    assert calls.() == 1
  end

  test "fetches one event by type and sequence", context do
    Req.Test.stub(context.test, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path =~ "/nfse/#{@key}/eventos/101101/1"

      Req.Test.json(conn, %{"eventoXmlGZipB64" => Codec.pack(SefinStub.event_xml(@key))})
    end)

    assert {:ok, %Event{access_key: @key, evento: %TCEvento{}}} =
             Nfse.fetch_event(client(context), @key, "101101", 1)
  end

  test "refuses a malformed key, event type or sequence before the network", context do
    Req.Test.stub(context.test, fn _conn -> flunk("the network must not be touched") end)

    assert {:error, %Error{kind: :validation, details: details}} =
             Nfse.fetch_event(client(context), "123", "1011", 0)

    assert details == [
             %{path: "access_key", error: :pattern},
             %{path: "tipo_evento", error: :pattern},
             %{path: "n_seq_evento", error: :type}
           ]

    assert {:error, %Error{kind: :validation, details: [%{path: "n_seq_evento", error: :type}]}} =
             Nfse.fetch_event(client(context), @key, "101101", "1")
  end

  test "fails when the success answer carries no event", context do
    Req.Test.stub(context.test, fn conn ->
      conn |> Plug.Conn.put_status(201) |> Req.Test.json(%{})
    end)

    assert {:error, %Error{kind: :unexpected}} =
             Nfse.cancel(client(context), @key, c_motivo: 1, x_motivo: @reason)
  end
end
