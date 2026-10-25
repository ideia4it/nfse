defmodule Nfse.Signature do
  @moduledoc """
  Uso interno da biblioteca: não faz parte da API pública.

  Assinatura XMLDSig envelopada, com C14N inclusiva, da DPS, do pedido de registro de evento e da
  NFS-e de decisão judicial.

  ## Por que não há canonicalização aqui

  O XMLDSig digere a forma *canônica* do que assina, não os bytes que vão pela rede. O OTP não traz
  C14N, e as dependências da biblioteca também não. Então a biblioteca vai pelo outro caminho: o
  escritor do leiaute (`Nfse.Schema.Runtime.encode/4`) já escreve na forma canônica, sem espaço
  entre tags, sem `<x/>` e com o namespace só na raiz, e `sign/4` digere os bytes literais. Para
  essa forma, a C14N de uma subárvore é a própria subárvore, com uma exceção.

  ## A exceção: o namespace herdado

  A C14N inclusiva escreve no topo do que canonicaliza todo namespace em escopo. O `infDPS` herda
  o namespace da NFS-e da `DPS` e não o declara, mas o digest é calculado sobre

      <infDPS xmlns="http://www.sped.fazenda.gov.br/nfse" Id="DPS...">...

  Assinar o `<infDPS Id="DPS...">` literal dá uma assinatura bem formada sobre os bytes errados,
  e a Sefin responde só "assinatura inválida". Por isso `sign/4` injeta o namespace antes de
  digerir. Daí vem a exigência sobre a raiz: ela declara o namespace da NFS-e como padrão e nenhum
  outro, porque cada namespace a mais que ela declarasse também entraria no topo da forma canônica.

  A mesma regra vale um nível abaixo: o `SignedInfo` herda o namespace do XMLDSig da `Signature`,
  então os bytes que o RSA assina levam um `xmlns` que os da rede não levam.

  ## Onde a assinatura entra

  A `Signature` devolvida vai logo depois do elemento assinado, como irmã dele dentro da raiz. Ela
  fica fora da subárvore digerida, e a transformação `enveloped-signature` não tira nada dali.

  Um documento que carrega outro já assinado, como a NFS-e de decisão judicial com a DPS dentro,
  assina o de dentro primeiro: o digest do de fora cobre a assinatura do de dentro.
  """

  alias Nfse.Certificate
  alias Nfse.Schema.Xml

  @nfse_namespace "http://www.sped.fazenda.gov.br/nfse"
  @dsig_namespace "http://www.w3.org/2000/09/xmldsig#"

  @canonicalization "http://www.w3.org/TR/2001/REC-xml-c14n-20010315"
  @enveloped_signature "http://www.w3.org/2000/09/xmldsig#enveloped-signature"

  @type algorithm :: :rsa_sha1 | :rsa_sha256

  @doc """
  O algoritmo que a biblioteca usa quando o chamador não escolhe outro.

  É `:rsa_sha1` até a conferência na produção restrita.
  """
  @spec default_algorithm() :: algorithm()
  def default_algorithm, do: :rsa_sha1

  @doc """
  Assina `element` e devolve a `<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">` que vai
  logo depois dele, como irmã dentro da raiz.

  `element` são os bytes literais e canônicos do elemento, exatamente como vão aparecer no
  documento final, e `id` é o valor do atributo `Id` dele, para onde a `Reference` aponta. A raiz
  que recebe o elemento declara o namespace da NFS-e como padrão e nenhum outro.

  Levanta `ArgumentError` quando `element` não está na forma que este módulo sabe digerir. É de
  propósito: cada um desses casos daria uma assinatura de aparência válida sobre os bytes errados,
  e o único retorno seria a recusa da Sefin, dias depois.
  """
  @spec sign(binary(), String.t(), Certificate.t(), algorithm()) :: binary()
  def sign(element, id, %Certificate{} = certificate, algorithm)
      when is_binary(element) and is_binary(id) and algorithm in [:rsa_sha1, :rsa_sha256] do
    {tag, attributes} = canonical_opening_tag!(element, id)
    digest_value = digest_value(element, tag, attributes, algorithm)

    # O SignedInfo da rede e o que o RSA assina saem da mesma função, para que uma mudança num
    # chegue sempre ao outro.
    signature_value =
      [{"xmlns", @dsig_namespace}]
      |> signed_info(id, digest_value, algorithm)
      |> rsa_sign(certificate.key, algorithm)

    IO.iodata_to_binary(
      element("Signature", [{"xmlns", @dsig_namespace}], [
        signed_info([], id, digest_value, algorithm),
        element("SignatureValue", [], Base.encode64(signature_value)),
        element("KeyInfo", [], [
          element("X509Data", [], [
            element("X509Certificate", [], Base.encode64(certificate.certificate))
          ])
        ])
      ])
    )
  end

  # O namespace vai antes dos atributos porque a C14N escreve as declarações de namespace
  # primeiro, qualquer que seja a ordem em que foram escritas.
  defp digest_value(element, tag, attributes, algorithm) do
    opening_tag_size = byte_size("<#{tag}#{attributes}>")
    rest = binary_part(element, opening_tag_size, byte_size(element) - opening_tag_size)
    canonical = [?<, tag, ~s( xmlns="), @nfse_namespace, ?", attributes, ?>, rest]

    algorithm
    |> hash()
    |> :crypto.hash(canonical)
    |> Base.encode64()
  end

  # Cada elemento de algoritmo é vazio e mesmo assim sai `<X></X>`: esta é a subárvore que o RSA
  # assina, e a forma curta assinaria bytes que a Sefin nunca canonicaliza.
  defp signed_info(namespace_declaration, id, digest_value, algorithm) do
    element("SignedInfo", namespace_declaration, [
      element("CanonicalizationMethod", [{"Algorithm", @canonicalization}], []),
      element("SignatureMethod", [{"Algorithm", signature_method(algorithm)}], []),
      element("Reference", [{"URI", "#" <> id}], [
        element("Transforms", [], [
          element("Transform", [{"Algorithm", @enveloped_signature}], []),
          element("Transform", [{"Algorithm", @canonicalization}], [])
        ]),
        element("DigestMethod", [{"Algorithm", digest_method(algorithm)}], []),
        element("DigestValue", [], digest_value)
      ])
    ])
  end

  # O texto aqui é sempre base64, que não tem caractere que a C14N escape. Os atributos passam pelo
  # escaping canônico.
  defp element(tag, attributes, content) do
    [
      ?<,
      tag,
      Enum.map(attributes, fn {name, value} ->
        [?\s, name, ~s(="), Xml.escape_attribute(value), ?"]
      end),
      ?>,
      content,
      "</",
      tag,
      ?>
    ]
  end

  defp rsa_sign(signed_info, {:RSAPrivateKey, der}, algorithm) do
    signed_info
    |> IO.iodata_to_binary()
    |> :public_key.sign(hash(algorithm), :public_key.der_decode(:RSAPrivateKey, der))
  end

  defp hash(:rsa_sha1), do: :sha
  defp hash(:rsa_sha256), do: :sha256

  defp signature_method(:rsa_sha1), do: "http://www.w3.org/2000/09/xmldsig#rsa-sha1"
  defp signature_method(:rsa_sha256), do: "http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"

  defp digest_method(:rsa_sha1), do: "http://www.w3.org/2000/09/xmldsig#sha1"
  defp digest_method(:rsa_sha256), do: "http://www.w3.org/2001/04/xmlenc#sha256"

  defp canonical_opening_tag!(element, id) do
    {tag, attributes} = opening_tag!(element)

    cond do
      not String.ends_with?(element, "</" <> tag <> ">") ->
        raise ArgumentError,
              "o elemento a assinar não termina na tag de fechamento `</#{tag}>`. O digest " <>
                "cobriria os bytes que vêm depois dela, que não fazem parte do elemento."

      indented?(element) ->
        raise ArgumentError,
              "o elemento a assinar não está em forma canônica: há espaço entre tags. A " <>
                "assinatura digere os bytes literais e só aceita o XML como o escritor do " <>
                "leiaute produz, sem indentação."

      Regex.match?(~r{<[\w.\-]+(?:[^>"']|"[^"]*"|'[^']*')*/>}, element) ->
        raise ArgumentError,
              "o elemento a assinar não está em forma canônica: há tag vazia abreviada (`<x/>`). " <>
                "A canonicalização escreve `<x></x>`, e o digest não bateria."

      Regex.match?(~r/(?:\A|\s)xmlns[:=]/, attributes) ->
        raise ArgumentError,
              "o elemento a assinar declara um namespace. O digest leva o namespace da NFS-e " <>
                "herdado da raiz, e uma declaração no próprio elemento mudaria a forma canônica."

      String.contains?(element, ~s(xmlns="#{@nfse_namespace}")) ->
        raise ArgumentError,
              "um descendente do elemento a assinar declara de novo o namespace da NFS-e. A " <>
                "canonicalização apaga a declaração repetida, e o digest não bateria."

      not Regex.match?(id_attribute(id), attributes) ->
        raise ArgumentError, ~s(o elemento a assinar não tem o atributo Id="#{id}")

      true ->
        {tag, attributes}
    end
  end

  defp opening_tag!(element) do
    opening_tag = ~r/\A<([A-Za-z_][\w.\-]*)((?:[^>"']|"[^"]*"|'[^']*')*)>/

    case Regex.run(opening_tag, element, capture: :all_but_first) do
      [tag, attributes] -> {tag, attributes}
      nil -> raise ArgumentError, "o elemento a assinar não começa com uma tag de abertura"
    end
  end

  # Uma folha cujo texto inteiro é espaço é um valor que o escritor do leiaute produz, e a C14N o
  # preserva. Só o espaço que sobra depois de tirar essas folhas é indentação.
  defp indented?(element) do
    element
    |> String.replace(~r{<([\w.\-]+)(?:[^>"']|"[^"]*"|'[^']*')*>\s+</\1>}, "")
    |> String.match?(~r/>\s+</)
  end

  defp id_attribute(id),
    do: ~r/(?:\A|\s)Id="#{Regex.escape(Xml.escape_attribute(id))}"/
end
