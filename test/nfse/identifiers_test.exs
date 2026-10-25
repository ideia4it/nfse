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

  test "computes the module 11 check digit of an access key" do
    # 1 x 2 + 3 x 3 = 11, resto 0
    assert Identifiers.check_digit("31") == "0"
    # 6 x 2 = 12, resto 1
    assert Identifiers.check_digit("6") == "0"
    # 3 x 2 + 2 x 3 + 1 x 4 = 16, resto 5, DV 11 - 5
    assert Identifiers.check_digit("123") == "6"
    # O nono dígito da direita volta ao peso 2: 1 x 2 = 2, resto 2, DV 11 - 2
    assert Identifiers.check_digit("100000000") == "9"
  end

  test "builds the 53-character NFS-e id from its parts" do
    key =
      Identifiers.access_key("2927408", "2", {:cnpj, "11222333000181"}, "1", "2611", "123456789")

    # Soma ponderada dos 49 dígitos: 604, resto 10, DV 11 - 10
    assert key ==
             "2927408" <>
               "2" <> "2" <> "11222333000181" <> "0000000000001" <> "2611" <> "123456789" <> "1"

    assert String.length("NFS" <> key) == 53

    assert Identifiers.access_key(
             "2927408",
             "2",
             {:cpf, "52998224725"},
             "42",
             "2611",
             "000000001"
           ) =~
             ~r/^2927408 2 1 00052998224725 0000000000042 2611 000000001 \d$/x
  end
end
