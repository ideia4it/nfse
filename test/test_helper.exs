# A tag :openssl3 marca o que depende dos providers do OpenSSL 3 em diante. Com outro openssl
# (LibreSSL, OpenSSL 1.1), esses testes ficam de fora em vez de falhar.
openssl_with_providers? =
  with executable when is_binary(executable) <- System.find_executable("openssl"),
       {"OpenSSL " <> version, 0} <- System.cmd(executable, ["version"]),
       {major, _rest} <- Integer.parse(version) do
    major >= 3
  else
    _other -> false
  end

ExUnit.start(exclude: [:restricted | if(openssl_with_providers?, do: [], else: [:openssl3])])
