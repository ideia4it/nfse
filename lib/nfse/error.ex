defmodule Nfse.Error do
  @moduledoc """
  Erro devolvido por toda função pública da biblioteca.

  `messages` é uma lista de `t:message/0`. A Sefin manda `erros[]` na emissão e um `erro` único
  nos eventos, e os dois viram essa lista. `details` carrega o dado específico de cada `kind`, e
  `dps_id` identifica a DPS de uma escrita para conferir o resultado em vez de reenviar.

  | `kind` | Quando |
  |---|---|
  | `:validation` | o documento não passa no schema; `details` traz os caminhos; sem rede |
  | `:certificate` | certificado vencido, sem *clientAuth* ou ilegível; sem rede |
  | `:rejected` | 400: regra de negócio (código `E....` do Anexo I ou II) |
  | `:forbidden` | 403: certificado recusado ou ator sem acesso ao documento |
  | `:not_found` | 404 |
  | `:server` | 5xx |
  | `:timeout`, `:transport` | sem resposta; numa escrita, o resultado é incerto |
  | `:unexpected` | resposta que não se consegue ler |
  """

  @type kind ::
          :validation
          | :certificate
          | :rejected
          | :forbidden
          | :not_found
          | :server
          | :timeout
          | :transport
          | :unexpected

  @type message :: %{
          code: String.t() | nil,
          description: String.t() | nil,
          complement: String.t() | nil
        }

  @type t :: %__MODULE__{
          kind: kind() | nil,
          status: non_neg_integer() | nil,
          dps_id: String.t() | nil,
          messages: [message()],
          details: term()
        }

  defexception [:kind, :status, :dps_id, messages: [], details: nil]

  @impl true
  def message(%__MODULE__{} = error) do
    [summary(error.kind), codes(error.messages), dps_reference(error.kind, error.dps_id)]
    |> Enum.reject(&is_nil/1)
    |> Enum.join(" ")
  end

  defp summary(:validation), do: "O documento não passou na validação do schema."
  defp summary(:certificate), do: "O certificado digital não pôde ser usado."
  defp summary(:rejected), do: "A requisição foi recusada pela Sefin."
  defp summary(:forbidden), do: "O acesso foi negado pela Sefin."
  defp summary(:not_found), do: "O recurso não foi encontrado."
  defp summary(:server), do: "O servidor da Sefin falhou."
  defp summary(:timeout), do: "A Sefin não respondeu a tempo."
  defp summary(:transport), do: "A conexão com a Sefin falhou."
  defp summary(_kind), do: "A resposta da Sefin não pôde ser lida."

  defp codes(messages) do
    case for(%{code: code} when is_binary(code) <- messages, do: code) do
      [] -> nil
      codes -> "Códigos: #{Enum.join(codes, ", ")}."
    end
  end

  defp dps_reference(_kind, nil), do: nil

  defp dps_reference(kind, dps_id) when kind in [:timeout, :transport, :server],
    do: "Confira a DPS #{dps_id} antes de reenviar."

  defp dps_reference(_kind, dps_id), do: "DPS #{dps_id}."
end
