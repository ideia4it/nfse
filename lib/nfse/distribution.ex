defmodule Nfse.Distribution do
  @moduledoc """
  Um lote da distribuição do ADN, devolvido por `Nfse.distribution/3`.

  `status` é `:documents` quando o lote traz documentos e `:no_documents` quando a fila acabou.
  `next_nsu` é o maior NSU do lote, ou o NSU pedido quando o lote vem vazio; é o ponto de partida
  da próxima chamada.
  """

  @enforce_keys [:status, :next_nsu]
  defstruct [:status, :next_nsu, documents: [], alerts: []]

  @type t :: %__MODULE__{
          status: :documents | :no_documents,
          documents: [Nfse.DistributedDocument.t()],
          next_nsu: non_neg_integer(),
          alerts: [Nfse.Error.message()]
        }
end
