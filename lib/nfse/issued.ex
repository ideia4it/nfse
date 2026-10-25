defmodule Nfse.Issued do
  @moduledoc """
  NFS-e emitida pela Sefin em resposta a `Nfse.issue/2`.

  `xml` é o documento exatamente como a Sefin o devolveu, para guardar e distribuir; `nfse` é o
  mesmo documento lido como `Nfse.Schema.V1_00.TCNFSe` ou `Nfse.Schema.V1_01.TCNFSe`, conforme o
  atributo `versao`. `alerts` traz os avisos da Sefin, que não impedem a emissão, e `processed_at`
  é `nil` quando a Sefin não informa o horário com fuso.
  """

  @enforce_keys [:access_key, :dps_id, :nfse, :xml]
  defstruct [:access_key, :dps_id, :nfse, :xml, :processed_at, alerts: []]

  @type t :: %__MODULE__{
          access_key: String.t(),
          dps_id: String.t(),
          nfse: struct(),
          xml: binary(),
          alerts: [Nfse.Error.message()],
          processed_at: DateTime.t() | nil
        }
end
