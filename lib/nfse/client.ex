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

  Uma escrita (`:post`) só é repetida quando o pedido nunca saiu da máquina: host que não resolve
  (`:nxdomain`), conexão recusada ou rede inalcançável antes do envio, e as recusas do pool HTTP/2
  que ocorrem antes de transmitir. Qualquer outra falha é ambígua, porque a Sefin pode já ter
  emitido a nota: timeout, conexão fechada e toda resposta HTTP, 5xx inclusive, voltam como
  `Nfse.Error` para o chamador conferir a DPS em vez de reenviá-la. Repetir nesses casos
  duplicaria a nota fiscal.

  Leituras (`:get` e `:head`) são repetidas em falhas transitórias (408, 429, 500, 502, 503, 504,
  timeout, conexão recusada ou fechada, `:nxdomain`).

  `req_options` não consegue religar o reenvio de uma escrita: a política de `:post` vale mesmo
  que `retry:` seja informado ali.

  ## Opções do Req

  `req_options` é mesclado por último e vence os padrões. Um `finch: [name: MyFinch]` ali
  substitui o pool inteiro, porque o Req não aceita nome junto com opções de pool. Quem faz isso
  precisa iniciar o próprio Finch com o certificado em `conn_opts: [transport_opts: [cert: ..., key: ...]]`,
  senão o mTLS não acontece.

  ## O que não está confirmado

    * a cadeia do certificado no handshake: `Nfse.Certificate` lê a cadeia do `.pfx`, mas o TLS
      envia só a folha. Se a Sefin recusar o handshake pedindo a cadeia, enviar
      `cert: [folha | cadeia]` em `transport_opts`; até a biblioteca fazer isso, quem precisar
      inicia o próprio Finch assim, como em "Opções do Req"
  """

  alias Nfse.Certificate
  alias Nfse.Error
  alias Nfse.Response

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

  @environments [:production, :restricted]

  @doc """
  Monta o cliente.

  Opções: `:certificate` e `:environment` (obrigatórias), `:receive_timeout` (padrão `60_000`) e
  `:req_options` (padrão `[]`). Recusa, sem rede, o certificado vencido e o que não serve para
  *clientAuth*.

  Uma opção obrigatória ausente ou um `:environment` fora de `:production` e `:restricted` volta
  como `%Nfse.Error{kind: :validation}`, com os erros juntos em `details`, nos caminhos
  `certificate` e `environment` (`:required` ou `:inclusion`).
  """
  @spec new(keyword()) :: {:ok, t()} | {:error, Error.t()}
  def new(opts) do
    with :ok <- check_options(opts),
         client = struct!(__MODULE__, opts),
         :ok <- check_certificate(client.certificate) do
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

  @doc false
  @spec path_segment(String.t()) :: String.t()
  def path_segment(value), do: URI.encode(value, &URI.char_unreserved?/1)

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

  @doc "Normaliza um item de `erros` ou de `alertas`, em PascalCase ou camelCase, como `t:Nfse.Error.message/0`."
  @spec message(map()) :: Error.message()
  def message(error) do
    %{
      code: Response.field(error, "codigo"),
      description: Response.field(error, "descricao"),
      complement: Response.field(error, "complemento")
    }
  end

  defp check_options(opts) do
    required_errors =
      for key <- [:certificate, :environment],
          is_nil(opts[key]),
          do: %{path: Atom.to_string(key), error: :required}

    environment_errors =
      if is_nil(opts[:environment]) or opts[:environment] in @environments,
        do: [],
        else: [%{path: "environment", error: :inclusion}]

    case required_errors ++ environment_errors do
      [] -> :ok
      errors -> {:error, %Error{kind: :validation, details: errors}}
    end
  end

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
      retry: &retry?/2
    ]
    |> Keyword.merge(Keyword.take(opts, [:json, :params]))
    |> Keyword.merge(client.req_options)
    |> enforce_write_retry(method)
    |> Req.new()
  end

  # Sem `cacerts`: com `verify: :verify_peer`, padrão do Mint, ele lê `:public_key.cacerts_get()`
  # ao conectar. A lista aqui ficaria copiada em cada pool, que é um por certificado, e entraria no
  # hash que o Req calcula a cada requisição para achar o pool.
  defp transport_opts(%Certificate{} = certificate),
    do: [cert: certificate.certificate, key: certificate.key]

  defp enforce_write_retry(options, :post), do: Keyword.put(options, :retry, &retry?/2)
  defp enforce_write_retry(options, _safe_method), do: options

  defp retry?(%Req.Request{method: :post}, outcome), do: never_sent?(outcome)
  defp retry?(%Req.Request{}, outcome), do: never_sent?(outcome) or transient_read?(outcome)

  defp never_sent?(%Req.TransportError{reason: reason}),
    do: reason in [:nxdomain, :econnrefused, :ehostunreach, :enetunreach]

  defp never_sent?(%Req.HTTPError{protocol: :http2, reason: reason}),
    do: reason in [:unprocessed, :pool_not_available]

  defp never_sent?(_outcome), do: false

  defp transient_read?(%Req.Response{status: status}),
    do: status in [408, 429, 500, 502, 503, 504]

  defp transient_read?(%Req.TransportError{reason: reason}), do: reason in [:timeout, :closed]
  defp transient_read?(_outcome), do: false

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
