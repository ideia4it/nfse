defmodule Nfse.Xmllint do
  @moduledoc false

  @doc "Valida `xml` contra o XSD `root_xsd` com o `xmllint` e falha o teste com a saída dele."
  def validate!(xml, root_xsd) do
    with_file(xml, fn path ->
      case System.cmd("xmllint", ["--noout", "--schema", root_xsd, path], stderr_to_stdout: true) do
        {_output, 0} -> :ok
        {output, _status} -> raise ExUnit.AssertionError, message: "xmllint recusou:\n" <> output
      end
    end)
  end

  @doc """
  Canonicaliza o documento `xml` com a C14N 1.0 inclusiva da libxml2, para o teste conferir os
  bytes assinados com uma implementação que não é a da biblioteca.
  """
  def canonicalize!(xml) do
    with_file(xml, fn path ->
      # O stderr fica de fora porque um aviso misturado à saída viraria parte dos bytes canônicos.
      case System.cmd("xmllint", ["--c14n", path]) do
        {canonical, 0} -> canonical
        {_output, status} -> raise ExUnit.AssertionError, message: "xmllint saiu com #{status}"
      end
    end)
  end

  defp with_file(xml, fun) do
    path = Path.join(System.tmp_dir!(), "nfse-xmllint-#{System.unique_integer([:positive])}.xml")
    File.write!(path, xml)

    try do
      fun.(path)
    after
      File.rm(path)
    end
  end
end
