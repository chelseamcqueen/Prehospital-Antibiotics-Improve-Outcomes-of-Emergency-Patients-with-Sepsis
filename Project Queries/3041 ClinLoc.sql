--Pangia3041 Clinical Unit Location- ICUs

SELECT
	fp.Coid AS HospID
	,Substr(Cast(Cast(Trim(OTranslate(reg.Medical_Record_Num,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,'')) AS INTEGER) + 135792468 + Cast(fp.Coid AS INTEGER) + 1000000000000 AS CHAR(13)),2,12) AS PtID
	,Cast((fp.Patient_DW_ID (Format '999999999999999999'))  + 135792468 + Cast(fp.Coid AS INTEGER)AS DECIMAL(18,0)) AS AdmtID 
	,cpt.Transfer_Seq
	,cpt.Location_mnemonic_cs AS Clin_Loc
	,Cast(cpt.Transfer_eff_from_Date_Time AS DATE Format 'YYYY-MM-DD') - Cast (fp.Admission_Date AS DATE Format 'YYYY-MM-DD') AS Eff_Fm_Rel_Day
	,Cast(cpt.Transfer_eff_from_date_time AS TIME) AS Eff_Fm_Time
	,Cast(cpt.Transfer_eff_to_Date_Time AS DATE Format 'YYYY-MM-DD') - Cast (fp.Admission_Date AS DATE Format 'YYYY-MM-DD') AS Eff_To_Rel_Day
	,Cast(cpt.Transfer_eff_to_date_time AS TIME) AS Eff_To_Time
	,cfl.Location_Type_Code AS Pat_Loc_Type
	,cfl.Location_Desc AS Pat_Loc_Desc
	,sc.SNOMED_CD AS SNOMED_Loc
	,sc.SNOMED_DESC AS SNOMED_Loc_Desc
FROM  EDWCDM_Views.Fact_Patient fp

INNER JOIN EDWCL_Views.Clinical_Registration reg
	ON fp.Patient_DW_Id = reg.Patient_DW_Id
	AND fp.CoID = reg.CoID
	AND fp.company_code = reg.company_code 

INNER JOIN qwu6617.Pangia3041PopA pop		--update pop
	ON fp.Patient_DW_Id = pop.Patient_DW_Id
	AND fp.Company_Code = pop.Company_Code
	AND fp.Coid = pop.Coid

INNER JOIN qwu6617.Alt_Transfer_Table cpt 
	ON fp.patient_dw_id = cpt.patient_dw_id 
	AND fp.coid = cpt.coid

LEFT JOIN EDWCL_VIEWS.Clinical_Facility_Location cfl
	ON cpt.COID = cfl.COID
	AND cpt.Location_mnemonic_cs = cfl.Location_mnemonic

LEFT JOIN EDWCL_Views.Ref_Nomenclature_Code_Map ncm
	ON cfl.COID = ncm.COID
	AND cfl.Nomenclature_Code = ncm.Nomenclature_Code
	AND ncm.Active_Ind = 'Y'
	AND ncm.Standard_Code_Type = 'SNOMED_CT'

LEFT JOIN EDWCDM_Views.SNOMED_CD sc
	ON ncm.Standard_Code_Text = sc.SNOMED_CD
	AND sc.VLD_TO_TS = '9999-12-31 00:00:00'


GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13