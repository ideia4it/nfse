defmodule Nfse.AdnTest do
  use ExUnit.Case, async: true

  alias Nfse.{Codec, DistributedDocument, Distribution, Error, SefinStub}
  alias Nfse.Schema.V1_00.TCNFSe
  alias Nfse.Schema.V1_01.TCEvento

  @key SefinStub.access_key()

  defp client(context), do: SefinStub.client(context.test)

  defp invoice_item(nsu) do
    %{
      "NSU" => nsu,
      "ChaveAcesso" => @key,
      "TipoDocumento" => "NFSE",
      "ArquivoXml" => Codec.pack(SefinStub.fixture_xml("1.00")),
      "DataHoraGeracao" => "2026-01-23T10:00:00-03:00"
    }
  end

  defp cancellation_item(nsu) do
    %{
      "NSU" => nsu,
      "ChaveAcesso" => @key,
      "TipoDocumento" => "EVENTO",
      "TipoEvento" => "CANCELAMENTO",
      "ArquivoXml" => Codec.pack(SefinStub.event_xml(@key))
    }
  end

  defp located(items),
    do: %{"StatusProcessamento" => "DOCUMENTOS_LOCALIZADOS", "LoteDFe" => items}

  defp end_of_queue,
    do: %{"StatusProcessamento" => "NENHUM_DOCUMENTO_LOCALIZADO", "LoteDFe" => []}

  defp requested_nsu(conn), do: conn.request_path |> String.split("/") |> List.last()

  test "reads a batch of invoices and events with their parsed documents", context do
    Req.Test.stub(context.test, fn conn ->
      assert conn.method == "GET"
      assert conn.request_path =~ "/contribuintes/DFe/0"
      Req.Test.json(conn, located([invoice_item(1), cancellation_item(2)]))
    end)

    assert {:ok, %Distribution{status: :documents, next_nsu: 2, alerts: [], documents: documents}} =
             Nfse.distribution(client(context), 0)

    assert [
             %DistributedDocument{
               nsu: 1,
               type: :nfse,
               document: %TCNFSe{},
               event_type: nil,
               error: nil,
               generated_at: ~U[2026-01-23 13:00:00Z]
             },
             %DistributedDocument{
               nsu: 2,
               type: :evento,
               event_type: "CANCELAMENTO",
               document: %TCEvento{},
               generated_at: nil
             }
           ] = documents
  end

  test "keeps the local time of a generation date that carries no offset", context do
    Req.Test.stub(context.test, fn conn ->
      item = Map.put(invoice_item(1), "DataHoraGeracao", "2026-01-23T10:00:00")
      Req.Test.json(conn, located([item]))
    end)

    assert {:ok, %Distribution{documents: [%{generated_at: ~N[2026-01-23 10:00:00]}]}} =
             Nfse.distribution(client(context), 0)
  end

  test "reads camelCase keys and carries the alerts", context do
    Req.Test.stub(context.test, fn conn ->
      Req.Test.json(conn, %{
        "statusProcessamento" => "DOCUMENTOS_LOCALIZADOS",
        "alertas" => [%{"Codigo" => "A1", "Descricao" => "Atenção"}],
        "loteDFe" => [
          %{
            "nsu" => 7,
            "chaveAcesso" => @key,
            "tipoDocumento" => "NFSE",
            "arquivoXml" => Codec.pack(SefinStub.fixture_xml("1.01"))
          }
        ]
      })
    end)

    assert {:ok, %Distribution{next_nsu: 7, alerts: [%{code: "A1"}], documents: [document]}} =
             Nfse.distribution(client(context), 0)

    assert %DistributedDocument{nsu: 7, access_key: @key, type: :nfse} = document
  end

  test "treats the end of the queue as success even when it comes as 404", context do
    Req.Test.stub(context.test, fn conn ->
      conn |> Plug.Conn.put_status(404) |> Req.Test.json(end_of_queue())
    end)

    assert {:ok, %Distribution{status: :no_documents, documents: [], next_nsu: 53}} =
             Nfse.distribution(client(context), 53)
  end

  test "reports a 404 that is not the end of the queue as not found", context do
    Req.Test.stub(context.test, fn conn ->
      conn
      |> Plug.Conn.put_status(404)
      |> Req.Test.json(%{"Erros" => [%{"Codigo" => "E404", "Descricao" => "Não existe"}]})
    end)

    assert {:error, %Error{kind: :not_found, status: 404, messages: [%{code: "E404"}]}} =
             Nfse.distribution(client(context), 0)
  end

  test "reports a rejected query with the messages of the ADN", context do
    Req.Test.stub(context.test, fn conn ->
      Req.Test.json(conn, %{
        "StatusProcessamento" => "REJEICAO",
        "Erros" => [%{"Codigo" => "E1", "Descricao" => "CNPJ sem acesso"}]
      })
    end)

    assert {:error, %Error{kind: :rejected, messages: [%{code: "E1"}]}} =
             Nfse.distribution(client(context), 0)
  end

  test "asks for another CNPJ of the same root", context do
    Req.Test.stub(context.test, fn conn ->
      assert conn.query_params["cnpjConsulta"] == "11222333000262"
      assert conn.query_params["lote"] == "true"
      Req.Test.json(conn, end_of_queue())
    end)

    assert {:ok, %Distribution{status: :no_documents}} =
             Nfse.distribution(client(context), 0, cnpj_consulta: "11222333000262")
  end

  test "omits cnpjConsulta when the caller does not ask for another CNPJ", context do
    Req.Test.stub(context.test, fn conn ->
      refute Map.has_key?(conn.query_params, "cnpjConsulta")
      Req.Test.json(conn, end_of_queue())
    end)

    assert {:ok, %Distribution{}} = Nfse.distribution(client(context), 0)
  end

  test "keeps a document it cannot parse with its raw XML", context do
    xml = "<cnc>conteúdo</cnc>"

    Req.Test.stub(context.test, fn conn ->
      item = %{
        "NSU" => 3,
        "ChaveAcesso" => @key,
        "TipoDocumento" => "CNC",
        "ArquivoXml" => Codec.pack(xml)
      }

      Req.Test.json(conn, located([item]))
    end)

    assert {:ok, %Distribution{documents: [document]}} = Nfse.distribution(client(context), 2)

    assert %DistributedDocument{type: :cnc, xml: ^xml, document: nil, error: nil} = document
  end

  test "keeps progressing when one document of the batch is unreadable", context do
    unknown_version = ~s(<NFSe xmlns="http://www.sped.fazenda.gov.br/nfse" versao="9.99"/>)

    Req.Test.stub(context.test, fn conn ->
      Req.Test.json(
        conn,
        located([
          Map.put(invoice_item(1), "ArquivoXml", "isto não é base64 nem gzip"),
          Map.put(invoice_item(2), "ArquivoXml", Codec.pack(unknown_version)),
          Map.put(invoice_item(3), "ArquivoXml", Codec.pack("<NFSe")),
          invoice_item(4),
          %{"NSU" => 5, "ChaveAcesso" => @key, "TipoDocumento" => "OUTRO", "ArquivoXml" => nil}
        ])
      )
    end)

    assert {:ok, %Distribution{next_nsu: 5, documents: documents}} =
             Nfse.distribution(client(context), 0)

    assert [bad_base64, bad_version, bad_xml, good, odd] = documents
    assert %{document: nil, xml: nil, error: %Error{kind: :unexpected}} = bad_base64
    assert %{document: nil, xml: ^unknown_version, error: %Error{}} = bad_version
    assert %{document: nil, xml: "<NFSe", error: %Error{kind: :unexpected}} = bad_xml
    assert %{document: %TCNFSe{}, error: nil} = good
    assert %{type: :unknown, document: nil, error: nil, xml: nil} = odd
  end

  test "walks every batch until the end", context do
    {count, calls} = SefinStub.count_calls()

    Req.Test.stub(context.test, fn conn ->
      count.()

      case requested_nsu(conn) do
        "0" -> Req.Test.json(conn, located(Enum.map(1..50, &invoice_item/1)))
        "50" -> Req.Test.json(conn, located(Enum.map(51..53, &invoice_item/1)))
        "53" -> conn |> Plug.Conn.put_status(404) |> Req.Test.json(end_of_queue())
      end
    end)

    documents = context |> client() |> Nfse.stream_distribution(0) |> Enum.to_list()

    assert Enum.map(documents, & &1.nsu) == Enum.to_list(1..53)
    assert calls.() == 3
  end

  test "asks for the next batch only when the consumer needs it", context do
    {count, calls} = SefinStub.count_calls()

    Req.Test.stub(context.test, fn conn ->
      count.()
      Req.Test.json(conn, located(Enum.map(1..50, &invoice_item/1)))
    end)

    assert [%{nsu: 1}, %{nsu: 2}] =
             context |> client() |> Nfse.stream_distribution(0) |> Enum.take(2)

    assert calls.() == 1
  end

  test "refuses a batch that does not move past the requested NSU", context do
    {count, calls} = SefinStub.count_calls()

    Req.Test.stub(context.test, fn conn ->
      count.()
      Req.Test.json(conn, located([invoice_item(5)]))
    end)

    assert {:error, %Error{kind: :unexpected, details: {:stalled_nsu, 5}}} =
             Nfse.distribution(client(context), 5)

    assert_raise Error, fn ->
      context |> client() |> Nfse.stream_distribution(5) |> Enum.to_list()
    end

    assert calls.() == 2
  end

  test "keeps an item whose NSU is not an integer and leaves it out of the cursor", context do
    Req.Test.stub(context.test, fn conn ->
      Req.Test.json(conn, located([invoice_item(1), invoice_item("12"), invoice_item(nil)]))
    end)

    assert {:ok, %Distribution{next_nsu: 1, documents: [good, text_nsu, missing_nsu]}} =
             Nfse.distribution(client(context), 0)

    assert %{nsu: 1, document: %TCNFSe{}, error: nil} = good
    xml = SefinStub.fixture_xml("1.00")

    assert %{nsu: "12", xml: ^xml, document: nil, error: %Error{details: {:invalid_nsu, "12"}}} =
             text_nsu

    assert %{nsu: nil, document: nil, error: %Error{details: {:invalid_nsu, nil}}} = missing_nsu
  end

  test "raises when a batch fails in the middle of the stream", context do
    Req.Test.stub(context.test, fn conn ->
      case requested_nsu(conn) do
        "0" -> Req.Test.json(conn, located([invoice_item(1)]))
        _later -> Plug.Conn.send_resp(conn, 400, "")
      end
    end)

    assert_raise Error, fn ->
      context |> client() |> Nfse.stream_distribution(0) |> Enum.to_list()
    end
  end

  test "lists the events of an invoice", context do
    Req.Test.stub(context.test, fn conn ->
      assert conn.request_path =~ "/contribuintes/NFSe/#{@key}/Eventos"
      Req.Test.json(conn, located([cancellation_item(9)]))
    end)

    assert {:ok, [%DistributedDocument{type: :evento, document: %TCEvento{}}]} =
             Nfse.events(client(context), @key)
  end

  test "lists no events when the invoice has none", context do
    Req.Test.stub(context.test, fn conn ->
      conn |> Plug.Conn.put_status(404) |> Req.Test.json(end_of_queue())
    end)

    assert {:ok, []} = Nfse.events(client(context), @key)
  end
end
