defmodule Nfse.CodecTest do
  use ExUnit.Case, async: true

  alias Nfse.Codec
  alias Nfse.Error

  test "round-trips a document through gzip and base64" do
    xml = ~s(<?xml version="1.0" encoding="UTF-8"?><DPS><x>Studio Ana ção</x></DPS>)

    packed = Codec.pack(xml)

    assert {:ok, ^xml} = Codec.unpack(packed)
    assert {:ok, ^xml} = Codec.unpack(Codec.pack([xml]))
  end

  test "refuses base64 that is not gzip" do
    assert {:error, %Error{kind: :unexpected}} = Codec.unpack(Base.encode64("not gzip at all"))
    assert {:error, %Error{kind: :unexpected}} = Codec.unpack("%%% not base64 %%%")
  end
end
