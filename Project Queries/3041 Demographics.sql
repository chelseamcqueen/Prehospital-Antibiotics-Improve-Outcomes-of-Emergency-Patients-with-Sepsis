--Pangia3041 Demographics

SELECT  
	 fp.Coid AS HospID
	 ,Substr(Cast(Cast(Trim(OTranslate(reg.Medical_Record_Num,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,'')) AS INTEGER) + 135792468 + Cast(fp.Coid AS INTEGER) + 1000000000000 AS CHAR(13)),2,12) AS PtID
	,Cast((reg.Patient_DW_ID (Format '999999999999999999')) + 135792468 + Cast(fp.Coid AS INTEGER)AS DECIMAL(18,0)) AS AdmtID
	,CASE 
	        WHEN (Trim(P.Gender_Code) IS  NULL OR P.Gender_Code = '') 
	        THEN 'U' 
	        ELSE P.Gender_Code 
	END AS Sex
	,petc.Patient_Ethnicity_Type_Code AS EthnicityCode
	,prc1.Patient_Race_Code AS Race1Code
	,prc2.Patient_Race_Code AS Race2Code
	,cpa.Block_Group_Tapestry_Segmenation_Code AS ESRI_Group
FROM EDWCL_Views.Fact_Patient_CL fp

INNER JOIN EDWCL_Views.Clinical_Registration reg
	ON fp.Patient_DW_Id = reg.Patient_DW_Id
	AND fp.CoID = reg.CoID
	AND fp.company_code = reg.company_code 

INNER JOIN qwu6617.Pangia3041PopA pop		--replace pop
	ON fp.Patient_DW_Id = pop.Patient_DW_Id
	AND fp.Company_Code = pop.Company_Code
	AND fp.Coid = pop.Coid

INNER JOIN EDWCL_Views.Person_CL p
	ON fp.Patient_Person_DW_Id = p.Person_DW_Id

LEFT JOIN (
        SELECT
                Patient_Dw_Id
                ,coid
                ,Trim(Patient_Care_Element_Value) AS Patient_Race_Code
        FROM EDWCL_VIEWS.Clinical_Patient_Care_Element 
        WHERE Patient_Care_Element_Code = 'RACE'
		) prc1
		ON FP.Patient_Dw_Id = prc1.Patient_Dw_Id          

LEFT JOIN (
        SELECT
                Patient_Dw_Id
                ,coid
                ,Trim(Patient_Care_Element_Value) AS Patient_Race_Code
        FROM EDWCL_VIEWS.Clinical_Patient_Care_Element 
        WHERE Patient_Care_Element_Code = 'RACE2'
		) prc2
		ON FP.Patient_Dw_Id = prc2.Patient_Dw_Id            

LEFT JOIN (
        SELECT
                Patient_Dw_Id
                ,coid
                ,Trim(Patient_Care_Element_Value) AS Patient_Ethnicity_Type_Code
        FROM EDWCL_VIEWS.Clinical_Patient_Care_Element 
        WHERE Patient_Care_Element_Code = 'ETHNICITY'
		) petc
		ON FP.Patient_Dw_Id = petc.Patient_Dw_Id 

LEFT JOIN EDWCDM_Views.Junc_Person_Address jpa
	ON p.Person_DW_Id = jpa.Person_DW_Id
	AND jpa.Eff_To_Date = '9999-12-31'

LEFT JOIN edwcdm_views.consolidated_patient_address cpa
	ON jpa.Address_DW_ID = cpa.Address_DW_Id

GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
