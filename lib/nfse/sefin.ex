defmodule Nfse.Sefin do
  @moduledoc """
  Emissão e consultas na Sefin Nacional. As funções são expostas por `Nfse`.

  A emissão é síncrona: `POST /nfse` recebe a DPS assinada e responde, na mesma chamada, com a
  NFS-e. Por isso uma emissão que não obteve resposta (`:timeout`, `:transport` ou `:server`) tem
  resultado incerto, e a biblioteca a envia uma única vez. O `Nfse.Error` volta com o `dps_id`, que
  se confere com `dps_issued?/2` e `fetch_access_key/2` antes de qualquer reenvio. Todo erro de
  `issue/2` posterior à montagem da DPS carrega o `dps_id`.

  A documentação da Sefin descreve a resposta de sucesso em camelCase, mas os erros chegam em
  PascalCase; os campos de sucesso são lidos nas duas grafias.

  ## Eventos

  `register_event/2` envia o pedido assinado a `POST /nfse/{chave}/eventos` e `fetch_event/4` lê um
  evento em `GET /nfse/{chave}/eventos/{tipo}/{sequência}`. Como na emissão, a escrita sai uma única
  vez: um `:timeout` ou `:server` deixa o resultado incerto, e o evento se confere com
  `fetch_event/4` antes de qualquer reenvio. A recusa de um evento chega com um único objeto
  `erro`, que o cliente já lê.

  ## O que não está confirmado

  Itens da Sefin ainda sem prova contra o ambiente de produção restrita:

    * o caminho da Sefin em produção restrita: `/API/SefinNacional`, como no portal gov.br, ou
      `/SefinNacional`
    * a assinatura da DPS em RSA-SHA1 ou RSA-SHA256
    * se o ME/EPP do Simples Nacional informa `pAliq`
    * a série com `^` ou `$`, que o padrão do schema permite
    * a resposta de `GET /nfse/{chave}/eventos/{tipo}/{sequência}`, documentada com o mesmo campo
      `eventoXmlGZipB64` da resposta do registro, ainda não vista de verdade
  """

  alias Nfse.{
    Client,
    Codec,
    Document,
    DPS,
    Error,
    Event,
    Identifiers,
    Issued,
    PedidoEvento,
    Schema
  }

  @doc false
  @spec issue(Client.t(), DPS.t() | map()) :: {:ok, Issued.t()} | {:error, Error.t()}
  def issue(%Client{} = client, dps) do
    with {:ok, %{xml: xml, id: dps_id}} <- DPS.build(dps, client) do
      client
      |> Client.request(:sefin, :post, "/nfse", json: %{"dpsXmlGZipB64" => Codec.pack(xml)})
      |> read_issued(dps_id)
      |> put_dps_id(dps_id)
    end
  end

  @doc false
  @spec fetch(Client.t(), String.t()) :: {:ok, Document.t()} | {:error, Error.t()}
  def fetch(%Client{} = client, access_key) do
    with {:ok, response} <- Client.request(client, :sefin, :get, "/nfse/" <> segment(access_key)),
         {:ok, xml, nfse} <- read_nfse(response.body) do
      {:ok, %Document{access_key: access_key, nfse: nfse, xml: xml}}
    end
  end

  @doc false
  @spec dps_issued?(Client.t(), String.t()) :: {:ok, boolean()} | {:error, Error.t()}
  def dps_issued?(%Client{} = client, dps_id) do
    with {:ok, response} <-
           Client.request(client, :sefin, :head, "/dps/" <> segment(dps_id), accept: [404]) do
      {:ok, response.status != 404}
    end
  end

  @doc false
  @spec fetch_access_key(Client.t(), String.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def fetch_access_key(%Client{} = client, dps_id) do
    with {:ok, response} <- Client.request(client, :sefin, :get, "/dps/" <> segment(dps_id)) do
      required(response.body, "chaveAcesso")
    end
  end

  @doc false
  @spec register_event(Client.t(), PedidoEvento.t() | map()) ::
          {:ok, Event.t()} | {:error, Error.t()}
  def register_event(%Client{} = client, pedido) do
    with {:ok, %{xml: xml, id: id}} <- PedidoEvento.build(pedido, client) do
      access_key = Identifiers.event_request_access_key(id)

      client
      |> Client.request(:sefin, :post, "/nfse/#{segment(access_key)}/eventos",
        json: %{"pedidoRegistroEventoXmlGZipB64" => Codec.pack(xml)}
      )
      |> read_event(access_key)
    end
  end

  @doc false
  @spec cancel(Client.t(), String.t(), keyword()) :: {:ok, Event.t()} | {:error, Error.t()}
  def cancel(%Client{} = client, access_key, opts) do
    register_event(client, %{
      ch_nfse: access_key,
      ver_aplic: Keyword.get(opts, :ver_aplic, default_ver_aplic()),
      e101101: %{
        x_desc: "Cancelamento de NFS-e",
        c_motivo: opts[:c_motivo],
        x_motivo: opts[:x_motivo]
      }
    })
  end

  @doc false
  @spec fetch_event(Client.t(), String.t(), String.t(), pos_integer()) ::
          {:ok, Event.t()} | {:error, Error.t()}
  def fetch_event(%Client{} = client, access_key, event_type, sequence)
      when is_integer(sequence) and sequence > 0 do
    path = "/nfse/#{segment(access_key)}/eventos/#{segment(event_type)}/#{sequence}"

    client
    |> Client.request(:sefin, :get, path)
    |> read_event(access_key)
  end

  @doc """
  Lê o XML de uma NFS-e na versão que o atributo `versao` da raiz indica.
  """
  @spec decode_nfse(binary()) :: {:ok, struct()} | {:error, Error.t()}
  def decode_nfse(xml), do: decode_root(xml, :nfse)

  defp decode_root(xml, root) do
    case Saxy.SimpleForm.parse_string(xml) do
      {:ok, {_tag, attributes, _content} = element} ->
        {_name, version} = List.keyfind(attributes, "versao", 0, {"versao", nil})

        with {:ok, module} <- Schema.root(version, root) do
          module.decode(element)
        end

      {:error, exception} ->
        {:error, %Error{kind: :unexpected, details: exception}}
    end
  end

  defp read_issued({:ok, %{body: body}}, dps_id) do
    with {:ok, access_key} <- required(body, "chaveAcesso"),
         {:ok, xml, nfse} <- read_nfse(body) do
      {:ok,
       %Issued{
         access_key: access_key,
         dps_id: dps_id,
         nfse: nfse,
         xml: xml,
         alerts: alerts(body),
         processed_at: processed_at(body)
       }}
    end
  end

  defp read_issued({:error, _error} = failure, _dps_id), do: failure

  defp read_event({:ok, %{body: body}}, access_key) do
    with {:ok, packed} <- required(body, "eventoXmlGZipB64"),
         {:ok, xml} <- Codec.unpack(packed),
         {:ok, evento} <- decode_root(xml, :evento) do
      {:ok, %Event{access_key: access_key, evento: evento, xml: xml}}
    end
  end

  defp read_event({:error, _error} = failure, _access_key), do: failure

  defp default_ver_aplic, do: "nfse-" <> to_string(Application.spec(:nfse, :vsn))

  defp read_nfse(body) do
    with {:ok, packed} <- required(body, "nfseXmlGZipB64"),
         {:ok, xml} <- Codec.unpack(packed),
         {:ok, nfse} <- decode_nfse(xml) do
      {:ok, xml, nfse}
    end
  end

  defp put_dps_id({:error, %Error{} = error}, dps_id), do: {:error, %{error | dps_id: dps_id}}
  defp put_dps_id(success, _dps_id), do: success

  defp required(body, camel_key) do
    case field(body, camel_key) do
      value when is_binary(value) -> {:ok, value}
      _missing -> {:error, %Error{kind: :unexpected, details: {:missing_field, camel_key}}}
    end
  end

  defp field(body, camel_key) when is_map(body),
    do: body[camel_key] || body[pascal_case(camel_key)]

  defp field(_body, _camel_key), do: nil

  defp alerts(body) do
    case field(body, "alertas") do
      alerts when is_list(alerts) -> Enum.map(alerts, &Client.message/1)
      _none -> []
    end
  end

  defp processed_at(body) do
    with value when is_binary(value) <- field(body, "dataHoraProcessamento"),
         {:ok, datetime, _offset} <- DateTime.from_iso8601(value) do
      datetime
    else
      _unparsed -> nil
    end
  end

  defp pascal_case(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest

  defp segment(value), do: URI.encode(value, &URI.char_unreserved?/1)
end
