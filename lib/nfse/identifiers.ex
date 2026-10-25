defmodule Nfse.Identifiers do
  @moduledoc """
  Uso interno da biblioteca: não faz parte da API pública.

  Identificadores que a biblioteca calcula a partir dos campos do documento, como o `Id` da DPS e
  a chave de acesso da NFS-e.
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

  @doc """
  O `Id` de 59 caracteres do pedido de registro de evento: `"PRE"`, a chave de acesso da NFS-e (50
  dígitos) e o tipo do evento (6). O texto do XSD cita o número do pedido (`nPedRegEvento`), mas o
  padrão `PRE[0-9]{56}` não tem lugar para ele.
  """
  @spec event_request_id(String.t(), String.t()) :: String.t()
  def event_request_id(access_key, event_type), do: "PRE" <> access_key <> event_type

  @doc """
  A chave de acesso de 50 dígitos da NFS-e, que precedida de `"NFS"` é o `Id` do `infNFSe`: o
  código IBGE do município emissor (7), o ambiente gerador (1), o tipo da inscrição federal (1), a
  inscrição (14), o número da NFS-e (13), o ano e o mês da emissão como `YYMM` (4), o código
  numérico (9) e o dígito verificador (1), calculado por `check_digit/1` sobre os 49 anteriores.
  """
  @spec access_key(String.t(), String.t(), inscription(), String.t(), String.t(), String.t()) ::
          String.t()
  def access_key(c_mun, amb_ger, {kind, number}, n_nfse, yymm, c_num) do
    digits =
      c_mun <>
        amb_ger <>
        inscription_type(kind) <>
        zero_padded(number, 14) <> zero_padded(n_nfse, 13) <> yymm <> c_num

    digits <> check_digit(digits)
  end

  @doc """
  O dígito verificador em módulo 11, como o da NF-e: pesos de 2 a 9 a partir do último dígito, da
  direita para a esquerda, recomeçando em 2 depois do 9. Resto 0 ou 1 dá `"0"`; outro resto `r`
  dá `11 - r`.
  """
  @spec check_digit(String.t()) :: String.t()
  def check_digit(digits) do
    remainder =
      digits
      |> String.reverse()
      |> String.to_charlist()
      |> Enum.zip(Stream.cycle(2..9))
      |> Enum.reduce(0, fn {digit, weight}, sum -> sum + (digit - ?0) * weight end)
      |> rem(11)

    if remainder < 2, do: "0", else: Integer.to_string(11 - remainder)
  end

  @doc "A chave de acesso da NFS-e dentro do `Id` de um pedido de registro de evento."
  @spec event_request_access_key(String.t()) :: String.t()
  def event_request_access_key("PRE" <> <<access_key::binary-size(50), _event_type::binary>>),
    do: access_key

  # Tabela do tipo de inscrição federal do Anexo I, v1.01 de 09/02/2026.
  defp inscription_type(:cpf), do: "1"
  defp inscription_type(:cnpj), do: "2"

  defp zero_padded(digits, width), do: String.pad_leading(digits, width, "0")
end
