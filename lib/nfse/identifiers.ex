defmodule Nfse.Identifiers do
  @moduledoc """
  Uso interno da biblioteca: não faz parte da API pública.

  Identificadores que a biblioteca calcula a partir dos campos do documento, como o `Id` da DPS.
  As funções esperam campos já validados pelo schema.
  """

  @type inscription :: {:cnpj | :cpf, String.t()}

  @doc """
  O `Id` de 45 caracteres da DPS: `"DPS"`, o código IBGE do município emissor (7 dígitos), o tipo
  da inscrição federal (`"1"` para CPF, `"2"` para CNPJ), a inscrição (14), a série (5) e o número
  (15), cada parte completada com zeros à esquerda só dentro do `Id`.
  """
  @spec dps_id(String.t(), inscription(), String.t(), String.t()) :: String.t()
  def dps_id(c_loc_emi, {kind, number}, serie, n_dps) do
    "DPS" <>
      c_loc_emi <>
      inscription_type(kind) <>
      zero_padded(number, 14) <> zero_padded(serie, 5) <> zero_padded(n_dps, 15)
  end

  # Tabela do tipo de inscrição federal do Anexo I, v1.01 de 09/02/2026.
  defp inscription_type(:cpf), do: "1"
  defp inscription_type(:cnpj), do: "2"

  defp zero_padded(digits, width), do: String.pad_leading(digits, width, "0")
end
