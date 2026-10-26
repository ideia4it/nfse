defmodule Nfse.Root do
  @moduledoc """
  Uso interno da biblioteca: não faz parte da API pública.

  A parte comum das raízes que a biblioteca monta e assina (`Nfse.DPS`, `Nfse.PedidoEvento`,
  `Nfse.NFSe`): os campos que a biblioteca calcula e que o chamador não pode preencher, como o
  `Id`; o `tp_amb`, que é sempre o do cliente; os valores provisórios que deixam o schema validar
  antes de o valor calculado existir; a junção dos erros do chamador com os do schema; e a raiz
  escrita em volta dos bytes assinados.
  """

  alias Nfse.{Client, Error, Signature}
  alias Nfse.Schema.SimpleType
  alias Nfse.Schema.V1_01.SimpleTypes

  @version "1.01"
  @namespace "http://www.sped.fazenda.gov.br/nfse"

  @type detail :: %{path: String.t(), error: atom()}

  @type put_computed :: (struct() -> {:ok, struct()} | {:error, [detail()]})

  @doc "A versão do leiaute que a biblioteca escreve."
  @spec version() :: String.t()
  def version, do: @version

  @doc "Os campos de um struct de raiz como mapa; um mapa passa como veio."
  @spec to_attrs(struct() | map()) :: map()
  def to_attrs(%_{} = root), do: Map.from_struct(root)
  def to_attrs(attrs) when is_map(attrs), do: attrs

  @doc """
  Converte e valida `attrs` como o tipo `module` (o `TCInf...` da raiz): `prepare/4` seguido de
  `validate/4`.
  """
  @spec build_inf(module(), map(), Client.t(), map(), put_computed()) ::
          {:ok, struct()} | {:error, Error.t()}
  def build_inf(module, attrs, %Client{} = client, computed, put_computed) do
    {attrs, caller_errors} = prepare(module, attrs, client, computed)
    validate(module, attrs, caller_errors, put_computed)
  end

  @doc """
  Junta a `attrs` os campos `computed`, que a biblioteca calcula, e o `tp_amb` do cliente, quando o
  tipo `module` tem `tpAmb`. Devolve os attrs e os erros que só o chamador pode cometer: um campo de
  `computed` preenchido é `:unknown_field`, e um `tp_amb` diferente do ambiente do cliente é
  `:environment`.

  O valor de um campo de `computed` é o definitivo ou um provisório, válido no padrão do schema,
  que `validate/4` troca pelo calculado.
  """
  @spec prepare(module(), map(), Client.t(), map()) :: {map(), [detail()]}
  def prepare(module, attrs, %Client{} = client, computed) do
    environment = environment(module, client)
    caller_errors = computed_errors(attrs, computed) ++ environment_errors(attrs, environment)

    {attrs |> Map.merge(environment) |> Map.merge(computed), caller_errors}
  end

  @doc """
  Converte e valida `attrs` como o tipo `module` e entrega o struct validado a `put_computed`, que
  troca os valores provisórios pelos calculados e devolve `{:ok, struct}` ou `{:error, details}`.

  A validação do tipo exige o `Id`, e o `Id` só sai dos campos já convertidos e validados (`n_dps:
  42` vira `"42"`). Os `caller_errors`, os do schema e os de `put_computed` voltam juntos, antes de
  qualquer assinatura.
  """
  @spec validate(module(), map(), [detail()], put_computed()) ::
          {:ok, struct()} | {:error, Error.t()}
  def validate(module, attrs, caller_errors, put_computed) do
    attrs
    |> module.new()
    |> put_computed(put_computed)
    |> merge_errors(caller_errors)
  end

  @doc """
  Escreve o `inf` validado como o elemento `inf_tag`, assina esses bytes com o `certificate` e
  devolve a raiz `root_tag`, com o namespace da NFS-e e a versão `"1.01"`, em volta deles e da
  assinatura.
  """
  @spec signed_xml(struct(), String.t(), String.t(), Nfse.Certificate.t()) :: binary()
  def signed_xml(%module{id: id} = inf, inf_tag, root_tag, certificate) do
    inf_xml = inf |> module.encode(inf_tag) |> IO.iodata_to_binary()
    signature = Signature.sign(inf_xml, id, certificate, Signature.default_algorithm())

    # A raiz é escrita em volta dos bytes assinados, e não pelo encode do tipo da raiz: a
    # assinatura só vale para os bytes exatos que ela digeriu. Sem a declaração, a Sefin recusa
    # com E1229 ("Xml não está utilizando codificação UTF-8") mesmo com os bytes em UTF-8.
    IO.iodata_to_binary([
      ~s(<?xml version="1.0" encoding="UTF-8"?>),
      ~s(<#{root_tag} xmlns="#{@namespace}" versao="#{@version}">),
      inf_xml,
      signature,
      "</#{root_tag}>"
    ])
  end

  defp environment(module, client) do
    if Enum.any?(module.__schema__(:fields), &(&1.name == :tp_amb)),
      do: %{tp_amb: Client.tp_amb(client)},
      else: %{}
  end

  # Um struct gerado traz todas as chaves, com nil: só um valor preenchido é erro do chamador.
  defp computed_errors(attrs, computed) do
    for {field, _value} <- computed, Map.get(attrs, field) != nil do
      %{path: Atom.to_string(field), error: :unknown_field}
    end
  end

  defp environment_errors(attrs, %{tp_amb: tp_amb}) do
    case SimpleType.cast(SimpleTypes, "TSTipoAmbiente", Map.get(attrs, :tp_amb)) do
      nil -> []
      ^tp_amb -> []
      _other_environment -> [%{path: "tp_amb", error: :environment}]
    end
  end

  defp environment_errors(_attrs, _type_without_environment), do: []

  defp put_computed({:ok, inf}, put_computed), do: put_computed.(inf)
  defp put_computed({:error, %Error{details: errors}}, _put_computed), do: {:error, errors}

  defp merge_errors({:ok, inf}, []), do: {:ok, inf}

  defp merge_errors({:ok, _inf}, caller_errors),
    do: {:error, %Error{kind: :validation, details: caller_errors}}

  defp merge_errors({:error, errors}, caller_errors),
    do: {:error, %Error{kind: :validation, details: caller_errors ++ errors}}
end
