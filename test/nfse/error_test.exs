defmodule Nfse.ErrorTest do
  use ExUnit.Case, async: true

  test "summarizes a rejection with every code the Sefin returned" do
    error = %Nfse.Error{
      kind: :rejected,
      status: 400,
      messages: [
        %{code: "E0234", description: "Endereço do tomador obrigatório", complement: nil},
        %{code: "E0921", description: "Município divergente", complement: "toma"}
      ]
    }

    message = Exception.message(error)
    assert message =~ "E0234"
    assert message =~ "E0921"
    assert message =~ "recusad"
  end

  test "points at the dps_id when a write got no answer" do
    error = %Nfse.Error{kind: :timeout, dps_id: "DPS" <> String.duplicate("1", 42)}
    assert Exception.message(error) =~ error.dps_id
  end

  test "only suggests conferring the DPS when the write outcome is uncertain" do
    dps_id = "DPS" <> String.duplicate("1", 42)

    for kind <- [:timeout, :transport, :server] do
      assert Exception.message(%Nfse.Error{kind: kind, dps_id: dps_id}) =~ "Confira"
    end

    message = Exception.message(%Nfse.Error{kind: :rejected, dps_id: dps_id})
    assert message =~ dps_id
    refute message =~ "Confira"
  end
end
