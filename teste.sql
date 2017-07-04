--------------------------------------------------------
--  DDL for Table TBL_INPUT_MASSA_DADOS_10_20
--------------------------------------------------------

  CREATE TABLE "CNTRPCSM"."TBL_INPUT_MASSA_DADOS_10_20" 
   (	"NRO_IDENTIF_GERA_MASSA" NUMBER, 
	"NRO_LINHA_ARQUIVO" NUMBER, 
	"DSC_TIPO_ARQUIVO" VARCHAR2(50 BYTE), 
	"NRO_REMESSA_B0" VARCHAR2(50 BYTE), 
	"COD_BANDEIRA_B0" VARCHAR2(50 BYTE), 
	"COD_ADQUIRENTE_B0" VARCHAR2(50 BYTE), 
        "COD_DESTINO" VARCHAR2(50 BYTE),
        "COD_ORIGEM" VARCHAR2(50 BYTE),
        "COD_MOTIVO_TRANSACAO" VARCHAR2(50 BYTE),
        "NRO_CARTAO" VARCHAR2(50 BYTE),
        "VL_DESTINO" VARCHAR2(50 BYTE),
        "VL_ORIGEM" VARCHAR2(50 BYTE),
        "DSC_MENSAGEM_TEXTO" VARCHAR2(50 BYTE),
	"NRO_REMESSA_BZ" VARCHAR2(50 BYTE), 
	"COD_TIPO_PLATAFORMA" VARCHAR2(50 BYTE), 
	"COD_BANDEIRA_TE05" VARCHAR2(50 BYTE), 
	"NRO_PARCELA" VARCHAR2(50 BYTE), 
	"VL_TAXA_EMBARQUE" VARCHAR2(50 BYTE), 
	"NRO_REFERENCIA" VARCHAR2(50 BYTE), 
	"TIPO_LAYOUT" VARCHAR2(20 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  DDL for Index PK_TBL_INPUT_MASSA_DADOS
--------------------------------------------------------

  CREATE UNIQUE INDEX "CNTRPCSM"."PK_TBL_INPUT_MASSA_DADOS_10_20" ON "CNTRPCSM"."TBL_INPUT_MASSA_DADOS_10_20" ("NRO_IDENTIF_GERA_MASSA_10_20", "NRO_LINHA_ARQUIVO") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;
--------------------------------------------------------
--  Constraints for Table TBL_INPUT_MASSA_DADOS
--------------------------------------------------------

  ALTER TABLE "CNTRPCSM"."TBL_INPUT_MASSA_DADOS_10_20" ADD CONSTRAINT "PK_TBL_INPUT_MASSA_DADOS_10_20" PRIMARY KEY ("NRO_IDENTIF_GERA_MASSA_10_20", "NRO_LINHA_ARQUIVO")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS"  ENABLE;

