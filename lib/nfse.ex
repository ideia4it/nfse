defmodule Nfse do
  @moduledoc """
  Cliente Elixir para a NFS-e Nacional.
  """

  alias Nfse.Sefin

  @doc """
  Emite a NFS-e a partir de uma DPS, de forma síncrona.

  Monta, valida e assina a DPS (`Nfse.DPS.build/2`) e a envia à Sefin uma única vez. Se a Sefin não
  responder (`:timeout`, `:transport` ou `:server`), o resultado é incerto: o `Nfse.Error` traz o
  `dps_id` para conferir com `dps_issued?/2` e `fetch_access_key/2` antes de reenviar.
  """
  @spec issue(Nfse.Client.t(), Nfse.DPS.t() | map()) ::
          {:ok, Nfse.Issued.t()} | {:error, Nfse.Error.t()}
  defdelegate issue(client, dps), to: Sefin

  @doc "Consulta uma NFS-e na Sefin pela chave de acesso de 50 dígitos."
  @spec fetch(Nfse.Client.t(), String.t()) :: {:ok, Nfse.Document.t()} | {:error, Nfse.Error.t()}
  defdelegate fetch(client, access_key), to: Sefin

  @doc """
  Confere se uma DPS virou NFS-e: `{:ok, true}` quando a Sefin a conhece e `{:ok, false}` quando
  não.
  """
  @spec dps_issued?(Nfse.Client.t(), String.t()) :: {:ok, boolean()} | {:error, Nfse.Error.t()}
  defdelegate dps_issued?(client, dps_id), to: Sefin

  @doc "Busca a chave de acesso da NFS-e emitida a partir do `Id` da DPS."
  @spec fetch_access_key(Nfse.Client.t(), String.t()) ::
          {:ok, String.t()} | {:error, Nfse.Error.t()}
  defdelegate fetch_access_key(client, dps_id), to: Sefin

  @doc """
  Registra um evento da NFS-e, como a solicitação de análise fiscal ou a manifestação do tomador.

  Monta, valida e assina o pedido (`Nfse.PedidoEvento.build/2`) e o envia à Sefin uma única vez.
  Se a Sefin não responder (`:timeout`, `:transport` ou `:server`), o resultado é incerto: confira
  com `fetch_event/4` antes de reenviar.
  """
  @spec register_event(Nfse.Client.t(), Nfse.PedidoEvento.t() | map()) ::
          {:ok, Nfse.Event.t()} | {:error, Nfse.Error.t()}
  defdelegate register_event(client, pedido), to: Sefin

  @doc """
  Cancela uma NFS-e pelo evento `101101`.

  Opções: `:c_motivo` (`1` erro na emissão, `2` serviço não prestado, `9` outros) e `:x_motivo`
  (de 15 a 255 caracteres), obrigatórias, e `:ver_aplic`, que por padrão é `"nfse-"` seguido da
  versão da biblioteca. O autor é o dono do certificado do cliente.
  """
  @spec cancel(Nfse.Client.t(), String.t(), keyword()) ::
          {:ok, Nfse.Event.t()} | {:error, Nfse.Error.t()}
  defdelegate cancel(client, access_key, opts), to: Sefin

  @doc """
  Consulta um evento da NFS-e pelo tipo (como `"101101"`) e pelo número de sequência.
  """
  @spec fetch_event(Nfse.Client.t(), String.t(), String.t(), pos_integer()) ::
          {:ok, Nfse.Event.t()} | {:error, Nfse.Error.t()}
  defdelegate fetch_event(client, access_key, event_type, sequence), to: Sefin
end
