defmodule Nfse.RestrictedEnvironment do
  @moduledoc false

  alias Nfse.{Certificate, Client}

  @variables ["NFSE_PFX_PATH", "NFSE_PFX_PASSWORD", "NFSE_C_LOC_EMI", "NFSE_TOMADOR_CPF"]

  @doc """
  Monta o cliente da produção restrita a partir das variáveis de ambiente e devolve também o
  código IBGE do município do emitente, o CPF do tomador e, se houver, a inscrição municipal do
  prestador. Levanta, nomeando as variáveis, quando faltam; a suíte nunca passa em silêncio sem
  credencial.
  """
  def fetch! do
    case Enum.reject(@variables, &present?/1) do
      [] -> build!()
      missing -> raise missing_message(missing)
    end
  end

  defp build! do
    pfx_path = System.fetch_env!("NFSE_PFX_PATH")

    with {:ok, bundle} <- File.read(pfx_path),
         {:ok, certificate} <-
           Certificate.from_pfx(bundle, System.fetch_env!("NFSE_PFX_PASSWORD")),
         {:ok, client} <- Client.new(certificate: certificate, environment: :restricted) do
      %{
        client: client,
        c_loc_emi: System.fetch_env!("NFSE_C_LOC_EMI"),
        taker_cpf: System.fetch_env!("NFSE_TOMADOR_CPF"),
        provider_im: System.get_env("NFSE_PRESTADOR_IM", "")
      }
    else
      {:error, reason} ->
        raise "Não foi possível abrir o certificado de NFSE_PFX_PATH: #{failure(reason)}"
    end
  end

  defp present?(variable), do: System.get_env(variable) not in [nil, ""]

  defp missing_message(missing) do
    "A suíte da produção restrita precisa de variáveis de ambiente que não estão definidas: " <>
      Enum.join(missing, ", ") <>
      ". Veja a seção \"Rodando contra a produção restrita\" do README."
  end

  defp failure(%Nfse.Error{kind: kind, details: details}), do: "#{kind} #{inspect(details)}"
  defp failure(posix) when is_atom(posix), do: "arquivo ilegível (#{posix})"
end
