--Pangia3041 Clinical Orders

SELECT  
		fp.Coid AS HospID
		,Substr(Cast(Cast(Trim(OTranslate(reg.Medical_Record_Num,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,'')) AS INTEGER) + 135792468 + Cast(pop.Coid AS INTEGER) + 1000000000000 AS CHAR(13)),2,12) AS PtID
		,Cast((reg.Patient_DW_ID (Format '999999999999999999')) + 135792468 + Cast(pop.Coid AS INTEGER)AS DECIMAL(18,0)) AS AdmtID
        ,Cast (co.Order_Date_Time AS DATE Format 'YYYY-MM-DD') - Cast (pop.Admission_Date AS DATE Format 'YYYY-MM-DD') AS Rel_Order_Date
        ,co.Order_Date_Time(TIME) AS Order_time
        ,co.Order_Set_Mnem_CS
        ,co.Order_Proc_Category_Mnem_CS
        ,co.Order_Proc_Id
        ,co.Order_Proc_Mnem_CS
		,kk.Order_Proc_Name
        ,co.Order_Proc_Order_By_Func_Desc

FROM EDWCL_VIEWS.Clinical_Order co

INNER JOIN EDWCL_Views.Clinical_Registration reg
ON co.Patient_DW_Id = reg.Patient_DW_Id
AND co.CoID = reg.CoID
AND co.company_code = reg.company_code

INNER JOIN qwu6617.Pangia3041PopA pop			--update pop
ON co.Patient_DW_Id = pop.Patient_DW_Id
AND co.Company_Code = pop.Company_Code
AND co.Coid = pop.Coid

INNER JOIN EDWCDM_Views.Fact_Patient fp
ON fp.Patient_DW_Id = pop.Patient_DW_Id
AND fp.Company_Code = pop.Company_Code
AND fp.Coid = pop.Coid

INNER JOIN EDWCL_VIEWS.Ref_Order_Procedure kk
ON co.Order_Proc_Mnem_CS = kk.Order_Proc_Mnemonic_CS

WHERE Order_Proc_Name LIKE ANY ('%SEPSIS%', '%ANTIBIOTIC%')

GROUP BY 1,2,3,4,5,6,7,8,9,10,11