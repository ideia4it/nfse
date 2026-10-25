defmodule Nfse.Codec do
  @moduledoc """
  Uso interno da biblioteca: não faz parte da API pública.

  Envelope dos documentos XML na API: gzip seguido de base64.

  A Sefin recebe a DPS e os eventos assim, e o ADN devolve os documentos no mesmo formato.
  """

  alias Nfse.Error

  @doc "Compacta o XML com gzip e codifica o resultado em base64."
  @spec pack(iodata()) :: String.t()
  def pack(xml) do
    xml
    |> IO.iodata_to_binary()
    |> :zlib.gzip()
    |> Base.encode64()
  end

  @doc "Decodifica o base64 e descompacta o gzip, devolvendo o XML."
  @spec unpack(String.t()) :: {:ok, binary()} | {:error, Error.t()}
  def unpack(b64) when is_binary(b64) do
    with {:ok, compressed} <- Base.decode64(b64, ignore: :whitespace),
         {:ok, xml} <- gunzip(compressed) do
      {:ok, xml}
    else
      _failure -> {:error, unreadable()}
    end
  end

  defp gunzip(compressed) do
    {:ok, :zlib.gunzip(compressed)}
  rescue
    ErlangError -> :error
  end

  defp unreadable do
    %Error{kind: :unexpected, details: :invalid_envelope}
  end
end
