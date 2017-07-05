CREATE OR REPLACE PACKAGE PKG_GERA_MASSA_10_20 AS
       --v1 (04/07/2017)



    PROCEDURE GERACAO_MASSA_10_20 (p_numero_geracao_massa varchar2);

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

    PROCEDURE LAYOUT_SUBTIPO_02 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2 );

    PROCEDURE INPUT_DADOS_VALIDACAO ( 
              p_numero_geracao_massa in out varchar2,
              p_numero_linha_arquivo varchar2,   
              p_dsc_linha_arquivo varchar2);
              
              

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
               select SQ_INPUT_MASSA_DADOS_10_20.nextval into l_numero_geracao_massa
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

       PROCEDURE GERACAO_MASSA_10_20 (p_numero_geracao_massa varchar2) IS
            l_dsc_linha_arquivo varchar2(400);
            l_numero_geracao_massa number;
            l_i number:=0;

            l_nome_arquivo varchar2(50);
            l_nro_parcela number;
       BEGIN
            l_numero_geracao_massa := to_number(p_numero_geracao_massa);

            LAYOUT_B0();
            LAYOUT_SUBTIPO_00 (p_numero_geracao_massa number,
                               p_nro_linha_arquivo number,
                               l_retorno out varchar2);

            LAYOUT_SUBTIPO_02 (p_numero_geracao_massa number,
                               p_nro_linha_arquivo number,
                               l_retorno out varchar2 );
            LAYOUT_BZ();

            commit;
       exception
                when others then
                null;
       END;

END PKG_GERA_MASSA;
/
