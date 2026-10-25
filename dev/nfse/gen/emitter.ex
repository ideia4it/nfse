defmodule Nfse.Gen.Emitter do
  @moduledoc false

  alias Nfse.Gen.Model
  alias Nfse.Gen.Model.{Attribute, ComplexType, Element, SimpleType}

  @builtin_kinds %{"xs:string" => :string, "xs:date" => :date}
  @decimal_name ~r/^TSDec(\d+)V(\d+)$/
  @inspect_options [limit: :infinity, printable_limit: :infinity]
  @signature_doc "Assinatura digital XMLDSig do documento, guardada como o XML do elemento."

  def emit(%Model{} = model, version, out_dir) do
    context = %{model: model, version: version, namespace: namespace(version)}

    complex_sources =
      model.complex
      |> Map.values()
      |> Enum.sort_by(& &1.name)
      |> Enum.map(&complex_source(context, &1))

    File.mkdir_p!(out_dir)

    Enum.map([simple_types_source(context) | complex_sources], fn {file_name, source} ->
      path = Path.join(out_dir, file_name)

      # Dois tipos cujos nomes viram o mesmo arquivo param aqui, em vez de um sobrescrever o outro.
      File.write!(path, [Code.format_string!(source), ?\n], [:exclusive])
      path
    end)
  end

  defp namespace(version), do: "Nfse.Schema.V" <> String.replace(version, ".", "_")

  defp complex_source(context, %ComplexType{} = complex_type) do
    fields = element_fields(context, complex_type) ++ attribute_fields(context, complex_type)
    refuse_colliding_fields!(complex_type, fields)
    choices = choices(complex_type)
    {element_fields, attribute_fields} = Enum.split_with(fields, &(not &1.attribute?))

    doc =
      moduledoc([
        complex_type.doc,
        origin(context, complex_type),
        field_table(context, fields),
        choice_notes(choices, fields)
      ])

    struct_keys = Enum.map_join(fields, ", ", &(":" <> &1.name))
    type_entries = Enum.map_join(fields, ", ", &field_spec(context, &1))
    attribute_literals = Enum.map_join(attribute_fields, ", ", &field_literal/1)
    field_literals = Enum.map_join(element_fields, ", ", &field_literal/1)

    source = ~s'''
    #{header([complex_type.file])}
    defmodule #{context.namespace}.#{complex_type.name} do
      @moduledoc """
    #{doc}
      """

      alias Nfse.Schema.{Field, Runtime}
      alias #{context.namespace}.#{aliases(fields)}

      defstruct [#{struct_keys}]

      @type t :: %__MODULE__{#{type_entries}}

      @doc false
      def __schema__(:version), do: #{inspect(context.version)}
      def __schema__(:simple_types), do: SimpleTypes
      def __schema__(:choices), do: #{inspect(choices)}
      def __schema__(:attributes), do: [#{attribute_literals}]
      def __schema__(:fields), do: [#{field_literals}]

      @doc """
      Converte `attrs` (mapa, lista de palavras-chave ou o próprio struct, também nos campos
      aninhados) neste struct e valida o resultado. As regras estão em `Nfse.Schema.Runtime`.
      """
      @spec new(map() | keyword() | t()) :: {:ok, t()} | {:error, Nfse.Error.t()}
      def new(attrs), do: Runtime.new(__MODULE__, attrs)

      @doc "Valida o struct contra o XSD e devolve cada erro com o caminho do campo."
      @spec validate(t()) :: :ok | {:error, Nfse.Error.t()}
      def validate(struct), do: Runtime.validate(__MODULE__, struct)

      @doc """
      Escreve o struct já validado como o elemento `tag`, na forma canônica. Os `extra_attributes`,
      como as declarações de namespace, saem antes dos atributos do struct.
      """
      @spec encode(t(), String.t(), [Runtime.attribute()]) :: iodata()
      def encode(struct, tag, extra_attributes \\\\ []),
        do: Runtime.encode(__MODULE__, struct, tag, extra_attributes)

      @doc "Lê o elemento, na árvore do `Saxy.SimpleForm`, como este struct e valida o resultado."
      @spec decode(Saxy.SimpleForm.t()) :: {:ok, t()} | {:error, Nfse.Error.t()}
      def decode(element), do: Runtime.decode(__MODULE__, element)
    end
    '''

    {Macro.underscore(complex_type.name) <> ".ex", source}
  end

  defp element_fields(context, %ComplexType{particles: particles}) do
    {fields, _choice_count} =
      Enum.flat_map_reduce(particles, 0, fn
        {:element, element}, choice_index ->
          {[element_field(context, element, nil)], choice_index}

        {:choice, %{elements: elements}}, choice_index ->
          {Enum.map(elements, &element_field(context, &1, choice_index)), choice_index + 1}
      end)

    fields
  end

  defp element_field(_context, %Element{signature?: true} = element, choice) do
    %{
      name: "signature",
      xml: "Signature",
      type: :signature,
      min: element.min,
      max: element.max,
      choice: choice,
      doc: @signature_doc,
      attribute?: false
    }
  end

  defp element_field(context, %Element{} = element, choice) do
    %{
      name: Macro.underscore(element.name),
      xml: element.name,
      type: field_type(context, element.type),
      min: element.min,
      max: element.max,
      choice: choice,
      doc: element.doc,
      attribute?: false
    }
  end

  defp attribute_fields(context, %ComplexType{attributes: attributes}) do
    Enum.map(attributes, fn %Attribute{} = attribute ->
      %{
        name: Macro.underscore(attribute.name),
        xml: attribute.name,
        type: field_type(context, attribute.type),
        min: if(attribute.required?, do: 1, else: 0),
        max: 1,
        choice: nil,
        doc: nil,
        attribute?: true
      }
    end)
  end

  # Um tipo desconhecido para o gerador em derivation/2, quando o @type do campo é escrito.
  defp field_type(%{model: model}, type_name) do
    if Map.has_key?(model.complex, type_name),
      do: {:complex, type_name},
      else: {:simple, type_name}
  end

  defp refuse_colliding_fields!(%ComplexType{} = complex_type, fields) do
    for {name, [_first, _second | _rest] = colliding} <- Enum.group_by(fields, & &1.name) do
      xml_names = colliding |> Enum.map(& &1.xml) |> sentence_list()

      raise ArgumentError,
            "#{complex_type.file}: no tipo #{complex_type.name}, #{xml_names} viram o mesmo " <>
              "campo #{name}"
    end
  end

  # O runtime representa um choice como campos irmãos, preenchidos no máximo uma vez.
  defp choices(%ComplexType{} = complex_type) do
    complex_type.particles
    |> Enum.filter(&match?({:choice, _choice}, &1))
    |> Enum.with_index()
    |> Enum.map(fn
      {{:choice, %{min: min, max: 1}}, index} ->
        %{index: index, min: min}

      {{:choice, %{max: max}}, _index} ->
        raise ArgumentError,
              "#{complex_type.file}: no tipo #{complex_type.name}, choice com maxOccurs " <>
                "#{max} não suportado"
    end)
  end

  defp aliases(fields) do
    complex_names = for %{type: {:complex, name}} <- fields, do: name

    case Enum.sort_by(Enum.uniq(["SimpleTypes" | complex_names]), &String.downcase/1) do
      [single] -> single
      names -> "{" <> Enum.join(names, ", ") <> "}"
    end
  end

  defp field_spec(context, field) do
    value_spec =
      case field.type do
        {:simple, name} -> context.model |> kind(name) |> kind_spec()
        {:complex, name} -> name <> ".t()"
        :signature -> "String.t()"
      end

    list_spec = if field.max == 1, do: value_spec, else: "[#{value_spec}]"
    "#{field.name}: #{list_spec} | nil"
  end

  defp kind_spec(:string), do: "String.t()"
  defp kind_spec(:date), do: "Date.t()"
  defp kind_spec(:datetime), do: "DateTime.t()"
  defp kind_spec({:decimal, _integer_digits, _fraction_digits}), do: "Decimal.t()"

  defp field_literal(field) do
    entries =
      [
        name: ":" <> field.name,
        xml: inspect(field.xml),
        type: type_literal(field.type),
        min: inspect(field.min),
        max: inspect(field.max)
      ] ++ if(field.choice, do: [choice: inspect(field.choice)], else: [])

    "%Field{" <> Enum.map_join(entries, ", ", fn {key, value} -> "#{key}: #{value}" end) <> "}"
  end

  defp type_literal({:simple, name}), do: "{:simple, #{inspect(name)}}"
  defp type_literal({:complex, name}), do: "{:complex, #{name}}"
  defp type_literal(:signature), do: ":signature"

  defp origin(context, %ComplexType{} = complex_type),
    do: "Tipo `#{complex_type.name}` do leiaute #{context.version}, em `#{complex_type.file}`."

  defp field_table(context, fields) do
    rows =
      Enum.map(fields, fn field ->
        table_row([
          "`#{field.name}`",
          xml_cell(field),
          type_cell(context, field.type),
          occurrence_cell(field),
          table_text(field.doc || "")
        ])
      end)

    Enum.join(
      [
        table_row(["Campo", "XML", "Tipo", "Ocorrência", "Descrição"]),
        "|---|---|---|---|---|" | rows
      ],
      "\n"
    )
  end

  defp table_row(cells), do: "| " <> Enum.join(cells, " | ") <> " |"

  defp xml_cell(%{attribute?: true, xml: xml}), do: "`#{xml}`, atributo"
  defp xml_cell(%{xml: xml}), do: "`#{xml}`"

  defp type_cell(_context, {:simple, name}), do: "`#{name}`"
  defp type_cell(context, {:complex, name}), do: "`#{context.namespace}.#{name}`"
  defp type_cell(_context, :signature), do: "`ds:Signature`"

  defp occurrence_cell(%{choice: nil} = field), do: occurrence(field)
  defp occurrence_cell(field), do: "#{occurrence(field)}, escolha #{field.choice + 1}"

  defp occurrence(%{min: min, max: min}), do: "#{min}"
  defp occurrence(%{min: min, max: :unbounded}), do: "#{min}..n"
  defp occurrence(%{min: min, max: max}), do: "#{min}..#{max}"

  # A barra separa as colunas da tabela em Markdown; a doc do TVerNFSe traz "1.00|1.01".
  defp table_text(text), do: String.replace(text, "|", "\\|")

  defp choice_notes([], _fields), do: nil

  defp choice_notes(choices, fields) do
    Enum.map_join(choices, "\n\n", fn %{index: index, min: min} ->
      branches = Enum.filter(fields, &(&1.choice == index))
      names = branches |> Enum.map(&"`#{&1.name}`") |> sentence_list()

      quantity =
        if min == 1 and Enum.all?(branches, &(&1.min == 1)),
          do: "exatamente um",
          else: "no máximo um"

      "Escolha #{index + 1}: #{quantity} entre #{names}."
    end)
  end

  defp simple_types_source(%{model: model} = context) do
    builtins = referenced_builtins(model)
    names = Enum.sort(Map.keys(model.simple) ++ Enum.uniq(Enum.map(builtins, &elem(&1, 0))))

    files =
      model.simple
      |> Map.keys()
      |> Enum.map(&model.files[&1])
      |> Enum.concat(Enum.map(builtins, &elem(&1, 1)))
      |> Enum.uniq()
      |> Enum.sort()

    doc =
      moduledoc([
        "Tipos simples do leiaute #{context.version}: as facetas de cada um, com as da base " <>
          "quando o tipo deriva de outro, e a representação em Elixir.",
        simple_type_table(model, names)
      ])

    facet_clauses =
      Enum.map_join(names, "\n", fn name ->
        "def facets(#{inspect(name)}), do: #{inspect(flattened_facets(model, name), @inspect_options)}"
      end)

    kind_clauses =
      Enum.map_join(names, "\n", &"def kind(#{inspect(&1)}), do: #{inspect(kind(model, &1))}")

    source = ~s'''
    #{header(files)}
    defmodule #{context.namespace}.SimpleTypes do
      @moduledoc """
    #{doc}
      """

      @doc "Facetas do tipo, as da base primeiro e depois as do próprio tipo."
      @spec facets(String.t()) :: keyword()
      #{facet_clauses}

      @doc "Representação do tipo em Elixir."
      @spec kind(String.t()) :: Nfse.Schema.SimpleType.kind()
      #{kind_clauses}
    end
    '''

    {"simple_types.ex", source}
  end

  # Um tipo embutido do XSD usado direto por um elemento, como o xs:date, também precisa de
  # cláusula, e vem do arquivo do tipo complexo que o usa.
  defp referenced_builtins(%Model{} = model) do
    for %ComplexType{} = complex_type <- Map.values(model.complex),
        type <- referenced_types(complex_type),
        Map.has_key?(@builtin_kinds, type),
        uniq: true,
        do: {type, complex_type.file}
  end

  defp referenced_types(%ComplexType{particles: particles, attributes: attributes}) do
    element_types =
      for particle <- particles,
          %Element{signature?: false, type: type} <- particle_elements(particle),
          do: type

    element_types ++ Enum.map(attributes, & &1.type)
  end

  defp particle_elements({:element, element}), do: [element]
  defp particle_elements({:choice, %{elements: elements}}), do: elements

  defp simple_type_table(model, names) do
    rows =
      Enum.map(names, fn name ->
        doc =
          case model.simple do
            %{^name => %SimpleType{doc: doc}} when is_binary(doc) -> table_text(doc)
            _no_doc -> ""
          end

        table_row(["`#{name}`", kind_description(kind(model, name)), doc])
      end)

    Enum.join([table_row(["Tipo", "Representação", "Descrição"]), "|---|---|---|" | rows], "\n")
  end

  defp kind_description(:string), do: "texto"
  defp kind_description(:date), do: "`Date`"
  defp kind_description(:datetime), do: "`DateTime`"

  defp kind_description({:decimal, integer_digits, fraction_digits}),
    do: "`Decimal`, até #{integer_digits} dígitos inteiros e #{fraction_digits} casas"

  defp flattened_facets(model, name) do
    {_builtin, chain} = derivation(model, name)
    Enum.flat_map(chain, & &1.facets)
  end

  defp kind(model, name) do
    {builtin, chain} = derivation(model, name)

    chain
    |> Enum.reverse()
    |> Enum.find_value(@builtin_kinds[builtin], &named_kind(&1.name))
  end

  defp named_kind("TSData"), do: :date
  defp named_kind("TSDateTimeUTC"), do: :datetime

  defp named_kind(name) do
    case Regex.run(@decimal_name, name, capture: :all_but_first) do
      [integer_digits, fraction_digits] ->
        {:decimal, String.to_integer(integer_digits), String.to_integer(fraction_digits)}

      nil ->
        nil
    end
  end

  # A cadeia vai da base mais distante até o próprio tipo, e termina num tipo embutido do XSD.
  defp derivation(model, name) do
    case model.simple do
      %{^name => %SimpleType{base: base} = simple_type} ->
        {builtin, chain} = derivation(model, base)
        {builtin, chain ++ [simple_type]}

      _builtin when is_map_key(@builtin_kinds, name) ->
        {name, []}

      _unknown ->
        raise ArgumentError, "tipo simples #{name} não suportado"
    end
  end

  defp header(files),
    do: "# Gerado por `mix nfse.gen` a partir de #{sentence_list(files)}. Não edite."

  defp moduledoc(paragraphs) do
    paragraphs
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n\n")
    |> heredoc_text()
    |> String.split("\n")
    |> Enum.map_join("\n", fn
      "" -> ""
      line -> "  " <> line
    end)
  end

  # A doc vem do XSD e vai para dentro de um heredoc: sem isso, `#{` interpolaria, `\` viraria
  # escape e `"""` fecharia o heredoc.
  defp heredoc_text(text) do
    text
    |> String.replace("\\", "\\\\")
    |> String.replace("\#{", "\\\#{")
    |> String.replace(~s("""), ~s(\\"""))
  end

  defp sentence_list([single]), do: single

  defp sentence_list(items) do
    {leading, [last]} = Enum.split(items, -1)
    Enum.join(leading, ", ") <> " e " <> last
  end
end
