defmodule Nfse.PedidoEventoTest do
  use ExUnit.Case, async: true

  alias Nfse.{Error, PedidoEvento, SefinStub, Signature, Xmllint}

  @nfse "http://www.sped.fazenda.gov.br/nfse"
  @key SefinStub.access_key()

  setup context, do: %{client: SefinStub.client(context.test)}

  defp cancellation(overrides \\ %{}) do
    Map.merge(
      %{
        ch_nfse: @key,
        ver_aplic: "nfse-0.1.0",
        dh_evento: ~U[2026-11-03 13:00:00Z],
        e101101: %{
          x_desc: "Cancelamento de NFS-e",
          c_motivo: 1,
          x_motivo: "Emitida com valor errado"
        }
      },
      overrides
    )
  end

  test "builds a cancellation request with the PRE id, the certificate author and the environment",
       %{client: client} do
    assert {:ok, %{xml: xml, id: id}} = PedidoEvento.build(cancellation(), client)

    assert id == "PRE" <> @key <> "101101"
    assert byte_size(id) == 59

    assert String.starts_with?(
             xml,
             ~s(<pedRegEvento xmlns="#{@nfse}" versao="1.01"><infPedReg Id="#{id}">)
           )

    assert xml =~ "<tpAmb>2</tpAmb>"
    assert xml =~ "<CNPJAutor>#{client.certificate.cnpj}</CNPJAutor>"
    assert xml =~ "<xDesc>Cancelamento de NFS-e</xDesc>"
    Xmllint.validate!(xml, "test/support/xsd_patched/pedRegEvento_v1.01.xsd")

    [inf_ped_reg] = Regex.run(~r{<infPedReg .*</infPedReg>}, xml)
    signature = Signature.sign(inf_ped_reg, id, client.certificate, Signature.default_algorithm())

    assert xml ==
             ~s(<pedRegEvento xmlns="#{@nfse}" versao="1.01">) <>
               inf_ped_reg <> signature <> "</pedRegEvento>"
  end

  test "keeps the author and the event time the caller gives", %{client: client} do
    attrs = cancellation(%{cpf_autor: "52998224725"})

    assert {:ok, %{xml: xml}} = PedidoEvento.build(attrs, client)
    assert xml =~ "<CPFAutor>52998224725</CPFAutor>"
    refute xml =~ "CNPJAutor"
    assert xml =~ "<dhEvento>2026-11-03T13:00:00+00:00</dhEvento>"

    assert {:ok, %{xml: stamped}} =
             PedidoEvento.build(Map.delete(cancellation(), :dh_evento), client)

    assert stamped =~ ~r/<dhEvento>\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\+00:00<\/dhEvento>/
  end

  test "derives the event type from the filled element", %{client: client} do
    rejection = %{e203206: %{x_desc: "Manifestação de NFS-e - Rejeição do Tomador", c_motivo: 3}}

    attrs = cancellation() |> Map.delete(:e101101) |> Map.merge(rejection)

    assert {:ok, %{id: id}} = PedidoEvento.build(attrs, client)
    assert String.ends_with?(id, "203206")
  end

  test "refuses two events in one request", %{client: client} do
    both = Map.put(cancellation(), :e105102, %{})

    assert {:error, %Error{kind: :validation, details: details}} =
             PedidoEvento.build(both, client)

    assert Enum.any?(details, &(&1.error == :choice))
  end

  test "refuses a cancellation reason shorter than 15 characters before the network",
       %{client: client} do
    short = put_in(cancellation(), [:e101101, :x_motivo], "erro")

    assert {:error, %Error{kind: :validation, details: [detail]}} =
             PedidoEvento.build(short, client)

    assert %{path: "e101101.x_motivo", error: :min_length} = detail
  end

  test "refuses a tpAmb that contradicts the client and an id the caller chose",
       %{client: client} do
    assert {:error, %Error{kind: :validation, details: details}} =
             PedidoEvento.build(Map.merge(cancellation(), %{tp_amb: "1", id: "PRE"}), client)

    assert Enum.sort_by(details, & &1.path) == [
             %{path: "id", error: :unknown_field},
             %{path: "tp_amb", error: :environment}
           ]
  end

  test "returns every error before signing", %{client: client} do
    client_that_cannot_sign = put_in(client.certificate.key, :unusable)
    attrs = cancellation(%{ch_nfse: "123"})

    assert {:error, %Error{kind: :validation, details: [%{path: "ch_nfse"}]}} =
             PedidoEvento.build(attrs, client_that_cannot_sign)
  end
end
