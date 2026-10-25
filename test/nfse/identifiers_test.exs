defmodule Nfse.IdentifiersTest do
  use ExUnit.Case, async: true

  alias Nfse.Identifiers

  test "builds the 45-character DPS id of a CNPJ issuer" do
    id = Identifiers.dps_id("2927408", {:cnpj, "11222333000181"}, "1", "42")

    assert id == "DPS" <> "2927408" <> "2" <> "11222333000181" <> "00001" <> "000000000000042"
    assert String.length(id) == 45
  end

  test "pads a CPF to 14 digits and marks it with 1" do
    assert Identifiers.dps_id("2927408", {:cpf, "52998224725"}, "1", "42") ==
             "DPS" <> "2927408" <> "1" <> "00052998224725" <> "00001" <> "000000000000042"
  end
end
