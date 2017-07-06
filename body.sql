CREATE OR REPLACE PACKAGE BODY PKG_GERA_MASSA_10_20 AS
       
       PROCEDURE INPUT_DADOS_10_20 ( 
                 p_numero_geracao_massa in out varchar2,
                 p_numero_linha_arquivo varchar2,   
                 p_cod_tipo_plataforma varchar2,
                 p_dsc_tipo_arquivo varchar2,
                 p_codigo_bandeira_b0 varchar2,
                 p_cod_adquirente_b0 varchar2,
                 p_numero_remessa_b0 varchar2,
                 p_numero_remessa_bz varchar2,
                 p_tipo_layout varchar2,
                 p_cod_destino varchar2,
                 p_cod_origem varchar2,
                 p_cod_motivo_transacao varchar2,
                 p_nro_cartao varchar2,
                 p_nro_referencia varchar2,
                 p_vl_destino varchar2,
                 p_vl_origem varchar2,
                 p_dsc_mensagem_texto varchar2,
                 p_qtd_parcelas_transacao varchar2, 
                 p_qtd_dias_liq_tran varchar2,
                 p_dta_processamento varchar2,
                 p_cod_token_pan varchar2
                 ) IS
                 
                 l_numero_geracao_massa number;
       BEGIN
            IF (to_number(p_numero_geracao_massa) = 0) then
               select SQ_INPUT_MASSA_DADOS.nextval into l_numero_geracao_massa
               from dual;
            ELSE 
               l_numero_geracao_massa := to_number(p_numero_geracao_massa);
            END IF;

            insert into tbl_input_massa_dados_10_20
            (
                NRO_IDENTIF_GERA_MASSA, 
                NRO_LINHA_ARQUIVO, 
                DSC_TIPO_ARQUIVO, 
                NRO_REMESSA_B0, 
                COD_BANDEIRA_B0, 
                COD_ADQUIRENTE_B0, 
                COD_DESTINO,
                COD_ORIGEM,
                COD_MOTIVO_TRANSACAO,
                NRO_CARTAO,
                VL_DESTINO,
                VL_ORIGEM,
                DSC_MENSAGEM_TEXTO,
                QTD_DIAS_LIQ_TRAN,
                DTA_PROCESSAMENTO,
                COD_TOKEN_PAN,
                NRO_REMESSA_BZ, 
                COD_TIPO_PLATAFORMA, 
                NRO_PARCELA, 
                NRO_REFERENCIA, 
                TIPO_LAYOUT
            )
            VALUES 
            (
                l_numero_geracao_massa, 
                to_number(p_numero_linha_arquivo),
                p_dsc_tipo_arquivo,
                p_numero_remessa_b0, 
                p_codigo_bandeira_b0,
                p_cod_adquirente_b0,
                p_cod_destino,
                p_cod_origem,
                p_cod_motivo_transacao,
                p_nro_cartao,  
                p_vl_destino,
                p_vl_origem,
                p_dsc_mensagem_texto,
                p_qtd_dias_liq_tran,
                p_dta_processamento,
                p_cod_token_pan,
                p_numero_remessa_bz,  
                p_cod_tipo_plataforma,
                p_qtd_parcelas_transacao, 
                p_nro_referencia, 
                p_tipo_layout
            );

            p_numero_geracao_massa := to_char(l_numero_geracao_massa);

            commit;
       EXCEPTION
                when others then
                null;
       END;

       PROCEDURE LAYOUT_SUBTIPO_00_TE1020 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2)IS
                 campo_1 char(2) := lpad('0',2,'0'); --Código da Transação (1)
                 campo_2 char(2) := lpad('0',2,'0'); --Subcódigo da Transação  (3)
                 campo_3 char(4) := lpad('0',4,'0'); --Código do destino (5)
                 campo_4 char(4) := lpad('0',4,'0'); --Código da origem (9)
                 campo_5 char(4) := lpad('0',4,'0'); --Motivo da transação (13)
                 campo_6 char(3) := rpad(' ',3,' '); --Código do país (17)
                 campo_7 char(8) := lpad('0',8,'0'); --Data de envio (20)
                 campo_8 char(19) := rpad(' ',19,' '); --Número do cartão (28)
                 campo_9 char(12) := lpad('0',12,'0'); --Valor do destino (47)
                 campo_10 char(3) := lpad('0',3,'0'); --Código da moeda de destino (59)
                 campo_11 char(12) := lpad('0',12,'0'); --Valor de origem (62)
                 campo_12 char(3) := lpad('986',3,'0'); --Código da Moeda de origem (74)
                 campo_13 char(70) := rpad(' ',70,' '); --Mensagem de texto (77)
                 campo_14 char(1) := lpad('0',1,'0'); --Indicador de liquidação (147)
                 campo_15 char(15) := lpad('0',15,'0'); --Indicador da transação original (148)
                 campo_16 char(4) := lpad('0',4,'0'); --Data de processamento (uso futuro) (163)
                 campo_17 char(2) := rpad(' ',2,' '); --Uso futuro

                 l_cod_transacao := '';

       BEGIN
            campo_7 := to_char(sysdate-1,'YYYY') || lpad(to_char(sysdate-1,'MM'),2,'0') || lpad(to_char(sysdate-1,'DD'),2,'0');
            campo_16 := to_char(sysdate-1,'YYYY');

            select substr(tipo_layout,3,2),
                   lpad(nvl(cod_destino,campo_3),4,'0'),
                   lpad(nvl(cod_origem,campo_4),4,'0'),
                   lpad(nvl(cod_motivo_transacao,campo_5),4,'0'),
                   rpad(nvl(nro_cartao,campo_8),19,' '),
                   lpad(nvl(vl_destino,campo_9),12,'0'),
                   lpad(nvl(vl_origem,campo_11),12,'0'),
                   rpad(nvl(dsc_mensagem_texto,campo_13),70,' '),
            into campo_1,
                 campo_3,
                 campo_4,
                 campo_5,
                 campo_8,
                 campo_9,
                 campo_11,
                 campo_13,
            from TBL_INPUT_MASSA_DADOS_10_20
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa 
            and nro_linha_arquivo = p_nro_linha_arquivo;

            l_retorno:= campo_1||campo_2||campo_3||campo_4||campo_5||campo_6||campo_7||campo_8||
                        campo_9||campo_10||campo_11||campo_12||campo_13||campo_14||campo_15||campo_16||campo_17;

            update tbl_input_massa_dados_10_20 a
            set tipo_layout = l_cod_transacao,
                cod_destino = campo_3,
                cod_origem = campo_4,
                cod_motivo_transacao = campo_5,
                nro_cartao = campo_8,
                vl_destino = campo_9,
                vl_origem = campo_11,
                dsc_mensagem_texto = campo_13
            where nro_identif_gera_massa = p_numero_geracao_massa
                        and nro_linha_arquivo = p_nro_linha_arquivo; 
       EXCEPTION
                when others then
                null;
       END;

       PROCEDURE LAYOUT_SUBTIPO_02_TE1020 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2)IS
                 campo_1 char(2) := lpad('0',2,'0'); --Código da Transação (1)
                 campo_2 char(2) := '02'; --Subcódigo da Transação  (3)
                 campo_18 char(12) := rpad(' ',12,' '); --Uso futuro (5)
                 campo_19 char(3) := 'BRA'; --Código do país (17)
                 campo_20 char(3) := rpad(' ',3,' '); --Uso futuro (20)
                 campo_21 char(3) := lpad('0',3,'0'); --Quantidade de dias para liquidação financeira (23)
                 campo_22 char(8) := lpad('0',8,'0'); --Data de processamento (26)
                 campo_23 char(3) := rpad(' ',3,' '); --Código de erro (34)
                 campo_24 char(19) := rpad(' ',19,' '); --Token PAN (37)
                 campo_5 char(113) := rpad(' ',113,' '); --Uso futuro (56)

       BEGIN
            select substr(tipo_layout,3,2),
                   lpad(nvl(qtd_dias_liq_tran,campo_21),3,'0'),
                   rpad(nvl(cod_token_pan,campo_24),19,' ')
            into campo_1,
                 campo_21,
                 campo_24
            from TBL_INPUT_MASSA_DADOS_10_20
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa 
            and nro_linha_arquivo = p_nro_linha_arquivo;

            l_retorno := campo_1||campo_2||campo_18||campo_19||campo_20||campo_21||campo_22||campo_23||campo_24||campo_5;

            update tbl_input_massa_dados_10_20 a
            set qtd_dias_liq_tran = campo_21,
                cod_token_pan = campo_24
            where nro_identif_gera_massa = p_numero_geracao_massa
                        and nro_linha_arquivo = p_nro_linha_arquivo; 
       EXCEPTION
                when others then
                null;
       END;

       PROCEDURE GERACAO_MASSA_10_20 (p_numero_geracao_massa varchar2) IS
            l_dsc_linha_arquivo varchar2(400);
            l_numero_geracao_massa number;
            l_i number:=0;

            l_nome_arquivo varchar2(50);
            l_nro_parcela number;
       BEGIN
            l_numero_geracao_massa := to_number(p_numero_geracao_massa);

            LAYOUT_B0 (l_numero_geracao_massa,l_dsc_linha_arquivo);

            GERACAO_MASSA_10_20_TE(p_numero_geracao_massa);

            LAYOUT_BZ (l_numero_geracao_massa,l_dsc_linha_arquivo);

            commit;
       EXCEPTION
                when others then
                null;
       END;

       PROCEDURE GERACAO_MASSA_10_20_TE (p_numero_geracao_massa varchar2) IS
            l_numero_geracao_massa number;
            l_i number:=0;

            l_nome_arquivo varchar2(50);
            l_nro_parcela number;
       BEGIN
            for rc in (select a.nro_identif_gera_massa,
                              a.nro_linha_arquivo
                      from tbl_input_massa_dados_10_20 a
                      where a.nro_identif_gera_massa = p_numero_geracao_massa
                      order by a.nro_linha_arquivo) loop

                LAYOUT_SUBTIPO_00_TE1020 (p_numero_geracao_massa,
                               rc.nro_linha_arquivo,
                               l_retorno);

                insert into TBL_OUTPUT_MASSA_DADOS (NRO_IDENTIF_GERA_MASSA, NRO_LINHA_ARQUIVO, DSC_LINHA_ARQUIVO)
                values (p_numero_geracao_massa,l_i,l_retorno);
                l_i :=  l_i + 1;

                LAYOUT_SUBTIPO_02_TE1020 (p_numero_geracao_massa,
                               rc.nro_linha_arquivo,
                               l_retorno);
                l_i :=  l_i + 1;

            end loop;
       exception
                when others then
                null;
       END;

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
       BEGIN
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

            l_retorno:= lpad(campo_1 || campo_2 || campo_3 || campo_4 || campo_5 || campo_6 || 
                             campo_7 || campo_8 || campo_9 || campo_10 || campo_11 || campo_12 || 
                             campo_13 || campo_14 || campo_15,168,' ') ;


            update TBL_INPUT_MASSA_DADOS a
            set nro_remessa_b0 = nvl(nro_remessa_b0,campo_4),
                cod_bandeira_b0 = nvl(cod_bandeira_b0,campo_14) ,
                cod_adquirente_b0 = nvl(cod_adquirente_b0,campo_13),
                cod_tipo_plataforma = nvl(cod_tipo_plataforma,'C'),
                DSC_TIPO_ARQUIVO = nvl(DSC_TIPO_ARQUIVO,'ADQUIRENCIAPARABANDEIRA')
            where NRO_IDENTIF_GERA_MASSA = p_numero_geracao_massa;  
       EXCEPTION
                when others then
                null;
       END;

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
       BEGIN
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

       EXCEPTION
                when others then
                null;
       END;       

END PKG_GERA_MASSA_10_20;
