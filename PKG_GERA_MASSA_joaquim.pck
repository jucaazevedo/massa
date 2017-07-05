CREATE OR REPLACE PACKAGE PKG_GERA_MASSA_10_20 AS
       --v1 (04/07/2017)



    PROCEDURE GERACAO_MASSA_10_20 (p_numero_geracao_massa varchar2);

                        
    PROCEDURE LAYOUT_OPERACAO (p_numero_geracao_massa number,
                                   p_nro_linha_arquivo number,
                                   l_cod_tipo_operacao varchar2,
                                   l_i in out number,
                                   tipo_layout varchar2);

              

END PKG_GERA_MASSA;
/
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
                 p_vl_destino varchar2,
                 p_vl_origem varchar2,
                 p_dsc_mensagem_texto varchar2,
                 p_qtd_dias_liq_tran varchar2,
                 p_dta_processamento varchar2,
                 p_cod_token_pan varchar2
                 ) IS
                 
                 l_numero_geracao_massa number;
       BEGIN
            if (to_number(p_numero_geracao_massa) = 0) then
               select SQ_INPUT_MASSA_DADOS.nextval into l_numero_geracao_massa
               from dual;
            else 
               l_numero_geracao_massa := to_number(p_numero_geracao_massa);
            end if;

            insert into TBL_INPUT_MASSA_DADOS_10_20
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
                VL_TAXA_EMBARQUE, 
                NRO_REFERENCIA, 
                TIPO_LAYOUT
            )
            values 
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
                p_numero_cartao,  
                p_vl_destino,
                p_vl_origem,
                p_dsc_mensagem_texto,
                p_quantidade_dias_liq_trs,
                p_dta_processamento,
                p_cod_token_pan,
                p_numero_remessa_bz,  
                p_cod_tipo_plataforma,
                p_qtd_parcelas_transacao, 
                p_vl_taxa_embarque,
                p_nro_referencia, 
                p_tipo_layout
            ) ;

            p_numero_geracao_massa := to_char(l_numero_geracao_massa);

            -- Populando variáveis globais
            l_cod_tipo_plataforma := p_cod_tipo_plataforma;
            l_tipo_arquivo := p_dsc_tipo_arquivo;
            l_cod_processadora:= 000;
            commit;
       exception
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

                 l_data_envio date;
                 l_data_juliana_movimento number;
                 valor_soma varchar2(12);
                 l_tipo_layout varchar2(5);
                 l_max_in_tokn char(1);
                 l_min_in_tokn char(1);
       begin

            campo_7 := to_char(sysdate-1,'YYYY') || lpad(to_char(sysdate-1,'MM'),2,'0') || lpad(to_char(sysdate-1,'DD'),2,'0');
            campo_16 := to_char(sysdate-1,'YYYY');

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

       PROCEDURE LAYOUT_SUBTIPO_02_TE1020 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2)IS
                 campo_1 char(2) := lpad('0',2,'0'); --Código da Transação (1)
                 campo_2 char(2) := lpad('0',2,'0'); --Subcódigo da Transação  (3)
                 campo_18 char(12) := rpad(' ',12,' '); --Uso futuro (5)
                 campo_19 char(3) := rpad(' ',3,' '); --Código do país (17)
                 campo_20 char(3) := rpad(' ',3,' '); --Uso futuro (20)
                 campo_21 char(3) := lpad('0',3,'0'); --Quantidade de dias para liquidação financeira (23)
                 campo_22 char(8) := lpad('0',8,'0'); --Data de processamento (26)
                 campo_23 char(3) := rpad(' ',3,' '); --Código de erro (34)
                 campo_24 char(19) := rpad(' ',19,' '); --Token PAN (37)
                 campo_5 char(113) := rpad(' ',113,' '); --Uso futuro (56)

                 l_data_envio date;
                 l_data_juliana_movimento number;
                 valor_soma varchar2(12);
                 l_tipo_layout varchar2(5);
                 l_max_in_tokn char(1);
                 l_min_in_tokn char(1);
       begin
                 l_retorno := campo_1||campo_2||campo_18||campo_19||campo_20||campo_21||campo_22||campo_23||campo_24||campo_5;
       exception
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

            LAYOUT_B0(); // existente
            LAYOUT_SUBTIPO_00_TE1020 (p_numero_geracao_massa number,
                               p_nro_linha_arquivo number,
                               l_retorno out varchar2);

            LAYOUT_SUBTIPO_02_TE1020 (p_numero_geracao_massa number,
                               p_nro_linha_arquivo number,
                               l_retorno out varchar2 );
            LAYOUT_BZ(); //existente

            commit;
       exception
                when others then
                null;
       END;

END PKG_GERA_MASSA;
/
