defmodule Nfse.SchemaFixtures.SimpleTypes do
  @moduledoc false

  def facets("TVerNFSe"),
    do: [max_length: 4, white_space: "preserve", pattern: ~S"1\.00|1\.01"]

  def facets("TSIdCNC"),
    do: [white_space: "preserve", max_length: 26, pattern: "CNC[0-9]{8}.{1,15}"]

  def facets("TSIdDPS"),
    do: [white_space: "preserve", max_length: 45, pattern: "DPS[0-9]{42}"]

  def facets("TSTipoAmbiente"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2"]

  def facets("TSCodCIB"), do: [white_space: "preserve", length: 8]

  def facets("TSSerieDPS"),
    do: [max_length: 5, pattern: ~S"^0{0,4}\d{1,5}$", white_space: "preserve"]

  def facets("TSDateTimeUTC"),
    do: [
      white_space: "preserve",
      pattern:
        ~S"(((20(([02468][048])|([13579][26]))-02-29))|(20[0-9][0-9])-((((0[1-9])|(1[0-2]))-((0[1-9])|(1\d)|(2[0-8])))|((((0[13578])|(1[02]))-31)|(((0[1,3-9])|(1[0-2]))-(29|30)))))T(20|21|22|23|[0-1]\d):[0-5]\d:[0-5]\d([\-,\+](0[0-9]|10|11):00|([\+](12):00))"
    ]

  def facets("TSData"),
    do: [
      white_space: "preserve",
      pattern:
        ~S"(((20(([02468][048])|([13579][26]))-02-29))|(20[0-9][0-9])-((((0[1-9])|(1[0-2]))-((0[1-9])|(1\d)|(2[0-8])))|((((0[13578])|(1[02]))-31)|(((0[1,3-9])|(1[0-2]))-(29|30)))))"
    ]

  def facets("TSDec15V2"),
    do: [white_space: "preserve", pattern: ~S"0|0\.[0-9]{2}|[1-9]{1}[0-9]{0,14}(\.[0-9]{2})?"]

  def facets("TSCNPJ"),
    do: [white_space: "preserve", max_length: 14, pattern: "[0-9]{14}"]

  def facets("TSCPF"),
    do: [white_space: "preserve", max_length: 11, pattern: "[0-9]{11}"]

  def facets("TSString"),
    do: [white_space: "preserve", pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}"]

  def facets("TSTelefone"),
    do: [white_space: "preserve", pattern: "[0-9]{6,20}"]

  def facets("TSEmail"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      white_space: "preserve",
      min_length: 1,
      max_length: 80
    ]

  # Inventado para o teste: os derivados oficiais com padrão próprio só aceitam o que o TSString
  # já aceita, e assim não provariam que o padrão herdado também é exigido.
  def facets("TSCodigoInternoComEspaco"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 20,
      pattern: "[a-zA-Z0-9 ]{1,20}"
    ]

  def kind("TSDateTimeUTC"), do: :datetime
  def kind("TSData"), do: :date
  def kind("TSDec15V2"), do: {:decimal, 15, 2}
  def kind(_name), do: :string
end

defmodule Nfse.SchemaFixtures.Pessoa do
  @moduledoc false

  alias Nfse.Schema.Field

  defstruct [:cnpj, :cpf, :x_nome, :fone, :emails, :c_int]

  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: Nfse.SchemaFixtures.SimpleTypes
  def __schema__(:attributes), do: []
  def __schema__(:choices), do: [%{index: 0, min: 1}]

  def __schema__(:fields) do
    [
      %Field{name: :cnpj, xml: "CNPJ", type: {:simple, "TSCNPJ"}, min: 1, max: 1, choice: 0},
      %Field{name: :cpf, xml: "CPF", type: {:simple, "TSCPF"}, min: 1, max: 1, choice: 0},
      %Field{name: :x_nome, xml: "xNome", type: {:simple, "TSString"}, min: 1, max: 1},
      %Field{name: :fone, xml: "fone", type: {:simple, "TSTelefone"}, min: 0, max: 1},
      %Field{name: :emails, xml: "email", type: {:simple, "TSEmail"}, min: 0, max: 3},
      %Field{
        name: :c_int,
        xml: "cInt",
        type: {:simple, "TSCodigoInternoComEspaco"},
        min: 0,
        max: 1
      }
    ]
  end
end

defmodule Nfse.SchemaFixtures.Deducoes do
  @moduledoc false

  alias Nfse.Schema.Field

  defstruct [:docs]

  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: Nfse.SchemaFixtures.SimpleTypes
  def __schema__(:attributes), do: []
  def __schema__(:choices), do: []

  def __schema__(:fields) do
    [%Field{name: :docs, xml: "doc", type: {:simple, "TSString"}, min: 1, max: :unbounded}]
  end
end

defmodule Nfse.SchemaFixtures.Nota do
  @moduledoc false

  alias Nfse.Schema.Field

  defstruct [:id, :tp_amb, :serie, :dh_emi, :d_compet, :v_serv, :c_cib, :toma, :deducoes]

  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: Nfse.SchemaFixtures.SimpleTypes
  def __schema__(:choices), do: []

  def __schema__(:attributes) do
    [%Field{name: :id, xml: "Id", type: {:simple, "TSIdDPS"}, min: 1, max: 1}]
  end

  def __schema__(:fields) do
    [
      %Field{name: :tp_amb, xml: "tpAmb", type: {:simple, "TSTipoAmbiente"}, min: 1, max: 1},
      %Field{name: :serie, xml: "serie", type: {:simple, "TSSerieDPS"}, min: 1, max: 1},
      %Field{name: :dh_emi, xml: "dhEmi", type: {:simple, "TSDateTimeUTC"}, min: 1, max: 1},
      %Field{name: :d_compet, xml: "dCompet", type: {:simple, "TSData"}, min: 1, max: 1},
      %Field{name: :v_serv, xml: "vServ", type: {:simple, "TSDec15V2"}, min: 1, max: 1},
      %Field{name: :c_cib, xml: "cCIB", type: {:simple, "TSCodCIB"}, min: 0, max: 1},
      %Field{
        name: :toma,
        xml: "toma",
        type: {:complex, Nfse.SchemaFixtures.Pessoa},
        min: 0,
        max: 1
      },
      %Field{
        name: :deducoes,
        xml: "deducoes",
        type: {:complex, Nfse.SchemaFixtures.Deducoes},
        min: 0,
        max: 1
      }
    ]
  end
end

defmodule Nfse.SchemaFixtures.Documento do
  @moduledoc false

  alias Nfse.Schema.Field

  defstruct [:versao, :id, :inf_nota, :signature]

  def __schema__(:version), do: "1.01"
  def __schema__(:simple_types), do: Nfse.SchemaFixtures.SimpleTypes
  def __schema__(:choices), do: []

  def __schema__(:attributes) do
    [
      %Field{name: :versao, xml: "versao", type: {:simple, "TVerNFSe"}, min: 1, max: 1},
      %Field{name: :id, xml: "Id", type: {:simple, "TSIdCNC"}, min: 0, max: 1}
    ]
  end

  def __schema__(:fields) do
    [
      %Field{
        name: :inf_nota,
        xml: "infNota",
        type: {:complex, Nfse.SchemaFixtures.Nota},
        min: 1,
        max: 1
      },
      %Field{name: :signature, xml: "Signature", type: :signature, min: 0, max: 1}
    ]
  end
end
