defmodule Nfse.Schema do
  @moduledoc """
  Os leiautes da NFS-e Nacional que a biblioteca conhece.

  Cada versão tem um módulo por tipo complexo do XSD, gerado por `mix nfse.gen`, como
  `Nfse.Schema.V1_01.TCInfDPS`. A 1.01 é a versão escrita; a 1.00 só é lida, para os documentos
  emitidos antes dela.

  Os campos têm o nome do XSD em snake_case, com as siglas NFSe, DFSe, NFe e DFe contadas como
  uma palavra: `cLocEmi` vira `c_loc_emi` e `infNFSe` vira `inf_nfse`.
  """

  alias Nfse.Error

  @namespaces %{"1.00" => Nfse.Schema.V1_00, "1.01" => Nfse.Schema.V1_01}
  @root_types %{dps: "TCDPS", nfse: "TCNFSe", pedido_evento: "TCPedRegEvt", evento: "TCEvento"}

  @type root :: :dps | :nfse | :pedido_evento | :evento

  @doc """
  Devolve o módulo do documento raiz `root` na versão do leiaute `version`, como o atributo
  `versao` do XML a traz.

      iex> Nfse.Schema.root("1.01", :nfse)
      {:ok, Nfse.Schema.V1_01.TCNFSe}
  """
  @spec root(String.t(), root()) :: {:ok, module()} | {:error, Error.t()}
  def root(version, root) when is_map_key(@root_types, root) do
    case @namespaces do
      %{^version => namespace} ->
        {:ok, Module.concat(namespace, @root_types[root])}

      _unsupported ->
        {:error, %Error{kind: :unexpected, details: {:unsupported_version, version}}}
    end
  end
end
