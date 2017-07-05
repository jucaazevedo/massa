CREATE OR REPLACE PACKAGE PKG_GERA_MASSA_10_20 AS
       --v1 (04/07/2017)

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
                 ); 
                 
       PROCEDURE LAYOUT_SUBTIPO_00_TE1020 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2);

       PROCEDURE LAYOUT_SUBTIPO_02_TE1020 (p_numero_geracao_massa number,
                                      p_nro_linha_arquivo number,
                                      l_retorno out varchar2);

       PROCEDURE GERACAO_MASSA_10_20 (p_numero_geracao_massa varchar2);

       PROCEDURE GERACAO_MASSA_10_20_TE (p_numero_geracao_massa varchar2);

       PROCEDURE LAYOUT_B0 (p_numero_geracao_massa number,
                           l_retorno out varchar2 );

       PROCEDURE LAYOUT_BZ (p_numero_geracao_massa number,
                           l_retorno out varchar2 );
              
END PKG_GERA_MASSA_10_20; 
