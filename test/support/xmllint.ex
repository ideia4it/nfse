defmodule Nfse.Xmllint do
  @moduledoc false

  @doc "Valida `xml` contra o XSD `root_xsd` com o `xmllint` e falha o teste com a saída dele."
  def validate!(xml, root_xsd) do
    path = Path.join(System.tmp_dir!(), "nfse-xmllint-#{System.unique_integer([:positive])}.xml")
    File.write!(path, xml)

    try do
      case System.cmd("xmllint", ["--noout", "--schema", root_xsd, path], stderr_to_stdout: true) do
        {_output, 0} -> :ok
        {output, _status} -> raise ExUnit.AssertionError, message: "xmllint recusou:\n" <> output
      end
    after
      File.rm(path)
    end
  end
end
