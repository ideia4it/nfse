defmodule Nfse do
  @moduledoc """
  Cliente Elixir para a NFS-e Nacional.
  """

  alias Nfse.{Adn, Parametros, Sefin}

  @doc """
  Emite a NFS-e a partir de uma DPS, de forma síncrona.

  Monta, valida e assina a DPS (`Nfse.DPS.build/2`) e a envia à Sefin uma única vez. Se a Sefin não
  responder (`:timeout`, `:transport` ou `:server`), o resultado é incerto: o `Nfse.Error` traz o
  `dps_id` para conferir com `dps_issued?/2` e `fetch_access_key/2` antes de reenviar.
  """
  @spec issue(Nfse.Client.t(), Nfse.DPS.t() | map()) ::
          {:ok, Nfse.Issued.t()} | {:error, Nfse.Error.t()}
  defdelegate issue(client, dps), to: Sefin

  @doc """
  Emite a NFS-e por decisão administrativa ou judicial, de forma síncrona.

  Monta, valida e assina a NFS-e inteira (`Nfse.NFSe.build/2`) e a envia à Sefin uma única vez. O
  município precisa ter cadastrado a decisão e autorizado o contribuinte antes. Se a Sefin não
  responder, o resultado é incerto, como em `issue/2`.
  """
  @spec issue_by_court_order(Nfse.Client.t(), Nfse.NFSe.t() | map()) ::
          {:ok, Nfse.Issued.t()} | {:error, Nfse.Error.t()}
  defdelegate issue_by_court_order(client, nfse), to: Sefin

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

  @doc """
  Lê um lote da distribuição do ADN: os documentos fiscais em que o CNPJ do certificado aparece,
  depois do `nsu` informado, em até 50 por chamada.

  Opção: `:cnpj_consulta`, para consultar outro CNPJ da mesma raiz. O `next_nsu` do resultado é o
  ponto de partida da próxima chamada. O fim da fila é `{:ok, %Nfse.Distribution{status:
  :no_documents}}`, nunca erro. Veja `Nfse.Adn`.
  """
  @spec distribution(Nfse.Client.t(), non_neg_integer(), keyword()) ::
          {:ok, Nfse.Distribution.t()} | {:error, Nfse.Error.t()}
  defdelegate distribution(client, nsu, opts \\ []), to: Adn

  @doc """
  Percorre a distribuição do ADN, lote a lote, a partir do `nsu`, e entrega os documentos um a um
  até o fim da fila. Aceita as mesmas opções de `distribution/3`.

  Diferente das demais funções, levanta `Nfse.Error` quando um lote falha.
  """
  @spec stream_distribution(Nfse.Client.t(), non_neg_integer(), keyword()) ::
          Enumerable.t(Nfse.DistributedDocument.t())
  defdelegate stream_distribution(client, nsu, opts \\ []), to: Adn

  @doc "Lista os documentos de evento de uma NFS-e (cancelamentos, manifestações) pelo ADN."
  @spec events(Nfse.Client.t(), String.t()) ::
          {:ok, [Nfse.DistributedDocument.t()]} | {:error, Nfse.Error.t()}
  defdelegate events(client, access_key), to: Adn

  @doc "Lê os parâmetros do convênio do município (código IBGE de sete dígitos) com o ADN."
  @spec municipal_agreement(Nfse.Client.t(), String.t()) ::
          {:ok, map()} | {:error, Nfse.Error.t()}
  defdelegate municipal_agreement(client, c_mun), to: Parametros

  @doc """
  Lê a alíquota de ISS de um serviço no município, na competência (um `Date`). O código do
  serviço aceita os nove dígitos com ou sem pontos. Veja `Nfse.Parametros`.
  """
  @spec rate(Nfse.Client.t(), String.t(), String.t(), Date.t()) ::
          {:ok, map()} | {:error, Nfse.Error.t()}
  defdelegate rate(client, c_mun, c_serv, competencia), to: Parametros

  @doc "Lê o histórico de alíquotas de ISS de um serviço no município."
  @spec rate_history(Nfse.Client.t(), String.t(), String.t()) ::
          {:ok, map()} | {:error, Nfse.Error.t()}
  defdelegate rate_history(client, c_mun, c_serv), to: Parametros

  @doc "Lê os regimes especiais de um serviço no município, na competência."
  @spec special_regimes(Nfse.Client.t(), String.t(), String.t(), Date.t()) ::
          {:ok, map()} | {:error, Nfse.Error.t()}
  defdelegate special_regimes(client, c_mun, c_serv, competencia), to: Parametros

  @doc "Lê os parâmetros de retenção do município na competência."
  @spec withholdings(Nfse.Client.t(), String.t(), Date.t()) ::
          {:ok, map()} | {:error, Nfse.Error.t()}
  defdelegate withholdings(client, c_mun, competencia), to: Parametros

  @doc "Lê um benefício municipal pelo número, na competência."
  @spec benefit(Nfse.Client.t(), String.t(), String.t() | integer(), Date.t()) ::
          {:ok, map()} | {:error, Nfse.Error.t()}
  defdelegate benefit(client, c_mun, n_beneficio, competencia), to: Parametros
end
