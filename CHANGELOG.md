# Changelog

## 0.1.0 (2026-10-25)

Primeira versão.

- `Nfse.Client`: cliente com mTLS, ambientes `:production` e `:restricted`, tempo de espera e opções do Req, sem processo nem configuração global.
- `Nfse.Certificate`: abre o `.pfx` A1 da ICP-Brasil pelo `openssl`, lê CNPJ ou CPF, validade e `clientAuth`.
- `Nfse.DPS` e `Nfse.NFSe`: montam, validam contra o schema e assinam a DPS e a NFS-e inteira, com `Id`, `tpAmb` e chave de acesso calculados.
- `Nfse.issue/2` e `Nfse.issue_by_court_order/2`: emissão síncrona e por decisão administrativa ou judicial, enviada uma única vez e com o `dps_id` nos erros.
- `Nfse.fetch/2`, `Nfse.dps_issued?/2` e `Nfse.fetch_access_key/2`: consulta da nota e conferência da DPS depois de um resultado incerto.
- `Nfse.cancel/3`, `Nfse.register_event/2` e `Nfse.fetch_event/4`: cancelamento e demais eventos do contribuinte.
- `Nfse.distribution/3`, `Nfse.stream_distribution/3` e `Nfse.events/2`: distribuição de documentos pelo ADN, com cursor de NSU, fim de fila como sucesso e documento ilegível sem derrubar o lote.
- `Nfse.municipal_agreement/2`, `Nfse.rate/4`, `Nfse.rate_history/3`, `Nfse.special_regimes/4`, `Nfse.withholdings/3` e `Nfse.benefit/4`: parâmetros municipais do ADN.
- Módulos gerados a partir dos XSD dos leiautes 1.00 e 1.01, com tabela de campos na documentação, e leitura estrita de NFS-e e eventos.
- `Nfse.Error`: erro único com `kind`, mensagens da Sefin e `dps_id`.
- Guias em pt-BR e suíte `mix test --only restricted` para a produção restrita.
- DPS, pedido de evento e NFS-e de decisão judicial saem com a declaração `<?xml version="1.0" encoding="UTF-8"?>`, sem a qual a Sefin recusa com E1229.
- Data e hora saem sempre na hora de Brasília (`-03:00`): a Sefin lê a hora sem considerar o offset e recusava `+00:00` com E0008.
