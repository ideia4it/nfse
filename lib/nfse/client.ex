defmodule Nfse.Client do
  @moduledoc """
  Cliente HTTP da NFS-e Nacional, autenticado por mTLS com o certificado A1 do emitente.

  Todo o estado vive no `%Nfse.Client{}`: certificado, ambiente, tempo de espera e opções do Req.
  Não há processo nem configuração global.

  ## Ambientes

  | `environment` | Sefin | ADN |
  |---|---|---|
  | `:production` | `https://sefin.nfse.gov.br/SefinNacional` | `https://adn.nfse.gov.br` |
  | `:restricted` | `https://sefin.producaorestrita.nfse.gov.br/API/SefinNacional` | `https://adn.producaorestrita.nfse.gov.br` |

  ## Reenvio

  Leituras (`:get` e `:head`) são repetidas em falhas transitórias. Escritas (`:post`) nunca são
  repetidas: sem resposta, o resultado é incerto e o `Nfse.Error` volta com `:timeout`, `:transport`
  ou `:server` para o chamador conferir antes de reenviar.

  ## Opções do Req

  `req_options` é mesclado por último e vence os padrões. Um `finch: [name: MyFinch]` ali
  substitui o pool inteiro, porque o Req não aceita nome junto com opções de pool. Quem faz isso
  precisa iniciar o próprio Finch com o certificado em `conn_opts: [transport_opts: [cert: ..., key: ...]]`,
  senão o mTLS não acontece.
  """

  alias Nfse.Certificate
  alias Nfse.Error

  @enforce_keys [:certificate, :environment]
  defstruct [:certificate, :environment, receive_timeout: 60_000, req_options: []]

  @type environment :: :production | :restricted
  @type service :: :sefin | :adn

  @type t :: %__MODULE__{
          certificate: Certificate.t(),
          environment: environment(),
          receive_timeout: pos_integer(),
          req_options: keyword()
        }

  @base_urls %{
    {:production, :sefin} => "https://sefin.nfse.gov.br/SefinNacional",
    {:production, :adn} => "https://adn.nfse.gov.br",
    {:restricted, :sefin} => "https://sefin.producaorestrita.nfse.gov.br/API/SefinNacional",
    {:restricted, :adn} => "https://adn.producaorestrita.nfse.gov.br"
  }

  @pool_max_idle_time :timer.minutes(5)

  @doc """
  Monta o cliente.

  Opções: `:certificate` e `:environment` (obrigatórias), `:receive_timeout` (padrão `60_000`) e
  `:req_options` (padrão `[]`). Recusa, sem rede, o certificado vencido e o que não serve para
  *clientAuth*.
  """
  @spec new(keyword()) :: {:ok, t()} | {:error, Error.t()}
  def new(opts) do
    client = struct!(__MODULE__, opts)

    with :ok <- check_certificate(client.certificate) do
      {:ok, client}
    end
  end

  @doc "Valor do campo `tpAmb` do ambiente, como texto: `1` em produção e `2` em produção restrita."
  @spec tp_amb(t()) :: String.t()
  def tp_amb(%__MODULE__{environment: :production}), do: "1"
  def tp_amb(%__MODULE__{environment: :restricted}), do: "2"

  @doc """
  Faz a requisição ao serviço e classifica a resposta.

  Opções: `:json` (corpo), `:params` (query string) e `:accept`, uma lista de status que voltam
  como `{:ok, resp}` mesmo fora de 2xx, para APIs que respondem 404 com corpo em vez de erro.
  """
  @spec request(t(), service(), :get | :head | :post, String.t(), keyword()) ::
          {:ok, Req.Response.t()} | {:error, Error.t()}
  def request(%__MODULE__{} = client, service, method, path, opts \\ []) do
    {accepted_statuses, request_opts} = Keyword.pop(opts, :accept, [])

    client
    |> build_request(service, method, path, request_opts)
    |> Req.request()
    |> classify(accepted_statuses)
  end

  @doc """
  Lê as mensagens de erro de um corpo de resposta.

  Aceita `erros`/`Erros` (lista), `erro`/`Erro` (objeto) e, na falta deles, um `mensagem` de nível
  superior. Os campos podem vir em PascalCase ou camelCase.
  """
  @spec messages(map()) :: [Error.message()]
  def messages(%{"erros" => errors}) when is_list(errors), do: Enum.map(errors, &message/1)
  def messages(%{"Erros" => errors}) when is_list(errors), do: Enum.map(errors, &message/1)
  def messages(%{"erro" => error}) when is_map(error), do: [message(error)]
  def messages(%{"Erro" => error}) when is_map(error), do: [message(error)]

  def messages(%{"mensagem" => description}) when is_binary(description),
    do: [%{code: nil, description: description, complement: nil}]

  def messages(_body), do: []

  defp message(error) do
    %{
      code: field(error, "Codigo", "codigo"),
      description: field(error, "Descricao", "descricao"),
      complement: field(error, "Complemento", "complemento")
    }
  end

  defp field(error, pascal_key, camel_key), do: error[pascal_key] || error[camel_key]

  defp check_certificate(certificate) do
    cond do
      Certificate.expired?(certificate, DateTime.utc_now()) ->
        {:error, %Error{kind: :certificate, details: :expired}}

      not certificate.client_auth ->
        {:error, %Error{kind: :certificate, details: :missing_client_auth}}

      true ->
        :ok
    end
  end

  defp build_request(client, service, method, path, opts) do
    [
      method: method,
      base_url: Map.fetch!(@base_urls, {client.environment, service}),
      url: path,
      finch: [
        pool_max_idle_time: @pool_max_idle_time,
        conn_opts: [transport_opts: transport_opts(client.certificate)]
      ],
      receive_timeout: client.receive_timeout,
      redirect: false,
      retry: retry_policy(method)
    ]
    |> Keyword.merge(Keyword.take(opts, [:json, :params]))
    |> Keyword.merge(client.req_options)
    |> Req.new()
  end

  defp transport_opts(%Certificate{} = certificate) do
    [
      cert: certificate.certificate,
      key: certificate.key,
      cacerts: :public_key.cacerts_get()
    ]
  end

  defp retry_policy(:post), do: false
  defp retry_policy(_safe_method), do: :safe_transient

  defp classify({:ok, %Req.Response{status: status} = response}, accepted_statuses) do
    if status in 200..299 or status in accepted_statuses do
      {:ok, response}
    else
      {:error, failure(response)}
    end
  end

  defp classify({:error, %Req.TransportError{reason: :timeout}}, _accepted_statuses),
    do: {:error, %Error{kind: :timeout}}

  defp classify({:error, exception}, _accepted_statuses),
    do: {:error, %Error{kind: :transport, details: exception}}

  defp failure(%Req.Response{status: status, body: body}) do
    %Error{kind: kind_for(status), status: status, messages: messages(body)}
  end

  defp kind_for(status) when status in [400, 422], do: :rejected
  defp kind_for(status) when status in [401, 403], do: :forbidden
  defp kind_for(404), do: :not_found
  defp kind_for(status) when status >= 500, do: :server
  defp kind_for(_status), do: :unexpected
end
