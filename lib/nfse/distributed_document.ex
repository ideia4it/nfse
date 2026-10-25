defmodule Nfse.DistributedDocument do
  @moduledoc """
  Documento fiscal entregue pela distribuição do ADN.

  `type` vem de `TipoDocumento`; um valor fora dos seis conhecidos vira `:unknown`. `event_type`
  é o `TipoEvento` do ADN, como `"CANCELAMENTO"`, e é `nil` nas notas.

  `xml` é o documento como o ADN o entregou. `document` é o mesmo documento lido como NFS-e ou
  evento (`Nfse.Schema.V1_00.TCNFSe`, `Nfse.Schema.V1_01.TCEvento` e assim por diante), e só os
  tipos `:nfse` e `:evento` são lidos; nos demais ele é `nil` e `error` também.

  Um documento ilegível (base64 ou gzip inválido, versão desconhecida, XML malformado) não derruba
  o lote: `document` fica `nil`, `xml` guarda o texto quando houve algum e `error` traz a falha.

  `generated_at` é um `DateTime` quando `DataHoraGeracao` traz o deslocamento de fuso e um
  `NaiveDateTime` quando não traz, sem adivinhar o fuso. É `nil` quando o campo falta ou não se lê.
  """

  @enforce_keys [:nsu, :type]
  defstruct [
    :nsu,
    :access_key,
    :type,
    :event_type,
    :xml,
    :document,
    :error,
    :generated_at
  ]

  @type type :: :nfse | :evento | :dps | :pedido_registro_evento | :cnc | :nenhum | :unknown

  @type t :: %__MODULE__{
          nsu: non_neg_integer(),
          access_key: String.t() | nil,
          type: type(),
          event_type: String.t() | nil,
          xml: binary() | nil,
          document: struct() | nil,
          error: Nfse.Error.t() | nil,
          generated_at: DateTime.t() | NaiveDateTime.t() | nil
        }
end
