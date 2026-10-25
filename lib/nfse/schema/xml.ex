defmodule Nfse.Schema.Xml do
  @moduledoc """
  Escaping da forma canônica do XML (C14N 1.0), o mesmo que a assinatura digital calcula.

  Texto e valor de atributo escapam conjuntos diferentes de caracteres. Escrever `&#xD;` no lugar
  do CR é o que impede o leitor de normalizar a quebra de linha e mudar o digest.
  """

  @doc "Escapa o conteúdo de texto de um elemento: `&`, `<`, `>` e CR."
  @spec escape_text(String.t()) :: String.t()
  def escape_text(text), do: String.replace(text, ["&", "<", ">", "\r"], &text_entity/1)

  @doc "Escapa o valor de um atributo: `&`, `<`, aspas duplas, tab, LF e CR."
  @spec escape_attribute(String.t()) :: String.t()
  def escape_attribute(value),
    do: String.replace(value, ["&", "<", "\"", "\t", "\n", "\r"], &attribute_entity/1)

  defp text_entity("&"), do: "&amp;"
  defp text_entity("<"), do: "&lt;"
  defp text_entity(">"), do: "&gt;"
  defp text_entity("\r"), do: "&#xD;"

  defp attribute_entity("&"), do: "&amp;"
  defp attribute_entity("<"), do: "&lt;"
  defp attribute_entity("\""), do: "&quot;"
  defp attribute_entity("\t"), do: "&#x9;"
  defp attribute_entity("\n"), do: "&#xA;"
  defp attribute_entity("\r"), do: "&#xD;"
end
