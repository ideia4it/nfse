defmodule Nfse.ClientTest do
  use ExUnit.Case, async: true

  alias Nfse.Certificate
  alias Nfse.Client
  alias Nfse.Error

  @fixtures Path.expand("../fixtures/certificates", __DIR__)
  @password "senha-de-teste"

  defp certificate(name) do
    {:ok, certificate} = Certificate.from_pfx(File.read!(Path.join(@fixtures, name)), @password)
    certificate
  end

  defp client(stub_name, opts \\ []) do
    {:ok, client} =
      Client.new(
        certificate: certificate("modern.pfx"),
        environment: Keyword.get(opts, :environment, :restricted),
        req_options: [plug: {Req.Test, stub_name}] ++ Keyword.get(opts, :req_options, [])
      )

    client
  end

  defp count_calls do
    counter = :counters.new(1, [])
    {counter, fn -> :counters.add(counter, 1, 1) end}
  end

  test "refuses an expired certificate before any request" do
    assert {:error, %Error{kind: :certificate, details: :expired}} =
             Client.new(certificate: certificate("expired.pfx"), environment: :production)
  end

  test "refuses a certificate without clientAuth before any request" do
    assert {:error, %Error{kind: :certificate, details: :missing_client_auth}} =
             Client.new(certificate: certificate("no_client_auth.pfx"), environment: :production)
  end

  test "never shows the private key or the certificate when inspected" do
    certificate = certificate("modern.pfx")
    {:ok, client} = Client.new(certificate: certificate, environment: :production)
    {:RSAPrivateKey, key_der} = certificate.key

    for subject <- [certificate, client], text = inspect(subject, limit: :infinity) do
      refute text =~ "RSAPrivateKey"
      refute text =~ inspect(key_der, limit: :infinity)
      refute text =~ inspect(certificate.certificate, limit: :infinity)
      refute text =~ Base.encode64(certificate.certificate)
    end
  end

  test "builds a client with defaults and maps the environment to tpAmb" do
    assert {:ok, %Client{receive_timeout: 60_000, req_options: []} = production} =
             Client.new(certificate: certificate("modern.pfx"), environment: :production)

    assert Client.tp_amb(production) == "1"
    assert Client.tp_amb(%{production | environment: :restricted}) == "2"
  end

  test "points each environment at its own hosts" do
    stub = :hosts
    test_pid = self()

    Req.Test.stub(stub, fn conn ->
      send(test_pid, {:called, conn.host, conn.request_path})
      Req.Test.json(conn, %{})
    end)

    assert {:ok, %{status: 200}} =
             Client.request(client(stub, environment: :restricted), :sefin, :get, "/nfse/1")

    assert_received {:called, "sefin.producaorestrita.nfse.gov.br", "/API/SefinNacional/nfse/1"}

    assert {:ok, _} = Client.request(client(stub, environment: :production), :sefin, :get, "/x")
    assert_received {:called, "sefin.nfse.gov.br", "/SefinNacional/x"}

    assert {:ok, _} = Client.request(client(stub, environment: :production), :adn, :get, "/x")
    assert_received {:called, "adn.nfse.gov.br", "/x"}

    assert {:ok, _} = Client.request(client(stub, environment: :restricted), :adn, :get, "/x")
    assert_received {:called, "adn.producaorestrita.nfse.gov.br", "/x"}
  end

  test "sends json and params to the service" do
    stub = :json_and_params
    test_pid = self()

    Req.Test.stub(stub, fn conn ->
      {:ok, body, conn} = Plug.Conn.read_body(conn)
      send(test_pid, {:called, conn.method, conn.query_string, Jason.decode!(body)})
      conn |> Plug.Conn.put_status(201) |> Req.Test.json(%{})
    end)

    assert {:ok, %{status: 201}} =
             Client.request(client(stub), :sefin, :post, "/nfse",
               json: %{"dpsXmlGZipB64" => "abc"},
               params: [lote: 1]
             )

    assert_received {:called, "POST", "lote=1", %{"dpsXmlGZipB64" => "abc"}}
  end

  test "sends a write once even when the server answers 503" do
    stub = :write_once
    {counter, count} = count_calls()

    Req.Test.stub(stub, fn conn ->
      count.()
      Plug.Conn.send_resp(conn, 503, "")
    end)

    assert {:error, %Error{kind: :server, status: 503}} =
             Client.request(client(stub), :sefin, :post, "/nfse", json: %{})

    assert :counters.get(counter, 1) == 1
  end

  test "retries a read on 503" do
    stub = :retry_read
    {counter, count} = count_calls()

    Req.Test.stub(stub, fn conn ->
      count.()

      if :counters.get(counter, 1) == 1 do
        Plug.Conn.send_resp(conn, 503, "")
      else
        Req.Test.json(conn, %{"ok" => true})
      end
    end)

    client = client(stub, req_options: [retry_delay: 0, retry_log_level: false])

    assert {:ok, %{status: 200}} = Client.request(client, :sefin, :get, "/nfse/1")
    assert :counters.get(counter, 1) == 2
  end

  test "reads PascalCase and camelCase rejections the same way" do
    stub = :rejections

    Req.Test.stub(stub, fn conn ->
      body =
        case conn.request_path do
          "/API/SefinNacional/pascal" ->
            %{"erros" => [%{"Codigo" => "E0001", "Descricao" => "x", "Complemento" => "y"}]}

          "/API/SefinNacional/camel" ->
            %{"erro" => %{"codigo" => "E0002", "descricao" => "z"}}
        end

      conn |> Plug.Conn.put_status(400) |> Req.Test.json(body)
    end)

    client = client(stub)

    assert {:error, %Error{kind: :rejected, status: 400, messages: pascal}} =
             Client.request(client, :sefin, :post, "/pascal", json: %{})

    assert pascal == [%{code: "E0001", description: "x", complement: "y"}]

    assert {:error, %Error{kind: :rejected, messages: camel}} =
             Client.request(client, :sefin, :post, "/camel", json: %{})

    assert camel == [%{code: "E0002", description: "z", complement: nil}]
  end

  test "reads a top-level mensagem when the body has no error list" do
    assert Client.messages(%{"aliquotas" => nil, "mensagem" => "Alíquotas não encontradas."}) ==
             [%{code: nil, description: "Alíquotas não encontradas.", complement: nil}]

    assert Client.messages(%{"Erros" => [%{"Codigo" => "E1"}], "mensagem" => "ignorada"}) ==
             [%{code: "E1", description: nil, complement: nil}]

    assert Client.messages(%{}) == []
  end

  test "maps 403, 404 and a timeout" do
    stub = :statuses

    Req.Test.stub(stub, fn conn ->
      case conn.request_path do
        "/API/SefinNacional/forbidden" -> Plug.Conn.send_resp(conn, 403, "")
        "/API/SefinNacional/missing" -> Plug.Conn.send_resp(conn, 404, "")
        "/API/SefinNacional/slow" -> Req.Test.transport_error(conn, :timeout)
        "/API/SefinNacional/down" -> Req.Test.transport_error(conn, :econnrefused)
      end
    end)

    client = client(stub, req_options: [retry: false])

    assert {:error, %Error{kind: :forbidden, status: 403}} =
             Client.request(client, :sefin, :get, "/forbidden")

    assert {:error, %Error{kind: :not_found, status: 404}} =
             Client.request(client, :sefin, :get, "/missing")

    assert {:error, %Error{kind: :timeout}} = Client.request(client, :sefin, :get, "/slow")
    assert {:error, %Error{kind: :transport}} = Client.request(client, :sefin, :get, "/down")
  end

  test "accepts the statuses the caller lists instead of failing" do
    stub = :accepted_statuses

    Req.Test.stub(stub, fn conn ->
      conn |> Plug.Conn.put_status(404) |> Req.Test.json(%{"mensagem" => "fim da fila"})
    end)

    client = client(stub)

    assert {:ok, %{status: 404, body: %{"mensagem" => "fim da fila"}}} =
             Client.request(client, :adn, :get, "/q", accept: [404])

    assert {:error, %Error{kind: :not_found}} = Client.request(client, :adn, :get, "/q")
  end
end
