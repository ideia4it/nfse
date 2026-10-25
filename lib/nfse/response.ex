defmodule Nfse.Response do
  @moduledoc """
  Uso interno da biblioteca: não faz parte da API pública.

  Leitura dos corpos JSON da Sefin e do ADN, que chegam ora em camelCase, ora em PascalCase.
  """

  @doc "Lê um campo pela chave em camelCase, com a PascalCase como alternativa. Não-mapa dá `nil`."
  @spec field(term(), String.t()) :: term()
  def field(map, camel_key), do: field(map, camel_key, pascal_case(camel_key))

  @doc "Como `field/2`, para a chave cuja grafia PascalCase não é a camelCase capitalizada (`NSU`)."
  @spec field(term(), String.t(), String.t()) :: term()
  def field(map, camel_key, pascal_key) when is_map(map), do: map[camel_key] || map[pascal_key]
  def field(_other, _camel_key, _pascal_key), do: nil

  defp pascal_case(<<first::utf8, rest::binary>>), do: String.upcase(<<first::utf8>>) <> rest
end
