defmodule Nfse.Event do
  @moduledoc """
  Evento registrado pela Sefin em resposta a `Nfse.register_event/2` e `Nfse.cancel/3`, ou
  consultado por `Nfse.fetch_event/4`.

  `xml` é o evento exatamente como a Sefin o devolveu, para guardar e distribuir; `evento` é o
  mesmo documento lido como `Nfse.Schema.V1_00.TCEvento` ou `Nfse.Schema.V1_01.TCEvento`, conforme
  o atributo `versao`.
  """

  @enforce_keys [:access_key, :evento, :xml]
  defstruct [:access_key, :evento, :xml]

  @type t :: %__MODULE__{access_key: String.t(), evento: struct(), xml: binary()}
end
