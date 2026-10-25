defmodule Nfse.Schema.RuntimeTest do
  use ExUnit.Case, async: true

  alias Nfse.Schema.Runtime
  alias Nfse.SchemaFixtures.{Deducoes, Documento, Nota, Pessoa}

  @nota_id "DPS" <> "2927408" <> "2" <> "11222333000181" <> "00001" <> "000000000000042"
  @nfse_namespace "http://www.sped.fazenda.gov.br/nfse"

  test "casts nested maps into structs and integers into strings" do
    attrs =
      nota_attrs(%{
        serie: 1,
        toma: %{cpf: 52_998_224_725, x_nome: "Ana Souza", emails: ["ana@studioana.com.br"]}
      })

    assert {:ok, nota} = Runtime.new(Nota, attrs)
    assert nota.serie == "1"

    assert %Pessoa{cpf: "52998224725", x_nome: "Ana Souza", emails: ["ana@studioana.com.br"]} =
             nota.toma

    keyword_attrs =
      attrs
      |> Map.put(:toma,
        cpf: 52_998_224_725,
        x_nome: "Ana Souza",
        emails: ["ana@studioana.com.br"]
      )
      |> Map.to_list()

    assert Runtime.new(Nota, keyword_attrs) == {:ok, nota}
    assert Runtime.new(Nota, nota) == {:ok, nota}
  end

  test "refuses an unknown key with its path" do
    assert errors(Runtime.new(Nota, %{toma: %{cpf_: "1"}})) == [
             %{path: "toma.cpf_", error: :unknown_field}
           ]

    misplaced_value = toma_attrs(%{v_serv: Decimal.new("49.90")})

    assert errors(Runtime.new(Nota, misplaced_value)) == [
             %{path: "toma.v_serv", error: :unknown_field}
           ]

    assert errors(Runtime.new(Nota, Map.put(nota_attrs(), "serie", "1"))) == [
             %{path: "serie", error: :unknown_field}
           ]
  end

  test "returns every error at once with its path" do
    attrs = %{
      tp_amb: "3",
      serie: "123456",
      c_cib: "1234567",
      toma: %{x_nome: "Ana 😊", emails: ["ana@studioana.com.br", "😊"]}
    }

    assert errors(Runtime.new(Nota, attrs)) == [
             %{path: "id", error: :required},
             %{path: "tp_amb", error: :enumeration},
             %{path: "serie", error: :max_length},
             %{path: "dh_emi", error: :required},
             %{path: "d_compet", error: :required},
             %{path: "v_serv", error: :required},
             %{path: "c_cib", error: :length},
             %{path: "toma.x_nome", error: :pattern},
             %{path: "toma.emails[1]", error: :pattern},
             %{path: "toma", error: :choice}
           ]
  end

  test "refuses a value of the wrong shape as a type error" do
    assert errors(Runtime.new(Nota, nota_attrs(%{toma: "Ana Souza"}))) == [
             %{path: "toma", error: :type}
           ]

    assert errors(Runtime.new(Nota, toma_attrs(%{emails: "ana@studioana.com.br"}))) == [
             %{path: "toma.emails", error: :type}
           ]

    assert errors(Runtime.new(Nota, toma_attrs(%{x_nome: ["Ana Souza"]}))) == [
             %{path: "toma.x_nome", error: :type}
           ]
  end

  test "validates a struct built by hand without casting it" do
    {:ok, nota} = Runtime.new(Nota, nota_attrs())

    assert Runtime.validate(Nota, nota) == :ok

    assert errors(Runtime.validate(Nota, %{nota | serie: 1, toma: %{cpf: "52998224725"}})) == [
             %{path: "serie", error: :type},
             %{path: "toma", error: :type}
           ]
  end

  test "requires exactly one branch of a choice" do
    both = toma_attrs(%{cnpj: "11222333000181", cpf: "52998224725"})
    assert errors(Runtime.new(Nota, both)) == [%{path: "toma", error: :choice}]

    none = nota_attrs(%{toma: %{x_nome: "Ana Souza"}})
    assert errors(Runtime.new(Nota, none)) == [%{path: "toma", error: :choice}]

    assert {:ok, %Nota{toma: %Pessoa{cnpj: "11222333000181", cpf: nil}}} =
             Runtime.new(
               Nota,
               nota_attrs(%{toma: %{cnpj: "11222333000181", x_nome: "Studio Ana"}})
             )
  end

  test "refuses text outside Latin-1 in a TSString field" do
    for name <- ["Ana 😊", "Ana — Souza", "“Ana”", "Ana…"] do
      assert errors(Runtime.new(Nota, toma_attrs(%{x_nome: name}))) == [
               %{path: "toma.x_nome", error: :pattern}
             ]
    end

    latin1_bytes = "Jo" <> <<0xE3>> <> "o"

    assert errors(Runtime.new(Nota, toma_attrs(%{x_nome: latin1_bytes}))) == [
             %{path: "toma.x_nome", error: :type}
           ]

    assert errors(Runtime.new(Nota, toma_attrs(%{emails: ["ana😊@studioana.com.br"]}))) == [
             %{path: "toma.emails[0]", error: :pattern}
           ]

    assert {:ok, _nota} = Runtime.new(Nota, toma_attrs(%{x_nome: "João Ünica & Cia. ÿ"}))
  end

  test "enforces the inherited TSString pattern together with the type's own" do
    assert {:ok, _nota} = Runtime.new(Nota, toma_attrs(%{c_int: "A 1"}))

    for code <- [" A1", "Ç1"] do
      assert errors(Runtime.new(Nota, toma_attrs(%{c_int: code}))) == [
               %{path: "toma.c_int", error: :pattern}
             ]
    end
  end

  test "refuses an empty string instead of omitting it" do
    assert errors(Runtime.new(Nota, toma_attrs(%{fone: ""}))) == [
             %{path: "toma.fone", error: :pattern}
           ]

    assert {:ok, %Nota{toma: %Pessoa{fone: nil}}} = Runtime.new(Nota, toma_attrs(%{fone: nil}))
  end

  test "accepts the DPS series without the literal ^ and $ of the XSD" do
    assert {:ok, %Nota{serie: "1"}} = Runtime.new(Nota, nota_attrs(%{serie: "1"}))
    assert {:ok, %Nota{serie: "00001"}} = Runtime.new(Nota, nota_attrs(%{serie: "00001"}))

    assert errors(Runtime.new(Nota, nota_attrs(%{serie: "123456"}))) == [
             %{path: "serie", error: :max_length}
           ]

    assert errors(Runtime.new(Nota, nota_attrs(%{serie: "^1$"}))) == [
             %{path: "serie", error: :pattern}
           ]
  end

  test "writes decimals with exactly two places and never rounds" do
    assert {:ok, nota} = Runtime.new(Nota, nota_attrs(%{v_serv: Decimal.new("49.9")}))
    assert encode(Nota, nota) =~ "<vServ>49.90</vServ>"

    for {value, written} <- [
          {"0", "0.00"},
          {"49.900", "49.90"},
          {"-0", "0.00"},
          {"999999999999999.99", "999999999999999.99"}
        ] do
      assert {:ok, nota} = Runtime.new(Nota, nota_attrs(%{v_serv: Decimal.new(value)}))
      assert encode(Nota, nota) =~ "<vServ>#{written}</vServ>"
    end

    for {value, error} <- [
          {Decimal.new("49.905"), :fraction_digits},
          {Decimal.new("1E+15"), :integer_digits},
          {Decimal.new("-1.00"), :pattern},
          {49.9, :type}
        ] do
      assert errors(Runtime.new(Nota, nota_attrs(%{v_serv: value}))) == [
               %{path: "v_serv", error: error}
             ]
    end

    assert_raise ArgumentError, fn ->
      Runtime.encode(Nota, %{nota | v_serv: Decimal.new("49.905")}, "infNota", [])
    end

    Decimal.Context.with(%Decimal.Context{precision: 5}, fn ->
      assert {:ok, nota} = Runtime.new(Nota, nota_attrs(%{v_serv: Decimal.new("123456789.1")}))
      assert encode(Nota, nota) =~ "<vServ>123456789.10</vServ>"
    end)
  end

  test "writes the offset of the DateTime and never Z or fractions" do
    assert {:ok, utc} = Runtime.new(Nota, nota_attrs(%{dh_emi: ~U[2026-11-03 13:00:00.123Z]}))
    utc_xml = encode(Nota, utc)
    assert utc_xml =~ "<dhEmi>2026-11-03T13:00:00+00:00</dhEmi>"

    brasilia = %DateTime{
      year: 2026,
      month: 11,
      day: 3,
      hour: 10,
      minute: 0,
      second: 0,
      microsecond: {0, 0},
      utc_offset: -10_800,
      std_offset: 0,
      time_zone: "America/Bahia",
      zone_abbr: "-03"
    }

    assert {:ok, local} = Runtime.new(Nota, nota_attrs(%{dh_emi: brasilia}))
    local_xml = encode(Nota, local)
    assert local_xml =~ "<dhEmi>2026-11-03T10:00:00-03:00</dhEmi>"

    assert errors(Runtime.new(Nota, nota_attrs(%{dh_emi: ~N[2026-11-03 13:00:00]}))) == [
             %{path: "dh_emi", error: :type}
           ]

    assert {:ok, %Nota{dh_emi: ~U[2026-11-03 13:00:00Z]}} = decode(Nota, local_xml)

    assert errors(decode(Nota, String.replace(utc_xml, "+00:00", "Z"))) == [
             %{path: "dh_emi", error: :pattern}
           ]
  end

  test "writes in canonical form" do
    nota = %Nota{
      id: "DPS\"&<\t\n\r>",
      tp_amb: "2",
      serie: "1",
      dh_emi: ~U[2026-11-03 13:00:00Z],
      d_compet: ~D[2026-11-01],
      v_serv: Decimal.new("49.90"),
      toma: %Pessoa{cpf: "52998224725", x_nome: "a&b<c>\r", fone: ""}
    }

    assert encode(Nota, nota) ==
             ~s(<infNota Id="DPS&quot;&amp;&lt;&#x9;&#xA;&#xD;>">) <>
               "<tpAmb>2</tpAmb>" <>
               "<serie>1</serie>" <>
               "<dhEmi>2026-11-03T13:00:00+00:00</dhEmi>" <>
               "<dCompet>2026-11-01</dCompet>" <>
               "<vServ>49.90</vServ>" <>
               "<toma><CPF>52998224725</CPF><xNome>a&amp;b&lt;c&gt;&#xD;</xNome><fone></fone></toma>" <>
               "</infNota>"
  end

  test "treats an empty list as absent and requires at least one item in a required list" do
    assert {:ok, %Nota{toma: %Pessoa{emails: nil}}} = Runtime.new(Nota, toma_attrs(%{emails: []}))

    assert errors(Runtime.new(Nota, nota_attrs(%{deducoes: %{docs: []}}))) == [
             %{path: "deducoes.docs", error: :required}
           ]

    {:ok, nota} = Runtime.new(Nota, nota_attrs())

    assert errors(Runtime.validate(Nota, %{nota | deducoes: %Deducoes{docs: []}})) == [
             %{path: "deducoes.docs", error: :required}
           ]

    many = for number <- 1..50, do: "Recibo #{number}"
    assert {:ok, nota} = Runtime.new(Nota, nota_attrs(%{deducoes: %{docs: many}}))
    assert {:ok, ^nota} = decode(Nota, encode(Nota, nota))
  end

  test "refuses more occurrences than the XSD allows" do
    three = ["a@studioana.com.br", "b@studioana.com.br", "c@studioana.com.br"]
    assert {:ok, nota} = Runtime.new(Nota, toma_attrs(%{emails: three}))

    four = three ++ ["d@studioana.com.br"]

    assert errors(Runtime.new(Nota, toma_attrs(%{emails: four}))) == [
             %{path: "toma.emails", error: :occurrences}
           ]

    xml = encode(Nota, nota)

    four_in_xml = String.replace(xml, "</toma>", "<email>d@studioana.com.br</email></toma>")

    assert errors(decode(Nota, four_in_xml)) == [%{path: "toma.emails", error: :occurrences}]

    two_names = String.replace(xml, "</toma>", "<xNome>Ana</xNome></toma>")
    assert errors(decode(Nota, two_names)) == [%{path: "toma.x_nome", error: :occurrences}]
  end

  test "decodes what it encodes" do
    toma = %{
      cnpj: "11222333000181",
      x_nome: "Studio Ana & Cia <Salvador>",
      fone: "71999990000",
      emails: ["contato@studioana.com.br", "financeiro@studioana.com.br"],
      c_int: "A 1"
    }

    assert {:ok, nota} = Runtime.new(Nota, nota_attrs(%{v_serv: Decimal.new("49.9"), toma: toma}))
    assert {:ok, ^nota} = decode(Nota, encode(Nota, nota))
  end

  test "writes namespaces first, then attributes by name, and keeps the signature as it came" do
    signature =
      ~s(<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">) <>
        ~s(<SignedInfo><Reference URI="##{@nota_id}"><DigestValue>abc=</DigestValue></Reference></SignedInfo>) <>
        "<SignatureValue>def=</SignatureValue>" <>
        "<KeyInfo><X509Data><X509SubjectName>CN=Studio Ana &amp; Cia</X509SubjectName></X509Data></KeyInfo>" <>
        "</Signature>"

    {:ok, nota} = Runtime.new(Nota, nota_attrs())
    attrs = %{versao: "1.01", id: "CNC29274082123456789", inf_nota: nota, signature: signature}
    assert {:ok, documento} = Runtime.new(Documento, attrs)

    xml =
      Documento
      |> Runtime.encode(documento, "Documento", [{"xmlns", @nfse_namespace}])
      |> IO.iodata_to_binary()

    assert String.starts_with?(
             xml,
             ~s(<Documento xmlns="#{@nfse_namespace}" Id="CNC29274082123456789" versao="1.01">) <>
               ~s(<infNota Id="#{@nota_id}">)
           )

    assert String.ends_with?(xml, "</infNota>" <> signature <> "</Documento>")
    assert {:ok, ^documento} = decode(Documento, xml)

    {:ok, parsed_signature} = Saxy.SimpleForm.parse_string(signature)

    assert errors(Runtime.new(Documento, %{attrs | signature: parsed_signature})) == [
             %{path: "signature", error: :type}
           ]
  end

  test "reads XSD patterns as Unicode, with a dot that never matches a line break" do
    {:ok, nota} = Runtime.new(Nota, nota_attrs())
    attrs = %{versao: "1.01", id: "CNC29274082123456789", inf_nota: nota}

    for line_break <- ["\r", "\n"] do
      assert errors(Runtime.new(Documento, %{attrs | id: "CNC29274082" <> line_break})) == [
               %{path: "id", error: :pattern}
             ]
    end

    assert {:ok, _documento} = Runtime.new(Documento, %{attrs | id: "CNC29274082 A-1"})

    fifteen_characters = "CNC29274082" <> String.duplicate("ç", 15)
    assert {:ok, _documento} = Runtime.new(Documento, %{attrs | id: fifteen_characters})
  end

  test "refuses an element the type does not declare when decoding" do
    {:ok, nota} = Runtime.new(Nota, nota_attrs())
    xml = encode(Nota, nota)

    assert errors(decode(Nota, String.replace(xml, "</toma>", "<extra>1</extra></toma>"))) == [
             %{path: "toma.extra", error: :unknown_field}
           ]

    assert errors(decode(Nota, String.replace(xml, "<toma>", ~s(<toma origem="1">)))) == [
             %{path: "toma.origem", error: :unknown_field}
           ]

    attribute_in_text = String.replace(xml, "<xNome>", ~s(<xNome origem="1">))

    assert errors(decode(Nota, attribute_in_text)) == [
             %{path: "toma.x_nome.origem", error: :unknown_field}
           ]

    nested_in_text =
      String.replace(xml, "<xNome>Ana Souza</xNome>", "<xNome>Ana <b>Souza</b></xNome>")

    assert errors(decode(Nota, nested_in_text)) == [
             %{path: "toma.x_nome.b", error: :unknown_field}
           ]

    with_namespaces =
      xml
      |> String.replace(
        "<toma>",
        ~s(<toma xmlns="#{@nfse_namespace}" xmlns:ds="http://www.w3.org/2000/09/xmldsig#">)
      )
      |> String.replace("<xNome>", ~s(<xNome xmlns="#{@nfse_namespace}">))

    assert {:ok, ^nota} = decode(Nota, with_namespaces)
  end

  test "ignores indentation between elements and refuses stray text" do
    {:ok, nota} = Runtime.new(Nota, nota_attrs())

    indented = """
    <infNota Id="#{@nota_id}">
      <tpAmb>2</tpAmb>
      <serie>1</serie>
      <dhEmi>2026-11-03T13:00:00+00:00</dhEmi>
      <dCompet>2026-11-01</dCompet>
      <vServ>49.90</vServ>
      <toma>
        <CPF>52998224725</CPF>
        <xNome>Ana Souza</xNome>
      </toma>
    </infNota>
    """

    assert {:ok, ^nota} = decode(Nota, indented)

    assert errors(decode(Nota, String.replace(indented, "<toma>", "<toma>texto solto"))) == [
             %{path: "toma", error: :type}
           ]

    padded_name = String.replace(indented, "<xNome>Ana Souza", "<xNome> Ana Souza")

    assert errors(decode(Nota, padded_name)) == [%{path: "toma.x_nome", error: :pattern}]
  end

  test "refuses a date that only the comma in the official pattern lets through" do
    {:ok, nota} = Runtime.new(Nota, nota_attrs())
    xml = encode(Nota, nota)

    comma_month = String.replace(xml, "<dCompet>2026-11-01", "<dCompet>2026-0,-30")
    assert errors(decode(Nota, comma_month)) == [%{path: "d_compet", error: :type}]

    comma_offset = String.replace(xml, "13:00:00+00:00", "13:00:00,03:00")
    assert errors(decode(Nota, comma_offset)) == [%{path: "dh_emi", error: :type}]
  end

  test "refuses an exponent in a decimal before parsing it" do
    {:ok, nota} = Runtime.new(Nota, nota_attrs())
    xml = encode(Nota, nota)

    for written <- ["1E+999999999", "4.99E1", "49.9", "-49.90"] do
      with_value = String.replace(xml, "<vServ>49.90</vServ>", "<vServ>#{written}</vServ>")
      assert errors(decode(Nota, with_value)) == [%{path: "v_serv", error: :pattern}]
    end
  end

  defp nota_attrs(overrides \\ %{}) do
    Map.merge(
      %{
        id: @nota_id,
        tp_amb: "2",
        serie: "1",
        dh_emi: ~U[2026-11-03 13:00:00Z],
        d_compet: ~D[2026-11-01],
        v_serv: Decimal.new("49.90"),
        toma: %{cpf: "52998224725", x_nome: "Ana Souza"}
      },
      overrides
    )
  end

  defp toma_attrs(overrides) do
    nota_attrs(%{toma: Map.merge(%{cpf: "52998224725", x_nome: "Ana Souza"}, overrides)})
  end

  defp encode(module, struct) do
    module
    |> Runtime.encode(struct, "infNota", [])
    |> IO.iodata_to_binary()
  end

  defp decode(module, xml) do
    {:ok, element} = Saxy.SimpleForm.parse_string(xml)
    Runtime.decode(module, element)
  end

  defp errors(result) do
    assert {:error, %Nfse.Error{kind: :validation, details: details}} = result
    details
  end
end
