

-- VIEWS SL_CIM only

/* <sc-view> SL_CIM_STG_OWNER.STG_SR_RESULTS_HISTORY_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_STG_OWNER"."STG_SR_RESULTS_HISTORY_VW" ("RUN_ID", "PRESENT_IN", "TST_ID", "TST_PART", "RUN_SEQ", "TST_NR", "TST_NM", "SCHEMA_NM", "TABLE_NM", "RESULT", "EXEC_DTM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  select run_id
, present_in
, tst_id
, tst_part
, run_seq
, tst_nr
, tst_nm
, schema_nm
, table_nm
, result
, exec_dtm
from
(
   (
      SELECT  RUNS.RID RUN_ID
      , CAST('Inf' as VARCHAR2(3)) Present_IN
      , 0 tst_id
      , 0 tst_part
      , run_seq_max run_seq
      , 0 tst_nr
      , 'Information' TST_NM
      , 'Check'       SCHEMA_NM
      , 'Differences' TABLE_NM
      , 'Tests id: '||tst_min||' to '||tst_max   result
      , Sysdate       EXEC_DTM
      FROM (select max(run_seq) run_seq_max, min(tst_id) tst_min, max(tst_id) tst_max from stg_sr_results) s
      , (SELECT NVL(MAX(RUN_ID),0) +1 as RID FROM stg_sr_RESULTS_HISTORY) RUNS
   )
   UNION
   ( --test 12345 Netezza rows not in Exadata
      SELECT RUNS.RID RUN_ID
      , CAST('NZa' as VARCHAR2(3)) Present_IN
      , s.TST_ID
      , s.TST_PART
      , s.RUN_SEQ
      , s.TST_NR
      , s.TST_NM
      , s.SCHEMA_NM_NZ SCHEMA_NM
      , s.TABLE_NM
      , s.result
      , s.EXEC_DTM
      FROM stg_sr_nza_results  s,
      (SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , result
         FROM stg_sr_nza_results
         where tst_nr in(1,2,3,4,5)
         MINUS
         SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , result
         from stg_sr_results
         where tst_nr in(1,2,3,4,5)
      )  f,
      (SELECT NVL(MAX(RUN_ID),0) +1 as RID FROM stg_sr_RESULTS_HISTORY)RUNS
      where s.RESULT = f.RESULT
      and  s.TST_ID   = f.tst_id
      and  s.TST_PART = f.TST_PART
      and  s.RUN_SEQ  = f.RUN_SEQ
      and  s.TST_NR   = f.tst_nr
      and  s.tst_nr in (1,2,3,4,5)
   )
   UNION
   ( --test 12345 Exadata rows not in Netezza
      SELECT RUNS.RID RUN_ID
      , CAST('Xa' as VARCHAR2(3)) Present_IN
      , s.TST_ID
      , s.TST_PART
      , s.RUN_SEQ
      , s.TST_NR
      , s.TST_NM
      , s.SCHEMA_NM_NZ SCHEMA_NM
      , s.TABLE_NM
      , s.result
      , s.EXEC_DTM
      FROM stg_sr_results  s,
      (SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , result
         FROM stg_sr_results
         where tst_nr in(1,2,3,4,5)
         MINUS
         SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , result
         from stg_sr_nza_results
         where tst_nr in(1,2,3,4,5)
      )  f,
      (SELECT NVL(MAX(RUN_ID),0) +1 as RID FROM stg_sr_RESULTS_HISTORY)RUNS
      where s.RESULT = f.RESULT
      and  s.TST_ID   = f.tst_id
      and  s.TST_PART = f.TST_PART
      and  s.RUN_SEQ  = f.RUN_SEQ
      and  s.TST_NR   = f.tst_nr
      and  s.tst_nr in (1,2,3,4,5)
   )
   UNION
   ( -- test 6 Netezza rows not in Exadata, NOTE checksum is only 32 char, rest after -> points to ROWID
      SELECT RUNS.RID RUN_ID
      , CAST('NZa' as VARCHAR2(3)) Present_IN
      , s.TST_ID
      , s.TST_PART
      , s.RUN_SEQ
      , s.TST_NR
      , s.TST_NM
      , s.SCHEMA_NM_NZ SCHEMA_NM
      , s.TABLE_NM
      , s.result
      , s.EXEC_DTM
      FROM stg_sr_nza_results  s,
      (
         SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , substr(RESULT,1,33) result
         FROM stg_sr_nza_results
         where tst_nr =6
         MINUS
         SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , substr(RESULT,1,33) result
         from stg_sr_results
         where tst_nr = 6
      ) f
      , (SELECT NVL(MAX(RUN_ID),0) +1 as RID FROM stg_sr_RESULTS_HISTORY) RUNS
      where substr(s.result,1,33) = f.result
      and  s.TST_ID = f.tst_id
      and  s.TST_PART = f.TST_PART
      and  s.RUN_SEQ = f.RUN_SEQ
      and  s.TST_NR = f.tst_nr
      and  s.tst_nr = 6
   )
   UNION
   ( -- test 6 Exadata rows not in Netezza, NOTE checksum is only 32 char, rest after -> points to ROWID
      SELECT RUNS.RID RUN_ID
      , CAST('Xa' as VARCHAR2(3)) Present_IN
      , s.TST_ID
      , s.TST_PART
      , s.RUN_SEQ
      , s.TST_NR
      , s.TST_NM
      , s.SCHEMA_NM_NZ SCHEMA_NM
      , s.TABLE_NM
      , s.result
      , s.EXEC_DTM
      FROM stg_sr_results s,
      (
         SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , substr(RESULT,1,33) result
         FROM stg_sr_results
         where tst_nr =6
         MINUS
         SELECT  TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , substr(RESULT,1,33) result
         from stg_sr_nza_results
         where tst_nr = 6
      ) f
      ,(SELECT NVL(MAX(RUN_ID),0) +1 as RID FROM stg_sr_RESULTS_HISTORY)  RUNS
      where substr(s.result,1,33) = f.result
      and  s.TST_ID = f.tst_id
      and  s.TST_PART = f.TST_PART
      and  s.RUN_SEQ = f.RUN_SEQ
      and  s.TST_NR = f.tst_nr
      and  s.tst_nr = 6
   )
   UNION
   ( -- test 7 and 8 Netezza rows not in Exadata
      SELECT RUNS.RID RUN_ID
      , CAST('NZa' as VARCHAR2(3)) Present_IN
      , s.TST_ID
      , s.TST_PART
      , s.RUN_SEQ
      , s.TST_NR
      , s.TST_NM
      , s.SCHEMA_NM_NZ SCHEMA_NM
      , s.TABLE_NM
      , s.result
      , s.EXEC_DTM
      FROM stg_sr_nza_results  s,
      (SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , result
         FROM stg_sr_nza_results
         where tst_nr in(7,8)
         MINUS
         SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , result
         from stg_sr_results
         where tst_nr in(7,8)
      )  f,
      (SELECT NVL(MAX(RUN_ID),0) +1 as RID FROM stg_sr_RESULTS_HISTORY) RUNS
      where s.result  = f.result
      and  s.TST_ID   = f.tst_id
      and  s.TST_PART = f.TST_PART
      and  s.RUN_SEQ  = f.RUN_SEQ
      and  s.TST_NR   = f.tst_nr
      and  s.tst_nr in (7,8)
   )
   UNION
   ( -- test 7 and 8 Exadata rows not in Netezza
      SELECT RUNS.RID RUN_ID
      , CAST('Xa' as VARCHAR2(3)) Present_IN
      , s.TST_ID
      , s.TST_PART
      , s.RUN_SEQ
      , s.TST_NR
      , s.TST_NM
      , s.SCHEMA_NM_NZ SCHEMA_NM
      , s.TABLE_NM
      , s.result
      , s.EXEC_DTM
      FROM stg_sr_results  s,
      (SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , result
         FROM stg_sr_results
         where tst_nr in(7,8)
         MINUS
         SELECT TST_ID
         , TST_PART
         , RUN_SEQ
         , TST_NR
         , result
         from stg_sr_nza_results
         where tst_nr in(7,8)
      )  f,
      (SELECT NVL(MAX(RUN_ID),0) +1 as RID FROM stg_sr_RESULTS_HISTORY) RUNS
      where s.result  = f.result
      and  s.TST_ID   = f.tst_id
      and  s.TST_PART = f.TST_PART
      and  s.RUN_SEQ  = f.RUN_SEQ
      and  s.TST_NR   = f.tst_nr
      and  s.tst_nr in (7,8)
   )
) QRY
order by tst_id, table_nm, tst_nr,tst_nm;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_AR_ST_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_AR_ST_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_AR_ST_CD", "HA_AR_ST_NM", "HA_EFF_DT", "HA_END_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ta_src_row_id,
    ta_key,
    ha_ar_st_cd,
    ha_ar_st_nm,
    ha_eff_dt,
    ha_end_dt,
    ta_hash_val
	FROM (
		  SELECT
			AR_ST.CL_ID                               	AS TA_SRC_ROW_ID,
			AR_ST.MSTR_SRC_STM_CD || '.'|| AR_ST.CD   	AS TA_KEY,
			row_number() over(partition by AR_ST.CD order by AR_ST.END_DT desc, AR_ST.EFF_DT desc) as RN,
			AR_ST.CD                                	AS HA_AR_ST_CD,
			AR_ST.CD_DESC                              	AS HA_AR_ST_NM,
			AR_ST.EFF_DT                        		AS HA_EFF_DT,
			AR_ST.END_DT                        		AS HA_END_DT,
			CAST(STANDARD_HASH(
				  nvl((AR_ST.MSTR_SRC_STM_CD || '.'|| AR_ST.CD) ,CHR(0) )
				  || ';'
				  || nvl(AR_ST.CD, CHR(0) )
				  || ';'
				  || nvl(AR_ST.CD_DESC, CHR(0) )
				  || ';'
				  || AR_ST.EFF_DT
				  || ';'
				  || AR_ST.END_DT ,'MD5') AS CHAR(32) ) AS  TA_HASH_VAL
		FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_GRDM_CL_GRDM_V__SL_CIM_CUSTOMER_INFO_XU_VW AR_ST
		WHERE AR_ST.VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
		AND AR_ST.GRDM_DIST_NM IN ('AR_LC_ST_TP','CTRP_RLTNP_LCS_TYP')
		)
	WHERE RN = 1;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_CCY_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_CCY_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ta_src_row_id,
    ta_key,
    ha_ccy_cd,
    ha_ccy_nm,
    ha_iso_cd,
    ha_eff_dt,
    ha_end_dt,
    ta_hash_val
	FROM	(
		  SELECT
			CCY.CL_ID                               AS TA_SRC_ROW_ID,
			CCY.MSTR_SRC_STM_CD || '.'|| CCY.CD   	AS TA_KEY,
			row_number() over(partition by CCY.CD order by CCY.END_DT desc, CCY.EFF_DT desc) as RN,
			CCY.CD                                	AS HA_CCY_CD,
			CCY.CD_DESC                             AS HA_CCY_NM,
			CCY.CD                                	AS HA_ISO_CD,
			CCY.EFF_DT                        		AS HA_EFF_DT,
			CCY.END_DT                        		AS HA_END_DT,
			CAST(STANDARD_HASH(
				  nvl((CCY.MSTR_SRC_STM_CD || '.'|| CCY.CD) ,CHR(0) )
				  || ';'
				  || nvl(CCY.CD, CHR(0) )
				  || ';'
				  || nvl(CCY.CD_DESC, CHR(0) )
				  || ';'
				  || CCY.EFF_DT
				  || ';'
				  || CCY.END_DT ,'MD5') AS CHAR(32) ) AS  TA_HASH_VAL
		FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_GRDM_CL_GRDM_V__SL_CIM_CUSTOMER_INFO_XU_VW CCY
		WHERE CCY.VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
		AND CCY.GRDM_DIST_NM = 'CUR'
			)
	WHERE RN = 1;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_CTRY_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_CTRY_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ta_src_row_id,
    ta_key,
    ha_ctry_cd,
    ha_ctry_nm,
    ha_iso_cd,
    ha_eff_dt,
    ha_end_dt,
    ta_hash_val
	FROM (
		  SELECT
			CTRY.CL_ID                               	AS TA_SRC_ROW_ID,
			CTRY.MSTR_SRC_STM_CD || '.'|| CTRY.CD   	AS TA_KEY,
			row_number() over(partition by CTRY.CD order by CTRY.END_DT desc, CTRY.EFF_DT desc) as RN,
			CTRY.CD                                		AS HA_CTRY_CD,
			CTRY.CD_DESC                             	AS HA_CTRY_NM,
			CTRY.CD                                		AS HA_ISO_CD,
			CTRY.EFF_DT                        			AS HA_EFF_DT,
			CTRY.END_DT                        			AS HA_END_DT,
			CAST(STANDARD_HASH(
				  nvl((CTRY.MSTR_SRC_STM_CD || '.'|| CTRY.CD) ,CHR(0) )
				  || ';'
				  || nvl(CTRY.CD, CHR(0) )
				  || ';'
				  || nvl(CTRY.CD_DESC, CHR(0) )
				  || ';'
				  || CTRY.EFF_DT
				  || ';'
				  || CTRY.END_DT ,'MD5') AS CHAR(32) ) AS  TA_HASH_VAL
		FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_GRDM_CL_GRDM_V__SL_CIM_CUSTOMER_INFO_XU_VW CTRY
		WHERE CTRY.VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
		AND CTRY.GRDM_DIST_NM = 'CTRY'
		)
	WHERE RN = 1;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_PD_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_PD_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ta_src_row_id,
    ta_key,
    ha_pd_int_cd,
    ha_pd_cd,
    ha_pd_nm,
    ha_pd_cgy_cd,
    ha_pd_cgy_nm,
    ha_eff_dt,
    ha_end_dt,
    ta_hash_val
	from (
			  SELECT
				PD.CL_ID                          AS TA_SRC_ROW_ID,
				PD.MSTR_SRC_STM_CD||'.'|| PD.SRC_CD  AS TA_KEY,
				row_number() over(partition by PD.SRC_CD order by PD.END_DT desc, PD.EFF_DT desc) as RN,
				PD.SRC_CD                         AS HA_PD_INT_CD,
				PD.CD                             AS HA_PD_CD,
				PD.CD_DESC                        AS HA_PD_NM,
				PD.CTG                            AS HA_PD_CGY_CD,
				PD.CTG_DSC                        AS HA_PD_CGY_NM,
				PD.EFF_DT                         AS HA_EFF_DT,
				PD.END_DT                         AS HA_END_DT,
				CAST(STANDARD_HASH(
					  nvl((PD.MSTR_SRC_STM_CD || '.'|| PD.SRC_CD) ,CHR(0) )
					  || ';'
					  || nvl(PD.SRC_CD, CHR(0) )
					  || ';'
					  || nvl(PD.CD, CHR(0) )
					  || ';'
					  || nvl(PD.CD_DESC, CHR(0) )
					  || ';'
					  || nvl(PD.CTG, CHR(0) )
					  || ';'
					  || nvl(PD.CTG_DSC, CHR(0) )
					  || ';'
					  || PD.EFF_DT
					  || ';'
					  || PD.END_DT ,'MD5') AS CHAR(32) ) AS  TA_HASH_VAL
			FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_GRDM_CL_GRDM_V__SL_CIM_CUSTOMER_INFO_XU_VW PD
			WHERE PD.VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
			AND PD.GRDM_DIST_NM IN ('PD_TYP','MAND_TYP','MEANS_TYP') AND PD.SRC_STM='MDM'
		)
	WHERE RN = 1;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_SBI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_SBI_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_SBI_CD", "HA_SBI_NM", "HA_CL_TP", "HA_EFF_DT", "HA_END_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ta_src_row_id,
    ta_key,
    ha_sbi_cd,
    ha_sbi_nm,
    ha_cl_tp,
    ha_eff_dt,
    ha_end_dt,
    ta_hash_val
	FROM (
		  SELECT
			SBI.CL_ID                               	AS TA_SRC_ROW_ID,
			SBI.MSTR_SRC_STM_CD||'.'||SBI.GRDM_DIST_NM||'.'|| SBI.CD  AS TA_KEY,
			row_number() over(partition by SBI.GRDM_DIST_NM||'.'|| SBI.CD order by SBI.END_DT desc, SBI.EFF_DT desc) as RN,
			SBI.CD                                		AS HA_SBI_CD,
			SBI.CD_DESC                             	AS HA_SBI_NM,
			SBI.GRDM_DIST_NM                            AS HA_CL_TP,
			SBI.EFF_DT                        			AS HA_EFF_DT,
			SBI.END_DT                        			AS HA_END_DT,
			CAST(STANDARD_HASH(
				  nvl((SBI.MSTR_SRC_STM_CD||'.'||SBI.GRDM_DIST_NM||'.'|| SBI.CD) ,CHR(0) )
				  || ';'
				  || nvl(SBI.CD, CHR(0) )
				  || ';'
				  || nvl(SBI.CD_DESC, CHR(0) )
				  || ';'
				  || nvl(SBI.GRDM_DIST_NM, CHR(0) )
				  || ';'
				  || SBI.EFF_DT
				  || ';'
				  || SBI.END_DT ,'MD5') AS CHAR(32) ) AS  TA_HASH_VAL
		FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_GRDM_CL_GRDM_V__SL_CIM_CUSTOMER_INFO_XU_VW SBI
		WHERE SBI.VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
		AND SBI.GRDM_DIST_NM IN ('IDY_CL_SBI','IDY_CL_NACE_BE')
		)
	WHERE RN = 1;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_SEG_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_SEG_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_LVL", "HA_GRP_TP", "HA_GRP_DSC", "HA_EFF_DT", "HA_END_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ta_src_row_id,
    ta_key,
    ha_seg_cd,
    ha_seg_nm,
    ha_seg_cgy_cd,
    ha_seg_cgy_nm,
    ha_lvl,
    ha_grp_tp,
    ha_grp_dsc,
    ha_eff_dt,
    ha_end_dt,
    ta_hash_val
	FROM	(
		  SELECT
			SEG.CL_ID                               	AS TA_SRC_ROW_ID,
			SEG.MSTR_SRC_STM_CD||'.'||SEG.CD||'.'||SEG.CTG   	AS TA_KEY,
			row_number() over(partition by SEG.CD||'.'||SEG.CTG order by SEG.END_DT desc, SEG.EFF_DT desc) as RN,
			SEG.CD                                		AS HA_SEG_CD,
			SEG.CD_DESC                             	AS HA_SEG_NM,
			SEG.PRNT                            		AS HA_SEG_CGY_CD,
			SEG.PRNT_DSC                                AS HA_SEG_CGY_NM,
			SEG.LVL                             		AS HA_LVL,
			SEG.CTG                            			AS HA_GRP_TP,
			SEG.CTG_DSC                            		AS HA_GRP_DSC,
			SEG.EFF_DT                        			AS HA_EFF_DT,
			SEG.END_DT                        			AS HA_END_DT,
			CAST(STANDARD_HASH(
				  nvl((SEG.MSTR_SRC_STM_CD||'.'||SEG.CD||'.'||SEG.CTG) ,CHR(0) )
				  || ';'
				  || nvl(SEG.CD, CHR(0) )
				  || ';'
				  || nvl(SEG.CD_DESC, CHR(0) )
				  || ';'
				  || nvl(SEG.PRNT, CHR(0) )
				  || ';'
				  || nvl(SEG.PRNT_DSC, CHR(0) )
				  || ';'
				  || nvl(SEG.LVL, CHR(0) )
				  || ';'
				  || nvl(SEG.CTG, CHR(0) )
				  || ';'
				  || nvl(SEG.CTG_DSC, CHR(0) )
				  || ';'
				  || SEG.EFF_DT
				  || ';'
				  || SEG.END_DT ,'MD5') AS CHAR(32) ) AS  TA_HASH_VAL
		FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_GRDM_CL_GRDM_V__SL_CIM_CUSTOMER_INFO_XU_VW SEG
		WHERE SEG.VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
		AND SEG.GRDM_DIST_NM IN ('SVC_SEGM_NL','SVC_SEGM_BE','PRC_GRP_PRV_BE','PRC_GRP_PRO_BE')
		)
	WHERE RN = 1;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_B2_AR_X_AR_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_B2_AR_X_AR_VW" ("HA_AR_1_UUID", "HA_AR_2_UUID", "HA_LE_CD", "HA_AR_1_TYPE", "HA_AR_1_DTL_TYPE", "HA_AR_2_TYPE", "HA_AR_2_DTL_TYPE", "HA_TYPE", "HA_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT", "TA_KEY", "HA_DEL_IND", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT AR_X_AR.FROMAGREEMENTUUID as HA_AR_1_UUID,
               AR_X_AR.TOAGREEMENTUUID as HA_AR_2_UUID,
    SubStr(AR_X_AR.ACCESSTOKEN,1,6) As HA_LE_CD,
    AR_X_AR.FROMAGREEMENTTYPE as HA_AR_1_TYPE,
    AR_X_AR.FROMAGREEMENTDETAILTYPE as HA_AR_1_DTL_TYPE,
    AR_X_AR.TOAGREEMENTTYPE as HA_AR_2_TYPE,
    AR_X_AR.TOAGREEMENTDETAILTYPE as HA_AR_2_DTL_TYPE,
    AR_X_AR.TYPE as HA_TYPE,
    AR_X_AR.STATUSTYPE as HA_STATUS_TYPE,
    AR_X_AR.EFFECTIVEDATE as HA_EFF_DT,
    AR_X_AR.ENDDATE as HA_END_DT,
               (AR_X_AR.MSTR_SRC_STM_CD || '.' || AR_X_AR.FROMAGREEMENTUUID || '.' || AR_X_AR.TYPE || '.' || AR_X_AR.TOAGREEMENTUUID) AS TA_KEY,
               CASE WHEN AR_X_AR.DEL_IN_SRC_STM_F =1 then 'Y' ELSE 'N' END as HA_DEL_IND,
               CAST(standard_hash(
                  NVL(AR_X_AR.FROMAGREEMENTUUID,CHR(0))
               ||';'
               || NVL(AR_X_AR."TOAGREEMENTUUID",CHR(0))
               ||';'
               || NVL(SubStr(AR_X_AR.ACCESSTOKEN,1,6),CHR(0))
               ||';'
               || NVL(AR_X_AR."FROMAGREEMENTTYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."FROMAGREEMENTDETAILTYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."TOAGREEMENTTYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."TOAGREEMENTDETAILTYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."TYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."STATUSTYPE",CHR(0))
               ||';'
               || TO_CHAR(AR_X_AR.EFFECTIVEDATE, 'DD-MON-YYYY HH24:MI:SSxFF')
               ||';'
               || TO_CHAR(AR_X_AR.ENDDATE, 'DD-MON-YYYY HH24:MI:SSxFF')
               ||';'
               || CASE WHEN AR_X_AR.DEL_IN_SRC_STM_F =1 then 'Y' ELSE 'N' END ,'MD5') AS CHAR(32)) TA_HASH_VAL
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_X_AR_R__SL_CIM_CUSTOMER_INFO_XU_VW AR_X_AR
INNER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_V__SL_CIM_CUSTOMER_INFO_XU_VW AR_TO
ON AR_X_AR.TOAGREEMENTUUID = AR_TO.IDENTIFIER
AND AR_X_AR.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_TO.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_X_AR.ACCESSTOKEN IN ('ING_BE','ING_BE_SHARED') AND AR_TO.ACCESSTOKEN IN ('ING_BE','ING_BE_SHARED')
INNER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_V__SL_CIM_CUSTOMER_INFO_XU_VW AR_FROM
ON AR_X_AR.FROMAGREEMENTUUID = AR_FROM.IDENTIFIER
AND AR_X_AR.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_FROM.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_X_AR.ACCESSTOKEN IN ('ING_BE','ING_BE_SHARED') AND AR_FROM.ACCESSTOKEN IN ('ING_BE','ING_BE_SHARED')
UNION ALL
SELECT AR_X_AR.FROMAGREEMENTUUID as HA_AR_1_UUID,
               AR_X_AR.TOAGREEMENTUUID as HA_AR_2_UUID,
    SubStr(AR_X_AR.ACCESSTOKEN,1,6) As HA_LE_CD,
    AR_X_AR.FROMAGREEMENTTYPE as HA_AR_1_TYPE,
    AR_X_AR.FROMAGREEMENTDETAILTYPE as HA_AR_1_DTL_TYPE,
    AR_X_AR.TOAGREEMENTTYPE as HA_AR_2_TYPE,
    AR_X_AR.TOAGREEMENTDETAILTYPE as HA_AR_2_DTL_TYPE,
    AR_X_AR.TYPE as HA_TYPE,
    AR_X_AR.STATUSTYPE as HA_STATUS_TYPE,
    AR_X_AR.EFFECTIVEDATE as HA_EFF_DT,
    AR_X_AR.ENDDATE as HA_END_DT,
               (AR_X_AR.MSTR_SRC_STM_CD || '.' || AR_X_AR.FROMAGREEMENTUUID || '.' || AR_X_AR.TYPE || '.' || AR_X_AR.TOAGREEMENTUUID) AS TA_KEY,
               CASE WHEN AR_X_AR.DEL_IN_SRC_STM_F =1 then 'Y' ELSE 'N' END as HA_DEL_IND,
               CAST(standard_hash(
                  NVL(AR_X_AR.FROMAGREEMENTUUID,CHR(0))
               ||';'
               || NVL(AR_X_AR."TOAGREEMENTUUID",CHR(0))
               ||';'
               || NVL(SubStr(AR_X_AR.ACCESSTOKEN,1,6),CHR(0))
               ||';'
               || NVL(AR_X_AR."FROMAGREEMENTTYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."FROMAGREEMENTDETAILTYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."TOAGREEMENTTYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."TOAGREEMENTDETAILTYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."TYPE",CHR(0))
               ||';'
               || NVL(AR_X_AR."STATUSTYPE",CHR(0))
               ||';'
               || TO_CHAR(AR_X_AR.EFFECTIVEDATE, 'DD-MON-YYYY HH24:MI:SSxFF')
               ||';'
               || TO_CHAR(AR_X_AR.ENDDATE, 'DD-MON-YYYY HH24:MI:SSxFF')
               ||';'
               || CASE WHEN AR_X_AR.DEL_IN_SRC_STM_F =1 then 'Y' ELSE 'N' END ,'MD5') AS CHAR(32)) TA_HASH_VAL
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_X_AR_R__SL_CIM_CUSTOMER_INFO_XU_VW AR_X_AR
INNER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_V__SL_CIM_CUSTOMER_INFO_XU_VW AR_TO
ON AR_X_AR.TOAGREEMENTUUID = AR_TO.IDENTIFIER
AND AR_X_AR.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_TO.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_X_AR.ACCESSTOKEN IN ('ING_NL','ING_NL_SHARED') AND AR_TO.ACCESSTOKEN IN ('ING_NL','ING_NL_SHARED')
INNER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_V__SL_CIM_CUSTOMER_INFO_XU_VW AR_FROM
ON AR_X_AR.FROMAGREEMENTUUID = AR_FROM.IDENTIFIER
AND AR_X_AR.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_FROM.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_X_AR.ACCESSTOKEN IN ('ING_NL','ING_NL_SHARED') AND AR_FROM.ACCESSTOKEN IN ('ING_NL','ING_NL_SHARED')
;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_AR_NOHASH_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_AR_NOHASH_VW" ("TA_KEY", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_UUID", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_ID_TP", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_AR_CD", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
			CASE WHEN ARR.IDENTIFIER IS NOT NULL THEN 'MDM.'||ARR.IDENTIFIER
                ELSE NULL
            END  as TA_KEY
      , ARR.EFFECTIVEDATE AS HA_OPN_DT
      , ARR.ENDDATE AS HA_END_DT
      , CASE WHEN ARR.ENDDATE IS NOT NULL AND ARR.ENDDATE < SYSDATE THEN 'COMPLD_AR' ELSE ARR.LIFECYCLESTATUSTYPE END AS HA_ST_CD
      , ARR.DENOMINATIONCURRENCY AS HA_CCY_CD
      , ARR.TYPE AS HA_PD_CD
      , SubStr(ARR.ACCESSTOKEN,1,6) As HA_LE_CD
      , ARR.IDENTIFIER AS HA_AR_UUID
      , INH.HA_INH_IND AS HA_INH_IND
	  , ARR.HA_JIVE_IND AS HA_JIVE_IND
	  , CASE WHEN ARR.DEL_IN_SRC_STM_F =1 then 'Y' ELSE 'N' END as HA_DEL_IND
	  , ARR.INGENTITY  as HA_INGENTITY_CD
	  , ARR.NICKNAME as HA_NCKNM
	  , OV.TYPE as HA_AR_ID_TP
	  , CASE WHEN  ARR.TYPE IN ('BE_CRN_AC','BE_ING_BNKR_AC','BE_ING_BSC_BNKG_SVC','BE_ING_CASE_AC','BE_ING_CASH_AC','BE_ING_CONSIGN_AC','BE_ING_CORP_AC','BE_ING_GOTO_18','BE_ING_GREEN_AC','BE_ING_IVSM_AC_PROF','BE_ING_LION_AC','BE_ING_MED_AC','BE_ING_MGN_CRN_AC','BE_ING_MGN_CRN_AC_IVSM_PROF','BE_ING_MGN_CRN_AC_PROF','BE_ING_MISC_CRN_AC','BE_ING_NOTARY_AC','BE_ING_NTRY_SUB_AC','BE_ING_ORDN_AC','BE_ING_PROF_CRN_AC','BE_ING_TP_NTRY_AC','CRN_AC','NL_BTLRKG','NL_EN_OF_BTLRKG','NL_G_REK','NL_IN_UIT_STROOMRKG','NL_IN_UIT_STROOMRKG_VV','NL_JONGRKG','NL_KINDRRKG','NL_SLUITRKG','NL_STUDNTNRKG','NL_TRANSITO_REK','NL_TRANSITO_REK_VV','NL_VRMDE_VALTRK','NL_ZAK_RKG_1') THEN ARR.VALUE
             WHEN  ARR.TYPE  IN ('NL_OVRST_SRV_GNDE_RK','NL_SLDLN_INFO', 'NL_SLDLN_RSCOVL', 'NL_ROODSTND_STDNT', 'NL_GIROKW_KRED', 'NL_DEBETKENMERK', 'NL_CRKENMERK', 'NL_SLDLN_RSCOARM', 'NL_OVRST_SRV_GNDE_RKG', 'NL_OVRST_SERV_KOMND_RKG') OR ARR.TYPE in ('NL_RENTPUNTN', 'NL_CONTINU_LMT_1') THEN PROD_IDN_CMRCL.VALUE
             WHEN  ARR.TYPE in ('BE_MRTG_LOAN','NL_ING_HYPOKOFFERTE','NL_ING_HYPO_GLDLING') THEN LTRIM( SUBSTR(OV.ARRNR, 1,9), '0' )
             WHEN  ARR.TYPE in ('NL_CRCARD_HOOFDOVK', 'NL_CRCARD_SUBOVK') THEN SUBSTR(OV.ARRNR,2,12)
             WHEN  ARR.TYPE in ('BE_ING_GEN_CR_CTR', 'NL_VAR_DRLP_KRED_3', 'BE_OPTICASH', 'BE_ING_TRM_TXN_FOR_CUR', 'NL_VAR_DRLP_KRED_1', 'NL_DRLP_KRED_6', 'BE_ING_IVSM_CR_NO_SPF', 'NL_SANERINGSKRED', 'NL_GRNE_AUTOLNG', 'BE_TAX_PREPYMT_RVL', 'BE_ING_IVSM_CR_LNG_TERM_FIX', 'BE_ING_SUN_CR', 'NL_DRLP_KRED_4', 'NL_CONTINU_LMT_2', 'BE_ING_INSTALLMENT_LOAN', 'BE_TAX_PREPYMT_NON_RVL_W_AND_WO_DEP', 'NL_VAR_DRLP_KRED_2', 'BE_BSN_LINE', 'NL_STUDENTENKRED', 'NL_VRDL_KRED', 'BE_BSN_LINE_START', 'NL_PERS_LNG_3', 'BE_ING_BRD_ADV_AND_STRAIGHT_LOAN', 'BE_ING_IVSM_CR_BPO', 'NL_DRLP_KRED_3', 'NL_VAR_VRDL_KRED', 'NL_DRLP_KRED_1', 'NL_RENDEMENTKRED', 'NL_DRLP_KRED_5', 'NL_DRLP_KRED_2', 'NL_PERS_LNG_1', 'NL_SPRKRED') THEN LTRIM( SUBSTR(OV.ARRNR, 2,9), '0' )
             WHEN  ARR.TYPE = 'NL_KLUIS' THEN LTRIM(OV.ARRNR, '0')
             WHEN  ARR.TYPE in ('NL_ZAK_SPRRKG', 'NL_ZAK_BONUS_SPRRKG', 'NL_LIQ_MGT_AC', 'NL_PRIV_BNK_SPRRKG_1', 'NL_BONUSRENTERKG', 'NL_TOPRKG', 'NL_COMFORTSPRRKG', 'NL_PRFTRKG', 'NL_VERMGN_SPRRKG', 'NL_ZAK_KW_SPRRKG') THEN AR_BBAN_IBAN.BBAN
             WHEN  ARR.TYPE in ('NL_GROEI_GROTER_RKG', 'NL_BANKSPRRKG_1', 'NL_BANKSPRRKG_2', 'NL_SPRDEP', 'NL_GROEN_SPRDEP', 'NL_ZAK_DEP', 'NL_PENSIOENSPRRKG', 'NL_SPRLOONRKG_1', 'NL_SPRLOONRKG_2', 'NL_LEVENSLPRGLNG', 'NL_ORANJE_SPRRKG', 'NL_SPRRKG_UNICEF', 'NL_UAP_SPRRKG', 'NL_SNELTREINSPR_RKG', 'NL_VRMDE_VALUTA_DEP', 'NL_SALDO_RKG') THEN SUBSTR(PROD_IDN_CMRCL.VALUE,2,9)
             WHEN  ARR.TYPE in ('NL_RENTECERTIFICT', 'NL_BELEGGINGSRKG', 'NL_SPRBANKBK') THEN  LTRIM ( SUBSTR(OV.ARRNR, 2, LENGTH(OV.ARRNR) - 1) ,'0')
             WHEN  ARR.TYPE in ('VV_RNTSTLSL', 'NL_RAAMOVK') THEN LTRIM (OV.ARRNR, '0')
             WHEN  ARR.TYPE in ('NL_BASISPAKKT', 'NL_ORANJEPAKKT', 'NL_ROYLPAKKT', 'NL_BETLPAKKT') THEN  SUBSTR(OV.ARRNR, 1, LENGTH(OV.ARRNR) - 9)
            WHEN  ARR.TYPE in ('BE_ING_OD_FCY','NL_ACCRIEF_FCLT','NL_ALLOWANCE_FCLT','NL_BANKGNT_FCLT','NL_ING_STNDBY_RLLOVE','NL_ING_STNDBY_RLLOVER','NL_OBLIGO_LMT','NL_ONGCOMMTTRD_RC_KR','NL_ONGCOMMTTRD_RC_KRED','NL_OVERWRDEKRED_1','NL_RKG_COURNT_KRED_1','NL_RKG_COURNT_KRED_10','NL_RKG_COURNT_KRED_13','NL_RKG_COURNT_KRED_14','NL_RKG_COURNT_KRED_15','NL_RKG_COURNT_KRED_16','NL_RKG_COURNT_KRED_4','NL_RKG_COURNT_KRED_5','NL_RKG_COURNT_KRED_6','NL_RKG_COURNT_KRED_8','NL_RKG_COURNT_KRED_9','NL_TEMP_LMT','NL_WERKKAPITL_KRED_1') THEN LTRIM ( SUBSTR(PROD_IDN_CMRCL.VALUE,9,10) , '0')
            WHEN  ARR.TYPE IN ('NL_BRGSTLLNGSKRED_3','NL_BRGSTLLNGSKRED_LB','NL_ANNUITTENLNG','NL_BORGSTELLINGSKRED','NL_ROLLOVR_LNG_2','NL_GAR_ONDRNEMGSFNC_1','NL_BRGSTLLNGSKRED_13','NL_MIDDELLANG_KRED','NL_RENTVSTLNG','NL_GAR_ONDRNEMGSFNC','NL_BRGSTLLNGSKRED_14','NL_BRGSTLLNGSKRED_16','NL_GAR_ONDRNEMGSFNC_GZ','NL_EURIBOR_OPTIML_LN','NL_ROLLOVER_TRKGKING','NL_RENTVSTLNG_C','NL_GROENLENING_1','NL_ING_GROEIFACLIT','NL_BRGSTLLNGSKRED_10','NL_BRGSTLLNGSKRED_17','NL_BRGSTLLNGSKRED_12','NL_BRGSTLLNGSKRED_15','NL_EURIBOR_OPTIML_LNG','NL_FLEXIBILITEIT_LNG','NL_BRGSTLLNGSKRED_11','NL_KASGELDLNG','NL_BEDRIJFSHYPOTHEEK_LINEAIR','NL_BORGSTELLINGSKRED_1','NL_EUROFLEXLNG') THEN LTRIM ( PROD_IDN_CMRCL.VALUE , '0')
             ELSE OV.ARRNR
             END AS HA_AR_NBR
        ,CASE WHEN ARR.TYPE in ('NL_TOPRKG','NL_COMFORTSPRRKG','NL_VERMGN_SPRRKG','NL_BONUSRENTERKG','NL_PRIV_BNK_SPRRKG_1','NL_ZAK_KW_SPRRKG','NL_PRFTRKG','NL_ZAK_BONUS_SPRRKG','NL_ZAK_SPRRKG','NL_LIQ_MGT_AC') THEN SUBSTR(PROD_IDN_CMRCL.VALUE, 1,18)
              WHEN ARR.TYPE in ('NL_RENTECERTIFICT','NL_BELEGGINGSRKG','NL_SPRBANKBK') THEN OV.ARRNR
              WHEN ARR.TYPE in ('NL_BASISPAKKT', 'NL_ORANJEPAKKT', 'NL_ROYLPAKKT', 'NL_BETLPAKKT') THEN AR_BBAN_IBAN.BBAN
              ELSE PROD_IDN_CMRCL.VALUE
          END                     AS HA_CMRCL_NBR
      ,  CASE WHEN  ARR.VALUE IS NOT NULL THEN ARR.VALUE
              WHEN  ARR.TYPE in ('BE_ING_OD_FCY','NL_ACCRIEF_FCLT','NL_ALLOWANCE_FCLT','NL_BANKGNT_FCLT','NL_ING_STNDBY_RLLOVE','NL_ING_STNDBY_RLLOVER','NL_OBLIGO_LMT','NL_ONGCOMMTTRD_RC_KR','NL_ONGCOMMTTRD_RC_KRED','NL_OVERWRDEKRED_1','NL_RKG_COURNT_KRED_1','NL_RKG_COURNT_KRED_10','NL_RKG_COURNT_KRED_13','NL_RKG_COURNT_KRED_14','NL_RKG_COURNT_KRED_15','NL_RKG_COURNT_KRED_16','NL_RKG_COURNT_KRED_4','NL_RKG_COURNT_KRED_5','NL_RKG_COURNT_KRED_6','NL_RKG_COURNT_KRED_8','NL_RKG_COURNT_KRED_9','NL_TEMP_LMT','NL_WERKKAPITL_KRED_1') THEN LTRIM ( SUBSTR(PROD_IDN_CMRCL.VALUE,9,10) , '0')
              WHEN  AR_BBAN_IBAN.BBAN IS NOT NULL THEN AR_BBAN_IBAN.BBAN
              WHEN ARR.TYPE IN ('NL_OVRST_SRV_GNDE_RK','NL_SLDLN_INFO', 'NL_SLDLN_RSCOVL', 'NL_ROODSTND_STDNT', 'NL_GIROKW_KRED', 'NL_DEBETKENMERK', 'NL_CRKENMERK', 'NL_SLDLN_RSCOARM', 'NL_OVRST_SRV_GNDE_RKG', 'NL_OVRST_SERV_KOMND_RKG')  THEN PROD_IDN_CMRCL.VALUE
              WHEN ARR.TYPE  in ('NL_RENTPUNTN', 'NL_CONTINU_LMT_1')     THEN PROD_IDN_CMRCL.VALUE
              ELSE NULL
              END               AS HA_BBAN_NBR
      ,  CASE WHEN PROD_IDN_IBAN.VALUE IS NOT NULL THEN PROD_IDN_IBAN.VALUE
              WHEN  ARR.TYPE in ('BE_ING_OD_FCY','NL_ACCRIEF_FCLT','NL_ALLOWANCE_FCLT','NL_BANKGNT_FCLT','NL_ING_STNDBY_RLLOVE','NL_ING_STNDBY_RLLOVER','NL_OBLIGO_LMT','NL_ONGCOMMTTRD_RC_KR','NL_ONGCOMMTTRD_RC_KRED','NL_OVERWRDEKRED_1','NL_RKG_COURNT_KRED_1','NL_RKG_COURNT_KRED_10','NL_RKG_COURNT_KRED_13','NL_RKG_COURNT_KRED_14','NL_RKG_COURNT_KRED_15','NL_RKG_COURNT_KRED_16','NL_RKG_COURNT_KRED_4','NL_RKG_COURNT_KRED_5','NL_RKG_COURNT_KRED_6','NL_RKG_COURNT_KRED_8','NL_RKG_COURNT_KRED_9','NL_TEMP_LMT','NL_WERKKAPITL_KRED_1') THEN PROD_IDN_CMRCL.VALUE              WHEN AR_BBAN_IBAN.IBAN is NOT NULL THEN AR_BBAN_IBAN.IBAN
              ELSE NULL
              END               AS HA_IBAN_NBR
	   ,  ARR.AR_CD as HA_AR_CD
	   , MAND_IDN_AMA.VALUE AS HA_AMA_ID
	   , MAND_IDN_GRP.VALUE AS HA_BE_GRP_ID
	   , OV.ARRNR AS HA_AR_IDNT
FROM
(    SELECT AGR.AR_ID, AGR.IDENTIFIER, AGR.ACCESSTOKEN, AGR.LIFECYCLESTATUSTYPE, AGR.TYPE, AGR.NAME, AGR.DEL_IN_SRC_STM_F, AGR.EFFECTIVEDATE, AGR.ENDDATE, AGR.NICKNAME,
AGR.INGENTITY, AGR.AR_CD, AGR.DENOMINATIONCURRENCY,  BBAN_TEMP.VALUE, --PROD.HA_PD_CGY_CD,
ROW_NUMBER() OVER (PARTITION BY BBAN_TEMP.VALUE ORDER BY NVL(AGR.ENDDATE, TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) DESC, AGR.DEL_IN_SRC_STM_F ASC)
        ROWNUM1
    , CASE WHEN NAME LIKE '%JIVE%' and NAME LIKE '%ING%'  THEN 'Y'
        WHEN  UPPER(NAME) LIKE '%PJIVE%' THEN 'Y'
        WHEN  UPPER(NAME) LIKE '%ZJIVE%' THEN 'Y'
           WHEN AGR.TYPE in ('NL_KINDRRKG','NL_EN_OF_BTLRKG','NL_BTLRKG','NL_JONGRKG','NL_STUDNTNRKG')  THEN 'N'
    ELSE NULL
         END as HA_JIVE_IND
    FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_V__SL_CIM_CUSTOMER_INFO_XU_VW AGR
    --LEFT OUTER JOIN SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD PROD ON PROD.HA_PD_CD = AGR.TYPE
    LEFT OUTER JOIN (
		SELECT AR_ID, VALUE  FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_PRDCT_AGRMNT_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW
		WHERE VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND TYPE = 'BBAN' ) BBAN_TEMP
    ON AGR.AR_ID = BBAN_TEMP.AR_ID
    WHERE AGR.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
)  ARR
LEFT OUTER JOIN (SELECT  AR_ID, VALUE
                 FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_PRDCT_AGRMNT_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW
                 WHERE TYPE = 'CMMRCL_ID'
                 AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                 ) PROD_IDN_CMRCL
ON ARR.AR_ID = PROD_IDN_CMRCL.AR_ID
LEFT OUTER JOIN (SELECT  AR_ID, VALUE
                 FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_PRDCT_AGRMNT_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW
                 WHERE TYPE = 'IBAN'
                 AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                ) PROD_IDN_IBAN
ON ARR.AR_ID = PROD_IDN_IBAN.AR_ID
LEFT OUTER JOIN (SELECT  AR_ID
                       , VALUE as ARRNR, TYPE
                FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW
                WHERE TYPE not in ('NL_PASOVRNKMSTN','CMMRCL_ID','IBAN','BBAN','UUID','BE_PAN','AMA_ID','BE_MAND_GRP_GRP_ID','IE_FINACLE','BG_FINACLE','DE_IFS','EXT_IBAN','NL_ING_BTLRKGN','NL_INT_AR_ID','NL_PROFILE','NL_VERZKRN','BE_CONTR','BE_QIS','NL_IBM_RKGN','NL_SAM_VV')
                 AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
				 UNION ALL
				 SELECT  AR_ID, VALUE as ARRNR, TYPE from (
					SELECT  AR_ID, VALUE, TYPE,
					row_number() over(partition by AR_ID order by decode(TYPE, 'NL_ING_BTLRKGN',1,'NL_INT_AR_ID',2,'NL_PROFILE',3 ) asc) as RN
					FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW
					WHERE TYPE in ('NL_ING_BTLRKGN','NL_INT_AR_ID','NL_PROFILE')
					AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
				) A where RN = 1
				UNION ALL
				SELECT  AR_ID, VALUE as ARRNR, TYPE from (
					SELECT  AR_ID, VALUE, TYPE,
					row_number() over(partition by AR_ID order by decode(TYPE, 'NL_VERZKRN',1,'BE_CONTR',2,'BE_QIS',3 ) asc) as RN
					FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW
					WHERE TYPE in ('NL_VERZKRN','BE_CONTR','BE_QIS')
					AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
				) A where RN = 1
				UNION ALL
				SELECT  AR_ID, VALUE as ARRNR, TYPE from (
					SELECT  AR_ID, VALUE, TYPE,
					row_number() over(partition by AR_ID order by decode(TYPE, 'NL_IBM_RKGN',1,'NL_SAM_VV',2 ) asc) as RN
					FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW
					WHERE TYPE in ('NL_IBM_RKGN','NL_SAM_VV')
					AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
				) A where RN = 1
                 ) OV
ON ARR.AR_ID = OV.AR_ID
LEFT OUTER JOIN (SELECT  AR_ID, VALUE
                 FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW
                 WHERE TYPE = 'AMA_ID'
                 AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                 ) MAND_IDN_AMA
ON ARR.AR_ID = MAND_IDN_AMA.AR_ID
LEFT OUTER JOIN (SELECT  AR_ID, VALUE
                 FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW
                 WHERE TYPE = ' BE_MAND_GRP_GRP_ID '
                 AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                 ) MAND_IDN_GRP
ON ARR.AR_ID = MAND_IDN_GRP.AR_ID
LEFT OUTER JOIN (
                 SELECT AR_1_ID, MIN(BBAN) BBAN, MIN(IBAN) IBAN
                 FROM
                   (SELECT    FROMAGREEMENTUUID as ARRUUID
                            , TOAGREEMENTUUID
                            ,AR_1_ID
                            ,AR_2_ID
                    FROM  OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_X_AR_R__SL_CIM_CUSTOMER_INFO_XU_VW
                    WHERE VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                    AND ENDDATE IS NULL
                   )  ARRTOARR
                 JOIN
                      (SELECT  AR_ID
                               , VALUE AS BBAN
                       FROM  OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW
                       WHERE VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                       AND TYPE = 'BBAN'
                       ) KEY
                 ON ARRTOARR.AR_2_ID = KEY.AR_ID
                  JOIN
                      (SELECT    AR_ID
                               , VALUE AS IBAN
                       FROM  OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_PRDCT_AGRMNT_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW
                       WHERE VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                       AND TYPE = 'IBAN'
                       ) KEY_IBAN
                 ON ARRTOARR.AR_2_ID = KEY_IBAN.AR_ID
                JOIN
                     (SELECT  AR_ID
                      FROM  OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_V__SL_CIM_CUSTOMER_INFO_XU_VW
                      WHERE  VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                      AND TYPE not in  ('NL_BALANCESTELSEL', 'IBP', 'VV_RNTSTLSL','NL_OVK_OPNMN_GRT_ZAK','NL_OVK_VRPKT_AFSTRTN',
                      'BID_BONDS_TNDR_GNT','RETN_GNTS','SHP_GNT_RLSE_GDS','RENT_GNTS','DCL_OF_ITN','JDCL_GNT','INR_CR_GNT','PYMT_GNTS','ADVNCD_PYMT_GNT','MNT_GNT','CR_RPLCMT_GNT','DOC_COLL_IMP','STNDBY_LC_ISSU','SHIP_GNT','PERF_GNT_BONDS','DOC_LTR_OF_CR_IMP','CSTMS_GNTS','LTR_OF_INDMNTY')
                     ) ARR
                ON ARRTOARR.AR_1_ID = ARR.AR_ID
                GROUP BY AR_1_ID
              ) AR_BBAN_IBAN
ON ARR.AR_ID = AR_BBAN_IBAN.AR_1_ID
LEFT OUTER JOIN (
    SELECT AR_ID
    , NAME
    , CASE WHEN
    (substr(upper(NAME), 1,5) = 'ERVEN'
    OR
      substr(upper(NAME), 1,8) = 'DE ERVEN'
    OR
      upper(NAME) like '% -ERVEN%'
    OR
      upper(NAME) like '%?-ERVEN%'
    OR
      upper(NAME) like '%Â¬-ERVEN%'
    OR
      upper(NAME) like '%?ERVEN%'
    OR
      upper(NAME) like '%Â¬ERVEN%'
    OR
      upper(NAME) like '%REK ERVEN%'
    OR
      upper(NAME) like '%REKENING ERVEN%'
    OR
      upper(NAME) like '%ERVENREK%'
    OR
    (upper(NAME) like '%ERVEN%' and    upper(NAME) like '%BENEF%')
    OR
      (upper(NAME) like '%ERVEN%' and    upper(NAME) like '%BEWIN%')
    OR
      (upper(NAME) like '%ERVEN%' and    upper(NAME) like '%DE GEZAM%')
    OR
      (upper(NAME) like '%ERVEN%' and    upper(NAME) like '%GEV%')
    OR
      (upper(NAME) like '%ERVEN%' and    upper(NAME) like '%GEMACHTIGDE%')
    OR
      (upper(NAME) like '%ERVEN%' and    upper(NAME) like '%GEZ%')
    OR
      (upper(NAME) like '%ERVEN%' and    upper(NAME) like '%INZ%')
    OR
      (upper(NAME) like '%ERVEN%' and    upper(NAME) like '%KINDE%')
    OR
      (upper(NAME) like '%ERVEN%' and    upper(NAME) like '%TBV%')
    OR
    upper(NAME) like '%ERFGE%'
    OR
    upper(NAME) like '%EXEC%'
    OR
    upper(NAME) like '%NALATENSCHAP%') THEN 'Y'
    WHEN  TYPE in ('NL_KINDRRKG','NL_EN_OF_BTLRKG','NL_BTLRKG','NL_JONGRKG','NL_STUDNTNRKG')  THEN 'N'
    ELSE NULL
    END  as HA_INH_IND
    FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_V__SL_CIM_CUSTOMER_INFO_XU_VW
    WHERE VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
    ) INH
ON ARR.AR_ID = INH.AR_ID
;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_AR_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_AR_VW" ("TA_KEY", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_UUID", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_AR_NBR", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_ID_TP", "TA_HASH_VAL", "HA_AR_CD", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT TA_KEY
      ,  HA_OPN_DT
      ,  HA_END_DT
      ,  HA_ST_CD
      ,  HA_CCY_CD
      ,  HA_PD_CD
      ,  HA_LE_CD
      ,  HA_AR_UUID
      ,  HA_CMRCL_NBR
      ,  HA_BBAN_NBR
      ,  HA_IBAN_NBR
      ,  HA_INH_IND
      ,  HA_JIVE_IND
	  ,  HA_DEL_IND
	  ,  HA_AR_NBR
	  ,  HA_INGENTITY_CD
	  ,  HA_NCKNM
	  ,  HA_AR_ID_TP
      ,  TA_HASH_VAL
	  ,  HA_AR_CD
	  ,  HA_AMA_ID
	  ,  HA_BE_GRP_ID
	  ,  HA_AR_IDNT
FROM (
SELECT
         TA_KEY
      ,  HA_OPN_DT
      ,  HA_END_DT
      ,  HA_ST_CD
      ,  HA_CCY_CD
      ,  HA_PD_CD
      ,  HA_LE_CD
      ,  HA_AR_UUID
      ,  HA_CMRCL_NBR
      ,  HA_BBAN_NBR
      ,  HA_IBAN_NBR
      ,  HA_INH_IND
      ,  HA_JIVE_IND
	  ,  HA_DEL_IND
	  ,  HA_AR_NBR
	  ,  HA_INGENTITY_CD
	  ,  HA_NCKNM
	  ,  HA_AR_ID_TP
	  ,  HA_AR_CD
	  ,  HA_AMA_ID
	  ,  HA_BE_GRP_ID
	  ,  HA_AR_IDNT
      ,  CAST(standard_hash(
        NVL(TA_KEY,CHR(0))
		|| ';'
		|| HA_OPN_DT
		|| ';'
		|| HA_END_DT
		|| ';'
		|| HA_ST_CD
		|| ';'
		|| HA_CCY_CD
		|| ';'
		|| HA_PD_CD
		|| ';'
		|| NVL(HA_LE_CD,CHR(0))
		|| ';'
		|| NVL(HA_AR_UUID,CHR(0))
		|| ';'
		|| NVL(HA_CMRCL_NBR,CHR(0))
		|| ';'
		|| NVL(HA_BBAN_NBR,CHR(0))
		|| ';'
		|| NVL(HA_IBAN_NBR,CHR(0))
		|| ';'
		|| NVL(HA_INH_IND,CHR(0))
		|| ';'
		|| NVL(HA_JIVE_IND,CHR(0))
		|| ';'
		|| NVL(HA_AR_NBR,CHR(0))
		|| ';'
		|| NVL(HA_INGENTITY_CD,CHR(0))
		|| ';'
		|| NVL(HA_NCKNM,CHR(0))
		|| ';'
		|| NVL(HA_AR_ID_TP,CHR(0))
		|| ';'
		|| NVL(HA_AR_CD,CHR(0))
		|| ';'
		|| NVL(HA_AMA_ID,CHR(0))
		|| ';'
		|| NVL(HA_BE_GRP_ID,CHR(0))
		|| ';'
		|| NVL(HA_AR_IDNT,CHR(0))
		|| ';'
		|| HA_DEL_IND ,'MD5') AS CHAR(32)) TA_HASH_VAL
		, ROW_NUMBER() OVER (PARTITION BY TA_KEY ORDER BY HA_DEL_IND asc,  HA_END_DT desc, HA_OPN_DT desc )     ROWNUM1
FROM
      SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_AR_NOHASH_VW )   A
WHERE ROWNUM1 = 1 AND TA_KEY is not null;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_INACTIVES_DEDUP_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_IP_INACTIVES_DEDUP_VW" ("IP_ID", "HA_END_TMS", "PREFERENCE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT A.IP_ID,
NVL(C.HA_END_DT,A.HA_END_TMS) As HA_END_TMS,
A.PREFERENCE
FROM ((SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_INACTIVES A
JOIN (
SELECT SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_INACTIVES.IP_ID, MIN(SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_INACTIVES.PREFERENCE) AS PREFERENCE
FROM SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_INACTIVES
GROUP BY SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_INACTIVES.IP_ID) B ON (((A.IP_ID = B.IP_ID)
AND (A.PREFERENCE = B.PREFERENCE))))
LEFT JOIN SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP C ON ((((C.TA_SRC_ROW_ID = A.IP_ID)
AND C.TA_VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND C.HA_END_DT  IS NOT NULL))));"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_D7_IP_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_IP_TP_IND", "HA_IP_TP_CD", "HA_BRTH_DT", "HA_DCSD_DT", "HA_GND_IND", "HA_BRTH_DT_QLY_CD", "HA_BRTH_CITY_NM", "HA_BRTH_CTRY_CD", "HA_RSDNT_CTRY_CD", "HA_IP_UUID", "HA_IP_NBR", "HA_GRID_NBR", "HA_COLLAPSED_IND", "HA_COLLAPSED_DT", "HA_COLLAPSED_TO_IP_UUID", "HA_COLLAPSED_TO_IP_NBR", "HA_PRIV_PREF_CD", "HA_MGN_ENT_CD", "HA_KVK_NBR", "HA_TRD_NM", "HA_FORMAL_NM", "HA_PREF_LANG_CD", "HA_ESTB_DT", "HA_LGL_FORM_CD", "HA_SBI_TP_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_STRT_DT", "HA_JIVE_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_SEG_CD", "HA_SEG_CGY_CD", "HA_CRSP_NM", "TA_HASH_VAL_HA") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP.IP_ID AS TA_SRC_ROW_ID,
IP.MSTR_SRC_STM_CD||'.'||MSTR_SRC_STM_KEY AS TA_KEY,
COMNFLDS.HA_IP_TP_IND AS HA_IP_TP_IND,
COMNFLDS.HA_IP_TP_CD AS HA_IP_TP_CD,
INDIVDEMOGR.DATEOFBIRTH AS HA_BRTH_DT,
INDIVDEMOGR.DATEOFDEATH AS HA_DCSD_DT,
substr(INDIVDEMOGR.GENDER,0,1) AS HA_GND_IND,
INDIVDEMOGR.DATEOFBIRTHQUALITYINDICATOR  AS HA_BRTH_DT_QLY_CD,
INDIVDEMOGR.CITYOFBIRTH  AS HA_BRTH_CITY_NM,
INDIVDEMOGR.COUNTRYOFBIRTH AS HA_BRTH_CTRY_CD,
INDIVDEMOGR.COUNTRYOFRESIDENCE AS HA_RSDNT_CTRY_CD,
COALESCE(INDIVDEMOGR.INVOLVEDPARTYIDENTIFIER, ORGDEM.INVOLVEDPARTYIDENTIFIER) AS HA_IP_UUID,
PKEY.VALUE AS HA_IP_NBR,
PKEYGRID.VALUE AS HA_GRID_NBR,
PKEYCOLL.COLLAPSED_IND AS HA_COLLAPSED_IND,
PKEYCOLL.COLLAPSED_DT as HA_COLLAPSED_DT,
PKEYCOLL.collapsedto_dedupinvolvedpartyidentifier AS HA_COLLAPSED_TO_IP_UUID,
PKEYCOLL.VALUE AS HA_COLLAPSED_TO_IP_NBR,
PRIVPREF.INVOLVEDPARTYPREFTYPE  AS HA_PRIV_PREF_CD,
PMANENT.CODE AS HA_MGN_ENT_CD,
PIDENT.VALUE AS HA_KVK_NBR,
NULL AS HA_TRD_NM,
ORGNAM_FRM.ORGANISATIONNAME AS HA_FORMAL_NM,
INDIVDEMOGR.PREFERREDLANGUAGE AS HA_PREF_LANG_CD,
ORGDEM.DATEOFFOUNDATION AS HA_ESTB_DT,
ORGDEM.LEGALFORM AS HA_LGL_FORM_CD,
NULL AS HA_SBI_TP_CD,
PPADDR.POSTALCODE AS HA_ZIP_CD,
COMNFLDS.HA_LE_CD AS HA_LE_CD,
COALESCE(INDIVDEMOGR.EFFECTIVEDATE, ORGDEM.EFFECTIVEDATE) HA_STRT_DT,
(case when PINAMPA.LASTNAME like '%JIVE%' or PINAMPA.NAMEINITIALS like '%JIVE%' or PINAMPA.LASTNAME LIKE '%ING%' THEN 1 ELSE 0 END) AS HA_JIVE_IND,
IPINACTIVES.HA_END_TMS AS HA_END_DT,
CASE WHEN PRFL_CCNT.PREFERENCECONSENT = 'INTD' THEN 'Y' WHEN PRFL_CCNT.PREFERENCECONSENT = 'NOT_INTD' THEN 'N' END AS HA_PRFL_CCNT_IND,
CASE WHEN RGHT_TO_OBJ.PREFERENCECONSENT = 'INTD' THEN 'Y' WHEN RGHT_TO_OBJ.PREFERENCECONSENT = 'NOT_INTD' THEN 'N' END AS HA_RGHT_TO_OBJ_IND,
SUBSTR(TRIM(PPADDR.STREETNAME),1,50) AS HA_STR_NM,
PPADDR.CITYNAME AS HA_CTY_NM,
SUBSTR(TRIM(PPADDR.HOUSENUMBER),1,10) AS HA_BLD_NBR,
PPADDR.HOUSENUMBERADDITION AS HA_UNIT_NBR,
SUBSTR(TRIM(PINAMPA.NAMEINITIALS),1,10) AS HA_INIT_NM,
SUBSTR(TRIM(PINAMPA.LASTNAMEPREFIX),1,20) AS HA_PREPSTN_NM,
SUBSTR(TRIM(PINAMPA.LASTNAME),1,50) AS HA_LST_NM,
SUBSTR(TRIM(CSI.VALUE),1,20) AS HA_CSI_NBR,
SUBSTR(TRIM(ING_ID_BE.VALUE),1,20) AS HA_BE_NBR,
NVL(COMNFLDS.HA_DEL_IND,'Y') AS HA_DEL_IND,
case when MOBILE.DEL_IN_SRC_STM_F='1' AND LANDLINE.DEL_IN_SRC_STM_F='0' THEN SUBSTR(TRIM(LANDLINE.FULLDIGITALADDRESS),1,20)
	 ELSE SUBSTR(TRIM(NVL(MOBILE.FULLDIGITALADDRESS,LANDLINE.FULLDIGITALADDRESS)),1,20)
end AS HA_TEL_NBR,
CASE PTYPE.PARTYTYPE
WHEN 'P' THEN SUBSTR(TRIM(PERSEMAIL.FULLDIGITALADDRESS),1,100)
WHEN 'O' THEN SUBSTR(TRIM(BUSEMAIL.FULLDIGITALADDRESS),1,100) END AS HA_EMAIL_ADR,
SEG.GROUPCODE AS HA_SEG_CD,
SEG_CAT.HA_SEG_CGY_CD AS HA_SEG_CGY_CD,
SUBSTR(TRIM(FORMNA.INDIVIDUALNAMEVALUE),1,50) AS HA_CRSP_NM,
CAST(STANDARD_HASH(
NVL(IP.MSTR_SRC_STM_CD,CHR(0)) ||'.'||
NVL(IP.MSTR_SRC_STM_KEY,CHR(0)) ||';'||
NVL(COMNFLDS.HA_IP_TP_IND,CHR(0)) ||';'||
COMNFLDS.HA_IP_TP_CD ||';'||
INDIVDEMOGR.DATEOFBIRTH ||';'||
INDIVDEMOGR.DATEOFDEATH  ||';'||
NVL(INDIVDEMOGR.GENDER,CHR(0)) ||';'||
INDIVDEMOGR.DATEOFBIRTHQUALITYINDICATOR ||';'||
NVL(INDIVDEMOGR.CITYOFBIRTH,CHR(0)) ||';'||
INDIVDEMOGR.COUNTRYOFBIRTH ||';'||
INDIVDEMOGR.COUNTRYOFRESIDENCE ||';'||
NVL(COALESCE(INDIVDEMOGR.INVOLVEDPARTYIDENTIFIER, ORGDEM.INVOLVEDPARTYIDENTIFIER),CHR(0)) ||';'||
NVL(PKEYGRID.VALUE,CHR(0)) ||';'||
PRIVPREF.INVOLVEDPARTYPREFTYPE ||';'||
NVL(PMANENT.CODE,CHR(0)) ||';'||
NVL(PIDENT.VALUE,CHR(0)) ||';'||
NVL(ORGNAM_FRM.ORGANISATIONNAME,CHR(0)) ||';'||
NVL(INDIVDEMOGR.PREFERREDLANGUAGE,CHR(0)) ||';'||
TO_DATE(TO_CHAR(ORGDEM.DATEOFFOUNDATION, 'YYYY-MM-DD'),'YYYY-MM-DD') ||';'||
NVL(ORGDEM.LEGALFORM,CHR(0)) ||';'||
NVL(PPADDR.POSTALCODE,CHR(0)) ||';'||
NVL(COMNFLDS.HA_LE_CD,CHR(0)) ||';'||
COALESCE(INDIVDEMOGR.EFFECTIVEDATE, ORGDEM.EFFECTIVEDATE) ||';'||
case when PINAMPA.LASTNAME like '%JIVE%' or PINAMPA.NAMEINITIALS like '%JIVE%' or PINAMPA.LASTNAME LIKE '%ING%' THEN 1 ELSE 0 END ||';'||
NVL(SUBSTR(TRIM(PPADDR.STREETNAME),1,50),CHR(0)) ||';'||
NVL(PPADDR.CITYNAME,CHR(0)) ||';'||
NVL(SUBSTR(TRIM(PPADDR.HOUSENUMBER),1,10),CHR(0)) ||';'||
NVL(PPADDR.HOUSENUMBERADDITION,CHR(0)) ||';'||
NVL(SUBSTR(TRIM(PINAMPA.NAMEINITIALS),1,10),CHR(0)) ||';'||
NVL(SUBSTR(TRIM(PINAMPA.LASTNAMEPREFIX),1,20),CHR(0)) ||';'||
NVL(SUBSTR(TRIM(PINAMPA.LASTNAME),1,50),CHR(0)) ||';'||
NVL(SUBSTR(TRIM(CSI.VALUE),1,20),CHR(0)) ||';'||
NVL(SUBSTR(TRIM(ING_ID_BE.VALUE),1,20),CHR(0)) ||';' ||
NVL(NVL(COMNFLDS.HA_DEL_IND,'Y'),CHR(0)) ||'.'||
NVL(IP.MSTR_SRC_STM_CD,CHR(0)) ||'.'||
NVL(IP.MSTR_SRC_STM_KEY,CHR(0)) ||';'||
1 ||';'||
TO_DATE(TO_CHAR(PKEYCOLL.COLLAPSED_DT, 'YYYY-MM-DD'),'YYYY-MM-DD') ||';'||
NVL(PKEYCOLL.collapsedto_dedupinvolvedpartyidentifier,CHR(0)) ||';'||
NVL(PKEYCOLL.VALUE,CHR(0)) ||';'||
TO_DATE(TO_CHAR(IPINACTIVES.HA_END_TMS, 'YYYY-MM-DD'),'YYYY-MM-DD') ||';'||
NVL(PRFL_CCNT.PREFERENCECONSENT,CHR(0)) ||';'||
NVL(RGHT_TO_OBJ.PREFERENCECONSENT,CHR(0)) ||';'||
NVL(case when MOBILE.DEL_IN_SRC_STM_F='1' AND LANDLINE.DEL_IN_SRC_STM_F='0' THEN SUBSTR(TRIM(LANDLINE.FULLDIGITALADDRESS),1,20)
ELSE SUBSTR(TRIM(NVL(MOBILE.FULLDIGITALADDRESS,LANDLINE.FULLDIGITALADDRESS)),1,20) end,CHR(0)) ||';'||
NVL(CASE PTYPE.PARTYTYPE
WHEN 'P' THEN SUBSTR(TRIM(PERSEMAIL.FULLDIGITALADDRESS),1,100)
WHEN 'O' THEN SUBSTR(TRIM(BUSEMAIL.FULLDIGITALADDRESS),1,100) END,CHR(0)) ||';'||
NVL(SEG.GROUPCODE,CHR(0)) ||';'||
NVL(SEG_CAT.HA_SEG_CGY_CD,CHR(0)) ||';'||
NVL(SUBSTR(TRIM(FORMNA.INDIVIDUALNAMEVALUE),1,50),CHR(0)) , 'MD5') AS CHAR(32))  AS TA_HASH_VAL_HA
FROM
( select IP_ID, IP_SUP_KEY, MSTR_SRC_STM_CD, SUBSTR(IP_SUP_KEY, INSTR(IP_SUP_KEY, '|', 1, 2)+1, LENGTH(IP_SUP_KEY)-INSTR(IP_SUP_KEY, '|', 1, 2)) as MSTR_SRC_STM_KEY
from OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDIVIDUAL_V__SL_CIM_CUSTOMER_INFO_XU_VW where MSTR_SRC_STM_CD = 'MDM' and ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED', 'ING_BE', 'ING_BE_SHARED')
UNION
select IP_ID, IP_SUP_KEY, MSTR_SRC_STM_CD, SUBSTR(IP_SUP_KEY, INSTR(IP_SUP_KEY, '|', 1, 2)+1, LENGTH(IP_SUP_KEY)-INSTR(IP_SUP_KEY, '|', 1, 2)) as MSTR_SRC_STM_KEY
from OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGANISATION_V__SL_CIM_CUSTOMER_INFO_XU_VW where MSTR_SRC_STM_CD = 'MDM' and ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED', 'ING_BE', 'ING_BE_SHARED')) IP
LEFT OUTER JOIN
(
SELECT IP.IP_ID, 'P' AS PARTYTYPE FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_IP_K__SL_CIM_CUSTOMER_INFO_XU_VW IP
INNER JOIN  OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDIVIDUAL_V__SL_CIM_CUSTOMER_INFO_XU_VW INDI
ON IP.IP_SUP_KEY = INDI.IP_SUP_KEY
AND INDI.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
UNION
SELECT IP.IP_ID, 'O' AS PARTYTYPE FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_IP_K__SL_CIM_CUSTOMER_INFO_XU_VW IP
INNER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGNAME_M__SL_CIM_CUSTOMER_INFO_XU_VW ORG
ON IP.IP_SUP_KEY = ORG.IP_SUP_KEY
AND ORG.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
) PTYPE ON IP.IP_ID = PTYPE.IP_ID
LEFT OUTER JOIN (select IP_ID, VALUE,  INVOLVEDPARTYIDENTIFIER,
				ROW_NUMBER() OVER (PARTITION BY IP_ID ORDER BY DEL_IN_SRC_STM_F ASC, LASTUPDATEDATE DESC, VALUE DESC ) as RN
				FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INTERNAL_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW
				WHERE VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND TYPE IN ('RGB_NL','CLP_NL')
				) PKEY ON PKEY.RN = 1 AND IP.IP_ID = PKEY.IP_ID
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDIVIDUAL_V__SL_CIM_CUSTOMER_INFO_XU_VW  INDIVDEMOGR ON IP.IP_ID=INDIVDEMOGR.IP_ID AND INDIVDEMOGR.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN (select IP_ID, VALUE,
				ROW_NUMBER() OVER (PARTITION BY IP_ID ORDER BY decode(TYPE, 'GRID',1,'GRID_INA_NL',2,'GRID_DUP_NL',3 ) ASC, DEL_IN_SRC_STM_F ASC, LASTUPDATEDATE DESC, VALUE DESC ) as RN
				FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INTERNAL_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW
				WHERE VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND TYPE IN ('GRID','GRID_INA_NL','GRID_DUP_NL')
				) PKEYGRID ON PKEYGRID.RN = 1 AND IP.IP_ID = PKEYGRID.IP_ID
LEFT OUTER JOIN
				(
				SELECT PKEYC.IP_ID, PKEYC.collapsedto_dedupinvolvedpartyidentifier , PKEYC.COLLAPSED_IND, PKEYC.COLLAPSED_DT, PKEY1.VALUE
				from  OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_IIDENTIFIER_M_COLL__SL_CIM_CUSTOMER_INFO_XU_VW PKEYC
				INNER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INTERNAL_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW PKEY1
				ON PKEYC.collapsedto_dedupinvolvedpartyidentifier =PKEY1.INVOLVEDPARTYIDENTIFIER AND PKEY1.TYPE in ('RGB_NL','CLP_NL')
				AND PKEY1.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
				AND PKEYC.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
				) PKEYCOLL ON IP.IP_ID=PKEYCOLL.IP_ID
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INPREF_COM_PREF_V__SL_CIM_CUSTOMER_INFO_XU_VW  PRIVPREF ON IP.IP_ID=PRIVPREF.IP_ID AND 		PRIVPREF.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_MANAGING_ENTITY_M__SL_CIM_CUSTOMER_INFO_XU_VW  PMANENT ON IP.IP_ID=PMANENT.IP_ID AND PMANENT.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') and PMANENT.TYPE IN ('MANAGING_ENTITIES_CODE_NL','RLTNP_MGR_PRTFL_BE')
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_EXTERNAL_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW  PIDENT ON IP.IP_ID=PIDENT.IP_ID AND PIDENT.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND PIDENT.TYPE ='KVK_NL'
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGNAME_M__SL_CIM_CUSTOMER_INFO_XU_VW  ORGNAM_FRM ON IP.IP_ID=ORGNAM_FRM.IP_ID AND ORGNAM_FRM.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND ORGNAM_FRM.ORGANISATIONNAMETYPE = 'LGL_NM_SHRT'
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGANISATION_V__SL_CIM_CUSTOMER_INFO_XU_VW  ORGDEM ON IP.IP_ID=ORGDEM.IP_ID AND ORGDEM.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_POSTAL_ADDRESS_M__SL_CIM_CUSTOMER_INFO_XU_VW  PPADDR ON IP.IP_ID=PPADDR.IP_ID AND PPADDR.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND PPADDR.USAGETYPE NOT IN ('CRSPD_ADR','NETG_ADR')
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDINAME_M__SL_CIM_CUSTOMER_INFO_XU_VW  PINAMPA ON IP.IP_ID=PINAMPA.IP_ID AND PINAMPA.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INTERNAL_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW  PKEYUUID ON IP.IP_ID=PKEYUUID.IP_ID AND PKEYUUID.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND PKEYUUID.TYPE='UUID'
LEFT OUTER JOIN (
(SELECT TA_SRC_ROW_ID AS IP_ID, NULL AS HA_END_TMS
  FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP
  WHERE TA_VLD_TO_TMS= TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
  AND HA_END_DT IS NOT NULL
MINUS
SELECT IP_ID, NULL AS HA_END_TMS
  FROM SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_INACTIVES_DEDUP_VW) -- RE-ACTIVE IPS
UNION
SELECT IP_ID, HA_END_TMS FROM SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_INACTIVES_DEDUP_VW )  IPINACTIVES -- INACTIVES PLUS RE-ACTIVES
ON IP.IP_ID=IPINACTIVES.IP_ID
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INPREF_M__SL_CIM_CUSTOMER_INFO_XU_VW  RGHT_TO_OBJ ON IP.IP_ID = RGHT_TO_OBJ.IP_ID AND RGHT_TO_OBJ.INVOLVEDPARTYPREFTYPE = 'RGHT_TO_OBJ' and RGHT_TO_OBJ.INVOLVEDPARTYPREFCATEGORY ='IP_PREF_PRVC' AND RGHT_TO_OBJ.VLD_TO_TMS =TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INPREF_M__SL_CIM_CUSTOMER_INFO_XU_VW  PRFL_CCNT ON IP.IP_ID = PRFL_CCNT.IP_ID AND PRFL_CCNT.INVOLVEDPARTYPREFTYPE = 'PRFL_CCNT' and PRFL_CCNT.INVOLVEDPARTYPREFCATEGORY ='IP_PREF_PRVC' AND PRFL_CCNT.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN (select IP_ID, FULLDIGITALADDRESS, DEL_IN_SRC_STM_F,
				ROW_NUMBER() OVER (PARTITION BY IP_ID ORDER BY DEL_IN_SRC_STM_F ASC, EFFECTIVEDATE DESC, ENDDATE DESC,LASTUPDATEDATE desc, vld_from_tms desc ) as RN
				FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_DIGITAL_ADDRESS_M__SL_CIM_CUSTOMER_INFO_XU_VW
				WHERE VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND USAGETYPE='LANDLINE_TEL_NBR' and TYPE='TEL_ADR'
				) LANDLINE ON LANDLINE.RN = 1 AND IP.IP_ID = LANDLINE.IP_ID
LEFT OUTER JOIN (select IP_ID, FULLDIGITALADDRESS, DEL_IN_SRC_STM_F,
				ROW_NUMBER() OVER (PARTITION BY IP_ID ORDER BY DEL_IN_SRC_STM_F ASC, EFFECTIVEDATE DESC, ENDDATE DESC,LASTUPDATEDATE desc, vld_from_tms desc  ) as RN
				FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_DIGITAL_ADDRESS_M__SL_CIM_CUSTOMER_INFO_XU_VW
				WHERE VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND USAGETYPE='MBL_TEL_NBR' and TYPE='TEL_ADR'
				) MOBILE ON MOBILE.RN = 1 AND IP.IP_ID = MOBILE.IP_ID
LEFT OUTER JOIN (select IP_ID, FULLDIGITALADDRESS,
				ROW_NUMBER() OVER (PARTITION BY IP_ID ORDER BY DEL_IN_SRC_STM_F ASC, EFFECTIVEDATE DESC, ENDDATE DESC,LASTUPDATEDATE desc, vld_from_tms desc  ) as RN
				FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_DIGITAL_ADDRESS_M__SL_CIM_CUSTOMER_INFO_XU_VW
				WHERE VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND USAGETYPE='PSN_EMAIL' and TYPE='EMAIL_ADR'
				) PERSEMAIL ON PERSEMAIL.RN = 1 AND IP.IP_ID = PERSEMAIL.IP_ID
LEFT OUTER JOIN (select IP_ID, FULLDIGITALADDRESS,
				ROW_NUMBER() OVER (PARTITION BY IP_ID ORDER BY DEL_IN_SRC_STM_F ASC, EFFECTIVEDATE DESC, ENDDATE DESC,LASTUPDATEDATE desc, vld_from_tms desc  ) as RN
				FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_DIGITAL_ADDRESS_M__SL_CIM_CUSTOMER_INFO_XU_VW
				WHERE VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND USAGETYPE='BSN_EMAIL' and TYPE='EMAIL_ADR'
				) BUSEMAIL ON BUSEMAIL.RN = 1 AND IP.IP_ID = BUSEMAIL.IP_ID
LEFT OUTER JOIN
				(
				SELECT GRP.IP_ID, GRP.GROUPCODE, SEGCAT.HA_SEG_CGY_CD
				FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_GROUP_V__SL_CIM_CUSTOMER_INFO_XU_VW  GRP
				INNER JOIN SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SEG  SEGCAT
				ON GRP.GROUPCODE = SEGCAT.HA_SEG_CD
                AND GRP.GROUPTYPE=SEGCAT.HA_GRP_TP
				AND GRP.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
				AND SEGCAT.TA_VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                WHERE GRP.GROUPTYPE in ('SVC_SEGM_NL','SVC_SEGM_BE')
				) SEG_CAT ON IP.IP_ID = SEG_CAT.IP_ID
LEFT OUTER JOIN
				(
				SELECT GRP.IP_ID, GRP.GROUPCODE	FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_GROUP_V__SL_CIM_CUSTOMER_INFO_XU_VW  GRP
				WHERE GRP.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
				AND GRP.GROUPTYPE in ('SVC_SEGM_NL','SVC_SEGM_BE')) SEG
				ON IP.IP_ID = SEG.IP_ID
LEFT OUTER JOIN (select IP_ID, VALUE,
				ROW_NUMBER() OVER (PARTITION BY IP_ID ORDER BY DEL_IN_SRC_STM_F ASC, LASTUPDATEDATE DESC, VALUE DESC ) as RN
				FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INTERNAL_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW
				WHERE VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND TYPE ='CSI_BE'
				) CSI ON CSI.RN = 1 AND IP.IP_ID = CSI.IP_ID
LEFT OUTER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDFMTNM_M__SL_CIM_CUSTOMER_INFO_XU_VW  FORMNA ON IP.IP_ID = FORMNA.IP_ID AND FORMNA.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND FORMNA.INDIVIDUALNAMETYPE = 'CORRPDC_NM'
LEFT OUTER JOIN (select IP_ID, VALUE,
				ROW_NUMBER() OVER (PARTITION BY IP_ID ORDER BY DEL_IN_SRC_STM_F ASC, LASTUPDATEDATE DESC, VALUE DESC ) as RN
				FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INTERNAL_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW
				WHERE VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND TYPE ='ING_ID_BE'
				) ING_ID_BE ON ING_ID_BE.RN = 1 AND IP.IP_ID = ING_ID_BE.IP_ID
LEFT OUTER JOIN SL_CIM_PRP_OWNER.ONEPAM_PRP_D7_IP_COMMON_FIELDS COMNFLDS ON IP.MSTR_SRC_STM_KEY = COMNFLDS.HA_IP_UUID;"
/* <sc-view> SL_CIM_PRP_OWNER.ONEPAM_PRP_B2_AR_X_IP_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."ONEPAM_PRP_B2_AR_X_IP_VW" ("HA_AR_UUID", "TA_AR_TYPE", "HA_LE_CD", "HA_ROLE_TYPE", "HA_OPER_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT", "HA_IP_UUID", "TA_KEY", "HA_DEL_IND", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT AGREEMENTIDENTIFIER as HA_AR_UUID,
    ARTYPE as TA_AR_TYPE,
    SubStr(ACCESSTOKEN,1,6) As HA_LE_CD,
    ROLETYPE as HA_ROLE_TYPE,
    OPERATIONALLIFECYCLESTATUSTYPE as HA_OPER_STATUS_TYPE,
    EFFECTIVEDATE as HA_EFF_DT,
    ENDDATE as HA_END_DT,
    INVOLVEDPARTYIDENTIFIER as HA_IP_UUID,
	(MSTR_SRC_STM_CD || '.' || ARTYPE || '.' || AGREEMENTIDENTIFIER || '.' || INVOLVEDPARTYIDENTIFIER || '.' || ROLETYPE) AS TA_KEY,
	 CASE WHEN DEL_IN_SRC_STM_F =1 then 'Y' ELSE 'N' END as HA_DEL_IND,
	 CAST(standard_hash(
	   NVL(AGREEMENTIDENTIFIER,CHR(0))
	||';'
	|| NVL("ARTYPE",CHR(0))
	||';'
	|| NVL(SubStr(ACCESSTOKEN,1,6),CHR(0))
	||';'
	|| NVL("ROLETYPE",CHR(0))
	||';'
	|| NVL("OPERATIONALLIFECYCLESTATUSTYPE",CHR(0))
	||';'
	|| TO_CHAR(EFFECTIVEDATE, 'DD-MON-YYYY HH24:MI:SSxFF')
	||';'
	|| TO_CHAR(ENDDATE, 'DD-MON-YYYY HH24:MI:SSxFF')
	||';'
	|| NVL(INVOLVEDPARTYIDENTIFIER,CHR(0))
	|| ';'
	|| CASE WHEN DEL_IN_SRC_STM_F =1 then 'Y' ELSE 'N' END ,'MD5') AS CHAR(32)) TA_HASH_VAL
FROM
( select IP_ID
from OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDIVIDUAL_V__SL_CIM_CUSTOMER_INFO_XU_VW where MSTR_SRC_STM_CD = 'MDM' and ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED')
UNION
select IP_ID
from OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGANISATION_V__SL_CIM_CUSTOMER_INFO_XU_VW where MSTR_SRC_STM_CD = 'MDM' and ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED')) IP
INNER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_X_IP_R__SL_CIM_CUSTOMER_INFO_XU_VW AR_X_IP
ON IP.IP_ID = AR_X_IP.IP_ID and AR_X_IP.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_X_IP.ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED')
UNION ALL
SELECT AGREEMENTIDENTIFIER as HA_AR_UUID,
    ARTYPE as TA_AR_TYPE,
    SubStr(ACCESSTOKEN,1,6) As HA_LE_CD,
    ROLETYPE as HA_ROLE_TYPE,
    OPERATIONALLIFECYCLESTATUSTYPE as HA_OPER_STATUS_TYPE,
    EFFECTIVEDATE as HA_EFF_DT,
    ENDDATE as HA_END_DT,
    INVOLVEDPARTYIDENTIFIER as HA_IP_UUID,
	(MSTR_SRC_STM_CD || '.' || ARTYPE || '.' || AGREEMENTIDENTIFIER || '.' || INVOLVEDPARTYIDENTIFIER || '.' || ROLETYPE) AS TA_KEY,
	 CASE WHEN DEL_IN_SRC_STM_F =1 then 'Y' ELSE 'N' END as HA_DEL_IND,
	 CAST(standard_hash(
	   NVL(AGREEMENTIDENTIFIER,CHR(0))
	||';'
	|| NVL("ARTYPE",CHR(0))
	||';'
	|| NVL(SubStr(ACCESSTOKEN,1,6),CHR(0))
	||';'
	|| NVL("ROLETYPE",CHR(0))
	||';'
	|| NVL("OPERATIONALLIFECYCLESTATUSTYPE",CHR(0))
	||';'
	|| TO_CHAR(EFFECTIVEDATE, 'DD-MON-YYYY HH24:MI:SSxFF')
	||';'
	|| TO_CHAR(ENDDATE, 'DD-MON-YYYY HH24:MI:SSxFF')
	||';'
	|| NVL(INVOLVEDPARTYIDENTIFIER,CHR(0))
	|| ';'
	|| CASE WHEN DEL_IN_SRC_STM_F =1 then 'Y' ELSE 'N' END ,'MD5') AS CHAR(32)) TA_HASH_VAL
FROM
( select IP_ID
from OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDIVIDUAL_V__SL_CIM_CUSTOMER_INFO_XU_VW where MSTR_SRC_STM_CD = 'MDM' and ACCESSTOKEN IN ('ING_BE', 'ING_BE_SHARED')
UNION
select IP_ID
from OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGANISATION_V__SL_CIM_CUSTOMER_INFO_XU_VW where MSTR_SRC_STM_CD = 'MDM' and ACCESSTOKEN IN ('ING_BE', 'ING_BE_SHARED')) IP
INNER JOIN OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_X_IP_R__SL_CIM_CUSTOMER_INFO_XU_VW AR_X_IP
ON IP.IP_ID = AR_X_IP.IP_ID and AR_X_IP.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_X_IP.ACCESSTOKEN IN ('ING_BE', 'ING_BE_SHARED')
;"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_AR_NOHASH_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_AR_NOHASH_VW" ("TA_KEY", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
		 CASE WHEN ARR.CATEGORYCODE = 1 AND ARR.ACCESSTOKEN in('ING_NL','ING_NL_SHARED')
THEN
(
CASE WHEN BBAN.BBAN IS NOT NULL THEN 'MDM.'||BBAN.BBAN||'&'||ARR.CATEGORYCODE
ELSE NULL
END
)
WHEN ARR.ARRUUID IS NOT NULL THEN 'MDM.'||ARR.ARRUUID
ELSE NULL
END  as TA_KEY
      ,  ARR.OPENDATE  as  HA_OPN_DT
      ,  ARR.ENDEDDATE as  HA_END_DT
      ,  ARR.STATUSCODE  as  HA_ST_CD
      ,  ARR.CURRENCYCODE as HA_CCY_CD
      ,  ARR.PRODUCTCODE HA_PD_CD
      ,  ARR.ACCESSTOKEN As HA_LE_CD
      ,  CASE WHEN  ARR.CATEGORYCODE = 1 THEN BBAN.BBAN
             WHEN  ARR.PRODUCTCODE  BETWEEN 71 and 79 OR ARR.PRODUCTCODE in (82, 178) THEN COMM.COMMERCIALID
             WHEN  ARR.CATEGORYCODE = 11 THEN LTRIM( SUBSTR(OV.ARRNR, 1,9), '0' )
             WHEN  ARR.PRODUCTCODE in (124,125) THEN SUBSTR(OV.ARRNR,2,12)
             WHEN  ARR.CATEGORYCODE in (8, 9, 10) THEN LTRIM( SUBSTR(OV.ARRNR, 2,9), '0' )
             WHEN  ARR.PRODUCTCODE = 480 THEN LTRIM(OV.ARRNR, '0')
             WHEN  ARR.PRODUCTCODE in (501, 503, 504, 505, 511, 512, 514, 516, 524, 525) THEN AR_BBAN_IBAN.BBAN
             WHEN  ARR.PRODUCTCODE in (506, 507, 508, 509, 510, 515, 517, 520, 521, 522, 523, 526, 530, 531, 532, 533) THEN SUBSTR(COMM.COMMERCIALID,2,9)
             WHEN  ARR.PRODUCTCODE in (527,528,529) THEN  LTRIM ( SUBSTR(OV.ARRNR, 2, LENGTH(OV.ARRNR) - 1) ,'0')
             WHEN  ARR.PRODUCTCODE in (340,920) THEN LTRIM (OV.ARRNR, '0')
             WHEN  ARR.PRODUCTCODE in (140, 141, 142, 143) THEN  SUBSTR(OV.ARRNR, 1, LENGTH(OV.ARRNR) - 9)
             WHEN  ARR.CATEGORYCODE = 22 THEN LTRIM ( SUBSTR(COMM.COMMERCIALID,9,10) , '0')
             WHEN  ARR.CATEGORYCODE = 24 THEN LTRIM ( COMM.COMMERCIALID , '0')
             ELSE OV.ARRNR
             END                  AS HA_AR_NBR
      ,  CASE WHEN ARR.PRODUCTCODE in (501, 503, 504, 505, 511, 512, 514, 516, 524, 525 ) THEN SUBSTR(COMM.COMMERCIALID, 1,18)
              WHEN ARR.PRODUCTCODE in (527,528,529) THEN OV.ARRNR
              WHEN ARR.PRODUCTCODE in (140, 141, 142, 143) THEN AR_BBAN_IBAN.BBAN
              ELSE COMM.COMMERCIALID
          END                     AS HA_CMRCL_NBR
      ,  CASE WHEN  BBAN.BBAN IS NOT NULL THEN BBAN.BBAN
              WHEN  ARR.CATEGORYCODE = 22 THEN LTRIM ( SUBSTR(COMM.COMMERCIALID,9,10) , '0')
              WHEN  AR_BBAN_IBAN.BBAN IS NOT NULL THEN AR_BBAN_IBAN.BBAN
              WHEN ARR.PRODUCTCODE  BETWEEN 71 and 79 THEN COMM.COMMERCIALID
              WHEN ARR.PRODUCTCODE  in (82,178)       THEN COMM.COMMERCIALID
              ELSE NULL
              END               AS HA_BBAN_NBR
      ,  CASE WHEN IBAN.IBAN IS NOT NULL THEN IBAN.IBAN
              WHEN ARR.CATEGORYCODE = 22 THEN COMM.COMMERCIALID
              WHEN AR_BBAN_IBAN.IBAN is NOT NULL THEN AR_BBAN_IBAN.IBAN
              ELSE NULL
              END               AS HA_IBAN_NBR
      ,  CASE WHEN
(substr(upper(ARR.ARRANGEMENTHEADING), 1,5) = 'ERVEN'
OR
  substr(upper(ARR.ARRANGEMENTHEADING), 1,8) = 'DE ERVEN'
OR
  upper(ARR.ARRANGEMENTHEADING) like '% -ERVEN%'
OR
  upper(ARR.ARRANGEMENTHEADING) like '%?-ERVEN%'
OR
  upper(ARR.ARRANGEMENTHEADING) like '%Â¬-ERVEN%'
OR
  upper(ARR.ARRANGEMENTHEADING) like '%?ERVEN%'
OR
  upper(ARR.ARRANGEMENTHEADING) like '%Â¬ERVEN%'
OR
  upper(ARR.ARRANGEMENTHEADING) like '%REK ERVEN%'
OR
  upper(ARR.ARRANGEMENTHEADING) like '%REKENING ERVEN%'
OR
  upper(ARR.ARRANGEMENTHEADING) like '%ERVENREK%'
OR
(upper(ARR.ARRANGEMENTHEADING) like '%ERVEN%' and    upper(ARR.ARRANGEMENTHEADING) like '%BENEF%')
OR
  (upper(ARR.ARRANGEMENTHEADING) like '%ERVEN%' and    upper(ARR.ARRANGEMENTHEADING) like '%BEWIN%')
OR
  (upper(ARR.ARRANGEMENTHEADING) like '%ERVEN%' and    upper(ARR.ARRANGEMENTHEADING) like '%DE GEZAM%')
OR
  (upper(ARR.ARRANGEMENTHEADING) like '%ERVEN%' and    upper(ARR.ARRANGEMENTHEADING) like '%GEV%')
OR
  (upper(ARR.ARRANGEMENTHEADING) like '%ERVEN%' and    upper(ARR.ARRANGEMENTHEADING) like '%GEMACHTIGDE%')
OR
  (upper(ARR.ARRANGEMENTHEADING) like '%ERVEN%' and    upper(ARR.ARRANGEMENTHEADING) like '%GEZ%')
OR
  (upper(ARR.ARRANGEMENTHEADING) like '%ERVEN%' and    upper(ARR.ARRANGEMENTHEADING) like '%INZ%')
OR
  (upper(ARR.ARRANGEMENTHEADING) like '%ERVEN%' and    upper(ARR.ARRANGEMENTHEADING) like '%KINDE%')
OR
  (upper(ARR.ARRANGEMENTHEADING) like '%ERVEN%' and    upper(ARR.ARRANGEMENTHEADING) like '%TBV%')
OR
upper(ARR.ARRANGEMENTHEADING) like '%ERFGE%'
OR
upper(ARR.ARRANGEMENTHEADING) like '%EXEC%'
OR
upper(ARR.ARRANGEMENTHEADING) like '%NALATENSCHAP%') THEN 'Y'
WHEN  ARR.PRODUCTCODE in (20,21,22,23,24)  THEN 'N'
ELSE NULL
END                 as HA_INH_IND
 , CASE WHEN ARRANGEMENTHEADING LIKE '%JIVE%' and ARRANGEMENTHEADING LIKE '%ING%'  THEN 'Y'
        WHEN  UPPER(ARRANGEMENTHEADING) LIKE '%PJIVE%' THEN 'Y'
        WHEN  UPPER(ARRANGEMENTHEADING) LIKE '%ZJIVE%' THEN 'Y'
   WHEN  ARR.PRODUCTCODE in (20,21,22,23,24)  THEN 'N'
ELSE NULL
 END as HA_JIVE_IND
,  ARR.DEL_IN_SRC_STM_IND As HA_DEL_IND
FROM
(SELECT UUID_SRC as ARRUUID ,PRODUCTCODE, PRODUCTNAME, CATEGORYCODE, CATEGORYNAME,
  TO_DATE(TO_CHAR(ARRANGEMENTEXECUTES, 'YYYY-MM-DD'),'YYYY-MM-DD') as OpenDate,
  TO_DATE(TO_CHAR(ARRANGEMENTENDED, 'YYYY-MM-DD'),'YYYY-MM-DD') as EndedDate,
ARRANGEMENTHEADING, STATUSCODE, STATUSNAME, CURRENCYCODE, CURRENCYNAME, ACCESSTOKEN,DEL_IN_SRC_STM_IND
 FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGMNTS_V__SL_CIM_CUSTOMER_INFO_XU_VW
  WHERE VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
)  ARR
LEFT OUTER JOIN (SELECT  UUID_SRC             as ARRUUID
                       , ARRANGEMENTKEYID_SRC as BBAN
                 FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__SL_CIM_CUSTOMER_INFO_XU_VW
                 WHERE ARRANGEMENTKEYCODE = 5
                 AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                 ) BBAN
ON ARR.ARRUUID = BBAN.ARRUUID
LEFT OUTER JOIN (SELECT  UUID_SRC             as ARRUUID
                       , ARRANGEMENTKEYID_SRC as IBAN
                 FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__SL_CIM_CUSTOMER_INFO_XU_VW
                 WHERE ARRANGEMENTKEYCODE = 4
                 AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                ) IBAN
ON ARR.ARRUUID = IBAN.ARRUUID
LEFT OUTER JOIN (SELECT  UUID_SRC             as ARRUUID
                       , ARRANGEMENTKEYID_SRC as COMMERCIALID
                 FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__SL_CIM_CUSTOMER_INFO_XU_VW
                 WHERE ARRANGEMENTKEYCODE = 3
                 AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                 ) COMM
ON ARR.ARRUUID = COMM.ARRUUID
LEFT OUTER JOIN (SELECT  UUID_SRC             as ARRUUID
                       , ARRANGEMENTKEYID_SRC as ARRNR
                 FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__SL_CIM_CUSTOMER_INFO_XU_VW
                 WHERE ARRANGEMENTKEYCODE  not in (3,4,5,14,80,87)
                 AND VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                 ) OV
ON ARR.ARRUUID = OV.ARRUUID
LEFT OUTER JOIN (
                 SELECT ARRUUID, min(BBAN) BBAN, min(IBAN) IBAN
                 FROM
                   (SELECT    UUIDFROM as ARRUUID
                            , UUIDTO
                    FROM  IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRTOARR_M__SL_CIM_CUSTOMER_INFO_XU_VW
                    WHERE VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                    AND RELATIONENDED IS NULL
                   )  ARRTOARR
                 JOIN
                      (SELECT    UUID_SRC
                               , ARRANGEMENTKEYID_SRC BBAN
                       FROM  IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__SL_CIM_CUSTOMER_INFO_XU_VW
                       WHERE VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                       AND ARRANGEMENTKEYCODE = 5
                       ) KEY
                 ON ARRTOARR.UUIDTO = KEY.UUID_SRC
                  JOIN
                      (SELECT    UUID_SRC
                               , ARRANGEMENTKEYID_SRC IBAN
                       FROM  IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__SL_CIM_CUSTOMER_INFO_XU_VW
                       WHERE VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                       AND ARRANGEMENTKEYCODE = 4
                       ) KEY_IBAN
                 ON ARRTOARR.UUIDTO = KEY_IBAN.UUID_SRC
                JOIN
                     (SELECT  UUID_SRC
                      FROM  IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGMNTS_V__SL_CIM_CUSTOMER_INFO_XU_VW
                      WHERE  VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
                      AND PRODUCTCODE not in  (452, 900, 920)
                      AND CATEGORYCODE not in (31, 42)
                     ) ARR
                ON ARRTOARR.ARRUUID = ARR.UUID_SRC
                GROUP BY ARRUUID
              ) AR_BBAN_IBAN
ON ARR.ARRUUID = AR_BBAN_IBAN.ARRUUID;"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_PD_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_PD_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT PD.CL_ID AS TA_SRC_ROW_ID,
PD.MSTR_SRC_STM_CD || '.' || PD.EXTCODE AS TA_KEY,
PD.EXTCODE AS HA_PD_CD,
PD.NAME AS HA_PD_NM,
PD.CATEGORYCODE AS HA_PD_CGY_CD,
PD.CATEGORYNAME AS HA_PD_CGY_NM,
PD.EXPIRYDATE AS HA_EXP_DT,
CAST(standard_hash(
nvl((PD.MSTR_SRC_STM_CD || '.' || PD.EXTCODE ) , CHR(0))
 || ';'
 ||nvl(PD.EXTCODE , CHR(0))
 || ';'
 ||nvl(PD.NAME , CHR(0))
 || ';'
 ||nvl(PD.CATEGORYCODE , CHR(0))
 || ';'
 ||nvl(PD.CATEGORYNAME , CHR(0))
 ||';'
 || PD.EXPIRYDATE  , 'MD5') AS CHAR(32)) AS ta_hash_val
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_CL_LOV_PRODTP_V__SL_CIM_CUSTOMER_INFO_XU_VW
 PD
WHERE
PD.VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND PD.CATEGORYCODE <> '43';"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_SEG_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_SEG_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_EXP_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT SEG.CL_ID AS TA_SRC_ROW_ID,
 ((((SEG.MSTR_SRC_STM_CD || '.') || SEG.EXTCODE) || '.') || SEG.CATEGORYCODE) AS TA_KEY,
 SEG.EXTCODE AS HA_SEG_CD,
 SEG."NAME" AS HA_SEG_NM,
 SEG.CATEGORYCODE AS HA_SEG_CGY_CD,
 SEG.CATEGORYNAME AS HA_SEG_CGY_NM,
 SEG.EXPIRYDATE AS HA_EXP_DT,
 CAST(standard_hash(
  NVL(((((SEG.MSTR_SRC_STM_CD || '.') || SEG.EXTCODE) || '.') || SEG.CATEGORYCODE),CHR(0))
  ||';'
  || NVL(SEG.EXTCODE,CHR(0))
  ||';'
  || NVL(SEG."NAME",CHR(0))
  ||';'
  || NVL(SEG.CATEGORYCODE,CHR(0))
  ||';'
  || NVL(SEG.CATEGORYNAME,CHR(0))
  ||';'
  || SEG.EXPIRYDATE
  ,'MD5') AS CHAR(32)) TA_HASH_VAL
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_CL_LOV_GRP_EXT_CAT_V__SL_CIM_CUSTOMER_INFO_XU_VW SEG
WHERE (SEG.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_CTRY_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_CTRY_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    CNTRY.CL_ID  AS TA_SRC_ROW_ID,
    CNTRY.MSTR_SRC_STM_CD || '.' ||CNTRY.CODE AS TA_KEY,
    CNTRY.CODE  AS HA_CTRY_CD,
    CNTRY."NAME" AS HA_CTRY_NM,
    CNTRY.ISOCODE  AS HA_ISO_CD,
    CNTRY.EXPIRYDATE AS HA_EXP_DT,
    CAST(STANDARD_HASH(NVL((CNTRY.MSTR_SRC_STM_CD || '.' ||CNTRY.CODE), CHR(0))
                       || ';'
                       || NVL(CNTRY.CODE, CHR(0))
                       || ';'
                       || NVL(CNTRY.NAME, CHR(0))
                       || ';'
                       || NVL(CNTRY.ISOCODE, CHR(0))
                       || ';'
                       || CNTRY.EXPIRYDATE, 'MD5') AS CHAR(32)) AS TA_HASH_VAL
FROM
    IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_CL_LOV_COUNTRYTP_V__SL_CIM_CUSTOMER_INFO_XU_VW CNTRY
WHERE
    CNTRY.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS');"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_INACTIVES_DEDUP_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_IP_INACTIVES_DEDUP_VW" ("IP_ID", "CA_END_TMS", "PREFERENCE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT A.IP_ID,
NVL(C.CA_END_DT,A.CA_END_TMS) As CA_END_TMS,
A.PREFERENCE
FROM ((SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_INACTIVES A
JOIN (
SELECT SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_INACTIVES.IP_ID, MIN(SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_INACTIVES.PREFERENCE) AS PREFERENCE
FROM SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_INACTIVES
GROUP BY SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_INACTIVES.IP_ID) B ON (((A.IP_ID = B.IP_ID)
AND (A.PREFERENCE = B.PREFERENCE))))
LEFT JOIN SL_CIM_SLT_OWNER.CIM_SLT_D7_IP C ON ((((C.TA_SRC_ROW_ID = A.IP_ID)
AND C.TA_VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND C.CA_END_DT  IS NOT NULL))));"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_SBI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_SBI_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_SBI_CD", "HA_SBI_NM", "HA_EXP_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SBI.CL_ID   AS TA_SRC_ROW_ID,
    SBI.MSTR_SRC_STM_CD || '.' || SBI.CODE   AS TA_KEY,
    SBI.CODE                                 AS HA_SBI_CD,
    SBI."NAME"                               AS HA_SBI_NM,
    SBI.EXPIRYDATE                           AS HA_EXP_DT,
    CAST(STANDARD_HASH(
         nvl((SBI.MSTR_SRC_STM_CD || '.' || SBI.CODE) ,CHR(0) )
         || ';'
         || nvl(SBI.CODE ,CHR(0) )
         || ';'
         || nvl(SBI."NAME" ,CHR(0) )
         || ';'
         || SBI.EXPIRYDATE ,'MD5') AS CHAR(32) ) AS  TA_HASH_VAL
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_CL_LOV_V__SL_CIM_CUSTOMER_INFO_XU_VW SBI
WHERE SBI.LOVNAME = 'EXT_CDSBITP'
AND SBI.VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS');"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_CCY_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_CCY_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EXP_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT CURR.CL_ID AS TA_SRC_ROW_ID,
 ((CURR.MSTR_SRC_STM_CD || '.') || CURR.CODE) AS TA_KEY,
 CURR.CODE AS HA_CCY_CD,
 CURR."NAME" AS HA_CCY_NM,
 CURR.ISOCODE AS HA_ISO_CD,
 CURR.EXPIRYDATE AS HA_EXP_DT,
 CAST(standard_hash(
NVL((CURR.MSTR_SRC_STM_CD || '.'|| CURR.CODE),CHR(0))
||';'
|| CAST(CURR.CODE AS NUMBER(19))
||';'
|| NVL(CURR."NAME",CHR(0))
||';'
|| NVL(CURR.ISOCODE,CHR(0))
||';'
|| CURR.EXPIRYDATE ,'MD5') AS CHAR(32)) TA_HASH_VAL
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_CL_LOV_CURRENCYTP_V__SL_CIM_CUSTOMER_INFO_XU_VW CURR
WHERE (CURR.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'));"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_AR_ST_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_AR_ST_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_AR_ST_CD", "HA_AR_ST_NM", "HA_AR_ST_CGY_CD", "HA_AR_ST_CGY_NM", "HA_EXP_DT", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    AR_ST.CL_ID                               AS TA_SRC_ROW_ID,
    AR_ST.MSTR_SRC_STM_CD || '.'|| AR_ST.CODE AS TA_KEY,
    AR_ST.CODE                                AS HA_AR_ST_CD,
    AR_ST."NAME"                              AS HA_AR_ST_NM,
    AR_ST.CATEGORYCODE                        AS HA_AR_ST_CGY_CD,
    AR_ST.CATEGORYNAME                        AS HA_AR_ST_CGY_NM,
    AR_ST.EXPIRYDATE                          AS HA_EXP_DT,
    CAST(STANDARD_HASH(
          nvl((AR_ST.MSTR_SRC_STM_CD || '.'|| AR_ST.CODE) ,CHR(0) )
          || ';'
          || CAST(AR_ST.CODE AS NUMBER(19) )
          || ';'
          || nvl(AR_ST."NAME" ,CHR(0) )
          || ';'
          || CAST(AR_ST.CATEGORYCODE AS NUMBER(19) )
          || ';'
          || nvl(AR_ST.CATEGORYNAME ,CHR(0) )
          || ';'
          || AR_ST.EXPIRYDATE ,'MD5') AS CHAR(32) ) AS  TA_HASH_VAL
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_CL_LOV_V__SL_CIM_CUSTOMER_INFO_XU_VW AR_ST
WHERE AR_ST.VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND AR_ST.LOVNAME = 'CDCONTRACTSTTP';"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_IP_VW" ("TA_SRC_ROW_ID", "TA_KEY", "HA_IP_TP_IND", "HA_IP_TP_CD", "HA_BRTH_DT", "HA_DCSD_DT", "HA_GND_IND", "HA_BRTH_DT_QLY_CD", "HA_BRTH_CITY_NM", "HA_BRTH_CTRY_CD", "HA_RSDNT_CTRY_CD", "HA_UUID_CD", "HA_IP_NBR", "HA_GRID_NBR", "CA_COLLAPSED_IND", "CA_COLLAPSED_DT", "CA_COLLAPSED_TO_IP_NBR", "HA_PRIV_PREF_CD", "HA_MGN_ENT_CD", "HA_KVK_NBR", "HA_TRD_NM", "HA_FORMAL_NM", "HA_PREF_LANG_CD", "HA_ESTB_DT", "HA_LGL_FORM_CD", "HA_SBI_TP_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_STRT_DT", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "CA_TEL_NBR", "CA_EMAIL_ADR", "CA_SEG_CD", "CA_SEG_CGY_CD", "CA_CRSP_NM", "TA_HASH_VAL_HA", "TA_HASH_VAL_CA") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP.IP_ID AS TA_SRC_ROW_ID,
IP.MSTR_SRC_STM_CD||'.'||IP.MSTR_SRC_STM_KEY AS TA_KEY,
COMNFLDS.HA_IP_TP_IND AS HA_IP_TP_IND,
COMNFLDS.HA_IP_TP_CD AS HA_IP_TP_CD,
INDIVDEMOGR.BORNDATEDATE AS HA_BRTH_DT,
INDIVDEMOGR.DECEASEDDATE AS HA_DCSD_DT,
INDIVDEMOGR.GENDER AS HA_GND_IND,
INDIVDEMOGR.BORNDATEQUALITYCODE AS HA_BRTH_DT_QLY_CD,
INDIVDEMOGR.BORNCITY AS HA_BRTH_CITY_NM,
INDIVDEMOGR.BORNCOUNTRYCODE AS HA_BRTH_CTRY_CD,
INDIVDEMOGR.RESIDENTCOUNTRYCODE AS HA_RSDNT_CTRY_CD,
PKEYUUID.PARTYKEYID_SRC AS HA_UUID_CD,
IP.MSTR_SRC_STM_KEY AS HA_IP_NBR,
PKEYGRID.PARTYKEYID_SRC AS HA_GRID_NBR,
PKEYCOLL.COLLAPSED_IND AS CA_COLLAPSED_IND,
PKEYCOLL.COLLAPSED_DT AS CA_COLLAPSED_DT,
PKEYCOLL.COLLAPSEDTO_PARTYID_SRC AS CA_COLLAPSED_TO_IP_NBR,
PRIVPREF.PRIVPREFVALUECODE AS HA_PRIV_PREF_CD,
PMANENT.MANAGINGENTITYVALUE AS HA_MGN_ENT_CD,
PIDENT.IDENTIFIERVALUE AS HA_KVK_NBR,
ORGNAM_TRD.VALUE AS HA_TRD_NM,
ORGNAM_FRM.VALUE AS HA_FORMAL_NM,
CASE WHEN PKEY.PARTYTYPE='O' THEN ORGDEM.PREFERREDLANGUAGECODE
	 WHEN PKEY.PARTYTYPE='P' THEN INDIVDEMOGR.PREFERREDLANGUAGECODE
	 ELSE NULL END AS HA_PREF_LANG_CD,
ORGDEM.ESTABLISHEDDATE AS HA_ESTB_DT,
ORGDEM.LEGALFORMCODE AS HA_LGL_FORM_CD,
ORGDEM.SBITYPECODE AS HA_SBI_TP_CD,
PPADDR.ADDRESSPOSTALCODE AS HA_ZIP_CD,
COMNFLDS.HA_LE_CD AS HA_LE_CD,
CASE WHEN PKEY.PARTYTYPE='P' THEN INDIVDEMOGR.STARTED
	WHEN PKEY.PARTYTYPE='O' THEN ORGDEM.STARTED
	ELSE NULL END AS HA_STRT_DT,
CASE WHEN PKEY.PARTYTYPE='O' AND ORGNAM_TRD.VALUE LIKE '%ZJIVE%' THEN 'Y'
	 WHEN PKEY.PARTYTYPE='O' THEN 'N'
	 WHEN PKEY.PARTYTYPE='P' AND PINAMPA.INITIALS IN ('PJIVE', 'ZJIVE') OR (PINAMPA.INITIALS LIKE 'PJIVE%' AND PINAMPA.LASTNAME LIKE '%PJIVE%') OR (PINAMPA.INITIALS = 'JIVE' AND (UPPER(PINAMPA.LASTNAME)  LIKE '%ING%' OR  UPPER(PINAMPA.LASTNAME)  LIKE 'PJIVE%' OR UPPER(PINAMPA.LASTNAME) LIKE '%JIVE%')) THEN 'Y'
	 WHEN PKEY.PARTYTYPE='P' THEN 'N'
	 ELSE NULL END AS HA_JIVE_IND,
HA_WWFT_CMPLN_IND,
IPINACTIVES.CA_END_TMS AS CA_END_DT,
CASE WHEN PRFL_CCNT.PRIVPREFTYPECODE = 2 THEN 'Y' WHEN PRFL_CCNT.PRIVPREFTYPECODE = 1 THEN 'N' END AS CA_PRFL_CCNT_IND,
CASE WHEN RGHT_TO_OBJ.PRIVPREFTYPECODE = 2 THEN 'Y' WHEN RGHT_TO_OBJ.PRIVPREFTYPECODE = 1 THEN 'N' END AS CA_RGHT_TO_OBJ_IND,
SUBSTR(TRIM(PPADDR.ADDRESSSTREETNAME),1,50) AS HA_STR_NM,
PPADDR.ADDRESSCITY AS HA_CTY_NM,
SUBSTR(TRIM(PPADDR.ADDRESSRESIDENCENUMBER),1,10) AS HA_BLD_NBR,
PPADDR.ADDRESSRESIDENCENUMBERADDITION AS HA_UNIT_NBR,
SUBSTR(TRIM(PINAMPA.INITIALS),1,10) AS HA_INIT_NM,
SUBSTR(TRIM(PINAMPA.PREPOSITIONNAME),1,20) AS HA_PREPSTN_NM,
SUBSTR(TRIM(PINAMPA.LASTNAME),1,50) AS HA_LST_NM,
SUBSTR(TRIM(CSI.PARTYKEYID_SRC),1,20) AS HA_CSI_NBR,
SUBSTR(TRIM(ING_ID_BE.PARTYKEYID_SRC),1,20) AS HA_BE_NBR,
NVL(COMNFLDS.HA_DEL_IND,'Y') AS HA_DEL_IND,
SUBSTR(TRIM(NVL(MOBILE.CONTACTMETHODVALUE,LANDLINE.CONTACTMETHODVALUE)),1,20) AS CA_TEL_NBR,
CASE PKEY.PARTYTYPE
WHEN 'P' THEN SUBSTR(TRIM(PERSEMAIL.CONTACTMETHODVALUE),1,100)
WHEN 'O' THEN SUBSTR(TRIM(BUSEMAIL.CONTACTMETHODVALUE),1,100) END AS CA_EMAIL_ADR,
SEG.SEGMENTVALUECODE AS CA_SEG_CD,
SEG.SEGMENTVALUECATEGORYCODE AS CA_SEG_CGY_CD,
SUBSTR(TRIM(FORMNA.LASTNAME),1,50) AS CA_CRSP_NM,
CAST(STANDARD_HASH(
NVL(IP.MSTR_SRC_STM_CD,CHR(0)) ||'.'||
NVL(IP.MSTR_SRC_STM_KEY,CHR(0)) ||';'||
NVL(COMNFLDS.HA_IP_TP_IND,CHR(0)) ||';'||
COMNFLDS.HA_IP_TP_CD ||';'||
INDIVDEMOGR.BORNDATEDATE ||';'||
INDIVDEMOGR.DECEASEDDATE  ||';'||
NVL(INDIVDEMOGR.GENDER,CHR(0)) ||';'||
INDIVDEMOGR.BORNDATEQUALITYCODE ||';'||
NVL(INDIVDEMOGR.BORNCITY,CHR(0)) ||';'||
BORNCOUNTRYCODE ||';'||
RESIDENTCOUNTRYCODE ||';'||
NVL(PKEYUUID.PARTYKEYID_SRC,CHR(0)) ||';'||
NVL(PKEYGRID.PARTYKEYID_SRC,CHR(0)) ||';'||
PRIVPREF.PRIVPREFVALUECODE ||';'||
NVL(PMANENT.MANAGINGENTITYVALUE,CHR(0)) ||';'||
NVL(PIDENT.IDENTIFIERVALUE,CHR(0)) ||';'||
NVL(ORGNAM_TRD.VALUE,CHR(0)) ||';'||
NVL(ORGNAM_FRM.VALUE,CHR(0)) ||';'||
CASE WHEN PKEY.PARTYTYPE='O' THEN ORGDEM.PREFERREDLANGUAGECODE
	 WHEN PKEY.PARTYTYPE='P' THEN INDIVDEMOGR.PREFERREDLANGUAGECODE
	 ELSE NULL END ||';'||
TO_DATE(TO_CHAR(ORGDEM.ESTABLISHEDDATE, 'YYYY-MM-DD'),'YYYY-MM-DD') ||';'||
ORGDEM.LEGALFORMCODE ||';'||
NVL(ORGDEM.SBITYPECODE,CHR(0)) ||';'||
NVL(PPADDR.ADDRESSPOSTALCODE,CHR(0)) ||';'||
NVL(COMNFLDS.HA_LE_CD,CHR(0)) ||';'||
CASE WHEN PKEY.PARTYTYPE='P' THEN INDIVDEMOGR.STARTED
	WHEN PKEY.PARTYTYPE='O' THEN  ORGDEM.STARTED
	ELSE NULL END ||';'||
NVL((CASE WHEN PKEY.PARTYTYPE='O' AND ORGNAM_TRD.VALUE LIKE '%ZJIVE%' THEN 'Y'
		  WHEN PKEY.PARTYTYPE='O' THEN 'N'
		  WHEN PKEY.PARTYTYPE='P' AND PINAMPA.INITIALS IN ('PJIVE', 'ZJIVE') OR (PINAMPA.INITIALS LIKE 'PJIVE%' AND PINAMPA.LASTNAME LIKE '%PJIVE%') OR (PINAMPA.INITIALS = 'JIVE' AND (UPPER(PINAMPA.LASTNAME)  LIKE '%ING%' OR  UPPER(PINAMPA.LASTNAME)  LIKE 'PJIVE%' OR UPPER(PINAMPA.LASTNAME) LIKE '%JIVE%')) THEN 'Y'
		  WHEN PKEY.PARTYTYPE='P' THEN 'N'
		  ELSE NULL END),CHR(0)) ||';'||
NVL(HA_WWFT_CMPLN_IND,CHR(0)) ||';'||
NVL(SUBSTR(TRIM(PPADDR.ADDRESSSTREETNAME),1,50),CHR(0)) ||';'||
NVL(PPADDR.ADDRESSCITY,CHR(0)) ||';'||
NVL(SUBSTR(TRIM(PPADDR.ADDRESSRESIDENCENUMBER),1,10),CHR(0)) ||';'||
NVL(PPADDR.ADDRESSRESIDENCENUMBERADDITION,CHR(0)) ||';'||
NVL(SUBSTR(TRIM(PINAMPA.INITIALS),1,10),CHR(0)) ||';'||
NVL(SUBSTR(TRIM(PINAMPA.PREPOSITIONNAME),1,20),CHR(0)) ||';'||
NVL(SUBSTR(TRIM(PINAMPA.LASTNAME),1,50),CHR(0)) ||';'||
NVL(SUBSTR(TRIM(CSI.PARTYKEYID_SRC),1,20),CHR(0)) ||';'||
NVL(SUBSTR(TRIM(ING_ID_BE.PARTYKEYID_SRC),1,20),CHR(0)) ||';' ||
NVL(NVL(COMNFLDS.HA_DEL_IND,'Y'),CHR(0))  , 'MD5') AS CHAR(32))  AS TA_HASH_VAL_HA,
CAST (STANDARD_HASH(
NVL(IP.MSTR_SRC_STM_CD,CHR(0)) ||'.'||
NVL(IP.MSTR_SRC_STM_KEY,CHR(0)) ||';'||
NVL(PKEYCOLL.COLLAPSED_IND,CHR(0)) ||';'||
TO_DATE(TO_CHAR(PKEYCOLL.COLLAPSED_DT, 'YYYY-MM-DD'),'YYYY-MM-DD') ||';'||
NVL(PKEYCOLL.COLLAPSEDTO_PARTYID_SRC,CHR(0)) ||';'||
TO_DATE(TO_CHAR(IPINACTIVES.CA_END_TMS, 'YYYY-MM-DD'),'YYYY-MM-DD') ||';'||
NVL(CASE WHEN PRFL_CCNT.PRIVPREFTYPECODE = 2 THEN 'Y' WHEN PRFL_CCNT.PRIVPREFTYPECODE = 1 THEN 'N' END,CHR(0)) ||';'||
NVL(CASE WHEN RGHT_TO_OBJ.PRIVPREFTYPECODE = 2 THEN 'Y' WHEN RGHT_TO_OBJ.PRIVPREFTYPECODE = 1 THEN 'N' END,CHR(0)) ||';'||
NVL(SUBSTR(TRIM(NVL(MOBILE.CONTACTMETHODVALUE,LANDLINE.CONTACTMETHODVALUE)),1,20),CHR(0)) ||';'||
NVL(CASE PKEY.PARTYTYPE
WHEN 'P' THEN SUBSTR(TRIM(PERSEMAIL.CONTACTMETHODVALUE),1,100)
WHEN 'O' THEN SUBSTR(TRIM(BUSEMAIL.CONTACTMETHODVALUE),1,100) END,CHR(0)) ||';'||
NVL(SEG.SEGMENTVALUECODE,CHR(0)) ||';'||
NVL(SEG.SEGMENTVALUECATEGORYCODE,CHR(0)) ||';'||
NVL(SUBSTR(TRIM(FORMNA.LASTNAME),1,50),CHR(0)) , 'MD5') AS CHAR(32))  AS TA_HASH_VAL_CA
FROM
IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_IP_K__SL_CIM_CUSTOMER_INFO_XU_VW  IP
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PARTYKEY_V__SL_CIM_CUSTOMER_INFO_XU_VW PKEY ON IP.IP_ID=PKEY.IP_ID AND PKEY.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PIDEMOGR_V__SL_CIM_CUSTOMER_INFO_XU_VW  INDIVDEMOGR ON IP.IP_ID=INDIVDEMOGR.IP_ID AND INDIVDEMOGR.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PARTYKEY_GRID_V__SL_CIM_CUSTOMER_INFO_XU_VW  PKEYGRID ON IP.IP_ID=PKEYGRID.IP_ID AND PKEYGRID.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND PKEYGRID.PARTYKEYTYPECODE IN (21,22, 23)
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PARTYKEY_V_COLL__SL_CIM_CUSTOMER_INFO_XU_VW PKEYCOLL ON IP.IP_ID=PKEYCOLL.IP_ID AND PKEYCOLL.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PRIVPREF_V__SL_CIM_CUSTOMER_INFO_XU_VW  PRIVPREF ON IP.IP_ID=PRIVPREF.IP_ID AND PRIVPREF.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PMANAENT_V__SL_CIM_CUSTOMER_INFO_XU_VW  PMANENT ON IP.IP_ID=PMANENT.IP_ID AND PMANENT.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PIDENTIF_M__SL_CIM_CUSTOMER_INFO_XU_VW  PIDENT ON IP.IP_ID=PIDENT.IP_ID AND PIDENT.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND PIDENT.IDENTIFIERTYPECODE = '28'
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGANAME_M__SL_CIM_CUSTOMER_INFO_XU_VW  ORGNAM_TRD ON IP.IP_ID=ORGNAM_TRD.IP_ID AND ORGNAM_TRD.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND ORGNAM_TRD.TYPECODE = 2
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGANAME_M__SL_CIM_CUSTOMER_INFO_XU_VW  ORGNAM_FRM ON IP.IP_ID=ORGNAM_FRM.IP_ID AND ORGNAM_FRM.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND ORGNAM_FRM.TYPECODE = 1
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGADEMO_V__SL_CIM_CUSTOMER_INFO_XU_VW  ORGDEM ON IP.IP_ID=ORGDEM.IP_ID AND ORGDEM.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PPADDRES_M__SL_CIM_CUSTOMER_INFO_XU_VW  PPADDR ON IP.IP_ID=PPADDR.IP_ID AND PPADDR.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND PPADDR.LOCATIONGROUPTYPECODE  = (CASE WHEN PPADDR.PARTYTYPE = 'P' THEN  1
																				WHEN PPADDR.PARTYTYPE = 'O' THEN 3 END)
LEFT OUTER JOIN (SELECT PARTYID_SRC,PARTYID_IP_ID AS IP_ID,
ROW_NUMBER() OVER(PARTITION BY PARTYID_SRC ORDER BY LEGALCOMPLIANCESTARTED DESC, VLD_FROM_TMS DESC) RN,
CASE WHEN UPPER(INDICATIONNOTCOMPLIANT)='FALSE' THEN 'Y' ELSE 'N' END AS HA_WWFT_CMPLN_IND
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_EV_LGLCOMP_V__SL_CIM_CUSTOMER_INFO_XU_VW
WHERE LEGALCOMPLIANCETYPECODE=1
AND VLD_TO_TMS= TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'))  LEGCOMP
ON IP.IP_ID=LEGCOMP.IP_ID AND LEGCOMP.RN = 1
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PINAMEPA_V__SL_CIM_CUSTOMER_INFO_XU_VW  PINAMPA ON IP.IP_ID=PINAMPA.IP_ID AND PINAMPA.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PARTYKEY_UUID_V__SL_CIM_CUSTOMER_INFO_XU_VW  PKEYUUID ON IP.IP_ID=PKEYUUID.IP_ID AND PKEYUUID.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN (
(SELECT TA_SRC_ROW_ID AS IP_ID, NULL AS CA_END_TMS
  FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP
  WHERE TA_VLD_TO_TMS= TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
  AND CA_END_DT IS NOT NULL
MINUS
SELECT IP_ID, NULL AS CA_END_TMS
  FROM SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_INACTIVES_DEDUP_VW) -- RE-ACTIVE IPS
UNION
SELECT IP_ID, CA_END_TMS FROM SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_INACTIVES_DEDUP_VW )  IPINACTIVES -- INACTIVES PLUS RE-ACTIVES
ON IP.IP_ID=IPINACTIVES.IP_ID
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PRIVPREF_PRIVACY_M__SL_CIM_CUSTOMER_INFO_XU_VW  RGHT_TO_OBJ ON IP.IP_ID = RGHT_TO_OBJ.IP_ID AND RGHT_TO_OBJ.PRIVPREFVALUECATEGORYCODE = 6 AND RGHT_TO_OBJ.PRIVPREFVALUECODE = 22 AND RGHT_TO_OBJ.VLD_TO_TMS =TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PRIVPREF_PRIVACY_M__SL_CIM_CUSTOMER_INFO_XU_VW  PRFL_CCNT ON IP.IP_ID = PRFL_CCNT.IP_ID AND PRFL_CCNT.PRIVPREFVALUECATEGORYCODE = 6 AND PRFL_CCNT.PRIVPREFVALUECODE = 21 AND PRFL_CCNT.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_CONTMETH_M__SL_CIM_CUSTOMER_INFO_XU_VW  LANDLINE ON IP.IP_ID = LANDLINE.IP_ID AND LANDLINE.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND LANDLINE.CONTACTMETHODTYPECODE=1
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_CONTMETH_M__SL_CIM_CUSTOMER_INFO_XU_VW  MOBILE ON IP.IP_ID = MOBILE.IP_ID AND MOBILE.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND MOBILE.CONTACTMETHODTYPECODE=2
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_CONTMETH_M__SL_CIM_CUSTOMER_INFO_XU_VW  PERSEMAIL ON IP.IP_ID = PERSEMAIL.IP_ID AND PERSEMAIL.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND PERSEMAIL.CONTACTMETHODTYPECODE=7
LEFT OUTER JOIN (SELECT PARTYID_CLP_IP_ID,PARTYID_SRC_CLP,CONTACTMETHODVALUE,ROW_NUMBER() OVER(PARTITION BY PARTYID_SRC_CLP ORDER BY LOCATIONGROUPSTARTED DESC) AS RNUM FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_RPLCON_CONTMTHD_M__SL_CIM_CUSTOMER_INFO_XU_VW WHERE VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND CONTACTMETHODTYPECODE=8) BUSEMAIL ON IP.IP_ID = BUSEMAIL.PARTYID_CLP_IP_ID AND BUSEMAIL.RNUM=1
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PPSEGMEN_V__SL_CIM_CUSTOMER_INFO_XU_VW  SEG ON IP.IP_ID = SEG.IP_ID AND SEG.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PARTYKEY_BE_M__SL_CIM_CUSTOMER_INFO_XU_VW  CSI ON IP.IP_ID = CSI.IP_ID AND CSI.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND CSI.PARTYKEYTYPECODE = 41
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PIFORMNA_M__SL_CIM_CUSTOMER_INFO_XU_VW  FORMNA ON IP.IP_ID = FORMNA.IP_ID AND FORMNA.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND FORMNA.NAMEUSAGETYPE = 5
LEFT OUTER JOIN IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PARTYKEY_BE_M__SL_CIM_CUSTOMER_INFO_XU_VW  ING_ID_BE ON IP.IP_ID = ING_ID_BE.IP_ID AND ING_ID_BE.VLD_TO_TMS=TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') AND ING_ID_BE.PARTYKEYTYPECODE = 48
LEFT OUTER JOIN SL_CIM_PRP_OWNER.CIM_PRP_D7_IP_COMMON_FIELDS COMNFLDS ON IP.MSTR_SRC_STM_KEY = COMNFLDS.HA_IP_NBR;"
/* <sc-view> SL_CIM_PRP_OWNER.CIM_PRP_D7_AR_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_PRP_OWNER"."CIM_PRP_D7_AR_VW" ("TA_KEY", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "TA_HASH_VAL") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT TA_KEY
      ,  HA_OPN_DT
      ,  HA_END_DT
      ,  HA_ST_CD
      ,  HA_CCY_CD
      ,  HA_PD_CD
      ,  HA_LE_CD
      ,  HA_AR_NBR
      ,  HA_CMRCL_NBR
      ,  HA_BBAN_NBR
      ,  HA_IBAN_NBR
      ,  HA_INH_IND
      ,  HA_JIVE_IND
	  ,  HA_DEL_IND
      ,  TA_HASH_VAL
FROM (
SELECT
         TA_KEY
      ,  HA_OPN_DT
      ,  HA_END_DT
      ,  HA_ST_CD
      ,  HA_CCY_CD
      ,  HA_PD_CD
      ,  HA_LE_CD
      ,  HA_AR_NBR
      ,  HA_CMRCL_NBR
      ,  HA_BBAN_NBR
      ,  HA_IBAN_NBR
      ,  HA_INH_IND
      ,  HA_JIVE_IND
	  ,  HA_DEL_IND
      ,  CAST(standard_hash(
        NVL(TA_KEY,CHR(0))
		|| ';'
		|| HA_OPN_DT
		|| ';'
		|| HA_END_DT
		|| ';'
		|| HA_ST_CD
		|| ';'
		|| HA_CCY_CD
		|| ';'
		|| HA_PD_CD
		|| ';'
		|| NVL(HA_LE_CD,CHR(0))
		|| ';'
		|| NVL(HA_AR_NBR,CHR(0))
		|| ';'
		|| NVL(HA_CMRCL_NBR,CHR(0))
		|| ';'
		|| NVL(HA_BBAN_NBR,CHR(0))
		|| ';'
		|| NVL(HA_IBAN_NBR,CHR(0))
		|| ';'
		|| NVL(HA_INH_IND,CHR(0))
		|| ';'
		|| NVL(HA_JIVE_IND,CHR(0))
		|| ';'
		|| NVL(HA_DEL_IND,CHR(0)) ,'MD5') AS CHAR(32)) TA_HASH_VAL
        , ROW_NUMBER() OVER (PARTITION BY TA_KEY ORDER BY NVL(HA_END_DT, TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) desc, HA_OPN_DT desc, HA_DEL_IND asc)
        ROWNUM1
FROM
      SL_CIM_PRP_OWNER.CIM_PRP_D7_AR_NOHASH_VW )   A
WHERE ROWNUM1 = 1
AND TA_KEY is not null;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D2_MGN_ENT__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D2_MGN_ENT__DM_SAL_SALESFORCE_XU_VW" ("D2_IP_ME_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_MGN_ENT_TP_CD", "HA_MGN_ENT_TP_NM", "HA_MGN_ENT_CD", "HA_MGN_ENT_STRT_TMS", "HA_MGN_ENT_END_TMS", "HA_IP_TP_IND", "HA_IP_NBR", "HA_LE_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT D2_IP_ME_ID, TA_KEY, TA_SRC_ROW_ID, TA_VLD_FROM_TMS, TA_VLD_TO_TMS, TA_PCS_ISRT_ID, TA_PCS_UDT_ID, TA_ISRT_TMS, TA_UDT_TMS, HA_MGN_ENT_TP_CD, HA_MGN_ENT_TP_NM, HA_MGN_ENT_CD, HA_MGN_ENT_STRT_TMS, HA_MGN_ENT_END_TMS, HA_IP_TP_IND, HA_IP_NBR, HA_LE_CD FROM SL_CIM_SLV_OWNER.CIM_SLV_D2_MGN_ENT_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_CIM_AR__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_CIM_AR__DM_SAL_SALESFORCE_XU_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT AR.S1_AR_ID, AR.S2_AR_ID, AR.TA_KEY, AR.TA_SRC_ROW_ID, AR.TA_HASH_VAL, AR.TA_VLD_FROM_TMS, AR.TA_VLD_TO_TMS, AR.TA_PCS_ISRT_ID, AR.TA_PCS_UDT_ID, AR.TA_ISRT_TMS, AR.TA_UDT_TMS, AR.CA_CID_NBR, AR.TA_CRN_IND, AR.HA_OPN_DT, AR.HA_END_DT, AR.HA_ST_CD, AR.HA_CCY_CD, AR.HA_PD_CD, AR.HA_LE_CD, AR.HA_AR_NBR, AR.HA_CMRCL_NBR, AR.HA_BBAN_NBR, AR.HA_IBAN_NBR, AR.HA_INH_IND, AR.HA_JIVE_IND, AR.HA_DEL_IND FROM SL_CIM_SLV_OWNER.CIM_SLV_D7_AR_VW AR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_CIM_CCY__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_CIM_CCY__DM_SAL_SALESFORCE_XU_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT S1_CCY_ID, S2_CCY_ID, TA_KEY, TA_SRC_ROW_ID, TA_HASH_VAL, TA_VLD_FROM_TMS, TA_VLD_TO_TMS, TA_PCS_ISRT_ID, TA_PCS_UDT_ID, TA_ISRT_TMS, TA_UDT_TMS, TA_CRN_IND, HA_CCY_CD, HA_CCY_NM, HA_ISO_CD, HA_EXP_DT FROM SL_CIM_SLV_OWNER.CIM_SLV_D7_CCY_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_CIM_CTRY__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_CIM_CTRY__DM_SAL_SALESFORCE_XU_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT S1_CTRY_ID, S2_CTRY_ID, TA_KEY, TA_SRC_ROW_ID, TA_HASH_VAL, TA_VLD_FROM_TMS, TA_VLD_TO_TMS, TA_PCS_ISRT_ID, TA_PCS_UDT_ID, TA_ISRT_TMS, TA_UDT_TMS, TA_CRN_IND, HA_CTRY_CD, HA_CTRY_NM, HA_ISO_CD, HA_EXP_DT FROM SL_CIM_SLV_OWNER.CIM_SLV_D7_CTRY_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_CIM_IP__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_CIM_IP__DM_SAL_SALESFORCE_XU_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_STR_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_CTY_NM", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_SBI_TP_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_UUID_CD", "HA_BRTH_CITY_NM", "CA_TEL_NBR", "CA_EMAIL_ADR", "HA_FORMAL_NM", "HA_TRD_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "CA_COLLAPSED_TO_IP_NBR", "CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "CA_SEG_CD", "HA_SEG_NM", "CA_CRSP_NM", "CA_SEG_CGY_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT IP_VW.S1_IP_ID, IP_VW.S2_IP_ID, IP_VW.TA_KEY, IP_VW.TA_SRC_ROW_ID, IP_VW.TA_VLD_FROM_TMS, IP_VW.TA_VLD_TO_TMS, IP_VW.TA_PCS_ISRT_ID, IP_VW.TA_PCS_UDT_ID, IP_VW.TA_ISRT_TMS, IP_VW.TA_UDT_TMS, IP_VW.TA_HASH_VAL_CA, IP_VW.TA_HASH_VAL_HA, IP_VW.TA_CRN_IND, IP_VW.HA_GRID_NBR, IP_VW.HA_IP_NBR, IP_VW.HA_KVK_NBR, IP_VW.HA_INIT_NM, IP_VW.HA_PREPSTN_NM, IP_VW.HA_LST_NM, IP_VW.HA_BRTH_DT, IP_VW.HA_DCSD_DT, IP_VW.HA_ESTB_DT, IP_VW.HA_STRT_DT, IP_VW.HA_BRTH_CTRY_CD, IP_VW.HA_STR_NM, IP_VW.HA_BLD_NBR, IP_VW.HA_UNIT_NBR, IP_VW.HA_CTY_NM, IP_VW.HA_BRTH_DT_QLY_CD, IP_VW.HA_IP_TP_CD, IP_VW.HA_LGL_FORM_CD, IP_VW.HA_MGN_ENT_CD, IP_VW.HA_PREF_LANG_CD, IP_VW.HA_PRIV_PREF_CD, IP_VW.HA_RSDNT_CTRY_CD, CTRY.HA_CTRY_NM, CTRY.HA_ISO_CD, IP_VW.HA_SBI_TP_CD, IP_VW.HA_ZIP_CD, IP_VW.HA_LE_CD, IP_VW.HA_UUID_CD, IP_VW.HA_BRTH_CITY_NM, IP_VW.CA_TEL_NBR, IP_VW.CA_EMAIL_ADR, IP_VW.HA_FORMAL_NM, IP_VW.HA_TRD_NM, IP_VW.HA_GND_IND, IP_VW.HA_IP_TP_IND, IP_VW.HA_JIVE_IND, IP_VW.HA_WWFT_CMPLN_IND, IP_VW.HA_CSI_NBR, IP_VW.HA_BE_NBR, IP_VW.HA_DEL_IND, IP_VW.CA_COLLAPSED_TO_IP_NBR, IP_VW.CA_COLLAPSED_DT, IP_VW.CA_COLLAPSED_IND, IP_VW.CA_END_DT, IP_VW.CA_PRFL_CCNT_IND, IP_VW.CA_RGHT_TO_OBJ_IND, IP_VW.CA_SEG_CD, SEG.HA_SEG_NM, IP_VW.CA_CRSP_NM, IP_VW.CA_SEG_CGY_CD FROM ((SL_CIM_SLV_OWNER.CIM_SLV_D7_IP_VW IP_VW LEFT JOIN (SELECT SEG.HA_SEG_CD, SEG.HA_SEG_NM, SEG.HA_SEG_CGY_CD FROM SL_CIM_SLV_OWNER.CIM_SLV_D7_SEG_VW SEG WHERE (SEG.TA_VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) GROUP BY SEG.HA_SEG_CD, SEG.HA_SEG_NM, SEG.HA_SEG_CGY_CD) SEG ON (((IP_VW.CA_SEG_CD = SEG.HA_SEG_CD) AND (IP_VW.CA_SEG_CGY_CD = SEG.HA_SEG_CGY_CD)))) LEFT JOIN (SELECT CTR.HA_CTRY_CD, CTR.HA_CTRY_NM, CTR.HA_ISO_CD FROM SL_CIM_SLV_OWNER.CIM_SLV_D7_CTRY_VW CTR WHERE (CTR.TA_VLD_TO_TMS = to_timestamp('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) GROUP BY CTR.HA_CTRY_CD, CTR.HA_CTRY_NM, CTR.HA_ISO_CD) CTRY ON ((IP_VW.HA_RSDNT_CTRY_CD = CTRY.HA_CTRY_CD)));"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_CIM_PD__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_CIM_PD__DM_SAL_SALESFORCE_XU_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT S1_PD_ID, S2_PD_ID, TA_KEY, TA_SRC_ROW_ID, TA_HASH_VAL, TA_VLD_FROM_TMS, TA_VLD_TO_TMS, TA_PCS_ISRT_ID, TA_PCS_UDT_ID, TA_ISRT_TMS, TA_UDT_TMS, TA_CRN_IND, HA_PD_CD, HA_PD_NM, HA_PD_CGY_CD, HA_PD_CGY_NM, HA_EXP_DT FROM SL_CIM_SLV_OWNER.CIM_SLV_D7_PD_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_CIM_SEG_HIST__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_CIM_SEG_HIST__DM_SAL_SALESFORCE_XU_VW" ("S2_SEG_HIST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_HIST_TP_CD", "HA_SEG_HIST_TP_NM", "HA_SEG_HIST_CD", "HA_SEG_HIST_NM", "HA_SEG_HIST_CGY_CD", "HA_SEG_HIST_CGY_NM", "HA_SEG_HIST_STRT_TMS", "HA_SEG_HIST_END_TMS", "HA_IP_TP_IND", "HA_IP_NBR", "HA_LE_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT HIST.S2_SEG_HIST_ID, HIST.TA_KEY, HIST.TA_SRC_ROW_ID, HIST.TA_VLD_FROM_TMS, HIST.TA_VLD_TO_TMS, HIST.TA_PCS_ISRT_ID, HIST.TA_PCS_UDT_ID, HIST.TA_ISRT_TMS, HIST.TA_UDT_TMS, HIST.HA_SEG_HIST_TP_CD, HIST.HA_SEG_HIST_TP_NM, HIST.HA_SEG_HIST_CD, HIST.HA_SEG_HIST_NM, HIST.HA_SEG_HIST_CGY_CD, HIST.HA_SEG_HIST_CGY_NM, HIST.HA_SEG_HIST_STRT_TMS, HIST.HA_SEG_HIST_END_TMS, HIST.HA_IP_TP_IND, HIST.HA_IP_NBR, HIST.HA_LE_CD FROM SL_CIM_SLV_OWNER.CIM_SLV_D7_SEG_HIST_VW HIST;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_CIM_SEG__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_CIM_SEG__DM_SAL_SALESFORCE_XU_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT S1_SEG_ID, S2_SEG_ID, TA_KEY, TA_SRC_ROW_ID, TA_HASH_VAL, TA_VLD_FROM_TMS, TA_VLD_TO_TMS, TA_PCS_ISRT_ID, TA_PCS_UDT_ID, TA_ISRT_TMS, TA_UDT_TMS, TA_CRN_IND, HA_SEG_CD, HA_SEG_NM, HA_SEG_CGY_CD, HA_SEG_CGY_NM, HA_EXP_DT FROM SL_CIM_SLV_OWNER.CIM_SLV_D7_SEG_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_FP_CIM_PD_PSSN__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_FP_CIM_PD_PSSN__DM_SAL_SALESFORCE_XU_VW" ("SP_PD_PSSN_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "D1_AR_ID", "D2_AR_ID", "D1_PD_ID", "D2_PD_ID", "D1_IP_ID", "D2_IP_ID", "D1_HLDR_ID", "D1_DT_ID", "D1_CCY_ID", "D2_CCY_ID", "D1_SEG_ID", "D2_SEG_ID", "FA_LE_CD", "AM_NBR", "NM_AGE_NBR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT SP_PD_PSSN_ID, TA_KEY, TA_SRC_ROW_ID, TA_PCS_ISRT_ID, TA_ISRT_TMS, D1_AR_ID, D2_AR_ID, D1_PD_ID, D2_PD_ID, D1_IP_ID, D2_IP_ID, D1_HLDR_ID, D1_DT_ID, D1_CCY_ID, D2_CCY_ID, D1_SEG_ID, D2_SEG_ID, FA_LE_CD, AM_NBR, NM_AGE_NBR FROM SL_CIM_SLV_OWNER.CIM_SLV_FP_PD_PSSN_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D1_DT_VW__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D1_DT_VW__DM_FDS_FINREP_NL_VW" ("S1_DT_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_PCS_ISRT_ID", "TA_PCS_LAST_UDT_ID", "TA_PCS_ISRT_TMS", "TA_PCS_LAST_UDT_TMS", "CA_DT", "CA_DAY_SHRT_NL_NM", "CA_DAY_SHRT_EN_NM", "CA_DAY_NL_NM", "CA_DAY_EN_NM", "CA_DAY_IN_WK_NR", "CA_DAY_IN_MO_NR", "CA_DAY_IN_QTR_NR", "CA_DAY_IN_ISO_QTR_NR", "CA_DAY_IN_YR_NR", "CA_DAY_HOL_IND", "CA_DAY_HOL_NL_NM", "CA_DAY_HOL_EN_NM", "CA_DAY_WEEKEND_IND", "CA_DAY_TARGETDAY_IND", "CA_ISO_WK_NR", "CA_ISO_WK_FIRST_DAY_DT", "CA_ISO_WK_LAST_DAY_DT", "CA_MO_NR", "CA_MO_FIRST_DAY_DT", "CA_MO_LAST_DAY_DT", "CA_MO_NUM_OF_DAYS_CNT", "CA_MO_SHRT_NL_NM", "CA_MO_NL_NM", "CA_MO_EN_NM", "CA_QTR_NR", "CA_QTR_FIRST_DAY_DT", "CA_QTR_LAST_DAY_DT", "CA_QTR_NUM_OF_DAYS_CNT", "CA_ISO_QTR_NR", "CA_ISO_QTR_FIRST_DAY_DT", "CA_ISO_QTR_LAST_DAY_DT", "CA_ISO_QTR_NUM_DAYS_CNT", "CA_YR_NR", "CA_YR_FIRST_DAY_DT", "CA_YR_LAST_DAY_DT", "CA_YR_LEAP_YR_IND", "CA_YR_NUM_OF_DAYS_CNT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  (((SELECT DATE_ID AS S1_DT_ID,
		 1 AS TA_KEY,
		 1 AS TA_SRC_ROW_ID,
		 1 AS TA_HASH_VAL,
		 1 AS TA_PCS_ISRT_ID,
		 1 AS TA_PCS_LAST_UDT_ID,
		 '2018-01-01 00:00:00' AS TA_PCS_ISRT_TMS,
		 NULL AS TA_PCS_LAST_UDT_TMS,
		 DAY_DT AS CA_DT,
		 DAY_SHORT_NL_NM AS CA_DAY_SHRT_NL_NM,
		 DAY_SHORT_EN_NM AS CA_DAY_SHRT_EN_NM,
		 DAY_LONG_NL_NM AS CA_DAY_NL_NM,
		 DAY_LONG_EN_NM AS CA_DAY_EN_NM,
		 DAY_DAY_WEEK_NR AS CA_DAY_IN_WK_NR,
		 DAY_IN_MONTH_NR AS CA_DAY_IN_MO_NR,
		 DAY_IN_QUARTER_NR AS CA_DAY_IN_QTR_NR,
		 DAY_IN_QUARTER_ISO AS CA_DAY_IN_ISO_QTR_NR,
		 DAY_IN_YEAR_NR AS CA_DAY_IN_YR_NR,
		 DAY_HOLIDAY_IND AS CA_DAY_HOL_IND,
		 DAY_HOLIDAY_NL_NM AS CA_DAY_HOL_NL_NM,
		 DAY_HOLIDAY_EN_NM AS CA_DAY_HOL_EN_NM,
		 DAY_WEEKEND_IND AS CA_DAY_WEEKEND_IND,
		 DAY_TARGET_DAY_IND AS CA_DAY_TARGETDAY_IND,
		 WEEK_ISO_CODE AS CA_ISO_WK_NR,
		 WEEK_ISO_FIRST_DAY_DT AS CA_ISO_WK_FIRST_DAY_DT,
		 WEEK_ISO_LAST_DAY_DT AS CA_ISO_WK_LAST_DAY_DT,
		 MON_NR AS CA_MO_NR,
		 MON_FIRST_DAY_DT AS CA_MO_FIRST_DAY_DT,
		 MON_LAST_DAY_DT AS CA_MO_LAST_DAY_DT,
		 MON_NUM_OF_DAYS AS CA_MO_NUM_OF_DAYS_CNT,
		 MON_SHORT_NL_DES AS CA_MO_SHRT_NL_NM,
		 MON_NL_NM AS CA_MO_NL_NM,
		 MON_EN_NM AS CA_MO_EN_NM,
		 QTR_NR AS CA_QTR_NR,
		 QTR_FIRST_DAY_DT AS CA_QTR_FIRST_DAY_DT,
		 QTR_LAST_DAY_DT AS CA_QTR_LAST_DAY_DT,
		 QTR_NUM_OF_DAYS_CNT AS CA_QTR_NUM_OF_DAYS_CNT,
		 QTR_ISO_NR AS CA_ISO_QTR_NR,
		 QTR_ISO_FIRST_DAY_DT AS CA_ISO_QTR_FIRST_DAY_DT,
		 QTR_ISO_LAST_DAY_DT AS CA_ISO_QTR_LAST_DAY_DT,
		 QTR_ISO_NUM_DAYS_CNT AS CA_ISO_QTR_NUM_DAYS_CNT,
		 YEAR_NR AS CA_YR_NR,
		 YEAR_FIRST_DAY_DT AS CA_YR_FIRST_DAY_DT,
		 YEAR_LAST_DAY_DT AS CA_YR_LAST_DAY_DT,
		 YEAR_LEAP_YEAR_IND AS CA_YR_LEAP_YR_IND,
		 YEAR_NUM_OF_DAYS_CNT AS CA_YR_NUM_OF_DAYS_CNT
	FROM CCL_CAS_OWNER.CALENDAR)
UNION (SELECT
		-1 AS S1_ST_ID,
		 1 AS TA_KEY,
		 1 AS TA_SRC_ROW_ID,
		 1 AS TA_HASH_VAL,
		 1 AS TA_PCS_ISRT_ID,
		 1 AS TA_PCS_LAST_UDT_ID,
		 '2018-01-01 00:00:00' AS TA_PCS_ISRT_TMS,
		 NULL AS TA_PCS_LAST_UDT_TMS,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_DT,
		 'Onbekend' AS CA_DAY_SHRT_NL_NM,
		 'Unknown' AS CA_DAY_SHRT_EN_NM,
		 'Onbekend' AS CA_DAY_NL_NM,
		 'Unknown' AS CA_DAY_EN_NM,
		 -1 AS CA_DAY_IN_WK_NR,
		 -1 AS CA_DAY_IN_MO_NR,
		 -1 AS CA_DAY_IN_QTR_NR,
		 -1 AS CA_DAY_IN_ISO_QTR_NR,
		 -1 AS CA_DAY_IN_YR_NR,
		 'X' AS CA_DAY_HOL_IND,
		 'Onbekend' CA_DAY_HOL_NL_NM,
		 'Unknown' CA_DAY_HOL_EN_NM,
		 'X' CA_DAY_WEEKEND_IND,
		 'X' CA_DAY_TARGETDAY_IND,
		 -1 AS CA_ISO_WK_NR,
		 to_date('9999-12-31','YYYY-MM-DD')AS CA_ISO_WK_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_WK_LAST_DAY_DT,
		 -1 AS CA_MO_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_MO_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_MO_LAST_DAY_DT,
		 -1 AS CA_MO_NUM_OF_DAYS_CNT,
		 'Onbekend' AS CA_MO_SHRT_NL_NM,
		 'Unknown' AS CA_MO_NL_NM,
		 '-1' AS CA_MO_EN_NM,
		 -1 AS CA_QTR_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_QTR_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_QTR_LAST_DAY_DT,
		 -1 AS CA_QTR_NUM_OF_DAYS_CNT,
		 -1 AS CA_ISO_QTR_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_QTR_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_QTR_LAST_DAY_DT,
		 -1 AS CA_ISO_QTR_NUM_DAYS_CNT,
		 -1 AS CA_YR_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_YR_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_YR_LAST_DAY_DT,
		 'X' AS CA_YR_LEAP_YR_IND,
		 -1 AS CA_YR_NUM_OF_DAYS_CNT FROM DUAL))
UNION (SELECT -2 AS S1_ST_ID,
		 1 AS TA_KEY,
		 1 AS TA_SRC_ROW_ID,
		 1 AS TA_HASH_VAL,
		 1 AS TA_PCS_ISRT_ID,
		 1 AS TA_PCS_LAST_UDT_ID,
		 '2018-01-01 00:00:00' AS TA_PCS_ISRT_TMS,
		 NULL AS TA_PCS_LAST_UDT_TMS,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_DT,
		 'Leeg' AS CA_DAY_SHRT_NL_NM,
		 'Empty' AS CA_DAY_SHRT_EN_NM,
		 'Leeg' AS CA_DAY_NL_NM,
		 'Empty' AS CA_DAY_EN_NM,
		 -2 AS CA_DAY_IN_WK_NR,
		 -2 AS CA_DAY_IN_MO_NR,
		 -2 AS CA_DAY_IN_QTR_NR,
		 -2 AS CA_DAY_IN_ISO_QTR_NR,
		 -2 AS CA_DAY_IN_YR_NR,
		 'X' AS CA_DAY_HOL_IND,
		 'Empty' AS CA_DAY_HOL_NL_NM,
		 'NULL' AS CA_DAY_HOL_EN_NM,
		 'X' AS CA_DAY_WEEKEND_IND,
		 'X' AS CA_DAY_TARGETDAY_IND,
		 -2 AS CA_ISO_WK_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_WK_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_WK_LAST_DAY_DT,
		 -2 AS CA_MO_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_MO_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_MO_LAST_DAY_DT,
		 -2 AS CA_MO_NUM_OF_DAYS_CNT,
		 'Leeg' AS CA_MO_SHRT_NL_NM,
		 'Empty' AS CA_MO_NL_NM,
		 '-2' AS CA_MO_EN_NM,
		 -2 AS CA_QTR_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_QTR_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_QTR_LAST_DAY_DT,
		 -2 AS CA_QTR_NUM_OF_DAYS_CNT,
		 -2 AS CA_ISO_QTR_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_QTR_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_QTR_LAST_DAY_DT,
		 -2 AS CA_ISO_QTR_NUM_DAYS_CNT,
		 -2 AS CA_YR_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_YR_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_YR_LAST_DAY_DT,
		 'X' AS CA_YR_LEAP_YR_IND,
		 -2 AS CA_YR_NUM_OF_DAYS_CNT FROM DUAL))
UNION (	SELECT -3 AS S1_ST_ID,
		 1 AS TA_KEY,
		 1 AS TA_SRC_ROW_ID,
		 1 AS TA_HASH_VAL,
		 1 AS TA_PCS_ISRT_ID,
		 1 AS TA_PCS_LAST_UDT_ID,
		 '2018-01-01 00:00:00' AS TA_PCS_ISRT_TMS,
		 NULL AS TA_PCS_LAST_UDT_TMS,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_DT,
		 'N.v.t.' AS CA_DAY_SHRT_NL_NM,
		 'N.a.' AS CA_DAY_SHRT_EN_NM,
		 'N.v.t.' AS CA_DAY_NL_NM,
		 'N.a.' AS CA_DAY_EN_NM,
		 -3 AS CA_DAY_IN_WK_NR,
		 -3 AS CA_DAY_IN_MO_NR,
		 -3 AS CA_DAY_IN_QTR_NR,
		 -3 AS CA_DAY_IN_ISO_QTR_NR,
		 -3 AS CA_DAY_IN_YR_NR,
		 'X' AS CA_DAY_HOL_IND,
		 'N.v.t.' AS CA_DAY_HOL_NL_NM,
		 'N.a.' AS CA_DAY_HOL_EN_NM,
		 'X' AS CA_DAY_WEEKEND_IND,
		 'X' AS CA_DAY_TARGETDAY_IND,
		 -3 AS CA_ISO_WK_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_WK_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_WK_LAST_DAY_DT,
		 -3 AS CA_MO_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_MO_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_MO_LAST_DAY_DT,
		 -3 AS CA_MO_NUM_OF_DAYS_CNT,
		 'N.v.t.' AS CA_MO_SHRT_NL_NM,
		 'N.a.' AS CA_MO_NL_NM,
		 '-3' AS CA_MO_EN_NM,
		 -3 AS CA_QTR_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_QTR_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_QTR_LAST_DAY_DT,
		 -3 AS CA_QTR_NUM_OF_DAYS_CNT,
		 -3 AS CA_ISO_QTR_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_QTR_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_ISO_QTR_LAST_DAY_DT,
		 -3 AS CA_ISO_QTR_NUM_DAYS_CNT,
		 -3 AS CA_YR_NR,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_YR_FIRST_DAY_DT,
		 to_date('9999-12-31','YYYY-MM-DD') AS CA_YR_LAST_DAY_DT,
		 'X' AS CA_YR_LEAP_YR_IND,
		 -3 AS CA_YR_NUM_OF_DAYS_CNT FROM DUAL);"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_PD_VW__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_PD_VW__DM_FDS_FINREP_NL_VW" ("HA_EXP_DT", "HA_PD_CD", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_PD_NM", "S1_PD_ID", "S2_PD_ID", "TA_CRN_IND", "TA_HASH_VAL", "TA_ISRT_TMS", "TA_KEY", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_SRC_ROW_ID", "TA_UDT_TMS", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	  HA_EXP_DT
	, HA_PD_CD
	, HA_PD_CGY_CD
	, HA_PD_CGY_NM
	, HA_PD_NM
	, S1_PD_ID
	, S2_PD_ID
	, CASE WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
	, TA_HASH_VAL
	, TA_ISRT_TMS
	, TA_KEY
	, TA_PCS_ISRT_ID
	, TA_PCS_UDT_ID
	, TA_SRC_ROW_ID
	, TA_UDT_TMS
	, TA_VLD_FROM_TMS
	, TA_VLD_TO_TMS
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_FP_PD_PSSN_VW__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_FP_PD_PSSN_VW__DM_FDS_FINREP_NL_VW" ("AM_NBR", "D1_AR_ID", "D1_CCY_ID", "D1_DT_ID", "D1_HLDR_ID", "D1_IP_ID", "D1_PD_ID", "D1_SEG_ID", "D2_AR_ID", "D2_CCY_ID", "D2_IP_ID", "D2_PD_ID", "D2_SEG_ID", "FA_LE_CD", "NM_AGE_NBR", "SP_PD_PSSN_ID", "TA_ISRT_TMS", "TA_KEY", "TA_PCS_ISRT_ID", "TA_SRC_ROW_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	  AM_NBR
	, D1_AR_ID
	, D1_CCY_ID
	, D1_DT_ID
	, D1_HLDR_ID
	, D1_IP_ID
	, D1_PD_ID
	, D1_SEG_ID
	, D2_AR_ID
	, D2_CCY_ID
	, D2_IP_ID
	, D2_PD_ID
	, D2_SEG_ID
	, FA_LE_CD
	, NM_AGE_NBR
	, SP_PD_PSSN_ID
	, TA_ISRT_TMS
	, TA_KEY
	, TA_PCS_ISRT_ID
	, TA_SRC_ROW_ID
FROM SL_CIM_SLT_OWNER.CIM_SLT_FP_PD_PSSN;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_IP_VW__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_IP_VW__DM_FDS_FINREP_NL_VW" ("CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_COLLAPSED_TO_IP_NBR", "CA_CRSP_NM", "CA_EMAIL_ADR", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "CA_SEG_CD", "CA_TEL_NBR", "HA_BE_NBR", "HA_BLD_NBR", "HA_BRTH_CITY_NM", "HA_BRTH_CTRY_CD", "HA_BRTH_DT", "HA_BRTH_DT_QLY_CD", "HA_CSI_NBR", "HA_CTY_NM", "HA_DCSD_DT", "HA_ESTB_DT", "HA_FORMAL_NM", "HA_GND_IND", "HA_GRID_NBR", "HA_INIT_NM", "HA_IP_NBR", "HA_IP_TP_CD", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_KVK_NBR", "HA_LE_CD", "HA_LGL_FORM_CD", "HA_LST_NM", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PREPSTN_NM", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_SBI_TP_CD", "HA_STR_NM", "HA_STRT_DT", "HA_TRD_NM", "HA_UNIT_NBR", "HA_UUID_CD", "HA_WWFT_CMPLN_IND", "HA_ZIP_CD", "S1_IP_ID", "S2_IP_ID", "TA_CRN_IND", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "TA_ISRT_TMS", "TA_KEY", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_SRC_ROW_ID", "TA_UDT_TMS", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	CA_COLLAPSED_DT,
	CA_COLLAPSED_IND,
	CA_COLLAPSED_TO_IP_NBR,
	CA_CRSP_NM,
	CA_EMAIL_ADR,
	CA_END_DT,
	CA_PRFL_CCNT_IND,
	CA_RGHT_TO_OBJ_IND,
	CA_SEG_CD,
	CA_TEL_NBR,
	HA_BE_NBR,
	HA_BLD_NBR,
	HA_BRTH_CITY_NM,
	HA_BRTH_CTRY_CD,
	HA_BRTH_DT,
	HA_BRTH_DT_QLY_CD,
	HA_CSI_NBR,
	HA_CTY_NM,
	HA_DCSD_DT,
	HA_ESTB_DT,
	HA_FORMAL_NM,
	HA_GND_IND,
	HA_GRID_NBR,
	HA_INIT_NM,
	HA_IP_NBR,
	HA_IP_TP_CD,
	HA_IP_TP_IND,
	HA_JIVE_IND,
	HA_KVK_NBR,
	HA_LE_CD,
	HA_LGL_FORM_CD,
	HA_LST_NM,
	HA_MGN_ENT_CD,
	HA_PREF_LANG_CD,
	HA_PREPSTN_NM,
	HA_PRIV_PREF_CD,
	HA_RSDNT_CTRY_CD,
	HA_SBI_TP_CD,
	HA_STR_NM,
	HA_STRT_DT,
	HA_TRD_NM,
	HA_UNIT_NBR,
	HA_UUID_CD,
	HA_WWFT_CMPLN_IND,
	HA_ZIP_CD,
	S1_IP_ID,
	S2_IP_ID,
	CASE WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
	TA_HASH_VAL_CA,
	TA_HASH_VAL_HA,
	TA_ISRT_TMS,
	TA_KEY,
	TA_PCS_ISRT_ID,
	TA_PCS_UDT_ID,
	TA_SRC_ROW_ID,
	TA_UDT_TMS,
	TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_SEG_VW__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_SEG_VW__DM_FDS_FINREP_NL_VW" ("HA_EXP_DT", "HA_SEG_CD", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_SEG_NM", "S1_SEG_ID", "S2_SEG_ID", "TA_CRN_IND", "TA_HASH_VAL", "TA_ISRT_TMS", "TA_KEY", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_SRC_ROW_ID", "TA_UDT_TMS", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	  HA_EXP_DT
	, HA_SEG_CD
	, HA_SEG_CGY_CD
	, HA_SEG_CGY_NM
	, HA_SEG_NM
	, S1_SEG_ID
	, S2_SEG_ID
	, CASE WHEN (CIM_SLT_D7_SEG.TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
	, TA_HASH_VAL
	, TA_ISRT_TMS
	, TA_KEY
	, TA_PCS_ISRT_ID
	, TA_PCS_UDT_ID
	, TA_SRC_ROW_ID
	, TA_UDT_TMS
	, TA_VLD_FROM_TMS
	, TA_VLD_TO_TMS
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_CCY_VW__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_CCY_VW__DM_FDS_FINREP_NL_VW" ("HA_CCY_CD", "HA_CCY_NM", "HA_EXP_DT", "HA_ISO_CD", "S1_CCY_ID", "S2_CCY_ID", "TA_CRN_IND", "TA_HASH_VAL", "TA_ISRT_TMS", "TA_KEY", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_SRC_ROW_ID", "TA_UDT_TMS", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	  HA_CCY_CD
	, HA_CCY_NM
	, HA_EXP_DT
	, HA_ISO_CD
	, S1_CCY_ID
	, S2_CCY_ID
	, CASE WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
	, TA_HASH_VAL
	, TA_ISRT_TMS
	, TA_KEY
	, TA_PCS_ISRT_ID
	, TA_PCS_UDT_ID
	, TA_SRC_ROW_ID
	, TA_UDT_TMS
	, TA_VLD_FROM_TMS
	, TA_VLD_TO_TMS
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_X_IP_S_VW__DM_CAN_CUSTANA_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_X_IP_S_VW__DM_CAN_CUSTANA_NL_VW" ("IP_X_IP_S_ID", "IP_1_S_ID", "IP_2_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "DEL_IN_SRC_STM_F", "IP_1_GRNTEE_UUID", "GRNTE_RL_TYP", "GRNTEE_EFFECTIVEDATE", "GRNTEE_ENDDATE", "IP_2_GRNTOR_UUID", "GRNTR_RL_TYP", "GRNTOR_EFFECTIVEDATE", "GRNTOR_ENDDATE", "IP_REL_UUID", "IP_IP_RELSHP_TYP", "REL_EFFECTIVEDATE", "REL_ENDDATE", "INGENTITY", "ACCESSTOKEN", "MIX_IND_TP", "OPRL_LCSR_TYP", "OPRL_LCS_TYP", "IP_X_IP_RLTNP_PPS_TP") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_X_IP_S_ID, IP_1_S_ID, IP_2_S_ID, SRC_STM_KEY, VLD_FROM_TMS, VLD_TO_TMS, ISRT_JOB_RUN_ID, UDT_JOB_RUN_ID, ISRT_TMS, UDT_TMS, HASH_VAL, DEL_IN_SRC_STM_F, IP_1_GRNTEE_UUID, GRNTE_RL_TYP, GRNTEE_EFFECTIVEDATE, GRNTEE_ENDDATE, IP_2_GRNTOR_UUID, GRNTR_RL_TYP, GRNTOR_EFFECTIVEDATE, GRNTOR_ENDDATE, IP_REL_UUID, IP_IP_RELSHP_TYP, REL_EFFECTIVEDATE, REL_ENDDATE, INGENTITY, ACCESSTOKEN, MIX_IND_TP, OPRL_LCSR_TYP, OPRL_LCS_TYP, IP_X_IP_RLTNP_PPS_TP
FROM SL_CIM_SLV_OWNER.CIM_ILV_IP_X_IP_S_VW
WHERE ACCESSTOKEN IN ('ING_NL','ING_NL_SHARED', 'ING_BE', 'ING_BE_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_S_VW__DM_CAN_CUSTANA_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_S_VW__DM_CAN_CUSTANA_NL_VW" ("IP_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "GRID_NBR", "IP_NBR", "KVK_NBR", "DATEOFBIRTH", "DATEOFDEATH", "DATEOFFOUNDATION", "STARTED", "CTRY_OF_BIRTH", "DOB_QLY_IND", "LEGAL_FORM", "MGM_ENT_CODE", "LNG_PREFERRED", "IP_PREF_TYP", "CTRY_OF_RESIDENCE", "ACCESSTOKEN", "CITYOFBIRTH", "ORGANISATIONNAME", "GNDR", "IP_TYPE_IND", "JIVE_IND", "DEDUPED_TO_IP_NBR", "DEDUPED_TO_IP_UUID", "DEDUPINVOLVEDPARTYDATEINACTIVATED", "DEDUPED_IND", "ENDDATE", "PRFL_CCNT_IND", "RGHT_TO_OBJ_IND", "IP_UUID", "NAMEINITIALS", "LASTNAMEPREFIX", "LASTNAME", "SEV_SEGM", "INDIVIDUALNAMEVALUE", "CSI_NBR", "BE_NBR", "DEL_IN_SRC_STM_F", "SEV_SEGM_CATG", "AGE", "BUSINESSCLOSEDDOWNDATE", "CHANNELOFENTRY", "CTRY_OF_CRSPD", "CTRY_OF_INC", "DATEINACTIVATED", "DCSD_IND", "EMAIL_ADR_BSN", "FINANCIALLEGALSTATUSTYPE", "FIRSTNAME1", "FIRSTNAME2", "FIRSTNAME3", "FIRSTNAME4", "GIVENNAME", "GROUPTYPE", "IP_EFFECTIVEDATE", "IP_ENDDATE", "LC_ST_TP", "LGL_CMPNC_ST_TP", "MINOR_IND", "NICKNAME", "PARTNERLASTNAME", "PARTNERLASTNAMEPREFIX", "SALUTATION", "SECONDLASTNAME", "TEL_NBR_LAND", "TEL_NBR_MBL", "GRID_TYP", "CSI_TYP", "CNTR_PRTY_REL_LCS_TYP", "CNTR_PRTY_REL_LCS_EFF_DT", "CNTR_PRTY_REL_LCS_END_DT", "NL_MING_INBOX") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_S_ID, SRC_STM_KEY, VLD_FROM_TMS, VLD_TO_TMS, ISRT_JOB_RUN_ID, UDT_JOB_RUN_ID, ISRT_TMS, UDT_TMS, HASH_VAL, GRID_NBR, IP_NBR, KVK_NBR, DATEOFBIRTH, DATEOFDEATH, DATEOFFOUNDATION, STARTED, CTRY_OF_BIRTH, DOB_QLY_IND, LEGAL_FORM, MGM_ENT_CODE, LNG_PREFERRED, IP_PREF_TYP, CTRY_OF_RESIDENCE, ACCESSTOKEN, CITYOFBIRTH, ORGANISATIONNAME, GNDR, IP_TYPE_IND, JIVE_IND, DEDUPED_TO_IP_NBR, DEDUPED_TO_IP_UUID, DEDUPINVOLVEDPARTYDATEINACTIVATED, DEDUPED_IND, ENDDATE, PRFL_CCNT_IND, RGHT_TO_OBJ_IND, IP_UUID, NAMEINITIALS, LASTNAMEPREFIX, LASTNAME, SEV_SEGM, INDIVIDUALNAMEVALUE, CSI_NBR, BE_NBR, DEL_IN_SRC_STM_F, SEV_SEGM_CATG, AGE, BUSINESSCLOSEDDOWNDATE, CHANNELOFENTRY, CTRY_OF_CRSPD, CTRY_OF_INC, DATEINACTIVATED, DCSD_IND, EMAIL_ADR_BSN, FINANCIALLEGALSTATUSTYPE, FIRSTNAME1, FIRSTNAME2, FIRSTNAME3, FIRSTNAME4, GIVENNAME, GROUPTYPE, IP_EFFECTIVEDATE, IP_ENDDATE, LC_ST_TP, LGL_CMPNC_ST_TP, MINOR_IND, NICKNAME, PARTNERLASTNAME, PARTNERLASTNAMEPREFIX, SALUTATION, SECONDLASTNAME, TEL_NBR_LAND, TEL_NBR_MBL, GRID_TYP, CSI_TYP, CNTR_PRTY_REL_LCS_TYP, CNTR_PRTY_REL_LCS_EFF_DT, CNTR_PRTY_REL_LCS_END_DT, NL_MING_INBOX
FROM SL_CIM_SLV_OWNER.CIM_ILV_IP_S_VW
WHERE ACCESSTOKEN IN ('ING_NL','ING_NL_SHARED', 'ING_BE', 'ING_BE_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_S_VW__DM_CAN_CUSTANA_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_S_VW__DM_CAN_CUSTANA_NL_VW" ("AR_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "EFFECTIVEDATE", "ENDDATE", "AR_LC_ST_TP", "CUR", "AR_TYP", "ACCESSTOKEN", "CMRCL_NBR", "BBAN_NBR", "IBAN_NBR", "INH_IND", "JIVE_IND", "DEL_IN_SRC_STM_F", "INGENTITY", "NICKNAME", "AR_UUID", "AR_IDNT_TYPE", "AMA_ID", "BE_GRP_ID", "AR_IDNT", "AR_TYP_MAIN", "AR_NBR", "AR_NAME", "CRN_IND", "COUNT_HOLDR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
AR_S_ID, SRC_STM_KEY, HASH_VAL, VLD_FROM_TMS, VLD_TO_TMS, ISRT_JOB_RUN_ID, UDT_JOB_RUN_ID, ISRT_TMS, UDT_TMS, EFFECTIVEDATE, ENDDATE, AR_LC_ST_TP, CUR, AR_TYP, ACCESSTOKEN, CMRCL_NBR, BBAN_NBR, IBAN_NBR, INH_IND, JIVE_IND, DEL_IN_SRC_STM_F, INGENTITY, NICKNAME, AR_UUID, AR_IDNT_TYPE, AMA_ID, BE_GRP_ID, AR_IDNT, AR_TYP_MAIN, AR_NBR, AR_NAME, CRN_IND, COUNT_HOLDR
FROM SL_CIM_SLV_OWNER.CIM_ILV_AR_S_VW
WHERE ACCESSTOKEN IN ('ING_NL','ING_NL_SHARED', 'ING_BE', 'ING_BE_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_X_AR_S_VW__DM_CAN_CUSTANA_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_AR_S_VW__DM_CAN_CUSTANA_NL_VW" ("AR_X_AR_S_ID", "AR_1_S_ID", "AR_2_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "DEL_IN_SRC_STM_F", "AR_1_UUID", "AR_2_UUID", "AR_TYP_MAIN_AR_1", "AR_TYP_AR_1", "AR_TYP_MAIN_AR_2", "AR_TYP_AR_2", "ACCESSTOKEN", "AR_AR_RELSHP_TP", "AR_AR_RELSHP_ST_TYPE", "EFFECTIVEDATE", "ENDDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
AR_X_AR_S_ID, AR_1_S_ID, AR_2_S_ID, SRC_STM_KEY, VLD_FROM_TMS, VLD_TO_TMS, ISRT_JOB_RUN_ID, UDT_JOB_RUN_ID, ISRT_TMS, UDT_TMS, HASH_VAL, DEL_IN_SRC_STM_F, AR_1_UUID, AR_2_UUID, AR_TYP_MAIN_AR_1, AR_TYP_AR_1, AR_TYP_MAIN_AR_2, AR_TYP_AR_2, ACCESSTOKEN, AR_AR_RELSHP_TP, AR_AR_RELSHP_ST_TYPE, EFFECTIVEDATE, ENDDATE
FROM SL_CIM_SLV_OWNER.CIM_ILV_AR_X_AR_S_VW
WHERE ACCESSTOKEN IN ('ING_NL','ING_NL_SHARED', 'ING_BE', 'ING_BE_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_X_IP_S_VW__DM_CAN_CUSTANA_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_IP_S_VW__DM_CAN_CUSTANA_NL_VW" ("AR_X_IP_S_ID", "IP_S_ID", "AR_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "AR_TYP_MAIN", "DEL_IN_SRC_STM_F", "AR_UUID", "IP_UUID", "ACCESSTOKEN", "AGRM_IP_RL_TYP", "OPRL_LCS_TYP", "EFFECTIVEDATE", "ENDDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
AR_X_IP_S_ID, IP_S_ID, AR_S_ID, SRC_STM_KEY, VLD_FROM_TMS, VLD_TO_TMS, ISRT_JOB_RUN_ID, UDT_JOB_RUN_ID, ISRT_TMS, UDT_TMS, HASH_VAL, AR_TYP_MAIN, DEL_IN_SRC_STM_F, AR_UUID, IP_UUID, ACCESSTOKEN, AGRM_IP_RL_TYP, OPRL_LCS_TYP, EFFECTIVEDATE, ENDDATE
FROM SL_CIM_SLV_OWNER.CIM_ILV_AR_X_IP_S_VW
WHERE ACCESSTOKEN IN ('ING_NL','ING_NL_SHARED', 'ING_BE', 'ING_BE_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_GRDM_S_VW__DM_CAN_CUSTANA_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_GRDM_S_VW__DM_CAN_CUSTANA_NL_VW" ("CL_GRDM_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "GRDM_DIST_NM", "GRDM_DSC", "SRC_STM", "SRC_CD", "SRC_DESC", "EFF_DT", "END_DT", "CD", "CD_DESC", "PRNT", "PRNT_DSC", "LVL", "CTG", "CTG_DSC", "STS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
CL_GRDM_S_ID, SRC_STM_KEY, HASH_VAL, VLD_FROM_TMS, VLD_TO_TMS, DEL_IN_SRC_STM_F, ISRT_JOB_RUN_ID, UDT_JOB_RUN_ID, ISRT_TMS, UDT_TMS, GRDM_DIST_NM, GRDM_DSC, SRC_STM, SRC_CD, SRC_DESC, EFF_DT, END_DT, CD, CD_DESC, PRNT, PRNT_DSC, LVL, CTG, CTG_DSC, STS
FROM SL_CIM_SLV_OWNER.CIM_ILV_GRDM_S_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_GRDM_PD_S_VW__DM_CAN_CUSTANA_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_GRDM_PD_S_VW__DM_CAN_CUSTANA_NL_VW" ("CL_PD_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "GRDM_DIST_NM", "GRDM_DSC", "EFF_DT", "END_DT", "CD", "CD_DSC", "PRNT", "PRNT_DSC", "LVL", "EXTND_DSC", "QUAL_AGRM", "PD_CAT", "PD_CAT_DSC", "CBA_PD_GRP", "FATCA_ELIG", "CRS_ELIG", "TAX_RPT", "DGS_RPT", "LWS_LVL", "AR_TYP", "AR_TYP_DSC", "STS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
CL_PD_S_ID, SRC_STM_KEY, HASH_VAL, VLD_FROM_TMS, VLD_TO_TMS, DEL_IN_SRC_STM_F, ISRT_JOB_RUN_ID, UDT_JOB_RUN_ID, ISRT_TMS, UDT_TMS, GRDM_DIST_NM, GRDM_DSC, EFF_DT, END_DT, CD, CD_DSC, PRNT, PRNT_DSC, LVL, EXTND_DSC, QUAL_AGRM, PD_CAT, PD_CAT_DSC, CBA_PD_GRP, FATCA_ELIG, CRS_ELIG, TAX_RPT, DGS_RPT, LWS_LVL, AR_TYP, AR_TYP_DSC, STS
FROM SL_CIM_SLV_OWNER.CIM_ILV_GRDM_PD_S_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_PD__DM_XAM_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_PD__DM_XAM_REPORTING_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	  S1_PD_ID
	, S2_PD_ID
	, TA_KEY
	, TA_SRC_ROW_ID
	, TA_HASH_VAL
	, TA_VLD_FROM_TMS
	, TA_VLD_TO_TMS
	, TA_PCS_ISRT_ID
	, TA_PCS_UDT_ID
	, TA_ISRT_TMS
	, TA_UDT_TMS
	, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
	, HA_PD_CD
	, HA_PD_NM
	, HA_PD_CGY_CD
	, HA_PD_CGY_NM
	, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_CDV_CIM_SLT_D7_PD__DM_CRM_DOD_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_CDV_CIM_SLT_D7_PD__DM_CRM_DOD_NL_VW" ("HA_PD_CD", "TA_CRN_IND", "TA_UDT_TMS", "TA_ISRT_TMS", "TA_SRC_ROW_ID", "TA_HASH_VAL", "S2_PD_ID", "HA_EXP_DT", "HA_PD_CGY_CD", "S1_PD_ID", "TA_KEY", "HA_PD_NM", "TA_PCS_UDT_ID", "TA_VLD_FROM_TMS", "TA_PCS_ISRT_ID", "TA_VLD_TO_TMS", "HA_PD_CGY_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  HA_PD_CD
, CASE
WHEN (TA_VLD_TO_TMS = '31-DEC-99')
THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, TA_UDT_TMS
, TA_ISRT_TMS
, TA_SRC_ROW_ID
, TA_HASH_VAL
, S2_PD_ID
, HA_EXP_DT
, HA_PD_CGY_CD
, S1_PD_ID
, TA_KEY
, HA_PD_NM
, TA_PCS_UDT_ID
, TA_VLD_FROM_TMS
, TA_PCS_ISRT_ID
, TA_VLD_TO_TMS
, HA_PD_CGY_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_CDV_CIM_SLT_D7_AR__DM_CRM_DOD_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_CDV_CIM_SLT_D7_AR__DM_CRM_DOD_NL_VW" ("S2_AR_ID", "TA_PCS_ISRT_ID", "TA_VLD_TO_TMS", "S1_AR_ID", "TA_KEY", "TA_ISRT_TMS", "TA_SRC_ROW_ID", "HA_DEL_IND", "TA_UDT_TMS", "TA_VLD_FROM_TMS", "HA_CMRCL_NBR", "HA_JIVE_IND", "HA_PD_CD", "HA_BBAN_NBR", "TA_CRN_IND", "TA_HASH_VAL", "HA_ST_CD", "HA_LE_CD", "TA_PCS_UDT_ID", "HA_END_DT", "HA_AR_NBR", "HA_IBAN_NBR", "HA_CCY_CD", "HA_OPN_DT", "HA_INH_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S2_AR_ID
, TA_PCS_ISRT_ID
, TA_VLD_TO_TMS
, S1_AR_ID
, TA_KEY
, TA_ISRT_TMS
, TA_SRC_ROW_ID
, HA_DEL_IND
, TA_UDT_TMS
, TA_VLD_FROM_TMS
, HA_CMRCL_NBR
, HA_JIVE_IND
, HA_PD_CD
, HA_BBAN_NBR
, CASE
WHEN (TA_VLD_TO_TMS = '31-DEC-99')
THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, TA_HASH_VAL
, HA_ST_CD
, HA_LE_CD
, TA_PCS_UDT_ID
, HA_END_DT
, HA_AR_NBR
, HA_IBAN_NBR
, HA_CCY_CD
, HA_OPN_DT
--, CA_CID_NBR
, HA_INH_IND
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR__DM_XAM_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR__DM_XAM_REPORTING_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	  S1_AR_ID
	, S2_AR_ID
	, TA_KEY
	, TA_SRC_ROW_ID
	, TA_HASH_VAL
	, TA_VLD_FROM_TMS
	, TA_VLD_TO_TMS
	, TA_PCS_ISRT_ID
	, TA_PCS_UDT_ID
	, TA_ISRT_TMS
	, TA_UDT_TMS
	, A.CA_CID_NBR
	, CASE WHEN (S.TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
	, HA_OPN_DT
	, HA_END_DT
	, HA_ST_CD
	, HA_CCY_CD
	, HA_PD_CD
	, HA_LE_CD
	, HA_AR_NBR
	, HA_CMRCL_NBR
	, HA_BBAN_NBR
	, HA_IBAN_NBR
	, HA_INH_IND
	, HA_JIVE_IND
	, HA_DEL_IND
FROM (SL_CIM_SLT_OWNER.CIM_SLT_D7_AR S LEFT JOIN (SELECT A.ARRANGEMENTKEYID_SRC AS CA_CID_NBR,
A.UUID_SRC FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__DM_KRO_KROV_NL_VW A
WHERE ((A.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) AND (A.ARRANGEMENTKEYCODE = 8))) A ON ((S.TA_KEY = ('MDM.' || A.UUID_SRC))));"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_AR_VW__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_AR_VW__DM_FDS_FINREP_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
     S.S1_AR_ID,
	 S.S2_AR_ID,
	 S.TA_KEY,
	 S.TA_SRC_ROW_ID,
	 S.TA_HASH_VAL,
	 S.TA_VLD_FROM_TMS,
	 S.TA_VLD_TO_TMS,
	 S.TA_PCS_ISRT_ID,
	 S.TA_PCS_UDT_ID,
	 S.TA_ISRT_TMS,
	 S.TA_UDT_TMS,
	 A.CA_CID_NBR,
	 CASE WHEN (S.TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
	 S.HA_OPN_DT,
	 S.HA_END_DT,
	 S.HA_ST_CD,
	 S.HA_CCY_CD,
	 S.HA_PD_CD,
	 S.HA_LE_CD,
	 S.HA_AR_NBR,
	 S.HA_CMRCL_NBR,
	 S.HA_BBAN_NBR,
	 S.HA_IBAN_NBR,
	 S.HA_INH_IND,
	 S.HA_JIVE_IND
FROM (SL_CIM_SLT_OWNER.CIM_SLT_D7_AR S
	LEFT JOIN (SELECT A.ARRANGEMENTKEYID_SRC AS CA_CID_NBR, A.UUID_SRC FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__DM_FDS_FINREP_NL_VW A
	WHERE ((A.VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00')
	AND (A.ARRANGEMENTKEYCODE = 8))) A ON ((S.TA_KEY = ('MDM.'|| A.UUID_SRC))));"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_S_VW__DM_FRM_FCS_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_S_VW__DM_FRM_FCS_MULTI_NL_VW" ("IP_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "GRID_NBR", "IP_NBR", "KVK_NBR", "DATEOFBIRTH", "DATEOFDEATH", "DATEOFFOUNDATION", "STARTED", "CTRY_OF_BIRTH", "DOB_QLY_IND", "LEGAL_FORM", "MGM_ENT_CODE", "LNG_PREFERRED", "IP_PREF_TYP", "CTRY_OF_RESIDENCE", "ACCESSTOKEN", "CITYOFBIRTH", "ORGANISATIONNAME", "GNDR", "IP_TYPE_IND", "JIVE_IND", "DEDUPED_TO_IP_NBR", "DEDUPED_TO_IP_UUID", "DEDUPINVOLVEDPARTYDATEINACTIVATED", "DEDUPED_IND", "ENDDATE", "PRFL_CCNT_IND", "RGHT_TO_OBJ_IND", "IP_UUID", "NAMEINITIALS", "LASTNAMEPREFIX", "LASTNAME", "SEV_SEGM", "INDIVIDUALNAMEVALUE", "CSI_NBR", "BE_NBR", "DEL_IN_SRC_STM_F", "SEV_SEGM_CATG", "AGE", "BUSINESSCLOSEDDOWNDATE", "CHANNELOFENTRY", "CTRY_OF_CRSPD", "CTRY_OF_INC", "DATEINACTIVATED", "DCSD_IND", "EMAIL_ADR_BSN", "FINANCIALLEGALSTATUSTYPE", "FIRSTNAME1", "FIRSTNAME2", "FIRSTNAME3", "FIRSTNAME4", "GIVENNAME", "GROUPTYPE", "IP_EFFECTIVEDATE", "IP_ENDDATE", "LC_ST_TP", "LGL_CMPNC_ST_TP", "MINOR_IND", "NICKNAME", "PARTNERLASTNAME", "PARTNERLASTNAMEPREFIX", "SALUTATION", "SECONDLASTNAME", "TEL_NBR_LAND", "TEL_NBR_MBL", "GRID_TYP", "CSI_TYP", "CNTR_PRTY_REL_LCS_TYP", "CNTR_PRTY_REL_LCS_EFF_DT", "CNTR_PRTY_REL_LCS_END_DT", "NL_MING_INBOX") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ip_s_id,
    src_stm_key,
    vld_from_tms,
    vld_to_tms,
    isrt_job_run_id,
    udt_job_run_id,
    isrt_tms,
    udt_tms,
    hash_val,
    grid_nbr,
    ip_nbr,
    kvk_nbr,
    dateofbirth,
    dateofdeath,
    dateoffoundation,
    started,
    ctry_of_birth,
    dob_qly_ind,
    legal_form,
    mgm_ent_code,
    lng_preferred,
    ip_pref_typ,
    ctry_of_residence,
    accesstoken,
    cityofbirth,
    organisationname,
    gndr,
    ip_type_ind,
    jive_ind,
    deduped_to_ip_nbr,
    deduped_to_ip_uuid,
    dedupinvolvedpartydateinactivated,
    deduped_ind,
    enddate,
    prfl_ccnt_ind,
    rght_to_obj_ind,
    ip_uuid,
    nameinitials,
    lastnameprefix,
    lastname,
    sev_segm,
    individualnamevalue,
    csi_nbr,
    be_nbr,
    del_in_src_stm_f,
    sev_segm_catg,
    age,
    businesscloseddowndate,
    channelofentry,
    ctry_of_crspd,
    ctry_of_inc,
    dateinactivated,
    dcsd_ind,
    email_adr_bsn,
    financiallegalstatustype,
    firstname1,
    firstname2,
    firstname3,
    firstname4,
    givenname,
    grouptype,
    ip_effectivedate,
    ip_enddate,
    lc_st_tp,
    lgl_cmpnc_st_tp,
    minor_ind,
    nickname,
    partnerlastname,
    partnerlastnameprefix,
    salutation,
    secondlastname,
    tel_nbr_land,
    tel_nbr_mbl,
    grid_typ,
    csi_typ,
    cntr_prty_rel_lcs_typ,
    cntr_prty_rel_lcs_eff_dt,
    cntr_prty_rel_lcs_end_dt,
    nl_ming_inbox
FROM
    sl_cim_slv_owner.cim_ilv_ip_s_vw;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_X_AR_S__DM_FRM_FCS_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_AR_S__DM_FRM_FCS_MULTI_NL_VW" ("AR_X_AR_S_ID", "AR_1_S_ID", "AR_2_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "DEL_IN_SRC_STM_F", "AR_1_UUID", "AR_2_UUID", "AR_TYP_MAIN_AR_1", "AR_TYP_AR_1", "AR_TYP_MAIN_AR_2", "AR_TYP_AR_2", "ACCESSTOKEN", "AR_AR_RELSHP_TP", "AR_AR_RELSHP_ST_TYPE", "EFFECTIVEDATE", "ENDDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ar_x_ar_s_id,
    ar_1_s_id,
    ar_2_s_id,
    src_stm_key,
    vld_from_tms,
    vld_to_tms,
    isrt_job_run_id,
    udt_job_run_id,
    isrt_tms,
    udt_tms,
    hash_val,
    del_in_src_stm_f,
    ar_1_uuid,
    ar_2_uuid,
    ar_typ_main_ar_1,
    ar_typ_ar_1,
    ar_typ_main_ar_2,
    ar_typ_ar_2,
    accesstoken,
    ar_ar_relshp_tp,
    ar_ar_relshp_st_type,
    effectivedate,
    enddate
FROM
    sl_cim_slv_owner.cim_ilv_ar_x_ar_s_vw;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_X_IP_S__DM_FRM_FCS_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_IP_S__DM_FRM_FCS_MULTI_NL_VW" ("AR_X_IP_S_ID", "IP_S_ID", "AR_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "AR_TYP_MAIN", "DEL_IN_SRC_STM_F", "AR_UUID", "IP_UUID", "ACCESSTOKEN", "AGRM_IP_RL_TYP", "OPRL_LCS_TYP", "EFFECTIVEDATE", "ENDDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ar_x_ip_s_id,
    ip_s_id,
    ar_s_id,
    src_stm_key,
    vld_from_tms,
    vld_to_tms,
    isrt_job_run_id,
    udt_job_run_id,
    isrt_tms,
    udt_tms,
    hash_val,
    ar_typ_main,
    del_in_src_stm_f,
    ar_uuid,
    ip_uuid,
    accesstoken,
    agrm_ip_rl_typ,
    oprl_lcs_typ,
    effectivedate,
    enddate
FROM
    sl_cim_slv_owner.cim_ilv_ar_x_ip_s_vw;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_S__DM_FRM_FCS_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_S__DM_FRM_FCS_MULTI_NL_VW" ("AR_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "EFFECTIVEDATE", "ENDDATE", "AR_LC_ST_TP", "CUR", "AR_TYP", "ACCESSTOKEN", "CMRCL_NBR", "BBAN_NBR", "IBAN_NBR", "INH_IND", "JIVE_IND", "DEL_IN_SRC_STM_F", "INGENTITY", "NICKNAME", "AR_UUID", "AR_IDNT_TYPE", "AMA_ID", "BE_GRP_ID", "AR_IDNT", "AR_TYP_MAIN", "AR_NBR", "AR_NAME", "CRN_IND", "COUNT_HOLDR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ar_s_id,
    src_stm_key,
    hash_val,
    vld_from_tms,
    vld_to_tms,
    isrt_job_run_id,
    udt_job_run_id,
    isrt_tms,
    udt_tms,
    effectivedate,
    enddate,
    ar_lc_st_tp,
    cur,
    ar_typ,
    accesstoken,
    cmrcl_nbr,
    bban_nbr,
    iban_nbr,
    inh_ind,
    jive_ind,
    del_in_src_stm_f,
    ingentity,
    nickname,
    ar_uuid,
    ar_idnt_type,
    ama_id,
    be_grp_id,
    ar_idnt,
    ar_typ_main,
    ar_nbr,
    ar_name,
    crn_ind,
    count_holdr
FROM
    sl_cim_slv_owner.cim_ilv_ar_s_vw;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_S_VW__DM_CAS_MONITORING_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_S_VW__DM_CAS_MONITORING_VW" ("IP_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "GRID_NBR", "IP_NBR", "KVK_NBR", "DATEOFBIRTH", "DATEOFDEATH", "DATEOFFOUNDATION", "STARTED", "CTRY_OF_BIRTH", "DOB_QLY_IND", "LEGAL_FORM", "MGM_ENT_CODE", "LNG_PREFERRED", "IP_PREF_TYP", "CTRY_OF_RESIDENCE", "ACCESSTOKEN", "CITYOFBIRTH", "ORGANISATIONNAME", "GNDR", "IP_TYPE_IND", "JIVE_IND", "DEDUPED_TO_IP_NBR", "DEDUPED_TO_IP_UUID", "DEDUPINVOLVEDPARTYDATEINACTIVATED", "DEDUPED_IND", "ENDDATE", "PRFL_CCNT_IND", "RGHT_TO_OBJ_IND", "IP_UUID", "NAMEINITIALS", "LASTNAMEPREFIX", "LASTNAME", "SEV_SEGM", "INDIVIDUALNAMEVALUE", "CSI_NBR", "BE_NBR", "DEL_IN_SRC_STM_F", "SEV_SEGM_CATG", "AGE", "BUSINESSCLOSEDDOWNDATE", "CHANNELOFENTRY", "CTRY_OF_CRSPD", "CTRY_OF_INC", "DATEINACTIVATED", "DCSD_IND", "EMAIL_ADR_BSN", "FINANCIALLEGALSTATUSTYPE", "FIRSTNAME1", "FIRSTNAME2", "FIRSTNAME3", "FIRSTNAME4", "GIVENNAME", "GROUPTYPE", "IP_EFFECTIVEDATE", "IP_ENDDATE", "LC_ST_TP", "LGL_CMPNC_ST_TP", "MINOR_IND", "NICKNAME", "PARTNERLASTNAME", "PARTNERLASTNAMEPREFIX", "SALUTATION", "SECONDLASTNAME", "TEL_NBR_LAND", "TEL_NBR_MBL", "GRID_TYP", "CSI_TYP", "CNTR_PRTY_REL_LCS_TYP", "CNTR_PRTY_REL_LCS_EFF_DT", "CNTR_PRTY_REL_LCS_END_DT", "NL_MING_INBOX") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    ip_s_id,
    src_stm_key,
    vld_from_tms,
    vld_to_tms,
    isrt_job_run_id,
    udt_job_run_id,
    isrt_tms,
    udt_tms,
    hash_val,
    grid_nbr,
    ip_nbr,
    kvk_nbr,
    dateofbirth,
    dateofdeath,
    dateoffoundation,
    started,
    ctry_of_birth,
    dob_qly_ind,
    legal_form,
    mgm_ent_code,
    lng_preferred,
    ip_pref_typ,
    ctry_of_residence,
    accesstoken,
    cityofbirth,
    organisationname,
    gndr,
    ip_type_ind,
    jive_ind,
    deduped_to_ip_nbr,
    deduped_to_ip_uuid,
    dedupinvolvedpartydateinactivated,
    deduped_ind,
    enddate,
    prfl_ccnt_ind,
    rght_to_obj_ind,
    ip_uuid,
    nameinitials,
    lastnameprefix,
    lastname,
    sev_segm,
    individualnamevalue,
    csi_nbr,
    be_nbr,
    del_in_src_stm_f,
    sev_segm_catg,
    age,
    businesscloseddowndate,
    channelofentry,
    ctry_of_crspd,
    ctry_of_inc,
    dateinactivated,
    dcsd_ind,
    email_adr_bsn,
    financiallegalstatustype,
    firstname1,
    firstname2,
    firstname3,
    firstname4,
    givenname,
    grouptype,
    ip_effectivedate,
    ip_enddate,
    lc_st_tp,
    lgl_cmpnc_st_tp,
    minor_ind,
    nickname,
    partnerlastname,
    partnerlastnameprefix,
    salutation,
    secondlastname,
    tel_nbr_land,
    tel_nbr_mbl,
    grid_typ,
    csi_typ,
    cntr_prty_rel_lcs_typ,
    cntr_prty_rel_lcs_eff_dt,
    cntr_prty_rel_lcs_end_dt,
    nl_ming_inbox
FROM
    sl_cim_slv_owner.cim_ilv_ip_s_vw;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR__DM_OCR_OFFLINERPT_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_FP_PD_PSSN__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_FP_PD_PSSN__DM_OCR_OFFLINERPT_NL_VW" ("D2_PD_ID", "D2_SEG_ID", "FA_LE_CD", "AM_NBR", "NM_AGE_NBR", "SP_PD_PSSN_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "D1_AR_ID", "D1_CCY_ID", "D1_DT_ID", "D1_HLDR_ID", "D1_IP_ID", "D1_PD_ID", "D1_SEG_ID", "D2_AR_ID", "D2_CCY_ID", "D2_IP_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  D2_PD_ID
, D2_SEG_ID
, FA_LE_CD
, AM_NBR
, NM_AGE_NBR
, SP_PD_PSSN_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, D1_AR_ID
, D1_CCY_ID
, D1_DT_ID
, D1_HLDR_ID
, D1_IP_ID
, D1_PD_ID
, D1_SEG_ID
, D2_AR_ID
, D2_CCY_ID
, D2_IP_ID
FROM SL_CIM_SLT_OWNER.CIM_SLT_FP_PD_PSSN;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SEG__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SEG__DM_OCR_OFFLINERPT_NL_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SEG_ID
, S2_SEG_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_SEG_CD
, HA_SEG_NM
, HA_SEG_CGY_CD
, HA_SEG_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D1_HLDR__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D1_HLDR__DM_OCR_OFFLINERPT_NL_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_LAST_UDT_TMS", "TA_PCS_LAST_UDT_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_HLDR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_LAST_UDT_TMS
, TA_PCS_LAST_UDT_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, CA_HLDR_CD
, CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_IP__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_IP__DM_OCR_OFFLINERPT_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_SBI_TP_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_BRTH_CITY_NM", "HA_FORMAL_NM", "HA_TRD_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "CA_COLLAPSED_TO_IP_NBR", "CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "HA_UUID_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "CA_TEL_NBR", "CA_EMAIL_ADR", "CA_SEG_CD", "CA_CRSP_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "CA_SEG_CGY_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_CA
, TA_HASH_VAL_HA
, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_SBI_TP_CD
, HA_ZIP_CD
, HA_LE_CD
, HA_BRTH_CITY_NM
, HA_FORMAL_NM
, HA_TRD_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_WWFT_CMPLN_IND
, CA_COLLAPSED_TO_IP_NBR
, CA_COLLAPSED_DT
, CA_COLLAPSED_IND
, CA_END_DT
, CA_PRFL_CCNT_IND
, CA_RGHT_TO_OBJ_IND
, HA_UUID_CD
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, CA_TEL_NBR
, CA_EMAIL_ADR
, CA_SEG_CD
, CA_CRSP_NM
, HA_CSI_NBR
, HA_BE_NBR
, HA_DEL_IND
, CA_SEG_CGY_CD
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_PD__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_PD__DM_OCR_OFFLINERPT_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_PD_ID
, S2_PD_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_PD_CD
, HA_PD_NM
, HA_PD_CGY_CD
, HA_PD_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CCY__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CCY__DM_OCR_OFFLINERPT_NL_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "HA_ISO_CD", "HA_EXP_DT", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CCY_ID
, S2_CCY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, HA_ISO_CD
, HA_EXP_DT
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_CCY_CD
, HA_CCY_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_OCR_OFFLINERPT_NL_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CTRY_ID
, S2_CTRY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_CTRY_CD
, HA_CTRY_NM
, HA_ISO_CD
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_FP_PD_PSSN__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_FP_PD_PSSN__DM_BLS_BL_REP_NL_VW" ("D2_PD_ID", "D2_SEG_ID", "FA_LE_CD", "AM_NBR", "NM_AGE_NBR", "SP_PD_PSSN_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "D1_AR_ID", "D1_CCY_ID", "D1_DT_ID", "D1_HLDR_ID", "D1_IP_ID", "D1_PD_ID", "D1_SEG_ID", "D2_AR_ID", "D2_CCY_ID", "D2_IP_ID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  D2_PD_ID
, D2_SEG_ID
, FA_LE_CD
, AM_NBR
, NM_AGE_NBR
, SP_PD_PSSN_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, D1_AR_ID
, D1_CCY_ID
, D1_DT_ID
, D1_HLDR_ID
, D1_IP_ID
, D1_PD_ID
, D1_SEG_ID
, D2_AR_ID
, D2_CCY_ID
, D2_IP_ID
FROM SL_CIM_SLT_OWNER.CIM_SLT_FP_PD_PSSN
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D1_HLDR__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D1_HLDR__DM_BLS_BL_REP_NL_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_LAST_UDT_TMS", "TA_PCS_LAST_UDT_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_HLDR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_LAST_UDT_TMS
, TA_PCS_LAST_UDT_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, CA_HLDR_CD
, CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR__DM_BLS_BL_REP_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_PD__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_PD__DM_BLS_BL_REP_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_PD_ID
, S2_PD_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_PD_CD
, HA_PD_NM
, HA_PD_CGY_CD
, HA_PD_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_BLS_BL_REP_NL_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT", "TA_VLD_FROM_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CTRY_ID
, S2_CTRY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_CTRY_CD
, HA_CTRY_NM
, HA_ISO_CD
, HA_EXP_DT
, TA_VLD_FROM_TMS
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CTRY
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CCY__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CCY__DM_BLS_BL_REP_NL_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "HA_ISO_CD", "HA_EXP_DT", "TA_UDT_TMS", "HA_CCY_CD", "HA_CCY_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CCY_ID
, S2_CCY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, HA_ISO_CD
, HA_EXP_DT
, TA_UDT_TMS
, HA_CCY_CD
, HA_CCY_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CCY
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SEG__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SEG__DM_BLS_BL_REP_NL_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SEG_ID
, S2_SEG_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_SEG_CD
, HA_SEG_NM
, HA_SEG_CGY_CD
, HA_SEG_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SEG
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SBI__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SBI__DM_BLS_BL_REP_NL_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SBI_CD", "HA_SBI_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SBI_ID
, S2_SBI_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_SBI_CD
, HA_SBI_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SBI
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_IP__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_IP__DM_BLS_BL_REP_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_SBI_TP_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_BRTH_CITY_NM", "HA_FORMAL_NM", "HA_TRD_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "CA_COLLAPSED_TO_IP_NBR", "CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "HA_UUID_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "CA_TEL_NBR", "CA_EMAIL_ADR", "CA_SEG_CD", "CA_CRSP_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "CA_SEG_CGY_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_CA
, TA_HASH_VAL_HA
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_SBI_TP_CD
, HA_ZIP_CD
, HA_LE_CD
, HA_BRTH_CITY_NM
, HA_FORMAL_NM
, HA_TRD_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_WWFT_CMPLN_IND
, CA_COLLAPSED_TO_IP_NBR
, CA_COLLAPSED_DT
, CA_COLLAPSED_IND
, CA_END_DT
, CA_PRFL_CCNT_IND
, CA_RGHT_TO_OBJ_IND
, HA_UUID_CD
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, CA_TEL_NBR
, CA_EMAIL_ADR
, CA_SEG_CD
, CA_CRSP_NM
, HA_CSI_NBR
, HA_BE_NBR
, HA_DEL_IND
, CA_SEG_CGY_CD
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_PD__DM_PYS_PYMNTS_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_PD__DM_PYS_PYMNTS_NL_VW" ("HA_PD_CD", "HA_PD_CGY_CD", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
HA_PD_CD
, HA_PD_CGY_CD
, TA_VLD_TO_TMS
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR__DM_PYS_PYMNTS_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR__DM_PYS_PYMNTS_NL_VW" ("HA_IBAN_NBR", "HA_AR_NBR", "HA_PD_CD", "HA_ST_CD", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  HA_IBAN_NBR
, HA_AR_NBR
, HA_PD_CD
, HA_ST_CD
, TA_VLD_TO_TMS
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D7_CTRY_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D7_CTRY_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT S1_CTRY_ID, S2_CTRY_ID, TA_KEY, TA_SRC_ROW_ID, TA_HASH_VAL, TA_VLD_FROM_TMS, TA_VLD_TO_TMS, TA_PCS_ISRT_ID, TA_PCS_UDT_ID, TA_ISRT_TMS, TA_UDT_TMS,
CASE
WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND, HA_CTRY_CD, HA_CTRY_NM, HA_ISO_CD, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D7_AR_ST_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D7_AR_ST_VW" ("S1_AR_ST_ID", "S2_AR_ST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_AR_ST_CD", "HA_AR_ST_NM", "HA_AR_ST_CGY_CD", "HA_AR_ST_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
      S1_AR_ST_ID
     ,S2_AR_ST_ID
     ,TA_KEY
     ,TA_SRC_ROW_ID
     ,TA_HASH_VAL
     ,TA_VLD_FROM_TMS
     ,TA_VLD_TO_TMS
     ,TA_PCS_ISRT_ID
     ,TA_PCS_UDT_ID
     ,TA_ISRT_TMS
     ,TA_UDT_TMS
     ,CASE WHEN TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') THEN 'Y' ELSE 'N' end AS TA_CRN_IND
     ,HA_AR_ST_CD
     ,HA_AR_ST_NM
     ,HA_AR_ST_CGY_CD
     ,HA_AR_ST_CGY_NM
     ,HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR_ST;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D7_SEG_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D7_SEG_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT S1_SEG_ID, S2_SEG_ID, TA_KEY, TA_SRC_ROW_ID, TA_HASH_VAL, TA_VLD_FROM_TMS, TA_VLD_TO_TMS, TA_PCS_ISRT_ID, TA_PCS_UDT_ID, TA_ISRT_TMS, TA_UDT_TMS,
CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
HA_SEG_CD, HA_SEG_NM, HA_SEG_CGY_CD, HA_SEG_CGY_NM, HA_EXP_DT FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR__DM_CHV_CSTCTC_MULTI_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SBI__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SBI__DM_CHV_CSTCTC_MULTI_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SBI_CD", "HA_SBI_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SBI_ID
, S2_SBI_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_SBI_CD
, HA_SBI_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SBI
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_CHV_CSTCTC_MULTI_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CTRY_ID
, S2_CTRY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_CTRY_CD
, HA_CTRY_NM
, HA_ISO_CD
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CTRY
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_IP__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_IP__DM_CHV_CSTCTC_MULTI_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_SBI_TP_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_BRTH_CITY_NM", "HA_FORMAL_NM", "HA_TRD_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "CA_COLLAPSED_TO_IP_NBR", "CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "HA_UUID_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "CA_TEL_NBR", "CA_EMAIL_ADR", "CA_SEG_CD", "CA_CRSP_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "CA_SEG_CGY_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_CA
, TA_HASH_VAL_HA
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_SBI_TP_CD
, HA_ZIP_CD
, HA_LE_CD
, HA_BRTH_CITY_NM
, HA_FORMAL_NM
, HA_TRD_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_WWFT_CMPLN_IND
, CA_COLLAPSED_TO_IP_NBR
, CA_COLLAPSED_DT
, CA_COLLAPSED_IND
, CA_END_DT
, CA_PRFL_CCNT_IND
, CA_RGHT_TO_OBJ_IND
, HA_UUID_CD
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, CA_TEL_NBR
, CA_EMAIL_ADR
, CA_SEG_CD
, CA_CRSP_NM
, HA_CSI_NBR
, HA_BE_NBR
, HA_DEL_IND
, CA_SEG_CGY_CD
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_PD__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_PD__DM_CHV_CSTCTC_MULTI_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_PD_ID
, S2_PD_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_PD_CD
, HA_PD_NM
, HA_PD_CGY_CD
, HA_PD_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR_ST__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR_ST__DM_CHV_CSTCTC_MULTI_VW" ("S1_AR_ST_ID", "S2_AR_ST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_AR_ST_CD", "HA_AR_ST_NM", "HA_AR_ST_CGY_CD", "HA_AR_ST_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ST_ID
, S2_AR_ST_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_AR_ST_CD
, HA_AR_ST_NM
, HA_AR_ST_CGY_CD
, HA_AR_ST_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR_ST
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CCY__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CCY__DM_CHV_CSTCTC_MULTI_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CCY_ID
, S2_CCY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_CCY_CD
, HA_CCY_NM
, HA_ISO_CD
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CCY
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SEG__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SEG__DM_CHV_CSTCTC_MULTI_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SEG_ID
, S2_SEG_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_SEG_CD
, HA_SEG_NM
, HA_SEG_CGY_CD
, HA_SEG_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SEG
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_D7_SBI_HIST__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_D7_SBI_HIST__SL_CHV_CIM_XU_VW" ("S2_SBI_ID", "TA_SRC_ROW_ID", "TA_KEY", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_DEL_IND", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_LE_CD", "HA_IP_UUID", "HA_SBI_ISSUER_TP_CD", "HA_SBI_CD", "HA_RANK", "HA_SBI_STRT_TMS", "HA_SBI_END_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_INDUSTRY_CLASS_M_ID AS S2_SBI_ID,
IP_INDUSTRY_CLASS_M_SUP_KEY AS TA_SRC_ROW_ID,
'MDM.'||UNQ_ID_IN_SRC_STM AS TA_KEY,
VLD_FROM_TMS AS TA_VLD_FROM_TMS,
VLD_TO_TMS AS TA_VLD_TO_TMS,
DEL_IN_SRC_STM_F AS HA_DEL_IND,
ISRT_JOB_RUN_ID AS TA_PCS_ISRT_ID,
UDT_JOB_RUN_ID AS TA_PCS_UDT_ID,
ISRT_TMS AS TA_ISRT_TMS,
UDT_TMS AS TA_UDT_TMS,
DECODE(ACCESSTOKEN,'ING_BE_SHARED','ING_BE','ING_NL_INTRY','ING_NL','ING_NL_SHARED','ING_NL',ACCESSTOKEN) AS HA_LE_CD,
IDENTIFIER AS HA_IP_UUID,
ISSUERTYPE AS HA_SBI_ISSUER_TP_CD,
CODE AS HA_SBI_CD,
RANK AS HA_RANK,
EFFECTIVEDATE AS HA_SBI_STRT_TMS,
ENDDATE AS HA_SBI_END_TMS
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDUSTRY_CLASS_M__SL_CIM_CUSTOMER_INFO_XU_VW
WHERE ISSUERTYPE = 'IDY_CL_SBI';"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_D7_SEG_HIST__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_D7_SEG_HIST__SL_CHV_CIM_XU_VW" ("S2_SEG_HIST_ID", "TA_SRC_ROW_ID", "TA_KEY", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_DEL_IND", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_LE_CD", "HA_IP_UUID", "HA_SEG_HIST_TP_CD", "HA_SEG_HIST_CD", "HA_SEG_HIST_STRT_TMS", "HA_SEG_HIST_END_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_GROUP_V_ID AS S2_SEG_HIST_ID,
IP_GROUP_V_SUP_KEY AS TA_SRC_ROW_ID,
'MDM.'||UNQ_ID_IN_SRC_STM AS TA_KEY,
VLD_FROM_TMS AS TA_VLD_FROM_TMS,
VLD_TO_TMS AS TA_VLD_TO_TMS,
DEL_IN_SRC_STM_F AS HA_DEL_IND,
ISRT_JOB_RUN_ID AS TA_PCS_ISRT_ID,
UDT_JOB_RUN_ID AS TA_PCS_UDT_ID,
ISRT_TMS AS TA_ISRT_TMS,
UDT_TMS AS TA_UDT_TMS,
DECODE(ACCESSTOKEN,'ING_BE_SHARED','ING_BE','ING_NL_INTRY','ING_NL','ING_NL_SHARED','ING_NL',ACCESSTOKEN) AS HA_LE_CD,
INVOLVEDPARTYIDENTIFIER AS HA_IP_UUID,
GROUPTYPE AS HA_SEG_HIST_TP_CD,
GROUPCODE AS HA_SEG_HIST_CD,
EFFECTIVEDATE AS HA_SEG_HIST_STRT_TMS,
ENDDATE AS HA_SEG_HIST_END_TMS
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_GROUP_V__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_D7_TRADE_NAME_HIST__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_D7_TRADE_NAME_HIST__SL_CHV_CIM_XU_VW" ("S2_TRADE_NAME_ID", "TA_SRC_ROW_ID", "TA_KEY", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_DEL_IND", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_IP_UUID", "HA_TRADE_NAME_TP", "HA_TRADE_NAME", "HA_DATA_SOURCE", "HA_TRADE_NAME_STRT_TMS", "HA_TRADE_NAME_END_TMS", "HA_LE_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_ORGNAME_FULL_M_ID AS S2_TRADE_NAME_ID,
IP_ORGNAME_FULL_M_SUP_KEY AS TA_SRC_ROW_ID,
'MDM.'||UNQ_ID_IN_SRC_STM AS TA_KEY,
VLD_FROM_TMS AS TA_VLD_FROM_TMS,
VLD_TO_TMS AS TA_VLD_TO_TMS,
DEL_IN_SRC_STM_F AS HA_DEL_IND,
ISRT_JOB_RUN_ID AS TA_PCS_ISRT_ID,
UDT_JOB_RUN_ID AS TA_PCS_UDT_ID,
ISRT_TMS AS TA_ISRT_TMS,
UDT_TMS AS TA_UDT_TMS,
INVOLVEDPARTYIDENTIFIER AS HA_IP_UUID,
ORGANISATIONNAMETYPE AS HA_TRADE_NAME_TP,
ORGANISATIONNAME AS HA_TRADE_NAME,
DATASOURCE AS HA_DATA_SOURCE,
EFFECTIVEDATE AS HA_TRADE_NAME_STRT_TMS,
ENDDATE AS HA_TRADE_NAME_END_TMS,
DECODE(ACCESSTOKEN,'ING_BE_SHARED','ING_BE','ING_NL_INTRY','ING_NL','ING_NL_SHARED','ING_NL',ACCESSTOKEN) AS HA_LE_CD
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGNAME_FULL_M__SL_CIM_CUSTOMER_INFO_XU_VW
WHERE ORGANISATIONNAMETYPE IN ('TRD_NM','TRD_NM_SHRT');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_INDUSTRY_CLASS_S_VW__DM_SAL_SALES_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_INDUSTRY_CLASS_S_VW__DM_SAL_SALES_XU_VW" ("IP_INDUSTRY_CLASS_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "IP_UUID", "INDUS_CL_ISSUR_TYP", "INDUS_CL_CODE", "RANK", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_INDUSTRY_CLASS_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","ACCESSTOKEN","IP_UUID","INDUS_CL_ISSUR_TYP","INDUS_CL_CODE","RANK","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_INDUSTRY_CLASS_S_VW";"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_MANAGING_ENTITY_S_VW__DM_SAL_SALES_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_MANAGING_ENTITY_S_VW__DM_SAL_SALES_XU_VW" ("IP_MANAGING_ENTITY_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "MGM_ENT_TP", "MGM_ENT_CODE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_MANAGING_ENTITY_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","ACCESSTOKEN","MGM_ENT_TP","MGM_ENT_CODE","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_MANAGING_ENTITY_S_VW";"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_TRADE_NAME_S_VW__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_TRADE_NAME_S_VW__DM_SAL_SALESFORCE_XU_VW" ("IP_TRADE_NAME_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ORG_NM_TP", "ORGANISATIONNAME", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEDUSER", "LASTUPDATEDDATE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_TRADE_NAME_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","ORG_NM_TP","ORGANISATIONNAME","DATASOURCE","EFFECTIVEDATE","ENDDATE","LASTUPDATEDUSER","LASTUPDATEDDATE","ACCESSTOKEN" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_TRADE_NAME_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED')
AND ORG_NM_TP IN ('TRD_NM','TRD_NM_SHRT');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_D7_MAN_ENTITY_HIST__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_D7_MAN_ENTITY_HIST__SL_CHV_CIM_XU_VW" ("D2_IP_ME_ID", "TA_SRC_ROW_ID", "TA_KEY", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_DEL_IND", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_IP_UUID", "HA_LE_CD", "HA_MGN_ENT_TP_CD", "HA_MGN_ENT_CD", "HA_MGN_ENT_STRT_TMS", "HA_MGN_ENT_END_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_MANAGING_ENTITY_M_ID AS D2_IP_ME_ID,
IP_MANAGING_ENTITY_M_SUP_KEY AS TA_SRC_ROW_ID,
'MDM.'||UNQ_ID_IN_SRC_STM AS TA_KEY,
VLD_FROM_TMS AS TA_VLD_FROM_TMS,
VLD_TO_TMS AS TA_VLD_TO_TMS,
DEL_IN_SRC_STM_F AS HA_DEL_IND,
ISRT_JOB_RUN_ID AS TA_PCS_ISRT_ID,
UDT_JOB_RUN_ID AS TA_PCS_UDT_ID,
ISRT_TMS AS TA_ISRT_TMS,
UDT_TMS AS TA_UDT_TMS,
INVOLVEDPARTYIDENTIFIER AS HA_IP_UUID,
ACCESSTOKEN AS HA_LE_CD,
TYPE AS HA_MGN_ENT_TP_CD,
CODE AS HA_MGN_ENT_CD,
EFFECTIVEDATE AS HA_MGN_ENT_STRT_TMS,
ENDDATE AS HA_MGN_ENT_END_TMS
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_MANAGING_ENTITY_M__SL_CIM_CUSTOMER_INFO_XU_VW
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_D7_SEG_HIST__DM_SAL_SALES_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_D7_SEG_HIST__DM_SAL_SALES_XU_VW" ("S2_SEG_HIST_ID", "TA_SRC_ROW_ID", "TA_KEY", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_DEL_IND", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_LE_CD", "HA_IP_UUID", "HA_SEG_HIST_TP_CD", "HA_SEG_HIST_CD", "HA_SEG_HIST_STRT_TMS", "HA_SEG_HIST_END_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_GROUP_V_ID AS S2_SEG_HIST_ID,
IP_GROUP_V_SUP_KEY AS TA_SRC_ROW_ID,
'MDM.'||UNQ_ID_IN_SRC_STM AS TA_KEY,
VLD_FROM_TMS AS TA_VLD_FROM_TMS,
VLD_TO_TMS AS TA_VLD_TO_TMS,
DEL_IN_SRC_STM_F AS HA_DEL_IND,
ISRT_JOB_RUN_ID AS TA_PCS_ISRT_ID,
UDT_JOB_RUN_ID AS TA_PCS_UDT_ID,
ISRT_TMS AS TA_ISRT_TMS,
UDT_TMS AS TA_UDT_TMS,
ACCESSTOKEN AS HA_LE_CD,
INVOLVEDPARTYIDENTIFIER AS HA_IP_UUID,
GROUPTYPE AS HA_SEG_HIST_TP_CD,
GROUPCODE AS HA_SEG_HIST_CD,
EFFECTIVEDATE AS HA_SEG_HIST_STRT_TMS,
ENDDATE AS HA_SEG_HIST_END_TMS
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_GROUP_V__SL_CIM_CUSTOMER_INFO_XU_VW
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__SL_CHV_SALES_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__SL_CHV_SALES_XU_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_IP_UUID", "HA_LE_CD", "HA_IP_NBR", "HA_CSI_NBR", "HA_MGN_ENT_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_IP_ID,
S2_IP_ID,
TA_KEY,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_ISRT_TMS,
TA_UDT_TMS,
HA_IP_UUID,
HA_LE_CD,
HA_IP_NBR,
HA_CSI_NBR,
HA_MGN_ENT_CD
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_IP_ORG_HIER_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_IP_ORG_HIER_S_VW" ("ORG_HIER_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "ORGANISATIONHIERARCHYRELATIONSHIPIDENTIFIER", "ORG_HIER_RLTNP_RSN_TP", "ORG_PRN_RL_TP", "ORGANISATIONOWNERSHIPPERCENTAGE", "PARENT_IP_UUID", "CHILD_IP_UUID", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_1_X_IP_2_R_ID AS ORG_HIER_S_ID,
UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
HASH_VAL AS HASH_VAL,
VLD_FROM_TMS AS VLD_FROM_TMS,
VLD_TO_TMS AS VLD_TO_TMS,
DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
ISRT_TMS AS ISRT_TMS,
UDT_TMS AS UDT_TMS,
ACCESSTOKEN AS ACCESSTOKEN,
ORGANISATIONHIERARCHYRELATIONSHIPIDENTIFIER AS ORGANISATIONHIERARCHYRELATIONSHIPIDENTIFIER,
ORGANISATIONPARENTROLEREASONTYPE AS ORG_HIER_RLTNP_RSN_TP,
ORGANISATIONPARENTROLETYPE AS ORG_PRN_RL_TP,
ORGANISATIONOWNERSHIPPERCENTAGE AS ORGANISATIONOWNERSHIPPERCENTAGE,
ORGANISATIONPARENT AS PARENT_IP_UUID,
ORGANISATIONCHILD AS CHILD_IP_UUID,
DATASOURCE AS DATASOURCE,
EFFECTIVEDATE AS EFFECTIVEDATE,
ENDDATE AS ENDDATE,
LASTUPDATEUSER AS LASTUPDATEUSER,
LASTUPDATEDATE AS LASTUPDATEDATE
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORG_HIER_R__SL_CIM_CUSTOMER_INFO_XU_VW
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_INDINAME_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_INDINAME_S_VW" ("IP_INDINAME_S_ID", "IP_INDINAME_S_SUP_KEY", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "TITLE1", "TITLE2", "TITLE3", "ENDDATE", "LASTNAME", "NICKNAME", "GIVENNAME", "DATASOURCE", "FIRSTNAME1", "FIRSTNAME2", "FIRSTNAME3", "FIRSTNAME4", "NAMESUFFIX", "SALUTATION", "NAMEINITIALS", "BIRTHLASTNAME", "EFFECTIVEDATE", "LASTNAMEPREFIX", "LASTUPDATEDATE", "LASTUPDATEUSER", "SECONDLASTNAME", "PARTNERLASTNAME", "IDV_NM_TP", "PARTNERLASTNAMEPREFIX", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_INDINAME_M_ID AS IP_INDINAME_S_ID,
IP_INDINAME_M_SUP_KEY AS IP_INDINAME_S_SUP_KEY,
UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
HASH_VAL AS HASH_VAL,
VLD_FROM_TMS AS VLD_FROM_TMS,
VLD_TO_TMS AS VLD_TO_TMS,
DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
ISRT_TMS AS ISRT_TMS,
UDT_TMS AS UDT_TMS,
INVOLVEDPARTYIDENTIFIER AS IP_UUID,
TITLE1 AS TITLE1,
TITLE2 AS TITLE2,
TITLE3 AS TITLE3,
ENDDATE AS ENDDATE,
LASTNAME AS LASTNAME,
NICKNAME AS NICKNAME,
GIVENNAME AS GIVENNAME,
DATASOURCE AS DATASOURCE,
FIRSTNAME1 AS FIRSTNAME1,
FIRSTNAME2 AS FIRSTNAME2,
FIRSTNAME3 AS FIRSTNAME3,
FIRSTNAME4 AS FIRSTNAME4,
NAMESUFFIX AS NAMESUFFIX,
SALUTATION AS SALUTATION,
NAMEINITIALS AS NAMEINITIALS,
BIRTHLASTNAME AS BIRTHLASTNAME,
EFFECTIVEDATE AS EFFECTIVEDATE,
LASTNAMEPREFIX AS LASTNAMEPREFIX,
LASTUPDATEDATE AS LASTUPDATEDATE,
LASTUPDATEUSER AS LASTUPDATEUSER,
SECONDLASTNAME AS SECONDLASTNAME,
PARTNERLASTNAME AS PARTNERLASTNAME,
INDIVIDUALNAMETYPE AS IDV_NM_TP,
PARTNERLASTNAMEPREFIX AS PARTNERLASTNAMEPREFIX,
ACCESSTOKEN AS ACCESSTOKEN
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDINAME_M__SL_CIM_CUSTOMER_INFO_XU_VW
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_S_VW" ("AR_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "EFFECTIVEDATE", "ENDDATE", "AR_LC_ST_TP", "CUR", "AR_TYP", "ACCESSTOKEN", "CMRCL_NBR", "BBAN_NBR", "IBAN_NBR", "INH_IND", "JIVE_IND", "DEL_IN_SRC_STM_F", "INGENTITY", "NICKNAME", "AR_UUID", "AR_IDNT_TYPE", "AMA_ID", "BE_GRP_ID", "AR_IDNT", "AR_TYP_MAIN", "AR_NBR", "AR_NAME", "CRN_IND", "COUNT_HOLDR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID as AR_S_ID
, TA_KEY as SRC_STM_KEY
, TA_HASH_VAL as HASH_VAL
, TA_VLD_FROM_TMS as VLD_FROM_TMS
, TA_VLD_TO_TMS as VLD_TO_TMS
, TA_PCS_ISRT_ID as ISRT_JOB_RUN_ID
, TA_PCS_UDT_ID as UDT_JOB_RUN_ID
, TA_ISRT_TMS as ISRT_TMS
, TA_UDT_TMS as UDT_TMS
, HA_OPN_DT as EFFECTIVEDATE
, HA_END_DT as ENDDATE
, HA_ST_CD as AR_LC_ST_TP
, HA_CCY_CD as CUR
, HA_PD_CD as AR_TYP
, HA_LE_CD as ACCESSTOKEN
, HA_CMRCL_NBR as CMRCL_NBR
, HA_BBAN_NBR as BBAN_NBR
, HA_IBAN_NBR as IBAN_NBR
, HA_INH_IND as INH_IND
, HA_JIVE_IND as JIVE_IND
, CASE WHEN HA_DEL_IND = 'Y' THEN 1 ELSE 0 END as DEL_IN_SRC_STM_F
, HA_INGENTITY_CD as INGENTITY
, HA_NCKNM as NICKNAME
, AR.HA_AR_UUID as AR_UUID
, HA_AR_ID_TP as AR_IDNT_TYPE
, HA_AMA_ID as AMA_ID
, HA_BE_GRP_ID as BE_GRP_ID
, HA_AR_IDNT as AR_IDNT
, HA_AR_CD as AR_TYP_MAIN
, HA_AR_NBR AS AR_NBR
, HA_AR_NAME AS AR_NAME
, HA_CRN_IND AS CRN_IND
, ARC.COUNT_HOLDR
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR AR
LEFT OUTER JOIN
(SELECT HA_AR_UUID, COUNT(*) AS COUNT_HOLDR FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_IP
WHERE HA_ROLE_TYPE='HOLDR'
AND HA_END_DT IS NULL
AND TA_VLD_TO_TMS = TO_DATE('9999-12-31 00:00:00','YYYY-MM-DD HH24:MI:SS')
GROUP BY HA_AR_UUID ) ARC
ON AR.HA_AR_UUID = ARC.HA_AR_UUID
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_X_AR_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_AR_S_VW" ("AR_X_AR_S_ID", "AR_1_S_ID", "AR_2_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "DEL_IN_SRC_STM_F", "AR_1_UUID", "AR_2_UUID", "AR_TYP_MAIN_AR_1", "AR_TYP_AR_1", "AR_TYP_MAIN_AR_2", "AR_TYP_AR_2", "ACCESSTOKEN", "AR_AR_RELSHP_TP", "AR_AR_RELSHP_ST_TYPE", "EFFECTIVEDATE", "ENDDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SB_AR_1_X_AR_2_ID as AR_X_AR_S_ID,
    D1_AR_1_ID as AR_1_S_ID,
    D1_AR_2_ID as AR_2_S_ID,
    TA_KEY as SRC_STM_KEY,
    TA_VLD_FROM_TMS as VLD_FROM_TMS,
    TA_VLD_TO_TMS as VLD_TO_TMS,
    TA_PCS_ISRT_ID as ISRT_JOB_RUN_ID,
    TA_PCS_UDT_ID as UDT_JOB_RUN_ID,
    TA_ISRT_TMS as ISRT_TMS,
    TA_UDT_TMS as UDT_TMS,
    TA_HASH_VAL as HASH_VAL,
	CASE WHEN HA_DEL_IND = 'Y' THEN 1 ELSE 0 END as DEL_IN_SRC_STM_F,
    HA_AR_1_UUID as AR_1_UUID,
    HA_AR_2_UUID as AR_2_UUID,
    HA_AR_1_TYPE as AR_TYP_MAIN_AR_1,
    HA_AR_1_DTL_TYPE as AR_TYP_AR_1,
    HA_AR_2_TYPE as AR_TYP_MAIN_AR_2,
    HA_AR_2_DTL_TYPE as AR_TYP_AR_2,
    HA_LE_CD as ACCESSTOKEN,
    HA_TYPE as AR_AR_RELSHP_TP,
    HA_STATUS_TYPE as AR_AR_RELSHP_ST_TYPE,
    HA_EFF_DT as EFFECTIVEDATE,
    HA_END_DT as ENDDATE
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_X_IP_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_IP_S_VW" ("AR_X_IP_S_ID", "IP_S_ID", "AR_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "AR_TYP_MAIN", "DEL_IN_SRC_STM_F", "AR_UUID", "IP_UUID", "ACCESSTOKEN", "AGRM_IP_RL_TYP", "OPRL_LCS_TYP", "EFFECTIVEDATE", "ENDDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SB_AR_X_IP_ID as AR_X_IP_S_ID,
    D1_IP_ID as IP_S_ID,
    D1_AR_ID as AR_S_ID,
    TA_KEY as SRC_STM_KEY,
    TA_VLD_FROM_TMS as VLD_FROM_TMS,
    TA_VLD_TO_TMS as VLD_TO_TMS,
    TA_PCS_ISRT_ID as ISRT_JOB_RUN_ID,
    TA_PCS_UDT_ID as UDT_JOB_RUN_ID,
    TA_ISRT_TMS as ISRT_TMS,
    TA_UDT_TMS as UDT_TMS,
    TA_HASH_VAL as HASH_VAL,
    TA_AR_TYPE as AR_TYP_MAIN,
    CASE WHEN HA_DEL_IND = 'Y' THEN 1 ELSE 0 END as DEL_IN_SRC_STM_F,
    HA_AR_UUID as AR_UUID,
    HA_IP_UUID as IP_UUID,
    HA_LE_CD as ACCESSTOKEN,
    HA_ROLE_TYPE as AGRM_IP_RL_TYP,
    HA_OPER_STATUS_TYPE as OPRL_LCS_TYP,
    HA_EFF_DT as EFFECTIVEDATE,
    HA_END_DT as ENDDATE
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_DIGITAL_ADDRESS_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_DIGITAL_ADDRESS_S_VW" ("IP_DIGITAL_ADDRESS_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "DLV_FAILURE_RSN_TP", "DGTL_ADR_USG_TYP", "DGTL_ADR_TYP", "FULLDIGITALADDRESS", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE", "DATASOURCE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_DIGITAL_ADDRESS_M_ID AS IP_DIGITAL_ADDRESS_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	INVOLVEDPARTYIDENTIFIER AS IP_UUID,
	DELIVERYFAILUREREASONTYPE AS DLV_FAILURE_RSN_TP,
	USAGETYPE AS DGTL_ADR_USG_TYP,
	TYPE AS DGTL_ADR_TYP,
	FULLDIGITALADDRESS AS FULLDIGITALADDRESS,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE,
	DATASOURCE AS DATASOURCE,
	ACCESSTOKEN AS ACCESSTOKEN
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_DIGITAL_ADDRESS_M__SL_CIM_CUSTOMER_INFO_XU_VW
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_CITIZENSHIP_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_CITIZENSHIP_S_VW" ("IP_CITIZENSHIP_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "IP_UUID", "CTRY_CITIZENSHIP", "RANK", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_CITIZENSHIP_M_ID AS IP_CITIZENSHIP_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	ACCESSTOKEN AS ACCESSTOKEN,
	IDENTIFIER AS IP_UUID,
	CITIZENSHIP AS CTRY_CITIZENSHIP,
	RANK AS RANK,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_CITIZENSHIP_M__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_ASSESSMENT_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_ASSESSMENT_S_VW" ("IP_ASSESSMENT_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "GKYC_CL", "ASES_RSLT_TP", "ASES_PCS_TP", "ASES_TRGR_TP", "APPROVALDATE", "NEXTREVIEWDATE", "OWNINGENTITY", "OWNINGDEPARTMENT", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE", "ELIGIBILITYOUTCOME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_ASSESSMENT_M_ID AS IP_ASSESSMENT_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	INVOLVEDPARTYIDENTIFIER AS IP_UUID,
	ACCESSTOKEN AS ACCESSTOKEN,
	TYPE AS GKYC_CL,
	RESULTTYPE AS ASES_RSLT_TP,
	PROCESSTYPE AS ASES_PCS_TP,
	TRIGGERTYPE AS ASES_TRGR_TP,
	APPROVALDATE AS APPROVALDATE,
	NEXTREVIEWDATE AS NEXTREVIEWDATE,
	OWNINGENTITY AS OWNINGENTITY,
	OWNINGDEPARTMENT AS OWNINGDEPARTMENT,
	DATASOURCE AS DATASOURCE,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE,
	ELIGIBILITYOUTCOME AS ELIGIBILITYOUTCOME
from OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ASSESSMENT_M__SL_CIM_CUSTOMER_INFO_XU_VW
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_EXTERNAL_IDENTIFIER_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_EXTERNAL_IDENTIFIER_S_VW" ("IP_EXTERNAL_IDENTIFIER_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "IP_EXT_ID_TYP", "VALUE", "STATUSTYPE", "CTRY_OF_ISSUE", "PLACEOFISSUE", "DATEOFISSUE", "EXPIRYDATE", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_EXTERNAL_IDENTIFIER_M_ID AS IP_EXTERNAL_IDENTIFIER_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	INVOLVEDPARTYIDENTIFIER AS IP_UUID,
	TYPE AS IP_EXT_ID_TYP,
	CASE WHEN TYPE IN ('BSN_NL', 'TIN') THEN '*********'
	ELSE VALUE
	END AS VALUE,
	STATUSTYPE AS STATUSTYPE,
	COUNTRYOFISSUE AS CTRY_OF_ISSUE,
	PLACEOFISSUE AS PLACEOFISSUE,
	DATEOFISSUE AS DATEOFISSUE,
	EXPIRYDATE AS EXPIRYDATE,
	DATASOURCE AS DATASOURCE,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE,
	ACCESSTOKEN AS ACCESSTOKEN
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_EXTERNAL_IDENTIFIER_M__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_GROUP_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_GROUP_S_VW" ("IP_GROUP_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "IP_UUID", "IP_GRP_TYP", "IP_GRP_CODE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_GROUP_V_ID AS IP_GROUP_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	ACCESSTOKEN AS ACCESSTOKEN,
	INVOLVEDPARTYIDENTIFIER AS IP_UUID,
	GROUPTYPE AS IP_GRP_TYP,
	GROUPCODE AS IP_GRP_CODE,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_GROUP_V__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_INDUSTRY_CLASS_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_INDUSTRY_CLASS_S_VW" ("IP_INDUSTRY_CLASS_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "IP_UUID", "INDUS_CL_ISSUR_TYP", "INDUS_CL_CODE", "RANK", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_INDUSTRY_CLASS_M_ID AS IP_INDUSTRY_CLASS_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	ACCESSTOKEN AS ACCESSTOKEN,
	IDENTIFIER AS IP_UUID,
	ISSUERTYPE AS INDUS_CL_ISSUR_TYP,
	CODE AS INDUS_CL_CODE,
	RANK AS RANK,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDUSTRY_CLASS_M__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_MANAGING_ENTITY_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_MANAGING_ENTITY_S_VW" ("IP_MANAGING_ENTITY_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "MGM_ENT_TP", "MGM_ENT_CODE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_MANAGING_ENTITY_M_ID AS IP_MANAGING_ENTITY_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	INVOLVEDPARTYIDENTIFIER AS IP_UUID,
	ACCESSTOKEN AS ACCESSTOKEN,
	TYPE AS MGM_ENT_TP,
	CODE AS MGM_ENT_CODE,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_MANAGING_ENTITY_M__SL_CIM_CUSTOMER_INFO_XU_VW
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_MARKING_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_MARKING_S_VW" ("IP_MARKING_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "MRKNG_CGY", "IP_MRKNG_TYP", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_MARKING_M_ID AS IP_MARKING_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	INVOLVEDPARTYIDENTIFIER AS IP_UUID,
	ACCESSTOKEN AS ACCESSTOKEN,
	CATEGORY AS MRKNG_CGY,
	TYPE AS IP_MRKNG_TYP,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_MARKING_M__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_POSTAL_ADDRESS_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_POSTAL_ADDRESS_S_VW" ("IP_POSTAL_ADDRESS_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "DATASOURCE", "DLV_FAILURE_RSN_TP", "PST_ADR_USG_TP", "CTRY", "COUNTRYREGIONCODE", "CITYNAME", "REGIONNAME", "POSTALCODE", "STREETNAME", "HOUSENUMBER", "HOUSENUMBERADDITION", "BUILDINGNAME", "DELIVERYINFORMATION", "POBOXNUMBER", "STR_TP", "UNSTRUCTUREDADDRESSLINE1", "UNSTRUCTUREDADDRESSLINE2", "UNSTRUCTUREDADDRESSLINE3", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE", "DISTRICTNAME", "CITYAREANAME", "FLOOR", "LOCATIONUNITNUMBER", "DEPARTMENTNAME", "SUBDEPARTMENTNAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_POSTAL_ADDRESS_M_ID AS IP_POSTAL_ADDRESS_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	INVOLVEDPARTYIDENTIFIER AS IP_UUID,
	ACCESSTOKEN AS ACCESSTOKEN,
	DATASOURCE AS DATASOURCE,
	DELIVERYFAILUREREASONTYPE AS DLV_FAILURE_RSN_TP,
	USAGETYPE AS PST_ADR_USG_TP,
	COUNTRYCODE AS CTRY,
	COUNTRYREGIONCODE AS COUNTRYREGIONCODE,
	CITYNAME AS CITYNAME,
	REGIONNAME AS REGIONNAME,
	POSTALCODE AS POSTALCODE,
	STREETNAME AS STREETNAME,
	HOUSENUMBER AS HOUSENUMBER,
	HOUSENUMBERADDITION AS HOUSENUMBERADDITION,
	BUILDINGNAME AS BUILDINGNAME,
	DELIVERYINFORMATION AS DELIVERYINFORMATION,
	POBOXNUMBER AS POBOXNUMBER,
	STREETTYPE AS STR_TP,
	UNSTRUCTUREDADDRESSLINE1 AS UNSTRUCTUREDADDRESSLINE1,
	UNSTRUCTUREDADDRESSLINE2 AS UNSTRUCTUREDADDRESSLINE2,
	UNSTRUCTUREDADDRESSLINE3 AS UNSTRUCTUREDADDRESSLINE3,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE,
	DISTRICTNAME AS DISTRICTNAME,
	CITYAREANAME AS CITYAREANAME,
	FLOOR AS FLOOR,
	LOCATIONUNITNUMBER AS LOCATIONUNITNUMBER,
	DEPARTMENTNAME AS DEPARTMENTNAME,
	SUBDEPARTMENTNAME AS SUBDEPARTMENTNAME
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_POSTAL_ADDRESS_M__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_S_VW" ("IP_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "GRID_NBR", "IP_NBR", "KVK_NBR", "DATEOFBIRTH", "DATEOFDEATH", "DATEOFFOUNDATION", "STARTED", "CTRY_OF_BIRTH", "DOB_QLY_IND", "LEGAL_FORM", "MGM_ENT_CODE", "LNG_PREFERRED", "IP_PREF_TYP", "CTRY_OF_RESIDENCE", "ACCESSTOKEN", "CITYOFBIRTH", "ORGANISATIONNAME", "GNDR", "IP_TYPE_IND", "JIVE_IND", "DEDUPED_TO_IP_NBR", "DEDUPED_TO_IP_UUID", "DEDUPINVOLVEDPARTYDATEINACTIVATED", "DEDUPED_IND", "ENDDATE", "PRFL_CCNT_IND", "RGHT_TO_OBJ_IND", "IP_UUID", "NAMEINITIALS", "LASTNAMEPREFIX", "LASTNAME", "SEV_SEGM", "INDIVIDUALNAMEVALUE", "CSI_NBR", "BE_NBR", "DEL_IN_SRC_STM_F", "SEV_SEGM_CATG", "AGE", "BUSINESSCLOSEDDOWNDATE", "CHANNELOFENTRY", "CTRY_OF_CRSPD", "CTRY_OF_INC", "DATEINACTIVATED", "DCSD_IND", "EMAIL_ADR_BSN", "FINANCIALLEGALSTATUSTYPE", "FIRSTNAME1", "FIRSTNAME2", "FIRSTNAME3", "FIRSTNAME4", "GIVENNAME", "GROUPTYPE", "IP_EFFECTIVEDATE", "IP_ENDDATE", "LC_ST_TP", "LGL_CMPNC_ST_TP", "MINOR_IND", "NICKNAME", "PARTNERLASTNAME", "PARTNERLASTNAMEPREFIX", "SALUTATION", "SECONDLASTNAME", "TEL_NBR_LAND", "TEL_NBR_MBL", "GRID_TYP", "CSI_TYP", "CNTR_PRTY_REL_LCS_TYP", "CNTR_PRTY_REL_LCS_EFF_DT", "CNTR_PRTY_REL_LCS_END_DT", "NL_MING_INBOX") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID as IP_S_ID
, TA_KEY as SRC_STM_KEY
, TA_VLD_FROM_TMS as VLD_FROM_TMS
, TA_VLD_TO_TMS as VLD_TO_TMS
, TA_PCS_ISRT_ID as ISRT_JOB_RUN_ID
, TA_PCS_UDT_ID as UDT_JOB_RUN_ID
, TA_ISRT_TMS as ISRT_TMS
, TA_UDT_TMS as UDT_TMS
, TA_HASH_VAL_HA as HASH_VAL
, HA_GRID_NBR as GRID_NBR
, HA_IP_NBR as IP_NBR
, HA_KVK_NBR as KVK_NBR
, HA_BRTH_DT as DATEOFBIRTH
, HA_DCSD_DT as DATEOFDEATH
, HA_ESTB_DT as DATEOFFOUNDATION
, HA_STRT_DT as STARTED
, HA_BRTH_CTRY_CD as CTRY_OF_BIRTH
, HA_BRTH_DT_QLY_CD as DOB_QLY_IND
, HA_LGL_FORM_CD as LEGAL_FORM
, HA_MGN_ENT_CD as MGM_ENT_CODE
, HA_PREF_LANG_CD as LNG_PREFERRED
, HA_PRIV_PREF_CD as IP_PREF_TYP
, HA_RSDNT_CTRY_CD as CTRY_OF_RESIDENCE
, HA_LE_CD as ACCESSTOKEN
, HA_BRTH_CITY_NM as CITYOFBIRTH
, HA_FORMAL_NM as ORGANISATIONNAME
, HA_GND_IND as GNDR
, HA_IP_TP_IND as IP_TYPE_IND
, HA_JIVE_IND as JIVE_IND
, HA_COLLAPSED_TO_IP_NBR as DEDUPED_TO_IP_NBR
, HA_COLLAPSED_TO_IP_UUID as DEDUPED_TO_IP_UUID
, HA_COLLAPSED_DT as DEDUPINVOLVEDPARTYDATEINACTIVATED
, HA_COLLAPSED_IND as DEDUPED_IND
, HA_END_DT as ENDDATE
, HA_PRFL_CCNT_IND as PRFL_CCNT_IND
, HA_RGHT_TO_OBJ_IND as RGHT_TO_OBJ_IND
, HA_IP_UUID as IP_UUID
, HA_INIT_NM as NAMEINITIALS
, HA_PREPSTN_NM as LASTNAMEPREFIX
, HA_LST_NM as LASTNAME
, HA_SEG_CD as SEV_SEGM
, HA_CRSP_NM as INDIVIDUALNAMEVALUE
, HA_CSI_NBR as CSI_NBR
, HA_BE_NBR as BE_NBR
, CASE WHEN HA_DEL_IND = 'Y' THEN 1 ELSE 0 END as DEL_IN_SRC_STM_F
, HA_SEG_CGY_CD as SEV_SEGM_CATG
, HA_AGE AS AGE
, HA_CLS_ORG_DT AS BUSINESSCLOSEDDOWNDATE
, HA_CHANNEL_ENTRY AS CHANNELOFENTRY
, HA_CRSPD_CTRY_CD AS CTRY_OF_CRSPD
, HA_CTRY_INC AS CTRY_OF_INC
, HA_INACTIVE_DT AS DATEINACTIVATED
, HA_DCSD_IND AS DCSD_IND
, HA_EMAIL_ADR_BSN AS EMAIL_ADR_BSN
, HA_FNC_LGL_ST_TP AS FINANCIALLEGALSTATUSTYPE
, HA_FRST_NM_1 AS FIRSTNAME1
, HA_FRST_NM_2 AS FIRSTNAME2
, HA_FRST_NM_3 AS FIRSTNAME3
, HA_FRST_NM_4 AS FIRSTNAME4
, HA_GVN_NM AS GIVENNAME
, HA_GRP_TYP AS GROUPTYPE
, HA_IP_EFF_DT AS IP_EFFECTIVEDATE
, HA_IP_END_DT AS IP_ENDDATE
, HA_LCS_TP AS LC_ST_TP
, HA_LGL_CMPNC_ST_TP AS LGL_CMPNC_ST_TP
, HA_MINOR_IND AS MINOR_IND
, HA_NCK_NM AS NICKNAME
, HA_PRTN_LAST_NM AS PARTNERLASTNAME
, HA_PRTN_LAST_NM_PFX AS PARTNERLASTNAMEPREFIX
, HA_SALUT AS SALUTATION
, HA_SCD_LAST_NM AS SECONDLASTNAME
, HA_TEL_NBR_LAND AS TEL_NBR_LAND
, HA_TEL_NBR_MBL AS TEL_NBR_MBL
, HA_GRID_TP AS GRID_TYP
, HA_CSI_TP AS CSI_TYP
, HA_CNTR_PRTY_REL_LCS_TP AS CNTR_PRTY_REL_LCS_TYP
, HA_CNTR_PRTY_REL_LCS_EFF_DT AS CNTR_PRTY_REL_LCS_EFF_DT
, HA_CNTR_PRTY_REL_LCS_END_DT AS CNTR_PRTY_REL_LCS_END_DT
, HA_NL_MING_INBOX AS NL_MING_INBOX
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_TRADE_NAME_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_TRADE_NAME_S_VW" ("IP_TRADE_NAME_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ORG_NM_TP", "ORGANISATIONNAME", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEDUSER", "LASTUPDATEDDATE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_ORGNAME_FULL_M_ID AS IP_TRADE_NAME_S_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	INVOLVEDPARTYIDENTIFIER AS IP_UUID,
	ORGANISATIONNAMETYPE AS ORG_NM_TP,
	ORGANISATIONNAME AS ORGANISATIONNAME,
	DATASOURCE AS DATASOURCE,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEDUSER AS LASTUPDATEDUSER,
	LASTUPDATEDDATE AS LASTUPDATEDDATE,
	ACCESSTOKEN AS ACCESSTOKEN
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGNAME_FULL_M__SL_CIM_CUSTOMER_INFO_XU_VW
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_X_IP_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_X_IP_S_VW" ("IP_X_IP_S_ID", "IP_1_S_ID", "IP_2_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "DEL_IN_SRC_STM_F", "IP_1_GRNTEE_UUID", "GRNTE_RL_TYP", "GRNTEE_EFFECTIVEDATE", "GRNTEE_ENDDATE", "IP_2_GRNTOR_UUID", "GRNTR_RL_TYP", "GRNTOR_EFFECTIVEDATE", "GRNTOR_ENDDATE", "IP_REL_UUID", "IP_IP_RELSHP_TYP", "REL_EFFECTIVEDATE", "REL_ENDDATE", "INGENTITY", "ACCESSTOKEN", "MIX_IND_TP", "OPRL_LCSR_TYP", "OPRL_LCS_TYP", "IP_X_IP_RLTNP_PPS_TP") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SB_IP_1_X_IP_2_ID as IP_X_IP_S_ID,
    D1_IP_1_ID as IP_1_S_ID,
    D1_IP_2_ID as IP_2_S_ID,
    TA_KEY as SRC_STM_KEY,
    TA_VLD_FROM_TMS as VLD_FROM_TMS,
    TA_VLD_TO_TMS as VLD_TO_TMS,
    TA_PCS_ISRT_ID as ISRT_JOB_RUN_ID,
    TA_PCS_UDT_ID as UDT_JOB_RUN_ID,
    TA_ISRT_TMS as ISRT_TMS,
    TA_UDT_TMS as UDT_TMS,
    TA_HASH_VAL as HASH_VAL,
    CASE WHEN HA_DEL_IND = 'Y' THEN 1 ELSE 0 END as DEL_IN_SRC_STM_F,
    HA_IP_1_GRNTEE_UUID as IP_1_GRNTEE_UUID,
    HA_GRNTEE_TYPE as GRNTE_RL_TYP,
    HA_GRNTEE_EFF_DT as GRNTEE_EFFECTIVEDATE,
    HA_GRNTEE_END_DT as GRNTEE_ENDDATE,
    HA_IP_2_GRNTOR_UUID as IP_2_GRNTOR_UUID,
    HA_GRNTOR_TYPE as GRNTR_RL_TYP,
    HA_GRNTOR_EFF_DT as GRNTOR_EFFECTIVEDATE,
    HA_GRNTOR_END_DT as GRNTOR_ENDDATE,
    HA_REL_UUID as IP_REL_UUID,
    HA_REL_TYPE as IP_IP_RELSHP_TYP,
    HA_REL_EFF_DT as REL_EFFECTIVEDATE,
    HA_REL_END_DT as REL_ENDDATE,
    HA_ING_ENT_CD as INGENTITY,
    HA_LE_CD as ACCESSTOKEN,
    HA_MIX_IND_TP as MIX_IND_TP,
    HA_OPER_LIFECYCLE_ST_RSN_TP as OPRL_LCSR_TYP,
    HA_OPER_LIFECYCLE_ST_TP as OPRL_LCS_TYP,
    HA_CNTR_PRTY_REL_LIFECYCLE_ST_TP as IP_X_IP_RLTNP_PPS_TP
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_IP_X_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_TAX_RESIDENCY_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_TAX_RESIDENCY_S_VW" ("IP_TAX_RESIDENCY_M_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "CTRY_TAX_RESIDENCE", "RANKVALUE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	IP_TAX_RESIDENCY_M_ID AS IP_TAX_RESIDENCY_M_ID,
	UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
	HASH_VAL AS HASH_VAL,
	VLD_FROM_TMS AS VLD_FROM_TMS,
	VLD_TO_TMS AS VLD_TO_TMS,
	DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
	ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
	UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
	ISRT_TMS AS ISRT_TMS,
	UDT_TMS AS UDT_TMS,
	INVOLVEDPARTYIDENTIFIER AS IP_UUID,
	ACCESSTOKEN AS ACCESSTOKEN,
	COUNTRYOFTAXRESIDENCE AS CTRY_TAX_RESIDENCE,
	RANKVALUE AS RANKVALUE,
	EFFECTIVEDATE AS EFFECTIVEDATE,
	ENDDATE AS ENDDATE,
	LASTUPDATEUSER AS LASTUPDATEUSER,
	LASTUPDATEDATE AS LASTUPDATEDATE
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_TAX_RESIDENCY_M__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_PYS_PYMNTS_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_PYS_PYMNTS_NL_VW" ("HA_IBAN_NBR", "HA_AR_NBR", "HA_PD_CD", "HA_ST_CD", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  HA_IBAN_NBR
, HA_AR_NBR
, HA_PD_CD
, HA_ST_CD
, TA_VLD_TO_TMS
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("AR_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "EFFECTIVEDATE", "ENDDATE", "AR_LC_ST_TP", "CUR", "AR_TYP", "ACCESSTOKEN", "CMRCL_NBR", "BBAN_NBR", "IBAN_NBR", "INH_IND", "JIVE_IND", "DEL_IN_SRC_STM_F", "INGENTITY", "NICKNAME", "AR_UUID", "AR_IDNT_TYPE", "AMA_ID", "BE_GRP_ID", "AR_IDNT", "AR_TYP_MAIN", "AR_NBR", "AR_NAME", "CRN_IND", "COUNT_HOLDR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "AR_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","EFFECTIVEDATE","ENDDATE","AR_LC_ST_TP","CUR","AR_TYP","ACCESSTOKEN","CMRCL_NBR","BBAN_NBR","IBAN_NBR","INH_IND","JIVE_IND","DEL_IN_SRC_STM_F","INGENTITY","NICKNAME","AR_UUID","AR_IDNT_TYPE","AMA_ID","BE_GRP_ID","AR_IDNT","AR_TYP_MAIN","AR_NBR","AR_NAME","CRN_IND","COUNT_HOLDR" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_AR_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_XAM_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_XAM_REPORTING_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, A.CA_CID_NBR
, NVL(HA_CRN_IND,'N') AS TA_CRN_IND
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_INGENTITY_CD
, HA_NCKNM
, HA_AR_UUID
, HA_AR_ID_TP
,HA_AMA_ID
,HA_BE_GRP_ID
,HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM (SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR S LEFT JOIN (SELECT A.VALUE AS CA_CID_NBR,
A.IDENTIFIER FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW A
WHERE ((A.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS'))
AND (A.TYPE = 'NL_CORBANK_ID'))) A ON ((S.TA_KEY = ('MDM.' || A.IDENTIFIER))));"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_X_AR_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_AR_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("AR_X_AR_S_ID", "AR_1_S_ID", "AR_2_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "DEL_IN_SRC_STM_F", "AR_1_UUID", "AR_2_UUID", "AR_TYP_MAIN_AR_1", "AR_TYP_AR_1", "AR_TYP_MAIN_AR_2", "AR_TYP_AR_2", "ACCESSTOKEN", "AR_AR_RELSHP_TP", "AR_AR_RELSHP_ST_TYPE", "EFFECTIVEDATE", "ENDDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "AR_X_AR_S_ID","AR_1_S_ID","AR_2_S_ID","SRC_STM_KEY","VLD_FROM_TMS","VLD_TO_TMS","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","HASH_VAL","DEL_IN_SRC_STM_F","AR_1_UUID","AR_2_UUID","AR_TYP_MAIN_AR_1","AR_TYP_AR_1","AR_TYP_MAIN_AR_2","AR_TYP_AR_2","ACCESSTOKEN","AR_AR_RELSHP_TP","AR_AR_RELSHP_ST_TYPE","EFFECTIVEDATE","ENDDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_AR_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_BSL_BASEL_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_BSL_BASEL_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_AR_UUID", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_ID_TP", "HA_AR_CD", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_AR_ID,
S2_AR_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_HASH_VAL,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
CASE WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
HA_OPN_DT,
HA_END_DT,
HA_ST_CD,
HA_CCY_CD,
HA_PD_CD,
HA_LE_CD,
HA_AR_NBR,
HA_AR_UUID,
HA_CMRCL_NBR,
HA_BBAN_NBR,
HA_IBAN_NBR,
HA_INH_IND,
HA_JIVE_IND,
HA_DEL_IND,
HA_INGENTITY_CD,
HA_NCKNM,
HA_AR_ID_TP,
HA_AR_CD
,HA_AMA_ID
,HA_BE_GRP_ID
,HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_ASSESSMENT_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_ASSESSMENT_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_ASSESSMENT_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "GKYC_CL", "ASES_RSLT_TP", "ASES_PCS_TP", "ASES_TRGR_TP", "APPROVALDATE", "NEXTREVIEWDATE", "OWNINGENTITY", "OWNINGDEPARTMENT", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE", "ELIGIBILITYOUTCOME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_ASSESSMENT_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","ACCESSTOKEN","GKYC_CL","ASES_RSLT_TP","ASES_PCS_TP","ASES_TRGR_TP","APPROVALDATE","NEXTREVIEWDATE","OWNINGENTITY","OWNINGDEPARTMENT","DATASOURCE","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE","ELIGIBILITYOUTCOME" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_ASSESSMENT_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR_ST__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR_ST__DM_CHV_CSTCTC_MULTI_VW" ("S1_AR_ST_ID", "S2_AR_ST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_AR_ST_CD", "HA_AR_ST_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_AR_ST_ID,
    S2_AR_ST_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_AR_ST_CD,
    HA_AR_ST_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR_ST;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_AR_X_IP_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_IP_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("AR_X_IP_S_ID", "IP_S_ID", "AR_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "AR_TYP_MAIN", "DEL_IN_SRC_STM_F", "AR_UUID", "IP_UUID", "ACCESSTOKEN", "AGRM_IP_RL_TYP", "OPRL_LCS_TYP", "EFFECTIVEDATE", "ENDDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "AR_X_IP_S_ID","IP_S_ID","AR_S_ID","SRC_STM_KEY","VLD_FROM_TMS","VLD_TO_TMS","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","HASH_VAL","AR_TYP_MAIN","DEL_IN_SRC_STM_F","AR_UUID","IP_UUID","ACCESSTOKEN","AGRM_IP_RL_TYP","OPRL_LCS_TYP","EFFECTIVEDATE","ENDDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_AR_X_IP_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_IP_X_IP__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_IP_X_IP__DM_SAL_SALESFORCE_XU_VW" ("SB_IP_1_X_IP_2_ID", "D1_IP_1_ID", "D2_IP_1_ID", "D1_IP_2_ID", "D2_IP_2_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "TA_CRN_IND", "HA_DEL_IND", "HA_IP_1_GRNTEE_UUID", "HA_GRNTEE_TYPE", "HA_GRNTEE_EFF_DT", "HA_GRNTEE_END_DT", "HA_IP_2_GRNTOR_UUID", "HA_GRNTOR_TYPE", "HA_GRNTOR_EFF_DT", "HA_GRNTOR_END_DT", "HA_REL_UUID", "HA_REL_TYPE", "HA_REL_EFF_DT", "HA_REL_END_DT", "HA_ING_ENT_CD", "HA_LE_CD", "HA_MIX_IND_TP", "HA_OPER_LIFECYCLE_ST_RSN_TP", "HA_OPER_LIFECYCLE_ST_TP", "HA_CNTR_PRTY_REL_LIFECYCLE_ST_TP") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
SB_IP_1_X_IP_2_ID,
D1_IP_1_ID,
D2_IP_1_ID,
D1_IP_2_ID,
D2_IP_2_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
TA_HASH_VAL,
CASE WHEN TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
HA_DEL_IND,
HA_IP_1_GRNTEE_UUID,
HA_GRNTEE_TYPE,
HA_GRNTEE_EFF_DT,
HA_GRNTEE_END_DT,
HA_IP_2_GRNTOR_UUID,
HA_GRNTOR_TYPE,
HA_GRNTOR_EFF_DT,
HA_GRNTOR_END_DT,
HA_REL_UUID,
HA_REL_TYPE,
HA_REL_EFF_DT,
HA_REL_END_DT,
HA_ING_ENT_CD,
HA_LE_CD,
HA_MIX_IND_TP,
HA_OPER_LIFECYCLE_ST_RSN_TP,
HA_OPER_LIFECYCLE_ST_TP,
HA_CNTR_PRTY_REL_LIFECYCLE_ST_TP
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_IP_X_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_DIGITAL_ADDRESS_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_DIGITAL_ADDRESS_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_DIGITAL_ADDRESS_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "DLV_FAILURE_RSN_TP", "DGTL_ADR_USG_TYP", "DGTL_ADR_TYP", "FULLDIGITALADDRESS", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE", "DATASOURCE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_DIGITAL_ADDRESS_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","DLV_FAILURE_RSN_TP","DGTL_ADR_USG_TYP","DGTL_ADR_TYP","FULLDIGITALADDRESS","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE","DATASOURCE","ACCESSTOKEN" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_DIGITAL_ADDRESS_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_CHV_CSTCTC_MULTI_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_INGENTITY_CD
, HA_NCKNM
, HA_AR_UUID
, HA_AR_ID_TP
,HA_AMA_ID
,HA_BE_GRP_ID
,HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_CITIZENSHIP_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_CITIZENSHIP_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_CITIZENSHIP_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "IP_UUID", "CTRY_CITIZENSHIP", "RANK", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_CITIZENSHIP_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","ACCESSTOKEN","IP_UUID","CTRY_CITIZENSHIP","RANK","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_CITIZENSHIP_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__DM_BLS_BL_REP_NL_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_LAST_UDT_TMS", "TA_PCS_LAST_UDT_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_HLDR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_LAST_UDT_TMS
, TA_PCS_LAST_UDT_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, CA_HLDR_CD
, CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_EXTERNAL_IDENTIFIER_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_EXTERNAL_IDENTIFIER_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_EXTERNAL_IDENTIFIER_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "IP_EXT_ID_TYP", "VALUE", "STATUSTYPE", "CTRY_OF_ISSUE", "PLACEOFISSUE", "DATEOFISSUE", "EXPIRYDATE", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_EXTERNAL_IDENTIFIER_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","IP_EXT_ID_TYP","VALUE","STATUSTYPE","CTRY_OF_ISSUE","PLACEOFISSUE","DATEOFISSUE","EXPIRYDATE","DATASOURCE","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE","ACCESSTOKEN" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_EXTERNAL_IDENTIFIER_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_CRM_DOD_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_CRM_DOD_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_AR_UUID", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_ID_TP", "HA_AR_CD", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_AR_ID,
S2_AR_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_HASH_VAL,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
HA_OPN_DT,
HA_END_DT,
HA_ST_CD,
HA_CCY_CD,
HA_PD_CD,
HA_LE_CD,
HA_AR_NBR,
HA_AR_UUID,
HA_CMRCL_NBR,
HA_BBAN_NBR,
HA_IBAN_NBR,
HA_INH_IND,
HA_JIVE_IND,
HA_DEL_IND,
HA_INGENTITY_CD,
HA_NCKNM,
HA_AR_ID_TP,
HA_AR_CD,
HA_AMA_ID,
HA_BE_GRP_ID,
HA_AR_IDNT,
HA_CRN_IND,
HA_AR_NAME
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__SL_CHV_CIM_XU_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT 
 S.S1_AR_ID,
 S.S2_AR_ID,
 S.TA_KEY,
 S.TA_SRC_ROW_ID,
 S.TA_HASH_VAL,
 S.TA_VLD_FROM_TMS,
 S.TA_VLD_TO_TMS,
 S.TA_PCS_ISRT_ID,
 S.TA_PCS_UDT_ID,
 S.TA_ISRT_TMS,
 S.TA_UDT_TMS,
 CASE WHEN (S.TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 S.HA_OPN_DT,
 S.HA_END_DT,
 S.HA_ST_CD,
 S.HA_CCY_CD,
 S.HA_PD_CD,
 S.HA_LE_CD,
 S.HA_AR_NBR,
 S.HA_CMRCL_NBR,
 S.HA_BBAN_NBR,
 S.HA_IBAN_NBR,
 S.HA_INH_IND,
 S.HA_JIVE_IND,
 S.HA_DEL_IND,
 S.HA_INGENTITY_CD,
 S.HA_NCKNM,
 S.HA_AR_UUID,
 S.HA_AR_ID_TP
 ,S.HA_AMA_ID
,S.HA_BE_GRP_ID
,S.HA_AR_IDNT
,S.HA_CRN_IND
,S.HA_AR_NAME
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR S;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_INDUSTRY_CLASS_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_INDUSTRY_CLASS_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_INDUSTRY_CLASS_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "IP_UUID", "INDUS_CL_ISSUR_TYP", "INDUS_CL_CODE", "RANK", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_INDUSTRY_CLASS_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","ACCESSTOKEN","IP_UUID","INDUS_CL_ISSUR_TYP","INDUS_CL_CODE","RANK","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_INDUSTRY_CLASS_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_GROUP_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_GROUP_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_GROUP_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "IP_UUID", "IP_GRP_TYP", "IP_GRP_CODE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_GROUP_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","ACCESSTOKEN","IP_UUID","IP_GRP_TYP","IP_GRP_CODE","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_GROUP_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_COM_COM_XU_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_INGENTITY_CD
, HA_NCKNM
, HA_AR_UUID
, HA_AR_ID_TP
,HA_AMA_ID
,HA_BE_GRP_ID
,HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_POSTAL_ADDRESS_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_POSTAL_ADDRESS_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_POSTAL_ADDRESS_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "DATASOURCE", "DLV_FAILURE_RSN_TP", "PST_ADR_USG_TP", "CTRY", "COUNTRYREGIONCODE", "CITYNAME", "REGIONNAME", "POSTALCODE", "STREETNAME", "HOUSENUMBER", "HOUSENUMBERADDITION", "BUILDINGNAME", "DELIVERYINFORMATION", "POBOXNUMBER", "STR_TP", "UNSTRUCTUREDADDRESSLINE1", "UNSTRUCTUREDADDRESSLINE2", "UNSTRUCTUREDADDRESSLINE3", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE", "DISTRICTNAME", "CITYAREANAME", "FLOOR", "LOCATIONUNITNUMBER", "DEPARTMENTNAME", "SUBDEPARTMENTNAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_POSTAL_ADDRESS_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","ACCESSTOKEN","DATASOURCE","DLV_FAILURE_RSN_TP","PST_ADR_USG_TP","CTRY","COUNTRYREGIONCODE","CITYNAME","REGIONNAME","POSTALCODE","STREETNAME","HOUSENUMBER","HOUSENUMBERADDITION","BUILDINGNAME","DELIVERYINFORMATION","POBOXNUMBER","STR_TP","UNSTRUCTUREDADDRESSLINE1","UNSTRUCTUREDADDRESSLINE2","UNSTRUCTUREDADDRESSLINE3","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE","DISTRICTNAME","CITYAREANAME","FLOOR","LOCATIONUNITNUMBER","DEPARTMENTNAME","SUBDEPARTMENTNAME" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_POSTAL_ADDRESS_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_FDS_FINREP_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
     S.S1_AR_ID,
	 S.S2_AR_ID,
	 S.TA_KEY,
	 S.TA_SRC_ROW_ID,
	 S.TA_HASH_VAL,
	 S.TA_VLD_FROM_TMS,
	 S.TA_VLD_TO_TMS,
	 S.TA_PCS_ISRT_ID,
	 S.TA_PCS_UDT_ID,
	 S.TA_ISRT_TMS,
	 S.TA_UDT_TMS,
	 A.CA_CID_NBR,
	 CASE WHEN (S.TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
	 S.HA_OPN_DT,
	 S.HA_END_DT,
	 S.HA_ST_CD,
	 S.HA_CCY_CD,
	 S.HA_PD_CD,
	 S.HA_LE_CD,
	 S.HA_AR_NBR,
	 S.HA_CMRCL_NBR,
	 S.HA_BBAN_NBR,
	 S.HA_IBAN_NBR,
	 S.HA_INH_IND,
	 S.HA_JIVE_IND,
	 S.HA_INGENTITY_CD,
	 S.HA_NCKNM,
	 S.HA_AR_UUID,
	 S.HA_AR_ID_TP
	 ,S.HA_AMA_ID
	,S.HA_BE_GRP_ID
	,S.HA_AR_IDNT
	,S.HA_CRN_IND
	,S.HA_AR_NAME
FROM (SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR S LEFT JOIN (SELECT A.VALUE AS CA_CID_NBR,
A.IDENTIFIER FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW A
WHERE ((A.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS'))
AND (A.TYPE = 'NL_CORBANK_ID'))) A ON ((S.TA_KEY = ('MDM.' || A.IDENTIFIER))));"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_MARKING_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_MARKING_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_MARKING_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "MRKNG_CGY", "IP_MRKNG_TYP", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_MARKING_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","ACCESSTOKEN","MRKNG_CGY","IP_MRKNG_TYP","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_MARKING_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_FRM_FCS_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_FRM_FCS_MULTI_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_AR_UUID", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_ID_TP", "HA_AR_CD", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_AR_ID,
S2_AR_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_HASH_VAL,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
HA_OPN_DT,
HA_END_DT,
HA_ST_CD,
HA_CCY_CD,
HA_PD_CD,
HA_LE_CD,
HA_AR_NBR,
HA_AR_UUID,
HA_CMRCL_NBR,
HA_BBAN_NBR,
HA_IBAN_NBR,
HA_INH_IND,
HA_JIVE_IND,
HA_DEL_IND,
HA_INGENTITY_CD,
HA_NCKNM,
HA_AR_ID_TP,
HA_AR_CD,
HA_AMA_ID,
HA_BE_GRP_ID,
HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM
    sl_cim_slt_owner.onepam_slt_d7_ar;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_TAX_RESIDENCY_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_TAX_RESIDENCY_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_TAX_RESIDENCY_M_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "CTRY_TAX_RESIDENCE", "RANKVALUE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_TAX_RESIDENCY_M_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","ACCESSTOKEN","CTRY_TAX_RESIDENCE","RANKVALUE","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_TAX_RESIDENCY_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR_ST__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR_ST__DM_SAL_SALESFORCE_XU_VW" ("S1_AR_ST_ID", "S2_AR_ST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_AR_ST_CD", "HA_AR_ST_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_AR_ST_ID,
S2_AR_ST_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_HASH_VAL,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
CASE WHEN TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
HA_AR_ST_CD,
HA_AR_ST_NM,
HA_EFF_DT,
HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR_ST;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "GRID_NBR", "IP_NBR", "KVK_NBR", "DATEOFBIRTH", "DATEOFDEATH", "DATEOFFOUNDATION", "STARTED", "CTRY_OF_BIRTH", "DOB_QLY_IND", "LEGAL_FORM", "MGM_ENT_CODE", "LNG_PREFERRED", "IP_PREF_TYP", "CTRY_OF_RESIDENCE", "ACCESSTOKEN", "CITYOFBIRTH", "ORGANISATIONNAME", "GNDR", "IP_TYPE_IND", "JIVE_IND", "DEDUPED_TO_IP_NBR", "DEDUPED_TO_IP_UUID", "DEDUPINVOLVEDPARTYDATEINACTIVATED", "DEDUPED_IND", "ENDDATE", "PRFL_CCNT_IND", "RGHT_TO_OBJ_IND", "IP_UUID", "NAMEINITIALS", "LASTNAMEPREFIX", "LASTNAME", "SEV_SEGM", "INDIVIDUALNAMEVALUE", "CSI_NBR", "BE_NBR", "DEL_IN_SRC_STM_F", "SEV_SEGM_CATG", "AGE", "BUSINESSCLOSEDDOWNDATE", "CHANNELOFENTRY", "CTRY_OF_CRSPD", "CTRY_OF_INC", "DATEINACTIVATED", "DCSD_IND", "EMAIL_ADR_BSN", "FINANCIALLEGALSTATUSTYPE", "FIRSTNAME1", "FIRSTNAME2", "FIRSTNAME3", "FIRSTNAME4", "GIVENNAME", "GROUPTYPE", "IP_EFFECTIVEDATE", "IP_ENDDATE", "LC_ST_TP", "LGL_CMPNC_ST_TP", "MINOR_IND", "NICKNAME", "PARTNERLASTNAME", "PARTNERLASTNAMEPREFIX", "SALUTATION", "SECONDLASTNAME", "TEL_NBR_LAND", "TEL_NBR_MBL", "GRID_TYP", "CSI_TYP", "CNTR_PRTY_REL_LCS_TYP", "CNTR_PRTY_REL_LCS_EFF_DT", "CNTR_PRTY_REL_LCS_END_DT", "NL_MING_INBOX") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_S_ID","SRC_STM_KEY","VLD_FROM_TMS","VLD_TO_TMS","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","HASH_VAL","GRID_NBR","IP_NBR","KVK_NBR","DATEOFBIRTH","DATEOFDEATH","DATEOFFOUNDATION","STARTED","CTRY_OF_BIRTH","DOB_QLY_IND","LEGAL_FORM","MGM_ENT_CODE","LNG_PREFERRED","IP_PREF_TYP","CTRY_OF_RESIDENCE","ACCESSTOKEN","CITYOFBIRTH","ORGANISATIONNAME","GNDR","IP_TYPE_IND","JIVE_IND","DEDUPED_TO_IP_NBR","DEDUPED_TO_IP_UUID","DEDUPINVOLVEDPARTYDATEINACTIVATED","DEDUPED_IND","ENDDATE","PRFL_CCNT_IND","RGHT_TO_OBJ_IND","IP_UUID","NAMEINITIALS","LASTNAMEPREFIX","LASTNAME","SEV_SEGM","INDIVIDUALNAMEVALUE","CSI_NBR","BE_NBR","DEL_IN_SRC_STM_F","SEV_SEGM_CATG","AGE","BUSINESSCLOSEDDOWNDATE","CHANNELOFENTRY","CTRY_OF_CRSPD","CTRY_OF_INC","DATEINACTIVATED","DCSD_IND","EMAIL_ADR_BSN","FINANCIALLEGALSTATUSTYPE","FIRSTNAME1","FIRSTNAME2","FIRSTNAME3","FIRSTNAME4","GIVENNAME","GROUPTYPE","IP_EFFECTIVEDATE","IP_ENDDATE","LC_ST_TP","LGL_CMPNC_ST_TP","MINOR_IND","NICKNAME","PARTNERLASTNAME","PARTNERLASTNAMEPREFIX","SALUTATION","SECONDLASTNAME","TEL_NBR_LAND","TEL_NBR_MBL","GRID_TYP","CSI_TYP","CNTR_PRTY_REL_LCS_TYP","CNTR_PRTY_REL_LCS_EFF_DT","CNTR_PRTY_REL_LCS_END_DT","NL_MING_INBOX" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_IP_X_IP__DM_CRM_BASEL_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_IP_X_IP__DM_CRM_BASEL_NL_VW" ("SB_IP_1_X_IP_2_ID", "D1_IP_1_ID", "D2_IP_1_ID", "D1_IP_2_ID", "D2_IP_2_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "HA_DEL_IND", "TA_CRN_IND", "HA_IP_1_GRNTEE_UUID", "HA_GRNTEE_TYPE", "HA_GRNTEE_EFF_DT", "HA_GRNTEE_END_DT", "HA_IP_2_GRNTOR_UUID", "HA_GRNTOR_TYPE", "HA_GRNTOR_EFF_DT", "HA_GRNTOR_END_DT", "HA_REL_UUID", "HA_REL_TYPE", "HA_REL_EFF_DT", "HA_REL_END_DT", "HA_ING_ENT_CD", "HA_LE_CD", "HA_MIX_IND_TP", "HA_OPER_LIFECYCLE_ST_RSN_TP", "HA_OPER_LIFECYCLE_ST_TP", "HA_CNTR_PRTY_REL_LIFECYCLE_ST_TP") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SB_IP_1_X_IP_2_ID,
    D1_IP_1_ID,
    D2_IP_1_ID,
    D1_IP_2_ID,
    D2_IP_2_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    TA_HASH_VAL,
    HA_DEL_IND,
	CASE WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END TA_CRN_IND,
    HA_IP_1_GRNTEE_UUID,
    HA_GRNTEE_TYPE,
    HA_GRNTEE_EFF_DT,
    HA_GRNTEE_END_DT,
    HA_IP_2_GRNTOR_UUID,
    HA_GRNTOR_TYPE,
    HA_GRNTOR_EFF_DT,
    HA_GRNTOR_END_DT,
    HA_REL_UUID,
    HA_REL_TYPE,
    HA_REL_EFF_DT,
    HA_REL_END_DT,
    HA_ING_ENT_CD,
    HA_LE_CD,
    HA_MIX_IND_TP,
    HA_OPER_LIFECYCLE_ST_RSN_TP,
    HA_OPER_LIFECYCLE_ST_TP,
    HA_CNTR_PRTY_REL_LIFECYCLE_ST_TP
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_IP_X_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_MANAGING_ENTITY_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_MANAGING_ENTITY_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_MANAGING_ENTITY_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "MGM_ENT_TP", "MGM_ENT_CODE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_MANAGING_ENTITY_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","ACCESSTOKEN","MGM_ENT_TP","MGM_ENT_CODE","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_MANAGING_ENTITY_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_KRO_KROV_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S.S1_AR_ID,
 S.S2_AR_ID,
 S.TA_KEY,
 S.TA_SRC_ROW_ID,
 S.TA_HASH_VAL,
 S.TA_VLD_FROM_TMS,
 S.TA_VLD_TO_TMS,
 S.TA_PCS_ISRT_ID,
 S.TA_PCS_UDT_ID,
 S.TA_ISRT_TMS,
 S.TA_UDT_TMS,
 A.CA_CID_NBR,
 CASE WHEN (S.TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 S.HA_OPN_DT,
 S.HA_END_DT,
 S.HA_ST_CD,
 S.HA_CCY_CD,
 S.HA_PD_CD,
 S.HA_LE_CD,
 S.HA_AR_NBR,
 S.HA_CMRCL_NBR,
 S.HA_BBAN_NBR,
 S.HA_IBAN_NBR,
 S.HA_INH_IND,
 S.HA_JIVE_IND,
 S.HA_DEL_IND,
 S.HA_INGENTITY_CD,
 S.HA_NCKNM,
 S.HA_AR_UUID,
 S.HA_AR_ID_TP
 ,S.HA_AMA_ID
,S.HA_BE_GRP_ID
,S.HA_AR_IDNT
,S.HA_CRN_IND
,S.HA_AR_NAME
FROM (SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR S LEFT JOIN (SELECT A.VALUE AS CA_CID_NBR,
A.IDENTIFIER FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW A
WHERE ((A.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS'))
AND (A.TYPE = 'NL_CORBANK_ID'))) A ON ((S.TA_KEY = ('MDM.' || A.IDENTIFIER))));"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_TRADE_NAME_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_TRADE_NAME_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_TRADE_NAME_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ORG_NM_TP", "ORGANISATIONNAME", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEDUSER", "LASTUPDATEDDATE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_TRADE_NAME_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","ORG_NM_TP","ORGANISATIONNAME","DATASOURCE","EFFECTIVEDATE","ENDDATE","LASTUPDATEDUSER","LASTUPDATEDDATE","ACCESSTOKEN" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_TRADE_NAME_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED')
AND ORG_NM_TP IN ('TRD_NM','TRD_NM_SHRT');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_BLS_BL_REP_NL_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 s1_ccy_id,
    s2_ccy_id,
    ta_key,
    ta_src_row_id,
    ta_hash_val,
    ta_vld_from_tms,
    ta_vld_to_tms,
    ta_pcs_isrt_id,
    ta_pcs_udt_id,
    ta_isrt_tms,
    ta_udt_tms,
    ha_ccy_cd,
    ha_ccy_nm,
    ha_iso_cd,
    ha_eff_dt,
    HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_X_IP_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_X_IP_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_X_IP_S_ID", "IP_1_S_ID", "IP_2_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "DEL_IN_SRC_STM_F", "IP_1_GRNTEE_UUID", "GRNTE_RL_TYP", "GRNTEE_EFFECTIVEDATE", "GRNTEE_ENDDATE", "IP_2_GRNTOR_UUID", "GRNTR_RL_TYP", "GRNTOR_EFFECTIVEDATE", "GRNTOR_ENDDATE", "IP_REL_UUID", "IP_IP_RELSHP_TYP", "REL_EFFECTIVEDATE", "REL_ENDDATE", "INGENTITY", "ACCESSTOKEN", "MIX_IND_TP", "OPRL_LCSR_TYP", "OPRL_LCS_TYP", "IP_X_IP_RLTNP_PPS_TP") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_X_IP_S_ID","IP_1_S_ID","IP_2_S_ID","SRC_STM_KEY","VLD_FROM_TMS","VLD_TO_TMS","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","HASH_VAL","DEL_IN_SRC_STM_F","IP_1_GRNTEE_UUID","GRNTE_RL_TYP","GRNTEE_EFFECTIVEDATE","GRNTEE_ENDDATE","IP_2_GRNTOR_UUID","GRNTR_RL_TYP","GRNTOR_EFFECTIVEDATE","GRNTOR_ENDDATE","IP_REL_UUID","IP_IP_RELSHP_TYP","REL_EFFECTIVEDATE","REL_ENDDATE","INGENTITY","ACCESSTOKEN","MIX_IND_TP","OPRL_LCSR_TYP","OPRL_LCS_TYP","IP_X_IP_RLTNP_PPS_TP" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_X_IP_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__SL_CHV_CIM_XU_VW" ("SB_AR_X_IP_ID", "D1_IP_ID", "D2_IP_ID", "D1_AR_ID", "D2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "TA_AR_TYPE", "HA_DEL_IND", "HA_AR_UUID", "HA_IP_UUID", "HA_LE_CD", "HA_ROLE_TYPE", "HA_OPER_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SB_AR_X_IP_ID,
    D1_IP_ID,
    D2_IP_ID,
    D1_AR_ID,
    D2_AR_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    TA_HASH_VAL,
    TA_AR_TYPE,
    HA_DEL_IND,
    HA_AR_UUID,
    HA_IP_UUID,
    HA_LE_CD,
    HA_ROLE_TYPE,
    HA_OPER_STATUS_TYPE,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_AR__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_AR__DM_OCR_OFFLINERPT_NL_VW" ("SB_AR_1_X_AR_2_ID", "D1_AR_1_ID", "D2_AR_1_ID", "D1_AR_2_ID", "D2_AR_2_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "HA_DEL_IND", "HA_AR_1_UUID", "HA_AR_2_UUID", "HA_AR_1_TYPE", "HA_AR_1_DTL_TYPE", "HA_AR_2_TYPE", "HA_AR_2_DTL_TYPE", "HA_LE_CD", "HA_TYPE", "HA_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SB_AR_1_X_AR_2_ID,
    D1_AR_1_ID,
    D2_AR_1_ID,
    D1_AR_2_ID,
    D2_AR_2_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    TA_HASH_VAL,
    HA_DEL_IND,
    HA_AR_1_UUID,
    HA_AR_2_UUID,
    HA_AR_1_TYPE,
    HA_AR_1_DTL_TYPE,
    HA_AR_2_TYPE,
    HA_AR_2_DTL_TYPE,
    HA_LE_CD,
    HA_TYPE,
    HA_STATUS_TYPE,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_AR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_PAY_REPORTING_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, A.CA_CID_NBR
, NVL(HA_CRN_IND,'N') AS TA_CRN_IND
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_INGENTITY_CD
, HA_NCKNM
, HA_AR_UUID
, HA_AR_ID_TP
,HA_AMA_ID
,HA_BE_GRP_ID
,HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM (SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR S LEFT JOIN (SELECT A.VALUE AS CA_CID_NBR,
A.IDENTIFIER FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW A
WHERE ((A.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS'))
AND (A.TYPE = 'NL_CORBANK_ID'))) A ON ((S.TA_KEY = ('MDM.' || A.IDENTIFIER))));"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_AR__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_AR__SL_CHV_CIM_XU_VW" ("SB_AR_1_X_AR_2_ID", "D1_AR_1_ID", "D2_AR_1_ID", "D1_AR_2_ID", "D2_AR_2_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "HA_DEL_IND", "HA_AR_1_UUID", "HA_AR_2_UUID", "HA_AR_1_TYPE", "HA_AR_1_DTL_TYPE", "HA_AR_2_TYPE", "HA_AR_2_DTL_TYPE", "HA_LE_CD", "HA_TYPE", "HA_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SB_AR_1_X_AR_2_ID,
    D1_AR_1_ID,
    D2_AR_1_ID,
    D1_AR_2_ID,
    D2_AR_2_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    TA_HASH_VAL,
    HA_DEL_IND,
    HA_AR_1_UUID,
    HA_AR_2_UUID,
    HA_AR_1_TYPE,
    HA_AR_1_DTL_TYPE,
    HA_AR_2_TYPE,
    HA_AR_2_DTL_TYPE,
    HA_LE_CD,
    HA_TYPE,
    HA_STATUS_TYPE,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_AR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__DM_KRO_KROV_NL_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_LAST_UDT_TMS", "TA_PCS_LAST_UDT_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_HLDR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_LAST_UDT_TMS
, TA_PCS_LAST_UDT_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, CA_HLDR_CD
, CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_FRM_FCS_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_FRM_FCS_MULTI_NL_VW" ("SB_AR_X_IP_ID", "D1_IP_ID", "D2_IP_ID", "D1_AR_ID", "D2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "TA_AR_TYPE", "HA_DEL_IND", "HA_AR_UUID", "HA_IP_UUID", "HA_LE_CD", "HA_ROLE_TYPE", "HA_OPER_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
   SB_AR_X_IP_ID,
D1_IP_ID,
D2_IP_ID,
D1_AR_ID,
D2_AR_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
TA_HASH_VAL,
TA_AR_TYPE,
HA_DEL_IND,
HA_AR_UUID,
HA_IP_UUID,
HA_LE_CD,
HA_ROLE_TYPE,
HA_OPER_STATUS_TYPE,
HA_EFF_DT,
HA_END_DT
FROM
    sl_cim_slt_owner.onepam_slt_b2_ar_x_ip;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_SAL_SALESFORCE_XU_VW" ("SB_AR_X_IP_ID", "D1_IP_ID", "D2_IP_ID", "D1_AR_ID", "D2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "TA_AR_TYPE", "TA_CRN_IND", "HA_DEL_IND", "HA_AR_UUID", "HA_IP_UUID", "HA_LE_CD", "HA_ROLE_TYPE", "HA_OPER_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
SB_AR_X_IP_ID,
D1_IP_ID,
D2_IP_ID,
D1_AR_ID,
D2_AR_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
TA_HASH_VAL,
TA_AR_TYPE,
CASE WHEN TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
HA_DEL_IND,
HA_AR_UUID,
HA_IP_UUID,
HA_LE_CD,
HA_ROLE_TYPE,
HA_OPER_STATUS_TYPE,
HA_EFF_DT,
HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_AR__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_AR__DM_SAL_SALESFORCE_XU_VW" ("SB_AR_1_X_AR_2_ID", "D1_AR_1_ID", "D2_AR_1_ID", "D1_AR_2_ID", "D2_AR_2_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "TA_CRN_IND", "HA_DEL_IND", "HA_AR_1_UUID", "HA_AR_2_UUID", "HA_AR_1_TYPE", "HA_AR_1_DTL_TYPE", "HA_AR_2_TYPE", "HA_AR_2_DTL_TYPE", "HA_LE_CD", "HA_TYPE", "HA_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
SB_AR_1_X_AR_2_ID,
D1_AR_1_ID,
D2_AR_1_ID,
D1_AR_2_ID,
D2_AR_2_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
TA_HASH_VAL,
CASE WHEN TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
HA_DEL_IND,
HA_AR_1_UUID,
HA_AR_2_UUID,
HA_AR_1_TYPE,
HA_AR_1_DTL_TYPE,
HA_AR_2_TYPE,
HA_AR_2_DTL_TYPE,
HA_LE_CD,
HA_TYPE,
HA_STATUS_TYPE,
HA_EFF_DT,
HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_AR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_AR__DM_FRM_FCS_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_AR__DM_FRM_FCS_MULTI_NL_VW" ("SB_AR_1_X_AR_2_ID", "D1_AR_1_ID", "D2_AR_1_ID", "D1_AR_2_ID", "D2_AR_2_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "HA_DEL_IND", "HA_AR_1_UUID", "HA_AR_2_UUID", "HA_AR_1_TYPE", "HA_AR_1_DTL_TYPE", "HA_AR_2_TYPE", "HA_AR_2_DTL_TYPE", "HA_LE_CD", "HA_TYPE", "HA_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
SB_AR_1_X_AR_2_ID,
D1_AR_1_ID,
D2_AR_1_ID,
D1_AR_2_ID,
D2_AR_2_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
TA_HASH_VAL,
HA_DEL_IND,
HA_AR_1_UUID,
HA_AR_2_UUID,
HA_AR_1_TYPE,
HA_AR_1_DTL_TYPE,
HA_AR_2_TYPE,
HA_AR_2_DTL_TYPE,
HA_LE_CD,
HA_TYPE,
HA_STATUS_TYPE,
HA_EFF_DT,
HA_END_DT
FROM
    sl_cim_slt_owner.onepam_slt_b2_ar_x_ar;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_BLS_BL_REP_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_INGENTITY_CD
, HA_NCKNM
, HA_AR_UUID
, HA_AR_ID_TP
,HA_AMA_ID
,HA_BE_GRP_ID
,HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_OCR_OFFLINERPT_NL_VW" ("SB_AR_X_IP_ID", "D1_IP_ID", "D2_IP_ID", "D1_AR_ID", "D2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "TA_AR_TYPE", "HA_DEL_IND", "HA_AR_UUID", "HA_IP_UUID", "HA_LE_CD", "HA_ROLE_TYPE", "HA_OPER_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SB_AR_X_IP_ID,
    D1_IP_ID,
    D2_IP_ID,
    D1_AR_ID,
    D2_AR_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    TA_HASH_VAL,
    TA_AR_TYPE,
    HA_DEL_IND,
    HA_AR_UUID,
    HA_IP_UUID,
    HA_LE_CD,
    HA_ROLE_TYPE,
    HA_OPER_STATUS_TYPE,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__SL_CHV_CIM_XU_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_LAST_UDT_TMS", "TA_PCS_LAST_UDT_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_HLDR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_LAST_UDT_TMS
, TA_PCS_LAST_UDT_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, CA_HLDR_CD
, CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_PAY_REPORTING_NL_VW" ("SB_AR_X_IP_ID", "D1_IP_ID", "D2_IP_ID", "D1_AR_ID", "D2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "TA_CRN_IND", "TA_AR_TYPE", "HA_DEL_IND", "HA_AR_UUID", "HA_IP_UUID", "HA_LE_CD", "HA_ROLE_TYPE", "HA_OPER_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    SB_AR_X_IP_ID,
    D1_IP_ID,
    D2_IP_ID,
    D1_AR_ID,
    D2_AR_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    TA_HASH_VAL,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    TA_AR_TYPE,
    HA_DEL_IND,
    HA_AR_UUID,
    HA_IP_UUID,
    HA_LE_CD,
    HA_ROLE_TYPE,
    HA_OPER_STATUS_TYPE,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__DM_OCR_OFFLINERPT_NL_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_LAST_UDT_TMS", "TA_PCS_LAST_UDT_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_HLDR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_LAST_UDT_TMS
, TA_PCS_LAST_UDT_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, CA_HLDR_CD
, CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_SAL_SALESFORCE_XU_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_INGENTITY_CD
, HA_NCKNM
, HA_AR_UUID
, HA_AR_ID_TP
,HA_AMA_ID
,HA_BE_GRP_ID
,HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D1_HLDR__DM_PAY_REPORTING_NL_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_LAST_UDT_TMS", "TA_PCS_LAST_UDT_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_HLDR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_LAST_UDT_TMS
, TA_PCS_LAST_UDT_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, CA_HLDR_CD
, CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_CHV_CSTCTC_MULTI_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 s1_ccy_id,
    s2_ccy_id,
    ta_key,
    ta_src_row_id,
    ta_hash_val,
    ta_vld_from_tms,
    ta_vld_to_tms,
    ta_pcs_isrt_id,
    ta_pcs_udt_id,
    ta_isrt_tms,
    ta_udt_tms,
    ha_ccy_cd,
    ha_ccy_nm,
    ha_iso_cd,
    ha_eff_dt,
    HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_COM_COM_XU_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 s1_ccy_id,
    s2_ccy_id,
    ta_key,
    ta_src_row_id,
    ta_hash_val,
    ta_vld_from_tms,
    ta_vld_to_tms,
    ta_pcs_isrt_id,
    ta_pcs_udt_id,
    ta_isrt_tms,
    ta_udt_tms,
    ha_ccy_cd,
    ha_ccy_nm,
    ha_iso_cd,
    ha_eff_dt,
    HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_FDS_FINREP_NL_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CCY_ID,
    S2_CCY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CCY_CD,
    HA_CCY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_PAY_REPORTING_NL_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CCY_ID,
    S2_CCY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CCY_CD,
    HA_CCY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_OCR_OFFLINERPT_NL_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CCY_ID,
    S2_CCY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CCY_CD,
    HA_CCY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CCY__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CCY__SL_CHV_CIM_XU_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CCY_ID,
    S2_CCY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CCY_CD,
    HA_CCY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CCY__DM_SAL_SALESFORCE_XU_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CCY_ID,
    S2_CCY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CCY_CD,
    HA_CCY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_BLS_BL_REP_NL_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CTRY_ID,
    S2_CTRY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_CTRY_CD,
    HA_CTRY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_PYS_FB_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_PYS_FB_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_AR_UUID", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_ID_TP", "HA_AR_CD", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_AR_UUID
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_INGENTITY_CD
, HA_NCKNM
, HA_AR_ID_TP
, HA_AR_CD
, HA_AMA_ID
, HA_BE_GRP_ID
, HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR
WHERE TA_VLD_TO_TMS=TO_TIMESTAMP('9999-12-31', 'YYYY-MM-DD')
and HA_DEL_IND='N'
AND HA_LE_CD in ('ING_NL','ING_NL_SHARED')
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR__DM_OCR_OFFLINERPT_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_INGENTITY_CD", "HA_NCKNM", "HA_AR_UUID", "HA_AR_ID_TP", "HA_AMA_ID", "HA_BE_GRP_ID", "HA_AR_IDNT", "HA_CRN_IND", "HA_AR_NAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, A.CA_CID_NBR
, NVL(HA_CRN_IND,'N') AS TA_CRN_IND
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_INGENTITY_CD
, HA_NCKNM
, HA_AR_UUID
, HA_AR_ID_TP
,HA_AMA_ID
,HA_BE_GRP_ID
,HA_AR_IDNT
,HA_CRN_IND
,HA_AR_NAME
FROM (SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR S LEFT JOIN (SELECT A.VALUE AS CA_CID_NBR,
A.IDENTIFIER FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_AR_AGREEMENT_IDENTIFIER__SL_CIM_CUSTOMER_INFO_XU_VW A
WHERE ((A.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS'))
AND (A.TYPE = 'NL_CORBANK_ID'))) A ON ((S.TA_KEY = ('MDM.' || A.IDENTIFIER))));"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_CHV_CSTCTC_MULTI_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CTRY_ID,
    S2_CTRY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_CTRY_CD,
    HA_CTRY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_AR_ST__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_AR_ST__DM_COM_COM_XU_VW" ("S1_AR_ST_ID", "S2_AR_ST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_AR_ST_CD", "HA_AR_ST_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_AR_ST_ID,
    S2_AR_ST_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_AR_ST_CD,
    HA_AR_ST_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_AR_ST;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_KRO_KROV_NL_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CTRY_ID,
    S2_CTRY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CTRY_CD,
    HA_CTRY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_OCR_OFFLINERPT_NL_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CTRY_ID,
    S2_CTRY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CTRY_CD,
    HA_CTRY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_COM_COM_XU_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CTRY_ID,
    S2_CTRY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_CTRY_CD,
    HA_CTRY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_PAY_REPORTING_NL_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CTRY_ID,
    S2_CTRY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CTRY_CD,
    HA_CTRY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__DM_SAL_SALESFORCE_XU_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CTRY_ID,
    S2_CTRY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CTRY_CD,
    HA_CTRY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_CTRY__SL_CHV_CIM_XU_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_CTRY_ID,
    S2_CTRY_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_CTRY_CD,
    HA_CTRY_NM,
    HA_ISO_CD,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_DBS_NIR_SGI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_DBS_NIR_SGI_NL_VW" ("TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "HA_IP_UUID", "HA_LE_CD", "HA_IP_TP_CD", "HA_IP_TP_IND", "HA_IP_NBR", "HA_GRID_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "HA_STRT_DT", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_BRTH_CITY_NM", "HA_GND_IND", "HA_JIVE_IND", "HA_RSDNT_CTRY_CD", "HA_ZIP_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_COLLAPSED_TO_IP_UUID", "HA_COLLAPSED_TO_IP_NBR", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_SEG_CD", "HA_SEG_CGY_CD", "HA_CRSP_NM", "HA_DEL_IND", "S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_HA
, HA_IP_UUID
, HA_LE_CD
, HA_IP_TP_CD
, HA_IP_TP_IND
, HA_IP_NBR
, HA_GRID_NBR
, HA_KVK_NBR
, HA_CSI_NBR
, HA_BE_NBR
, HA_STRT_DT
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_BRTH_CITY_NM
, HA_GND_IND
, HA_JIVE_IND
, HA_RSDNT_CTRY_CD
, HA_ZIP_CD
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, HA_FORMAL_NM
, HA_COLLAPSED_TO_IP_UUID
, HA_COLLAPSED_TO_IP_NBR
, HA_COLLAPSED_DT
, HA_COLLAPSED_IND
, HA_END_DT
, HA_PRFL_CCNT_IND
, HA_RGHT_TO_OBJ_IND
, HA_TEL_NBR
, HA_EMAIL_ADR
, HA_SEG_CD
, HA_SEG_CGY_CD
, HA_CRSP_NM
, HA_DEL_IND
, S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, HA_AGE
, HA_MINOR_IND
, HA_DCSD_IND
, HA_CLS_ORG_DT
, HA_CTRY_INC
, HA_INACTIVE_DT
, HA_LCS_TP
, HA_FNC_LGL_ST_TP
, HA_LGL_CMPNC_ST_TP
, HA_FRST_NM_1
, HA_FRST_NM_2
, HA_FRST_NM_3
, HA_FRST_NM_4
, HA_GVN_NM
, HA_NCK_NM
, HA_SCD_LAST_NM
, HA_PRTN_LAST_NM
, HA_PRTN_LAST_NM_PFX
, HA_SALUT
, HA_CRSPD_CTRY_CD
, HA_CHANNEL_ENTRY
, HA_GRP_TYP
, HA_TEL_NBR_LAND
, HA_TEL_NBR_MBL
, HA_EMAIL_ADR_BSN
, HA_IP_EFF_DT
, HA_IP_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP
WHERE HA_IP_TP_IND='INDIV'
AND TA_VLD_TO_TMS= TO_TIMESTAMP ('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')
AND HA_DEL_IND='N'
AND HA_LE_CD IN ('ING_NL','ING_NL_SHARED')
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_BLS_BL_REP_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_BRTH_CITY_NM", "HA_FORMAL_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_COLLAPSED_TO_IP_NBR", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_IP_UUID", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_SEG_CD", "HA_CRSP_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "HA_SEG_CGY_CD", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_HA
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_ZIP_CD
, HA_LE_CD
, HA_BRTH_CITY_NM
, HA_FORMAL_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_COLLAPSED_TO_IP_NBR
, HA_COLLAPSED_DT
, HA_COLLAPSED_IND
, HA_END_DT
, HA_PRFL_CCNT_IND
, HA_RGHT_TO_OBJ_IND
, HA_IP_UUID
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, HA_TEL_NBR
, HA_EMAIL_ADR
, HA_SEG_CD
, HA_CRSP_NM
, HA_CSI_NBR
, HA_BE_NBR
, HA_DEL_IND
, HA_SEG_CGY_CD
, HA_AGE
, HA_MINOR_IND
, HA_DCSD_IND
, HA_CLS_ORG_DT
, HA_CTRY_INC
, HA_INACTIVE_DT
, HA_LCS_TP
, HA_FNC_LGL_ST_TP
, HA_LGL_CMPNC_ST_TP
, HA_FRST_NM_1
, HA_FRST_NM_2
, HA_FRST_NM_3
, HA_FRST_NM_4
, HA_GVN_NM
, HA_NCK_NM
, HA_SCD_LAST_NM
, HA_PRTN_LAST_NM
, HA_PRTN_LAST_NM_PFX
, HA_SALUT
, HA_CRSPD_CTRY_CD
, HA_CHANNEL_ENTRY
, HA_GRP_TYP
, HA_TEL_NBR_LAND
, HA_TEL_NBR_MBL
, HA_EMAIL_ADR_BSN
, HA_IP_EFF_DT
, HA_IP_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_COM_COM_XU_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_BRTH_CITY_NM", "HA_FORMAL_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_COLLAPSED_TO_IP_NBR", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_IP_UUID", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_SEG_CD", "HA_CRSP_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "HA_SEG_CGY_CD", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_HA
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_ZIP_CD
, HA_LE_CD
, HA_BRTH_CITY_NM
, HA_FORMAL_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_COLLAPSED_TO_IP_NBR
, HA_COLLAPSED_DT
, HA_COLLAPSED_IND
, HA_END_DT
, HA_PRFL_CCNT_IND
, HA_RGHT_TO_OBJ_IND
, HA_IP_UUID
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, HA_TEL_NBR
, HA_EMAIL_ADR
, HA_SEG_CD
, HA_CRSP_NM
, HA_CSI_NBR
, HA_BE_NBR
, HA_DEL_IND
, HA_SEG_CGY_CD
, HA_AGE
, HA_MINOR_IND
, HA_DCSD_IND
, HA_CLS_ORG_DT
, HA_CTRY_INC
, HA_INACTIVE_DT
, HA_LCS_TP
, HA_FNC_LGL_ST_TP
, HA_LGL_CMPNC_ST_TP
, HA_FRST_NM_1
, HA_FRST_NM_2
, HA_FRST_NM_3
, HA_FRST_NM_4
, HA_GVN_NM
, HA_NCK_NM
, HA_SCD_LAST_NM
, HA_PRTN_LAST_NM
, HA_PRTN_LAST_NM_PFX
, HA_SALUT
, HA_CRSPD_CTRY_CD
, HA_CHANNEL_ENTRY
, HA_GRP_TYP
, HA_TEL_NBR_LAND
, HA_TEL_NBR_MBL
, HA_EMAIL_ADR_BSN
, HA_IP_EFF_DT
, HA_IP_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_BSL_BASEL_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_BSL_BASEL_NL_VW" ("HA_IP_NBR", "HA_RSDNT_CTRY_CD", "HA_IP_TP_CD", "HA_SEG_CGY_CD", "HA_SEG_CD", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_DEL_IND", "HA_IP_UUID") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
HA_IP_NBR,
HA_RSDNT_CTRY_CD,
HA_IP_TP_CD,
HA_SEG_CGY_CD,
HA_SEG_CD,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
HA_DEL_IND,
HA_IP_UUID
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_FDS_FINREP_NL_VW" ("HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_COLLAPSED_TO_IP_NBR", "HA_CRSP_NM", "HA_EMAIL_ADR", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_SEG_CD", "HA_TEL_NBR", "HA_BE_NBR", "HA_BLD_NBR", "HA_BRTH_CITY_NM", "HA_BRTH_CTRY_CD", "HA_BRTH_DT", "HA_BRTH_DT_QLY_CD", "HA_CSI_NBR", "HA_CTY_NM", "HA_DCSD_DT", "HA_ESTB_DT", "HA_FORMAL_NM", "HA_GND_IND", "HA_GRID_NBR", "HA_INIT_NM", "HA_IP_NBR", "HA_IP_TP_CD", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_KVK_NBR", "HA_LE_CD", "HA_LGL_FORM_CD", "HA_LST_NM", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PREPSTN_NM", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_STR_NM", "HA_STRT_DT", "HA_UNIT_NBR", "HA_IP_UUID", "HA_ZIP_CD", "S1_IP_ID", "S2_IP_ID", "TA_CRN_IND", "TA_HASH_VAL_HA", "TA_ISRT_TMS", "TA_KEY", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_SRC_ROW_ID", "TA_UDT_TMS", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
	HA_COLLAPSED_DT,
	HA_COLLAPSED_IND,
	HA_COLLAPSED_TO_IP_NBR,
	HA_CRSP_NM,
	HA_EMAIL_ADR,
	HA_END_DT,
	HA_PRFL_CCNT_IND,
	HA_RGHT_TO_OBJ_IND,
	HA_SEG_CD,
	HA_TEL_NBR,
	HA_BE_NBR,
	HA_BLD_NBR,
	HA_BRTH_CITY_NM,
	HA_BRTH_CTRY_CD,
	HA_BRTH_DT,
	HA_BRTH_DT_QLY_CD,
	HA_CSI_NBR,
	HA_CTY_NM,
	HA_DCSD_DT,
	HA_ESTB_DT,
	HA_FORMAL_NM,
	HA_GND_IND,
	HA_GRID_NBR,
	HA_INIT_NM,
	HA_IP_NBR,
	HA_IP_TP_CD,
	HA_IP_TP_IND,
	HA_JIVE_IND,
	HA_KVK_NBR,
	HA_LE_CD,
	HA_LGL_FORM_CD,
	HA_LST_NM,
	HA_MGN_ENT_CD,
	HA_PREF_LANG_CD,
	HA_PREPSTN_NM,
	HA_PRIV_PREF_CD,
	HA_RSDNT_CTRY_CD,
	HA_STR_NM,
	HA_STRT_DT,
	HA_UNIT_NBR,
	HA_IP_UUID,
	HA_ZIP_CD,
	S1_IP_ID,
	S2_IP_ID,
	CASE WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
	TA_HASH_VAL_HA,
	TA_ISRT_TMS,
	TA_KEY,
	TA_PCS_ISRT_ID,
	TA_PCS_UDT_ID,
	TA_SRC_ROW_ID,
	TA_UDT_TMS,
	TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
	HA_AGE,
	HA_MINOR_IND,
	HA_DCSD_IND,
	HA_CLS_ORG_DT,
	HA_CTRY_INC,
	HA_INACTIVE_DT,
	HA_LCS_TP,
	HA_FNC_LGL_ST_TP,
	HA_LGL_CMPNC_ST_TP,
	HA_FRST_NM_1,
	HA_FRST_NM_2,
	HA_FRST_NM_3,
	HA_FRST_NM_4,
	HA_GVN_NM,
	HA_NCK_NM,
	HA_SCD_LAST_NM,
	HA_PRTN_LAST_NM,
	HA_PRTN_LAST_NM_PFX,
	HA_SALUT,
	HA_CRSPD_CTRY_CD,
	HA_CHANNEL_ENTRY,
	HA_GRP_TYP,
	HA_TEL_NBR_LAND,
	HA_TEL_NBR_MBL,
	HA_EMAIL_ADR_BSN,
	HA_IP_EFF_DT,
	HA_IP_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_SAL_SALESFORCE_XU_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_BRTH_CITY_NM", "HA_FORMAL_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_COLLAPSED_TO_IP_NBR", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_IP_UUID", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_SEG_CD", "HA_CRSP_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "HA_SEG_CGY_CD", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_HA
, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_ZIP_CD
, HA_LE_CD
, HA_BRTH_CITY_NM
, HA_FORMAL_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_COLLAPSED_TO_IP_NBR
, HA_COLLAPSED_DT
, HA_COLLAPSED_IND
, HA_END_DT
, HA_PRFL_CCNT_IND
, HA_RGHT_TO_OBJ_IND
, HA_IP_UUID
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, HA_TEL_NBR
, HA_EMAIL_ADR
, HA_SEG_CD
, HA_CRSP_NM
, HA_CSI_NBR
, HA_BE_NBR
, HA_DEL_IND
, HA_SEG_CGY_CD
, HA_AGE
, HA_MINOR_IND
, HA_DCSD_IND
, HA_CLS_ORG_DT
, HA_CTRY_INC
, HA_INACTIVE_DT
, HA_LCS_TP
, HA_FNC_LGL_ST_TP
, HA_LGL_CMPNC_ST_TP
, HA_FRST_NM_1
, HA_FRST_NM_2
, HA_FRST_NM_3
, HA_FRST_NM_4
, HA_GVN_NM
, HA_NCK_NM
, HA_SCD_LAST_NM
, HA_PRTN_LAST_NM
, HA_PRTN_LAST_NM_PFX
, HA_SALUT
, HA_CRSPD_CTRY_CD
, HA_CHANNEL_ENTRY
, HA_GRP_TYP
, HA_TEL_NBR_LAND
, HA_TEL_NBR_MBL
, HA_EMAIL_ADR_BSN
, HA_IP_EFF_DT
, HA_IP_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_KRO_KROV_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "HA_COLLAPSED_TO_IP_NBR", "HA_IP_UUID", "HA_LE_CD", "HA_SEG_CD", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_ZIP_CD", "HA_BRTH_CITY_NM", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_CRSP_NM", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_SEG_CGY_CD", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_HA
,  CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_CSI_NBR
, HA_BE_NBR
, HA_COLLAPSED_TO_IP_NBR
, HA_IP_UUID
, HA_LE_CD
, HA_SEG_CD
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_ZIP_CD
, HA_BRTH_CITY_NM
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, HA_FORMAL_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_TEL_NBR
, HA_EMAIL_ADR
, HA_CRSP_NM
, HA_COLLAPSED_DT
, HA_COLLAPSED_IND
, HA_END_DT
, HA_PRFL_CCNT_IND
, HA_RGHT_TO_OBJ_IND
, HA_SEG_CGY_CD
, HA_AGE
, HA_MINOR_IND
, HA_DCSD_IND
, HA_CLS_ORG_DT
, HA_CTRY_INC
, HA_INACTIVE_DT
, HA_LCS_TP
, HA_FNC_LGL_ST_TP
, HA_LGL_CMPNC_ST_TP
, HA_FRST_NM_1
, HA_FRST_NM_2
, HA_FRST_NM_3
, HA_FRST_NM_4
, HA_GVN_NM
, HA_NCK_NM
, HA_SCD_LAST_NM
, HA_PRTN_LAST_NM
, HA_PRTN_LAST_NM_PFX
, HA_SALUT
, HA_CRSPD_CTRY_CD
, HA_CHANNEL_ENTRY
, HA_GRP_TYP
, HA_TEL_NBR_LAND
, HA_TEL_NBR_MBL
, HA_EMAIL_ADR_BSN
, HA_IP_EFF_DT
, HA_IP_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_KYC_KYC_MULTI_NL_VW" ("HA_IP_NBR", "HA_JIVE_IND", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT HA_IP_NBR,
		HA_JIVE_IND,
		TA_VLD_TO_TMS
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_PAY_REPORTING_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "HA_COLLAPSED_TO_IP_NBR", "HA_IP_UUID", "HA_LE_CD", "HA_SEG_CD", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_ZIP_CD", "HA_BRTH_CITY_NM", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_DEL_IND", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_CRSP_NM", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_HA
, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_CSI_NBR
, HA_BE_NBR
, HA_COLLAPSED_TO_IP_NBR
, HA_IP_UUID
, HA_LE_CD
, HA_SEG_CD
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_ZIP_CD
, HA_BRTH_CITY_NM
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, HA_FORMAL_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_DEL_IND
, HA_TEL_NBR
, HA_EMAIL_ADR
, HA_CRSP_NM
, HA_COLLAPSED_DT
, HA_COLLAPSED_IND
, HA_END_DT
, HA_PRFL_CCNT_IND
, HA_RGHT_TO_OBJ_IND
, HA_AGE
, HA_MINOR_IND
, HA_DCSD_IND
, HA_CLS_ORG_DT
, HA_CTRY_INC
, HA_INACTIVE_DT
, HA_LCS_TP
, HA_FNC_LGL_ST_TP
, HA_LGL_CMPNC_ST_TP
, HA_FRST_NM_1
, HA_FRST_NM_2
, HA_FRST_NM_3
, HA_FRST_NM_4
, HA_GVN_NM
, HA_NCK_NM
, HA_SCD_LAST_NM
, HA_PRTN_LAST_NM
, HA_PRTN_LAST_NM_PFX
, HA_SALUT
, HA_CRSPD_CTRY_CD
, HA_CHANNEL_ENTRY
, HA_GRP_TYP
, HA_TEL_NBR_LAND
, HA_TEL_NBR_MBL
, HA_EMAIL_ADR_BSN
, HA_IP_EFF_DT
, HA_IP_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__SL_CHV_CIM_XU_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_IP_UUID", "HA_LE_CD", "HA_IP_TP_CD", "HA_IP_TP_IND", "HA_IP_NBR", "HA_GRID_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "HA_STRT_DT", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_BRTH_CITY_NM", "HA_GND_IND", "HA_JIVE_IND", "HA_RSDNT_CTRY_CD", "HA_ZIP_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_COLLAPSED_TO_IP_UUID", "HA_COLLAPSED_TO_IP_NBR", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_SEG_CD", "HA_SEG_CGY_CD", "HA_CRSP_NM", "HA_DEL_IND", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_IP_ID,
    S2_IP_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    TA_HASH_VAL_HA,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_IP_UUID,
    HA_LE_CD,
    HA_IP_TP_CD,
    HA_IP_TP_IND,
    HA_IP_NBR,
    HA_GRID_NBR,
    HA_KVK_NBR,
    HA_CSI_NBR,
    HA_BE_NBR,
    HA_STRT_DT,
    HA_BRTH_DT,
    HA_DCSD_DT,
    HA_ESTB_DT,
    HA_BRTH_CTRY_CD,
    HA_BRTH_DT_QLY_CD,
    HA_LGL_FORM_CD,
    HA_MGN_ENT_CD,
    HA_PREF_LANG_CD,
    HA_PRIV_PREF_CD,
    HA_BRTH_CITY_NM,
    HA_GND_IND,
    HA_JIVE_IND,
    HA_RSDNT_CTRY_CD,
    HA_ZIP_CD,
    HA_STR_NM,
    HA_CTY_NM,
    HA_BLD_NBR,
    HA_UNIT_NBR,
    HA_INIT_NM,
    HA_PREPSTN_NM,
    HA_LST_NM,
    HA_FORMAL_NM,
    HA_COLLAPSED_TO_IP_UUID,
    HA_COLLAPSED_TO_IP_NBR,
    HA_COLLAPSED_DT,
    HA_COLLAPSED_IND,
    HA_END_DT,
    HA_PRFL_CCNT_IND,
    HA_RGHT_TO_OBJ_IND,
    HA_TEL_NBR,
    HA_EMAIL_ADR,
    HA_SEG_CD,
    HA_SEG_CGY_CD,
    HA_CRSP_NM,
    HA_DEL_IND,
	HA_AGE,
	HA_MINOR_IND,
	HA_DCSD_IND,
	HA_CLS_ORG_DT,
	HA_CTRY_INC,
	HA_INACTIVE_DT,
	HA_LCS_TP,
	HA_FNC_LGL_ST_TP,
	HA_LGL_CMPNC_ST_TP,
	HA_FRST_NM_1,
	HA_FRST_NM_2,
	HA_FRST_NM_3,
	HA_FRST_NM_4,
	HA_GVN_NM,
	HA_NCK_NM,
	HA_SCD_LAST_NM,
	HA_PRTN_LAST_NM,
	HA_PRTN_LAST_NM_PFX,
	HA_SALUT,
	HA_CRSPD_CTRY_CD,
	HA_CHANNEL_ENTRY,
	HA_GRP_TYP,
	HA_TEL_NBR_LAND,
	HA_TEL_NBR_MBL,
	HA_EMAIL_ADR_BSN,
	HA_IP_EFF_DT,
	HA_IP_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_BSL_BASEL_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_BSL_BASEL_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_PD_ID,
S2_PD_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_HASH_VAL,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
CASE WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END TA_CRN_IND,
HA_PD_INT_CD,
HA_PD_CD,
HA_PD_NM,
HA_PD_CGY_CD,
HA_PD_CGY_NM,
HA_EFF_DT,
HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_BLS_BL_REP_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = '31-DEC-99') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_COM_COM_XU_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_CHV_CSTCTC_MULTI_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_OCR_OFFLINERPT_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_BRTH_CITY_NM", "HA_FORMAL_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_COLLAPSED_TO_IP_NBR", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_IP_UUID", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_SEG_CD", "HA_CRSP_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "HA_SEG_CGY_CD", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_HA
, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_ZIP_CD
, HA_LE_CD
, HA_BRTH_CITY_NM
, HA_FORMAL_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_COLLAPSED_TO_IP_NBR
, HA_COLLAPSED_DT
, HA_COLLAPSED_IND
, HA_END_DT
, HA_PRFL_CCNT_IND
, HA_RGHT_TO_OBJ_IND
, HA_IP_UUID
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, HA_TEL_NBR
, HA_EMAIL_ADR
, HA_SEG_CD
, HA_CRSP_NM
, HA_CSI_NBR
, HA_BE_NBR
, HA_DEL_IND
, HA_SEG_CGY_CD
, HA_AGE
, HA_MINOR_IND
, HA_DCSD_IND
, HA_CLS_ORG_DT
, HA_CTRY_INC
, HA_INACTIVE_DT
, HA_LCS_TP
, HA_FNC_LGL_ST_TP
, HA_LGL_CMPNC_ST_TP
, HA_FRST_NM_1
, HA_FRST_NM_2
, HA_FRST_NM_3
, HA_FRST_NM_4
, HA_GVN_NM
, HA_NCK_NM
, HA_SCD_LAST_NM
, HA_PRTN_LAST_NM
, HA_PRTN_LAST_NM_PFX
, HA_SALUT
, HA_CRSPD_CTRY_CD
, HA_CHANNEL_ENTRY
, HA_GRP_TYP
, HA_TEL_NBR_LAND
, HA_TEL_NBR_MBL
, HA_EMAIL_ADR_BSN
, HA_IP_EFF_DT
, HA_IP_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_CRM_DOD_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_CRM_DOD_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_PD_ID,
S2_PD_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_HASH_VAL,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
HA_PD_INT_CD,
HA_PD_CD,
HA_PD_NM,
HA_PD_CGY_CD,
HA_PD_CGY_NM,
HA_EFF_DT,
HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_FRM_FCS_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_FRM_FCS_MULTI_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "HA_IP_UUID", "HA_LE_CD", "HA_IP_TP_CD", "HA_IP_TP_IND", "HA_IP_NBR", "HA_GRID_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "HA_STRT_DT", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_BRTH_CITY_NM", "HA_GND_IND", "HA_JIVE_IND", "HA_RSDNT_CTRY_CD", "HA_ZIP_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_COLLAPSED_TO_IP_UUID", "HA_COLLAPSED_TO_IP_NBR", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
   S1_IP_ID,
S2_IP_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
TA_HASH_VAL_HA,
HA_IP_UUID,
HA_LE_CD,
HA_IP_TP_CD,
HA_IP_TP_IND,
HA_IP_NBR,
HA_GRID_NBR,
HA_KVK_NBR,
HA_CSI_NBR,
HA_BE_NBR,
HA_STRT_DT,
HA_BRTH_DT,
HA_DCSD_DT,
HA_ESTB_DT,
HA_BRTH_CTRY_CD,
HA_BRTH_DT_QLY_CD,
HA_LGL_FORM_CD,
HA_MGN_ENT_CD,
HA_PREF_LANG_CD,
HA_PRIV_PREF_CD,
HA_BRTH_CITY_NM,
HA_GND_IND,
HA_JIVE_IND,
HA_RSDNT_CTRY_CD,
HA_ZIP_CD,
HA_STR_NM,
HA_CTY_NM,
HA_BLD_NBR,
HA_UNIT_NBR,
HA_INIT_NM,
HA_PREPSTN_NM,
HA_LST_NM,
HA_FORMAL_NM,
HA_COLLAPSED_TO_IP_UUID,
HA_COLLAPSED_TO_IP_NBR,
HA_COLLAPSED_DT,
HA_COLLAPSED_IND,
HA_END_DT,
HA_PRFL_CCNT_IND,
HA_AGE,
HA_MINOR_IND,
HA_DCSD_IND,
HA_CLS_ORG_DT,
HA_CTRY_INC,
HA_INACTIVE_DT,
HA_LCS_TP,
HA_FNC_LGL_ST_TP,
HA_LGL_CMPNC_ST_TP,
HA_FRST_NM_1,
HA_FRST_NM_2,
HA_FRST_NM_3,
HA_FRST_NM_4,
HA_GVN_NM,
HA_NCK_NM,
HA_SCD_LAST_NM,
HA_PRTN_LAST_NM,
HA_PRTN_LAST_NM_PFX,
HA_SALUT,
HA_CRSPD_CTRY_CD,
HA_CHANNEL_ENTRY,
HA_GRP_TYP,
HA_TEL_NBR_LAND,
HA_TEL_NBR_MBL,
HA_EMAIL_ADR_BSN,
HA_IP_EFF_DT,
HA_IP_END_DT
FROM
    sl_cim_slt_owner.onepam_slt_d7_ip;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_CHV_CSTCTC_MULTI_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_IP_UUID", "HA_LE_CD", "HA_IP_TP_CD", "HA_IP_TP_IND", "HA_IP_NBR", "HA_GRID_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "HA_STRT_DT", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_BRTH_CITY_NM", "HA_GND_IND", "HA_JIVE_IND", "HA_RSDNT_CTRY_CD", "HA_ZIP_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_COLLAPSED_TO_IP_UUID", "HA_COLLAPSED_TO_IP_NBR", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_SEG_CD", "HA_SEG_CGY_CD", "HA_CRSP_NM", "HA_DEL_IND", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN", "HA_IP_EFF_DT", "HA_IP_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_IP_ID,
    S2_IP_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    TA_HASH_VAL_HA,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_IP_UUID,
    HA_LE_CD,
    HA_IP_TP_CD,
    HA_IP_TP_IND,
    HA_IP_NBR,
    HA_GRID_NBR,
    HA_KVK_NBR,
    HA_CSI_NBR,
    HA_BE_NBR,
    HA_STRT_DT,
    HA_BRTH_DT,
    HA_DCSD_DT,
    HA_ESTB_DT,
    HA_BRTH_CTRY_CD,
    HA_BRTH_DT_QLY_CD,
    HA_LGL_FORM_CD,
    HA_MGN_ENT_CD,
    HA_PREF_LANG_CD,
    HA_PRIV_PREF_CD,
    HA_BRTH_CITY_NM,
    HA_GND_IND,
    HA_JIVE_IND,
    HA_RSDNT_CTRY_CD,
    HA_ZIP_CD,
    HA_STR_NM,
    HA_CTY_NM,
    HA_BLD_NBR,
    HA_UNIT_NBR,
    HA_INIT_NM,
    HA_PREPSTN_NM,
    HA_LST_NM,
    HA_FORMAL_NM,
    HA_COLLAPSED_TO_IP_UUID,
    HA_COLLAPSED_TO_IP_NBR,
    HA_COLLAPSED_DT,
    HA_COLLAPSED_IND,
    HA_END_DT,
    HA_PRFL_CCNT_IND,
    HA_RGHT_TO_OBJ_IND,
    HA_TEL_NBR,
    HA_EMAIL_ADR,
    HA_SEG_CD,
    HA_SEG_CGY_CD,
    HA_CRSP_NM,
    HA_DEL_IND,
	HA_AGE,
	HA_MINOR_IND,
	HA_DCSD_IND,
	HA_CLS_ORG_DT,
	HA_CTRY_INC,
	HA_INACTIVE_DT,
	HA_LCS_TP,
	HA_FNC_LGL_ST_TP,
	HA_LGL_CMPNC_ST_TP,
	HA_FRST_NM_1,
	HA_FRST_NM_2,
	HA_FRST_NM_3,
	HA_FRST_NM_4,
	HA_GVN_NM,
	HA_NCK_NM,
	HA_SCD_LAST_NM,
	HA_PRTN_LAST_NM,
	HA_PRTN_LAST_NM_PFX,
	HA_SALUT,
	HA_CRSPD_CTRY_CD,
	HA_CHANNEL_ENTRY,
	HA_GRP_TYP,
	HA_TEL_NBR_LAND,
	HA_TEL_NBR_MBL,
	HA_EMAIL_ADR_BSN,
	HA_IP_EFF_DT,
	HA_IP_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_FDS_FINREP_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_PAY_REPORTING_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_OCR_OFFLINERPT_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_KRO_KROV_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_PYS_FB_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_PYS_FB_NL_VW" ("HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT", "S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_PD_INT_CD", "HA_PD_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  HA_PD_NM
, HA_PD_CGY_CD
, HA_PD_CGY_NM
, HA_EFF_DT
, HA_END_DT
, S1_PD_ID
, S2_PD_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_PD_INT_CD
, HA_PD_CD
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
WHERE TA_VLD_TO_TMS=TO_TIMESTAMP('9999-12-31', 'YYYY-MM-DD')
AND HA_PD_CGY_CD='CC'
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_SAL_SALESFORCE_XU_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_XAM_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_XAM_REPORTING_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_PYS_PYMNTS_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__DM_PYS_PYMNTS_NL_VW" ("HA_PD_CD", "HA_PD_CGY_CD", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
HA_PD_CD
, HA_PD_CGY_CD
, TA_VLD_TO_TMS
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_BLS_BL_REP_NL_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SBI_CD", "HA_SBI_NM", "HA_CL_TP", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SBI_ID,
    S2_SBI_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_SBI_CD,
    HA_SBI_NM,
    HA_CL_TP,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_COM_COM_XU_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SBI_CD", "HA_SBI_NM", "HA_CL_TP", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SBI_ID,
    S2_SBI_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_SBI_CD,
    HA_SBI_NM,
    HA_CL_TP,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_CHV_CSTCTC_MULTI_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SBI_CD", "HA_SBI_NM", "HA_CL_TP", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SBI_ID,
    S2_SBI_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_SBI_CD,
    HA_SBI_NM,
    HA_CL_TP,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_PD__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_PD__SL_CHV_CIM_XU_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_INT_CD", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_PD_ID,
    S2_PD_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_PD_INT_CD,
    HA_PD_CD,
    HA_PD_NM,
    HA_PD_CGY_CD,
    HA_PD_CGY_NM,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_SAL_SALESFORCE_XU_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SBI_CD", "HA_SBI_NM", "HA_CL_TP", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_SBI_ID,
S2_SBI_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_HASH_VAL,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
CASE WHEN TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
HA_SBI_CD,
HA_SBI_NM,
HA_CL_TP,
HA_EFF_DT,
HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_PAY_REPORTING_NL_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SBI_CD", "HA_SBI_NM", "HA_CL_TP", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SBI_ID,
    S2_SBI_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_SBI_CD,
    HA_SBI_NM,
    HA_CL_TP,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_CHV_CSTCTC_MULTI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_CHV_CSTCTC_MULTI_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_LVL", "HA_GRP_TP", "HA_GRP_DSC", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SEG_ID,
    S2_SEG_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_SEG_CD,
    HA_SEG_NM,
    HA_SEG_CGY_CD,
    HA_SEG_CGY_NM,
    HA_LVL,
    HA_GRP_TP,
    HA_GRP_DSC,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SBI__DM_OCR_OFFLINERPT_NL_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SBI_CD", "HA_SBI_NM", "HA_CL_TP", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SBI_ID,
    S2_SBI_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_SBI_CD,
    HA_SBI_NM,
    HA_CL_TP,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_BLS_BL_REP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_BLS_BL_REP_NL_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_LVL", "HA_GRP_TP", "HA_GRP_DSC", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SEG_ID,
    S2_SEG_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_SEG_CD,
    HA_SEG_NM,
    HA_SEG_CGY_CD,
    HA_SEG_CGY_NM,
    HA_LVL,
    HA_GRP_TP,
    HA_GRP_DSC,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_FDS_FINREP_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_FDS_FINREP_NL_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_LVL", "HA_GRP_TP", "HA_GRP_DSC", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SEG_ID,
    S2_SEG_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_SEG_CD,
    HA_SEG_NM,
    HA_SEG_CGY_CD,
    HA_SEG_CGY_NM,
    HA_LVL,
    HA_GRP_TP,
    HA_GRP_DSC,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SBI__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SBI__SL_CHV_CIM_XU_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SBI_CD", "HA_SBI_NM", "HA_CL_TP", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SBI_ID,
    S2_SBI_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_SBI_CD,
    HA_SBI_NM,
    HA_CL_TP,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_COM_COM_XU_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_LVL", "HA_GRP_TP", "HA_GRP_DSC", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SEG_ID,
    S2_SEG_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_SEG_CD,
    HA_SEG_NM,
    HA_SEG_CGY_CD,
    HA_SEG_CGY_NM,
    HA_LVL,
    HA_GRP_TP,
    HA_GRP_DSC,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_PAY_REPORTING_NL_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_LVL", "HA_GRP_TP", "HA_GRP_DSC", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SEG_ID,
    S2_SEG_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_SEG_CD,
    HA_SEG_NM,
    HA_SEG_CGY_CD,
    HA_SEG_CGY_NM,
    HA_LVL,
    HA_GRP_TP,
    HA_GRP_DSC,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_OCR_OFFLINERPT_NL_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_LVL", "HA_GRP_TP", "HA_GRP_DSC", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SEG_ID,
    S2_SEG_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
    HA_SEG_CD,
    HA_SEG_NM,
    HA_SEG_CGY_CD,
    HA_SEG_CGY_NM,
    HA_LVL,
    HA_GRP_TP,
    HA_GRP_DSC,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SEG__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SEG__SL_CHV_CIM_XU_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_LVL", "HA_GRP_TP", "HA_GRP_DSC", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SEG_ID,
    S2_SEG_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_SEG_CD,
    HA_SEG_NM,
    HA_SEG_CGY_CD,
    HA_SEG_CGY_NM,
    HA_LVL,
    HA_GRP_TP,
    HA_GRP_DSC,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_SAL_SALESFORCE_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_SEG__DM_SAL_SALESFORCE_XU_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_LVL", "HA_GRP_TP", "HA_GRP_DSC", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
    S1_SEG_ID,
    S2_SEG_ID,
    TA_KEY,
    TA_SRC_ROW_ID,
    TA_HASH_VAL,
    TA_VLD_FROM_TMS,
    TA_VLD_TO_TMS,
    TA_PCS_ISRT_ID,
    TA_PCS_UDT_ID,
    TA_ISRT_TMS,
    TA_UDT_TMS,
	CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
    HA_SEG_CD,
    HA_SEG_NM,
    HA_SEG_CGY_CD,
    HA_SEG_CGY_NM,
    HA_LVL,
    HA_GRP_TP,
    HA_GRP_DSC,
    HA_EFF_DT,
    HA_END_DT
FROM
    SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR__DM_PAY_REPORTING_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
--, CA_CID_NBR
, CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D1_HLDR__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D1_HLDR__DM_PAY_REPORTING_NL_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_LAST_UDT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_HLDR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_LAST_UDT_TMS
, CA_HLDR_CD
, CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CCY__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CCY__DM_PAY_REPORTING_NL_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CCY_ID
, S2_CCY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_CCY_CD
, HA_CCY_NM
, HA_ISO_CD
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CCY
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_PAY_REPORTING_NL_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CTRY_ID
, S2_CTRY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_CTRY_CD
, HA_CTRY_NM
, HA_ISO_CD
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CTRY
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_IP__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_IP__DM_PAY_REPORTING_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "CA_COLLAPSED_TO_IP_NBR", "HA_UUID_CD", "HA_LE_CD", "CA_SEG_CD", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_SBI_TP_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_ZIP_CD", "HA_BRTH_CITY_NM", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_TRD_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "HA_DEL_IND", "CA_TEL_NBR", "CA_EMAIL_ADR", "CA_CRSP_NM", "CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_CA
, TA_HASH_VAL_HA
, CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_CSI_NBR
, HA_BE_NBR
, CA_COLLAPSED_TO_IP_NBR
, HA_UUID_CD
, HA_LE_CD
, CA_SEG_CD
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_SBI_TP_CD
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_ZIP_CD
, HA_BRTH_CITY_NM
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, HA_FORMAL_NM
, HA_TRD_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_WWFT_CMPLN_IND
, HA_DEL_IND
, CA_TEL_NBR
, CA_EMAIL_ADR
, CA_CRSP_NM
, CA_COLLAPSED_DT
, CA_COLLAPSED_IND
, CA_END_DT
, CA_PRFL_CCNT_IND
, CA_RGHT_TO_OBJ_IND
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_PD__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_PD__DM_PAY_REPORTING_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_PD_ID
, S2_PD_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_PD_CD
, HA_PD_NM
, HA_PD_CGY_CD
, HA_PD_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SBI__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SBI__DM_PAY_REPORTING_NL_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SBI_CD", "HA_SBI_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SBI_ID
, S2_SBI_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_SBI_CD
, HA_SBI_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SBI
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SEG__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SEG__DM_PAY_REPORTING_NL_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SEG_ID
, S2_SEG_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = '31-DEC-9999') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_SEG_CD
, HA_SEG_NM
, HA_SEG_CGY_CD
, HA_SEG_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SEG
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_FP_PD_PSSN__DM_PAY_REPORTING_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_FP_PD_PSSN__DM_PAY_REPORTING_NL_VW" ("SP_PD_PSSN_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "D1_AR_ID", "D2_AR_ID", "D1_PD_ID", "D2_PD_ID", "D1_IP_ID", "D2_IP_ID", "D1_HLDR_ID", "D1_DT_ID", "D1_CCY_ID", "D2_CCY_ID", "D1_SEG_ID", "D2_SEG_ID", "FA_LE_CD", "AM_NBR", "NM_AGE_NBR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  SP_PD_PSSN_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, D1_AR_ID
, D2_AR_ID
, D1_PD_ID
, D2_PD_ID
, D1_IP_ID
, D2_IP_ID
, D1_HLDR_ID
, D1_DT_ID
, D1_CCY_ID
, D2_CCY_ID
, D1_SEG_ID
, D2_SEG_ID
, FA_LE_CD
, AM_NBR
, NM_AGE_NBR
FROM SL_CIM_SLT_OWNER.CIM_SLT_FP_PD_PSSN
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_EXTERNAL_IDENTIFIER_S_VW__DM_SAL_SALES_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_EXTERNAL_IDENTIFIER_S_VW__DM_SAL_SALES_XU_VW" ("IP_EXTERNAL_IDENTIFIER_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "IP_EXT_ID_TYP", "DATEOFISSUE", "EXPIRYDATE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEDATE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_EXTERNAL_IDENTIFIER_S_ID,
SRC_STM_KEY,
HASH_VAL,
VLD_FROM_TMS,
VLD_TO_TMS,
DEL_IN_SRC_STM_F,
ISRT_JOB_RUN_ID,
UDT_JOB_RUN_ID,
ISRT_TMS,
UDT_TMS,
IP_UUID,
IP_EXT_ID_TYP,
DATEOFISSUE,
EXPIRYDATE,
EFFECTIVEDATE,
ENDDATE,
LASTUPDATEDATE,
ACCESSTOKEN
FROM SL_CIM_SLV_OWNER.CIM_ILV_IP_EXTERNAL_IDENTIFIER_S_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_CITIZENSHIP_S_VW__DM_SAL_SALES_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_CITIZENSHIP_S_VW__DM_SAL_SALES_XU_VW" ("IP_CITIZENSHIP_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "IP_UUID", "CTRY_CITIZENSHIP", "RANK", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_CITIZENSHIP_S_ID,
SRC_STM_KEY,
HASH_VAL,
VLD_FROM_TMS,
VLD_TO_TMS,
DEL_IN_SRC_STM_F,
ISRT_JOB_RUN_ID,
UDT_JOB_RUN_ID,
ISRT_TMS,
UDT_TMS,
ACCESSTOKEN,
IP_UUID,
CTRY_CITIZENSHIP,
RANK,
EFFECTIVEDATE,
ENDDATE,
LASTUPDATEUSER,
LASTUPDATEDATE
FROM SL_CIM_SLV_OWNER.CIM_ILV_IP_CITIZENSHIP_S_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SBI__DM_OCR_OFFLINERPT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SBI__DM_OCR_OFFLINERPT_NL_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SBI_CD", "HA_SBI_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SBI_ID
, S2_SBI_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_SBI_CD
, HA_SBI_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D7_IP__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D7_IP__SL_CHV_CIM_XU_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "CA_COLLAPSED_TO_IP_NBR", "HA_UUID_CD", "HA_LE_CD", "CA_SEG_CD", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_SBI_TP_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_ZIP_CD", "HA_BRTH_CITY_NM", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_TRD_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "HA_DEL_IND", "CA_TEL_NBR", "CA_EMAIL_ADR", "CA_CRSP_NM", "CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "CA_SEG_CGY_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 IP.S1_IP_ID,
 IP.S2_IP_ID,
 IP.TA_KEY,
 IP.TA_SRC_ROW_ID,
 IP.TA_VLD_FROM_TMS,
 IP.TA_VLD_TO_TMS,
 IP.TA_PCS_ISRT_ID,
 IP.TA_PCS_UDT_ID,
 IP.TA_ISRT_TMS,
 IP.TA_UDT_TMS,
 IP.TA_HASH_VAL_CA,
 IP.TA_HASH_VAL_HA,
CASE
WHEN (IP.TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 IP.HA_GRID_NBR,
 IP.HA_IP_NBR,
 IP.HA_KVK_NBR,
 IP.HA_CSI_NBR,
 IP.HA_BE_NBR,
 IP.CA_COLLAPSED_TO_IP_NBR,
 IP.HA_UUID_CD,
 IP.HA_LE_CD,
 IP.CA_SEG_CD,
 IP.HA_BRTH_DT,
 IP.HA_DCSD_DT,
 IP.HA_ESTB_DT,
 IP.HA_STRT_DT,
 IP.HA_BRTH_CTRY_CD,
 IP.HA_BRTH_DT_QLY_CD,
 IP.HA_IP_TP_CD,
 IP.HA_LGL_FORM_CD,
 IP.HA_MGN_ENT_CD,
 IP.HA_PREF_LANG_CD,
 IP.HA_PRIV_PREF_CD,
 IP.HA_RSDNT_CTRY_CD,
 IP.HA_SBI_TP_CD,
 IP.HA_STR_NM,
 IP.HA_CTY_NM,
 IP.HA_BLD_NBR,
 IP.HA_UNIT_NBR,
 IP.HA_ZIP_CD,
 IP.HA_BRTH_CITY_NM,
 IP.HA_INIT_NM,
 IP.HA_PREPSTN_NM,
 IP.HA_LST_NM,
 IP.HA_FORMAL_NM,
 IP.HA_TRD_NM,
 IP.HA_GND_IND,
 IP.HA_IP_TP_IND,
 IP.HA_JIVE_IND,
 IP.HA_WWFT_CMPLN_IND,
 IP.HA_DEL_IND,
 IP.CA_TEL_NBR,
 IP.CA_EMAIL_ADR,
 IP.CA_CRSP_NM,
 IP.CA_COLLAPSED_DT,
 IP.CA_COLLAPSED_IND,
 IP.CA_END_DT,
 IP.CA_PRFL_CCNT_IND,
 IP.CA_RGHT_TO_OBJ_IND,
 IP.CA_SEG_CGY_CD
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D1_HLDR__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D1_HLDR__SL_CHV_CIM_XU_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_LAST_UDT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_HLDR_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_LAST_UDT_TMS,
CA_HLDR_CD,
CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D2_MGN_ENT__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D2_MGN_ENT__SL_CHV_CIM_XU_VW" ("D2_IP_ME_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_MGN_ENT_TP_CD", "HA_MGN_ENT_TP_NM", "HA_MGN_ENT_CD", "HA_MGN_ENT_STRT_TMS", "HA_MGN_ENT_END_TMS", "HA_IP_TP_IND", "HA_IP_NBR", "HA_LE_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 IP_PMANAENT_V_ID AS D2_IP_ME_ID,
 ('MDM.' || PARTYID_SRC) AS TA_KEY,
 IP_ID AS TA_SRC_ROW_ID,
 VLD_FROM_TMS AS TA_VLD_FROM_TMS,
 VLD_TO_TMS AS TA_VLD_TO_TMS,
 PCS_ISRT_ID AS TA_PCS_ISRT_ID,
 PCS_UDT_ID AS TA_PCS_UDT_ID,
 ISRT_TMS AS TA_ISRT_TMS,
 UDT_TMS AS TA_UDT_TMS,
 MANAGINGENTITYTYPECODE AS HA_MGN_ENT_TP_CD,
 MANAGINGENTITYTYPENAME AS HA_MGN_ENT_TP_NM,
 MANAGINGENTITYVALUE AS HA_MGN_ENT_CD,
 MANAGINGENTITYSTARTED AS HA_MGN_ENT_STRT_TMS,
 MANAGINGENTITYENDED AS HA_MGN_ENT_END_TMS,
 PARTYTYPE AS HA_IP_TP_IND,
 PARTYID_SRC AS HA_IP_NBR,
 ACCESSTOKEN AS HA_LE_CD
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PMANAENT_V__SL_CHV_CIM_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D7_AR_ST__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D7_AR_ST__SL_CHV_CIM_XU_VW" ("S1_AR_ST_ID", "S2_AR_ST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_AR_ST_CD", "HA_AR_ST_NM", "HA_AR_ST_CGY_CD", "HA_AR_ST_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 S1_AR_ST_ID,
 S2_AR_ST_ID,
 TA_KEY,
 TA_SRC_ROW_ID,
 TA_HASH_VAL,
 TA_VLD_FROM_TMS,
 TA_VLD_TO_TMS,
 TA_PCS_ISRT_ID,
 TA_PCS_UDT_ID,
 TA_ISRT_TMS,
 TA_UDT_TMS,
CASE
WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 HA_AR_ST_CD,
 HA_AR_ST_NM,
 HA_AR_ST_CGY_CD,
 HA_AR_ST_CGY_NM,
 HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR_ST;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D7_CCY__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D7_CCY__SL_CHV_CIM_XU_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 S1_CCY_ID,
 S2_CCY_ID,
 TA_KEY,
 TA_SRC_ROW_ID,
 TA_HASH_VAL,
 TA_VLD_FROM_TMS,
 TA_VLD_TO_TMS,
 TA_PCS_ISRT_ID,
 TA_PCS_UDT_ID,
 TA_ISRT_TMS,
 TA_UDT_TMS,
CASE
WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 HA_CCY_CD,
 HA_CCY_NM,
 HA_ISO_CD,
 HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CCY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D7_CTRY__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D7_CTRY__SL_CHV_CIM_XU_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 S1_CTRY_ID,
 S2_CTRY_ID,
 TA_KEY,
 TA_SRC_ROW_ID,
 TA_HASH_VAL,
 TA_VLD_FROM_TMS,
 TA_VLD_TO_TMS,
 TA_PCS_ISRT_ID,
 TA_PCS_UDT_ID,
 TA_ISRT_TMS,
 TA_UDT_TMS,
CASE
WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 HA_CTRY_CD,
 HA_CTRY_NM,
 HA_ISO_CD,
 HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CTRY;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D7_AR__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D7_AR__SL_CHV_CIM_XU_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 S.S1_AR_ID,
 S.S2_AR_ID,
 S.TA_KEY,
 S.TA_SRC_ROW_ID,
 S.TA_HASH_VAL,
 S.TA_VLD_FROM_TMS,
 S.TA_VLD_TO_TMS,
 S.TA_PCS_ISRT_ID,
 S.TA_PCS_UDT_ID,
 S.TA_ISRT_TMS,
 S.TA_UDT_TMS,
 A.CA_CID_NBR,
CASE
WHEN (S.TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 S.HA_OPN_DT,
 S.HA_END_DT,
 S.HA_ST_CD,
 S.HA_CCY_CD,
 S.HA_PD_CD,
 S.HA_LE_CD,
 S.HA_AR_NBR,
 S.HA_CMRCL_NBR,
 S.HA_BBAN_NBR,
 S.HA_IBAN_NBR,
 S.HA_INH_IND,
 S.HA_JIVE_IND,
 S.HA_DEL_IND
FROM (SL_CIM_SLT_OWNER.CIM_SLT_D7_AR S
LEFT JOIN (
SELECT A.ARRANGEMENTKEYID_SRC AS CA_CID_NBR, A.UUID_SRC
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__SL_CHV_CIM_XU_VW A
WHERE ((A.VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00')
AND (A.ARRANGEMENTKEYCODE = 8))) A ON ((S.TA_KEY = ('MDM.' || A.UUID_SRC))));"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D7_PD__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D7_PD__SL_CHV_CIM_XU_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 S1_PD_ID,
 S2_PD_ID,
 TA_KEY,
 TA_SRC_ROW_ID,
 TA_HASH_VAL,
 TA_VLD_FROM_TMS,
 TA_VLD_TO_TMS,
 TA_PCS_ISRT_ID,
 TA_PCS_UDT_ID,
 TA_ISRT_TMS,
 TA_UDT_TMS,
CASE
WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 HA_PD_CD,
 HA_PD_NM,
 HA_PD_CGY_CD,
 HA_PD_CGY_NM,
 HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D7_SBI__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D7_SBI__SL_CHV_CIM_XU_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SBI_CD", "HA_SBI_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 S1_SBI_ID,
 S2_SBI_ID,
 TA_KEY,
 TA_SRC_ROW_ID,
 TA_HASH_VAL,
 TA_VLD_FROM_TMS,
 TA_VLD_TO_TMS,
 TA_PCS_ISRT_ID,
 TA_PCS_UDT_ID,
 TA_ISRT_TMS,
 TA_UDT_TMS,
CASE
WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 HA_SBI_CD,
 HA_SBI_NM,
 HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D7_SEG__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D7_SEG__SL_CHV_CIM_XU_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 S1_SEG_ID,
 S2_SEG_ID,
 TA_KEY,
 TA_SRC_ROW_ID,
 TA_HASH_VAL,
 TA_VLD_FROM_TMS,
 TA_VLD_TO_TMS,
 TA_PCS_ISRT_ID,
 TA_PCS_UDT_ID,
 TA_ISRT_TMS,
 TA_UDT_TMS,
CASE
WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 HA_SEG_CD,
 HA_SEG_NM,
 HA_SEG_CGY_CD,
 HA_SEG_CGY_NM,
 HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SEG;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_FP_PD_PSSN__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_FP_PD_PSSN__SL_CHV_CIM_XU_VW" ("SP_PD_PSSN_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "D1_AR_ID", "D2_AR_ID", "D1_PD_ID", "D2_PD_ID", "D1_IP_ID", "D2_IP_ID", "D1_HLDR_ID", "D1_DT_ID", "D1_CCY_ID", "D2_CCY_ID", "D1_SEG_ID", "D2_SEG_ID", "FA_LE_CD", "AM_NBR", "NM_AGE_NBR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 SP_PD_PSSN_ID,
 TA_KEY,
 TA_SRC_ROW_ID,
 TA_PCS_ISRT_ID,
 TA_ISRT_TMS,
 D1_AR_ID,
 D2_AR_ID,
 D1_PD_ID,
 D2_PD_ID,
 D1_IP_ID,
 D2_IP_ID,
 D1_HLDR_ID,
 D1_DT_ID,
 D1_CCY_ID,
 D2_CCY_ID,
 D1_SEG_ID,
 D2_SEG_ID,
 FA_LE_CD,
 AM_NBR,
 NM_AGE_NBR
FROM SL_CIM_SLT_OWNER.CIM_SLT_FP_PD_PSSN;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_D7_SEG_HIST__SL_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_D7_SEG_HIST__SL_CHV_CIM_XU_VW" ("S2_SEG_HIST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_HIST_TP_CD", "HA_SEG_HIST_TP_NM", "HA_SEG_HIST_CD", "HA_SEG_HIST_NM", "HA_SEG_HIST_CGY_CD", "HA_SEG_HIST_CGY_NM", "HA_SEG_HIST_STRT_TMS", "HA_SEG_HIST_END_TMS", "HA_IP_TP_IND", "HA_IP_NBR", "HA_LE_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 IP_PPSEGMEN_V_ID AS S2_SEG_HIST_ID,
 ('MDM.' || PARTYID_SRC) AS TA_KEY,
 IP_ID AS TA_SRC_ROW_ID,
 VLD_FROM_TMS AS TA_VLD_FROM_TMS,
 VLD_TO_TMS AS TA_VLD_TO_TMS,
 PCS_ISRT_ID AS TA_PCS_ISRT_ID,
 PCS_UDT_ID AS TA_PCS_UDT_ID,
 ISRT_TMS AS TA_ISRT_TMS,
 UDT_TMS AS TA_UDT_TMS,
 SEGMENTTYPECODE AS HA_SEG_HIST_TP_CD,
 SEGMENTTYPENAME AS HA_SEG_HIST_TP_NM,
 SEGMENTVALUECODE AS HA_SEG_HIST_CD,
 SEGMENTVALUENAME AS HA_SEG_HIST_NM,
 SEGMENTVALUECATEGORYCODE AS HA_SEG_HIST_CGY_CD,
 SEGMENTVALUECATEGORYNAME AS HA_SEG_HIST_CGY_NM,
 STARTED AS HA_SEG_HIST_STRT_TMS,
 ENDED AS HA_SEG_HIST_END_TMS,
 PARTYTYPE AS HA_IP_TP_IND,
 PARTYID_SRC AS HA_IP_NBR,
 ACCESSTOKEN AS HA_LE_CD
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PPSEGMEN_V__SL_CHV_CIM_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR__DM_BSL_BASEL_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR__DM_BSL_BASEL_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 S1_AR_ID,
 S2_AR_ID,
 TA_KEY,
 TA_SRC_ROW_ID,
 TA_HASH_VAL,
 TA_VLD_FROM_TMS,
 TA_VLD_TO_TMS,
 TA_PCS_ISRT_ID,
 TA_PCS_UDT_ID,
 TA_ISRT_TMS,
 TA_UDT_TMS,
 CASE WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N'
 END AS TA_CRN_IND,
 HA_OPN_DT,
 HA_END_DT,
 HA_ST_CD,
 HA_CCY_CD,
 HA_PD_CD,
 HA_LE_CD,
 HA_AR_NBR,
 HA_CMRCL_NBR,
 HA_BBAN_NBR,
 HA_IBAN_NBR,
 HA_INH_IND,
 HA_JIVE_IND,
 HA_DEL_IND
 FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR ;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_PD__DM_BSL_BASEL_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_PD__DM_BSL_BASEL_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
 S1_PD_ID,
 S2_PD_ID,
 TA_KEY,
 TA_SRC_ROW_ID,
 TA_HASH_VAL,
 TA_VLD_FROM_TMS,
 TA_VLD_TO_TMS,
 TA_PCS_ISRT_ID,
 TA_PCS_UDT_ID,
 TA_ISRT_TMS,
 TA_UDT_TMS,
 CASE WHEN (TA_VLD_TO_TMS = TIMESTAMP '9999-12-31 00:00:00') THEN 'Y' ELSE 'N'
 END AS TA_CRN_IND,
 HA_PD_CD,
 HA_PD_NM,
 HA_PD_CGY_CD,
 HA_PD_CGY_NM,
 HA_EXP_DT
 FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD ;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D1_HLDR__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D1_HLDR__DM_KRO_KROV_NL_VW" ("S1_HLDR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_LAST_UDT_TMS", "CA_HLDR_CD", "CA_HLDR_NM") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_HLDR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_LAST_UDT_TMS
, CA_HLDR_CD
, CA_HLDR_NM
FROM SL_CIM_SLT_OWNER.CIM_SLT_D1_HLDR
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_IP__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_IP__DM_KRO_KROV_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "CA_COLLAPSED_TO_IP_NBR", "HA_UUID_CD", "HA_LE_CD", "CA_SEG_CD", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_SBI_TP_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_ZIP_CD", "HA_BRTH_CITY_NM", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_TRD_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "HA_DEL_IND", "CA_TEL_NBR", "CA_EMAIL_ADR", "CA_CRSP_NM", "CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "CA_SEG_CGY_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_CA
, TA_HASH_VAL_HA
,  CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_CSI_NBR
, HA_BE_NBR
, CA_COLLAPSED_TO_IP_NBR
, HA_UUID_CD
, HA_LE_CD
, CA_SEG_CD
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_SBI_TP_CD
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_ZIP_CD
, HA_BRTH_CITY_NM
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, HA_FORMAL_NM
, HA_TRD_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_WWFT_CMPLN_IND
, HA_DEL_IND
, CA_TEL_NBR
, CA_EMAIL_ADR
, CA_CRSP_NM
, CA_COLLAPSED_DT
, CA_COLLAPSED_IND
, CA_END_DT
, CA_PRFL_CCNT_IND
, CA_RGHT_TO_OBJ_IND
, CA_SEG_CGY_CD
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_FP_PD_PSSN__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_FP_PD_PSSN__DM_KRO_KROV_NL_VW" ("SP_PD_PSSN_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "D1_AR_ID", "D2_AR_ID", "D1_PD_ID", "D2_PD_ID", "D1_IP_ID", "D2_IP_ID", "D1_HLDR_ID", "D1_DT_ID", "D1_CCY_ID", "D2_CCY_ID", "D1_SEG_ID", "D2_SEG_ID", "FA_LE_CD", "AM_NBR", "NM_AGE_NBR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  SP_PD_PSSN_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_PCS_ISRT_ID
, TA_ISRT_TMS
, D1_AR_ID
, D2_AR_ID
, D1_PD_ID
, D2_PD_ID
, D1_IP_ID
, D2_IP_ID
, D1_HLDR_ID
, D1_DT_ID
, D1_CCY_ID
, D2_CCY_ID
, D1_SEG_ID
, D2_SEG_ID
, FA_LE_CD
, AM_NBR
, NM_AGE_NBR
FROM SL_CIM_SLT_OWNER.CIM_SLT_FP_PD_PSSN
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR__DM_KRO_KROV_NL_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S.S1_AR_ID,
 S.S2_AR_ID,
 S.TA_KEY,
 S.TA_SRC_ROW_ID,
 S.TA_HASH_VAL,
 S.TA_VLD_FROM_TMS,
 S.TA_VLD_TO_TMS,
 S.TA_PCS_ISRT_ID,
 S.TA_PCS_UDT_ID,
 S.TA_ISRT_TMS,
 S.TA_UDT_TMS,
 A.CA_CID_NBR,
 CASE WHEN (S.TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND,
 S.HA_OPN_DT,
 S.HA_END_DT,
 S.HA_ST_CD,
 S.HA_CCY_CD,
 S.HA_PD_CD,
 S.HA_LE_CD,
 S.HA_AR_NBR,
 S.HA_CMRCL_NBR,
 S.HA_BBAN_NBR,
 S.HA_IBAN_NBR,
 S.HA_INH_IND,
 S.HA_JIVE_IND,
 S.HA_DEL_IND FROM (SL_CIM_SLT_OWNER.CIM_SLT_D7_AR S LEFT JOIN (SELECT A.ARRANGEMENTKEYID_SRC AS CA_CID_NBR,
 A.UUID_SRC FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__DM_KRO_KROV_NL_VW A
 WHERE ((A.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) AND (A.ARRANGEMENTKEYCODE = 8))) A ON ((S.TA_KEY = ('MDM.' || A.UUID_SRC))))
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_KRO_KROV_NL_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CTRY_ID
, S2_CTRY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
,  CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_CTRY_CD
, HA_CTRY_NM
, HA_ISO_CD
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CTRY
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_PD__DM_KRO_KROV_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_PD__DM_KRO_KROV_NL_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_PD_ID
, S2_PD_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
,  CASE WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00' , 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND
, HA_PD_CD
, HA_PD_NM
, HA_PD_CGY_CD
, HA_PD_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_GRDM_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_GRDM_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("CL_GRDM_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "GRDM_DIST_NM", "GRDM_DSC", "SRC_STM", "SRC_CD", "SRC_DESC", "EFF_DT", "END_DT", "CD", "CD_DESC", "PRNT", "PRNT_DSC", "LVL", "CTG", "CTG_DSC", "STS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "CL_GRDM_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","GRDM_DIST_NM","GRDM_DSC","SRC_STM","SRC_CD","SRC_DESC","EFF_DT","END_DT","CD","CD_DESC","PRNT","PRNT_DSC","LVL","CTG","CTG_DSC","STS" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_GRDM_S_VW";"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_GRDM_PD_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_GRDM_PD_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("CL_PD_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "GRDM_DIST_NM", "GRDM_DSC", "EFF_DT", "END_DT", "CD", "CD_DSC", "PRNT", "PRNT_DSC", "LVL", "EXTND_DSC", "QUAL_AGRM", "PD_CAT", "PD_CAT_DSC", "CBA_PD_GRP", "FATCA_ELIG", "CRS_ELIG", "TAX_RPT", "DGS_RPT", "LWS_LVL", "AR_TYP", "AR_TYP_DSC", "STS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "CL_PD_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","GRDM_DIST_NM","GRDM_DSC","EFF_DT","END_DT","CD","CD_DSC","PRNT","PRNT_DSC","LVL","EXTND_DSC","QUAL_AGRM","PD_CAT","PD_CAT_DSC","CBA_PD_GRP","FATCA_ELIG","CRS_ELIG","TAX_RPT","DGS_RPT","LWS_LVL","AR_TYP","AR_TYP_DSC","STS" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_GRDM_PD_S_VW";"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_S_VW__NHG_DM_MRT_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_S_VW__NHG_DM_MRT_NL_VW" ("IP_S_ID", "SRC_STM_KEY", "VLD_FROM_TMS", "VLD_TO_TMS", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "HASH_VAL", "IP_UUID", "IP_NBR", "DATEOFDEATH", "DATEOFBIRTH", "NAMEINITIALS", "LASTNAMEPREFIX", "LASTNAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT IP_S_ID,SRC_STM_KEY,VLD_FROM_TMS,VLD_TO_TMS,ISRT_JOB_RUN_ID,UDT_JOB_RUN_ID,ISRT_TMS,UDT_TMS,HASH_VAL,IP_UUID,IP_NBR,DATEOFDEATH,DATEOFBIRTH,NAMEINITIALS,LASTNAMEPREFIX,LASTNAME
FROM SL_CIM_SLV_OWNER.CIM_ILV_IP_S_VW
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_FP_PD_PSSN_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_FP_PD_PSSN_VW" ("SP_PD_PSSN_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_PCS_ISRT_ID", "TA_ISRT_TMS", "D1_AR_ID", "D2_AR_ID", "D1_PD_ID", "D2_PD_ID", "D1_IP_ID", "D2_IP_ID", "D1_HLDR_ID", "D1_DT_ID", "D1_CCY_ID", "D2_CCY_ID", "D1_SEG_ID", "D2_SEG_ID", "FA_LE_CD", "AM_NBR", "NM_AGE_NBR") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
         SP_PD_PSSN_ID
        ,TA_KEY
        ,TA_SRC_ROW_ID
        ,TA_PCS_ISRT_ID
        ,TA_ISRT_TMS
        ,D1_AR_ID
        ,D2_AR_ID
        ,D1_PD_ID
        ,D2_PD_ID
        ,D1_IP_ID
        ,D2_IP_ID
        ,D1_HLDR_ID
        ,D1_DT_ID
        ,D1_CCY_ID
        ,D2_CCY_ID
        ,D1_SEG_ID
        ,D2_SEG_ID
        ,FA_LE_CD
        ,AM_NBR
        ,NM_AGE_NBR
FROM SL_CIM_SLT_OWNER.CIM_SLT_FP_PD_PSSN;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D7_CCY_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D7_CCY_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT S1_CCY_ID, S2_CCY_ID, TA_KEY, TA_SRC_ROW_ID, TA_HASH_VAL, TA_VLD_FROM_TMS, TA_VLD_TO_TMS, TA_PCS_ISRT_ID, TA_PCS_UDT_ID, TA_ISRT_TMS, TA_UDT_TMS,
CASE
WHEN (TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y'ELSE 'N' END AS TA_CRN_IND, HA_CCY_CD, HA_CCY_NM, HA_ISO_CD, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CCY SLT;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D7_SEG_HIST_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D7_SEG_HIST_VW" ("S2_SEG_HIST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_HIST_TP_CD", "HA_SEG_HIST_TP_NM", "HA_SEG_HIST_CD", "HA_SEG_HIST_NM", "HA_SEG_HIST_CGY_CD", "HA_SEG_HIST_CGY_NM", "HA_SEG_HIST_STRT_TMS", "HA_SEG_HIST_END_TMS", "HA_IP_TP_IND", "HA_IP_NBR", "HA_LE_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT IP_PPSEGMEN_V_ID AS S2_SEG_HIST_ID,
('MDM.'|| PARTYID_SRC) AS TA_KEY,
IP_ID AS TA_SRC_ROW_ID, VLD_FROM_TMS AS TA_VLD_FROM_TMS, VLD_TO_TMS AS TA_VLD_TO_TMS, PCS_ISRT_ID AS TA_PCS_ISRT_ID, PCS_UDT_ID AS TA_PCS_UDT_ID, ISRT_TMS AS TA_ISRT_TMS, UDT_TMS AS TA_UDT_TMS, SEGMENTTYPECODE AS HA_SEG_HIST_TP_CD, SEGMENTTYPENAME AS HA_SEG_HIST_TP_NM, SEGMENTVALUECODE AS HA_SEG_HIST_CD, SEGMENTVALUENAME AS HA_SEG_HIST_NM, SEGMENTVALUECATEGORYCODE AS HA_SEG_HIST_CGY_CD, SEGMENTVALUECATEGORYNAME AS HA_SEG_HIST_CGY_NM, STARTED AS HA_SEG_HIST_STRT_TMS, ENDED AS HA_SEG_HIST_END_TMS, PARTYTYPE AS HA_IP_TP_IND, PARTYID_SRC AS HA_IP_NBR,
ACCESSTOKEN AS HA_LE_CD
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PPSEGMEN_V__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D7_IP_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D7_IP_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "TA_CRN_IND", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "CA_COLLAPSED_TO_IP_NBR", "HA_UUID_CD", "HA_LE_CD", "CA_SEG_CD", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_SBI_TP_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_ZIP_CD", "HA_BRTH_CITY_NM", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_TRD_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "HA_DEL_IND", "CA_TEL_NBR", "CA_EMAIL_ADR", "CA_CRSP_NM", "CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "CA_SEG_CGY_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
     IP.S1_IP_ID
    ,IP.S2_IP_ID
    ,IP.TA_KEY
    ,IP.TA_SRC_ROW_ID
    ,IP.TA_VLD_FROM_TMS
    ,IP.TA_VLD_TO_TMS
    ,IP.TA_PCS_ISRT_ID
    ,IP.TA_PCS_UDT_ID
    ,IP.TA_ISRT_TMS
    ,IP.TA_UDT_TMS
    ,IP.TA_HASH_VAL_CA
    ,IP.TA_HASH_VAL_HA
	,CASE WHEN IP.TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
    ,IP.HA_GRID_NBR
    ,IP.HA_IP_NBR
    ,IP.HA_KVK_NBR
    ,IP.HA_CSI_NBR
    ,IP.HA_BE_NBR
    ,IP.CA_COLLAPSED_TO_IP_NBR
    ,IP.HA_UUID_CD
    ,IP.HA_LE_CD
    ,IP.CA_SEG_CD
    ,IP.HA_BRTH_DT
    ,IP.HA_DCSD_DT
    ,IP.HA_ESTB_DT
    ,IP.HA_STRT_DT
    ,IP.HA_BRTH_CTRY_CD
    ,IP.HA_BRTH_DT_QLY_CD
    ,IP.HA_IP_TP_CD
    ,IP.HA_LGL_FORM_CD
    ,IP.HA_MGN_ENT_CD
    ,IP.HA_PREF_LANG_CD
    ,IP.HA_PRIV_PREF_CD
    ,IP.HA_RSDNT_CTRY_CD
    ,IP.HA_SBI_TP_CD
    ,IP.HA_STR_NM
    ,IP.HA_CTY_NM
    ,IP.HA_BLD_NBR
    ,IP.HA_UNIT_NBR
    ,IP.HA_ZIP_CD
    ,IP.HA_BRTH_CITY_NM
    ,IP.HA_INIT_NM
    ,IP.HA_PREPSTN_NM
    ,IP.HA_LST_NM
    ,IP.HA_FORMAL_NM
    ,IP.HA_TRD_NM
    ,IP.HA_GND_IND
    ,IP.HA_IP_TP_IND
    ,IP.HA_JIVE_IND
    ,IP.HA_WWFT_CMPLN_IND
    ,IP.HA_DEL_IND
    ,IP.CA_TEL_NBR
    ,IP.CA_EMAIL_ADR
    ,IP.CA_CRSP_NM
    ,IP.CA_COLLAPSED_DT
    ,IP.CA_COLLAPSED_IND
    ,IP.CA_END_DT
    ,IP.CA_PRFL_CCNT_IND
    ,IP.CA_RGHT_TO_OBJ_IND
    ,IP.CA_SEG_CGY_CD
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP IP;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D7_PD_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D7_PD_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
     S1_PD_ID
    ,S2_PD_ID
    ,TA_KEY
    ,TA_SRC_ROW_ID
    ,TA_HASH_VAL
    ,TA_VLD_FROM_TMS
    ,TA_VLD_TO_TMS
    ,TA_PCS_ISRT_ID
    ,TA_PCS_UDT_ID
    ,TA_ISRT_TMS
    ,TA_UDT_TMS
	,CASE WHEN TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS') THEN 'Y' ELSE 'N' END AS TA_CRN_IND
    ,HA_PD_CD
    ,HA_PD_NM
    ,HA_PD_CGY_CD
    ,HA_PD_CGY_NM
    ,HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D7_SBI_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D7_SBI_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_CRN_IND", "HA_SBI_CD", "HA_SBI_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
      S1_SBI_ID
     ,S2_SBI_ID
     ,TA_KEY
     ,TA_SRC_ROW_ID
     ,TA_HASH_VAL
     ,TA_VLD_FROM_TMS
     ,TA_VLD_TO_TMS
     ,TA_PCS_ISRT_ID
     ,TA_PCS_UDT_ID
     ,TA_ISRT_TMS
     ,TA_UDT_TMS
     ,CASE WHEN TA_VLD_TO_TMS	 = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')   THEN 'Y' ELSE 'N' END AS TA_CRN_IND
     ,HA_SBI_CD
     ,HA_SBI_NM
     ,HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SBI;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D7_AR_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D7_AR_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "CA_CID_NBR", "TA_CRN_IND", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT S.S1_AR_ID, S.S2_AR_ID, S.TA_KEY, S.TA_SRC_ROW_ID, S.TA_HASH_VAL, S.TA_VLD_FROM_TMS, S.TA_VLD_TO_TMS, S.TA_PCS_ISRT_ID, S.TA_PCS_UDT_ID, S.TA_ISRT_TMS, S.TA_UDT_TMS, A.CA_CID_NBR,
CASE
WHEN (S.TA_VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS')) THEN 'Y' ELSE 'N' END AS TA_CRN_IND, S.HA_OPN_DT, S.HA_END_DT, S.HA_ST_CD, S.HA_CCY_CD, S.HA_PD_CD, S.HA_LE_CD, S.HA_AR_NBR, S.HA_CMRCL_NBR, S.HA_BBAN_NBR, S.HA_IBAN_NBR, S.HA_INH_IND, S.HA_JIVE_IND, S.HA_DEL_IND
FROM (SL_CIM_SLT_OWNER.CIM_SLT_D7_AR S
LEFT JOIN (
SELECT A.ARRANGEMENTKEYID_SRC AS CA_CID_NBR, A.UUID_SRC
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_AR_ARRGKEYS_M__SL_CIM_CUSTOMER_INFO_XU_VW A
WHERE ((A.VLD_TO_TMS = TO_TIMESTAMP('9999-12-31 00:00:00', 'YYYY-MM-DD HH24:MI:SS'))
AND (A.ARRANGEMENTKEYCODE = 8))) A ON ((S.TA_KEY = ('MDM.' || A.UUID_SRC))));"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_SLV_D2_MGN_ENT_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_SLV_D2_MGN_ENT_VW" ("D2_IP_ME_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_MGN_ENT_TP_CD", "HA_MGN_ENT_TP_NM", "HA_MGN_ENT_CD", "HA_MGN_ENT_STRT_TMS", "HA_MGN_ENT_END_TMS", "HA_IP_TP_IND", "HA_IP_NBR", "HA_LE_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  IP_PMANAENT_V_ID AS D2_IP_ME_ID
 ,('MDM.'|| PARTYID_SRC) AS TA_KEY
 ,IP_ID AS TA_SRC_ROW_ID
 ,VLD_FROM_TMS AS TA_VLD_FROM_TMS
 ,VLD_TO_TMS AS TA_VLD_TO_TMS
 ,PCS_ISRT_ID AS TA_PCS_ISRT_ID
 ,PCS_UDT_ID AS TA_PCS_UDT_ID
 ,ISRT_TMS AS TA_ISRT_TMS
 ,UDT_TMS AS TA_UDT_TMS
 ,MANAGINGENTITYTYPECODE AS HA_MGN_ENT_TP_CD
 ,MANAGINGENTITYTYPENAME AS HA_MGN_ENT_TP_NM
 ,MANAGINGENTITYVALUE AS HA_MGN_ENT_CD
 ,MANAGINGENTITYSTARTED AS HA_MGN_ENT_STRT_TMS
 ,MANAGINGENTITYENDED AS HA_MGN_ENT_END_TMS
 ,PARTYTYPE AS HA_IP_TP_IND
 ,PARTYID_SRC AS HA_IP_NBR
 ,ACCESSTOKEN AS HA_LE_CD
FROM IS_PPA_CDV_OWNER.IS_PPA_CDV_PPA_CDS_SS_MDM_IP_PMANAENT_V__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_POSTAL_ADDRESS_S_VW__DM_BSL_BASEL_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_POSTAL_ADDRESS_S_VW__DM_BSL_BASEL_NL_VW" ("IP_POSTAL_ADDRESS_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ACCESSTOKEN", "DATASOURCE", "DLV_FAILURE_RSN_TP", "PST_ADR_USG_TP", "CTRY", "COUNTRYREGIONCODE", "CITYNAME", "REGIONNAME", "POSTALCODE", "STREETNAME", "HOUSENUMBER", "HOUSENUMBERADDITION", "BUILDINGNAME", "DELIVERYINFORMATION", "POBOXNUMBER", "STR_TP", "UNSTRUCTUREDADDRESSLINE1", "UNSTRUCTUREDADDRESSLINE2", "UNSTRUCTUREDADDRESSLINE3", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE", "DISTRICTNAME", "CITYAREANAME", "FLOOR", "LOCATIONUNITNUMBER", "DEPARTMENTNAME", "SUBDEPARTMENTNAME") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_POSTAL_ADDRESS_S_ID, SRC_STM_KEY, HASH_VAL, VLD_FROM_TMS, VLD_TO_TMS, DEL_IN_SRC_STM_F, ISRT_JOB_RUN_ID, UDT_JOB_RUN_ID, ISRT_TMS, UDT_TMS, IP_UUID, ACCESSTOKEN, DATASOURCE, DLV_FAILURE_RSN_TP, PST_ADR_USG_TP, CTRY, COUNTRYREGIONCODE, CITYNAME, REGIONNAME, POSTALCODE, STREETNAME, HOUSENUMBER, HOUSENUMBERADDITION, BUILDINGNAME, DELIVERYINFORMATION, POBOXNUMBER, STR_TP, UNSTRUCTUREDADDRESSLINE1, UNSTRUCTUREDADDRESSLINE2, UNSTRUCTUREDADDRESSLINE3, EFFECTIVEDATE, ENDDATE, LASTUPDATEUSER, LASTUPDATEDATE, DISTRICTNAME, CITYAREANAME, FLOOR, LOCATIONUNITNUMBER, DEPARTMENTNAME, SUBDEPARTMENTNAME FROM SL_CIM_SLV_OWNER.CIM_ILV_IP_POSTAL_ADDRESS_S_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_D7_SEG_HIST__DM_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_D7_SEG_HIST__DM_CHV_CIM_XU_VW" ("S2_SEG_HIST_ID", "TA_SRC_ROW_ID", "TA_KEY", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_DEL_IND", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_LE_CD", "HA_IP_UUID", "HA_SEG_HIST_TP_CD", "HA_SEG_HIST_CD", "HA_SEG_HIST_STRT_TMS", "HA_SEG_HIST_END_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_GROUP_V_ID AS S2_SEG_HIST_ID,
IP_GROUP_V_SUP_KEY AS TA_SRC_ROW_ID,
'MDM.'||UNQ_ID_IN_SRC_STM AS TA_KEY,
VLD_FROM_TMS AS TA_VLD_FROM_TMS,
VLD_TO_TMS AS TA_VLD_TO_TMS,
DEL_IN_SRC_STM_F AS HA_DEL_IND,
ISRT_JOB_RUN_ID AS TA_PCS_ISRT_ID,
UDT_JOB_RUN_ID AS TA_PCS_UDT_ID,
ISRT_TMS AS TA_ISRT_TMS,
UDT_TMS AS TA_UDT_TMS,
DECODE(ACCESSTOKEN,'ING_BE_SHARED','ING_BE','ING_NL_INTRY','ING_NL','ING_NL_SHARED','ING_NL',ACCESSTOKEN) AS HA_LE_CD,
INVOLVEDPARTYIDENTIFIER AS HA_IP_UUID,
GROUPTYPE AS HA_SEG_HIST_TP_CD,
GROUPCODE AS HA_SEG_HIST_CD,
EFFECTIVEDATE AS HA_SEG_HIST_STRT_TMS,
ENDDATE AS HA_SEG_HIST_END_TMS
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_GROUP_V__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_D7_TRADE_NAME_HIST__DM_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_D7_TRADE_NAME_HIST__DM_CHV_CIM_XU_VW" ("S2_TRADE_NAME_ID", "TA_SRC_ROW_ID", "TA_KEY", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_DEL_IND", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_IP_UUID", "HA_TRADE_NAME_TP", "HA_TRADE_NAME", "HA_DATA_SOURCE", "HA_TRADE_NAME_STRT_TMS", "HA_TRADE_NAME_END_TMS", "HA_LE_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_ORGNAME_FULL_M_ID AS S2_TRADE_NAME_ID,
IP_ORGNAME_FULL_M_SUP_KEY AS TA_SRC_ROW_ID,
'MDM.'||UNQ_ID_IN_SRC_STM AS TA_KEY,
VLD_FROM_TMS AS TA_VLD_FROM_TMS,
VLD_TO_TMS AS TA_VLD_TO_TMS,
DEL_IN_SRC_STM_F AS HA_DEL_IND,
ISRT_JOB_RUN_ID AS TA_PCS_ISRT_ID,
UDT_JOB_RUN_ID AS TA_PCS_UDT_ID,
ISRT_TMS AS TA_ISRT_TMS,
UDT_TMS AS TA_UDT_TMS,
INVOLVEDPARTYIDENTIFIER AS HA_IP_UUID,
ORGANISATIONNAMETYPE AS HA_TRADE_NAME_TP,
ORGANISATIONNAME AS HA_TRADE_NAME,
DATASOURCE AS HA_DATA_SOURCE,
EFFECTIVEDATE AS HA_TRADE_NAME_STRT_TMS,
ENDDATE AS HA_TRADE_NAME_END_TMS,
DECODE(ACCESSTOKEN,'ING_BE_SHARED','ING_BE','ING_NL_INTRY','ING_NL','ING_NL_SHARED','ING_NL',ACCESSTOKEN) AS HA_LE_CD
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGNAME_FULL_M__SL_CIM_CUSTOMER_INFO_XU_VW
WHERE ORGANISATIONNAMETYPE IN ('TRD_NM','TRD_NM_SHRT');"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_D7_SBI_HIST__DM_CHV_CIM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_D7_SBI_HIST__DM_CHV_CIM_XU_VW" ("S2_SBI_ID", "TA_SRC_ROW_ID", "TA_KEY", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "HA_DEL_IND", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_LE_CD", "HA_IP_UUID", "HA_SBI_ISSUER_TP_CD", "HA_SBI_CD", "HA_RANK", "HA_SBI_STRT_TMS", "HA_SBI_END_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_INDUSTRY_CLASS_M_ID AS S2_SBI_ID,
IP_INDUSTRY_CLASS_M_SUP_KEY AS TA_SRC_ROW_ID,
'MDM.'||UNQ_ID_IN_SRC_STM AS TA_KEY,
VLD_FROM_TMS AS TA_VLD_FROM_TMS,
VLD_TO_TMS AS TA_VLD_TO_TMS,
DEL_IN_SRC_STM_F AS HA_DEL_IND,
ISRT_JOB_RUN_ID AS TA_PCS_ISRT_ID,
UDT_JOB_RUN_ID AS TA_PCS_UDT_ID,
ISRT_TMS AS TA_ISRT_TMS,
UDT_TMS AS TA_UDT_TMS,
DECODE(ACCESSTOKEN,'ING_BE_SHARED','ING_BE','ING_NL_INTRY','ING_NL','ING_NL_SHARED','ING_NL',ACCESSTOKEN) AS HA_LE_CD,
IDENTIFIER AS HA_IP_UUID,
ISSUERTYPE AS HA_SBI_ISSUER_TP_CD,
CODE AS HA_SBI_CD,
RANK AS HA_RANK,
EFFECTIVEDATE AS HA_SBI_STRT_TMS,
ENDDATE AS HA_SBI_END_TMS
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_INDUSTRY_CLASS_M__SL_CIM_CUSTOMER_INFO_XU_VW
WHERE ISSUERTYPE = 'IDY_CL_SBI';"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLV_D7_IP_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLV_D7_IP_VW__DM_KYC_KYC_MULTI_NL_VW" ("HA_IP_NBR", "HA_JIVE_IND", "TA_VLD_TO_TMS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT HA_IP_NBR,HA_JIVE_IND,TA_VLD_TO_TMS
FROM
SL_CIM_SLV_OWNER.CIM_SLV_D7_IP_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_ORG_NAME_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_ORG_NAME_S_VW" ("IP_ORGNAME_S_ID", "IP_ORGNAME_S_SUP_KEY", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ORG_NM_TP", "ORGANISATIONNAME", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEDUSER", "LASTUPDATEDDATE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
IP_ORGNAME_M_ID AS IP_ORGNAME_S_ID,
IP_ORGNAME_M_SUP_KEY AS IP_ORGNAME_S_SUP_KEY,
UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
HASH_VAL AS HASH_VAL,
VLD_FROM_TMS AS VLD_FROM_TMS,
VLD_TO_TMS AS VLD_TO_TMS,
DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
ISRT_TMS AS ISRT_TMS,
UDT_TMS AS UDT_TMS,
INVOLVEDPARTYIDENTIFIER AS IP_UUID,
ORGANISATIONNAMETYPE AS ORG_NM_TP ,
ORGANISATIONNAME AS ORGANISATIONNAME,
DATASOURCE AS DATASOURCE,
EFFECTIVEDATE AS EFFECTIVEDATE,
ENDDATE AS ENDDATE,
LASTUPDATEDUSER AS LASTUPDATEDUSER,
LASTUPDATEDDATE AS LASTUPDATEDDATE,
ACCESSTOKEN AS ACCESSTOKEN
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_MDM_IP_ORGNAME_M__SL_CIM_CUSTOMER_INFO_XU_VW
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR_ST__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR_ST__DM_COM_COM_XU_VW" ("S1_AR_ST_ID", "S2_AR_ST_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_AR_ST_CD", "HA_AR_ST_NM", "HA_AR_ST_CGY_CD", "HA_AR_ST_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ST_ID
, S2_AR_ST_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_AR_ST_CD
, HA_AR_ST_NM
, HA_AR_ST_CGY_CD
, HA_AR_ST_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR_ST
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_IP__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_IP__DM_COM_COM_XU_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_CA", "TA_HASH_VAL_HA", "HA_GRID_NBR", "HA_IP_NBR", "HA_KVK_NBR", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_STRT_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_IP_TP_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_RSDNT_CTRY_CD", "HA_SBI_TP_CD", "HA_ZIP_CD", "HA_LE_CD", "HA_BRTH_CITY_NM", "HA_FORMAL_NM", "HA_TRD_NM", "HA_GND_IND", "HA_IP_TP_IND", "HA_JIVE_IND", "HA_WWFT_CMPLN_IND", "CA_COLLAPSED_TO_IP_NBR", "CA_COLLAPSED_DT", "CA_COLLAPSED_IND", "CA_END_DT", "CA_PRFL_CCNT_IND", "CA_RGHT_TO_OBJ_IND", "HA_UUID_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "CA_TEL_NBR", "CA_EMAIL_ADR", "CA_SEG_CD", "CA_CRSP_NM", "HA_CSI_NBR", "HA_BE_NBR", "HA_DEL_IND", "CA_SEG_CGY_CD") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_IP_ID
, S2_IP_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, TA_HASH_VAL_CA
, TA_HASH_VAL_HA
, HA_GRID_NBR
, HA_IP_NBR
, HA_KVK_NBR
, HA_BRTH_DT
, HA_DCSD_DT
, HA_ESTB_DT
, HA_STRT_DT
, HA_BRTH_CTRY_CD
, HA_BRTH_DT_QLY_CD
, HA_IP_TP_CD
, HA_LGL_FORM_CD
, HA_MGN_ENT_CD
, HA_PREF_LANG_CD
, HA_PRIV_PREF_CD
, HA_RSDNT_CTRY_CD
, HA_SBI_TP_CD
, HA_ZIP_CD
, HA_LE_CD
, HA_BRTH_CITY_NM
, HA_FORMAL_NM
, HA_TRD_NM
, HA_GND_IND
, HA_IP_TP_IND
, HA_JIVE_IND
, HA_WWFT_CMPLN_IND
, CA_COLLAPSED_TO_IP_NBR
, CA_COLLAPSED_DT
, CA_COLLAPSED_IND
, CA_END_DT
, CA_PRFL_CCNT_IND
, CA_RGHT_TO_OBJ_IND
, HA_UUID_CD
, HA_STR_NM
, HA_CTY_NM
, HA_BLD_NBR
, HA_UNIT_NBR
, HA_INIT_NM
, HA_PREPSTN_NM
, HA_LST_NM
, CA_TEL_NBR
, CA_EMAIL_ADR
, CA_SEG_CD
, CA_CRSP_NM
, HA_CSI_NBR
, HA_BE_NBR
, HA_DEL_IND
, CA_SEG_CGY_CD
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_IP
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CTRY__DM_COM_COM_XU_VW" ("S1_CTRY_ID", "S2_CTRY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CTRY_CD", "HA_CTRY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CTRY_ID
, S2_CTRY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_CTRY_CD
, HA_CTRY_NM
, HA_ISO_CD
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CTRY
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_CCY__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_CCY__DM_COM_COM_XU_VW" ("S1_CCY_ID", "S2_CCY_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_CCY_CD", "HA_CCY_NM", "HA_ISO_CD", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_CCY_ID
, S2_CCY_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_CCY_CD
, HA_CCY_NM
, HA_ISO_CD
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_CCY
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_PD__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_PD__DM_COM_COM_XU_VW" ("S1_PD_ID", "S2_PD_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_PD_CD", "HA_PD_NM", "HA_PD_CGY_CD", "HA_PD_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_PD_ID
, S2_PD_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_PD_CD
, HA_PD_NM
, HA_PD_CGY_CD
, HA_PD_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_PD
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SBI__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SBI__DM_COM_COM_XU_VW" ("S1_SBI_ID", "S2_SBI_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SBI_CD", "HA_SBI_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SBI_ID
, S2_SBI_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_SBI_CD
, HA_SBI_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SBI
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_AR__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_AR__DM_COM_COM_XU_VW" ("S1_AR_ID", "S2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_OPN_DT", "HA_END_DT", "HA_ST_CD", "HA_CCY_CD", "HA_PD_CD", "HA_LE_CD", "HA_AR_NBR", "HA_CMRCL_NBR", "HA_BBAN_NBR", "HA_IBAN_NBR", "HA_INH_IND", "HA_JIVE_IND", "HA_DEL_IND") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_AR_ID
, S2_AR_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_OPN_DT
, HA_END_DT
, HA_ST_CD
, HA_CCY_CD
, HA_PD_CD
, HA_LE_CD
, HA_AR_NBR
, HA_CMRCL_NBR
, HA_BBAN_NBR
, HA_IBAN_NBR
, HA_INH_IND
, HA_JIVE_IND
, HA_DEL_IND
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_AR
;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_CIM_SLT_D7_SEG__DM_COM_COM_XU_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_CIM_SLT_D7_SEG__DM_COM_COM_XU_VW" ("S1_SEG_ID", "S2_SEG_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_HASH_VAL", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "HA_SEG_CD", "HA_SEG_NM", "HA_SEG_CGY_CD", "HA_SEG_CGY_NM", "HA_EXP_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
  S1_SEG_ID
, S2_SEG_ID
, TA_KEY
, TA_SRC_ROW_ID
, TA_HASH_VAL
, TA_VLD_FROM_TMS
, TA_VLD_TO_TMS
, TA_PCS_ISRT_ID
, TA_PCS_UDT_ID
, TA_ISRT_TMS
, TA_UDT_TMS
, HA_SEG_CD
, HA_SEG_NM
, HA_SEG_CGY_CD
, HA_SEG_CGY_NM
, HA_EXP_DT
FROM SL_CIM_SLT_OWNER.CIM_SLT_D7_SEG
;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_GRDM_PD_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_GRDM_PD_S_VW" ("CL_PD_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "GRDM_DIST_NM", "GRDM_DSC", "EFF_DT", "END_DT", "CD", "CD_DSC", "PRNT", "PRNT_DSC", "LVL", "EXTND_DSC", "QUAL_AGRM", "PD_CAT", "PD_CAT_DSC", "CBA_PD_GRP", "FATCA_ELIG", "CRS_ELIG", "TAX_RPT", "DGS_RPT", "LWS_LVL", "AR_TYP", "AR_TYP_DSC", "STS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
		CL_PD_V_ID AS CL_PD_S_ID,
		UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
		HASH_VAL AS HASH_VAL,
		VLD_FROM_TMS AS VLD_FROM_TMS,
		VLD_TO_TMS AS VLD_TO_TMS,
		DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
		ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
		UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
		ISRT_TMS AS ISRT_TMS,
		UDT_TMS AS UDT_TMS,
		GRDM_DIST_NM AS GRDM_DIST_NM,
		GRDM_DSC AS GRDM_DSC,
		EFF_DT AS EFF_DT,
		END_DT AS END_DT,
		CD AS CD,
		CD_DSC AS CD_DSC,
		PRNT AS PRNT,
		PRNT_DSC AS PRNT_DSC,
		LVL AS LVL,
		EXTND_DSC AS EXTND_DSC,
		QUAL_AGRM AS QUAL_AGRM,
		PD_CAT AS PD_CAT,
		PD_CAT_DSC AS PD_CAT_DSC,
		CBA_PD_GRP AS CBA_PD_GRP,
		FATCA_ELIG AS FATCA_ELIG,
		CRS_ELIG AS CRS_ELIG,
		TAX_RPT AS TAX_RPT,
		DGS_RPT AS DGS_RPT,
		LWS_LVL AS LWS_LVL,
		AR_TYP AS AR_TYP,
		AR_TYP_DSC AS AR_TYP_DSC,
		STS AS STS
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_GRDM_CL_PD_V__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_CRM_DOD_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_D7_IP__DM_CRM_DOD_NL_VW" ("S1_IP_ID", "S2_IP_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL_HA", "HA_IP_UUID", "HA_LE_CD", "HA_IP_TP_CD", "HA_IP_TP_IND", "HA_IP_NBR", "HA_GRID_NBR", "HA_KVK_NBR", "HA_CSI_NBR", "HA_BE_NBR", "HA_STRT_DT", "HA_BRTH_DT", "HA_DCSD_DT", "HA_ESTB_DT", "HA_BRTH_CTRY_CD", "HA_BRTH_DT_QLY_CD", "HA_LGL_FORM_CD", "HA_MGN_ENT_CD", "HA_PREF_LANG_CD", "HA_PRIV_PREF_CD", "HA_BRTH_CITY_NM", "HA_GND_IND", "HA_JIVE_IND", "HA_RSDNT_CTRY_CD", "HA_ZIP_CD", "HA_STR_NM", "HA_CTY_NM", "HA_BLD_NBR", "HA_UNIT_NBR", "HA_INIT_NM", "HA_PREPSTN_NM", "HA_LST_NM", "HA_FORMAL_NM", "HA_COLLAPSED_TO_IP_UUID", "HA_COLLAPSED_TO_IP_NBR", "HA_COLLAPSED_DT", "HA_COLLAPSED_IND", "HA_END_DT", "HA_PRFL_CCNT_IND", "HA_RGHT_TO_OBJ_IND", "HA_TEL_NBR", "HA_EMAIL_ADR", "HA_SEG_CD", "HA_SEG_CGY_CD", "HA_CRSP_NM", "HA_DEL_IND", "HA_AGE", "HA_MINOR_IND", "HA_DCSD_IND", "HA_CLS_ORG_DT", "HA_CTRY_INC", "HA_IP_EFF_DT", "HA_IP_END_DT", "HA_INACTIVE_DT", "HA_LCS_TP", "HA_FNC_LGL_ST_TP", "HA_LGL_CMPNC_ST_TP", "HA_FRST_NM_1", "HA_FRST_NM_2", "HA_FRST_NM_3", "HA_FRST_NM_4", "HA_GVN_NM", "HA_NCK_NM", "HA_SCD_LAST_NM", "HA_PRTN_LAST_NM", "HA_PRTN_LAST_NM_PFX", "HA_SALUT", "HA_CRSPD_CTRY_CD", "HA_CHANNEL_ENTRY", "HA_GRP_TYP", "HA_TEL_NBR_LAND", "HA_TEL_NBR_MBL", "HA_EMAIL_ADR_BSN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
S1_IP_ID,
S2_IP_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
TA_HASH_VAL_HA,
HA_IP_UUID,
HA_LE_CD,
HA_IP_TP_CD,
HA_IP_TP_IND,
HA_IP_NBR,
HA_GRID_NBR,
HA_KVK_NBR,
HA_CSI_NBR,
HA_BE_NBR,
HA_STRT_DT,
HA_BRTH_DT,
HA_DCSD_DT,
HA_ESTB_DT,
HA_BRTH_CTRY_CD,
HA_BRTH_DT_QLY_CD,
HA_LGL_FORM_CD,
HA_MGN_ENT_CD,
HA_PREF_LANG_CD,
HA_PRIV_PREF_CD,
HA_BRTH_CITY_NM,
HA_GND_IND,
HA_JIVE_IND,
HA_RSDNT_CTRY_CD,
HA_ZIP_CD,
HA_STR_NM,
HA_CTY_NM,
HA_BLD_NBR,
HA_UNIT_NBR,
HA_INIT_NM,
HA_PREPSTN_NM,
HA_LST_NM,
HA_FORMAL_NM,
HA_COLLAPSED_TO_IP_UUID,
HA_COLLAPSED_TO_IP_NBR,
HA_COLLAPSED_DT,
HA_COLLAPSED_IND,
HA_END_DT,
HA_PRFL_CCNT_IND,
HA_RGHT_TO_OBJ_IND,
HA_TEL_NBR,
HA_EMAIL_ADR,
HA_SEG_CD,
HA_SEG_CGY_CD,
HA_CRSP_NM,
HA_DEL_IND,
HA_AGE,
HA_MINOR_IND,
HA_DCSD_IND,
HA_CLS_ORG_DT,
HA_CTRY_INC,
HA_IP_EFF_DT,
HA_IP_END_DT,
HA_INACTIVE_DT,
HA_LCS_TP,
HA_FNC_LGL_ST_TP,
HA_LGL_CMPNC_ST_TP,
HA_FRST_NM_1,
HA_FRST_NM_2,
HA_FRST_NM_3,
HA_FRST_NM_4,
HA_GVN_NM,
HA_NCK_NM,
HA_SCD_LAST_NM,
HA_PRTN_LAST_NM,
HA_PRTN_LAST_NM_PFX,
HA_SALUT,
HA_CRSPD_CTRY_CD,
HA_CHANNEL_ENTRY,
HA_GRP_TYP,
HA_TEL_NBR_LAND,
HA_TEL_NBR_MBL,
HA_EMAIL_ADR_BSN
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_D7_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_CRM_DOD_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."SL_CIM_SLV_ONEPAM_SLT_B2_AR_X_IP__DM_CRM_DOD_NL_VW" ("SB_AR_X_IP_ID", "D1_IP_ID", "D2_IP_ID", "D1_AR_ID", "D2_AR_ID", "TA_KEY", "TA_SRC_ROW_ID", "TA_VLD_FROM_TMS", "TA_VLD_TO_TMS", "TA_PCS_ISRT_ID", "TA_PCS_UDT_ID", "TA_ISRT_TMS", "TA_UDT_TMS", "TA_HASH_VAL", "TA_AR_TYPE", "HA_DEL_IND", "HA_AR_UUID", "HA_IP_UUID", "HA_LE_CD", "HA_ROLE_TYPE", "HA_OPER_STATUS_TYPE", "HA_EFF_DT", "HA_END_DT") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
SB_AR_X_IP_ID,
D1_IP_ID,
D2_IP_ID,
D1_AR_ID,
D2_AR_ID,
TA_KEY,
TA_SRC_ROW_ID,
TA_VLD_FROM_TMS,
TA_VLD_TO_TMS,
TA_PCS_ISRT_ID,
TA_PCS_UDT_ID,
TA_ISRT_TMS,
TA_UDT_TMS,
TA_HASH_VAL,
TA_AR_TYPE,
HA_DEL_IND,
HA_AR_UUID,
HA_IP_UUID,
HA_LE_CD,
HA_ROLE_TYPE,
HA_OPER_STATUS_TYPE,
HA_EFF_DT,
HA_END_DT
FROM SL_CIM_SLT_OWNER.ONEPAM_SLT_B2_AR_X_IP;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_GRDM_S_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_GRDM_S_VW" ("CL_GRDM_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "GRDM_DIST_NM", "GRDM_DSC", "SRC_STM", "SRC_CD", "SRC_DESC", "EFF_DT", "END_DT", "CD", "CD_DESC", "PRNT", "PRNT_DSC", "LVL", "CTG", "CTG_DSC", "STS") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT
		CL_GRDM_V_ID AS CL_GRDM_S_ID,
		UNQ_ID_IN_SRC_STM AS SRC_STM_KEY,
		HASH_VAL AS HASH_VAL,
		VLD_FROM_TMS AS VLD_FROM_TMS,
		VLD_TO_TMS AS VLD_TO_TMS,
		DEL_IN_SRC_STM_F AS DEL_IN_SRC_STM_F,
		ISRT_JOB_RUN_ID AS ISRT_JOB_RUN_ID,
		UDT_JOB_RUN_ID AS UDT_JOB_RUN_ID,
		ISRT_TMS AS ISRT_TMS,
		UDT_TMS AS UDT_TMS,
		GRDM_DIST_NM AS GRDM_DIST_NM,
		GRDM_DSC AS GRDM_DSC,
		SRC_STM AS SRC_STM,
		SRC_CD AS SRC_CD,
		SRC_DESC AS SRC_DESC,
		EFF_DT AS EFF_DT,
		END_DT AS END_DT,
		CD AS CD,
		CD_DESC AS CD_DESC,
		PRNT AS PRNT,
		PRNT_DSC AS PRNT_DSC,
		LVL AS LVL,
		CTG AS CTG,
		CTG_DSC AS CTG_DSC,
		STS AS STS
FROM OS_PPA_CDV_OWNER.OS_PPA_CDV_PPA_CDS_SS_GRDM_CL_GRDM_V__SL_CIM_CUSTOMER_INFO_XU_VW;"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_INDINAME_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_INDINAME_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_INDINAME_S_ID", "IP_INDINAME_S_SUP_KEY", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "TITLE1", "TITLE2", "TITLE3", "ENDDATE", "LASTNAME", "NICKNAME", "GIVENNAME", "DATASOURCE", "FIRSTNAME1", "FIRSTNAME2", "FIRSTNAME3", "FIRSTNAME4", "NAMESUFFIX", "SALUTATION", "NAMEINITIALS", "BIRTHLASTNAME", "EFFECTIVEDATE", "LASTNAMEPREFIX", "LASTUPDATEDATE", "LASTUPDATEUSER", "SECONDLASTNAME", "PARTNERLASTNAME", "IDV_NM_TP", "PARTNERLASTNAMEPREFIX", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_INDINAME_S_ID","IP_INDINAME_S_SUP_KEY","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","TITLE1","TITLE2","TITLE3","ENDDATE","LASTNAME","NICKNAME","GIVENNAME","DATASOURCE","FIRSTNAME1","FIRSTNAME2","FIRSTNAME3","FIRSTNAME4","NAMESUFFIX","SALUTATION","NAMEINITIALS","BIRTHLASTNAME","EFFECTIVEDATE","LASTNAMEPREFIX","LASTUPDATEDATE","LASTUPDATEUSER","SECONDLASTNAME","PARTNERLASTNAME","IDV_NM_TP","PARTNERLASTNAMEPREFIX","ACCESSTOKEN" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_INDINAME_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_ORG_NAME_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_ORG_NAME_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("IP_ORGNAME_S_ID", "IP_ORGNAME_S_SUP_KEY", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "IP_UUID", "ORG_NM_TP", "ORGANISATIONNAME", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEDUSER", "LASTUPDATEDDATE", "ACCESSTOKEN") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "IP_ORGNAME_S_ID","IP_ORGNAME_S_SUP_KEY","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","IP_UUID","ORG_NM_TP","ORGANISATIONNAME","DATASOURCE","EFFECTIVEDATE","ENDDATE","LASTUPDATEDUSER","LASTUPDATEDDATE","ACCESSTOKEN" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_ORG_NAME_S_VW"
WHERE ACCESSTOKEN IN ('ING_NL', 'ING_NL_SHARED');"
/* <sc-view> SL_CIM_SLV_OWNER.CIM_ILV_IP_IP_ORG_HIER_S_VW__DM_KYC_KYC_MULTI_NL_VW </sc-view> */	"
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "SL_CIM_SLV_OWNER"."CIM_ILV_IP_IP_ORG_HIER_S_VW__DM_KYC_KYC_MULTI_NL_VW" ("ORG_HIER_S_ID", "SRC_STM_KEY", "HASH_VAL", "VLD_FROM_TMS", "VLD_TO_TMS", "DEL_IN_SRC_STM_F", "ISRT_JOB_RUN_ID", "UDT_JOB_RUN_ID", "ISRT_TMS", "UDT_TMS", "ACCESSTOKEN", "ORGANISATIONHIERARCHYRELATIONSHIPIDENTIFIER", "ORG_HIER_RLTNP_RSN_TP", "ORG_PRN_RL_TP", "ORGANISATIONOWNERSHIPPERCENTAGE", "PARENT_IP_UUID", "CHILD_IP_UUID", "DATASOURCE", "EFFECTIVEDATE", "ENDDATE", "LASTUPDATEUSER", "LASTUPDATEDATE") DEFAULT COLLATION "USING_NLS_COMP"  AS 
  SELECT "ORG_HIER_S_ID","SRC_STM_KEY","HASH_VAL","VLD_FROM_TMS","VLD_TO_TMS","DEL_IN_SRC_STM_F","ISRT_JOB_RUN_ID","UDT_JOB_RUN_ID","ISRT_TMS","UDT_TMS","ACCESSTOKEN","ORGANISATIONHIERARCHYRELATIONSHIPIDENTIFIER","ORG_HIER_RLTNP_RSN_TP","ORG_PRN_RL_TP","ORGANISATIONOWNERSHIPPERCENTAGE","PARENT_IP_UUID","CHILD_IP_UUID","DATASOURCE","EFFECTIVEDATE","ENDDATE","LASTUPDATEUSER","LASTUPDATEDATE" FROM "SL_CIM_SLV_OWNER"."CIM_ILV_IP_IP_ORG_HIER_S_VW"
WHERE ACCESSTOKEN  IN ('ING_NL', 'ING_NL_SHARED');"