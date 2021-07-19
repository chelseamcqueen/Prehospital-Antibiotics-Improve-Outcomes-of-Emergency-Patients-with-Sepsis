-- Pangia3041 Provider notes

SELECT	
		fp.Coid AS HospID
	,Substr(Cast(Cast(Trim(OTranslate(reg.Medical_Record_Num,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,'')) AS INTEGER) + 135792468 + Cast(fp.Coid AS INTEGER) + 1000000000000 AS CHAR(13)),2,12) AS PtID
	,Cast((reg.Patient_DW_ID (Format '999999999999999999')) + 135792468 + Cast(fp.Coid AS INTEGER)AS DECIMAL(18,0)) AS AdmtID,
		edq.QRY_TYPE_REF_CD,
		edq.QRY_ID_TXT,
		Cast (edq.QRY_OCCR_TS AS DATE Format 'YYYY-MM-DD') - Cast (pop.Admission_Date AS DATE Format 'YYYY-MM-DD') AS Rel_Occur_Day,
		edq.QRY_OCCR_TS(TIME) AS Occur_Time,
		edq.QRY_VAL_TXT,
		SRC_SYS_ORGNL_CD
FROM	EDWCDM_Views.Fact_Patient fp

INNER JOIN qwu6617.Pangia3041PopA pop		--update pop
	ON fp.Patient_DW_Id = pop.Patient_DW_Id
	AND fp.Company_Code = pop.Company_Code
	AND fp.Coid = pop.Coid
	
INNER JOIN EDWCL_Views.Clinical_Registration reg
	  ON fp.Patient_DW_Id = reg.Patient_DW_Id
	AND fp.CoID = reg.CoID
	AND fp.company_code = reg.company_code 
	
INNER JOIN EDWCDM_Views.ED_QRY_RSLT_DTL EDQ
	ON fp.Patient_DW_Id = edq.Patient_DW_Id
	AND fp.Company_Code = edq.Company_Code
	AND fp.Coid = edq.Coid

WHERE SRC_SYS_ORGNL_CD in(
		'1EDM00819A',
		'1EDRIA016A',
		'QEDM3315',
		'BAICPES01A',
		'bvhAHX0002',
		'EDMPSY01X',
		'bvhAHX0404',
		'EDMPSY01B')
AND Rel_Occur_Day ='0'

GROUP BY 1,2,3,4,5,6,7,8,9