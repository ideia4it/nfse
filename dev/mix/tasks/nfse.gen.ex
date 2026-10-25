defmodule Mix.Tasks.Nfse.Gen do
  @shortdoc "Gera os módulos de schema a partir dos XSDs oficiais"

  @moduledoc """
  Gera um módulo por tipo complexo do leiaute, mais o módulo de tipos simples de cada versão:
  `priv/xsd/1.00` vira `lib/nfse/schema/v1_00/` e `priv/xsd/1.01` vira `lib/nfse/schema/v1_01/`.

  O conteúdo dessas duas pastas é apagado antes de escrever. Os outros arquivos de
  `lib/nfse/schema/` são escritos à mão e ficam como estão.

  Cada campo tem o nome do XSD em snake_case, pelo `Macro.underscore/1`, com as siglas fiscais
  NFSe, DFSe, NFe e DFe contadas como uma palavra: `cLocEmi` vira `c_loc_emi`, `infNFSe`
  vira `inf_nfse` e `chNFe` vira `ch_nfe`. Dois nomes do mesmo tipo que dariam o mesmo campo param
  o gerador.

  A representação de cada tipo simples sai do nome dele: `TSDec<i>V<f>` vira `Decimal`, `TSData` e
  o `xs:date` usado direto num elemento viram `Date`, `TSDateTimeUTC` vira `DateTime` e o resto
  fica texto.

      mix nfse.gen
  """

  use Mix.Task

  alias Nfse.Gen.{Emitter, XsdReader}

  @targets [{"1.00", "lib/nfse/schema/v1_00"}, {"1.01", "lib/nfse/schema/v1_01"}]

  @impl Mix.Task
  def run(_args) do
    for {version, out_dir} <- @targets do
      File.rm_rf!(out_dir)

      paths =
        "priv/xsd"
        |> Path.join(version)
        |> XsdReader.read()
        |> Emitter.emit(version, out_dir)

      Mix.shell().info("#{length(paths)} arquivos gerados em #{out_dir}")
    end
  end
end
