--Pangia3041 VITALS 


SELECT 
fvs.Coid AS HospID,
Substr(Cast(Cast(Trim(OTranslate(reg.Medical_Record_Num,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,'')) AS INTEGER) + 135792468 + Cast(fvs.Coid AS INTEGER) + 1000000000000 AS CHAR(13)),2,12) AS PtID,
Cast((fp.Patient_DW_ID (Format '999999999999999999'))  + 135792468 + Cast(fp.Coid AS INTEGER)AS DECIMAL(18,0)) AS AdmtID,
CASE
	WHEN fvs.Vital_Id_Txt = fvs.Source_System_Original_Code THEN dvt.Vital_Test_Desc
	ELSE fvs.Vital_Id_Txt
	END AS Vital_Test_Desc,		--updated dvt.Vital_Test_Desc to a case/when to eliminate all the null values to actual descriptions
fvs.Vital_Result_Value_Txt,
fvs.Vital_Result_Unit_Type_Code AS Vital_UOM,
Cast(fvs.Vital_Occr_Date_Time AS DATE) - fp.Admission_Date AS Vital_Rel_Day,
Cast(fvs.Vital_Occr_Date_Time AS TIME) AS Vital_Time,
fvs.Source_System_Original_Code
FROM EDWCDM_PC_VIEWS.Fact_Vital_Signs fvs

INNER JOIN EDWCDM_Views.Fact_Patient fp
ON fp.Patient_DW_Id = fvs.Patient_DW_Id
AND fp.CoID = fvs.CoID
AND fp.company_code = fvs.company_code 

INNER JOIN EDWCL_Views.Clinical_Registration reg
ON fvs.Patient_DW_Id = reg.Patient_DW_Id
AND fvs.CoID = reg.CoID
AND fvs.company_code = reg.company_code 

INNER JOIN qwu6617.Pangia3041PopA pop
ON fvs.Patient_DW_Id = pop.Patient_DW_Id
AND fvs.Company_Code = pop.Company_Code
AND fvs.Coid = pop.Coid

LEFT JOIN EDWCDM_VIEWS.Dim_Vital_Test dvt
ON dvt.Vital_Test_Sk = fvs.Vital_Test_Sk

WHERE fvs.Source_System_Original_Code IN ('K33010002A', 'K33010003A', 'K33010024A', 'cppdiastolic', 'K33010006A', 'cppsystolic' )

--AND (Cast(fvs.Vital_Occr_Date_Time AS DATE) - Cast(cpt.Transfer_eff_from_Date_Time AS DATE Format 'YYYY-MM-DD') BETWEEN '0' AND '1' ))
