# Nfse

Biblioteca Elixir para emitir, consultar e cancelar a NFS-e pelo sistema nacional da Receita Federal, com assinatura digital da DPS e distribuição de documentos pelo ADN.

## Rodando contra a produção restrita

A suíte `test/restricted/journey_test.exs` conversa com a produção restrita da Sefin e do ADN, onde os documentos não têm validade jurídica, usando um certificado ICP-Brasil A1 de verdade. Ela fica fora do `mix test` e precisa de três variáveis de ambiente:

| Variável | Conteúdo |
|---|---|
| `NFSE_PFX_PATH` | caminho do arquivo `.pfx` do emitente |
| `NFSE_PFX_PASSWORD` | senha do `.pfx` |
| `NFSE_C_LOC_EMI` | código IBGE de sete dígitos do município do emitente |

```bash
NFSE_PFX_PATH=/caminho/certificado.pfx NFSE_PFX_PASSWORD=... NFSE_C_LOC_EMI=2927408 mix test --only restricted
```

O CNPJ do emitente sai do certificado. Sem as variáveis, a suíte falha e diz quais faltam. Cada execução emite e cancela uma nota de teste; o tomador é fictício.
