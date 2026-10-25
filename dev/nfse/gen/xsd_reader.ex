defmodule Nfse.Gen.XsdReader do
  @moduledoc false

  alias Nfse.Gen.Model
  alias Nfse.Gen.Model.{Attribute, ComplexType, Element, SimpleType}

  @facets %{
    "pattern" => :pattern,
    "enumeration" => :enumeration,
    "maxLength" => :max_length,
    "minLength" => :min_length,
    "length" => :length,
    "whiteSpace" => :white_space
  }
  @integer_facets [:max_length, :min_length, :length]

  def read(dir) do
    documents =
      dir
      |> Path.join("*.xsd")
      |> Path.wildcard()
      |> Map.new(&{Path.basename(&1), parse!(&1)})

    # O xmldsig só entra como fonte do ref="ds:Signature"; interpretá-lo não faz sentido.
    imported_files =
      documents
      |> Map.values()
      |> Enum.flat_map(&child_nodes(&1, "import"))
      |> MapSet.new(&attribute(&1, "schemaLocation"))

    documents
    |> Map.keys()
    |> Enum.sort()
    |> Enum.reject(&MapSet.member?(imported_files, &1))
    |> Enum.reduce({%Model{}, MapSet.new()}, &load_file(&1, documents, &2))
    |> elem(0)
  end

  defp parse!(path) do
    xml = path |> File.read!() |> String.replace_prefix("\uFEFF", "")

    case Saxy.SimpleForm.parse_string(xml) do
      {:ok, schema} ->
        schema

      {:error, error} ->
        raise ArgumentError, "#{Path.basename(path)}: XML inválido (#{Exception.message(error)})"
    end
  end

  defp load_file(file, documents, {model, visited}) do
    if MapSet.member?(visited, file) do
      {model, visited}
    else
      {_tag, _attributes, children} = fetch_document!(documents, file)

      children
      |> nodes()
      |> Enum.reduce(
        {model, MapSet.put(visited, file)},
        &read_schema_child(&1, file, documents, &2)
      )
    end
  end

  defp fetch_document!(documents, file) do
    case documents do
      %{^file => schema} -> schema
      _missing -> raise ArgumentError, "#{file}: arquivo incluído não encontrado"
    end
  end

  defp read_schema_child(node, file, documents, {model, visited} = state) do
    case tag(node) do
      "include" ->
        load_file(attribute(node, "schemaLocation"), documents, state)

      ignored when ignored in ["import", "annotation"] ->
        state

      "complexType" ->
        complex_type = read_complex(attribute(node, "name"), node, file)
        {register_complex(model, complex_type, file), visited}

      "simpleType" ->
        simple_type = read_simple(attribute(node, "name"), node, file)
        {register_type(model, :simple, simple_type, file), visited}

      "element" ->
        {register_root(model, node, file), visited}

      _other ->
        unsupported!(node, file)
    end
  end

  defp register_root(model, node, file) do
    case {attribute(node, "name"), attribute(node, "type")} do
      {name, type} when is_binary(name) and is_binary(type) ->
        %{model | roots: Map.put(model.roots, name, type)}

      _other ->
        unsupported!(node, file)
    end
  end

  defp register_complex(model, %ComplexType{} = complex_type, file) do
    model = register_type(model, :complex, complex_type, file)

    complex_type.particles
    |> Enum.flat_map(&particle_elements/1)
    |> Enum.reduce(model, &register_anonymous_types(&2, &1, file))
  end

  defp register_anonymous_types(model, element, file) do
    model
    |> register_anonymous(:simple, element.anonymous_simple, file)
    |> register_anonymous(:complex, element.anonymous_complex, file)
  end

  defp register_anonymous(model, _kind, nil, _file), do: model

  defp register_anonymous(model, :simple, simple_type, file),
    do: register_type(model, :simple, simple_type, file)

  defp register_anonymous(model, :complex, complex_type, file),
    do: register_complex(model, complex_type, file)

  defp register_type(model, kind, %{name: name} = type, file) do
    if Map.has_key?(model.files, name) do
      raise ArgumentError, "#{file}: tipo #{name} declarado mais de uma vez"
    end

    %{model | files: Map.put(model.files, name, file)}
    |> Map.update!(kind, &Map.put(&1, name, type))
  end

  defp particle_elements({:element, element}), do: [element]
  defp particle_elements({:choice, %{elements: elements}}), do: elements

  defp read_complex(name, {_tag, _attributes, children}, file) do
    Enum.reduce(
      nodes(children),
      %ComplexType{name: name, file: file, particles: [], attributes: []},
      fn child, complex_type ->
        case tag(child) do
          "annotation" ->
            %{complex_type | doc: read_doc(child, file)}

          "sequence" ->
            %{complex_type | particles: read_sequence(child, name, file)}

          "choice" ->
            %{complex_type | particles: [{:choice, read_choice(child, name, file)}]}

          "attribute" ->
            %{complex_type | attributes: complex_type.attributes ++ [read_attribute(child)]}

          _other ->
            unsupported!(child, file)
        end
      end
    )
  end

  defp read_sequence({_tag, _attributes, children}, owner, file) do
    children
    |> nodes()
    |> Enum.reject(&(tag(&1) == "annotation"))
    |> Enum.map(fn child ->
      case tag(child) do
        "element" -> {:element, read_element(child, owner, file)}
        "choice" -> {:choice, read_choice(child, owner, file)}
        _other -> unsupported!(child, file)
      end
    end)
  end

  defp read_choice({_tag, _attributes, children} = node, owner, file) do
    elements =
      children
      |> nodes()
      |> Enum.reject(&(tag(&1) == "annotation"))
      |> Enum.map(fn child ->
        if tag(child) == "element",
          do: read_element(child, owner, file),
          else: unsupported!(child, file)
      end)

    %{min: min_occurs(node), max: max_occurs(node), elements: elements}
  end

  defp read_element(node, owner, file) do
    case {attribute(node, "ref"), attribute(node, "name")} do
      {"ds:Signature", nil} ->
        %Element{
          name: "Signature",
          type: "ds:Signature",
          min: min_occurs(node),
          max: max_occurs(node),
          signature?: true
        }

      {nil, name} when is_binary(name) ->
        read_named_element(node, name, owner, file)

      _other ->
        unsupported!(node, file)
    end
  end

  defp read_named_element({_tag, _attributes, children} = node, name, owner, file) do
    element = %Element{
      name: name,
      type: attribute(node, "type"),
      min: min_occurs(node),
      max: max_occurs(node)
    }

    children
    |> nodes()
    |> Enum.reduce(element, fn child, element ->
      case tag(child) do
        "annotation" -> %{element | doc: read_doc(child, file)}
        "simpleType" -> with_anonymous_simple(element, child, owner, file)
        "complexType" -> with_anonymous_complex(element, child, owner, file)
        _other -> unsupported!(child, file)
      end
    end)
  end

  defp with_anonymous_simple(element, node, owner, file) do
    simple_type = read_simple("#{owner}.#{element.name}", node, file)
    %{element | type: simple_type.name, anonymous_simple: simple_type}
  end

  defp with_anonymous_complex(element, node, owner, file) do
    complex_type = read_complex(owner <> Macro.camelize(element.name), node, file)
    %{element | type: complex_type.name, anonymous_complex: complex_type}
  end

  defp read_attribute(node) do
    %Attribute{
      name: attribute(node, "name"),
      type: attribute(node, "type"),
      required?: attribute(node, "use") == "required"
    }
  end

  defp read_simple(name, {_tag, _attributes, children}, file) do
    Enum.reduce(nodes(children), %SimpleType{name: name, base: nil, facets: []}, fn child,
                                                                                    simple_type ->
      case tag(child) do
        "annotation" -> %{simple_type | doc: read_doc(child, file)}
        "restriction" -> read_restriction(simple_type, child, file)
        _other -> unsupported!(child, file)
      end
    end)
  end

  defp read_restriction(simple_type, {_tag, _attributes, children} = node, file) do
    facets =
      children
      |> nodes()
      |> Enum.reject(&(tag(&1) == "annotation"))
      |> Enum.map(&read_facet(&1, file))

    %{simple_type | base: attribute(node, "base"), facets: facets}
  end

  defp read_facet(node, file) do
    kind = Map.get(@facets, tag(node))
    value = attribute(node, "value")

    cond do
      is_nil(kind) or is_nil(value) -> unsupported!(node, file)
      kind in @integer_facets -> {kind, String.to_integer(value)}
      true -> {kind, value}
    end
  end

  defp read_doc({_tag, _attributes, children}, file) do
    children
    |> nodes()
    |> Enum.map_join(" ", fn
      {_name, _attributes, content} = child ->
        if tag(child) == "documentation", do: text(content), else: unsupported!(child, file)
    end)
    |> String.split()
    |> Enum.join(" ")
    |> presence()
  end

  defp text(content), do: content |> Enum.filter(&is_binary/1) |> Enum.join()

  defp presence(""), do: nil
  defp presence(text), do: text

  defp min_occurs(node), do: String.to_integer(attribute(node, "minOccurs") || "1")

  defp max_occurs(node) do
    case attribute(node, "maxOccurs") do
      nil -> 1
      "unbounded" -> :unbounded
      value -> String.to_integer(value)
    end
  end

  defp unsupported!({name, _attributes, _children}, file) do
    raise ArgumentError, "#{file}: construção XSD não suportada <#{name}>"
  end

  defp tag({name, _attributes, _children}), do: name |> String.split(":") |> List.last()

  defp attribute({_tag, attributes, _children}, name) do
    Enum.find_value(attributes, fn {key, value} -> if key == name, do: value end)
  end

  defp nodes(children), do: Enum.filter(children, &is_tuple/1)

  defp child_nodes({_tag, _attributes, children}, tag),
    do: children |> nodes() |> Enum.filter(&(tag(&1) == tag))
end
