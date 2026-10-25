defmodule Nfse.PedidoEvento do
  @moduledoc """
  O pedido de registro de um evento da NFS-e, montado a partir dos campos que quem o pede
  preenche.

  Os campos do struct são os elementos do `Nfse.Schema.V1_01.TCInfPedReg`, com os mesmos nomes e
  as mesmas regras de conversão. Exatamente um elemento `e<código>` vai preenchido, e é ele que
  define o tipo do evento. `build/2` aceita o struct ou um mapa com essas chaves.

  ## Eventos que o contribuinte pode registrar

  | Código | Campo | Evento |
  |---|---|---|
  | `101101` | `e101101` | Cancelamento de NFS-e |
  | `101103` | `e101103` | Solicitação de análise fiscal para cancelamento |
  | `202201` | `e202201` | Confirmação do prestador |
  | `203202` | `e203202` | Confirmação do tomador |
  | `204203` | `e204203` | Confirmação do intermediário |
  | `202205` | `e202205` | Rejeição do prestador |
  | `203206` | `e203206` | Rejeição do tomador |
  | `204207` | `e204207` | Rejeição do intermediário |
  | `205208` | `e205208` | Anulação da rejeição |

  No cancelamento (`e101101`), `c_motivo` é `1` para erro na emissão, `2` para serviço não prestado
  e `9` para outros, e `x_motivo` explica o motivo com 15 a 255 caracteres. Para cancelar sem
  montar o pedido, use `Nfse.cancel/3`.

  ## O que `build/2` calcula

    * `Id` do `infPedReg`, com 59 caracteres: `"PRE"`, a chave de acesso da NFS-e e o tipo do
      evento com 6 dígitos
    * `versao` da raiz, sempre `"1.01"`
    * `tp_amb`, a partir do ambiente do cliente. Pode ser omitido; se vier, precisa ser o do
      cliente
    * `cnpj_autor` ou `cpf_autor`, a partir do certificado do cliente, quando o chamador não
      informa nenhum dos dois
    * `dh_evento`, a hora atual em UTC com precisão de segundos, quando o chamador não informa

  `ver_aplic` vem sempre do chamador. Depois valida tudo, assina o `infPedReg` com o certificado do
  cliente e devolve o XML canônico, pronto para enviar. Nada é reescrito entre assinar e devolver.

  ## Erros

  Os erros voltam juntos, como `%Nfse.Error{kind: :validation}`, antes de qualquer assinatura. Além
  dos erros do schema, descritos em `Nfse.Schema.Runtime`:

  | Caminho | Erro | Quando |
  |---|---|---|
  | `id` | `:unknown_field` | o chamador passou `id`, que é sempre calculado |
  | `tp_amb` | `:environment` | `tp_amb` diferente do ambiente do cliente |
  | (vários) | `:choice` | mais de um elemento `e<código>` preenchido, ou nenhum |
  """

  alias Nfse.{Client, Error, Identifiers, Signature}
  alias Nfse.Schema.V1_01.{TCInfPedReg, TCPedRegEvt}

  @version "1.01"
  @root_opening_tag ~s(<pedRegEvento xmlns="http://www.sped.fazenda.gov.br/nfse" versao="#{@version}">)

  # O TCInfPedReg exige o Id, e o Id só sai da chave e do evento já convertidos e validados. Este
  # Id provisório, válido no padrão, deixa a primeira validação rodar e é trocado pelo calculado
  # antes de assinar.
  @provisional_id "PRE" <> String.duplicate("0", 56)

  defstruct Enum.map(TCInfPedReg.__schema__(:fields), & &1.name)

  @event_fields for %{name: name, xml: "e" <> code = xml} <- TCInfPedReg.__schema__(:fields),
                    code =~ ~r/^\d{6}$/,
                    do: {name, xml}

  @type t :: %__MODULE__{}

  @type built :: %{xml: binary(), id: String.t()}

  @doc """
  Calcula `Id`, `versao` e `tpAmb`, valida, assina e devolve o XML do pedido com o `Id`.
  """
  @spec build(t() | map(), Client.t()) :: {:ok, built()} | {:error, Error.t()}
  def build(%__MODULE__{} = pedido, %Client{} = client),
    do: build(Map.from_struct(pedido), client)

  def build(attrs, %Client{} = client) when is_map(attrs) do
    with {:ok, inf_ped_reg} <- inf_ped_reg(attrs, client),
         {:ok, pedido} <- TCPedRegEvt.new(%{versao: @version, inf_ped_reg: inf_ped_reg}) do
      {:ok, %{xml: signed_xml(pedido.inf_ped_reg, client.certificate), id: inf_ped_reg.id}}
    end
  end

  defp inf_ped_reg(attrs, client) do
    caller_errors = id_errors(attrs) ++ Client.environment_errors(attrs, client)

    attrs
    |> with_defaults(client)
    |> TCInfPedReg.new()
    |> put_event_request_id()
    |> case do
      {:ok, inf_ped_reg} when caller_errors == [] -> {:ok, inf_ped_reg}
      {:ok, _inf_ped_reg} -> {:error, %Error{kind: :validation, details: caller_errors}}
      {:error, %Error{details: errors}} -> {:error, validation_error(caller_errors ++ errors)}
    end
  end

  defp validation_error(details), do: %Error{kind: :validation, details: details}

  defp id_errors(attrs) do
    if Map.has_key?(attrs, :id), do: [%{path: "id", error: :unknown_field}], else: []
  end

  defp with_defaults(attrs, client) do
    attrs
    |> Map.merge(%{tp_amb: Client.tp_amb(client), id: @provisional_id})
    |> put_missing(:dh_evento, DateTime.utc_now() |> DateTime.truncate(:second))
    |> put_certificate_author(client.certificate)
  end

  defp put_certificate_author(%{cnpj_autor: author} = attrs, _certificate) when author != nil,
    do: attrs

  defp put_certificate_author(%{cpf_autor: author} = attrs, _certificate) when author != nil,
    do: attrs

  defp put_certificate_author(attrs, %{cnpj: cnpj}) when is_binary(cnpj),
    do: Map.put(attrs, :cnpj_autor, cnpj)

  defp put_certificate_author(attrs, %{cpf: cpf}) when is_binary(cpf),
    do: Map.put(attrs, :cpf_autor, cpf)

  defp put_certificate_author(attrs, _certificate), do: attrs

  defp put_missing(attrs, key, value) do
    if Map.get(attrs, key) == nil, do: Map.put(attrs, key, value), else: attrs
  end

  defp put_event_request_id({:error, _error} = failure), do: failure

  defp put_event_request_id({:ok, inf_ped_reg}) do
    {_field, "e" <> event_type} =
      Enum.find(@event_fields, fn {field, _xml} -> Map.fetch!(inf_ped_reg, field) != nil end)

    {:ok, %{inf_ped_reg | id: Identifiers.event_request_id(inf_ped_reg.ch_nfse, event_type)}}
  end

  # A raiz é escrita em volta dos bytes assinados, e não pelo TCPedRegEvt.encode: a assinatura só
  # vale para os bytes exatos que ela digeriu.
  defp signed_xml(inf_ped_reg, certificate) do
    inf_ped_reg_xml = inf_ped_reg |> TCInfPedReg.encode("infPedReg") |> IO.iodata_to_binary()

    signature =
      Signature.sign(inf_ped_reg_xml, inf_ped_reg.id, certificate, Signature.default_algorithm())

    IO.iodata_to_binary([@root_opening_tag, inf_ped_reg_xml, signature, "</pedRegEvento>"])
  end
end
