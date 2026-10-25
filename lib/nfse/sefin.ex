defmodule Nfse.Sefin do
  @moduledoc """
  Emissão e consultas na Sefin Nacional. As funções são expostas por `Nfse`.

  A emissão é síncrona: `POST /nfse` recebe a DPS assinada e responde, na mesma chamada, com a
  NFS-e. Por isso uma emissão que não obteve resposta (`:timeout`, `:transport` ou `:server`) tem
  resultado incerto, e a biblioteca a envia uma única vez. O `Nfse.Error` volta com o `dps_id`, que
  se confere com `dps_issued?/2` e `fetch_access_key/2` antes de qualquer reenvio. Todo erro de
  `issue/2` posterior à montagem da DPS carrega o `dps_id`.

  Uma resposta 2xx que não se consegue ler, na emissão, na consulta ou num evento, volta como
  `:unexpected` com o `status` da resposta, nunca como `:validation`: o documento existe na Sefin.
  `details` é sempre `%{access_key: ..., xml: ..., reason: ...}`, com `nil` no que não se chegou a
  ler e, em `reason`, o `Nfse.Error` da etapa que falhou. Numa escrita, esse erro é incerto como
  um `:timeout`, e o `dps_id` também vem nele.

  A documentação da Sefin descreve a resposta de sucesso em camelCase, mas os erros chegam em
  PascalCase; os campos de sucesso são lidos nas duas grafias.

  ## Decisão judicial

  `issue_by_court_order/2` envia a NFS-e inteira, montada e assinada por `Nfse.NFSe`, a
  `POST /decisao-judicial/nfse`, que responde como a emissão normal. A escrita também sai uma única
  vez, e o erro carrega o `dps_id` da DPS embutida.

  ## Eventos

  `register_event/2` envia o pedido assinado a `POST /nfse/{chave}/eventos` e `fetch_event/4` lê um
  evento em `GET /nfse/{chave}/eventos/{tipo}/{sequência}`. Como na emissão, a escrita sai uma única
  vez: um `:timeout`, um `:server` ou um 2xx ilegível deixa o resultado incerto, e o evento se
  confere com `fetch_event/4` antes de qualquer reenvio. A recusa de um evento chega com um único
  objeto `erro`, que o cliente já lê.

  ## O que não está confirmado

  Itens da Sefin ainda sem prova contra o ambiente de produção restrita:

    * o caminho da Sefin em produção restrita: `/API/SefinNacional`, como no portal gov.br, ou
      `/SefinNacional`
    * a assinatura da DPS em RSA-SHA1 ou RSA-SHA256
    * se o ME/EPP do Simples Nacional informa `pAliq`
    * a série com `^` ou `$`, que o padrão do schema permite
    * emoji no `xNome`, que o XSD não restringe e a biblioteca aceita; se a Sefin o recusar, a
      recusa chega como `:rejected`
    * campo de texto só com espaços em branco, que a biblioteca nunca apara e envia como está
    * a recusa de uma DPS repetida pelo `Id`: se a Sefin a aceitar, reenviar depois de uma
      conferência negativa emite a nota duas vezes
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
    NFSe,
    PedidoEvento,
    Response,
    Schema
  }

  @doc false
  @spec issue(Client.t(), DPS.t() | map()) :: {:ok, Issued.t()} | {:error, Error.t()}
  def issue(%Client{} = client, dps) do
    with {:ok, %{xml: xml, id: dps_id}} <- DPS.build(dps, client) do
      post_for_issued(client, "/nfse", %{"dpsXmlGZipB64" => Codec.pack(xml)}, dps_id)
    end
  end

  @doc false
  @spec issue_by_court_order(Client.t(), NFSe.t() | map()) ::
          {:ok, Issued.t()} | {:error, Error.t()}
  def issue_by_court_order(%Client{} = client, nfse) do
    with {:ok, %{xml: xml, dps_id: dps_id}} <- NFSe.build(nfse, client) do
      post_for_issued(
        client,
        "/decisao-judicial/nfse",
        %{"xmlGZipB64" => Codec.pack(xml)},
        dps_id
      )
    end
  end

  @doc false
  @spec fetch(Client.t(), String.t()) :: {:ok, Document.t()} | {:error, Error.t()}
  def fetch(%Client{} = client, access_key) do
    with {:ok, response} <-
           Client.request(client, :sefin, :get, "/nfse/" <> Client.path_segment(access_key)),
         {:ok, xml, nfse} <- read_document(response, {:ok, access_key}, :nfse) do
      {:ok, %Document{access_key: access_key, nfse: nfse, xml: xml}}
    end
  end

  @doc false
  @spec dps_issued?(Client.t(), String.t()) :: {:ok, boolean()} | {:error, Error.t()}
  def dps_issued?(%Client{} = client, dps_id) do
    with {:ok, response} <-
           Client.request(client, :sefin, :head, "/dps/" <> Client.path_segment(dps_id),
             accept: [404]
           ) do
      {:ok, response.status != 404}
    end
  end

  @doc false
  @spec fetch_access_key(Client.t(), String.t()) :: {:ok, String.t()} | {:error, Error.t()}
  def fetch_access_key(%Client{} = client, dps_id) do
    with {:ok, response} <-
           Client.request(client, :sefin, :get, "/dps/" <> Client.path_segment(dps_id)) do
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
      |> Client.request(:sefin, :post, "/nfse/#{Client.path_segment(access_key)}/eventos",
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
  def fetch_event(%Client{} = client, access_key, event_type, sequence) do
    case event_reference_errors(access_key, event_type, sequence) do
      [] ->
        path =
          "/nfse/#{Client.path_segment(access_key)}/eventos/#{Client.path_segment(event_type)}/#{sequence}"

        client
        |> Client.request(:sefin, :get, path)
        |> read_event(access_key)

      errors ->
        {:error, %Error{kind: :validation, details: errors}}
    end
  end

  @doc """
  Lê o XML de uma NFS-e na versão que o atributo `versao` da raiz indica.
  """
  @spec decode_nfse(binary()) :: {:ok, struct()} | {:error, Error.t()}
  def decode_nfse(xml), do: decode_root(xml, :nfse)

  @doc """
  Lê o XML de um evento na versão que o atributo `versao` da raiz indica.
  """
  @spec decode_evento(binary()) :: {:ok, struct()} | {:error, Error.t()}
  def decode_evento(xml), do: decode_root(xml, :evento)

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

  defp post_for_issued(client, path, json, dps_id) do
    client
    |> Client.request(:sefin, :post, path, json: json)
    |> read_issued(dps_id)
    |> put_dps_id(dps_id)
  end

  defp read_issued({:ok, %{body: body} = response}, dps_id) do
    access_key_read = required(body, "chaveAcesso")

    with {:ok, xml, nfse} <- read_document(response, access_key_read, :nfse) do
      {:ok,
       %Issued{
         access_key: read_value(access_key_read),
         dps_id: dps_id,
         nfse: nfse,
         xml: xml,
         alerts: alerts(body),
         processed_at: processed_at(body)
       }}
    end
  end

  defp read_issued({:error, _error} = failure, _dps_id), do: failure

  defp read_event({:ok, response}, access_key) do
    with {:ok, xml, evento} <- read_document(response, {:ok, access_key}, :evento) do
      {:ok, %Event{access_key: access_key, evento: evento, xml: xml}}
    end
  end

  defp read_event({:error, _error} = failure, _access_key), do: failure

  # Depois de um 2xx o documento já existe na Sefin: o que não se lê é problema da resposta, nunca
  # dos dados de quem enviou, e a chave e o XML já lidos precisam chegar a quem vai guardá-los.
  defp read_document(%{status: status, body: body}, access_key_read, root) do
    xml_read = with {:ok, packed} <- required(body, packed_field(root)), do: Codec.unpack(packed)

    with {:ok, _access_key} <- access_key_read,
         {:ok, xml} <- xml_read,
         {:ok, document} <- decode_root(xml, root) do
      {:ok, xml, document}
    else
      {:error, %Error{} = reason} ->
        known = %{access_key: read_value(access_key_read), xml: read_value(xml_read)}

        {:error,
         %Error{kind: :unexpected, status: status, details: Map.put(known, :reason, reason)}}
    end
  end

  defp packed_field(:nfse), do: "nfseXmlGZipB64"
  defp packed_field(:evento), do: "eventoXmlGZipB64"

  defp read_value({:ok, value}), do: value
  defp read_value({:error, _reason}), do: nil

  defp event_reference_errors(access_key, event_type, sequence) do
    for {path, false, error} <- [
          {"access_key", digits?(access_key, 50), :pattern},
          {"tipo_evento", digits?(event_type, 6), :pattern},
          {"n_seq_evento", is_integer(sequence) and sequence > 0, :type}
        ],
        do: %{path: path, error: error}
  end

  defp digits?(value, count) when is_binary(value),
    do: byte_size(value) == count and value =~ ~r/\A\d+\z/

  defp digits?(_value, _count), do: false

  defp default_ver_aplic, do: "nfse-" <> to_string(Application.spec(:nfse, :vsn))

  defp put_dps_id({:error, %Error{} = error}, dps_id), do: {:error, %{error | dps_id: dps_id}}
  defp put_dps_id(success, _dps_id), do: success

  defp required(body, camel_key) do
    case Response.field(body, camel_key) do
      value when is_binary(value) -> {:ok, value}
      _missing -> {:error, %Error{kind: :unexpected, details: {:missing_field, camel_key}}}
    end
  end

  defp alerts(body) do
    case Response.field(body, "alertas") do
      alerts when is_list(alerts) -> Enum.map(alerts, &Client.message/1)
      _none -> []
    end
  end

  defp processed_at(body) do
    with value when is_binary(value) <- Response.field(body, "dataHoraProcessamento"),
         {:ok, datetime, _offset} <- DateTime.from_iso8601(value) do
      datetime
    else
      _unparsed -> nil
    end
  end
end
