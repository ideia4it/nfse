defmodule Nfse.Root do
  @moduledoc """
  Uso interno da biblioteca: não faz parte da API pública.

  A parte comum das raízes que a biblioteca monta e assina (`Nfse.DPS`, `Nfse.PedidoEvento`): os
  erros que só o chamador pode cometer (`id`, que é sempre calculado, e `tp_amb`, que é sempre o do
  cliente), o `Id` provisório que deixa o schema validar antes de o `Id` existir, e a junção dos
  erros do chamador com os do schema.
  """

  alias Nfse.{Client, Error}
  alias Nfse.Schema.SimpleType
  alias Nfse.Schema.V1_01.SimpleTypes

  @type detail :: %{path: String.t(), error: atom()}

  @doc "Os campos de um struct de raiz como mapa; um mapa passa como veio."
  @spec to_attrs(struct() | map()) :: map()
  def to_attrs(%_{} = root), do: Map.from_struct(root)
  def to_attrs(attrs) when is_map(attrs), do: attrs

  @doc """
  Converte e valida `attrs` como o tipo `module` (o `TCInf...` da raiz), com `tp_amb` do cliente e
  `provisional_id` no lugar do `Id`.

  A validação do tipo exige o `Id`, e o `Id` só sai dos campos já convertidos e validados (`n_dps:
  42` vira `"42"`). O `Id` provisório, válido no padrão, deixa a primeira validação rodar, e
  `put_id` o troca pelo calculado: recebe o struct validado e devolve `{:ok, struct}` ou
  `{:error, details}`.

  Os erros do chamador, os do schema e os de `put_id` voltam juntos, antes de qualquer assinatura.
  """
  @spec build_inf(module(), map(), Client.t(), String.t(), (struct() ->
                                                              {:ok, struct()}
                                                              | {:error, [detail()]})) ::
          {:ok, struct()} | {:error, Error.t()}
  def build_inf(module, attrs, %Client{} = client, provisional_id, put_id) do
    caller_errors = caller_errors(attrs, client)

    attrs
    |> Map.merge(%{tp_amb: Client.tp_amb(client), id: provisional_id})
    |> module.new()
    |> put_id(put_id)
    |> merge_errors(caller_errors)
  end

  @doc "Os erros de `id` passado e de `tp_amb` diferente do ambiente do cliente."
  @spec caller_errors(map(), Client.t()) :: [detail()]
  def caller_errors(attrs, %Client{} = client),
    do: id_errors(attrs) ++ environment_errors(attrs, client)

  defp id_errors(attrs) do
    if Map.has_key?(attrs, :id), do: [%{path: "id", error: :unknown_field}], else: []
  end

  defp environment_errors(attrs, client) do
    tp_amb = Client.tp_amb(client)

    case SimpleType.cast(SimpleTypes, "TSTipoAmbiente", Map.get(attrs, :tp_amb)) do
      nil -> []
      ^tp_amb -> []
      _other_environment -> [%{path: "tp_amb", error: :environment}]
    end
  end

  defp put_id({:ok, inf}, put_id), do: put_id.(inf)
  defp put_id({:error, %Error{details: errors}}, _put_id), do: {:error, errors}

  defp merge_errors({:ok, inf}, []), do: {:ok, inf}

  defp merge_errors({:ok, _inf}, caller_errors),
    do: {:error, %Error{kind: :validation, details: caller_errors}}

  defp merge_errors({:error, errors}, caller_errors),
    do: {:error, %Error{kind: :validation, details: caller_errors ++ errors}}
end
