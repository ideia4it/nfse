defmodule Nfse.Restricted.JourneyTest do
  use ExUnit.Case, async: false

  @moduletag :restricted
  @moduletag timeout: 600_000

  alias Nfse.{Error, Identifiers, RestrictedEnvironment}

  # A parametrização da produção restrita não espelha a de produção, e um serviço que o município
  # não administra volta com E0312. A jornada usa o primeiro da lista nacional (Anexo B v1.01,
  # sem os serviços que exigem obra, evento ou não incidência) que tem alíquota no município.
  @external_resource "test/restricted/servicos_nacionais.txt"
  @services "test/restricted/servicos_nacionais.txt" |> File.read!() |> String.split()

  setup_all do
    context = RestrictedEnvironment.fetch!()
    Map.put(context, :c_trib_nac, administered_service!(context))
  end

  defp administered_service!(%{client: client, c_loc_emi: c_loc_emi}) do
    Enum.find(@services, fn c_trib_nac ->
      match?({:ok, _rate}, Nfse.rate(client, c_loc_emi, c_trib_nac <> "000", brasilia_today()))
    end) ||
      raise "O município #{c_loc_emi} não administra nenhum dos #{length(@services)} serviços " <>
              "da lista nacional na produção restrita"
  end

  test "issues, confirms, fetches, cancels and distributes an invoice on the restricted environment",
       %{client: client} = context do
    assert {:ok, issued} = Nfse.issue(client, dps(context, "Ana Souza", 0))

    cancelling_afterwards(client, issued.access_key, fn ->
      assert issued.nfse.inf_nfse.dps.inf_dps.id == issued.dps_id
      assert_valid_check_digit(issued.access_key)
      assert_valid_check_digit(String.replace_prefix(issued.nfse.inf_nfse.id, "NFS", ""))

      assert {:ok, true} = Nfse.dps_issued?(client, issued.dps_id)
      assert {:ok, access_key} = Nfse.fetch_access_key(client, issued.dps_id)
      assert access_key == issued.access_key
      assert_valid_check_digit(access_key)
      assert {:ok, fetched} = Nfse.fetch(client, issued.access_key)
      assert fetched.xml == issued.xml

      assert {:ok, cancellation} = cancel_note(client, issued.access_key)
      assert cancellation.access_key == issued.access_key
      assert {:ok, event} = Nfse.fetch_event(client, issued.access_key, "101101", 1)
      assert event.access_key == issued.access_key

      assert eventually(fn ->
               client
               |> Nfse.stream_distribution(0)
               |> Enum.find(&(&1.access_key == issued.access_key))
             end)

      assert eventually(fn ->
               {:ok, events} = Nfse.events(client, issued.access_key)
               Enum.find(events, &(&1.event_type == "CANCELAMENTO"))
             end)
    end)
  end

  @tag :records_outcome
  test "records whether the Sefin accepts an emoji in the taker name",
       %{client: client} = context do
    result = Nfse.issue(client, dps(context, "Ana Souza \u{1F60A}", 1))

    assert match?({:ok, _}, result) or match?({:error, %Error{kind: :rejected}}, result)

    case result do
      {:ok, issued} ->
        IO.puts("EMOJI ACEITO: a Sefin emitiu a nota #{issued.access_key}; cancelando.")

        cancelling_afterwards(client, issued.access_key, fn ->
          assert {:ok, _event} = cancel_note(client, issued.access_key)
        end)

      {:error, %Error{messages: messages}} ->
        codes = Enum.map_join(messages, "; ", &"#{&1.code} #{&1.description} #{&1.complement}")
        IO.puts("EMOJI RECUSADO: #{codes}")
    end
  end

  # Quem chegou a emitir sempre cancela, mesmo se uma asserção falhar no meio, para que cada
  # execução não deixe nota viva na produção restrita.
  defp cancelling_afterwards(client, access_key, journey) do
    journey.()
  after
    unless Process.get({:cancelled, access_key}), do: cancel_leftover(client, access_key)
  end

  defp cancel_note(client, access_key) do
    with {:ok, _event} = cancelled <-
           Nfse.cancel(client, access_key, c_motivo: 1, x_motivo: "Teste da biblioteca nfse") do
      Process.put({:cancelled, access_key}, true)
      cancelled
    end
  end

  defp cancel_leftover(client, access_key) do
    case cancel_note(client, access_key) do
      {:ok, _event} ->
        :ok

      {:error, error} ->
        IO.puts(
          "NOTA SEM CANCELAR: cancele à mão a chave #{access_key} (#{Exception.message(error)})"
        )
    end
  end

  # O ADN recebe a nota e o cancelamento da Sefin de forma assíncrona: logo depois do cancelamento,
  # a distribuição e os eventos da chave ainda voltam vazios.
  defp eventually(find, attempts \\ 12)
  defp eventually(find, 1), do: find.()

  defp eventually(find, attempts) do
    with nil <- find.() do
      Process.sleep(10_000)
      eventually(find, attempts - 1)
    end
  end

  defp assert_valid_check_digit(access_key) do
    assert Identifiers.check_digit(String.slice(access_key, 0, 49)) == String.last(access_key)
  end

  defp dps(context, taker_name, offset) do
    %{
      client: client,
      c_loc_emi: c_loc_emi,
      taker_cpf: taker_cpf,
      provider_im: provider_im,
      c_trib_nac: c_trib_nac
    } = context

    %Nfse.DPS{
      dh_emi: DateTime.add(DateTime.utc_now(), -60),
      ver_aplic: "nfse-restrita",
      serie: "1",
      n_dps: System.os_time(:millisecond) + offset,
      d_compet: brasilia_today(),
      tp_emit: 1,
      c_loc_emi: c_loc_emi,
      prest: %{
        cnpj: client.certificate.cnpj,
        im: if(provider_im != "", do: provider_im),
        reg_trib: %{op_simp_nac: 3, reg_ap_trib_sn: 1, reg_esp_trib: 0}
      },
      toma: %{cpf: taker_cpf, x_nome: taker_name},
      serv: %{
        loc_prest: %{c_loc_prestacao: c_loc_emi},
        c_serv: %{
          c_trib_nac: c_trib_nac,
          x_desc_serv: "Serviço de teste da biblioteca nfse"
        }
      },
      valores: %{
        v_serv_prest: %{v_serv: Decimal.new("49.90")},
        trib: %{
          trib_mun: %{trib_issqn: 1, tp_ret_issqn: 1},
          tot_trib: %{p_tot_trib_sn: Decimal.new("6.00")}
        }
      }
    }
  end

  defp brasilia_today, do: DateTime.utc_now() |> DateTime.add(-3 * 3600) |> DateTime.to_date()
end
