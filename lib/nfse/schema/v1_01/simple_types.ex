# Gerado por `mix nfse.gen` a partir de tiposCnc_v1.00.xsd, tiposComplexos_v1.01.xsd, tiposEventos_v1.01.xsd e tiposSimples_v1.01.xsd. Não edite.
defmodule Nfse.Schema.V1_01.SimpleTypes do
  @moduledoc """
  Tipos simples do leiaute 1.01: as facetas de cada um, com as da base quando o tipo deriva de outro, e a representação em Elixir. `TSDec<i>V<f>` vira `Decimal`, `TSData` e o `xs:date` usado direto num elemento viram `Date`, `TSDateTimeUTC` vira `DateTime` e o resto fica texto.

  | Tipo | Representação | Descrição |
  |---|---|---|
  | `TBMISSQN` | texto | Tipo Benefício Municipal (BM): 1) Isenção; 2) Redução da BC em 'ppBM' %; 3) Redução da BC em R$ 'vInfoBM'; 4) Alíquota Diferenciada de 'aliqDifBM' %; |
  | `TCCodTribMun` | texto | Código de tributação municipal do ISSQN |
  | `TCObjetoLocacao` | texto | Tipo de objetos da locação, sublocação, arrendamento, direito de passagem ou permissão de uso: 1 - Ferrovia; 2 - Rodovia; 3 - Postes; 4 - Cabos; 5 - Dutos; 6 - Condutos de qualquer natureza; |
  | `TE101101.xDesc` | texto |  |
  | `TE101103.xDesc` | texto |  |
  | `TE105102.xDesc` | texto |  |
  | `TE105104.xDesc` | texto |  |
  | `TE105105.xDesc` | texto |  |
  | `TE202201.xDesc` | texto |  |
  | `TE202205.xDesc` | texto |  |
  | `TE203202.xDesc` | texto |  |
  | `TE203206.xDesc` | texto |  |
  | `TE204203.xDesc` | texto |  |
  | `TE204207.xDesc` | texto |  |
  | `TE205204.xDesc` | texto |  |
  | `TE205208.xDesc` | texto |  |
  | `TE305101.xDesc` | texto |  |
  | `TE305102.xDesc` | texto |  |
  | `TE305103.xDesc` | texto |  |
  | `TSAmbGeradorEvt` | texto | Tipo Ambiente gerador do evento: 1- Prefeitura; 2- Sefin Nacional; 3- Ambiente Nacional. |
  | `TSAmbGeradorNFSe` | texto | Tipo Ambiente Gerador de NFS-e: 1 - Prefeitura; 2 - Sistema Nacional da NFS-e; |
  | `TSBairro` | texto | Bairro |
  | `TSCAEPF` | texto | Tipo Número do CAEPF |
  | `TSCEP` | texto | CEP |
  | `TSCNPJ` | texto | Tipo Número do CNPJ |
  | `TSCPF` | texto | Tipo Número do CPF |
  | `TSCategVeic` | texto | Categorias de veículos para cobrança: 00 - Categoria de veículos (tipo não informado na nota de origem) 01 - Automóvel, caminhonete e furgão; 02 - Caminhão leve, ônibus, caminhão trator e furgão; 03 - Automóvel e caminhonete com semireboque; 04 - Caminhão, caminhão-trator, caminhão-trator com semi-reboque e ônibus; 05 - Automóvel e caminhonete com reboque; 06 - Caminhão com reboque; 07 - Caminhão trator com semi-reboque; 08 - Motocicletas, motonetas e bicicletas motorizadas; 09 - Veículo especial; 10 - Veículo Isento; |
  | `TSCategoriaServico` | texto | Categorias do serviço: 1 - Locação; 2 - Sublocação; 3 - Arrendamento; 4 - Direito de passagem; 5 - Permissão de uso; |
  | `TSChaveNFSe` | texto | Tipo Chave da Nota Fiscal de Serviço Eletrônica |
  | `TSChaveNFe` | texto | Tipo Chave da Nota Fiscal Eletrônica - NF-e |
  | `TSCidade` | texto | Cidade |
  | `TSCodAcessoPed` | texto |  |
  | `TSCodAutorManifestacao` | texto | Tipo do autor da manifestação da NFS-e: 1 - Prestador; 2 - Tomador; 3 - Intermediário. |
  | `TSCodCIB` | texto |  |
  | `TSCodContrato` | texto |  |
  | `TSCodJustAnaliseFiscalCanc` | texto | Código do motivo da solicitação de análise fiscal para cancelamento de NFS-e: 1 - Erro na Emissão; 2 - Serviço não Prestado; 3 - Outros. |
  | `TSCodJustAnaliseFiscalCancDef` | texto | Resposta da análise da solicitação do cancelamento extemporâneo de NFS-e: 1 - Cancelamento Extemporâneo Deferido. |
  | `TSCodJustAnaliseFiscalCancIndef` | texto | Resposta da análise da solicitação do cancelamento extemporâneo de NFS-e: 1 - Cancelamento Extemporâneo Indeferido; 2 - Cancelamento Extemporâneo Indeferido Sem Análise de Mérito. |
  | `TSCodJustCanc` | texto | Código de justificativa de cancelamento: 1 - Erro na Emissão; 2 - Serviço não Prestado; 9 - Outros; |
  | `TSCodJustSubst` | texto | Código de justificativa para substituição de NFS-e: 01 - Desenquadramento de NFS-e do Simples Nacional; 02 - Enquadramento de NFS-e no Simples Nacional; 03 - Inclusão Retroativa de Imunidade/Isenção para NFS-e; 04 - Exclusão Retroativa de Imunidade/Isenção para NFS-e; 05 - Rejeição de NFS-e pelo tomador ou pelo intermediário se responsável pelo recolhimento do tributo; 99 - Outros; |
  | `TSCodMoeda` | texto | Tipo com código que identifica a moeda conforme tabela do BACEN |
  | `TSCodMotivoRejeicao` | texto | Motivo da Rejeição da NFS-e: 1 - NFS-e em duplicidade; 2 - NFS-e já emitida pelo tomador; 3 - Não ocorrência do fato gerador; 4 - Erro quanto a responsabilidade tributária; 5 - Erro quanto ao valor do serviço, valor das deduções ou serviço prestado ou data do fato gerador; 9 - Outros; |
  | `TSCodMunIBGE` | texto | Tipo Código do Município segundo tabela IBGE |
  | `TSCodNBS` | texto | Código da lista de Nomenclatura Brasileira de Serviços (NBS) |
  | `TSCodNaoNIF` | texto | Motivo para não informação do NIF: 0 - Não informado na nota de origem; 1 - Dispensado do NIF; 2 - Não exigência do NIF; |
  | `TSCodObra` | texto |  |
  | `TSCodPaisISO` | texto | Tipo Código do País segundo tabela ISO |
  | `TSCodTribNac` | texto | Código de tributação nacional do ISSQN: Regra de formação - 6 dígitos numéricos sendo: 2 para Item (LC 116/2003), 2 para Subitem (LC 116/2003) e 2 para Desdobro Nacional |
  | `TSCodVerificacao` | texto |  |
  | `TSCodigoEndPostal` | texto | Código de enderaçamento postal |
  | `TSCodigoEventoNFSe` | texto | Código de evento da NFS-e |
  | `TSCodigoInternoContribuinte` | texto |  |
  | `TSComplementoEndereco` | texto | Complemento |
  | `TSDRT` | texto |  |
  | `TSData` | `Date` | Tipo data no formato AAAA-MM-DD |
  | `TSDateTimeUTC` | `DateTime` | Data e Hora, formato UTC (AAAA-MM-DDThh:mm:ssTZD, onde TZD = +hh:mm ou -hh:mm) |
  | `TSDec15V2` | `Decimal`, até 15 dígitos inteiros e 2 casas | Valor decimal com 1 a 15 dígitos mais 2 casas decimais |
  | `TSDec1V2` | `Decimal`, até 1 dígitos inteiros e 2 casas | Valor decimal com 1 dígito mais 2 casas decimais |
  | `TSDec2V2` | `Decimal`, até 2 dígitos inteiros e 2 casas | Valor decimal com 1 ou 2 dígitos mais 2 casas decimais |
  | `TSDec3V2` | `Decimal`, até 3 dígitos inteiros e 2 casas | Valor decimal com 1 a 3 dígitos mais 2 casas decimais |
  | `TSDesc1000` | texto |  |
  | `TSDesc150` | texto |  |
  | `TSDesc2000` | texto |  |
  | `TSDesc255` | texto |  |
  | `TSDesc40` | texto |  |
  | `TSDesc500` | texto |  |
  | `TSDesc600` | texto |  |
  | `TSDescInfCompl` | texto |  |
  | `TSDescOutDedRed` | texto | Descrição da Dedução/Redução quando a opção é "99 – Outras Deduções" |
  | `TSEmail` | texto |  |
  | `TSEmitenteDPS` | texto | Emitente da DPS: 1 - Prestador 2 - Tomador 3 - Intermediário |
  | `TSEnderCompletoExt` | texto |  |
  | `TSEnvMDIC` | texto | Compartilhar as informações da NFS-e gerada a partir desta DPS com a Secretaria de Comércio Exterior: 0 - Não enviar para o MDIC; 1 - Enviar para o MDIC; |
  | `TSEstadoProvRegiao` | texto | Estado, província ou região |
  | `TSExtensaoTotal` | texto | Extensão total da ferrovia, rodovia, cabos, dutos ou condutos |
  | `TSIdDPS` | texto | Informar o identificador precedido do literal ‘DPS’. A regra de formação do identificador de 45 posições da DPS é: "DPS" + Cód.Mun (7) + Tipo de Inscrição Federal (1) + Inscrição Federal (14 - CPF completar com 000 à esquerda) + Série DPS (5)+ Núm. DPS (15) |
  | `TSIdEvento` | texto | Identificador do evento: "EVT" + Chave de acesso(50) Tipo do evento (6) + Pedido de Registro do Evento(3) (nPedRegEvento) |
  | `TSIdNFSe` | texto | Informar o identificador precedido do literal ‘NFS’. A regra de formação do identificador de 53 posições da NFS-e é: "NFS" + Cód.Mun.(7) + Amb.Ger.(1) + Tipo de Inscrição Federal(1) + Inscrição Federal(14) + No.NFS-e(13) + AnoMes Emis.(4) + Cód.Num.(9) + DV(1) |
  | `TSIdNumEvento` | texto | Referência ao Id "Manifestação de rejeição da NFS-e" que originou o presente evento de anulação. |
  | `TSIdPedRegEvt` | texto | O identificador do pedido de registro do evento é formado conforme a concatenação dos seguintes campos: "PRE" + Chave de Acesso NFS-e + Tipo do evento + Número do Pedido de Registro do Evento (nPedRegEvento) |
  | `TSIdeDedRed` | texto | Identificação da Dedução/Redução: 1 – Alimentação e bebidas/frigobar; 2 – Materiais; 3 - Produção Externa; 4 - Reembolso de despesas; 5 – Repasse consorciado; 6 – Repasse plano de saúde; 7 – Serviços; 8 – Subempreitada de mão de obra; 9 - Profissional parceiro; 99 – Outras deduções; |
  | `TSIdeEvento` | texto | Identificação da Atividade de Evento (código identificador de evento determinado pela Administração Tributária Municipal) |
  | `TSInscImobFisc` | texto |  |
  | `TSInscMun` | texto |  |
  | `TSLogradouro` | texto | Logradouro |
  | `TSMecAFComExPrest` | texto | Mecanismo de apoio/fomento ao Comércio Exterior utilizado pelo prestador do serviço: 00 - Desconhecido (tipo não informado na nota de origem); 01 - Nenhum; 02 - ACC - Adiantamento sobre Contrato de Câmbio – Redução a Zero do IR e do IOF; 03 - ACE – Adiantamento sobre Cambiais Entregues - Redução a Zero do IR e do IOF; 04 - BNDES-Exim Pós-Embarque – Serviços; 05 - BNDES-Exim Pré-Embarque - Serviços; 06 - FGE - Fundo de Garantia à Exportação; 07 - PROEX - EQUALIZAÇÃO 08 - PROEX - Financiamento; |
  | `TSMecAFComExToma` | texto | Mecanismo de apoio/fomento ao Comércio Exterior utilizado pelo tomador do serviço: 00 - Desconhecido (tipo não informado na nota de origem); 01 - Nenhum; 02 - Adm. Pública e Repr. Internacional; 03 - Alugueis e Arrend. Mercantil de maquinas, equip., embarc. e aeronaves; 04 - Arrendamento Mercantil de aeronave para empresa de transporte aéreo público; 05 - Comissão a agentes externos na exportação; 06 - Despesas de armazenagem, mov. e transporte de carga no exterior; 07 - Eventos FIFA (subsidiária); 08 - Eventos FIFA; 09 - Fretes, arrendamentos de embarcações ou aeronaves e outros; 10 - Material Aeronáutico; 11 - Promoção de Bens no Exterior; 12 - Promoção de Dest. Turísticos Brasileiros; 13 - Promoção do Brasil no Exterior; 14 - Promoção Serviços no Exterior; 15 - RECINE; 16 - RECOPA; 17 - Registro e Manutenção de marcas, patentes e cultivares; 18 - REICOMP; 19 - REIDI; 20 - REPENEC; 21 - REPES; 22 - RETAERO; 23 - RETID; 24 - Royalties, Assistência Técnica, Científica e Assemelhados; 25 - Serviços de avaliação da conformidade vinculados aos Acordos da OMC; 26 - ZPE; |
  | `TSModoPrestacao` | texto | Modo de Prestação: 0 - Desconhecido (tipo não informado na nota de origem); 1 - Transfronteiriço; 2 - Consumo no Brasil; 3 - Presença Comercial no Exterior; 4 - Movimento Temporário de Pessoas Físicas; |
  | `TSMotivo` | texto | Descrição do motivo da substituição da NFS-e |
  | `TSMotivoEmisTI` | texto | Motivo da Emissão da DPS pelo Tomador/Intermediário: 1 - Importação de Serviço; 2 - Tomador/Intermediário obrigado a emitir NFS-e por legislação municipal; 3 - Tomador/Intermediário emitindo NFS-e por recusa de emissão pelo prestador; 4 - Tomador/Intermediário emitindo por rejeitar a NFS-e emitida pelo prestador; |
  | `TSMotivoSituacaoCadastroContribuinte` | texto | Motivo pelo qual o contribuinte se enquadra na situação informada |
  | `TSMovTempBens` | texto | Vínculo da Operação à Movimentação Temporária de Bens: 0 - Desconhecido (tipo não informado na nota de origem); 1 - Não; 2 - Vinculada - Declaração de Importação; 3 - Vinculada - Declaração de Exportação; |
  | `TSNDFSe` | texto | Tipo Número do DFS-e |
  | `TSNIF` | texto |  |
  | `TSNNFSe` | texto | Tipo Número sequencial do documento |
  | `TSNomeFantasia` | texto |  |
  | `TSNomeRazaoSocial` | texto |  |
  | `TSNum14Dig` | texto | Número com 14 dígitos |
  | `TSNum15Dig` | texto | Número com 15 dígitos |
  | `TSNum3Dig` | texto | Número com 3 dígitos |
  | `TSNum7Dig` | texto | Número com 7 dígitos |
  | `TSNumBeneficioMunicipal` | texto | Identificador do benefício parametrizado pelo município. Trata-se de um identificador único que foi gerado pelo Sistema Nacional no momento em que o município de incidência do ISSQN incluiu o benefício no sistema. Critério de formação do número de identificação de parâmetros municipais: 7 dígitos - posição 1 a 7: número identificador do Município, conforme código IBGE; 2 dígitos - posições 8 e 9 : número identificador do tipo de parametrização (01-legislação, 02-regimes especiais, 03-retenções, 04-outros benefícios); 5 dígitos - posição 10 a 14 : número sequencial definido pelo sistema quando do registro específico do parâmetro dentro do tipo de parametrização no sistema; |
  | `TSNumDFe` | texto | Número sequencial do documento gerado por ambiente gerador de DFe do município. |
  | `TSNumDPS` | texto | Tipo Número do DPS |
  | `TSNumDocImport` | texto | Número da Declaração de Importação (DI/DSI/DA/DRI-E) averbado |
  | `TSNumEixos` | texto | Número de eixos para fins de cobrança |
  | `TSNumProcAdmAnaliseFiscalCanc` | texto | Número do processo administrativo municipal vinculado à solicitação de cancelamento extemporâneo de NFS-e. |
  | `TSNumProcExigSuspensa` | texto | Número do processo judicial ou administrativo de suspensão da exigibilidade |
  | `TSNumProcesso` | texto | Número do processo judicial ou administrativo de suspensão da exigibilidade. |
  | `TSNumRegExport` | texto | Número do Registro de Exportação (RE) averbado |
  | `TSNumeroEndereco` | texto | Número |
  | `TSNumeroPostes` | texto | Número total de postes |
  | `TSOpConsumServ` | texto | Opção para que o emitente informe onde ocorreu o consumo do serviço prestado. 0 - Consumo do serviço prestado ocorrido no município do local da prestação; 1 - Consumo do serviço prestado ocorrido ocorrido no exterior ; |
  | `TSOpExigSuspensa` | texto | Opção para Exigibilidade Suspensa: 1 - Exigibilidade Suspensa por Decisão Judicial; 2 - Exigibilidade Suspensa por Processo Administrativo; |
  | `TSOpSNLimUltrap` | texto | Opção que indica se o limite do Simples Nacional foi ultrapassado: 0 - Não ultrapassado; 1 - Ultrapassado; |
  | `TSOpSimpNac` | texto | Situação perante o Simples Nacional: 1 - Não Optante; 2 - Optante - Microempreendedor Individual (MEI); 3 - Optante - Microempresa ou Empresa de Pequeno Porte (ME/EPP); |
  | `TSPlaca` | texto |  |
  | `TSProcEmissao` | texto | Processo de Emissão da DPS: 1 - Emissão com aplicativo do contribuinte (via Web Service); 2 - Emissão com aplicativo disponibilizado pelo fisco (Web); 3 - Emissão com aplicativo disponibilizado pelo fisco (App); |
  | `TSRTCChaveDFe` | texto | Chave do Documento Fiscal Eletrônico |
  | `TSRTCCodClassTrib` | texto | Código de Classificação Tributária |
  | `TSRTCCodCredPres` | texto | Código e Classificação do Crédito Presumido |
  | `TSRTCCodIndOp` | texto | Código indicador da operação de fornecimento, conforme tabela "código indicador de operação" |
  | `TSRTCCodSitTrib` | texto | Código de Situação Tributária |
  | `TSRTCFinNFSe` | texto | Indicador da finalidade da emissão de NFS-e: 0 - NFS-e regular; |
  | `TSRTCIndDest` | texto | A respeito do Destinatário dos serviços: 0 – o destinatário é o próprio tomador/adquirente identificado na NFS-e (tomador = adquirente = destinatário); 1 – o destinatário não é o próprio adquirente, podendo ser outra pessoa, física ou jurídica (ou equiparada), ou um estabelecimento diferente do indicado como tomador (tomador = adquirente ≠ destinatário); |
  | `TSRTCIndFinal` | texto | Indica operação de uso ou consumo pessoal (art. 57): 0 - Não; 1 - Sim; |
  | `TSRTCTipoChaveDFe` | texto | Documento fiscal a que se refere a chaveDfe que seja um dos documentos do Repositório Nacional: 1 - NFS-e; 2 - NF-e; 3 - CT-e; 9 - Outro; |
  | `TSRTCTpEnteGov` | texto | Tipo de ente governamental Para administração pública direta e suas autarquias e fundações: 1 - União; 2 - Estado; 3 - Distrito Federal; 4 - Município; |
  | `TSRTCTpOper` | texto | Tipo de Operação com Entes Governamentais ou outros serviços sobre bens imóveis: 1 – Fornecimento com pagamento posterior; 2 - Recebimento do pagamento com fornecimento já realizado; 3 – Fornecimento com pagamento já realizado; 4 – Recebimento do pagamento com fornecimento posterior; 5 – Fornecimento e recebimento do pagamento concomitantes; |
  | `TSRTCTpReeRepRes` | texto | Tipo de valor incluído neste documento, recebido por motivo de estarem relacionadas a operações de terceiros, objeto de reembolso, repasse ou ressarcimento pelo recebedor, já tributados e aqui referenciados 01 - Repasse de remuneração por intermediação de imóveis a demais corretores envolvidos na operação; 02 - Repasse de valores a fornecedor relativo a fornecimento intermediado por agência de turismo; 03 - Reembolso ou ressarcimento recebido por agência de propaganda e publicidade por valores pagos relativos a serviços de produção externa por conta e ordem de terceiro; 04 - Reembolso ou ressarcimento recebido por agência de propaganda e publicidade por valores pagos relativos a serviços de mídia por conta e ordem de terceiro; 99 - Outros reembolsos ou ressarcimentos recebidos por valores pagos relativos a operações por conta e ordem de terceiro; |
  | `TSRegEspTrib` | texto | Tipos de Regimes Especiais de Tributação: 0 - Nenhum; 1 - Ato Cooperado (Cooperativa); 2 - Estimativa; 3 - Microempresa Municipal; 4 - Notário ou Registrador; 5 - Profissional Autônomo; 6 - Sociedade de Profissionais; 9 - Outros; |
  | `TSRegimeApuracaoSimpNac` | texto | Opção para que o contribuinte optante pelo Simples Nacional ME/EPP (opSimpNac = 3) possa indicar, ao emitir o documento fiscal, em qual regime de apuração os tributos federais e municipal estão inseridos, caso tenha ultrapassado algum sublimite ou limite definido para o Simples Nacional. 1 – Regime de apuração dos tributos federais e municipal pelo SN; 2 – Regime de apuração dos tributos federais pelo SN e ISSQN por fora do SN conforme respectiva legislação municipal do tributo; 3 – Regime de apuração dos tributos federais e municipal por fora do SN conforme respectivas legislações federal e municipal de cada tributo; |
  | `TSRodagem` | texto | Tipo de rodagem: 1 - Simples; 2 - Dupla; |
  | `TSSentido` | texto | Orientação de passagem do veículo: ângulo em graus a partir do norte geográfico em sentido horário, número inteiro de 0 a 359, onde 0º seria o norte, 90º o leste, 180º o sul, 270º o oeste. Precisão mínima de 10 |
  | `TSSerieDPS` | texto |  |
  | `TSSerieNFNFS` | texto |  |
  | `TSSituacaoCadastroContribuinte` | texto | Identificação da situação do cadastro do contribuinte |
  | `TSSituacaoEmissaoNFSE` | texto | Situação Emissão NFS-e: 0 - Não Habilitado; 1 - Habilitado; |
  | `TSString` | texto | Tipo string genérico |
  | `TSStringComQuebraDeLinha` | texto | Tipo string genérico |
  | `TSTelefone` | texto | Número do telefone do prestador: Preencher com o Código DDD + número do telefone. Nas operações com exterior é permitido informar o código do país + código da localidade + número do telefone |
  | `TSTipoAmbiente` | texto | Tipos de ambiente do Sistema Nacional NFS-e: 1 - Produção; 2 - Homologação; |
  | `TSTipoCST` | texto | Código de Situação Tributária do PIS/COFINS (CST): 00 - Nenhum; 01 - Operação Tributável com Alíquota Básica; 02 - Operação Tributável com Alíquota Diferenciada; 03 - Operação Tributável com Alíquota por Unidade de Medida de Produto; 04 - Operação Tributável monofásica - Revenda a Alíquota Zero; 05 - Operação Tributável por Substituição Tributária; 06 - Operação Tributável a Alíquota Zero; 07 - Operação Isenta da Contribuição; 08 - Operação sem Incidência da Contribuição; 09 - Operação com Suspensão da Contribuição; 49 - Outras Operações de Saída; 50 - Operação com Direito a Crédito – Vinculada Exclusivamente a Receita Tributada no Mercado Interno; 51 - Operação com Direito a Crédito – Vinculada Exclusivamente a Receita Não-Tributada no Mercado Interno; 52 - Operação com Direito a Crédito – Vinculada Exclusivamente a Receita de Exportação; 53 - Operação com Direito a Crédito – Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno; 54 - Operação com Direito a Crédito – Vinculada a Receitas Tributadas no Mercado Interno e de Exportação; 55 - Operação com Direito a Crédito – Vinculada a Receitas Não Tributadas no Mercado Interno e de Exportação; 56 - Operação com Direito a Crédito – Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno e de Exportação; 60 - Crédito Presumido – Operação de Aquisição Vinculada Exclusivamente a Receita Tributada no Mercado Interno; 61 - Crédito Presumido – Operação de Aquisição Vinculada Exclusivamente a Receita Não-Tributada no Mercado Interno; 62 - Crédito Presumido – Operação de Aquisição Vinculada Exclusivamente a Receita de Exportação; 63 - Crédito Presumido – Operação de Aquisição Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno; 64 - Crédito Presumido – Operação de Aquisição Vinculada a Receitas Tributadas no Mercado Interno e de Exportação; 65 - Crédito Presumido – Operação de Aquisição Vinculada a Receitas Não-Tributadas no Mercado Interno e de Exportação; 66 - Crédito Presumido – Operação de Aquisição Vinculada a Receitas Tributadas e Não-Tributadas no Mercado Interno e de Exportação; 67 - Crédito Presumido – Outras Operações; 70 - Operação de Aquisição sem Direito a Crédito; 71 - Operação de Aquisição com Isenção; 72 - Operação de Aquisição com Suspensão; 73 - Operação de Aquisição a Alíquota Zero; 74 - Operação de Aquisição sem Incidência da Contribuição; 75 - Operação de Aquisição por Substituição Tributária; 98 - Outras Operações de Entrada; 99 - Outras Operações; |
  | `TSTipoEmissao` | texto | Tipo de emissão da NFS-e: 1 - Emissão normal no modelo da NFS-e Nacional; 2 - Emissão original em leiaute próprio do município com transcrição para o modelo da NFS-e Nacional. |
  | `TSTipoImunidadeISSQN` | texto | Identificação da Imunidade do ISSQN – somente para o caso de Imunidade. Tipos de Imunidades: 0 - Imunidade (tipo não informado na nota de origem); 1 - Patrimônio, renda ou serviços, uns dos outros (CF88, Art 150, VI, a); 2 - Templos de qualquer culto (CF88, Art 150, VI, b); 3 - Patrimônio, renda ou serviços dos partidos políticos, inclusive suas fundações, das entidades sindicais dos trabalhadores, das instituições de educação e de assistência social, sem fins lucrativos, atendidos os requisitos da lei (CF88, Art 150, VI, c); 4 - Livros, jornais, periódicos e o papel destinado a sua impressão (CF88, Art 150, VI, d); 5 - Fonogramas e videofonogramas musicais produzidos no Brasil contendo obras musicais ou literomusicais de autores brasileiros e/ou obras em geral interpretadas por artistas brasileiros bem como os suportes materiais ou arquivos digitais que os contenham, salvo na etapa de replicação industrial de mídias ópticas de leitura a laser. (CF88, Art 150, VI, e); |
  | `TSTipoIndTotTrib` | texto | Indicador de informação de valor total de tributos. Possui valor fixo igual a zero (indTotTrib=0). Não informar nenhum valor estimado para os Tributos (Decreto 8.264/2014). 0 - Não; |
  | `TSTipoRetISSQN` | texto | Tipo de retencao do ISSQN: 1 - Não Retido; 2 - Retido pelo Tomador; 3 - Retido pelo Intermediario; |
  | `TSTipoRetPISCofins` | texto | Tipo de retencao do Pis/Cofins: 0 - PIS/COFINS/CSLL Não Retidos; 1 - PIS/COFINS Retidos; 2 - PIS/COFINS Não Retidos; 3 - PIS/COFINS/CSLL Retidos; 4 - PIS/COFINS Retidos, CSLL Não Retido; 5 - PIS Retido, COFINS/CSLL Não Retido; 6 - COFINS Retido, PIS/CSLL Não Retido; 7 - PIS Não Retido, COFINS/CSLL Retidos; 8 - PIS/COFINS Não Retidos, CSLL Retido; 9 - COFINS Não Retido, PIS/CSLL Retidos; |
  | `TSTribISSQN` | texto | Tributação do ISSQN sobre o serviço prestado: 1 - Operação tributável; 2 - Imunidade; 3 - Exportação de serviço; 4 - Não Incidência; |
  | `TSUF` | texto | Tipo Sigla da UF |
  | `TSVerAplic` | texto | Tipo Versão do Aplicativo que gerou o documento fiscal |
  | `TSVincPrest` | texto | Vínculo entre as partes no negócio: 0 - Sem vínculo com o Tomador/Prestador 1 - Controlada; 2 - Controladora; 3 - Coligada; 4 - Matriz; 5 - Filial ou sucursal; 6 - Outro vínculo; 9 - Desconhecido (tipo não informado na nota de origem); |
  | `TStat` | texto | Situações possíveis: 100 - NFS-e Gerada; 102 - NFS-e de Decisão Judicial; 103 - NFS-e Avulsa; 107 - NFS-e MEI; |
  | `TVerCNC` | texto | Tipo Versão do CNC - 1.00 |
  | `TVerNFSe` | texto | Tipo Versão da NF-e - 1.00\\|1.01 |
  | `xs:date` | `Date` |  |
  """

  @doc "Facetas do tipo, as da base primeiro e depois as do próprio tipo."
  @spec facets(String.t()) :: keyword()
  def facets("TBMISSQN"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4"
    ]

  def facets("TCCodTribMun"), do: [white_space: "preserve", pattern: "[0-9]{3}"]

  def facets("TCObjetoLocacao"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4",
      enumeration: "5",
      enumeration: "6"
    ]

  def facets("TE101101.xDesc"),
    do: [white_space: "preserve", enumeration: "Cancelamento de NFS-e"]

  def facets("TE101103.xDesc"),
    do: [
      white_space: "preserve",
      enumeration: "Solicitação de Análise Fiscal para Cancelamento de NFS-e"
    ]

  def facets("TE105102.xDesc"),
    do: [white_space: "preserve", enumeration: "Cancelamento de NFS-e por Substituição"]

  def facets("TE105104.xDesc"),
    do: [
      white_space: "preserve",
      enumeration: "Cancelamento de NFS-e Deferido por Análise Fiscal"
    ]

  def facets("TE105105.xDesc"),
    do: [
      white_space: "preserve",
      enumeration: "Cancelamento de NFS-e Indeferido por Análise Fiscal"
    ]

  def facets("TE202201.xDesc"),
    do: [white_space: "preserve", enumeration: "Manifestação de NFS-e - Confirmação do Prestador"]

  def facets("TE202205.xDesc"),
    do: [white_space: "preserve", enumeration: "Manifestação de NFS-e - Rejeição do Prestador"]

  def facets("TE203202.xDesc"),
    do: [white_space: "preserve", enumeration: "Manifestação de NFS-e - Confirmação do Tomador"]

  def facets("TE203206.xDesc"),
    do: [white_space: "preserve", enumeration: "Manifestação de NFS-e - Rejeição do Tomador"]

  def facets("TE204203.xDesc"),
    do: [
      white_space: "preserve",
      enumeration: "Manifestação de NFS-e - Confirmação do Intermediário"
    ]

  def facets("TE204207.xDesc"),
    do: [
      white_space: "preserve",
      enumeration: "Manifestação de NFS-e - Rejeição do Intermediário"
    ]

  def facets("TE205204.xDesc"),
    do: [white_space: "preserve", enumeration: "Manifestação de NFS-e - Confirmação Tácita"]

  def facets("TE205208.xDesc"),
    do: [white_space: "preserve", enumeration: "Manifestação de NFS-e - Anulação da Rejeição"]

  def facets("TE305101.xDesc"),
    do: [white_space: "preserve", enumeration: "Cancelamento de NFS-e por Ofício"]

  def facets("TE305102.xDesc"),
    do: [white_space: "preserve", enumeration: "Bloqueio de NFS-e por Ofício"]

  def facets("TE305103.xDesc"),
    do: [white_space: "preserve", enumeration: "Desbloqueio de NFS-e por Ofício"]

  def facets("TSAmbGeradorEvt"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2", enumeration: "3"]

  def facets("TSAmbGeradorNFSe"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2"]

  def facets("TSBairro"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 60
    ]

  def facets("TSCAEPF"), do: [white_space: "preserve", max_length: 14, pattern: "[0-9]{14}"]
  def facets("TSCEP"), do: [white_space: "preserve", pattern: "[0-9]{8}"]
  def facets("TSCNPJ"), do: [white_space: "preserve", max_length: 14, pattern: "[0-9]{14}"]
  def facets("TSCPF"), do: [white_space: "preserve", max_length: 11, pattern: "[0-9]{11}"]

  def facets("TSCategVeic"),
    do: [
      white_space: "preserve",
      enumeration: "00",
      enumeration: "01",
      enumeration: "02",
      enumeration: "03",
      enumeration: "04",
      enumeration: "05",
      enumeration: "06",
      enumeration: "07",
      enumeration: "08",
      enumeration: "09",
      enumeration: "10"
    ]

  def facets("TSCategoriaServico"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4",
      enumeration: "5"
    ]

  def facets("TSChaveNFSe"), do: [white_space: "preserve", max_length: 50, pattern: "[0-9]{50}"]
  def facets("TSChaveNFe"), do: [white_space: "preserve", max_length: 44, pattern: "[0-9]{44}"]
  def facets("TSCidade"), do: [white_space: "preserve", min_length: 1, max_length: 60]
  def facets("TSCodAcessoPed"), do: [white_space: "preserve", pattern: "[a-zA-Z0-9]{10}"]

  def facets("TSCodAutorManifestacao"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2", enumeration: "3"]

  def facets("TSCodCIB"), do: [white_space: "preserve", length: 8]
  def facets("TSCodContrato"), do: [white_space: "preserve", pattern: "[a-zA-Z0-9]{4}"]

  def facets("TSCodJustAnaliseFiscalCanc"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2", enumeration: "9"]

  def facets("TSCodJustAnaliseFiscalCancDef"), do: [white_space: "preserve", enumeration: "1"]

  def facets("TSCodJustAnaliseFiscalCancIndef"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2"]

  def facets("TSCodJustCanc"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2", enumeration: "9"]

  def facets("TSCodJustSubst"),
    do: [
      white_space: "preserve",
      enumeration: "01",
      enumeration: "02",
      enumeration: "03",
      enumeration: "04",
      enumeration: "05",
      enumeration: "99"
    ]

  def facets("TSCodMoeda"), do: [white_space: "preserve", max_length: 3, pattern: "[0-9]{3}"]

  def facets("TSCodMotivoRejeicao"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4",
      enumeration: "5",
      enumeration: "9"
    ]

  def facets("TSCodMunIBGE"), do: [white_space: "preserve", pattern: "[0-9]{7}"]
  def facets("TSCodNBS"), do: [white_space: "preserve", pattern: "[0-9]{9}"]

  def facets("TSCodNaoNIF"),
    do: [white_space: "preserve", enumeration: "0", enumeration: "1", enumeration: "2"]

  def facets("TSCodObra"), do: [white_space: "preserve", min_length: 1, max_length: 30]
  def facets("TSCodPaisISO"), do: [white_space: "preserve", pattern: "[A-Z]{2}"]
  def facets("TSCodTribNac"), do: [white_space: "preserve", pattern: "[0-9]{6}"]

  def facets("TSCodVerificacao"),
    do: [white_space: "preserve", min_length: 1, max_length: 9, pattern: "[a-zA-Z0-9]{1,9}"]

  def facets("TSCodigoEndPostal"), do: [white_space: "preserve", min_length: 1, max_length: 11]

  def facets("TSCodigoEventoNFSe"),
    do: [
      enumeration: "e101101",
      enumeration: "e105102",
      enumeration: "e105104",
      enumeration: "e105105",
      enumeration: "e305101"
    ]

  def facets("TSCodigoInternoContribuinte"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 20,
      pattern: "[a-zA-Z0-9]{1,20}"
    ]

  def facets("TSComplementoEndereco"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 156
    ]

  def facets("TSDRT"), do: [white_space: "preserve", min_length: 1, max_length: 40]

  def facets("TSData"),
    do: [
      white_space: "preserve",
      pattern:
        "(((20(([02468][048])|([13579][26]))-02-29))|(20[0-9][0-9])-((((0[1-9])|(1[0-2]))-((0[1-9])|(1\\d)|(2[0-8])))|((((0[13578])|(1[02]))-31)|(((0[1,3-9])|(1[0-2]))-(29|30)))))"
    ]

  def facets("TSDateTimeUTC"),
    do: [
      white_space: "preserve",
      pattern:
        "(((20(([02468][048])|([13579][26]))-02-29))|(20[0-9][0-9])-((((0[1-9])|(1[0-2]))-((0[1-9])|(1\\d)|(2[0-8])))|((((0[13578])|(1[02]))-31)|(((0[1,3-9])|(1[0-2]))-(29|30)))))T(20|21|22|23|[0-1]\\d):[0-5]\\d:[0-5]\\d([\\-,\\+](0[0-9]|10|11):00|([\\+](12):00))"
    ]

  def facets("TSDec15V2"),
    do: [white_space: "preserve", pattern: "0|0\\.[0-9]{2}|[1-9]{1}[0-9]{0,14}(\\.[0-9]{2})?"]

  def facets("TSDec1V2"), do: [white_space: "preserve", pattern: "0|[0-9]{1}(\\.[0-9]{2})?"]

  def facets("TSDec2V2"),
    do: [white_space: "preserve", pattern: "0|0\\.[0-9]{2}|[1-9]{1}[0-9]{0,1}(\\.[0-9]{2})?"]

  def facets("TSDec3V2"),
    do: [white_space: "preserve", pattern: "0|0\\.[0-9]{2}|[1-9]{1}[0-9]{0,2}(\\.[0-9]{2})?"]

  def facets("TSDesc1000"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 1000
    ]

  def facets("TSDesc150"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 150
    ]

  def facets("TSDesc2000"),
    do: [
      white_space: "preserve",
      pattern: "[\\s\\S!-ÿ]{1}[\\s\\S -ÿ]{0,}[\\s\\S!-ÿ]{1}|[\\s\\S!-ÿ]{1}",
      min_length: 1,
      max_length: 2000
    ]

  def facets("TSDesc255"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      white_space: "preserve",
      min_length: 1,
      max_length: 255
    ]

  def facets("TSDesc40"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 40
    ]

  def facets("TSDesc500"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      white_space: "preserve",
      min_length: 1,
      max_length: 500
    ]

  def facets("TSDesc600"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      white_space: "preserve",
      min_length: 1,
      max_length: 600
    ]

  def facets("TSDescInfCompl"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      white_space: "preserve",
      min_length: 1,
      max_length: 2000
    ]

  def facets("TSDescOutDedRed"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      white_space: "preserve",
      min_length: 1,
      max_length: 150
    ]

  def facets("TSEmail"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      white_space: "preserve",
      min_length: 1,
      max_length: 80
    ]

  def facets("TSEmitenteDPS"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2", enumeration: "3"]

  def facets("TSEnderCompletoExt"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      white_space: "preserve",
      min_length: 1,
      max_length: 255
    ]

  def facets("TSEnvMDIC"), do: [white_space: "preserve", enumeration: "0", enumeration: "1"]
  def facets("TSEstadoProvRegiao"), do: [white_space: "preserve", min_length: 1, max_length: 60]

  def facets("TSExtensaoTotal"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 5,
      pattern: "[0-9]{1,5}"
    ]

  def facets("TSIdDPS"), do: [white_space: "preserve", max_length: 45, pattern: "DPS[0-9]{42}"]
  def facets("TSIdEvento"), do: [white_space: "preserve", max_length: 62, pattern: "EVT[0-9]{59}"]
  def facets("TSIdNFSe"), do: [white_space: "preserve", max_length: 53, pattern: "NFS[0-9]{50}"]
  def facets("TSIdNumEvento"), do: [white_space: "preserve", pattern: "[0-9]{59}"]

  def facets("TSIdPedRegEvt"),
    do: [white_space: "preserve", max_length: 59, pattern: "PRE[0-9]{56}"]

  def facets("TSIdeDedRed"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4",
      enumeration: "5",
      enumeration: "6",
      enumeration: "7",
      enumeration: "8",
      enumeration: "9",
      enumeration: "99"
    ]

  def facets("TSIdeEvento"), do: [white_space: "preserve", min_length: 1, max_length: 30]
  def facets("TSInscImobFisc"), do: [white_space: "preserve", min_length: 1, max_length: 30]
  def facets("TSInscMun"), do: [max_length: 15, min_length: 1, white_space: "preserve"]

  def facets("TSLogradouro"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 255
    ]

  def facets("TSMecAFComExPrest"),
    do: [
      white_space: "preserve",
      enumeration: "00",
      enumeration: "01",
      enumeration: "02",
      enumeration: "03",
      enumeration: "04",
      enumeration: "05",
      enumeration: "06",
      enumeration: "07",
      enumeration: "08"
    ]

  def facets("TSMecAFComExToma"),
    do: [
      white_space: "preserve",
      enumeration: "00",
      enumeration: "01",
      enumeration: "02",
      enumeration: "03",
      enumeration: "04",
      enumeration: "05",
      enumeration: "06",
      enumeration: "07",
      enumeration: "08",
      enumeration: "09",
      enumeration: "10",
      enumeration: "11",
      enumeration: "12",
      enumeration: "13",
      enumeration: "14",
      enumeration: "15",
      enumeration: "16",
      enumeration: "17",
      enumeration: "18",
      enumeration: "19",
      enumeration: "20",
      enumeration: "21",
      enumeration: "22",
      enumeration: "23",
      enumeration: "24",
      enumeration: "25",
      enumeration: "26"
    ]

  def facets("TSModoPrestacao"),
    do: [
      white_space: "preserve",
      enumeration: "0",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4"
    ]

  def facets("TSMotivo"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 15,
      max_length: 255
    ]

  def facets("TSMotivoEmisTI"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4"
    ]

  def facets("TSMotivoSituacaoCadastroContribuinte"),
    do: [white_space: "preserve", pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}", min_length: 1]

  def facets("TSMovTempBens"),
    do: [
      white_space: "preserve",
      enumeration: "0",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3"
    ]

  def facets("TSNDFSe"),
    do: [white_space: "preserve", max_length: 13, pattern: "[1-9]{1}[0-9]{0,12}"]

  def facets("TSNIF"), do: [white_space: "preserve", min_length: 1, max_length: 40]

  def facets("TSNNFSe"),
    do: [white_space: "preserve", max_length: 13, pattern: "[1-9]{1}[0-9]{0,12}"]

  def facets("TSNomeFantasia"), do: [white_space: "preserve", min_length: 1, max_length: 150]
  def facets("TSNomeRazaoSocial"), do: [white_space: "preserve", min_length: 1, max_length: 300]
  def facets("TSNum14Dig"), do: [white_space: "preserve", max_length: 14, pattern: "[0-9]{14}"]
  def facets("TSNum15Dig"), do: [white_space: "preserve", max_length: 15, pattern: "[0-9]{15}"]

  def facets("TSNum3Dig"),
    do: [white_space: "preserve", max_length: 3, pattern: "[0-9]{1}[0-9]{0,2}"]

  def facets("TSNum7Dig"), do: [white_space: "preserve", max_length: 7, pattern: "[0-9]{7}"]
  def facets("TSNumBeneficioMunicipal"), do: [pattern: "[0-9]{14}"]
  def facets("TSNumDFe"), do: [white_space: "preserve", pattern: "[0-9]{1,13}"]

  def facets("TSNumDPS"),
    do: [white_space: "preserve", max_length: 15, pattern: "[1-9]{1}[0-9]{0,14}"]

  def facets("TSNumDocImport"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 12
    ]

  def facets("TSNumEixos"), do: [white_space: "preserve", pattern: "[0-9]{1,2}"]

  def facets("TSNumProcAdmAnaliseFiscalCanc"),
    do: [white_space: "preserve", min_length: 1, max_length: 30, pattern: "[0-9]{1,30}"]

  def facets("TSNumProcExigSuspensa"), do: [pattern: "[0-9]{30}"]

  def facets("TSNumProcesso"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      white_space: "preserve",
      min_length: 1,
      max_length: 30
    ]

  def facets("TSNumRegExport"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 12
    ]

  def facets("TSNumeroEndereco"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 60
    ]

  def facets("TSNumeroPostes"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 6,
      pattern: "[0-9]{1,6}"
    ]

  def facets("TSOpConsumServ"), do: [white_space: "preserve", enumeration: "0", enumeration: "1"]

  def facets("TSOpExigSuspensa"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2"]

  def facets("TSOpSNLimUltrap"), do: [white_space: "preserve", enumeration: "0", enumeration: "1"]

  def facets("TSOpSimpNac"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2", enumeration: "3"]

  def facets("TSPlaca"),
    do: [white_space: "preserve", pattern: "[A-Z]{2,3}[0-9]{4}|[A-Z]{3,4}[0-9]{3}"]

  def facets("TSProcEmissao"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2", enumeration: "3"]

  def facets("TSRTCChaveDFe"), do: [white_space: "preserve", min_length: 1, max_length: 50]
  def facets("TSRTCCodClassTrib"), do: [white_space: "preserve", pattern: "[0-9]{6}"]
  def facets("TSRTCCodCredPres"), do: [white_space: "preserve", pattern: "[0-9]{2}"]
  def facets("TSRTCCodIndOp"), do: [white_space: "preserve", pattern: "[0-9]{6}"]
  def facets("TSRTCCodSitTrib"), do: [white_space: "preserve", pattern: "[0-9]{3}"]
  def facets("TSRTCFinNFSe"), do: [white_space: "preserve", enumeration: "0"]
  def facets("TSRTCIndDest"), do: [white_space: "preserve", enumeration: "0", enumeration: "1"]
  def facets("TSRTCIndFinal"), do: [white_space: "preserve", enumeration: "0", enumeration: "1"]

  def facets("TSRTCTipoChaveDFe"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "9"
    ]

  def facets("TSRTCTpEnteGov"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4"
    ]

  def facets("TSRTCTpOper"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4",
      enumeration: "5"
    ]

  def facets("TSRTCTpReeRepRes"),
    do: [
      white_space: "preserve",
      enumeration: "01",
      enumeration: "02",
      enumeration: "03",
      enumeration: "04",
      enumeration: "99"
    ]

  def facets("TSRegEspTrib"),
    do: [
      white_space: "preserve",
      enumeration: "0",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4",
      enumeration: "5",
      enumeration: "6",
      enumeration: "9"
    ]

  def facets("TSRegimeApuracaoSimpNac"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2", enumeration: "3"]

  def facets("TSRodagem"), do: [white_space: "preserve", enumeration: "1", enumeration: "2"]
  def facets("TSSentido"), do: [white_space: "preserve", pattern: "[0-9]{1,3}"]

  def facets("TSSerieDPS"),
    do: [max_length: 5, pattern: "^0{0,4}\\d{1,5}$", white_space: "preserve"]

  def facets("TSSerieNFNFS"),
    do: [white_space: "preserve", min_length: 1, max_length: 15, pattern: "[a-zA-Z0-9]{1,15}"]

  def facets("TSSituacaoCadastroContribuinte"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 150
    ]

  def facets("TSSituacaoEmissaoNFSE"),
    do: [white_space: "preserve", enumeration: "0", enumeration: "1"]

  def facets("TSString"),
    do: [white_space: "preserve", pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}"]

  def facets("TSStringComQuebraDeLinha"),
    do: [
      white_space: "preserve",
      pattern: "[\\s\\S!-ÿ]{1}[\\s\\S -ÿ]{0,}[\\s\\S!-ÿ]{1}|[\\s\\S!-ÿ]{1}"
    ]

  def facets("TSTelefone"), do: [white_space: "preserve", pattern: "[0-9]{6,20}"]
  def facets("TSTipoAmbiente"), do: [white_space: "preserve", enumeration: "1", enumeration: "2"]

  def facets("TSTipoCST"),
    do: [
      white_space: "preserve",
      enumeration: "00",
      enumeration: "01",
      enumeration: "02",
      enumeration: "03",
      enumeration: "04",
      enumeration: "05",
      enumeration: "06",
      enumeration: "07",
      enumeration: "08",
      enumeration: "09",
      enumeration: "49",
      enumeration: "50",
      enumeration: "51",
      enumeration: "52",
      enumeration: "53",
      enumeration: "54",
      enumeration: "55",
      enumeration: "56",
      enumeration: "60",
      enumeration: "61",
      enumeration: "62",
      enumeration: "63",
      enumeration: "64",
      enumeration: "65",
      enumeration: "66",
      enumeration: "67",
      enumeration: "70",
      enumeration: "71",
      enumeration: "72",
      enumeration: "73",
      enumeration: "74",
      enumeration: "75",
      enumeration: "98",
      enumeration: "99"
    ]

  def facets("TSTipoEmissao"), do: [white_space: "preserve", enumeration: "1", enumeration: "2"]

  def facets("TSTipoImunidadeISSQN"),
    do: [
      white_space: "preserve",
      enumeration: "0",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4",
      enumeration: "5"
    ]

  def facets("TSTipoIndTotTrib"), do: [white_space: "preserve", enumeration: "0"]

  def facets("TSTipoRetISSQN"),
    do: [white_space: "preserve", enumeration: "1", enumeration: "2", enumeration: "3"]

  def facets("TSTipoRetPISCofins"),
    do: [
      white_space: "preserve",
      enumeration: "0",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4",
      enumeration: "5",
      enumeration: "6",
      enumeration: "7",
      enumeration: "8",
      enumeration: "9"
    ]

  def facets("TSTribISSQN"),
    do: [
      white_space: "preserve",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4"
    ]

  def facets("TSUF"),
    do: [
      white_space: "preserve",
      enumeration: "AC",
      enumeration: "AL",
      enumeration: "AM",
      enumeration: "AP",
      enumeration: "BA",
      enumeration: "CE",
      enumeration: "DF",
      enumeration: "ES",
      enumeration: "GO",
      enumeration: "MA",
      enumeration: "MG",
      enumeration: "MS",
      enumeration: "MT",
      enumeration: "PA",
      enumeration: "PB",
      enumeration: "PE",
      enumeration: "PI",
      enumeration: "PR",
      enumeration: "RJ",
      enumeration: "RN",
      enumeration: "RO",
      enumeration: "RR",
      enumeration: "RS",
      enumeration: "SC",
      enumeration: "SE",
      enumeration: "SP",
      enumeration: "TO"
    ]

  def facets("TSVerAplic"),
    do: [
      white_space: "preserve",
      pattern: "[!-ÿ]{1}[ -ÿ]{0,}[!-ÿ]{1}|[!-ÿ]{1}",
      min_length: 1,
      max_length: 20
    ]

  def facets("TSVincPrest"),
    do: [
      white_space: "preserve",
      enumeration: "0",
      enumeration: "1",
      enumeration: "2",
      enumeration: "3",
      enumeration: "4",
      enumeration: "5",
      enumeration: "6",
      enumeration: "9"
    ]

  def facets("TStat"),
    do: [
      white_space: "preserve",
      enumeration: "100",
      enumeration: "102",
      enumeration: "103",
      enumeration: "107"
    ]

  def facets("TVerCNC"), do: [white_space: "preserve", pattern: "1\\.00"]
  def facets("TVerNFSe"), do: [max_length: 4, white_space: "preserve", pattern: "1\\.00|1\\.01"]
  def facets("xs:date"), do: []

  @doc "Representação do tipo em Elixir."
  @spec kind(String.t()) :: Nfse.Schema.SimpleType.kind()
  def kind("TBMISSQN"), do: :string
  def kind("TCCodTribMun"), do: :string
  def kind("TCObjetoLocacao"), do: :string
  def kind("TE101101.xDesc"), do: :string
  def kind("TE101103.xDesc"), do: :string
  def kind("TE105102.xDesc"), do: :string
  def kind("TE105104.xDesc"), do: :string
  def kind("TE105105.xDesc"), do: :string
  def kind("TE202201.xDesc"), do: :string
  def kind("TE202205.xDesc"), do: :string
  def kind("TE203202.xDesc"), do: :string
  def kind("TE203206.xDesc"), do: :string
  def kind("TE204203.xDesc"), do: :string
  def kind("TE204207.xDesc"), do: :string
  def kind("TE205204.xDesc"), do: :string
  def kind("TE205208.xDesc"), do: :string
  def kind("TE305101.xDesc"), do: :string
  def kind("TE305102.xDesc"), do: :string
  def kind("TE305103.xDesc"), do: :string
  def kind("TSAmbGeradorEvt"), do: :string
  def kind("TSAmbGeradorNFSe"), do: :string
  def kind("TSBairro"), do: :string
  def kind("TSCAEPF"), do: :string
  def kind("TSCEP"), do: :string
  def kind("TSCNPJ"), do: :string
  def kind("TSCPF"), do: :string
  def kind("TSCategVeic"), do: :string
  def kind("TSCategoriaServico"), do: :string
  def kind("TSChaveNFSe"), do: :string
  def kind("TSChaveNFe"), do: :string
  def kind("TSCidade"), do: :string
  def kind("TSCodAcessoPed"), do: :string
  def kind("TSCodAutorManifestacao"), do: :string
  def kind("TSCodCIB"), do: :string
  def kind("TSCodContrato"), do: :string
  def kind("TSCodJustAnaliseFiscalCanc"), do: :string
  def kind("TSCodJustAnaliseFiscalCancDef"), do: :string
  def kind("TSCodJustAnaliseFiscalCancIndef"), do: :string
  def kind("TSCodJustCanc"), do: :string
  def kind("TSCodJustSubst"), do: :string
  def kind("TSCodMoeda"), do: :string
  def kind("TSCodMotivoRejeicao"), do: :string
  def kind("TSCodMunIBGE"), do: :string
  def kind("TSCodNBS"), do: :string
  def kind("TSCodNaoNIF"), do: :string
  def kind("TSCodObra"), do: :string
  def kind("TSCodPaisISO"), do: :string
  def kind("TSCodTribNac"), do: :string
  def kind("TSCodVerificacao"), do: :string
  def kind("TSCodigoEndPostal"), do: :string
  def kind("TSCodigoEventoNFSe"), do: :string
  def kind("TSCodigoInternoContribuinte"), do: :string
  def kind("TSComplementoEndereco"), do: :string
  def kind("TSDRT"), do: :string
  def kind("TSData"), do: :date
  def kind("TSDateTimeUTC"), do: :datetime
  def kind("TSDec15V2"), do: {:decimal, 15, 2}
  def kind("TSDec1V2"), do: {:decimal, 1, 2}
  def kind("TSDec2V2"), do: {:decimal, 2, 2}
  def kind("TSDec3V2"), do: {:decimal, 3, 2}
  def kind("TSDesc1000"), do: :string
  def kind("TSDesc150"), do: :string
  def kind("TSDesc2000"), do: :string
  def kind("TSDesc255"), do: :string
  def kind("TSDesc40"), do: :string
  def kind("TSDesc500"), do: :string
  def kind("TSDesc600"), do: :string
  def kind("TSDescInfCompl"), do: :string
  def kind("TSDescOutDedRed"), do: :string
  def kind("TSEmail"), do: :string
  def kind("TSEmitenteDPS"), do: :string
  def kind("TSEnderCompletoExt"), do: :string
  def kind("TSEnvMDIC"), do: :string
  def kind("TSEstadoProvRegiao"), do: :string
  def kind("TSExtensaoTotal"), do: :string
  def kind("TSIdDPS"), do: :string
  def kind("TSIdEvento"), do: :string
  def kind("TSIdNFSe"), do: :string
  def kind("TSIdNumEvento"), do: :string
  def kind("TSIdPedRegEvt"), do: :string
  def kind("TSIdeDedRed"), do: :string
  def kind("TSIdeEvento"), do: :string
  def kind("TSInscImobFisc"), do: :string
  def kind("TSInscMun"), do: :string
  def kind("TSLogradouro"), do: :string
  def kind("TSMecAFComExPrest"), do: :string
  def kind("TSMecAFComExToma"), do: :string
  def kind("TSModoPrestacao"), do: :string
  def kind("TSMotivo"), do: :string
  def kind("TSMotivoEmisTI"), do: :string
  def kind("TSMotivoSituacaoCadastroContribuinte"), do: :string
  def kind("TSMovTempBens"), do: :string
  def kind("TSNDFSe"), do: :string
  def kind("TSNIF"), do: :string
  def kind("TSNNFSe"), do: :string
  def kind("TSNomeFantasia"), do: :string
  def kind("TSNomeRazaoSocial"), do: :string
  def kind("TSNum14Dig"), do: :string
  def kind("TSNum15Dig"), do: :string
  def kind("TSNum3Dig"), do: :string
  def kind("TSNum7Dig"), do: :string
  def kind("TSNumBeneficioMunicipal"), do: :string
  def kind("TSNumDFe"), do: :string
  def kind("TSNumDPS"), do: :string
  def kind("TSNumDocImport"), do: :string
  def kind("TSNumEixos"), do: :string
  def kind("TSNumProcAdmAnaliseFiscalCanc"), do: :string
  def kind("TSNumProcExigSuspensa"), do: :string
  def kind("TSNumProcesso"), do: :string
  def kind("TSNumRegExport"), do: :string
  def kind("TSNumeroEndereco"), do: :string
  def kind("TSNumeroPostes"), do: :string
  def kind("TSOpConsumServ"), do: :string
  def kind("TSOpExigSuspensa"), do: :string
  def kind("TSOpSNLimUltrap"), do: :string
  def kind("TSOpSimpNac"), do: :string
  def kind("TSPlaca"), do: :string
  def kind("TSProcEmissao"), do: :string
  def kind("TSRTCChaveDFe"), do: :string
  def kind("TSRTCCodClassTrib"), do: :string
  def kind("TSRTCCodCredPres"), do: :string
  def kind("TSRTCCodIndOp"), do: :string
  def kind("TSRTCCodSitTrib"), do: :string
  def kind("TSRTCFinNFSe"), do: :string
  def kind("TSRTCIndDest"), do: :string
  def kind("TSRTCIndFinal"), do: :string
  def kind("TSRTCTipoChaveDFe"), do: :string
  def kind("TSRTCTpEnteGov"), do: :string
  def kind("TSRTCTpOper"), do: :string
  def kind("TSRTCTpReeRepRes"), do: :string
  def kind("TSRegEspTrib"), do: :string
  def kind("TSRegimeApuracaoSimpNac"), do: :string
  def kind("TSRodagem"), do: :string
  def kind("TSSentido"), do: :string
  def kind("TSSerieDPS"), do: :string
  def kind("TSSerieNFNFS"), do: :string
  def kind("TSSituacaoCadastroContribuinte"), do: :string
  def kind("TSSituacaoEmissaoNFSE"), do: :string
  def kind("TSString"), do: :string
  def kind("TSStringComQuebraDeLinha"), do: :string
  def kind("TSTelefone"), do: :string
  def kind("TSTipoAmbiente"), do: :string
  def kind("TSTipoCST"), do: :string
  def kind("TSTipoEmissao"), do: :string
  def kind("TSTipoImunidadeISSQN"), do: :string
  def kind("TSTipoIndTotTrib"), do: :string
  def kind("TSTipoRetISSQN"), do: :string
  def kind("TSTipoRetPISCofins"), do: :string
  def kind("TSTribISSQN"), do: :string
  def kind("TSUF"), do: :string
  def kind("TSVerAplic"), do: :string
  def kind("TSVincPrest"), do: :string
  def kind("TStat"), do: :string
  def kind("TVerCNC"), do: :string
  def kind("TVerNFSe"), do: :string
  def kind("xs:date"), do: :date
end
