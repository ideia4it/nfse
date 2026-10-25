defmodule Nfse.Gen.EmitterTest do
  use ExUnit.Case, async: true

  alias Nfse.Gen.{Emitter, XsdReader}

  @mini_dir Path.expand("../../support/xsd", __DIR__)

  @moduletag :tmp_dir

  test "emits a struct in XSD order with the pt-BR doc table", %{tmp_dir: tmp_dir} do
    paths = @mini_dir |> XsdReader.read() |> Emitter.emit("1.01", tmp_dir)

    assert paths |> Enum.map(&Path.basename/1) |> Enum.sort() ==
             ["simple_types.ex", "tc_pessoa.ex", "tc_pessoa_itens.ex"]

    source = File.read!(Path.join(tmp_dir, "tc_pessoa.ex"))

    assert source =~ "defmodule Nfse.Schema.V1_01.TCPessoa do"
    assert source =~ "defstruct [:cnpj, :cpf, :x_nome, :end, :tipo, :itens, :signature, :id]"
    assert source =~ "| `x_nome` | `xNome` | `TSNome` | 1 | Nome ou razão social. |"

    assert source =~
             "| `cnpj` | `CNPJ` | `TSCNPJ` | 1, escolha 1 | Número do CNPJ do prestador. |"

    assert source =~ "Escolha 1: exatamente um entre `cnpj` e `cpf`."
    assert source =~ "| `itens` | `itens` | `Nfse.Schema.V1_01.TCPessoaItens` | 1 |"
    assert source =~ "| `end` | `end` | `TSNome` | 0..n |"

    assert source =~
             ~s(%Field{name: :x_nome, xml: "xNome", type: {:simple, "TSNome"}, min: 1, max: 1})

    assert source =~ ~s(%Field{name: :signature, xml: "Signature", type: :signature, min: 0)
    assert source =~ "def __schema__(:choices), do: [%{index: 0, min: 1}]"
  end

  test "marks generated files as not to be edited", %{tmp_dir: tmp_dir} do
    paths = @mini_dir |> XsdReader.read() |> Emitter.emit("1.01", tmp_dir)

    for path <- paths do
      [first_line | _rest] = path |> File.read!() |> String.split("\n")
      assert first_line == "# Gerado por `mix nfse.gen` a partir de mini.xsd. Não edite."
    end
  end

  test "keeps the XSD documentation literal even where Elixir would interpolate", %{
    tmp_dir: tmp_dir
  } do
    xsd_dir = Path.join(tmp_dir, "xsd")
    doc = ~S(Valor #{vServ} com \d e """ no meio, e 1.00|1.01.)

    write_xsd!(xsd_dir, """
    <xs:complexType name="TCNota">
      <xs:annotation><xs:documentation>#{doc}</xs:documentation></xs:annotation>
      <xs:sequence>
        <xs:element name="xObs" type="xs:string">
          <xs:annotation><xs:documentation>#{doc}</xs:documentation></xs:annotation>
        </xs:element>
      </xs:sequence>
    </xs:complexType>
    """)

    xsd_dir |> XsdReader.read() |> Emitter.emit("1.01", Path.join(tmp_dir, "out"))

    moduledoc =
      tmp_dir
      |> Path.join("out/tc_nota.ex")
      |> File.read!()
      |> Code.string_to_quoted!()
      |> moduledoc()

    assert moduledoc =~ ~S(Valor #{vServ} com \d e """ no meio, e 1.00|1.01.)
    assert moduledoc =~ ~S(| Valor #{vServ} com \d e """ no meio, e 1.00\|1.01. |)
  end

  test "keeps the minOccurs of a choice and of each branch as the XSD declares them", %{
    tmp_dir: tmp_dir
  } do
    write_xsd!(tmp_dir, """
    <xs:complexType name="TCEndereco">
      <xs:sequence>
        <xs:choice minOccurs="0">
          <xs:element name="endNac" type="xs:string"/>
          <xs:element name="endExt" type="xs:string" minOccurs="0"/>
        </xs:choice>
      </xs:sequence>
    </xs:complexType>
    """)

    tmp_dir |> XsdReader.read() |> Emitter.emit("1.01", Path.join(tmp_dir, "out"))
    source = File.read!(Path.join(tmp_dir, "out/tc_endereco.ex"))

    assert source =~ "def __schema__(:choices), do: [%{index: 0, min: 0}]"
    assert source =~ "| `end_nac` | `endNac` | `xs:string` | 1, escolha 1 |"
    assert source =~ "| `end_ext` | `endExt` | `xs:string` | 0..1, escolha 1 |"
    assert source =~ "Escolha 1: no máximo um entre `end_nac` e `end_ext`."
  end

  test "keeps the fiscal acronyms NFSe, DFSe, NFe and DFe as one word in field names", %{
    tmp_dir: tmp_dir
  } do
    write_xsd!(tmp_dir, """
    <xs:complexType name="TCRef">
      <xs:sequence>
        <xs:element name="infNFSe" type="xs:string"/>
        <xs:element name="chNFe" type="xs:string"/>
        <xs:element name="nDFSe" type="xs:string"/>
        <xs:element name="tipoChaveDFe" type="xs:string"/>
        <xs:element name="cMunNFSeMun" type="xs:string"/>
        <xs:element name="dFeNacional" type="xs:string"/>
      </xs:sequence>
    </xs:complexType>
    """)

    tmp_dir |> XsdReader.read() |> Emitter.emit("1.01", Path.join(tmp_dir, "out"))
    source = File.read!(Path.join(tmp_dir, "out/tc_ref.ex"))

    assert source =~
             "defstruct [:inf_nfse, :ch_nfe, :n_dfse, :tipo_chave_dfe, :c_mun_nfse_mun, :d_fe_nacional]"

    assert source =~ "| `inf_nfse` | `infNFSe` |"
    assert source =~ "| `ch_nfe` | `chNFe` |"
  end

  test "refuses two XSD names that collapse to the same field", %{tmp_dir: tmp_dir} do
    write_xsd!(tmp_dir, """
    <xs:complexType name="TCNome">
      <xs:sequence>
        <xs:element name="xNome" type="xs:string"/>
        <xs:element name="XNome" type="xs:string"/>
      </xs:sequence>
    </xs:complexType>
    """)

    assert_raise ArgumentError, ~r/TCNome.*xNome.*XNome.*x_nome/, fn ->
      tmp_dir |> XsdReader.read() |> Emitter.emit("1.01", Path.join(tmp_dir, "out"))
    end
  end

  for {construct, sequence} <- [
        {"a repeated choice",
         ~s(<xs:choice maxOccurs="2"><xs:element name="a" type="xs:string"/><xs:element name="b" type="xs:string"/></xs:choice>)},
        {"a built-in type it does not map", ~s(<xs:element name="qtd" type="xs:int"/>)}
      ] do
    test "refuses #{construct}, which the runtime cannot represent", %{tmp_dir: tmp_dir} do
      write_xsd!(tmp_dir, """
      <xs:complexType name="TCItem"><xs:sequence>#{unquote(sequence)}</xs:sequence></xs:complexType>
      """)

      assert_raise ArgumentError, ~r/não suportado/, fn ->
        tmp_dir |> XsdReader.read() |> Emitter.emit("1.01", Path.join(tmp_dir, "out"))
      end
    end
  end

  defp write_xsd!(dir, types) do
    File.mkdir_p!(dir)

    File.write!(Path.join(dir, "nota.xsd"), """
    <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
    #{types}
    </xs:schema>
    """)
  end

  defp moduledoc(quoted) do
    {_quoted, docs} =
      Macro.prewalk(quoted, [], fn
        {:@, _meta, [{:moduledoc, _attribute_meta, [doc]}]} = node, docs -> {node, [doc | docs]}
        node, docs -> {node, docs}
      end)

    [doc] = docs
    doc
  end
end
