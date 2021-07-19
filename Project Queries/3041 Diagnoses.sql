--Pangia3041 Diagnoses

SELECT
	fp.Coid AS HospID
	,Substr(Cast(Cast(Trim(OTranslate(reg.Medical_Record_Num,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,'')) AS INTEGER) + 135792468 + Cast(fp.Coid AS INTEGER) + 1000000000000 AS CHAR(13)),2,12) AS PtID
	,Cast((reg.Patient_DW_ID (Format '999999999999999999')) + 135792468 + Cast(fp.Coid AS INTEGER)AS DECIMAL(18,0)) AS AdmtID
	,pd.Diag_Rank_Num AS DxSeq
	,pd.Diag_Code AS Dx
	,rd.Diagnosis_Long_Desc AS DxDesc
	,CASE	
		WHEN	PD.Diag_Type_Code='9' THEN '09' 
		WHEN    PD.Diag_Type_Code='0' THEN '10' 
		ELSE	'OT' 
	END AS DX_CodeType
	,pd.Diag_Cycle_Code
	,CASE	 
		WHEN PD.Present_On_Admission_Ind = 'Y' THEN 'Y' 
		ELSE	'N' 
	END AS Padmit
		,Substr(pd.Diag_Code,1,3) ||
	CASE 
		WHEN	Char_Length(Trim(pd.Diag_Code)) > 3
		THEN '.' || Substr(pd.Diag_Code,4)
		ELSE ''
	END  AS OrigDX
FROM EDWCDM_Views.Fact_Patient fp

INNER JOIN EDWCL_Views.Clinical_Registration reg
	ON fp.Patient_DW_Id = reg.Patient_DW_Id
	AND fp.CoID = reg.CoID
	AND fp.company_code = reg.company_code

INNER JOIN qwu6617.Pangia3041PopA pop		--update pop
	ON fp.Patient_DW_Id = pop.Patient_DW_Id
	AND fp.Company_Code = pop.Company_Code
	AND fp.Coid = pop.Coid

INNER JOIN EDWCDM_PC_Views.Patient_Diagnosis  PD
	ON	PD.Patient_DW_Id = FP.Patient_DW_Id  	   
	AND	PD.COID = FP.COID
	AND    PD.Diag_Mapped_Code NOT = 'Y'

LEFT JOIN EDWCL_VIEWS.Ref_Diagnosis rd
	ON rd.Diag_Code = pd.Diag_Code
	AND rd.Diag_Type_Code = pd.Diag_Type_Code
	AND rd.Eff_To_Date = '9999-12-31'

GROUP BY 1,2,3,4,5,6,7,8,9,10