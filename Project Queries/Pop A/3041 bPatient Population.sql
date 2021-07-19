--Pangia3041 Patient Population

REPLACE VIEW qwu6617.Pangia3041PT2 AS
SELECT
fp.Patient_DW_Id
,fp.Company_Code
,fp.Coid
,fp.Admission_Date
,CAST (fp.Patient_DW_ID AS CHAR(18)) as PPID
,Cast (co.Order_Date_Time AS DATE Format 'YYYY-MM-DD') - Cast (fp.Admission_Date AS DATE Format 'YYYY-MM-DD') AS Rel_Order_Date
FROM EDWCDM_Views.Fact_Patient fp

INNER JOIN EDWCL_Views.Person_CL p
ON fp.Patient_Person_DW_Id = p.Person_DW_Id

INNER JOIN EDW_Pub_Views.Fact_Facility ff
ON fp.Coid = ff.Coid
AND ff.LOB_Code = 'HOS' --Code for hospital
AND ff.COID_Status_Code = 'F' --Code for active facilities (i.e. not sold/closed)

INNER JOIN EDWCL_VIEWS.Clinical_Order co --SAME NUMBER OF PEOPLE WHEN INCLUDING SEPSIS ORDERS
ON co.Patient_DW_Id = fp.Patient_DW_Id
AND co.Company_Code = fp.Company_Code
AND co.Coid = fp.Coid

LEFT JOIN EDWCL_VIEWS.Ref_Order_Procedure kk
ON co.Order_Proc_Mnem_CS = kk.Order_Proc_Mnemonic_CS

INNER JOIN EDWCL_Views.Clinical_Reg_Patient_Type_Dtl dtl --bringing in column to identify EF
ON fp.Patient_DW_Id = dtl.Patient_DW_Id
AND fp.Company_Code = dtl.Company_Code
AND fp.Coid = dtl.Coid
AND dtl.Patient_Type_Mnemonic_CS IN ('PRE ER','REG ER')

WHERE fp.Admission_Date BETWEEN '2017-01-01' AND '2018-01-01' --update date
AND fp.Discharge_Date BETWEEN  '2017-01-01' AND '2018-01-01' --update date
--AND ((Cast((Cast((fp.Admission_Date(Format'YYYY-MM')) AS CHAR(7)) || '-01') AS DATE) - Cast((Cast((p.Person_Birth_Date(Format'YYYY-MM')) AS CHAR(7)) || '-01') AS DATE))/365) BETWEEN 'XX' AND 'XX' --update age
AND fp.Company_Code='H'
AND fp.final_bill_date <> '0001-01-01'
AND fp.final_bill_date IS NOT NULL
AND fp.COID= '34003'
AND (Order_Proc_Name LIKE ('%SEPSIS%') AND Rel_Order_Date <'3')

GROUP BY 1,2,3,4,5,6