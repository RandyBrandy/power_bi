
SELECT TRN_ID, SETOUT_DT, STATION
FROM OPENQUERY(MECH_DW, '
SELECT DISTINCT TRN_ID, EVT_DT--, DPU_CD--, PRJ_CMP_STS--SUBSTRING(B.LOCO, 9, 4) TRN_ID, A.TRN_SCH_DPT_DT, A.EVT_DT, A.DPU_CD, B.PRJ_CMP_STS, TSI_STRT_DTTM, TSI_ROOT_CAUS, TSI_MECH_CMNT 
FROM (
SELECT TRN_TYPE, TRN_SECT, TRN_SYM, TRN_DAY, TRN_PRTY, PROC_DTTM,
		CO_ABBR, LST_RPTG_333, LST_RPTG_ST, SDIV_NUMB, TRN_LD_TOT, TRN_MTY_TOT,
		TRN_GRS_TONS, TRN_LGTH_FT, ACTL_HPT, TRN_PDIEM, SCHD_DEVN_CD,
		SCHD_DEVN_MN, EVT_DT, EVT_TM, END_EQP_TYPE, TRN_ARR_CD, TRN_SCH_DPT_DT,
		STN_SEQ_NBR, EVT_CD, EVST_CD, TRN_SVC_TYP, TMTBL_DIR, MAX_HPT,
		AUTO_PAD_FLG, SPD_RESTR_CD, TRN_RPTG_GRP, STN_TYPE_CD, TOT_AVL_HP,
		TOT_LOCO_HP, LOCO_ACT_CNT, LOCO_DEAD_CNT, LOCO_RPOS_CNT, DEAD_RT_HP,
		RPOS_RT_HP, ACT_RT_HP, RPOS_AVL_HP, ACT_AVL_HP, WGT_DRVR_ACT,
		WGT_DRVR_DEAD, WGT_DRVR_RPOS, REV_CAR_CNT, NREV_CAR_CNT, REV_IMDL_CNT,
		NREV_IMDL_CNT, REV_OPR_CNT, NREV_OPR_CNT, REV_EQUIV, NREV_EQUIV,
		GRS_TONS_CAR, REV_CAR_GTON, GRS_TONS_IMDL, REV_IMDL_GTON, REV_CAR_NTON,
		REV_IMDL_NTON, TRN_LGTH_CAR, REV_CAR_LGTH, TRN_LGTH_IMDL, REV_IMDL_LGTH,
		STD_SLOT_AVL, STK_SLOT_AVL, ARTCD_SLOT_AVL, STD_SLOT_USD, STK_SLOT_USD,
		ARTCD_SLOT_USD, REV_STD_SLOT, REV_STK_SLOT, REV_ARTCD_SLOT, TOFC_20_REV,
		TOFC_28_39_REV, TOFC_40_REV, TOFC_45_REV, TOFC_48_REV, TOFC_GT48_REV,
		TOFC_20_NREV, TOFC_28_39NREV, TOFC_40_NREV, TOFC_45_NREV, TOFC_48_NREV,
		TOFC_GT48_NREV, COFC_20_REV, COFC_28_39_REV, COFC_40_REV, COFC_45_REV,
		COFC_48_REV, COFC_GT48_REV, COFC_20_NREV, COFC_28_39NREV, COFC_40_NREV,
		COFC_45_NREV, COFC_48_NREV, COFC_GT48_NREV, UPS_VN_CNT, JBH_VN_CNT,
		USM_VN_CNT, LTL_VN_CNT, HAZ_LD_CNT, HAZ_MTY_CNT, HAZ_GRS_TONS,
		HAZ_TRN_LGTH, KEY_5_CNT, KEY_20_CNT, AFE_DTOUR_NUMB, LOCO_TRN_LGTH,
		CORRIDOR_NME, DIV_NUMB, USER_ID, LOG_USER, DPU_CD, ARR_DIR, DPT_DIR,
		GUAR_PROD_CNT, KEY_1_CAR_CNT, KEY_2_CAR_CNT, RDW_VN_CNT, CAR_ACTL_LD,
		CAR_ACTL_MTY, FDX_VN_CNT, YRC_VN_CNT, MIN_HPT, FUEL_CNSV_EXCL_CD,
		TRN_TYPE || '' '' || TRN_SYM || TRN_SECT || '' '' || TRN_DAY || TRN_PRTY AS TRN_ID
FROM CWVIEWS.VTRN_EVNT_BNSF_ALL  A
)A

--Trains with DPUs
WHERE YEAR(A.EVT_DT) = ''2023''
--AND A.EVT_DT = ''2022-08-29''
AND A.DPU_CD IN (''Y'', ''U'')
--AND A.DPU_CD <> ''N''
AND A.EVT_CD = ''TD''
AND A.STN_SEQ_NBR = ''10''
AND A.TRN_TYPE IN (''B'', ''C'', ''E'', ''g'', ''h'', ''q'', ''s'', ''u'', ''v'', ''x'', ''z'')
--AND B.LOCO IS NOT NULL
--AND D.TSI_LLOCO_SQN = ''1''
--AND C.TSI_ROOT_CAUS = ''DP Comm Loss''
--AND YEAR(C.TSI_STRT_DTTM) >= ''2019''
--AND C.TSI_ID IS NOT NULL
--AND D.LLOCO_NBR LIKE SUBSTRING(B.LOCO, 9, 9) 

GROUP BY TRN_ID, EVT_DT--, DPU_CD--, PRJ_CMP_STS --TSI_STRT_DTTM, TSI_ROOT_CAUS, TSI_MECH_CMNT
ORDER BY A.EVT_DT, A.TRN_ID
')A

LEFT JOIN OPENQUERY(MECH_DB2, '

select EQP_INIT, EQP_NBR, EQP_INIT || EQP_NBR AS CAR, CAST( BO_EQP_TS AS DATE) AS SETOUT_DT , BO_EQP_TS, STN_333, STN_ST, STN_333 || STN_ST AS STATION,
IOBND_INSP_CD, OBND_TRN_ID, IBND_TRN_ID, DFCT_CD_1 ||  ''-'' || DFCT_CD_2 ||  ''-'' ||   DFCT_CD_3 ||  ''-'' ||  DFCT_CD_4 AS SETOUT_DFCTCDS
FROM ME.TSCRD_BO_SETOUT 
where IOBND_INSP_CD IN (''M'',''S'',''E'',''I'')
AND CAST( BO_EQP_TS AS DATE) >= CURRENT_DATE - 365 DAY
')E

ON E.IBND_TRN_ID = REPLACE(A.TRN_ID, ' ', '')
AND E.SETOUT_DT >= A.EVT_DT
AND E.SETOUT_DT <= DATEADD(DAY, 20, A.EVT_DT)


WHERE E.SETOUT_DT IS NOT NULL
GROUP BY TRN_ID, SETOUT_DT, STATION
ORDER BY SETOUT_DT