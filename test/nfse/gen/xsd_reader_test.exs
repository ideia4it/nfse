defmodule Nfse.Gen.XsdReaderTest do
  use ExUnit.Case, async: true

  alias Nfse.Gen.Model
  alias Nfse.Gen.Model.{Attribute, Element}
  alias Nfse.Gen.XsdReader

  @mini_dir Path.expand("../../support/xsd", __DIR__)
  @official_dir Path.expand("../../../priv/xsd/1.01", __DIR__)

  test "reads a sequence with a nested choice, an attribute and a signature ref" do
    %Model{complex: complex} = XsdReader.read(@mini_dir)
    pessoa = complex["TCPessoa"]

    assert [
             {:choice,
              %{min: 1, max: 1, elements: [%Element{name: "CNPJ"}, %Element{name: "CPF"}]}},
             {:element, %Element{name: "xNome", type: "TSNome", min: 1, max: 1}},
             {:element, %Element{name: "end", min: 0, max: :unbounded}},
             {:element, %Element{name: "tipo"}},
             {:element, %Element{name: "itens"}},
             {:element, %Element{name: "Signature", signature?: true, min: 0}}
           ] = pessoa.particles

    assert pessoa.attributes == [%Attribute{name: "Id", type: "TSNome", required?: true}]
    assert pessoa.file == "mini.xsd"
  end

  test "keeps the pt-BR documentation of every element" do
    %Model{complex: complex, simple: simple} = XsdReader.read(@mini_dir)
    [{:choice, %{elements: [cnpj, cpf]}}, {:element, x_nome} | _] = complex["TCPessoa"].particles

    assert cnpj.doc == "Número do CNPJ do prestador."
    assert cpf.doc == "Número do CPF do prestador."
    assert x_nome.doc == "Nome ou razão social."
    assert simple["TSNome"].doc == "Nome livre."
  end

  test "reads every facet kind of a simple type" do
    %Model{simple: simple} = XsdReader.read(@mini_dir)

    assert simple["TSNome"].facets == [
             {:min_length, 1},
             {:max_length, 150},
             {:pattern, "[!-ÿ]{1,150}"},
             {:white_space, "preserve"}
           ]

    assert simple["TSCNPJ"].facets == [{:length, 14}]
  end

  test "names anonymous types after their owner" do
    %Model{complex: complex, simple: simple} = XsdReader.read(@mini_dir)

    assert simple["TCPessoa.tipo"].facets == [
             {:white_space, "preserve"},
             {:enumeration, "Pessoa"}
           ]

    assert complex["TCPessoaItens"].particles == [
             {:element, %Element{name: "item", type: "TSNome", min: 1, max: 99}}
           ]

    {:element, tipo} = Enum.at(complex["TCPessoa"].particles, 3)
    assert tipo.anonymous_simple == simple["TCPessoa.tipo"]
  end

  test "reads the official 1.01 bundle whole" do
    model = XsdReader.read(@official_dir)

    named_types = 71 + 20 + 4
    anonymous_types = 1
    assert map_size(model.complex) == named_types + anonymous_types

    assert model.roots == %{
             "DPS" => "TCDPS",
             "NFSe" => "TCNFSe",
             "pedRegEvento" => "TCPedRegEvt",
             "evento" => "TCEvento",
             "CNC" => "TCNC"
           }

    assert {:pattern, "^0{0,4}\\d{1,5}$"} in model.simple["TSSerieDPS"].facets
    assert model.files["TCDPS"] == "tiposComplexos_v1.01.xsd"
    assert model.complex["TCNFSe"].file == "tiposComplexos_v1.01.xsd"
  end

  test "names the anonymous simple type of an official event after its owner" do
    model = XsdReader.read(@official_dir)

    assert {:enumeration, "Cancelamento de NFS-e"} in model.simple["TE101101.xDesc"].facets
    assert Map.has_key?(model.complex, "TCInfCNCContribuintesCnc")
  end

  for construct <- [
        ~s(<xs:group name="G"/>),
        ~s(<xs:complexType name="T"><xs:complexContent><xs:extension base="B"/></xs:complexContent></xs:complexType>)
      ] do
    @tag tmp_dir: true
    test "refuses a construct it does not understand: #{String.slice(construct, 0, 20)}", %{
      tmp_dir: tmp_dir
    } do
      File.write!(Path.join(tmp_dir, "unsupported.xsd"), """
      <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">#{unquote(construct)}</xs:schema>
      """)

      assert_raise ArgumentError, ~r/unsupported\.xsd/, fn -> XsdReader.read(tmp_dir) end
    end
  end
end
