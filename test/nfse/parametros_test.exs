defmodule Nfse.ParametrosTest do
  use ExUnit.Case, async: true

  alias Nfse.{Error, SefinStub}

  defp client(context), do: SefinStub.client(context.test)

  defp stub_json(context, status, body, assertions \\ fn _conn -> :ok end) do
    Req.Test.stub(context.test, fn conn ->
      assert conn.method == "GET"
      assertions.(conn)

      conn
      |> Plug.Conn.put_status(status)
      |> Req.Test.json(body)
    end)
  end

  defp refuse_network(context) do
    Req.Test.stub(context.test, fn _conn ->
      flunk("a validation error must not reach the network")
    end)
  end

  test "reads the agreement of a municipality", context do
    stub_json(
      context,
      200,
      %{
        "parametrosConvenio" => %{"aderenteEmissorNacional" => 0, "aderenteMAN" => 0},
        "mensagem" => "Parâmetros do convênio recuperados com sucesso."
      },
      fn conn -> assert conn.request_path =~ "/parametrizacao/2927408/convenio" end
    )

    assert {:ok, %{"aderenteEmissorNacional" => 0, "aderenteMAN" => 0}} =
             Nfse.municipal_agreement(client(context), "2927408")
  end

  test "sends the service code with dots and the competencia as a date-time", context do
    stub_json(context, 200, %{"aliquotas" => %{"01.04.01.000" => []}}, fn conn ->
      assert conn.request_path =~
               "/parametrizacao/2927408/01.04.01.000/2026-11-01T00:00:00/aliquota"
    end)

    assert {:ok, %{"01.04.01.000" => []}} =
             Nfse.rate(client(context), "2927408", "010401000", ~D[2026-11-01])

    assert {:ok, %{"01.04.01.000" => []}} =
             Nfse.rate(client(context), "2927408", "01.04.01.000", ~D[2026-11-01])
  end

  test "reads the rate history, special regimes, withholdings and benefit of a municipality",
       context do
    history = %{"01.04.01.000" => [%{"Incidencia" => "SIM", "Aliq" => 5.0}]}

    stub_json(context, 200, %{"aliquotas" => history}, fn conn ->
      assert conn.request_path =~ "/parametrizacao/2927408/01.04.01.000/historicoaliquotas"
    end)

    assert {:ok, ^history} = Nfse.rate_history(client(context), "2927408", "010401000")

    stub_json(context, 200, %{"regimesEspeciais" => %{"x" => 1}}, fn conn ->
      assert conn.request_path =~
               "/parametrizacao/2927408/01.04.01.000/2026-11-01T00:00:00/regimes_especiais"
    end)

    assert {:ok, %{"x" => 1}} =
             Nfse.special_regimes(client(context), "2927408", "010401000", ~D[2026-11-01])

    stub_json(context, 200, %{"retencoes" => %{"y" => 2}}, fn conn ->
      assert conn.request_path =~ "/parametrizacao/2927408/2026-11-01T00:00:00/retencoes"
    end)

    assert {:ok, %{"y" => 2}} = Nfse.withholdings(client(context), "2927408", ~D[2026-11-01])

    stub_json(context, 200, %{"beneficio" => %{"z" => 3}}, fn conn ->
      assert conn.request_path =~ "/parametrizacao/2927408/AB%2F1/2026-11-01T00:00:00/beneficio"
    end)

    assert {:ok, %{"z" => 3}} =
             Nfse.benefit(client(context), "2927408", "AB/1", ~D[2026-11-01])
  end

  test "refuses invalid arguments before the network", context do
    refuse_network(context)
    client = client(context)

    assert {:error, %Error{kind: :validation, details: [%{path: "c_serv", error: :length}]}} =
             Nfse.rate(client, "2927408", "010401", ~D[2026-11-01])

    assert {:error, %Error{kind: :validation, details: [%{path: "c_mun", error: :pattern}]}} =
             Nfse.municipal_agreement(client, "29274")

    assert {:error, %Error{kind: :validation, details: [%{path: "competencia", error: :type}]}} =
             Nfse.withholdings(client, "2927408", "2026-11-01")

    assert {:error, %Error{kind: :validation, details: [%{path: "n_beneficio"}]}} =
             Nfse.benefit(client, "2927408", "", ~D[2026-11-01])
  end

  test "returns not found when the municipality has no rate for the period", context do
    stub_json(context, 404, %{"aliquotas" => nil, "mensagem" => "Alíquotas não encontradas."})

    assert {:error, %Error{kind: :not_found, messages: [%{description: description}]}} =
             Nfse.rate(client(context), "2927408", "010401000", ~D[2026-11-01])

    assert description == "Alíquotas não encontradas."
  end

  test "flags a success answer without the expected object as unexpected", context do
    stub_json(context, 200, %{"parametrosConvenio" => nil, "mensagem" => "ok"})

    assert {:error, %Error{kind: :unexpected, details: {:missing_field, "parametrosConvenio"}}} =
             Nfse.municipal_agreement(client(context), "2927408")
  end
end
