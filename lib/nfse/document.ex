defmodule Nfse.Document do
  @moduledoc """
  NFS-e consultada na Sefin por `Nfse.fetch/2`.

  `xml` é o documento como a Sefin o devolveu e `nfse` é o mesmo documento lido como
  `Nfse.Schema.V1_00.TCNFSe` ou `Nfse.Schema.V1_01.TCNFSe`, conforme o atributo `versao`.
  """

  @enforce_keys [:access_key, :nfse, :xml]
  defstruct [:access_key, :nfse, :xml]

  @type t :: %__MODULE__{access_key: String.t(), nfse: struct(), xml: binary()}
end
