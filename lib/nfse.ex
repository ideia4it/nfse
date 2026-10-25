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
end
