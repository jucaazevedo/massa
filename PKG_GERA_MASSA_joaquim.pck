CREATE OR REPLACE PACKAGE PKG_GERA_MASSA_10_20 AS
       --v1 (04/07/2017)

       l_cod_bandeira varchar2(50);
       l_cod_adquir varchar2(50); /* tb chamado de codigo credenciadora*/
       l_cod_servico varchar2(10);
       l_cod_tipo_plataforma varchar2(50);
       l_cod_processadora varchar2(50);
       l_tipo_arquivo varchar2(50);
       l_valor_total_venda_debito number:=0;
       l_qtde_total_transacoes_debito number:=0;
       l_valor_total_venda_credito number:=0;
       l_qtde_total_trans_credito number:=0;
       l_nro_referencia varchar2(20);


       /*
       Pendencias:
       TE0500 - gerar nro transacao
       TE0501 - validar se é CPF ou CNPJ e dar um exemplo
       */
       PROCEDURE INPUT_DADOS_10_20 ( 
                 p_credenciadora_emissor varchar2, 
                 p_numero_geracao_massa in out varchar2,
                 p_numero_linha_arquivo varchar2,   
                 p_tipo_plataforma varchar2,
                 p_tipo_arquivo varchar2,
                 p_codigo_bandeira_b0 varchar2,
                 p_cod_adquirente_b0 varchar2,
                 p_numero_remessa_b0 varchar2,
                 p_numero_remessa_bz varchar2,
                 p_tipo_layout varchar2,
                 p_cod_adquirente_te05 varchar2, --6.8 b11
                 p_banco_emissor varchar2, --6.8 b12
                 p_numero_cartao varchar2, --6.8 b13
                 p_vlr_venda varchar2, --6.8 b09
                 p_cod_bandeira_te05 varchar2,
                 p_mcc_pv varchar2, --6.8 b14
                 p_nro_referencia varchar2,
                 p_cnpj_cpf varchar2, -- 6.8 b01
                 p_ponto_de_venda varchar2, --6.8 b02
                 p_tipo_pessoa varchar2, --6.8 b03
                 p_vlr_transacao varchar2, --6.8 b07
                 p_qtd_parcelas_transacao varchar2, --6.8 b08
                 p_codigo_produto varchar2, --6.8 b06
                 p_vl_taxa_embarque varchar2,
                 p_nro_parcela varchar2,
                 p_quantidade_dias_liq_trs varchar2, --6.8 b04
                 p_tipo_operacao varchar2 --6.8 b20
                 );

    PROCEDURE GERACAO_MASSA (p_numero_geracao_massa varchar2);
    PROCEDURE GERACAO_MASSA_TE (p_numero_geracao_massa varchar2,l_i in out number);

    PROCEDURE LAYOUT_B0 (p_numero_geracao_massa number, 
                        l_retorno out varchar2 );

    PROCEDURE LAYOUT_BZ (p_numero_geracao_massa number,
                        l_retorno out varchar2 );
                        
    PROCEDURE LAYOUT_OPERACAO (p_numero_geracao_massa number,
                                   p_nro_linha_arquivo number,
                                   l_cod_tipo_operacao varchar2,
                                   l_i in out number,
                                   tipo_layout varchar2);

    PROCEDURE LAYOUT_SUBTIPO_00 (p_numero_geracao_massa number,
                                   p_nro_linha_arquivo number,
                                   l_retorno out varchar2);

    PROCEDURE LAYOUT_SUBTIPO_01 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2 );

    PROCEDURE LAYOUT_SUBTIPO_02 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      p_tipo_operacao varchar2,
                                      l_retorno out varchar2 );
                                      
    PROCEDURE LAYOUT_SUBTIPO_05 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2 );
                                      
    PROCEDURE LAYOUT_SUBTIPO_07 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2 );

    PROCEDURE INPUT_DADOS_VALIDACAO ( 
              p_numero_geracao_massa in out varchar2,
              p_numero_linha_arquivo varchar2,   
              p_dsc_linha_arquivo varchar2);
              
              
    PROCEDURE GERACAO_CRITICAS (p_numero_geracao_massa number);    
    
    PROCEDURE LAYOUT_B0_CRITICAS (p_numero_geracao_massa number);
    
    PROCEDURE LAYOUT_BZ_CRITICAS (p_numero_geracao_massa number);
    
    PROCEDURE LAYOUT_TE0500_CRITICAS (p_numero_geracao_massa number );
    PROCEDURE LAYOUT_TE0501_CRITICAS (p_numero_geracao_massa number );
    PROCEDURE LAYOUT_TE0502_CRITICAS (p_numero_geracao_massa number );
    
    PROCEDURE PERSISTE_CRITICA  (p_numero_geracao_massa number,
                              p_numero_linha_arquivo in out number,
                              l_linha_arquivo varchar2) ;

END PKG_GERA_MASSA;
/
CREATE OR REPLACE PACKAGE BODY PKG_GERA_MASSA_10_20 AS
       
       PROCEDURE INPUT_DADOS_10_20 ( 
                 p_credenciadora_emissor varchar2, 
                 p_numero_geracao_massa in out varchar2,
                 p_numero_linha_arquivo varchar2,   
                 p_tipo_plataforma varchar2,
                 p_tipo_arquivo varchar2,
                 p_codigo_bandeira_b0 varchar2,
                 p_cod_adquirente_b0 varchar2,
                 p_numero_remessa_b0 varchar2,
                 p_numero_remessa_bz varchar2,
                 p_tipo_layout varchar2,
                 p_cod_adquirente_te05 varchar2, --6.8 b11
                 p_banco_emissor varchar2, --6.8 b12
                 p_numero_cartao varchar2, --6.8 b13
                 p_vlr_venda varchar2, --6.8 b09
                 p_cod_bandeira_te05 varchar2,
                 p_mcc_pv varchar2, --6.8 b14
                 p_nro_referencia varchar2,
                 p_cnpj_cpf varchar2, -- 6.8 b01
                 p_ponto_de_venda varchar2, --6.8 b02
                 p_tipo_pessoa varchar2, --6.8 b03
                 p_vlr_transacao varchar2, --6.8 b07
                 p_qtd_parcelas_transacao varchar2, --6.8 b08
                 p_codigo_produto varchar2,--6.8 b06
                 p_vl_taxa_embarque varchar2,
                 p_nro_parcela varchar2,
                 p_quantidade_dias_liq_trs varchar2, --6.8 b04
                 p_tipo_operacao varchar2 --6.8 b20
                 ) IS
                 
                 l_numero_geracao_massa number;
       begin
            if (to_number(p_numero_geracao_massa) = 0) then
               select SQ_INPUT_MASSA_DADOS.nextval into l_numero_geracao_massa
               from dual;
            else 
                 l_numero_geracao_massa := to_number(p_numero_geracao_massa);
            end if;
            insert into TBL_INPUT_MASSA_DADOS
            (
                NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO,
                DSC_TIPO_ARQUIVO,
                NRO_REMESSA_B0, COD_TIPO_PLATAFORMA,
                COD_BANDEIRA_B0,COD_ADQUIRENTE_B0, 
                NRO_REMESSA_BZ, TIPO_LAYOUT,  
                NRO_CNPJ_CPF_TE05, NRO_PONTO_VENDA_TE05,
                DSC_TIPO_PESSOA_TE05, QTD_DIAS_LIQ_TRAN_TE05,
                COD_PRODUTO_TE05, VLR_TRAN_TE05,
                QTD_PARC_TRAN_TE05, VLD_VENDA_TE05,
                COD_ADQUIRENTE_TE05, COD_BANCO_EMISSOR_TE05,
                NRO_CARTAO_TE05, NRO_MCC_PONTO_VENDA_TE05, COD_BANDEIRA_TE05,
                DSC_TIPO_OPERACAO_TE05, NRO_REFERENCIA, VL_TAXA_EMBARQUE, NRO_PARCELA

            )
            values 
            (
                l_numero_geracao_massa, to_number(p_numero_linha_arquivo),
                p_credenciadora_emissor,
                p_numero_remessa_b0, p_tipo_plataforma,
                p_codigo_bandeira_b0,p_cod_adquirente_b0,
                p_numero_remessa_bz, p_tipo_layout,  
                p_cnpj_cpf, p_ponto_de_venda,
                p_tipo_pessoa, p_quantidade_dias_liq_trs,
                p_codigo_produto, p_vlr_transacao,
                p_qtd_parcelas_transacao, p_vlr_venda,
                p_cod_adquirente_te05, p_banco_emissor,
                p_numero_cartao, p_mcc_pv, p_cod_bandeira_te05,
                p_tipo_operacao,
                p_nro_referencia, 
                p_vl_taxa_embarque, 
                p_nro_parcela
            ) ;

            p_numero_geracao_massa := to_char(l_numero_geracao_massa);

            -- Populando variáveis globais
            l_cod_bandeira := p_codigo_bandeira_b0;
            l_cod_adquir := p_cod_adquirente_b0;
            l_cod_tipo_plataforma := p_tipo_plataforma;
            l_tipo_arquivo := p_tipo_arquivo;
            l_cod_processadora:= 000;
            commit;
       exception
                when others then
                null;
       end;

       PROCEDURE LAYOUT_B0 (p_numero_geracao_massa number,
                           l_retorno out varchar2 )IS
                 campo_1 char(2) := lpad('B0',2,' '); --Codigo do Registro (1)
                 campo_2 char(2) := lpad('10',2,'0'); --Codigo do Servico (3)
                 campo_3 char(8) := lpad('0',8,'0'); --Data da Remessa (5)
                 campo_4 char(4) := lpad('0',4,'0'); --Numero da Remessa (13)
                 campo_5 char(4) := lpad(' ',4,' '); --Uso futuro (17)
                 campo_6 char(8) := lpad('0',8,'0'); --Data de envio (21)
                 campo_7 char(6) := lpad('0',6,'0'); --Hora de Envio do Arquivo (29)
                 campo_8 char(8) := lpad('0',8,'0'); --Data de Retorno do Arquivo (35)
                 campo_9 char(6) := lpad('0',6,'0'); --Hora de Retorno do Arquivo (43)
                 campo_10 char(4) := lpad('1',4,'0'); --Banco Emissor (49)
                 campo_11 char(4) := lpad('0',4,'0'); --Codigo da Processadora (53)
                 campo_12 char(100) := lpad(' ',100,' '); --Uso Futuro (57)
                 campo_13 char(8) := lpad('25',8,'0'); --Codigo do adquirente (157)
                 campo_14 char(3) := lpad('007',3,'0'); --Codigo da bandeira (165)
                 campo_15 char(1) := lpad('0',1,'0'); --(Indicador de Rota do Arquivo (168)
       begin
            --------------Tipo de Arquivo a ser gerado (ad -> band OU band -> ad)
            select case when max(DSC_TIPO_ARQUIVO) = 'ADQUIRENCIAPARABANDEIRA' then 1
                    else 2 end
            into campo_15
            from TBL_INPUT_MASSA_DADOS
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;

            campo_3 := to_char(sysdate,'YYYY') || lpad(to_char(sysdate,'MM'),2,'0') || lpad(to_char(sysdate,'DD'),2,'0');
            campo_6 := to_char(sysdate-1,'YYYY') || lpad(to_char(sysdate-1,'MM'),2,'0') || lpad(to_char(sysdate-1,'DD'),2,'0');
            campo_7 := lpad(to_char(sysdate-1,'hh24'),2,'0') || lpad(to_char(sysdate-1,'mi'),2,'0') || lpad(to_char(sysdate-1,'ss'),2,'0');

            --------------Codigo Bandeira (ok)
            --------------VALIDACAO LOGICA: Deve existir na Base de Adquirentes.
            SELECT nvl(lpad(to_char(cd_bndr),3,'0'),'007')
            into campo_14
            FROM CCR.TBCCRR_BNDR
            WHERE NM_BNDR='ELO';

            select substr(nvl(lpad(max(COD_BANDEIRA_B0),3,'0'),campo_14),1,3)
            into campo_14
            from TBL_INPUT_MASSA_DADOS
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;

            l_cod_bandeira := campo_14;

            ------------- Codigo do Servico (OK)
            --------------VALIDACAO LOGICA: Deve existir na tabela Tipo de Serviços x Emissor.
            SELECT substr(nvl(lpad(max(CD_SRVC_BNDR),2,'0'),campo_2),1,2)
            into campo_2
            FROM CLC.TBCLCR_SRVC_BNDR 
            WHERE CD_BNDR = campo_14;

            l_cod_servico := campo_2;

            --------------Codigo Adquirente
            begin
              SELECT  nvl(lpad(to_char(CD_CRDE),8,'0'),'00000025')
              into campo_13
              FROM CCR.TBCCRR_CRDE_BNDR 
              WHERE CD_BNDR = campo_14 AND 
                    IN_CRDE_ATVO = 'S' AND 
                    ROWNUM = 1;
            exception
                     when NO_DATA_FOUND then
                          campo_13 := '00000025';
            end;
            select substr(nvl(lpad(max(COD_ADQUIRENTE_B0),8,'0'),campo_13),1,8)
            into campo_13
            from TBL_INPUT_MASSA_DADOS
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;            

            l_cod_adquir := campo_13;

            --------------Numero Remessa
            SELECT lpad(NVL( MAX( NU_RMSA_CRDE ), 0 ) + 1,4,'0') 
            into campo_4
            FROM CLC.TBCLCR_RMSA_CRDE 
            WHERE CD_BNDR = campo_14
            AND CD_CRDE = campo_13
            AND CD_TIPO_PLTF_PGMN = l_cod_tipo_plataforma;

            select substr(nvl(lpad(max(NRO_REMESSA_B0),4,'0'),campo_4),1,4)
            into campo_4
            from TBL_INPUT_MASSA_DADOS
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;

            begin
                select max(cod_tipo_plataforma)
                into l_cod_tipo_plataforma
                from TBL_INPUT_MASSA_DADOS
                where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;
            exception
                     when NO_DATA_FOUND then
                          l_cod_tipo_plataforma := 'C';
            end;

            l_retorno:= lpad(campo_1 || campo_2 || campo_3 || campo_4 || campo_5 || 
                      campo_6 || campo_7 || campo_8 || campo_9 || campo_10 || 
                      campo_11 || campo_12 || campo_13 || campo_14 || campo_15,168,' ') ;


            update TBL_INPUT_MASSA_DADOS a
            set nro_remessa_b0 = nvl(nro_remessa_b0,campo_4),
                cod_bandeira_b0 = nvl(cod_bandeira_b0,campo_14) ,
                cod_adquirente_b0 = nvl(cod_adquirente_b0,campo_13),
                cod_tipo_plataforma = nvl(cod_tipo_plataforma,'C'),
                DSC_TIPO_ARQUIVO = nvl(DSC_TIPO_ARQUIVO,'ADQUIRENCIAPARABANDEIRA')
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;  
       exception
                when others then
                null;
       end;

       PROCEDURE LAYOUT_BZ (p_numero_geracao_massa number,
                           l_retorno out varchar2 )IS
                 campo_1 char(2) := lpad('BZ',2,' '); --Codigo do Registro (1)
                 campo_2 char(2) := lpad('10',2,'0'); --Codigo do Servico (3)
                 campo_3 char(4) := lpad('0',4,'0'); --Numero da Remessa (13)
                 campo_4 char(8) := lpad('0',8,'0'); --Quantidade de transacoes de Credito em Moeda Real
                 campo_5 char(15) := lpad('0',15,'0'); --Valor total das transacoes de creditos em moeda real
                 campo_6 char(8) := lpad('0',8,'0'); --Quantidade de transacoes de Debito em Moeda Real
                 campo_7 char(15) := lpad('0',15,'0'); --Valor total das transacoes de Debito em moeda real
                 campo_8 char(8) := lpad('0',8,'0'); --Quantidade de Transacoes de Credito em Moeda Dolar (uso futuro)
                 campo_9 char(15) := lpad('0',15,'0'); --Valor total das transacoes de creditos em moeda real (uso futuro)
                 campo_10 char(8) := lpad('0',8,'0'); --Quantidade de transacoes de Debito em Moeda Real (uso futuro)
                 campo_11 char(15) := lpad('0',15,'0'); --Valor total das transacoes de Debito em moeda real (uso futuro)
                 campo_12 char(8) := lpad('0',8,'0'); --quantidade total de registros
                 campo_13 char(8) := lpad('0',8,'0'); --quantidade de transacoes de movimentacao de parcelado
                 campo_14 char(15) := lpad('0',15,'0'); --valor total das transacoes de movimentacao de parcelado
                 campo_15 char(36) := lpad(' ',36,' '); --uso futuro
                 campo_16 char(1) := lpad('0',1,'0'); --indicador de rota de arquivo
                 l_tipo_layout char(50);
                 --l_retorno varchar2(200);

--                 l_cod_bandeira varchar2(3):='007';
--                 l_cod_adquir varchar2(8):='00000025';
       begin
            --------------Tipo de Arquivo a ser gerado (ad -> band OU band -> ad)
            select case when max(DSC_TIPO_ARQUIVO) = 'ADQUIRENCIAPARABANDEIRA' then 1
                    else 2 end
            into campo_16
            from TBL_INPUT_MASSA_DADOS
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;
            


  
            --------------Numero Remessa
            SELECT lpad(NVL( MAX( NU_RMSA_CRDE ), 0 ) + 1 ,4,'0') 
            into campo_3
            FROM CLC.TBCLCR_RMSA_CRDE 
            WHERE CD_BNDR = l_cod_bandeira
            AND CD_CRDE = l_cod_adquir
            AND CD_TIPO_PLTF_PGMN = l_cod_tipo_plataforma;

            select lpad(nvl(nvl(max(NRO_REMESSA_BZ),max(NRO_REMESSA_B0)),campo_3),4, '0')
            into campo_3
            from TBL_INPUT_MASSA_DADOS
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;            

            
            campo_6 := lpad(to_char(l_qtde_total_transacoes_debito),8,'0');
            campo_7 := lpad(to_char(l_valor_total_venda_debito),15,'0');
            
            campo_4 := lpad(to_char(l_qtde_total_trans_credito),8,'0');
            campo_5 := lpad(to_char(l_valor_total_venda_credito),15,'0');
            

            -- +1 relativo ao registro do BZ que ainda nao foi comitado
            select lpad(MAX(NRO_LINHA_ARQUIVO)+1,8,'0')
            into campo_12
            from TBL_OUTPUT_MASSA_DADOS
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;   
            
 --           campo_12 := lpad(2,8,'0');

            l_retorno:= lpad(campo_1 || campo_2 || campo_3 || campo_4 || campo_5 || 
                      campo_6 || campo_7 || campo_8 || campo_9 || campo_10 || 
                      campo_11 || campo_12 || campo_13 || campo_14 || campo_15 ||
                      campo_16,168,' ');
                      
                      
            update TBL_INPUT_MASSA_DADOS a
            set nro_remessa_bz = nvl(nro_remessa_bz,campo_3)
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;                        

       exception
                when others then
                null;
       end;       

       PROCEDURE LAYOUT_SUBTIPO_00 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2)IS
                 campo_1 char(2) := lpad('00',2,'0'); --Código da Transação (1)
                 campo_2 char(2) := lpad('00',2,'0'); --Subcódigo da Transação  (3)
                 campo_3 char(19) := rpad('',19,' '); --Número do Cartão (5)
                 campo_4 char(1) := lpad('C',1,' '); --Tipo de Liquidação (24)
                 campo_5 char(1) := lpad(' ',1,' '); --Uso futuro (25)
                 campo_6 char(1) := lpad('1',1,' '); --Indicador de Origem da Autorização da Transação ou Cancelamento (26)
                 campo_7 char(23) := lpad('24428567010429000076614',23,'0'); --Número de Referência da Transação (27)
                 campo_8 char(8) := lpad('0',8,'0'); --Código do Adquirente (50)
                 campo_9 char(8) := lpad('0',8,'0'); --Data da Venda (58) 
                 campo_10 char(11) := lpad(' ',11,' '); --Uso Futuro (69)
                 campo_11 char(12) := lpad('0',12,'0'); --Valor da Venda ou Valor do Chargeback 
                 campo_12 char(3) := lpad('986',3,'0'); --Código da Moeda da Transação
                 campo_13 char(25) := lpad('KGBLG H BMQ  I KUQL      ',25,' '); --Nome do PV (Ponto de Venda)
                 campo_14 char(13) := lpad('SAO PAULO    ',13,' '); --Cidade do PV (Ponto de Venda)
                 campo_15 char(3) := lpad('BR ',3,' '); --Código do País do PV (Ponto de Venda)
                 campo_16 char(4) := lpad('0',4,'0'); --MCC do PV (Ponto de Venda)
                 campo_17 char(5) := lpad('0',5,'0'); --Banco Emissor
                 campo_18 char(2) := lpad(' ',2,' '); --Uso futuro
                 campo_19 char(3) := lpad('0',3,'0'); --Código da Bandeira
                 campo_20 char(1) := lpad('1',1,'0'); --Identificação do Tipo de Transação
                 campo_21 char(2) := lpad('30',2,'0'); --Código de Motivo do Chargeback
                 campo_22 char(6) := lpad('910046',6,' '); --Código de Autorização da Transação
                 campo_23 char(1) := lpad('5',1,' '); --Indicador de Tecnologia do Terminal
                 campo_24 char(1) := lpad('1',1,'0'); --Meio de Identificação do Portador
                 campo_25 char(1) := lpad(' ',1,' '); --Uso futuro
                 campo_26 char(2) := lpad('05',2,' '); --Modo de Entrada da Transação no POS
                 campo_27 char(8) := lpad('0',8,'0'); --Data do Movimento / Data de apresentação do Chargeback
                 --l_retorno varchar2(200);

                 l_banco_emissor varchar2(20);
                 l_nro_mcc_ponto_venda varchar2(20);
                 l_nro_bin varchar2(50);
                 l_nro_referencia varchar2(50);
                 l_data_movimento date;
                 l_data_juliana_movimento number;
                 valor_soma varchar2(12);
                 l_tipo_layout varchar2(5);
                 l_max_in_tokn char(1);
                 l_min_in_tokn char(1);
       begin

            campo_9 := to_char(sysdate-1,'YYYY') || lpad(to_char(sysdate-1,'MM'),2,'0') || lpad(to_char(sysdate-1,'DD'),2,'0');
            campo_27 := to_char(sysdate,'YYYY') || lpad(to_char(sysdate,'MM'),2,'0') || lpad(to_char(sysdate,'DD'),2,'0');

            --------------Codigo Bandeira (ok)
            --------------VALIDACAO LOGICA: Deve existir na Base de Adquirentes.
            select substr(nvl(lpad(COD_BANDEIRA_TE05,3,'0'),l_cod_bandeira),1,3)
            into campo_19
            from TBL_INPUT_MASSA_DADOS
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa
            and nro_linha_arquivo = p_nro_linha_arquivo;      

            -------------Validar Banco Emissor
            -------------busca um banco emissor valido para a bandeira apresentada
            begin
                SELECT CD_EMSR
                into l_banco_emissor
                FROM CLC.TBCLCW_EMSR_RPLC 
                WHERE CD_BNDR = campo_19
                and rownum < 2;  
            exception
                     WHEN OTHERS THEN
                          l_banco_emissor:='00000';
            end;

            -------------Validar MCC
            -------------busca um MCC valido para a bandeira apresentada

            begin
                SELECT CD_MCC_BNDR
                into l_nro_mcc_ponto_venda
                FROM CPR.TBCPRR_MCC_BNDR 
                WHERE CD_BNDR = campo_19 
                AND IN_RGST_ATVO='S' 
                AND ROWNUM = 1;
            exception
                     when OTHERS then
                          l_nro_mcc_ponto_venda := '0000';
            end;
            
            
            

            select substr(a.tipo_layout, 3, 2),
                   nvl(rpad(a.nro_cartao_te05,19,' '),'XXXXXXXXXXXXXXXXXXX') ,
                   nvl(lpad(a.vld_venda_te05,12,'0'),'000000000837'),
                   lpad(nvl(a.cod_adquirente_te05, l_cod_adquir),8,'0'),
                   lpad(nvl(a.cod_banco_emissor_te05, l_banco_emissor),5,'0'),
                   lpad(nvl(a.nro_mcc_ponto_venda_te05, l_nro_mcc_ponto_venda),4,'0'),
                   nvl(a.nro_referencia, '0'),
                   tipo_layout
            into campo_1,
                 campo_3,
                 campo_11, 
                 campo_8,
                 campo_17, 
                 campo_16,
                 campo_7,
                 l_tipo_layout
            from tbl_input_massa_dados a
            where a.nro_identif_gera_massa = p_numero_geracao_massa
            and a.nro_linha_arquivo = p_nro_linha_arquivo;

            if translate(rtrim(ltrim( campo_11 )),' +-0123456789.', ' ') is not null then
               valor_soma := '0';
            else
               valor_soma := campo_11;
            end if;

            if l_tipo_layout = 'TE05' then
                l_valor_total_venda_debito := l_valor_total_venda_debito + to_number(valor_soma);
                l_qtde_total_transacoes_debito := l_qtde_total_transacoes_debito + 1;
            end if;
            if l_tipo_layout = 'TE25' then
                l_valor_total_venda_credito := l_valor_total_venda_credito + to_number(valor_soma);
                l_qtde_total_trans_credito := l_qtde_total_trans_credito + 1;
            end if;
            

            -- Se o usuário não definir o NroCartao. Definimos um cartao a partir da bandeira e l_cod_tipo_plataforma 
            if (campo_3 = 'XXXXXXXXXXXXXXXXXXX') then
              begin 
                  SELECT to_char(NU_BIN)
                  into l_nro_bin
                  FROM CLC.TBCLCW_BIN_RPLC  
                  WHERE --NU_BIN = substr(campo_3,1,6)
                     CD_BNDR = campo_19
                     AND CD_TIPO_PLTF_PGMN = l_cod_tipo_plataforma
                     AND IN_TOKN = 'N'
                     and rownum < 2; 

                  if (length(rtrim(ltrim(l_nro_bin))) <> 6) then
                      campo_3 := '9999999999999999   ';
                  else
                      campo_3 := rpad(rtrim(ltrim(l_nro_bin)) || '77' || '7777' || '7777',19,' ');
                  end if;

               exception
                        WHEN NO_DATA_FOUND THEN
                             campo_3 := '8888888888888888   ';
               end;
            elsif (campo_3 <> 'XXXXXXXXXXXXXXXXXXX') then
              begin 
                  SELECT to_char(NU_BIN),max(IN_TOKN) max_in_tokn,min(IN_TOKN) min_in_tokn
                  into l_nro_bin, l_max_in_tokn, l_min_in_tokn
                  FROM CLC.TBCLCW_BIN_RPLC  
                  WHERE --NU_BIN = substr(campo_3,1,6)
                     CD_BNDR = campo_19
                     AND CD_TIPO_PLTF_PGMN = l_cod_tipo_plataforma
                     AND nu_bin = substr(campo_3,1,6)
                  group by to_char(NU_BIN);
                     
                  if (l_max_in_tokn ='S' or l_min_in_tokn = 'S') then
                     -- BIN é tokenizer
                     -- procurar na tabela de DE_PARA campos novos a serem descriptografaods
                     null;
--                     select *
--                     from CLC.TBCLCR_CRSA_CRTO_FSCO_DNMC x
--                     where x.
                  end if;
               exception
                        WHEN NO_DATA_FOUND THEN
                             campo_3 := '8888888888888888   ';
               end;
            end if;
            
            if (campo_7 = '0') then
                -- Gerar Nro de Referencia Valido a partir do NroCartao 
                l_data_movimento := to_date(campo_27,'YYYYMMDD');
                l_data_juliana_movimento := (TO_NUMBER(to_char(l_data_movimento,'Y'))) * 1000 
                                         + TO_NUMBER(TO_CHAR(l_data_movimento,'DDD'));            
                                         
                campo_7 := case when (l_tipo_layout = 'TE06' or l_tipo_layout = 'TE26') then '7' else '2' end || 
                           substr(campo_3,1,6) ||
                           to_char(l_data_juliana_movimento) ||
                           to_char(to_number(rpad(p_numero_geracao_massa,11,'0')) + p_nro_linha_arquivo) ||
                           '1'; --digito verificador
            end if;
            l_nro_referencia := campo_7;
            

            l_retorno:= lpad(campo_1 || campo_2 || campo_3 || campo_4 || campo_5 || 
                      campo_6 || campo_7 || campo_8 || campo_9 || campo_10 || 
                      campo_11 || campo_12 || campo_13 || campo_14 || campo_15 ||
                      campo_16 || campo_17 || campo_18 || campo_19 || campo_20 ||
                      campo_21 || campo_22 || campo_23 || campo_24 || campo_25 ||
                      campo_26 || campo_27,168,' ');
                      
            update tbl_input_massa_dados a
            set cod_adquirente_te05 = nvl(cod_adquirente_te05,campo_8),
                cod_banco_emissor_te05 = nvl(cod_banco_emissor_te05,campo_17),
                nro_cartao_te05 = nvl(nro_cartao_te05,campo_3),
                vld_venda_te05 = nvl(vld_venda_te05,campo_11),
                cod_bandeira_te05 = nvl(cod_bandeira_te05,campo_19),
                nro_mcc_ponto_venda_te05 = nvl(nro_mcc_ponto_venda_te05,campo_16),
                nro_referencia = campo_7
            where nro_identif_gera_massa = p_numero_geracao_massa
                        and nro_linha_arquivo = p_nro_linha_arquivo;
       exception
                when others then
                null;
       end;

       PROCEDURE LAYOUT_SUBTIPO_01 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2 )IS
                 campo_1 char(2) := lpad('00',2,' '); --Código da Transação
                 campo_2 char(2) := lpad('01',2,'0'); --Subcódigo da Transação
                 campo_3 char(5) := lpad('0',5,'0'); --Uso futuro
                 campo_4 char(7) := lpad(' ',7,' '); --Uso futuro
                 campo_5 char(6) := lpad('0',6,'0'); --Número de Referência do Chargeback
                 campo_6 char(1) := lpad(' ',1,' '); --Indicador do Envio de Documentação
                 campo_7 char(50) := lpad(' ',50,' '); --Texto Livre do Emissor
                 campo_8 char(3) := lpad('0',3,'0'); --Código do produto
                 campo_9 char(4) := lpad(' ',4,' '); --Uso futuro
                 campo_10 char(15) := lpad('0',15,'0'); --PV (Ponto de Venda)
                 campo_11 char(8) := lpad('44410903',8,' '); --Número Lógico do Equipamento
                 campo_12 char(12) := lpad('000000000837',12,'0'); --Valor Taxa de Embarque
                 campo_13 char(1) := lpad(' ',1,' '); --Indicador de Transação feita por corresp./Telefone ou comércio eletrônico
                 campo_14 char(12) := lpad('0',12,'0'); --Valor da Transação
                 campo_15 char(1) := lpad('0',1,'0'); --Indicador de Movimentação
                 campo_16 char(3) := lpad('0',3,'0'); --Quantidade de Parcelas da Transação
                 campo_17 char(3) := lpad('1',3,'0'); --Número da Parcela
                 campo_18 char(5) := lpad('25',5,'0'); --Tarifa Pagamento de Insumo
                 campo_19 char(1) := lpad(' ',1,' '); --Tipo de Pessoa
                 campo_20 char(14) := lpad('0',14,'0'); --CNPJ ou CPF
                 campo_21 char(11) := lpad('0',11,'0'); --Valor de Troco ou Agro Debito
                 campo_22 char(1) := lpad('0',1,' '); --Codigo Condicional de Transacao com Chip
                 campo_23 char(1) := lpad(' ',1,' '); --uso futuro

                 l_cod_prod varchar2(50);
                 l_cod_pdv varchar2(15);
                 l_campo_20 varchar2(50);
                 l_campo_19 varchar2(50);
                 l_campo_10 varchar2(50);
       begin

            begin
              SELECT CD_PRDT_BNDR
              INTO l_cod_prod
              FROM CLC.TBCLCW_PRDT_BNDR_RPLC
              WHERE CD_BNDR = l_cod_bandeira
              AND ROWNUM < 2;    
            exception
                     when NO_DATA_FOUND then
                          l_cod_prod := '000';
            end;

            -- CPF ou CNPJ?
            select substr(a.tipo_layout, 3, 2),
                   lpad(nvl(a.nro_cnpj_cpf_te05,'0'),14,'0'), 
                   lpad(nvl(a.nro_ponto_venda_te05,'0'),15,'0'), 
                   lpad(nvl(a.dsc_tipo_pessoa_te05,'X'),1,' '),
                   lpad(nvl(a.cod_produto_te05,l_cod_prod),3,'0') ,
                   lpad(nvl(a.vlr_tran_te05,'000000010000'), 12,'0'),
                   lpad(nvl(a.qtd_parc_tran_te05,'012'),3,'0'),
                   lpad(nvl(a.vl_taxa_embarque,'000000000837'),12,'0'),
                   lpad(nvl(a.nro_parcela,'0'),3,'0')
            into campo_1,
                 campo_20, 
                 campo_10, 
                 campo_19,
                 campo_8, 
                 campo_14, 
                 campo_16,
                 campo_12,
                 campo_17
            from tbl_input_massa_dados a
            where a.nro_identif_gera_massa = p_numero_geracao_massa
                  and a.nro_linha_arquivo = p_nro_linha_arquivo;

            if (campo_20 = lpad('0',14,'0') and campo_19 = 'X' and campo_10 = lpad('0',15,'0')) then
               begin
                 -- usuario nao definiu CPF/CNPJ, tipo pessoa, PDV
                  SELECT case when rplc.SG_TPPS_CLNT = 'J' then
                                            lpad(lpad(rplc.NU_RAIZ_CNPJ_CLNT,8,'0') ||
                                            lpad(rplc.NU_FILI_CNPJ_CLNT,4,'0') ||
                                            lpad(rplc.NU_DV_CNPJ_CLNT,2,'0'),14,'0')
                              when rplc.SG_TPPS_CLNT = 'F' then
                                       lpad(lpad(rplc.NU_CPF_CLNT,9,'0') ||
                                       lpad(rplc.NU_DV_CPF_CLNT,2,'0'),14,'0')
                              end cpf_cnpj,
                         rplc.SG_TPPS_CLNT tipo_pessoa,
                         lpad(to_char(rplc.CD_PDV),15,'0')
                  into l_campo_20, l_campo_19, l_campo_10              
                  FROM CLC.TBCLCW_CRDE_CLNT_PDV_RPLC rplc
                  WHERE CD_BNDR = l_cod_bandeira
                    AND CD_CRDE = l_cod_adquir
                    AND IN_TRNS_FINC = 'S'
                    AND ROWNUM < 2;
               exception
                        when others then
                             l_campo_20 := lpad('0',14,'0');
                             l_campo_19 := lpad('0',1,'0');
                             l_campo_10 := lpad('0',15,'0');                              
               end;
            elsif (campo_19 <> 'X' and campo_20 = lpad('0',14,'0')) then
            begin
               -- usuario definiu tipo_pessoa
                SELECT case when campo_19 = 'J' then 
                                          lpad(lpad(rplc.NU_RAIZ_CNPJ_CLNT,8,'0') ||
                                          lpad(rplc.NU_FILI_CNPJ_CLNT,4,'0') ||
                                          lpad(rplc.NU_DV_CNPJ_CLNT,2,'0'),14,'0')
                            when campo_19 = 'F' then
                                     lpad(lpad(rplc.NU_CPF_CLNT,9,'0') ||
                                     lpad(rplc.NU_DV_CPF_CLNT,2,'0'),14,'0')
                            end cpf_cnpj,
                       lpad(to_char(rplc.CD_PDV),15,'0')
                into l_campo_20, l_campo_10              
                FROM CLC.TBCLCW_CRDE_CLNT_PDV_RPLC rplc
                WHERE CD_BNDR = l_cod_bandeira
                  AND CD_CRDE = l_cod_adquir
                  AND IN_TRNS_FINC = 'S'
                  and rplc.SG_TPPS_CLNT = campo_19
                  and (campo_10 = lpad('0',15,'0')
                        or to_number(campo_10) = rplc.cd_pdv)
                  AND ROWNUM < 2;
             exception
                      when others then
                           l_campo_20 := lpad('0',14,'0');
                           l_campo_10 := lpad('0',15,'0');                              
             end;
            elsif (campo_19 = 'X' and campo_20 <> lpad('0',14,'0')) then
            begin
                  -- usuario definiu CPF ou CNPJ qq
                  SELECT 
                       rplc.SG_TPPS_CLNT tipo_pessoa,
                       lpad(to_char(rplc.CD_PDV),15,'0')                            
                into l_campo_19, l_campo_10
                FROM CLC.TBCLCW_CRDE_CLNT_PDV_RPLC rplc
                WHERE CD_BNDR = l_cod_bandeira
                  AND CD_CRDE = l_cod_adquir
                  AND IN_TRNS_FINC = 'S'
                  and ((rplc.NU_RAIZ_CNPJ_CLNT = substr(to_char( to_number(campo_20)) ,1,8)
                       and rplc.NU_FILI_CNPJ_CLNT = substr(to_char( to_number(campo_20)) ,9,4)
                       and rplc.NU_DV_CNPJ_CLNT = substr(to_char( to_number(campo_20)) ,13,2) 
                       )
                       or
                       (
                       rplc.NU_CPF_CLNT = substr(to_char( to_number(campo_20)) ,1,9)
                       and rplc.NU_DV_CPF_CLNT = substr(to_char( to_number(campo_20)) ,10,2)
                       ))
                  and (campo_10 = lpad('0',15,'0')
                        or to_number(campo_10) = rplc.cd_pdv)
                  AND ROWNUM < 2;
               exception
                        when others then
                             l_campo_19 := lpad('0',1,'0');
                             l_campo_10 := lpad('0',15,'0');                              
               end;      
            elsif (campo_10 <> lpad('0',15,'0') and campo_20 = lpad('0',14,'0') and campo_19 = 'X') then
            begin
                  -- usuario definiu um ponto de venda
                  SELECT case when rplc.SG_TPPS_CLNT = 'J' then
                                          lpad(
                                          lpad(rplc.NU_RAIZ_CNPJ_CLNT,8,'0') ||
                                          lpad(rplc.NU_FILI_CNPJ_CLNT,4,'0') ||
                                          lpad(rplc.NU_DV_CNPJ_CLNT,2,'0'),14,'0')
                            when rplc.SG_TPPS_CLNT = 'F' then
                                     lpad(
                                     lpad(rplc.NU_CPF_CLNT,9,'0') ||
                                     lpad(rplc.NU_DV_CPF_CLNT,2,'0'),14,'0')
                            end cpf_cnpj,
                       rplc.SG_TPPS_CLNT tipo_pessoa
                into l_campo_20, l_campo_19
                FROM CLC.TBCLCW_CRDE_CLNT_PDV_RPLC rplc
                WHERE CD_BNDR = l_cod_bandeira
                  AND CD_CRDE = l_cod_adquir
                  AND IN_TRNS_FINC = 'S'
                  and rplc.cd_pdv = to_number(campo_10)
                  AND ROWNUM < 2;
           exception
                    when others then
                         l_campo_20 := lpad('0',14,'0');
                         l_campo_19 := lpad('0',1,'0');
           end;
            elsif (campo_10 = lpad('0',15,'0')) then
            begin
                SELECT rplc.CD_PDV
                into l_campo_10
                FROM CLC.TBCLCW_CRDE_CLNT_PDV_RPLC rplc
                WHERE CD_BNDR = l_cod_bandeira
                  AND CD_CRDE = l_cod_adquir
                  AND IN_TRNS_FINC = 'S'
                  AND ROWNUM < 2
                  and ((rplc.NU_RAIZ_CNPJ_CLNT = substr(to_char(to_number(campo_20)),1,8)
                      and rplc.NU_FILI_CNPJ_CLNT = substr(to_char(to_number(campo_20)),9,4)
                      and rplc.NU_DV_CNPJ_CLNT = substr(to_char(to_number(campo_20)),13,2)
                      )
                      or
                      (
                      rplc.NU_CPF_CLNT = substr(to_char(to_number(campo_20)),1,9)
                      and rplc.NU_DV_CPF_CLNT = substr(to_char(to_number(campo_20)),10,2)
                      ));
           exception
                    when others then
                         l_campo_10 := lpad('0',15,'0');                              
           end;
            end if;

            if (campo_10 = lpad('0',15,'0')) then
               campo_10 := l_campo_10;
            end if;
            if (campo_19 = lpad(' ',1,' ') or campo_19 = 'X') then
               campo_19 := l_campo_19;
            end if;
            if (campo_20 = lpad('0',14,'0')) then
               campo_20 := l_campo_20;
            end if;
            
            -- Nro Parcela
            if (campo_17 = '000') then
              select lpad(to_char(nvl(max(nu_prcl),0) + 1),3,'0')
              into campo_17
              from CLC.TBCLCR_LNCM_RECB 
              where nu_rfrn = l_nro_referencia;
            end if;
            l_retorno:= lpad(campo_1 || campo_2 || campo_3 || campo_4 || campo_5 || 
                      campo_6 || campo_7 || campo_8 || campo_9 || campo_10 || 
                      campo_11 || campo_12 || campo_13 || campo_14 || campo_15 ||
                      campo_16 || campo_17 || campo_18 || campo_19 || campo_20 ||
                      campo_21 || campo_22 || campo_23,168,' ');
            

            update tbl_input_massa_dados
            set nro_cnpj_cpf_te05 = nvl(nro_cnpj_cpf_te05,campo_20),
                nro_ponto_venda_te05 = nvl(nro_ponto_venda_te05,campo_10),
                dsc_tipo_pessoa_te05 = nvl(dsc_tipo_pessoa_te05,campo_19),
                vlr_tran_te05 = nvl(vlr_tran_te05,campo_14),
                qtd_parc_tran_te05 = nvl(qtd_parc_tran_te05,campo_16),
                cod_produto_te05 = nvl(cod_produto_te05,campo_8),
                vl_taxa_embarque = nvl(vl_taxa_embarque,campo_12),
                nro_parcela = nvl(nro_parcela,campo_17)
            where nro_identif_gera_massa = p_numero_geracao_massa
                        and nro_linha_arquivo = p_nro_linha_arquivo;                
            
       exception
                when others then
                null;
       end;

       PROCEDURE LAYOUT_SUBTIPO_02 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      p_tipo_operacao varchar2,
                                      l_retorno out varchar2 )IS
                 campo_1 char(2) := lpad('00',2,' '); --Código da Transação
                 campo_2 char(2) := lpad('02',2,'0'); --Subcódigo da Transação
                 campo_3 char(12) := lpad(' ',12,' '); --Uso futuro
                 campo_4 char(3) := rpad('BR',3,' '); --Código do Pais da Liquidacao
                 campo_5 char(3) := lpad(' ',3,' '); --Uso Futuro
                 campo_6 char(3) := lpad('0',3,'0'); --Quantidade de dias para Liquidacao Financeira
                 campo_7 char(10) := lpad('0',10,'0'); --Uso Futuro
                 campo_8 char(8) := lpad('0',8,'0'); --Data do movimento da transicao original
                 campo_9 char(5) := lpad(' ',5,' '); --tipo_operacao
                 campo_10 char(19) := lpad(' ',19,' '); --uso futuro
                 campo_11 char(11) := lpad(' ',11,' '); --uso futuro
                 campo_12 char(2) := lpad(' ',2,' '); --uso futuro
                 campo_13 char(88) := lpad(' ',88,' '); --uso futuro
       begin

            select substr(a.tipo_layout, 3, 2),
                   lpad(nvl(a.qtd_dias_liq_tran_te05,'003'),3,'0')
            into campo_1,
                 campo_6
            from tbl_input_massa_dados a
            where a.nro_identif_gera_massa = p_numero_geracao_massa
                  and a.nro_linha_arquivo = p_nro_linha_arquivo;

            if (campo_1 = '06') then
                campo_8 := to_char(sysdate,'YYYY') || lpad(to_char(sysdate,'MM'),2,'0') || lpad(to_char(sysdate,'DD'),2,'0');
            end if;

            campo_9 := rpad(nvl(p_tipo_operacao,' '),5,' ');

            l_retorno:= lpad(campo_1 || campo_2 || campo_3 || campo_4 || campo_5 || 
                      campo_6 || campo_7 || campo_8 || campo_9 || campo_10 || 
                      campo_11 || campo_12 || campo_13 ,168,' ');
                      
            update tbl_input_massa_dados a
            set qtd_dias_liq_tran_te05 = nvl(qtd_dias_liq_tran_te05,campo_6),
                dsc_tipo_operacao_te05 = nvl(dsc_tipo_operacao_te05,campo_9)
            where nro_identif_gera_massa = p_numero_geracao_massa
                        and nro_linha_arquivo = p_nro_linha_arquivo;                
                
       exception
                when others then
                null;
       end;

      PROCEDURE LAYOUT_SUBTIPO_05 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2 )IS
                 campo_1 char(2) := lpad('00',2,'0'); --Código da Transação
                 campo_2 char(1) := lpad('0',1,'0'); --Codigo Qualificador da Transacao
                 campo_3 char(1) := lpad('5',1,'0'); --Numero de Sequencia do Componente da Transacao
                 campo_4 char(15) := rpad('0',15,'0'); --Identificador da Transacao
                 campo_5 char(12) := lpad('0',12,'0'); --Valor Autorizado
                 campo_6 char(3) := lpad(' ',3,' '); --Codigo da Moeda do Valor Autorizado
                 campo_7 char(2) := lpad(' ',2,' '); --Codigo de Resposta da Autorizacao
                 campo_8 char(4) := lpad(' ',4,' '); --Codigo de Validacao
                 campo_9 char(1) := lpad(' ',1,' '); --Indicador de Transacao Excluida
                 campo_10 char(1) := lpad(' ',1,' '); --Codigo do ProcessamentoCRS
                 campo_11 char(2) := lpad(' ',2,' '); --Indicador de Direito de Devolucao
                 campo_12 char(2) := lpad('0',2,'0'); --Numero Sequencial da Conta
                 campo_13 char(2) := lpad('0',2,'0'); --Contador Sequencial de Envio
                 campo_14 char(1) := lpad(' ',1,' '); --Contador Sequencial de Envio
                 campo_15 char(12) := lpad('0',12,'0'); --Contador Sequencial de Envio
                 campo_16 char(107) := lpad(' ',107,' '); --Contador Sequencial de Envio
       begin

            select substr(a.tipo_layout, 3, 2)
            into campo_1
            from tbl_input_massa_dados a
            where a.nro_identif_gera_massa = p_numero_geracao_massa
                  and a.nro_linha_arquivo = p_nro_linha_arquivo;

            l_retorno:= '0505000000000000000000000000000   00        0000 000000000000                                                                                                           ';
            l_retorno:= lpad(campo_1 || campo_2 || campo_3 || campo_4 || campo_5 || 
                      campo_6 || campo_7 || campo_8 || campo_9 || campo_10 || 
                      campo_11 || campo_12 || campo_13 || campo_14 || campo_15 ||
                      campo_16,168,' ');

       exception
                when others then
                null;
       end;

      PROCEDURE LAYOUT_SUBTIPO_07 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2 )IS
                 campo_1 char(2) := lpad('00',2,'0'); --Código da Transação
                 campo_2 char(1) := lpad('0',1,'0'); --Codigo Qualificador da Transacao
                 campo_3 char(1) := lpad('5',1,'0'); --Número de Sequência do Componente da Transação
                 campo_4 char(2) := rpad('0',2,'0'); --Tipo de Transação
                 campo_5 char(3) := lpad('0',3,'0'); --Número Sequencial do Cartão
                 campo_6 char(6) := lpad(' ',6,' '); --Data de Transação do Terminal
                 campo_7 char(6) := lpad(' ',6,' '); --Capacidade do Termina
                 campo_8 char(3) := lpad(' ',3,' '); --Código do País do Terminal
                 campo_9 char(8) := lpad(' ',8,' '); --Número de Série do Terminal 
                 campo_10 char(8) := lpad(' ',8,' '); --Número Randômico para Criptograma
                 campo_11 char(4) := lpad(' ',4,' '); --Contador da Transação da Aplicação
                 campo_12 char(4) := lpad('0',4,'0'); --Application Interchange Profile
                 campo_13 char(16) := lpad('0',16,'0'); --Criptograma
                 campo_14 char(2) := lpad(' ',2,' '); --Índice de Derivação da Chave 
                 campo_15 char(2) := lpad('0',2,'0'); --Número da Versão do Criptograma
                 campo_16 char(10) := lpad(' ',10,' '); --Verificação do Resultado do Terminal
                 campo_17 char(8) := lpad(' ',8,' '); --Verificação do Resultado do Cartão

                 campo_18 char(12) := lpad(' ',12,' '); --Valor de Transação para Criptograma
                 campo_19 char(60) := lpad(' ',60,' '); --Uso futuro
                 campo_20 char(10) := lpad(' ',10,' '); --
       begin
       
            select substr(a.tipo_layout, 3, 2)
            into campo_1
            from tbl_input_massa_dados a
            where a.nro_identif_gera_massa = p_numero_geracao_massa
                  and a.nro_linha_arquivo = p_nro_linha_arquivo;

            l_retorno:= campo_1 || substr('0700000170110E0E0C0076444109036E07216A34565800E22E009269275117010C800000800003648000000000010000                                                                      ',1,166);
       exception
                when others then
                null;
       end;       
       PROCEDURE GERACAO_MASSA (p_numero_geracao_massa varchar2) IS
            l_dsc_linha_arquivo varchar2(400);
            l_numero_geracao_massa number;
            l_i number:=0;

            l_nome_arquivo varchar2(50);
            l_nro_parcela number;
       BEGIN
            l_numero_geracao_massa := to_number(p_numero_geracao_massa);

            IF l_tipo_arquivo = 'CRD' THEN
                l_nome_arquivo := lpad(l_cod_bandeira,3,'0') || lpad(l_cod_adquir,4,'0') || l_cod_tipo_plataforma;
            ELSIF l_tipo_arquivo = 'EMI' THEN 
                l_nome_arquivo := lpad(l_cod_bandeira,3,'0') || lpad(l_cod_adquir,4,'0') || l_cod_processadora || l_cod_tipo_plataforma || to_char(sysdate,'yyyymmddHH24miss');
            END IF;


            insert into TBL_OUTPUT_MASSA_DADOS (NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO, DSC_LINHA_ARQUIVO)
            values (l_numero_geracao_massa,l_i,l_nome_arquivo);
            l_i := l_i + 1;

            LAYOUT_B0 (l_numero_geracao_massa,l_dsc_linha_arquivo);
            insert into TBL_OUTPUT_MASSA_DADOS (NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO, DSC_LINHA_ARQUIVO)
            values (l_numero_geracao_massa,l_i,l_dsc_linha_arquivo);
             l_i :=  l_i + 1;

             GERACAO_MASSA_TE (p_numero_geracao_massa,l_i);

            LAYOUT_BZ (l_numero_geracao_massa,l_dsc_linha_arquivo);
            insert into TBL_OUTPUT_MASSA_DADOS (NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO, DSC_LINHA_ARQUIVO)
            values (l_numero_geracao_massa,l_i,l_dsc_linha_arquivo);
            commit;

       END;
       
       PROCEDURE GERACAO_MASSA_TE (p_numero_geracao_massa varchar2,l_i in out number) IS
            l_dsc_linha_arquivo varchar2(400);
            l_numero_geracao_massa number;

            l_nome_arquivo varchar2(50);
            l_nro_parcela number := 1;
            l_data_venda varchar2(8);
       BEGIN
            l_numero_geracao_massa := to_number(p_numero_geracao_massa);

            for rc in (select a.nro_identif_gera_massa,
                              a.nro_linha_arquivo,
                              a.dsc_tipo_operacao_te05,
                              a.cod_produto_te05,
                              a.tipo_layout
                      from tbl_input_massa_dados a
                      where a.nro_identif_gera_massa = p_numero_geracao_massa
                      order by a.nro_linha_arquivo) loop
                     
                if (rc.cod_produto_te05 = '72' or rc.cod_produto_te05 = '072') then                    
                        l_data_venda := to_char(sysdate-1,'YYYYMMDD');
                        if (rc.dsc_tipo_operacao_te05 = '990') then
                             LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,'990',l_i,rc.tipo_layout);
                        elsif (rc.dsc_tipo_operacao_te05 = '991') then
                             LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,'991',l_i,rc.tipo_layout);
                             LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,'994',l_i,rc.tipo_layout);
                        elsif (rc.dsc_tipo_operacao_te05 = '992') then
                             LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,'992',l_i,rc.tipo_layout);
                             LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,'995',l_i,rc.tipo_layout);
                        elsif (rc.dsc_tipo_operacao_te05 = '993') then
                             LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,'993',l_i,rc.tipo_layout);
                             LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,'994',l_i,rc.tipo_layout);
                             LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,'995',l_i,rc.tipo_layout);
                        else 
                             LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,rc.dsc_tipo_operacao_te05,l_i,rc.tipo_layout);
                        end if;
                else
                        LAYOUT_OPERACAO (p_numero_geracao_massa,rc.nro_linha_arquivo,rc.dsc_tipo_operacao_te05,l_i,rc.tipo_layout);
                end if;
            end loop;

       END;
       
      PROCEDURE LAYOUT_OPERACAO (p_numero_geracao_massa number,
                                   p_nro_linha_arquivo number,
                                   l_cod_tipo_operacao varchar2,
                                   l_i in out number,
                                   tipo_layout varchar2) is
            l_dsc_linha_arquivo varchar2(400);                                   
       begin
                LAYOUT_SUBTIPO_00 (p_numero_geracao_massa,p_nro_linha_arquivo,l_dsc_linha_arquivo);
                insert into TBL_OUTPUT_MASSA_DADOS (NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO, DSC_LINHA_ARQUIVO)
                values (p_numero_geracao_massa,l_i,l_dsc_linha_arquivo);
                l_i :=  l_i + 1;
                LAYOUT_SUBTIPO_01 (p_numero_geracao_massa,p_nro_linha_arquivo,l_dsc_linha_arquivo);
                insert into TBL_OUTPUT_MASSA_DADOS (NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO, DSC_LINHA_ARQUIVO)
                values (p_numero_geracao_massa,l_i,l_dsc_linha_arquivo);
                l_i :=  l_i + 1;
                LAYOUT_SUBTIPO_02 (p_numero_geracao_massa,p_nro_linha_arquivo,l_cod_tipo_operacao,l_dsc_linha_arquivo);
                insert into TBL_OUTPUT_MASSA_DADOS (NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO, DSC_LINHA_ARQUIVO)
                values (p_numero_geracao_massa,l_i,l_dsc_linha_arquivo);
                l_i :=  l_i + 1;
                if (tipo_layout = 'TE05' or tipo_layout = 'TE25') then
                  LAYOUT_SUBTIPO_05 (p_numero_geracao_massa,p_nro_linha_arquivo,l_dsc_linha_arquivo);
                  insert into TBL_OUTPUT_MASSA_DADOS (NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO, DSC_LINHA_ARQUIVO)
                  values (p_numero_geracao_massa,l_i,l_dsc_linha_arquivo);
                  l_i :=  l_i + 1;
                  LAYOUT_SUBTIPO_07 (p_numero_geracao_massa,p_nro_linha_arquivo,l_dsc_linha_arquivo);
                  insert into TBL_OUTPUT_MASSA_DADOS (NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO, DSC_LINHA_ARQUIVO)
                  values (p_numero_geracao_massa,l_i,l_dsc_linha_arquivo);
                  l_i :=  l_i + 1;
                end if;
       end;
       


       PROCEDURE INPUT_DADOS_VALIDACAO ( 
              p_numero_geracao_massa in out varchar2,
              p_numero_linha_arquivo varchar2,   
              p_dsc_linha_arquivo varchar2) IS
                 l_numero_geracao_massa number;
       begin
            if (to_number(p_numero_geracao_massa) = 0) then
               select SQ_INPUT_MASSA_DADOS.nextval into l_numero_geracao_massa
               from dual;
            else 
                 l_numero_geracao_massa := to_number(p_numero_geracao_massa);
            end if;
            insert into tbl_output_massa_dados (nro_identif_gera_massa, nro_linha_arquivo, dsc_linha_arquivo)
            values (l_numero_geracao_massa, p_numero_linha_arquivo, p_dsc_linha_arquivo);

            p_numero_geracao_massa := to_char(l_numero_geracao_massa);            
            commit;
       end;


    PROCEDURE GERACAO_CRITICAS (p_numero_geracao_massa number) IS
        l_nome_arquivo varchar2(500);
    BEGIN
         select x.dsc_linha_arquivo
         into l_nome_arquivo
         from tbl_output_massa_dados x
         where nro_identif_gera_massa = p_numero_geracao_massa
         and nro_linha_arquivo = 0;

         if ( length(rtrim(ltrim(l_nome_arquivo))) = 8 ) then
            l_cod_tipo_plataforma := substr(rtrim(ltrim(l_nome_arquivo)),-1);
         end if;


         LAYOUT_B0_CRITICAS(p_numero_geracao_massa);
         LAYOUT_TE0500_CRITICAS(p_numero_geracao_massa);
         LAYOUT_TE0501_CRITICAS(p_numero_geracao_massa);
         LAYOUT_TE0502_CRITICAS(p_numero_geracao_massa);
         LAYOUT_BZ_CRITICAS(p_numero_geracao_massa);

         commit;
    END;

    PROCEDURE LAYOUT_B0_CRITICAS (p_numero_geracao_massa number) IS
      l_dsc_linha_arquivo varchar2(500);
      l_nro_linha_arquivo number;
      l_retorno varchar2(500);
      l_i number:=0;
      l_teste_numerico number;
      l_teste_qtde number;
      campo_1 char(2); --Codigo do Registro (1)
      campo_2 char(2); --Codigo do Servico (3)
      campo_3 char(8); --Data da Remessa (5)
      campo_4 char(4); --Numero da Remessa (13)
      campo_5 char(4); --Uso futuro (17)
      campo_6 char(8); --Data de envio (21)
      campo_7 char(6); --Hora de Envio do Arquivo (29)
      campo_8 char(8); --Data de Retorno do Arquivo (35)
      campo_9 char(6); --Hora de Retorno do Arquivo (43)
      campo_10 char(4); --Banco Emissor (49)
      campo_11 char(4); --Codigo da Processadora (53)
      campo_12 char(100); --Uso Futuro (57)
      campo_13 char(8); --Codigo do adquirente (157)
      campo_14 char(3); --Codigo da bandeira (165)
      campo_15 char(1); --(Indicador de Rota do Arquivo (168)

      erro_linha_b0 exception ;
    BEGIN
         begin
           select dsc_linha_arquivo,nro_linha_arquivo
           into l_dsc_linha_arquivo, l_nro_linha_arquivo
           from TBL_OUTPUT_MASSA_DADOS m
           where m.nro_identif_gera_massa = p_numero_geracao_massa
           and m.nro_linha_arquivo = 1;
         exception
                  when DUP_VAL_ON_INDEX then
                       null;
         end;

         campo_1 := substr(l_dsc_linha_arquivo,1,2);
         campo_2 := substr(l_dsc_linha_arquivo,3,2);
         campo_3 := substr(l_dsc_linha_arquivo,5,8);
         campo_4 := substr(l_dsc_linha_arquivo,13,4);
         campo_5 := substr(l_dsc_linha_arquivo,17,4);
         campo_6 := substr(l_dsc_linha_arquivo,21,8);
         campo_7 := substr(l_dsc_linha_arquivo,29,6);
         campo_8 := substr(l_dsc_linha_arquivo,35,8);
         campo_9 := substr(l_dsc_linha_arquivo,43,6);
         campo_10 := substr(l_dsc_linha_arquivo,49,4);
         campo_11 := substr(l_dsc_linha_arquivo,53,4);
         campo_12 := substr(l_dsc_linha_arquivo,57,100);
         campo_13 := substr(l_dsc_linha_arquivo,157,8);
         campo_14 := substr(l_dsc_linha_arquivo,165,3);
         campo_15 := substr(l_dsc_linha_arquivo,168,1);


         l_retorno :=  'Código do Registro' || ':' || campo_1 || '| ' ||
                                'Código do Serviço' || ':' || campo_2 || '| ' ||
                                'Data da Remessa' || ':' || campo_3 || '| ' ||
                                'Número da Remessa' || ':' || campo_4 || '| ' ||
                                'Uso Futuro' || ':' || campo_5 || '| ' ||
                                'Data de Envio' || ':' || campo_6 || '| ' ||
                                'Hora de Envio do Arquivo' || ':' || campo_7 || '| ' ||
                                'Data de Retorno do Arquivo' || ':' || campo_8 || '| ' ||
                                'Hora de Retorno do Arquivo' || ':' || campo_9 || '| ' ||
                                'Banco Emissor' || ':' || campo_10 || '| ' ||
                                'Código da Processadora' || ':' || campo_11 || '| ' ||
                                'Uso Futuro' || ':' || campo_12 || '| ' ||
                                'Código do Adquirente' || ':' || campo_13 || '| ' ||
                                'Código da Bandeira' || ':' || campo_14 || '| ' ||
                                'Indicador de Rota do Arquivo' || ':' || campo_15 ; 
         l_cod_bandeira := campo_14;
         l_cod_adquir := campo_13;
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------B0----------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);


         if (campo_1 <> 'B0') then
                  l_retorno:= 'B0:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || ':Regra 6.6 - 15' || ':Codigo Do Registro:' || campo_1 || ': Validacao Fisica: Codigo do Registro deve ser B0.';
                  PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                  --raise erro_linha_b0;
         end if;

         if (campo_15 <> '1') then
                  l_retorno:= 'B0:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || ':Regra 6.6 - 22' || ':Indicador de Rota do Arquivo:' || campo_15 || ': Validacao Fisica/Logica: Código de Rota do Arquivo deve ser 1.';
                  PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                  --raise erro_linha_b0;
         end if;

         ------------ Código da Bandeira
         begin
              select to_number(campo_14) into l_teste_numerico
              from dual;
         exception
              when others then
                  l_retorno:= 'B0:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || ':Regra 6.6 - 13' || ':Codigo Da Bandeira:' ||  campo_14 || ': Validacao Fisica: Codigo da Bandeira nao e numerico.';
                  PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                  --raise erro_linha_b0;
         end;

         select count(1)
         into l_teste_qtde
         from CCR.TBCCRR_BNDR 
         where CD_BNDR = to_number(campo_14);

         if (l_teste_qtde <> 1) then
             l_retorno:= 'B0:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || ':Regra 6.6 - 13' || ':Codigo Da Bandeira:' ||  campo_14 || ': Validacao Logica: Codigo da Bandeira nao existe na Base de Bandeiras.';                       
             PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
             --raise erro_linha_b0;
         end if;

         ------------Código Adquirente
         begin
              select to_number(campo_13) into l_teste_numerico
              from dual;
         exception
              when others then
                  l_retorno:= 'B0:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || ':Regra 6.6 - 14' || ':Codigo do Adquirente:'  || campo_13 || ': Validacao Fisica: Codigo do Adquirente nao e numerico.';
                 PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                 --raise erro_linha_b0;
         end;


        SELECT count(1)
        into l_teste_qtde
        FROM CCR.TBCCRR_CRDE_BNDR 
        WHERE CD_BNDR = to_number(campo_14) 
              AND CD_CRDE = to_number(campo_13)
              AND IN_CRDE_ATVO = 'S' 
              AND ROWNUM = 1;    
         if (l_teste_qtde <> 1) then
             l_retorno:= 'B0:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || ':Regra 6.6 - 14' || ':Codigo do Adquirente:' ||  campo_13 || ': Validacao Logica: Codigo do Adquirente nao existe na Base de Adquirentes.';                       
             PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
             --raise erro_linha_b0;
         end if;

         -------------Codigo do Servico
         begin
              select to_number(campo_2) into l_teste_numerico
              from dual;
         exception
              when others then
                 l_retorno:= 'B0:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 11:',20,' ') || lpad('Código do Serviço:',45,' ') ||  campo_2 || ': Validacao Fisica: Numerico.';
                 PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                 --raise erro_linha_bz;
         end;

         SELECT COUNT(1)
         into l_teste_qtde 
         FROM CLC.TBCLCR_SRVC_BNDR 
         WHERE CD_SRVC_BNDR = campo_2 
               AND CD_BNDR = l_cod_bandeira;

         if(l_teste_qtde < 1) then
              l_retorno:= 'B0:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 11:',20,' ') || lpad('Codigo do Servico:',45,' ') ||  campo_2 || ': Validacao Logica: Deve existir na tabela Tipos de Servico x Emissor.';
              PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
         end if;
         l_cod_servico := campo_2;

    EXCEPTION
             WHEN erro_linha_b0 THEN
                  null;
    END;

    PROCEDURE LAYOUT_BZ_CRITICAS (p_numero_geracao_massa number) IS
      l_dsc_linha_arquivo varchar2(500);
      l_nro_linha_arquivo number;
      l_retorno varchar2(4000);
      l_i number:=0;
      l_teste_numerico number;
      l_teste_qtde number;

      campo_1 char(2); --Codigo do Registro (1)
      campo_2 char(2); --Codigo do Servico (3)
      campo_3 char(4); --Numero da Remessa (13)
      campo_4 char(8); --Quantidade de transacoes de Credito em Moeda Real
      campo_5 char(15); --Valor total das transacoes de creditos em moeda real
      campo_6 char(8); --Quantidade de transacoes de Debito em Moeda Real
      campo_7 char(15); --Valor total das transacoes de Debito em moeda real
      campo_8 char(8); --Quantidade de Transacoes de Credito em Moeda Dolar (uso futuro)
      campo_9 char(15); --Valor total das transacoes de creditos em moeda real (uso futuro)
      campo_10 char(8); --Quantidade de transacoes de Debito em Moeda Real (uso futuro)
      campo_11 char(15); --Valor total das transacoes de Debito em moeda real (uso futuro)
      campo_12 char(8); --quantidade total de registros
      campo_13 char(8); --quantidade de transacoes de movimentacao de parcelado
      campo_14 char(15); --valor total das transacoes de movimentacao de parcelado
      campo_15 char(36); --uso futuro
      campo_16 char(1); --indicador de rota de arquivo

      erro_linha_bz exception ;
    BEGIN

         select max(nro_linha_arquivo)
         into l_i
         from tbl_critica_massa_dados
         where nro_identif_gera_massa = p_numero_geracao_massa;
         l_i := l_i + 1;

         begin
           select max(nro_linha_arquivo)
           into l_nro_linha_arquivo
           from TBL_OUTPUT_MASSA_DADOS m
           where m.nro_identif_gera_massa = p_numero_geracao_massa;


           select dsc_linha_arquivo
           into l_dsc_linha_arquivo
           from TBL_OUTPUT_MASSA_DADOS m
           where m.nro_identif_gera_massa = p_numero_geracao_massa
           and m.nro_linha_arquivo = l_nro_linha_arquivo;
         exception
                  when DUP_VAL_ON_INDEX then
                       null;
         end;

         campo_1 := substr(l_dsc_linha_arquivo,1,2);
         campo_2 := substr(l_dsc_linha_arquivo,3,2);
         campo_3 := substr(l_dsc_linha_arquivo,5,4);
         campo_4 := substr(l_dsc_linha_arquivo,9,8);
         campo_5 := substr(l_dsc_linha_arquivo,17,15);
         campo_6 := substr(l_dsc_linha_arquivo,32,8);
         campo_7 := substr(l_dsc_linha_arquivo,40,15);
         campo_8 := substr(l_dsc_linha_arquivo,55,8);
         campo_9 := substr(l_dsc_linha_arquivo,63,15);
         campo_10 := substr(l_dsc_linha_arquivo,78,8);
         campo_11 := substr(l_dsc_linha_arquivo,86,15);
         campo_12 := substr(l_dsc_linha_arquivo,101,8);
         campo_13 := substr(l_dsc_linha_arquivo,109,8);
         campo_14 := substr(l_dsc_linha_arquivo,117,15);
         campo_15 := substr(l_dsc_linha_arquivo,132,36);
         campo_16 := substr(l_dsc_linha_arquivo,168,1);


         l_retorno :=  'Codigo do Registro' || ':' || campo_1 || '| ' ||
                                'Codigo do Serviço' || ':' || campo_2 || '| ' ||
                                'Numero da Remessa' || ':' || campo_3 || '| ' ||
                                'Quantidade de Transacoes de Credito Real' || ':' || campo_4 || '| ' ||
                                'Valor Total das Transacoes de Creditos Real' || ':' || campo_5 || '| ' ||
                                'Quantidade de Transacoes de Debito Real' || ':' || campo_6 || '| ' ||
                                'Valor Total das Transacoes de Debitos Real' || ':' || campo_7 || '| ' ||
                                'Quantidade de Transacoes de Credito Dolar' || ':' || campo_8 || '| ' ||
                                'Valor Total das Transacoes de Creditos Dolar' || ':' || campo_9 || '| ' ||
                                'Quantidade de Transacoes de Debito Dolar' || ':' || campo_10 || '| ' ||
                                'Valor Total das Transacoes de Debitos Dolar' || ':' || campo_11 || '| ' ||
                                'Qtde Total de Registros' || ':' || campo_12 || '| ' ||
                                'Qtde de Transacoes de Movimentacao de Parcelado' || ':' || campo_13 || '| ' ||
                                'Valor Total de Transacoes de Movimentacoes de Parcelado' || ':' || campo_14 || '| ' ||
                                'Uso Futuro' || ':' || campo_15 || '| ' ||
                                'Indicador de Rota do Arquivo' || ':' || campo_16; 

         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------BZ----------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');         
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);

         if (campo_1 <> 'BZ') then
                  l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 15:',20,' ') || lpad('Codigo Do Registro:',45,' ')  || campo_1 || ': Validacao Fisica: Codigo do Registro deve ser BZ.';
                  PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                  --raise erro_linha_bz;
         end if;

         if (campo_16 <> '1') then
                  l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad('Regra 6.6 - 22:',20,' ') || lpad(':Indicador de Rota do Arquivo:',45,' ') || campo_16 || ': Validacao Fisica/Logica: Código de Rota do Arquivo deve ser 1.';
                  PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                  --raise erro_linha_bz;
         end if;

         ------------Número da Remessa
         begin
              select to_number(campo_3) into l_teste_numerico
              from dual;
         exception
              when others then
                 l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 16:',20,' ') || lpad('Numero da Remessa:',45,' ') ||  campo_3 || ': Validacao Fisica: Numero da Remessa nao e numerico.';
                 PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                 --raise erro_linha_bz;
         end;

         ------ Numero da Remessa
          SELECT case when (NVL( MAX( NU_RMSA_CRDE ), 0 ) + 1 = to_number(campo_3)) then 1 else 0 end
          into l_teste_qtde
          FROM CLC.TBCLCR_RMSA_CRDE 
          WHERE CD_BNDR = l_cod_bandeira
          AND CD_CRDE = l_cod_adquir
          AND CD_TIPO_PLTF_PGMN = l_cod_tipo_plataforma;

         if (l_teste_qtde <> 1) then
             l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 02:',20,' ') || lpad('Numero da Remessa:',45,' ') ||  campo_3 || ': Validacao Logica: Deve ser validado contra o Controle de Remessa.';
             PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
             --raise erro_linha_bz;
         end if;

         begin
           select sum(valor)
           into l_teste_qtde
           from (
            select to_number(substr(dsc_linha_arquivo,77,12)) valor
            from tbl_output_massa_dados a
            where nro_identif_gera_massa = 17
            and dsc_linha_arquivo like '0500%'
            and translate(substr(dsc_linha_arquivo,77,12),' +-0123456789.', ' ') is null);
         exception
                  when others then
                       l_teste_qtde := 0;
         end;
         -- Valor Total dos Transacoes de Debito Real
         begin
              select to_number(campo_7)
              into l_teste_numerico
              from tbl_output_massa_dados m
              where m.nro_identif_gera_massa = p_numero_geracao_massa
                    and m.nro_linha_arquivo = l_nro_linha_arquivo;
              if (l_teste_qtde <> campo_7) then
                l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 05:',20,' ') || lpad('Valor Total ads Transacoes de Movi de Parcelado:',45,' ') || campo_7 || ': Validacao Logica: Deve ser igual ao somatorio do valor das transacoes debito real.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
              end if;
         exception
            when others then
              l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 05:',20,' ') || lpad('Valor Total ads Transacoes de Movi de Parcelado:',45,' ') ||  campo_7 || ': Validacao Fisica: O valor deve ser numerico.';
              PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
         end;


         -- Quantidade de Transacoes de Debito Real
         select count(1)
         into l_teste_qtde
         from (select length(trim(translate(substr(dsc_linha_arquivo,77,12),' +-0123456789.', ' '))) teste_numerico,
                        to_number(substr(dsc_linha_arquivo,77,12)) valor
               from tbl_output_massa_dados a
               where nro_identif_gera_massa = p_numero_geracao_massa
               and dsc_linha_arquivo like '0500%');
--         where teste_numerico is not null;

         begin
              select to_number(campo_6)
              into l_teste_numerico
              from tbl_output_massa_dados m
              where m.nro_identif_gera_massa = p_numero_geracao_massa
                    and m.nro_linha_arquivo = l_nro_linha_arquivo;
              if (l_teste_qtde <> campo_6) then
                l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 05:',20,' ') || lpad('Quantidadede Transacoes Debito Real:',45,' ') ||  campo_7 || ': Validacao Logica: Deve ser igual ao nro de registros do tipo 00.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
              end if;
         exception
            when others then
              l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 05:',20,' ') || lpad('Quantidadede Transacoes Debito Real:',45,' ') ||  campo_7 || ': Validacao Fisica: O valor deve ser numerico.';
              PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
         end;


         ------------Qunatidade Total de Registros
         begin
              select to_number(campo_12) into l_teste_numerico
              from dual;
         exception
              when others then
                 l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 03:',20,' ') || lpad('Qunatidade Total de Registros:',45,' ') ||  campo_12 || ': Validacao Fisica: Numerico e diferente de zeros.';
                 PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                 --raise erro_linha_bz;
         end;

         select count(1)
         into l_teste_qtde
         from tbl_output_massa_dados m
         where m.nro_identif_gera_massa = p_numero_geracao_massa
         and m.nro_linha_arquivo <> 0;

         if(l_teste_qtde <> campo_12) then
              l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 03:',20,' ') || lpad('Quantidade Total de Registros:',45,' ') ||  campo_12 || ': Validacao Logica: Deve ser a quantidade total de registros no arquivio. Incluindo Header e Trailler.';
              PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
         end if;

         -------------Codigo do Servico
         begin
              select to_number(campo_2) into l_teste_numerico
              from dual;
         exception
              when others then
                 l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 11:',20,' ') || lpad('Código do Serviço:',45,' ') ||  campo_2 || ': Validacao Fisica: Numerico.';
                 PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                 --raise erro_linha_bz;
         end;

         SELECT COUNT(1)
         into l_teste_qtde 
         FROM CLC.TBCLCR_SRVC_BNDR a
         WHERE CD_SRVC_BNDR = campo_2 
               AND CD_BNDR = l_cod_bandeira;

         if(l_teste_qtde < 1) then
              l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - 11:',20,' ') || lpad('Codigo do Servico:',45,' ') ||  campo_2 || ': Validacao Logica: Deve existir na tabela Tipos de Servico x Emissor.';
              PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
         end if;

         if (l_cod_servico <> campo_2) then
              l_retorno:= 'BZ:' || lpad(to_char(l_nro_linha_arquivo),4,'0') || lpad(':Regra 6.6 - XX:',20,' ') || lpad('Codigo do Servico:',45,' ') ||  l_cod_servico || '|' || campo_2 || ': Validacao Logica: Codigo do Servico deve ser igual em B0 e BZ.';
              PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
         end if;


    EXCEPTION
             WHEN erro_linha_bz THEN
                  null;
    END;
    PROCEDURE LAYOUT_TE0500_CRITICAS (p_numero_geracao_massa number ) IS
       l_dsc_linha_arquivo varchar2(500);
       l_retorno varchar2(400);
       l_i number := 1;

    BEGIN
         begin
           select nvl(max(nro_linha_arquivo),1)
           into l_i
           from tbl_critica_massa_dados
           where nro_identif_gera_massa = p_numero_geracao_massa;
        exception
             when others then
                 l_i :=1;
         end;
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------0500--------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');

         for rc in (select distinct nro_linha_arquivo,dsc_linha_arquivo,
                           campo_8, valida_campo_8,
                           campo_17, valida_campo_17,
                           campo_3, valida_campo_3,
                           campo_11, valida_campo_11,
                           campo_19, valida_campo_19,
                           campo_16, valida_campo_16,
                           bin, valida_bin
                    from (select nro_linha_arquivo,dsc_linha_arquivo,
                                 substr(dsc_linha_arquivo,50,8) campo_8, --Codigo adquirente
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,50,8) )),' +-0123456789.', ' ') valida_campo_8,
                                 substr(dsc_linha_arquivo,137,5) campo_17, --banco emissor
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,137,5) )),' +-0123456789.', ' ') valida_campo_17,
                                 substr(dsc_linha_arquivo,5,19) campo_3, --numero cartao - B13
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,5,19) )),' +-0123456789.', ' ') valida_campo_3,
                                 substr(dsc_linha_arquivo,77,12) campo_11, --valor venda
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,77,12) )),' +-0123456789.', ' ') valida_campo_11,
                                 substr(dsc_linha_arquivo,144,3) campo_19, --codigo da Bandeira
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,144,3) )),' +-0123456789.', ' ') valida_campo_19,
                                 substr(dsc_linha_arquivo,133,4) campo_16, --MCC do PV
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,133,4) )),' +-0123456789.', ' ') valida_campo_16,
                                 substr(rtrim(ltrim( substr(dsc_linha_arquivo,27,23))),2,6) bin,
                                 translate(rtrim(ltrim( substr(rtrim(ltrim( substr(dsc_linha_arquivo,27,23))),2,6) )),' +-0123456789.', ' ') valida_bin
                          from TBL_OUTPUT_MASSA_DADOS m
                          where m.dsc_linha_arquivo like '0500%'
                          and m.nro_identif_gera_massa = p_numero_geracao_massa) 
                    where (valida_campo_8 is not null or
                          valida_campo_17 is not null or
                          valida_campo_3 is not null or
                          (valida_campo_3 is null and to_number(campo_3) = 0) or
                          (valida_campo_3 is null and length(rtrim(ltrim(campo_3))) < 16) or
                          valida_campo_11 is not null or
                          (valida_campo_11 is null and to_number(campo_11) = 0) or
                          valida_campo_19 is not null or
                          valida_campo_16 is not null or
                          valida_bin is not null)) loop

            PERSISTE_CRITICA(p_numero_geracao_massa,l_i,rc.dsc_linha_arquivo);

            if (rc.valida_campo_11 is not null or
                (rc.valida_campo_11 is null and to_number(rc.campo_11) = 0)) then
                l_retorno:= '0500:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B09:',20,' ') || 
                            rpad('Valor da Venda:',45,' ') ||  
                            lpad(rc.campo_11,20,' ') || 
                            ': Validacao Fisica: Valor deve ser numerico e diferente de zeros.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_8 is not null ) then
                l_retorno:= '0500:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B11:',20,' ') || 
                            rpad('Codigo Adquirente:',45,' ') ||  
                            lpad(rc.campo_8,20,' ') || 
                            ': Validacao Fisica: Valor deve ser numerico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);                
            end if;
            if (rc.valida_campo_17 is not null ) then
                l_retorno:= '0500:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B12:',20,' ') || 
                            rpad('Banco Emissor:',45,' ') ||  
                            lpad(rc.campo_17,20,' ') || 
                            ': Validacao Fisica: Valor deve ser numerico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_3 is not null or
               ( rc.valida_campo_3  is null and to_number(rc.campo_3) = 0) or
               ( rc.valida_campo_3 is null and length(rtrim(ltrim(rc.campo_3))) < 16)) then
                l_retorno:= '0500:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B13:',20,' ') || 
                            rpad('Numero do Cartao:',45,' ') ||  
                            lpad(rc.campo_3,20,' ') || 
                            ': Validacao Fisica: Preenchimento Inalido.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_16 is not null ) then
                l_retorno:= '0500:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B14:',20,' ') || 
                            rpad('MCC do PV:',45,' ') ||  
                            lpad(rc.campo_16,20,' ') || 
                            ': Validacao Fisica: Valor deve ser numerico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;
            if (rc.valida_campo_19 is not null ) then
                l_retorno:= '0500:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -BXX:',20,' ') || 
                            rpad('Codigo da Bandeira:',45,' ') ||  
                            lpad(rc.campo_19,20,' ') || 
                            ': Validacao Fisica: Valor deve ser numerico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;
            if (rc.valida_bin is not null ) then
                l_retorno:= '0500:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -BXX:',20,' ') || 
                            rpad('BIN:',45,' ') ||  
                            lpad(rc.bin,20,' ') || 
                            ': Validacao Fisica: BIN deve ser numerico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;
         end loop;

         for rc in (select distinct m.nro_linha_arquivo,
                             -- codigo adquirente - B11
                             substr(dsc_linha_arquivo,50,8) campo_8,
                             case when crde.cd_crde is null then 0
                                  when substr(dsc_linha_arquivo,50,8) <> l_cod_adquir then 0
                                else 1 end valida_campo_8,    
                             -- banco emissor - B12
                             substr(dsc_linha_arquivo,137,5) campo_17,
                             case when rplc.CD_BNDR is null then 0 else 1 end valida_campo_17,
                             -- bin - B13
                             substr(dsc_linha_arquivo,27,23) campo_7,
                             substr(rtrim(ltrim( substr(dsc_linha_arquivo,27,23))),2,6) bin,
                             case when bin.CD_BNDR is null then 0 
                                  else 1 end valida_campo_7,
                             --MCC do PV - B16                            
                             substr(dsc_linha_arquivo,133,4) campo_16,
                             case when mcc.cd_bndr is null then 0 else 1 end valida_campo_16,
                             m.dsc_linha_arquivo
                      from TBL_OUTPUT_MASSA_DADOS m
                      left join CLC.TBCLCW_EMSR_RPLC rplc on
                           rplc.CD_EMSR = substr(dsc_linha_arquivo,137,5) --campo_17  
                           AND rplc.CD_BNDR = l_cod_bandeira
                      left join CLC.TBCLCW_BIN_RPLC  bin
                      on bin.NU_BIN = substr(rtrim(ltrim( substr(dsc_linha_arquivo,27,23))),2,6)
                         AND bin.CD_BNDR = l_cod_bandeira
                         AND bin.CD_TIPO_PLTF_PGMN = l_cod_tipo_plataforma
                         AND bin.IN_TOKN = 'N' 

                      left join CPR.TBCPRR_MCC_BNDR mcc
                      on mcc.CD_BNDR = l_cod_bandeira 
                          AND mcc.CD_MCC_BNDR = substr(dsc_linha_arquivo,133,4)
                          AND mcc.IN_RGST_ATVO='S' 
                      left join ccr.tbccrr_crde_bndr crde
                      on crde.cd_bndr = l_cod_bandeira
                          and crde.in_crde_atvo = 'S'
                          and crde.cd_crde = substr(dsc_linha_arquivo,50,8)

                      where m.nro_identif_gera_massa = p_numero_geracao_massa
                      and m.dsc_linha_arquivo like '0500%'
                      and not exists (select 1
                                     from tbl_critica_massa_dados x
                                     where x.nro_identif_gera_massa = p_numero_geracao_massa
                                     and x.dsc_linha_arquivo = m.dsc_linha_arquivo)
                 order by nro_linha_arquivo) loop

            PERSISTE_CRITICA(p_numero_geracao_massa,l_i,rc.dsc_linha_arquivo);

            if (rc.valida_campo_8 = 0 ) then
                l_retorno:= '0500:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B11:',20,' ') || 
                            rpad('Codigo do Adquirente:',45,' ') ||  
                            lpad(rc.campo_8,20,' ') || 
                            ': Validacao Logica: Codigo nao cadastrado na Tabela de Adquirentes.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;
            if (rc.valida_campo_17 = 0 ) then
                l_retorno:= '0500:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B12:',20,' ') || 
                            rpad('Banco Emissor:',45,' ') ||  
                            lpad(rc.campo_17,20,' ') || 
                            ': Validacao Logica: Codigo nao cadastrado na Tabela de Emissores.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_7 = 0 ) then
                l_retorno:= '0500:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B13:',20,' ') || 
                            rpad('Numero do Bin:',45,' ') ||  
                            lpad(rc.bin,20,' ') || 
                            ': Validacao Logica: Bin nao cadastrado na tabela de BINs.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_16 = 0 ) then
                l_retorno:= '0500:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B14:',20,' ') || 
                            rpad('MCC do PV:',45,' ') ||  
                            lpad(rc.campo_16,20,' ') || 
                            ': Validacao Logica: MCC nao cadastrado na Tabela de MCCs.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;            
        end loop;
    END;


    PROCEDURE LAYOUT_TE0501_CRITICAS (p_numero_geracao_massa number ) IS
       l_dsc_linha_arquivo varchar2(500);
       l_retorno varchar2(400);
       l_i number := 1;

    BEGIN

         select max(nro_linha_arquivo)
         into l_i
         from tbl_critica_massa_dados
         where nro_identif_gera_massa = p_numero_geracao_massa;

         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------0501--------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');

         for rc in (select distinct nro_linha_arquivo,dsc_linha_arquivo,
                           campo_20, valida_campo_20,
                           campo_10, valida_campo_10,
                           campo_19, valida_campo_19,
                           campo_8, valida_campo_8,
                           campo_14, valida_campo_14,
                           campo_16, valida_campo_16
                    from (select nro_linha_arquivo,dsc_linha_arquivo,
                                 substr(dsc_linha_arquivo,142,14) campo_20, --CPF/CNPJ
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,142,14) )),' +-0123456789.', ' ') valida_campo_20,
                                 substr(dsc_linha_arquivo,81,15) campo_10, --Ponto de Venda
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,81,15) )),' +-0123456789.', ' ') valida_campo_10,
                                 substr(dsc_linha_arquivo,141,1) campo_19, --Tipo de Pessoa
                                 case when substr(dsc_linha_arquivo,141,1) not in ('F','J') then 0 else 1 end valida_campo_19,
                                 substr(dsc_linha_arquivo,74,3) campo_8, --Codigo do Produto
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,74,3) )),' +-0123456789.', ' ') valida_campo_8,
                                 substr(dsc_linha_arquivo,117,12) campo_14, --Valor da Transacao
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,117,12) )),' +-0123456789.', ' ') valida_campo_14,
                                 substr(dsc_linha_arquivo,130,3) campo_16, --Quantidade de Parcelas na Transacao
                                 translate(rtrim(ltrim( substr(dsc_linha_arquivo,130,3) )),' +-0123456789.', ' ') valida_campo_16
                          from TBL_OUTPUT_MASSA_DADOS m
                          where m.dsc_linha_arquivo like '0501%'
                          and m.nro_identif_gera_massa = p_numero_geracao_massa) 
                    where (valida_campo_20 is not null or
                          valida_campo_10 is not null or
                          valida_campo_19 = 0  or
                          valida_campo_8 is not null or
                          valida_campo_14 is not null or
                          valida_campo_16 is not null)) loop

            PERSISTE_CRITICA(p_numero_geracao_massa,l_i,rc.dsc_linha_arquivo);
            if (rc.valida_campo_20 is not null) then
                l_retorno:= '0501:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B01:',20,' ') || 
                            rpad('CNPJ ou CPF:',45,' ') ||  
                            lpad(rc.campo_20,20,' ') || 
                            ': Validacao Fisica: CNPJ ou CPF deve ser numérico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;
            if (rc.valida_campo_10 is not null) then
                l_retorno:= '0501:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B02:',20,' ') || 
                            rpad('Ponto de Venda:',45,' ') ||  
                            lpad(rc.campo_10,20,' ') || 
                            ': Validacao Fisica: Ponto de Venda deve ser numérico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;
            if (rc.valida_campo_19 = 0) then
                l_retorno:= '0501:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B03:',20,' ') || 
                            rpad('Tipo de Pessoa:',45,' ') ||  
                            lpad(rc.campo_19,20,' ') || 
                            ': Validacao Fisica: Tipo de Pessoa deve ser F ou J.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if; 
            if (rc.valida_campo_8 is not null) then
                l_retorno:= '0501:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B06:',20,' ') || 
                            rpad('Codigo do Produto:',45,' ') ||  
                            lpad(rc.campo_8,20,' ') || 
                            ': Validacao Fisica: Codigo do Produto deve ser numerico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if; 
            if (rc.valida_campo_14 is not null) then
                l_retorno:= '0501:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B07:',20,' ') || 
                            rpad('Valor da Transacao',45,' ') ||  
                            lpad(rc.campo_14,20,' ') || 
                            ': Validacao Fisica: Valor da Transacao deve ser numerico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if; 
            if (rc.valida_campo_16 is not null) then
                l_retorno:= '0501:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B08:',20,' ') || 
                            rpad('Quantidade de Parcelas',45,' ') ||  
                            lpad(rc.campo_16,20,' ') || 
                            ': Validacao Fisica: Quantidade de parcelas deve ser numerico.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if; 
         end loop;
         for rc in (select distinct m.nro_linha_arquivo,
                             substr(m.dsc_linha_arquivo,142,14) campo_20, --cnpj ou cpf
                             case when substr(dsc_linha_arquivo,141,1) = 'F' and pf.NU_CPF_CLNT is null then 0 
                                  when substr(dsc_linha_arquivo,141,1) = 'J' and pj.NU_RAIZ_CNPJ_CLNT is null then 0 
                             else 1 end valida_campo_20,

                             substr(dsc_linha_arquivo,81,15) campo_10, --pv
                             case when pv.CD_PDV is null then 0 else 1 end valida_campo_10,

                             substr(dsc_linha_arquivo,141,1) campo_19, --tipo de pessoa
                             case when (substr(dsc_linha_arquivo,141,1) not in ('J','F')) then 0 else 1 end valida_campo_19,
                             case when substr(dsc_linha_arquivo,141,1) = 'F' then substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),4,9) else ' ' end cpf_raiz,
                             case when substr(dsc_linha_arquivo,141,1) = 'F' then substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),13,2) else ' ' end cpf_dv,
                             case when substr(dsc_linha_arquivo,141,1) = 'J' then substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),1,8) else ' ' end cnpj_raiz,
                             case when substr(dsc_linha_arquivo,141,1) = 'J' then substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),9,4) else ' ' end cnpj_filial,
                             case when substr(dsc_linha_arquivo,141,1) = 'J' then substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),13,2) else ' ' end cnpj_dv,


                             substr(dsc_linha_arquivo,74,3) campo_8, --codigo do produto
                             case when prd.CD_PRDT_BNDR is null then 0 else 1 end valida_campo_8,

                             substr(dsc_linha_arquivo,117,12) campo_14, --valor da transacao
                             case when 
                                  substr(dsc_linha_arquivo,74,3) =70 --codigo do produto
                                      and to_number(substr(dsc_linha_arquivo,130,3)) > 1 --qtde de parcelas
                                      and  to_number(substr(dsc_linha_arquivo,117,12)) <> 0 --valor da transacao
                                  then 0
                                  when substr(dsc_linha_arquivo,74,3) =70 
                                      and to_number(substr(dsc_linha_arquivo,130,3)) = 0
                                      and  to_number(substr(dsc_linha_arquivo,117,12)) <> 0
                                  then 0
                                  when substr(dsc_linha_arquivo,74,3)  = 72 
                                       and  to_number(substr(dsc_linha_arquivo,117,12)) = 0
                                  then 0
                             else 1 end valida_campo_14,

                             substr(dsc_linha_arquivo,130,3) campo_16, --quantidade de parcelas da transacao
                             case when 
                                  substr(dsc_linha_arquivo,74,3) =70 and to_number(substr(dsc_linha_arquivo,130,3)) = 1 
                                  then 0
                                  when 
                                  substr(dsc_linha_arquivo,74,3) =72 and to_number(substr(dsc_linha_arquivo,130,3)) < 2
                                  then 0
                             else 1 end valida_campo_16,
                             case when (substr(dsc_linha_arquivo,141,1) = 'F' and
                                       pf_pv.CD_BNDR is null) then 0 else 1 end valida_pf_pv,
                             case when (substr(dsc_linha_arquivo,141,1) = 'J' and
                                       pj_pv.CD_BNDR is null) then 0 else 1 end valida_pj_pv,
                             m.dsc_linha_arquivo
                      from TBL_OUTPUT_MASSA_DADOS m
                      left join CLC.TBCLCW_CRDE_CLNT_PDV_RPLC pf
                           on pf.SG_TPPS_CLNT = substr(dsc_linha_arquivo,141,1)
                           and pf.NU_CPF_CLNT = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),4,9)
                           and pf.NU_DV_CPF_CLNT = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),13,2)
                           and pf.CD_BNDR = l_cod_bandeira
                           AND pf.CD_CRDE = l_cod_adquir
                      left join CLC.TBCLCW_CRDE_CLNT_PDV_RPLC pj
                           on pj.SG_TPPS_CLNT = substr(dsc_linha_arquivo,141,1)
                           and pj.NU_RAIZ_CNPJ_CLNT  = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),1,8)
                           and pj.NU_FILI_CNPJ_CLNT  = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),9,4)
                           and pj.NU_DV_CNPJ_CLNT   = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),13,2)
                           and pj.CD_BNDR = l_cod_bandeira
                           AND pj.CD_CRDE = l_cod_adquir
                      left join CLC.TBCLCW_CRDE_CLNT_PDV_RPLC pv
                           on pv.CD_BNDR = l_cod_bandeira
                           AND pv.CD_CRDE = l_cod_adquir
                           AND pv.CD_PDV = substr(dsc_linha_arquivo,81,15)
                           AND pv.IN_TRNS_FINC = 'S'

                      left join CLC.TBCLCW_CRDE_CLNT_PDV_RPLC pf_pv
                           on pf_pv.SG_TPPS_CLNT = substr(dsc_linha_arquivo,141,1)
                           and pf_pv.NU_CPF_CLNT = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),4,9)
                           and pf_pv.NU_DV_CPF_CLNT = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),13,2)
                           and pf_pv.CD_BNDR = l_cod_bandeira
                           AND pf_pv.CD_CRDE = l_cod_adquir
                           AND pf_pv.CD_PDV = substr(dsc_linha_arquivo,81,15)
                           AND pf_pv.IN_TRNS_FINC = 'S'

                      left join CLC.TBCLCW_CRDE_CLNT_PDV_RPLC pj_pv
                           on pj_pv.SG_TPPS_CLNT = substr(dsc_linha_arquivo,141,1)
                           and pj_pv.NU_RAIZ_CNPJ_CLNT  = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),1,8)
                           and pj_pv.NU_FILI_CNPJ_CLNT  = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),9,4)
                           and pj_pv.NU_DV_CNPJ_CLNT   = substr(rtrim(ltrim(substr(dsc_linha_arquivo,142,14))),13,2)
                           and pj_pv.CD_BNDR = l_cod_bandeira
                           AND pj_pv.CD_CRDE = l_cod_adquir
                           AND pj_pv.CD_PDV = substr(dsc_linha_arquivo,81,15)
                           AND pj_pv.IN_TRNS_FINC = 'S'

                      left join CLC.TBCLCW_PRDT_BNDR_RPLC prd
                           on prd.CD_BNDR = l_cod_bandeira
                           AND prd.CD_PRDT_BNDR = substr(dsc_linha_arquivo,74,3)



                      where m.nro_identif_gera_massa = p_numero_geracao_massa
                      and m.dsc_linha_arquivo like '0501%'
                      and not exists (select 1
                                     from tbl_critica_massa_dados x
                                     where x.nro_identif_gera_massa = p_numero_geracao_massa
                                     and x.dsc_linha_arquivo = m.dsc_linha_arquivo)
                 order by nro_linha_arquivo) loop

            PERSISTE_CRITICA(p_numero_geracao_massa,l_i,rc.dsc_linha_arquivo);

            if (rc.valida_campo_20 = 0 ) then
                l_retorno:= '0501:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B01:',20,' ') || 
                            rpad('CNPJ ou CPF:',45,' ') ||  
                            lpad(rc.campo_20,20,' ') || 
                            ': Validacao Lógica: CPF CNPJ não cadastrado';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_10 = 0 ) then
                l_retorno:= '0501:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B02:',20,' ') || 
                            rpad('Ponto de Venda:',45,' ') ||  
                            lpad(rc.campo_10,20,' ') || 
                            ': Validacao Lógica: Ponto de Venda não cadastrado como Financeiro';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_19 = 0 ) then
                l_retorno:= '0501:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B03:',20,' ') || 
                            rpad('Tipo de Pessoa:',45,' ') ||  
                            lpad(rc.campo_19,20,' ') || 
                            ': Validacao Lógica: Preenchimento Inválido';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_8 = 0 ) then
                l_retorno:= '0501:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B06:',20,' ') || 
                            rpad('Código do Produto:',45,' ') ||  
                            lpad(rc.campo_8,20,' ') || 
                            ': Validacao Lógica: Código não cadastrado na tabela de Produtos';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_14 = 0 ) then
                l_retorno:= '0501:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B07:',20,' ') || 
                            rpad('Valor da Transação:',45,' ') ||  
                            lpad(rc.campo_14,20,' ') || 
                            ': Validacao Logica: Igual a zero se Produto Parcelado Emissor e/ou Credito a Vista. Diferente de zero se Parcelado Loja';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_campo_16 = 0 ) then
                l_retorno:= '0501:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B08:',20,' ') || 
                            rpad('Quantidade de Parcelas da Transação:',45,' ') ||  
                            lpad(rc.campo_16,20,' ') || 
                            ': Validacao Logica: Quantidade de Parcela não confere com Código do Produto ' || rc.campo_8;
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if (rc.valida_pf_pv = 0 or rc.valida_pj_pv = 0) then
                l_retorno:= '0501:' || 
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                            lpad(':Regra 6.8 -B19:',20,' ') || 
                            rpad('CPF/CNPJ x PV:',45,' ') ||  
                            lpad(rc.campo_16,20,' ') || 
                            ': Validacao Logica: CPF/CNPJ não cadastrado para o Ponto de Venda';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

         end loop;
    end;                              
    PROCEDURE LAYOUT_TE0502_CRITICAS (p_numero_geracao_massa number ) IS
       l_dsc_linha_arquivo varchar2(500);
       l_retorno varchar2(400);
       l_i number := 1;

    BEGIN

         select max(nro_linha_arquivo)
         into l_i
         from tbl_critica_massa_dados
         where nro_identif_gera_massa = p_numero_geracao_massa;

         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------0502--------');
         PERSISTE_CRITICA(p_numero_geracao_massa,l_i,'----------------------');

         for rc in (select distinct nro_linha_arquivo,dsc_linha_arquivo,
                           campo_6, valida_campo_6,
                           campo_9, valida_campo_9
                    from (select nro_linha_arquivo,dsc_linha_arquivo,
                                 substr(m.dsc_linha_arquivo,23,3) campo_6, --quantidade de dias para liquidacao
                                 translate(rtrim(ltrim( substr(m.dsc_linha_arquivo,23,3) )),' +-0123456789.', ' ') valida_campo_6,

                                 substr(m.dsc_linha_arquivo,44,5) campo_9, --tipo_operacao
                                 translate(rtrim(ltrim( substr(m.dsc_linha_arquivo,44,5) )),' +-0123456789.', ' ') valida_campo_9

                          from TBL_OUTPUT_MASSA_DADOS m
                          where m.dsc_linha_arquivo like '0502%'
                          and m.nro_identif_gera_massa = p_numero_geracao_massa) 
                    where (valida_campo_6 is not null or
                          (valida_campo_6 is null and to_number(campo_6) = 0) or
                          (valida_campo_9 is not null and rtrim(ltrim(campo_9)) is not null)  or 
                          (valida_campo_9 is null and to_number(rtrim(ltrim(campo_9))) not in (990,991,992,993,994,995))
                          )
                   ) loop

            PERSISTE_CRITICA(p_numero_geracao_massa,l_i,rc.dsc_linha_arquivo);
            if (rc.valida_campo_6 is not null or
                (rc.valida_campo_6 is null and to_number(rc.campo_6) = 0)
               ) then
                l_retorno:= '0502:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B04:',20,' ') || 
                            rpad('Qtde de dias para liquidacao:',45,' ') ||  
                            lpad(rc.campo_6,20,' ') || 
                            ': Validacao Fisica: Numerico e Diferente de zeros.';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;

            if ( (rc.valida_campo_9 is not null and rtrim(ltrim(rc.campo_9)) is not null)  or 
                (rc.valida_campo_9 is null and to_number(rtrim(ltrim(rc.campo_9))) not in (990,991,992,993,994,995))
               ) then
                l_retorno:= '0502:' ||  
                            lpad(to_char(rc.nro_linha_arquivo),4,'0') ||
                            lpad(':Regra 6.8 -B20:',20,' ') || 
                            rpad('Tipo de Operacao:',45,' ') ||  
                            lpad(rc.campo_9,20,' ') || 
                            ': Validacao Fisica: Brancos se Produtos (Credito a vista e/ou Parcelado Emissor). Se parcelado Loja deve ser (990,991,992,993,994,995)';
                PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
            end if;
         end loop;

         for rc in (select distinct m.nro_linha_arquivo,
                           substr(m.dsc_linha_arquivo,44,5) campo_9,
                           case when (to_number(substr(m.dsc_linha_arquivo,44,5)) not in (990,991,992,993,994,995)) then 0
                                else 1 end valida_campo_9,
                             m.dsc_linha_arquivo
                      from TBL_OUTPUT_MASSA_DADOS m                                                                                                     
                      where m.nro_identif_gera_massa = p_numero_geracao_massa
                      and m.dsc_linha_arquivo like '0502%'
                      and not exists (select 1
                                     from tbl_critica_massa_dados x
                                     where x.nro_identif_gera_massa = p_numero_geracao_massa
                                     and x.dsc_linha_arquivo = m.dsc_linha_arquivo)
                 order by nro_linha_arquivo) loop

                if (rc.valida_campo_9 = 0 ) then
                    l_retorno:= '0502:' || 
                                lpad(to_char(rc.nro_linha_arquivo),4,'0') || 
                                lpad(':Regra 6.8 -B20:',20,' ') || 
                                rpad('Tipo de Operacao:',45,' ') ||  
                                lpad(rc.campo_9,20,' ') || 
                                ': Validacao Lógica: Valores Conforme Definicao do Campo / Sequencia de Transacoes deve ocorrer conforme regra definida no campo';
                    PERSISTE_CRITICA(p_numero_geracao_massa,l_i,l_retorno);
                end if;
            end loop;
        end;
        procedure PERSISTE_CRITICA  (p_numero_geracao_massa number,
                                    p_numero_linha_arquivo in out number,
                                    l_linha_arquivo varchar2) 
                  IS
        begin
            p_numero_linha_arquivo := p_numero_linha_arquivo+1;
            insert into tbl_critica_massa_dados (nro_identif_gera_massa, nro_linha_arquivo, dsc_linha_arquivo)
            values 
            (p_numero_geracao_massa,p_numero_linha_arquivo,l_linha_arquivo);
        end;

END PKG_GERA_MASSA;
/
