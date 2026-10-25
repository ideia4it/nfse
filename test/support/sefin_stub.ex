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
end
