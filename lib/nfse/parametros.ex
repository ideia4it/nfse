defmodule Nfse.Parametros do
  @moduledoc """
  Parâmetros municipais do ADN: como o município configurou o sistema nacional (convênio,
  alíquotas por serviço, regimes especiais, retenções e benefícios). As funções são expostas por
  `Nfse`.

  São consultas de leitura em `GET /parametrizacao/...`. Cada função devolve o objeto de dentro
  da resposta (`parametrosConvenio`, `aliquotas`, `regimesEspeciais`, `retencoes` ou `beneficio`),
  com as chaves da API como vieram. Uma resposta 200 sem esse objeto é `:unexpected`. Quando o
  município não tem o dado, o ADN responde 404 com a `mensagem` no corpo, que vira `:not_found`
  com a mensagem em `messages`.

  Os `POST .../{idManut}` de alteração são operações do próprio município e ficam fora da
  biblioteca.

  ## Formatos medidos em produção (25/10/2026)

    * o código de serviço vai com pontos, `01.04.01.000`; sem eles a API responde 400. A
      biblioteca aceita os nove dígitos com ou sem pontos e monta o formato da API
    * a competência é um `Date` e vai como `2026-11-01T00:00:00`
    * o código do município é o de sete dígitos do IBGE

  ## O que não está confirmado

    * as chaves `beneficio` e `regimesEspeciais`: o swagger não as mostra e nenhuma resposta
      com sucesso foi vista; a biblioteca assume esses nomes
  """

  alias Nfse.{Client, Error, Response}

  @doc false
  @spec municipal_agreement(Client.t(), String.t()) :: {:ok, map()} | {:error, Error.t()}
  def municipal_agreement(%Client{} = client, c_mun) do
    with {:ok, [c_mun]} <- validate([municipality_code(c_mun)]) do
      fetch(client, "/parametrizacao/#{c_mun}/convenio", "parametrosConvenio")
    end
  end

  @doc false
  @spec rate(Client.t(), String.t(), String.t(), Date.t()) :: {:ok, map()} | {:error, Error.t()}
  def rate(%Client{} = client, c_mun, c_serv, competencia) do
    with {:ok, [c_mun, c_serv, competencia]} <-
           validate([municipality_code(c_mun), service_code(c_serv), competence(competencia)]) do
      fetch(client, "/parametrizacao/#{c_mun}/#{c_serv}/#{competencia}/aliquota", "aliquotas")
    end
  end

  @doc false
  @spec rate_history(Client.t(), String.t(), String.t()) :: {:ok, map()} | {:error, Error.t()}
  def rate_history(%Client{} = client, c_mun, c_serv) do
    with {:ok, [c_mun, c_serv]} <- validate([municipality_code(c_mun), service_code(c_serv)]) do
      fetch(client, "/parametrizacao/#{c_mun}/#{c_serv}/historicoaliquotas", "aliquotas")
    end
  end

  @doc false
  @spec special_regimes(Client.t(), String.t(), String.t(), Date.t()) ::
          {:ok, map()} | {:error, Error.t()}
  def special_regimes(%Client{} = client, c_mun, c_serv, competencia) do
    with {:ok, [c_mun, c_serv, competencia]} <-
           validate([municipality_code(c_mun), service_code(c_serv), competence(competencia)]) do
      fetch(
        client,
        "/parametrizacao/#{c_mun}/#{c_serv}/#{competencia}/regimes_especiais",
        "regimesEspeciais"
      )
    end
  end

  @doc false
  @spec withholdings(Client.t(), String.t(), Date.t()) :: {:ok, map()} | {:error, Error.t()}
  def withholdings(%Client{} = client, c_mun, competencia) do
    with {:ok, [c_mun, competencia]} <-
           validate([municipality_code(c_mun), competence(competencia)]) do
      fetch(client, "/parametrizacao/#{c_mun}/#{competencia}/retencoes", "retencoes")
    end
  end

  @doc false
  @spec benefit(Client.t(), String.t(), String.t() | integer(), Date.t()) ::
          {:ok, map()} | {:error, Error.t()}
  def benefit(%Client{} = client, c_mun, n_beneficio, competencia) do
    with {:ok, [c_mun, n_beneficio, competencia]} <-
           validate([
             municipality_code(c_mun),
             benefit_number(n_beneficio),
             competence(competencia)
           ]) do
      fetch(
        client,
        "/parametrizacao/#{c_mun}/#{n_beneficio}/#{competencia}/beneficio",
        "beneficio"
      )
    end
  end

  defp municipality_code(code) do
    if is_binary(code) and code =~ ~r/\A\d{7}\z/,
      do: {:ok, code},
      else: invalid("c_mun", :pattern)
  end

  defp service_code(code) when is_binary(code) do
    case String.replace(code, ".", "") do
      <<aa::binary-2, bb::binary-2, cc::binary-2, ddd::binary-3>> = digits ->
        if digits =~ ~r/\A\d{9}\z/,
          do: {:ok, "#{aa}.#{bb}.#{cc}.#{ddd}"},
          else: invalid("c_serv", :length)

      _wrong_length ->
        invalid("c_serv", :length)
    end
  end

  defp service_code(_other), do: invalid("c_serv", :type)

  defp competence(%Date{} = date), do: {:ok, Date.to_iso8601(date) <> "T00:00:00"}
  defp competence(_other), do: invalid("competencia", :type)

  defp benefit_number(number) when is_integer(number), do: {:ok, Integer.to_string(number)}
  defp benefit_number(""), do: invalid("n_beneficio", :blank)
  defp benefit_number(number) when is_binary(number), do: {:ok, Client.path_segment(number)}
  defp benefit_number(_other), do: invalid("n_beneficio", :type)

  defp invalid(path, error), do: {:error, %{path: path, error: error}}

  defp validate(results) do
    case for({:error, entry} <- results, do: entry) do
      [] -> {:ok, Enum.map(results, fn {:ok, value} -> value end)}
      entries -> {:error, %Error{kind: :validation, details: entries}}
    end
  end

  defp fetch(client, path, key) do
    with {:ok, %{body: body}} <- Client.request(client, :adn, :get, path) do
      case Response.field(body, key) do
        inner when is_map(inner) -> {:ok, inner}
        _missing -> {:error, %Error{kind: :unexpected, details: {:missing_field, key}}}
      end
    end
  end
end
