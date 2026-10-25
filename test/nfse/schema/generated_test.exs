defmodule Nfse.Schema.GeneratedTest do
  use ExUnit.Case, async: true

  alias Nfse.Schema.V1_01.{TCBeneficioMunicipal, TCDPS, TCInfDPS}

  @fixtures_dir Path.expand("../../fixtures/nfse", __DIR__)
  @nfse_namespace "http://www.sped.fazenda.gov.br/nfse"

  test "builds a minimal DPS of a Simples Nacional provider that the official schema accepts" do
    {:ok, inf_dps} = TCInfDPS.new(studio_ana_inf_dps())
    {:ok, dps} = TCDPS.new(%{versao: "1.01", inf_dps: inf_dps})

    xml =
      dps
      |> TCDPS.encode("DPS", [{"xmlns", @nfse_namespace}])
      |> IO.iodata_to_binary()

    assert xml =~
             ~s(<DPS xmlns="#{@nfse_namespace}" versao="1.01"><infDPS Id="DPS2927408211222333000181)

    assert xml =~ "<cTribNac>010401</cTribNac><xDescServ>Corte de cabelo</xDescServ>"
    assert xml =~ "<vServ>49.90</vServ>"

    Nfse.Xmllint.validate!(xml, "test/support/xsd_patched/DPS_v1.01.xsd")
  end

  test "reads an NFS-e in both versions" do
    for {file, xsd, module} <- [
          {"nfse_v1_00.xml", "priv/xsd/1.00/NFSe_v1.00.xsd", Nfse.Schema.V1_00.TCNFSe},
          {"nfse_v1_01.xml", "test/support/xsd_patched/NFSe_v1.01.xsd", Nfse.Schema.V1_01.TCNFSe}
        ] do
      xml = @fixtures_dir |> Path.join(file) |> File.read!()
      Nfse.Xmllint.validate!(xml, xsd)

      {:ok, {"NFSe", attributes, _content} = element} = Saxy.SimpleForm.parse_string(xml)

      {"versao", version} = List.keyfind(attributes, "versao", 0)
      assert {:ok, ^module} = Nfse.Schema.root(version, :nfse)

      assert {:ok, nfse} = module.decode(element)
      assert nfse.__struct__ == module
      assert nfse.inf_nfse.n_nfse == "42"
      assert nfse.inf_nfse.emit.x_nome == "Studio Ana"
      assert nfse.inf_nfse.dps.inf_dps.valores.v_serv_prest.v_serv == Decimal.new("49.90")
      assert nfse.signature =~ "<SignatureValue>"
    end
  end

  test "refuses text outside Latin-1 in a field whose type derives from TSString" do
    attrs = Map.put(studio_ana_inf_dps(), :ver_aplic, "nfse 😊")

    assert {:error,
            %Nfse.Error{kind: :validation, details: [%{path: "ver_aplic", error: :pattern}]}} =
             TCInfDPS.new(attrs)
  end

  test "accepts a municipal benefit with no reduction, whose choice branches the XSD makes optional" do
    assert {:ok, _benefit} = TCBeneficioMunicipal.new(%{n_bm: "29274080100001"})

    assert {:error, %Nfse.Error{details: [%{path: "", error: :choice}]}} =
             TCBeneficioMunicipal.new(%{
               n_bm: "29274080100001",
               v_red_bcbm: Decimal.new("10"),
               p_red_bcbm: Decimal.new("5")
             })
  end

  test "documents every field from the XSD" do
    {:docs_v1, _anno, :elixir, _format, %{"en" => moduledoc}, _metadata, _docs} =
      Code.fetch_docs(TCInfDPS)

    assert moduledoc =~ "Data e hora da emissão do DPS"

    for field <- TCInfDPS.__schema__(:fields) ++ TCInfDPS.__schema__(:attributes) do
      assert moduledoc =~ "| `#{field.name}` | `#{field.xml}`"
    end
  end

  defp studio_ana_inf_dps do
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
        c_serv: %{c_trib_nac: "010401", x_desc_serv: "Corte de cabelo"}
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
end
