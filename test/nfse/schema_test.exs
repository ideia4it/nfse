defmodule Nfse.SchemaTest do
  use ExUnit.Case, async: true

  alias Nfse.Schema.{V1_00, V1_01}

  doctest Nfse.Schema

  test "picks the generated root of each supported version and refuses any other version" do
    assert Nfse.Schema.root("1.01", :dps) == {:ok, V1_01.TCDPS}
    assert Nfse.Schema.root("1.01", :nfse) == {:ok, V1_01.TCNFSe}
    assert Nfse.Schema.root("1.01", :pedido_evento) == {:ok, V1_01.TCPedRegEvt}
    assert Nfse.Schema.root("1.01", :evento) == {:ok, V1_01.TCEvento}
    assert Nfse.Schema.root("1.00", :dps) == {:ok, V1_00.TCDPS}
    assert Nfse.Schema.root("1.00", :nfse) == {:ok, V1_00.TCNFSe}
    assert Nfse.Schema.root("1.00", :pedido_evento) == {:ok, V1_00.TCPedRegEvt}
    assert Nfse.Schema.root("1.00", :evento) == {:ok, V1_00.TCEvento}

    assert Nfse.Schema.root("1.02", :nfse) ==
             {:error, %Nfse.Error{kind: :unexpected, details: {:unsupported_version, "1.02"}}}
  end
end
