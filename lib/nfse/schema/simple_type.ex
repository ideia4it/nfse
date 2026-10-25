defmodule Nfse.Schema.SimpleType do
  @moduledoc """
  Valor de um tipo simples do XSD: conversão, validação, escrita e leitura.

  As regras vêm do módulo de tipos simples do schema, que responde `facets/1` com as facetas já
  achatadas (as da base primeiro, depois as do próprio tipo) e `kind/1` com a representação em
  Elixir. Os detalhes e as divergências em relação ao XSD estão em `Nfse.Schema.Runtime`.
  """

  @type kind :: :string | :date | :datetime | {:decimal, pos_integer(), pos_integer()}

  @type error ::
          :type
          | :length
          | :min_length
          | :max_length
          | :enumeration
          | :pattern
          | :integer_digits
          | :fraction_digits

  # Ordem fixa para que o erro de um valor não dependa da ordem das facetas no XSD.
  @facet_order [:length, :min_length, :max_length, :enumeration, :pattern]

  @doc """
  Converte o valor de entrada para a representação canônica do tipo.

  Inteiro vira string num tipo `:string`, e decimal válido passa a ter exatamente as casas do tipo.
  Qualquer outro valor volta como veio, para que `validate/3` aponte o erro.
  """
  @spec cast(module(), String.t(), term()) :: term()
  def cast(simple_types, name, value), do: cast_kind(simple_types.kind(name), value)

  @doc "Confere o tipo, os dígitos de um decimal e cada faceta sobre a forma escrita do valor."
  @spec validate(module(), String.t(), term()) :: :ok | {:error, error()}
  def validate(simple_types, name, value) do
    kind = simple_types.kind(name)

    with :ok <- check_value(kind, value) do
      check_facets(simple_types.facets(name), lexical(kind, value))
    end
  end

  @doc """
  Devolve a forma escrita do valor, sem escaping.

  Levanta `ArgumentError` para um valor do tipo errado ou um decimal com dígitos demais, porque
  escrevê-lo exigiria arredondar ou truncar.
  """
  @spec to_lexical(module(), String.t(), term()) :: String.t()
  def to_lexical(simple_types, name, value) do
    kind = simple_types.kind(name)

    case check_value(kind, value) do
      :ok ->
        lexical(kind, value)

      {:error, reason} ->
        raise ArgumentError, "O valor #{inspect(value)} não cabe no tipo #{name} (#{reason})."
    end
  end

  @doc """
  Lê o texto de um elemento ou atributo. As facetas são conferidas no texto antes de qualquer
  conversão, para que um decimal com expoente nunca chegue ao `Decimal`.
  """
  @spec parse(module(), String.t(), String.t()) :: {:ok, term()} | {:error, error()}
  def parse(simple_types, name, text) do
    kind = simple_types.kind(name)

    with :ok <- check_facets(simple_types.facets(name), text),
         {:ok, value} <- from_lexical(kind, text) do
      {:ok, cast_kind(kind, value)}
    end
  end

  defp cast_kind(:string, value) when is_integer(value), do: Integer.to_string(value)

  defp cast_kind({:decimal, _integer_limit, places} = kind, %Decimal{} = decimal) do
    case check_value(kind, decimal) do
      :ok -> fixed_point(decimal, places)
      {:error, _reason} -> decimal
    end
  end

  defp cast_kind(_kind, value), do: value

  defp check_value(:string, value) when is_binary(value) do
    if xml_text?(value), do: :ok, else: {:error, :type}
  end

  defp check_value(:date, %Date{}), do: :ok
  defp check_value(:datetime, %DateTime{}), do: :ok

  defp check_value({:decimal, integer_limit, fraction_limit}, %Decimal{coef: coef} = decimal)
       when is_integer(coef) do
    cond do
      integer_digits(decimal) > integer_limit -> {:error, :integer_digits}
      fraction_digits(decimal) > fraction_limit -> {:error, :fraction_digits}
      true -> :ok
    end
  end

  defp check_value(_kind, _value), do: {:error, :type}

  # O xs:string só aceita os caracteres do XML 1.0. Um controle como o U+000B, que o Word usa como
  # quebra de linha, faria o leitor da Sefin recusar o documento inteiro, sem dizer o campo.
  defp xml_text?(<<character::utf8, rest::binary>>)
       when character in [0x9, 0xA, 0xD] or character in 0x20..0xD7FF or
              character in 0xE000..0xFFFD or character >= 0x10000,
       do: xml_text?(rest)

  defp xml_text?(rest), do: rest == ""

  defp lexical(:string, text), do: text
  defp lexical(:date, date), do: Date.to_iso8601(date)

  defp lexical(:datetime, datetime) do
    wall_clock =
      datetime
      |> DateTime.to_naive()
      |> NaiveDateTime.truncate(:second)
      |> NaiveDateTime.to_iso8601()

    wall_clock <> utc_offset(datetime.utc_offset + datetime.std_offset)
  end

  defp lexical({:decimal, _integer_limit, places}, decimal) do
    decimal
    |> fixed_point(places)
    |> Decimal.to_string(:normal)
  end

  defp from_lexical(:string, text), do: {:ok, text}

  defp from_lexical(:date, text) do
    case Date.from_iso8601(text) do
      {:ok, date} -> {:ok, date}
      {:error, _reason} -> {:error, :type}
    end
  end

  defp from_lexical(:datetime, text) do
    case DateTime.from_iso8601(text) do
      {:ok, datetime, _offset} -> {:ok, datetime}
      {:error, _reason} -> {:error, :type}
    end
  end

  defp from_lexical({:decimal, _integer_limit, _places}, text) do
    {decimal, ""} = Decimal.parse(text)
    {:ok, decimal}
  end

  defp utc_offset(seconds) do
    sign = if seconds < 0, do: "-", else: "+"
    minutes = div(abs(seconds), 60)
    sign <> two_digits(div(minutes, 60)) <> ":" <> two_digits(rem(minutes, 60))
  end

  defp two_digits(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(2, "0")
  end

  # Contas sobre coeficiente e expoente, sem Decimal.round: o round segue a precisão do contexto do
  # processo de quem chama, que pode arredondar ou levantar exceção.
  defp integer_digits(%Decimal{coef: 0}), do: 0
  defp integer_digits(%Decimal{coef: coef, exp: exp}), do: max(digit_count(coef) + exp, 0)

  defp fraction_digits(%Decimal{coef: 0}), do: 0
  defp fraction_digits(%Decimal{coef: coef, exp: exp}), do: max(-exp - trailing_zeros(coef), 0)

  defp fixed_point(%Decimal{sign: sign, coef: coef, exp: exp}, places) do
    scaled = shift_digits(coef, exp + places)
    %Decimal{sign: if(scaled == 0, do: 1, else: sign), coef: scaled, exp: -places}
  end

  defp shift_digits(coef, shift) when shift >= 0, do: coef * Integer.pow(10, shift)
  defp shift_digits(coef, shift), do: div(coef, Integer.pow(10, -shift))

  defp digit_count(coef) do
    coef
    |> Integer.to_string()
    |> byte_size()
  end

  defp trailing_zeros(coef) when rem(coef, 10) == 0, do: 1 + trailing_zeros(div(coef, 10))
  defp trailing_zeros(_coef), do: 0

  defp check_facets(facets, lexical) do
    Enum.each(facets, &supported_facet!/1)

    case Enum.find(@facet_order, &violated?(&1, Keyword.get_values(facets, &1), lexical)) do
      nil -> :ok
      facet -> {:error, facet}
    end
  end

  # Só `preserve` existe no pacote oficial; outro valor pediria normalizar o texto antes de validar.
  defp supported_facet!({:white_space, "preserve"}), do: :ok
  defp supported_facet!({facet, _value}) when facet in @facet_order, do: :ok

  defp violated?(_facet, [], _lexical), do: false

  defp violated?(:length, lengths, lexical),
    do: Enum.any?(lengths, &(codepoint_count(lexical) != &1))

  defp violated?(:min_length, minimums, lexical),
    do: Enum.any?(minimums, &(codepoint_count(lexical) < &1))

  defp violated?(:max_length, maximums, lexical),
    do: Enum.any?(maximums, &(codepoint_count(lexical) > &1))

  defp violated?(:enumeration, values, lexical), do: lexical not in values

  defp violated?(:pattern, patterns, lexical),
    do: not Enum.all?(patterns, &Regex.match?(xsd_regex(&1), lexical))

  # O XSD mede comprimento em caracteres Unicode, não em grafemas como String.length/1.
  defp codepoint_count(text) do
    text
    |> String.codepoints()
    |> length()
  end

  # O padrão do XSD já é ancorado, e nele o ponto não casa CR nem LF, o que o `:anycrlf` reproduz.
  defp xsd_regex(pattern) do
    body =
      pattern
      |> String.replace_prefix("^", "")
      |> String.replace_suffix("$", "")

    Regex.compile!("\\A(?:" <> body <> ")\\z", [:unicode, :ucp, {:newline, :anycrlf}])
  end
end
