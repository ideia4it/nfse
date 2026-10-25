defmodule Nfse.SefinStub do
  @moduledoc false

  alias Nfse.{Certificate, Client}

  @pfx Path.expand("../fixtures/certificates/modern.pfx", __DIR__)

  def client(stub_name) do
    {:ok, certificate} = Certificate.from_pfx(File.read!(@pfx), "senha-de-teste")

    {:ok, client} =
      Client.new(
        certificate: certificate,
        environment: :restricted,
        req_options: [plug: {Req.Test, stub_name}, retry_delay: 0]
      )

    client
  end

  def count_calls do
    counter = :counters.new(1, [])
    {fn -> :counters.add(counter, 1, 1) end, fn -> :counters.get(counter, 1) end}
  end

  def fixture_xml(version),
    do:
      File.read!(
        Path.expand("../fixtures/nfse/nfse_v#{String.replace(version, ".", "_")}.xml", __DIR__)
      )

  def access_key, do: String.duplicate("2", 50)

  @doc "O XML de um evento de cancelamento como a Sefin o devolve, com o pedido assinado dentro."
  def event_xml(access_key) do
    {:ok, %{xml: request_xml}} =
      Nfse.PedidoEvento.build(
        %{
          ch_nfse: access_key,
          ver_aplic: "nfse-0.1.0",
          e101101: %{
            x_desc: "Cancelamento de NFS-e",
            c_motivo: 1,
            x_motivo: "Emitida com valor errado"
          }
        },
        client(:event_xml)
      )

    nested_request =
      String.replace(request_xml, ~s( xmlns="http://www.sped.fazenda.gov.br/nfse"), "",
        global: false
      )

    ~s(<evento xmlns="http://www.sped.fazenda.gov.br/nfse" versao="1.01">) <>
      ~s(<infEvento Id="EVT#{access_key}101101001">) <>
      "<verAplic>SefinNac_Pre_1.0.0</verAplic><ambGer>2</ambGer><nSeqEvento>1</nSeqEvento>" <>
      "<dhProc>2026-11-03T10:00:05-03:00</dhProc><nDFSe>77</nDFSe>" <>
      nested_request <>
      ~s(</infEvento><Signature xmlns="http://www.w3.org/2000/09/xmldsig#">) <>
      "<SignatureValue>AA==</SignatureValue></Signature></evento>"
  end
end
