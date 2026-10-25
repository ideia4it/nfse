defmodule Nfse.Adn do
  @moduledoc """
  Distribuição de documentos pelo ADN (Ambiente de Dados Nacional). As funções são expostas por
  `Nfse`.

  O ADN entrega ao contribuinte todo documento fiscal em que o CNPJ dele aparece (notas emitidas,
  notas recebidas e eventos como o cancelamento) numa fila numerada por NSU, em lotes de até 50.
  `GET /contribuintes/DFe/{NSU}` devolve os documentos depois do NSU pedido, então o `next_nsu` de
  um lote é o NSU da próxima chamada. Para importar notas, guarde o último `next_nsu` e continue
  dele.

  O fim da fila pode chegar como 404 com `NENHUM_DOCUMENTO_LOCALIZADO` no corpo. Isso é sucesso
  (`status: :no_documents`); um 404 sem esse status é `:not_found`. O status do processamento vem
  do corpo: `REJEICAO` vira `:rejected`, com as mensagens de `Erros`.

  Um documento do lote que não se consegue ler não derruba o lote nem trava o NSU: ele volta com
  `document: nil` e o motivo em `error` (veja `Nfse.DistributedDocument`).

  As chaves da resposta chegam em PascalCase (medido em produção em 25/10/2026) e a leitura
  aceita também camelCase.

  ## O que não está confirmado

    * a resposta de `GET /contribuintes/NFSe/{chave}/Eventos`: o swagger só diz que devolve os
      eventos da chave, e a biblioteca assume o mesmo formato do lote da distribuição
  """

  alias Nfse.{Client, Codec, DistributedDocument, Distribution, Error, Response, Sefin}

  @document_types %{
    "NFSE" => :nfse,
    "EVENTO" => :evento,
    "DPS" => :dps,
    "PEDIDO_REGISTRO_EVENTO" => :pedido_registro_evento,
    "CNC" => :cnc,
    "NENHUM" => :nenhum
  }

  @doc false
  @spec distribution(Client.t(), non_neg_integer(), keyword()) ::
          {:ok, Distribution.t()} | {:error, Error.t()}
  def distribution(%Client{} = client, nsu, opts \\ []) when is_integer(nsu) and nsu >= 0 do
    params = [lote: true] ++ cnpj_param(opts[:cnpj_consulta])

    client
    |> Client.request(:adn, :get, "/contribuintes/DFe/#{nsu}", params: params, accept: [404])
    |> read_distribution(nsu)
  end

  @doc false
  @spec stream_distribution(Client.t(), non_neg_integer(), keyword()) ::
          Enumerable.t(DistributedDocument.t())
  def stream_distribution(%Client{} = client, nsu, opts \\ []) do
    Stream.resource(
      fn -> nsu end,
      &next_batch(client, &1, opts),
      fn _last_nsu -> :ok end
    )
  end

  @doc false
  @spec events(Client.t(), String.t()) ::
          {:ok, [DistributedDocument.t()]} | {:error, Error.t()}
  def events(%Client{} = client, access_key) do
    path = "/contribuintes/NFSe/#{Client.path_segment(access_key)}/Eventos"

    with {:ok, %Distribution{documents: documents}} <-
           client
           |> Client.request(:adn, :get, path, accept: [404])
           |> read_distribution(0) do
      {:ok, documents}
    end
  end

  defp cnpj_param(nil), do: []
  defp cnpj_param(cnpj), do: [cnpjConsulta: cnpj]

  defp next_batch(_client, :done, _opts), do: {:halt, :done}

  defp next_batch(client, nsu, opts) do
    case distribution(client, nsu, opts) do
      {:ok, %Distribution{status: :no_documents}} -> {:halt, :done}
      {:ok, %Distribution{documents: documents, next_nsu: ^nsu}} -> {documents, :done}
      {:ok, %Distribution{documents: documents, next_nsu: next_nsu}} -> {documents, next_nsu}
      {:error, %Error{} = error} -> raise error
    end
  end

  defp read_distribution({:ok, %{status: http_status, body: body}}, requested_nsu) do
    case {Response.field(body, "statusProcessamento"), http_status} do
      {"DOCUMENTOS_LOCALIZADOS", _status} ->
        {:ok, build_distribution(:documents, body, requested_nsu)}

      {"NENHUM_DOCUMENTO_LOCALIZADO", _status} ->
        {:ok, build_distribution(:no_documents, body, requested_nsu)}

      {"REJEICAO", _status} ->
        {:error, %Error{kind: :rejected, status: http_status, messages: Client.messages(body)}}

      {_unknown, 404} ->
        {:error, %Error{kind: :not_found, status: 404, messages: messages(body)}}

      {unknown, _status} ->
        {:error,
         %Error{kind: :unexpected, status: http_status, details: {:unknown_status, unknown}}}
    end
  end

  defp read_distribution({:error, _error} = failure, _requested_nsu), do: failure

  defp build_distribution(status, body, requested_nsu) do
    documents = body |> Response.field("loteDFe") |> List.wrap() |> Enum.map(&build_document/1)

    %Distribution{
      status: status,
      documents: documents,
      next_nsu: Enum.max([requested_nsu | Enum.map(documents, & &1.nsu)]),
      alerts: body |> Response.field("alertas") |> List.wrap() |> Enum.map(&Client.message/1)
    }
  end

  defp build_document(item) do
    type = Map.get(@document_types, Response.field(item, "tipoDocumento"), :unknown)
    packed = Response.field(item, "arquivoXml")

    %DistributedDocument{
      nsu: Response.field(item, "nsu", "NSU"),
      access_key: Response.field(item, "chaveAcesso"),
      type: type,
      event_type: Response.field(item, "tipoEvento"),
      generated_at: item |> Response.field("dataHoraGeracao") |> parse_datetime()
    }
    |> read_content(packed)
  end

  defp read_content(%DistributedDocument{type: type} = document, packed)
       when type in [:nfse, :evento] do
    case unpack(packed) do
      {:ok, xml} -> parse_content(%{document | xml: xml})
      {:error, %Error{} = error} -> %{document | error: error}
    end
  end

  defp read_content(document, packed) do
    case unpack(packed) do
      {:ok, xml} -> %{document | xml: xml}
      {:error, _unreadable} -> document
    end
  end

  defp parse_content(%DistributedDocument{type: type, xml: xml} = document) do
    case decode(type, xml) do
      {:ok, parsed} -> %{document | document: parsed}
      {:error, %Error{} = error} -> %{document | error: error}
    end
  end

  defp unpack(packed) when is_binary(packed), do: Codec.unpack(packed)

  defp unpack(_missing),
    do: {:error, %Error{kind: :unexpected, details: {:missing_field, "ArquivoXml"}}}

  defp decode(:nfse, xml), do: Sefin.decode_nfse(xml)
  defp decode(:evento, xml), do: Sefin.decode_evento(xml)

  defp parse_datetime(value) when is_binary(value) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, _offset} -> datetime
      {:error, :missing_offset} -> naive_datetime(value)
      {:error, _invalid} -> nil
    end
  end

  defp parse_datetime(_missing), do: nil

  defp naive_datetime(value) do
    case NaiveDateTime.from_iso8601(value) do
      {:ok, naive} -> naive
      {:error, _invalid} -> nil
    end
  end

  defp messages(body) when is_map(body), do: Client.messages(body)
  defp messages(_body), do: []
end
