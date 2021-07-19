--Pangia3041 Patient Population

CREATE VIEW qwu6617.Pangia3041PT1 AS
SELECT
fp.Patient_DW_Id
,fp.Company_Code
,fp.Coid
,fp.Admission_Date
,CAST (fp.Patient_DW_ID AS CHAR(18)) as PPID
FROM EDWCDM_Views.Fact_Patient fp

INNER JOIN EDWCL_Views.Person_CL p
ON fp.Patient_Person_DW_Id = p.Person_DW_Id

INNER JOIN EDW_Pub_Views.Fact_Facility ff
ON fp.Coid = ff.Coid
AND ff.LOB_Code = 'HOS' --Code for hospital
AND ff.COID_Status_Code = 'F' --Code for active facilities (i.e. not sold/closed)

INNER JOIN EDWCDM_PC_Views.Patient_Diagnosis  PD
ON	PD.Patient_DW_Id = FP.Patient_DW_Id  	   
AND PD.COID = FP.COID
AND PD.Diag_Mapped_Code NOT = 'Y'
AND pd.Diag_Cycle_Code = 'F'
AND pd.Diag_Rank_Num BETWEEN '1' AND '10'
AND (
	 (PD.Diag_Type_Code='0' AND pd.diag_code IN(
'A021'   
,'A227'   
,'A267'   
,'A327'   
,'A400'   
,'A401'   
,'A403'   
,'A408'   
,'A409'   
,'A4101'  
,'A4102'  
,'A411'   
,'A412'   
,'A413'   
,'A414'   
,'A4150'  
,'A4151'  
,'A4152'  
,'A4153'  
,'A4159'  
,'A4181'  
,'A4189'  
,'A419'   
,'A427'   
,'A5486'  
,'B377'   
,'O0337'  
,'O0387'  
,'O0487'  
,'O0737'  
,'O0882'  
,'O85'    
,'O8604'  
,'P360'   
,'P3610'  
,'P3619'  
,'P362'   
,'P3630'  
,'P3639'  
,'P364'   
,'P365'   
,'P368'   
,'P369'   
,'R6520'  
,'R6521'  
,'T8144XA'
,'T8144XD'
,'T8144XS'
		)))


WHERE fp.Admission_Date BETWEEN '2017-01-01' AND '2018-01-01' --update date
AND fp.Discharge_Date BETWEEN  '2017-01-01' AND '2018-01-01' --update date
AND fp.Company_Code='H'
AND fp.final_bill_date <> '0001-01-01'
AND fp.final_bill_date IS NOT NULL
AND fp.COID= '34003'

GROUP BY 1,2,3,4,5