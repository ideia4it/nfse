defmodule Nfse.DpsFixtures do
  @moduledoc false

  @doc "Os campos de uma DPS mínima da Studio Ana, prestadora do Simples Nacional em Salvador."
  def studio_ana_inf_dps do
    %{
      id: "DPS292740821122233300018100001000000000000042",
      tp_amb: 2,
      dh_emi: ~U[2026-11-03 13:00:00Z],
      ver_aplic: "nfse-0.1.0",
      serie: "1",
      n_dps: 42,
      d_compet: ~D[2026-11-03],
      tp_emit: 1,
      c_loc_emi: "2927408",
      prest: %{
        cnpj: "11222333000181",
        reg_trib: %{op_simp_nac: 3, reg_ap_trib_sn: 1, reg_esp_trib: 0}
      },
      toma: %{cpf: "52998224725", x_nome: "Ana Souza"},
      serv: %{
        loc_prest: %{c_loc_prestacao: "2927408"},
        c_serv: %{c_trib_nac: "060101", x_desc_serv: "Corte de cabelo"}
      },
      valores: %{
        v_serv_prest: %{v_serv: Decimal.new("49.9")},
        trib: %{
          trib_mun: %{trib_issqn: 1, tp_ret_issqn: 1},
          tot_trib: %{p_tot_trib_sn: Decimal.new("6")}
        }
      }
    }
  end

  @doc "A mesma DPS como quem emite a preenche: sem `Id` nem `tpAmb`, que `Nfse.DPS` calcula."
  def studio_ana_dps, do: Map.drop(studio_ana_inf_dps(), [:id, :tp_amb])
end
