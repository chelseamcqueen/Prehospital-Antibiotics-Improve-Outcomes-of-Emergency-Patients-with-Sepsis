--Pangia3041 Encounters

SELECT
	fp.Coid AS HospID
	,Substr(Cast(Cast(Trim(OTranslate(reg.Medical_Record_Num,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,'')) AS INTEGER) + 135792468 + Cast(fp.Coid AS INTEGER) + 1000000000000 AS CHAR(13)),2,12) AS PtID
	,Cast((reg.Patient_DW_ID (Format '999999999999999999')) + 135792468 + Cast(fp.Coid AS INTEGER)AS DECIMAL(18,0)) AS AdmtID
	,Extract (YEAR From (Cast(fp.Admission_Date AS DATE Format 'YYYY-MM-DD'))) AS Admit_Year
	,Cast (fp.Discharge_Date AS DATE Format 'YYYY-MM-DD') - Cast (fp.Admission_Date AS DATE Format 'YYYY-MM-DD') AS Rel_Discharge_Day
	,CASE WHEN Substring(fp.patient_zip_code FROM 1,3) IS IN ('036', '059', '102', '202', '203', '204', '205', '369', '556', '692', '753', '772', '821', '823', '878', '879', '884', '893' ) THEN '000'
		ELSE Substring (fp.patient_zip_code FROM 1,3)
		END AS Pat_ZIP_Masked
	,fp.Patient_Type_Code_Pos1 AS EncType
	,Coalesce(FP.DRG_Code_HCFA,FP.DRG_HCFA_ICD10_Code) AS DRG
	,CASE WHEN FP.DRG_Code_HCFA IS NOT NULL THEN '9'
	      WHEN FP.DRG_HCFA_ICD10_Code IS NOT NULL THEN '10'
	      ELSE NULL 
		  END AS DRG_Type
	,fp.Admission_Source_Code AS HCA_Adm_Src
	,ras.Admission_Classification_Code AS HCA_Adm_Class
	,AD.Discharge_Status_Code AS HCA_Disch_Dispo
	,rpd.Discharge_Status_Code_Desc AS HCA_Disch_Dispo_Desc
	,CASE WHEN (Cast((Cast((fp.Admission_Date(Format'YYYY-MM')) AS CHAR(7)) || '-01') AS DATE) - Cast((Cast((p.Person_Birth_Date(Format'YYYY-MM')) AS CHAR(7)) || '-01') AS DATE))/365 > '89'
		THEN '999'
		ELSE (Cast((Cast((fp.Admission_Date(Format'YYYY-MM')) AS CHAR(7)) || '-01') AS DATE) - Cast((Cast((p.Person_Birth_Date(Format'YYYY-MM')) AS CHAR(7)) || '-01') AS DATE))/365
		END AS Ageyrs
	,rfc.Financial_Class_Desc AS Payer_Type
	--,CASE WHEN (Extract (MONTH From (Cast(fp.Admission_Date AS DATE Format 'YYYY-MM-DD'))) BETWEEN '1' AND '3') THEN 'Q1'
		--WHEN (Extract (MONTH From (Cast(fp.Admission_Date AS DATE Format 'YYYY-MM-DD'))) BETWEEN '4' AND '6') THEN 'Q2'
		--	WHEN (Extract (MONTH From (Cast(fp.Admission_Date AS DATE Format 'YYYY-MM-DD'))) BETWEEN '7' AND '9') THEN 'Q3'
		--	ELSE 'Q4' 
		--END AS Admit_Quarter
FROM EDWCDM_Views.Fact_Patient fp

INNER JOIN qwu6617.Pangia3041PopA pop		--update pop
	ON fp.Patient_DW_Id = pop.Patient_DW_Id
	AND fp.Company_Code = pop.Company_Code
	AND fp.Coid = pop.Coid

INNER JOIN EDWCL_Views.Admission_Discharge_CL ad
	ON fp.Patient_DW_Id = ad.Patient_DW_Id
	AND fp.Company_Code = ad.Company_Code 
	AND fp.COID = ad.COID 

INNER JOIN EDWCL_Views.Clinical_Registration reg
	ON fp.Patient_DW_Id = reg.Patient_DW_Id
	AND fp.CoID = reg.CoID
	AND fp.company_code = reg.company_code 

INNER JOIN EDWCL_Views.Person_CL p
	ON fp.Patient_Person_DW_Id = p.Person_DW_Id

LEFT JOIN EDW_PUB_Views.Ref_Admission_Source ras
	ON fp.Admission_Source_Code = ras.Admission_Source_Code
	AND ras.Admission_Classification_Code = 'A'
	AND ras.EFf_To_Date = '9999-12-31'

LEFT JOIN EDW_PUB_Views.Ref_Discharge_Status rpd
	ON ad.Discharge_Status_Code =  rpd.Discharge_Status_Code
	AND rpd.EFf_To_Date = '9999-12-31'

LEFT JOIN EDWCL_Views.Ref_Financial_Class rfc
	ON fp.COID = rfc.COID
	AND fp.Financial_Class_Code = rfc.Financial_Class_Code

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15