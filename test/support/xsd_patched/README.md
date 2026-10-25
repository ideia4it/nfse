# XSD 1.01 corrigido para o xmllint

Cópia de `priv/xsd/1.01` com uma única mudança, no `TSSerieDPS` de `tiposSimples_v1.01.xsd`:

```diff
-      <xs:pattern value="^0{0,4}\d{1,5}$"/>
+      <xs:pattern value="0{0,4}\d{1,5}"/>
```

No padrão XSD, `^` e `$` são caracteres literais, porque o padrão inteiro já é ancorado. O
`xmllint`, fiel a isso, recusa a série `"1"` e aceita `"^1$"` com o XSD oficial (medido em
25/10/2026). A intenção evidente do leiaute é ancorar, e é assim que `Nfse.Schema.Runtime` trata o
padrão. Esta cópia existe só para os testes conferirem com o `xmllint` o XML que a biblioteca
escreve. O XSD oficial em `priv/xsd/` nunca é editado.

Para conferir que a mudança continua sendo a única (além deste README):

```bash
diff -r priv/xsd/1.01 test/support/xsd_patched
```
