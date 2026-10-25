defmodule Nfse.Schema.Field do
  @moduledoc """
  Um elemento ou atributo de um tipo complexo do XSD, como o descritor de cada módulo de schema o
  declara em `__schema__(:fields)` e `__schema__(:attributes)`.

  | Campo | Significado |
  |---|---|
  | `name` | a chave no struct, o nome do XSD em snake_case |
  | `xml` | o nome do elemento ou do atributo no XML |
  | `type` | `{:simple, nome_do_tipo}`, `{:complex, módulo}` ou `:signature` |
  | `min` | `0` quando o campo é opcional, `1` quando é obrigatório |
  | `max` | quantas vezes o elemento pode aparecer; acima de 1, o campo guarda uma lista |
  | `choice` | o índice do `choice` de que o campo faz parte, ou `nil` |

  Num `choice`, o `min` do ramo não torna o campo obrigatório sozinho. O `choice` exige um ramo
  quando o `min` dele, em `__schema__(:choices)`, é 1 e cada ramo tem `min` 1; se algum ramo tem
  `min` 0, ele pode ser escolhido vazio, e nenhum ramo preenchido é válido. Dois ramos preenchidos
  são sempre erro.
  """

  @enforce_keys [:name, :xml, :type, :min, :max]
  defstruct [:name, :xml, :type, :min, :max, choice: nil]

  @type type :: {:simple, String.t()} | {:complex, module()} | :signature

  @type t :: %__MODULE__{
          name: atom(),
          xml: String.t(),
          type: type(),
          min: 0 | 1,
          max: pos_integer() | :unbounded,
          choice: non_neg_integer() | nil
        }
end
