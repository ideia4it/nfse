defmodule Nfse.Schema.Runtime do
  @moduledoc """
  Conversão, validação, escrita canônica e leitura de qualquer tipo complexo do schema.

  Cada módulo gerado a partir do XSD guarda só o struct e o descritor. Este módulo lê o descritor e
  faz o resto, com as mesmas regras para todos os tipos.

  ## Contrato do módulo de schema

    * `__schema__(:version)`: a versão do leiaute, como `"1.01"`
    * `__schema__(:fields)`: os elementos, como `Nfse.Schema.Field`, na ordem do XSD
    * `__schema__(:attributes)`: os atributos, também como `Nfse.Schema.Field`
    * `__schema__(:choices)`: `%{index: índice, min: 0 | 1}` de cada `choice`, com o `minOccurs`
      dele
    * `__schema__(:simple_types)`: o módulo de tipos simples

  O módulo de tipos simples responde `facets(nome)`, com as facetas já achatadas (as da base
  primeiro, depois as do próprio tipo), e `kind(nome)`: `:string`, `:date`, `:datetime` ou
  `{:decimal, dígitos_inteiros, casas}`.

  ## Conversão

  `new/2` aceita mapa, lista de palavras-chave ou o próprio struct, também nos campos aninhados. As
  chaves são os átomos dos campos. Uma chave que o tipo não declara, inclusive em forma de string, é
  `:unknown_field`, e então a validação nem roda. Inteiro vira string num campo de texto, sem
  completar com zeros. Decimal passa a ter exatamente as casas do tipo (`49.9` vira `49.90`), sem
  arredondar. Lista vazia num campo repetido vale como campo ausente.

  ## Validação

  A ordem é obrigatoriedade, tipo, facetas, `choice` e ocorrências. Os erros voltam juntos em
  `details`, cada um com o caminho do campo, como `toma.emails[1]` (o índice começa em zero), ou
  `""` quando o erro é do próprio documento.

    * `:string` aceita só string UTF-8 válida com os caracteres que o XML 1.0 permite: tab, LF, CR e
      de U+0020 em diante, menos os substitutos e U+FFFE e U+FFFF. Isso vale também onde o XSD não
      tem `pattern`, e também na leitura. Espaço nunca é aparado, porque cada `whiteSpace` do
      pacote oficial é `preserve`, e string vazia é um valor, não ausência
    * um `choice` com dois ramos preenchidos é sempre erro. Sem ramo preenchido, só é erro quando o
      `choice` tem `min: 1` e cada ramo tem `min: 1`, porque um ramo opcional pode ser escolhido vazio
    * `:date` aceita só `Date`, e `:datetime` só `DateTime`
    * decimal aceita só `Decimal`; casas a mais são `:fraction_digits` e dígitos inteiros a mais são
      `:integer_digits`
    * as facetas valem sobre a forma escrita do valor, e cada `pattern` da lista precisa casar

  | Erro | Quando |
  |---|---|
  | `:unknown_field` | chave, elemento ou atributo que o tipo não declara |
  | `:required` | campo obrigatório ausente |
  | `:type` | valor de outro tipo, caractere que o XML proíbe, ou texto solto entre elementos |
  | `:length`, `:min_length`, `:max_length` | comprimento fora da faceta, em caracteres Unicode |
  | `:enumeration` | valor fora da lista do tipo |
  | `:pattern` | algum `pattern` do tipo não casa |
  | `:integer_digits`, `:fraction_digits` | decimal com dígitos inteiros ou casas a mais |
  | `:choice` | mais de um ramo de um `choice`, ou nenhum quando algum é obrigatório |
  | `:occurrences` | mais repetições do que o `maxOccurs` permite |

  ## Escrita

  `encode/4` escreve na forma canônica (C14N): os atributos extras, que são as declarações de
  namespace, saem primeiro, na ordem dada, e depois os atributos do struct, em ordem de nome. Não há
  espaço entre tags, elemento vazio sai `<x></x>` e nunca `<x/>`, campo ausente é omitido e o
  escaping é o de `Nfse.Schema.Xml`. Data e hora saem com o offset do próprio `DateTime`
  (`2026-11-03T10:00:00-03:00`), sem frações de segundo e nunca com `Z`. Decimal sai com exatamente
  as casas do tipo. A assinatura (`:signature`) sai como veio.

  `encode/4` espera um struct já validado e levanta `ArgumentError` diante de um valor que só daria
  para escrever arredondando ou truncando.

  ## Leitura

  `decode/2` lê a árvore do `Saxy.SimpleForm`. As facetas são conferidas no texto antes de qualquer
  conversão, o que mantém um decimal com expoente longe do `Decimal`. Data e hora voltam em UTC.
  Elemento ou atributo que o tipo não declara é `:unknown_field`, e `xmlns` e `xmlns:*` são
  ignorados. Espaço entre elementos (XML indentado) é ignorado, e texto de verdade nesse lugar é
  `:type`. A assinatura volta como o XML do elemento, escrito pelo `Saxy.encode!/1`. Depois da
  leitura, o documento passa pela mesma validação de `new/2`.

  ## Onde o runtime diverge do XSD

    * O padrão do `TSSerieDPS` é `^0{0,4}\\d{1,5}$`. No padrão XSD, `^` e `$` são caracteres
      literais, e o `xmllint` recusa a série `"1"` e aceita `"^1$"`. A intenção evidente é ancorar,
      e é o que se espera do validador da Sefin, ainda a confirmar na produção restrita. Por isso o
      runtime tira um `^` inicial e um `$` final antes de compilar o padrão.
    * Cada padrão vira uma regex `\\A(?:...)\\z` em Unicode, em que `[!-ÿ]` é a faixa de U+0021 a
      U+00FF, e o ponto não casa CR nem LF, como no XSD.
    * Os decimais não passam por `Decimal.round/2`, que segue a precisão do contexto do processo de
      quem chama. As contas são feitas direto sobre o coeficiente e o expoente.
  """

  alias Nfse.Error
  alias Nfse.Schema.{Field, SimpleType, Xml}

  @type attribute :: {String.t(), String.t()}

  @doc "Converte `attrs` no struct de `module` e valida o resultado."
  @spec new(module(), map() | keyword() | struct()) :: {:ok, struct()} | {:error, Error.t()}
  def new(module, attrs) do
    {value, cast_errors} = cast_complex(module, attrs, "")

    with :ok <- result(cast_errors),
         :ok <- validate(module, value) do
      {:ok, value}
    end
  end

  @doc "Valida um struct de `module` sem convertê-lo."
  @spec validate(module(), struct()) :: :ok | {:error, Error.t()}
  def validate(module, value) do
    module
    |> complex_errors(value, "")
    |> result()
  end

  @doc """
  Escreve o struct como o elemento `tag`, na forma canônica, com `extra_attributes` antes dos
  atributos do struct.
  """
  @spec encode(module(), struct(), String.t(), [attribute()]) :: iodata()
  def encode(module, %{__struct__: module} = struct, tag, extra_attributes) do
    simple_types = module.__schema__(:simple_types)
    own_attributes = written_attributes(simple_types, module.__schema__(:attributes), struct)

    content =
      Enum.map(
        module.__schema__(:fields),
        &write_field(simple_types, &1, Map.fetch!(struct, &1.name))
      )

    [
      ?<,
      tag,
      Enum.map(extra_attributes ++ own_attributes, &write_attribute/1),
      ?>,
      content,
      "</",
      tag,
      ?>
    ]
  end

  @doc "Lê o elemento como um struct de `module` e valida o resultado."
  @spec decode(module(), Saxy.SimpleForm.t()) :: {:ok, struct()} | {:error, Error.t()}
  def decode(module, element) do
    {value, read_errors} = read_complex(module, element, "")

    with :ok <- result(read_errors),
         :ok <- validate(module, value) do
      {:ok, value}
    end
  end

  defp result([]), do: :ok
  defp result(errors), do: {:error, %Error{kind: :validation, details: errors}}

  defp cast_complex(module, %{__struct__: module} = struct, path),
    do: cast_complex(module, Map.from_struct(struct), path)

  defp cast_complex(module, attrs, path) when is_map(attrs) and not is_struct(attrs) do
    {pairs, errors} =
      attrs
      |> Enum.map(&cast_entry(module, &1, path))
      |> merge()

    {struct(module, pairs), errors}
  end

  defp cast_complex(module, attrs, path) when is_list(attrs) do
    if Keyword.keyword?(attrs), do: cast_complex(module, Map.new(attrs), path), else: {attrs, []}
  end

  defp cast_complex(_module, value, _path), do: {value, []}

  defp cast_entry(module, {key, value}, path) do
    case Enum.find(declared_fields(module), &(&1.name == key)) do
      nil ->
        {[], [%{path: child_path(path, key_name(key)), error: :unknown_field}]}

      field ->
        simple_types = module.__schema__(:simple_types)
        {cast, errors} = cast_field(simple_types, field, value, field_path(path, field))
        {[{field.name, cast}], errors}
    end
  end

  defp cast_field(_simple_types, _field, nil, _path), do: {nil, []}

  defp cast_field(simple_types, %Field{max: 1} = field, value, path),
    do: cast_item(simple_types, field.type, value, path)

  defp cast_field(_simple_types, _field, [], _path), do: {nil, []}

  defp cast_field(simple_types, field, values, path) when is_list(values) do
    {items, errors} =
      values
      |> Enum.with_index()
      |> Enum.map(fn {item, index} ->
        cast_item(simple_types, field.type, item, item_path(path, index))
      end)
      |> Enum.unzip()

    {items, Enum.concat(errors)}
  end

  defp cast_field(_simple_types, _field, value, _path), do: {value, []}

  defp cast_item(simple_types, {:simple, type}, value, _path),
    do: {SimpleType.cast(simple_types, type, value), []}

  defp cast_item(_simple_types, {:complex, module}, value, path),
    do: cast_complex(module, value, path)

  defp cast_item(_simple_types, :signature, value, _path), do: {value, []}

  defp complex_errors(module, %{__struct__: module} = struct, path) do
    simple_types = module.__schema__(:simple_types)
    fields = declared_fields(module)

    Enum.flat_map(fields, &field_errors(simple_types, &1, Map.fetch!(struct, &1.name), path)) ++
      Enum.flat_map(module.__schema__(:choices), &choice_errors(&1, fields, struct, path)) ++
      Enum.flat_map(fields, &occurrence_errors(&1, Map.fetch!(struct, &1.name), path))
  end

  defp complex_errors(_module, _value, path), do: [%{path: path, error: :type}]

  defp field_errors(simple_types, field, value, parent_path) do
    path = field_path(parent_path, field)

    cond do
      absent?(field, value) -> missing_errors(field, path)
      field.max == 1 -> value_errors(simple_types, field.type, value, path)
      is_list(value) -> item_errors(simple_types, field.type, value, path)
      true -> [%{path: path, error: :type}]
    end
  end

  defp missing_errors(%Field{min: 1, choice: nil}, path), do: [%{path: path, error: :required}]
  defp missing_errors(_field, _path), do: []

  defp item_errors(simple_types, type, values, path) do
    values
    |> Enum.with_index()
    |> Enum.flat_map(fn {item, index} ->
      value_errors(simple_types, type, item, item_path(path, index))
    end)
  end

  defp value_errors(simple_types, {:simple, type}, value, path) do
    case SimpleType.validate(simple_types, type, value) do
      :ok -> []
      {:error, error} -> [%{path: path, error: error}]
    end
  end

  defp value_errors(_simple_types, {:complex, module}, value, path),
    do: complex_errors(module, value, path)

  defp value_errors(_simple_types, :signature, value, _path) when is_binary(value), do: []
  defp value_errors(_simple_types, :signature, _value, path), do: [%{path: path, error: :type}]

  defp choice_errors(%{index: index, min: min}, fields, struct, path) do
    branches = Enum.filter(fields, &(&1.choice == index))
    present = Enum.count(branches, &(not absent?(&1, Map.fetch!(struct, &1.name))))
    branch_required? = min == 1 and Enum.all?(branches, &(&1.min == 1))

    if present > 1 or (present == 0 and branch_required?),
      do: [%{path: path, error: :choice}],
      else: []
  end

  defp occurrence_errors(%Field{max: max} = field, values, parent_path)
       when is_integer(max) and max > 1 and is_list(values) and length(values) > max,
       do: [%{path: field_path(parent_path, field), error: :occurrences}]

  defp occurrence_errors(_field, _value, _parent_path), do: []

  defp absent?(_field, nil), do: true
  defp absent?(%Field{max: max}, []) when max != 1, do: true
  defp absent?(_field, _value), do: false

  defp written_attributes(simple_types, attribute_fields, struct) do
    attribute_fields
    |> Enum.reject(&is_nil(Map.fetch!(struct, &1.name)))
    |> Enum.map(fn %Field{type: {:simple, type}} = field ->
      {field.xml, SimpleType.to_lexical(simple_types, type, Map.fetch!(struct, field.name))}
    end)
    |> Enum.sort_by(fn {name, _value} -> name end)
  end

  defp write_attribute({name, value}), do: [?\s, name, "=\"", Xml.escape_attribute(value), ?"]

  defp write_field(_simple_types, _field, nil), do: []

  defp write_field(simple_types, %Field{max: 1} = field, value),
    do: write_value(simple_types, field, value)

  defp write_field(simple_types, field, values) when is_list(values),
    do: Enum.map(values, &write_value(simple_types, field, &1))

  defp write_value(simple_types, %Field{type: {:simple, type}, xml: xml}, value) do
    text = SimpleType.to_lexical(simple_types, type, value)
    [?<, xml, ?>, Xml.escape_text(text), "</", xml, ?>]
  end

  defp write_value(_simple_types, %Field{type: {:complex, module}, xml: xml}, value),
    do: encode(module, value, xml, [])

  defp write_value(_simple_types, %Field{type: :signature}, signature) when is_binary(signature),
    do: signature

  defp read_complex(module, {_tag, attributes, content}, path) do
    {attribute_pairs, attribute_errors} = read_attributes(module, attributes, path)
    {element_pairs, element_errors} = read_elements(module, content, path)
    {struct(module, attribute_pairs ++ element_pairs), attribute_errors ++ element_errors}
  end

  defp read_attributes(module, attributes, path) do
    simple_types = module.__schema__(:simple_types)
    fields = module.__schema__(:attributes)

    attributes
    |> Enum.reject(&namespace_declaration?/1)
    |> Enum.map(fn {name, text} ->
      case Enum.find(fields, &(&1.xml == name)) do
        nil -> {[], [unknown_field(path, name)]}
        field -> read_attribute(simple_types, field, text, path)
      end
    end)
    |> merge()
  end

  defp read_attribute(simple_types, %Field{type: {:simple, type}} = field, text, path) do
    {value, errors} = parse_text(simple_types, type, text, field_path(path, field))
    {[{field.name, value}], errors}
  end

  defp read_elements(module, content, path) do
    simple_types = module.__schema__(:simple_types)
    fields = module.__schema__(:fields)
    {texts, elements} = Enum.split_with(content, &text?/1)

    undeclared =
      for {name, _attributes, _content} <- elements,
          not Enum.any?(fields, &(&1.xml == name)),
          do: unknown_field(path, name)

    {pairs, field_errors} =
      fields
      |> Enum.map(&read_occurrences(simple_types, &1, occurrences(elements, &1), path))
      |> merge()

    {pairs, stray_text_errors(texts, path) ++ undeclared ++ field_errors}
  end

  defp occurrences(elements, %Field{xml: xml}),
    do: for({^xml, _attributes, _content} = element <- elements, do: element)

  defp read_occurrences(_simple_types, _field, [], _parent_path), do: {[], []}

  defp read_occurrences(simple_types, %Field{max: 1} = field, [element], parent_path) do
    {value, errors} =
      read_value(simple_types, field.type, element, field_path(parent_path, field))

    {[{field.name, value}], errors}
  end

  defp read_occurrences(_simple_types, %Field{max: 1} = field, _elements, parent_path),
    do: {[], [%{path: field_path(parent_path, field), error: :occurrences}]}

  defp read_occurrences(simple_types, field, elements, parent_path) do
    path = field_path(parent_path, field)

    {values, errors} =
      elements
      |> Enum.with_index()
      |> Enum.map(fn {element, index} ->
        read_value(simple_types, field.type, element, item_path(path, index))
      end)
      |> Enum.unzip()

    {[{field.name, values}], Enum.concat(errors)}
  end

  defp read_value(simple_types, {:simple, type}, {_name, attributes, content}, path) do
    {texts, elements} = Enum.split_with(content, &text?/1)

    undeclared =
      for(
        {name, _value} = attribute <- attributes,
        not namespace_declaration?(attribute),
        do: name
      ) ++
        for({name, _attributes, _content} <- elements, do: name)

    case undeclared do
      [] -> parse_text(simple_types, type, IO.iodata_to_binary(texts), path)
      names -> {nil, Enum.map(names, &unknown_field(path, &1))}
    end
  end

  defp read_value(_simple_types, {:complex, module}, element, path),
    do: read_complex(module, element, path)

  defp read_value(_simple_types, :signature, element, _path),
    do: {element |> encodable() |> Saxy.encode!(), []}

  defp parse_text(simple_types, type, text, path) do
    case SimpleType.parse(simple_types, type, text) do
      {:ok, value} -> {value, []}
      {:error, error} -> {nil, [%{path: path, error: error}]}
    end
  end

  defp stray_text_errors(texts, path) do
    if Enum.all?(texts, &blank?/1), do: [], else: [%{path: path, error: :type}]
  end

  # O Saxy escreve uma string solta no conteúdo sem escaping; {:characters, _} é escapado.
  defp encodable({name, attributes, content}),
    do: {name, attributes, Enum.map(content, &encodable/1)}

  defp encodable(text) when is_binary(text), do: {:characters, text}

  defp text?(text) when is_binary(text), do: true
  defp text?({_name, _attributes, _content}), do: false

  defp blank?(<<character, rest::binary>>) when character in ~c" \t\r\n", do: blank?(rest)
  defp blank?(rest), do: rest == ""

  defp namespace_declaration?({"xmlns", _value}), do: true
  defp namespace_declaration?({"xmlns:" <> _prefix, _value}), do: true
  defp namespace_declaration?(_attribute), do: false

  defp merge(readings) do
    {pairs, errors} = Enum.unzip(readings)
    {Enum.concat(pairs), Enum.concat(errors)}
  end

  defp declared_fields(module), do: module.__schema__(:attributes) ++ module.__schema__(:fields)

  defp unknown_field(path, name), do: %{path: child_path(path, name), error: :unknown_field}

  defp field_path(parent_path, %Field{name: name}),
    do: child_path(parent_path, Atom.to_string(name))

  defp child_path("", name), do: name
  defp child_path(parent_path, name), do: parent_path <> "." <> name

  defp item_path(path, index), do: "#{path}[#{index}]"

  defp key_name(key) when is_atom(key), do: Atom.to_string(key)
  defp key_name(key) when is_binary(key), do: key
end
