--Pangia3041 Microbiology-

SELECT  
	fp.Coid AS HospID
	,Substr(Cast(Cast(Trim(OTranslate(reg.Medical_Record_Num,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,'')) AS INTEGER) + 135792468 + Cast(fp.Coid AS INTEGER) + 1000000000000 AS CHAR(13)),2,12) AS PtID
	,Cast((reg.Patient_DW_ID (Format '999999999999999999')) + 135792468 + Cast(fp.Coid AS INTEGER)AS DECIMAL(18,0)) AS AdmtID
	,CPPS.Specimen_Collection_Date - fp.Admission_Date AS Rel_Coll_Date
	,CPPS.Specimen_Collection_Time AS Coll_Time
	,CPPS.Specimen_Source_Mnemonic_CS AS Source_Mnemonic
	,rss.Specimen_Source_Name AS Source_Name
	,CPPR.Result_Verify_Date - fp.Admission_Date AS Rel_Final_Report_Day
	,CPPR.Clinical_Proc_Num AS Proc_Num
	,RCTP.Clinical_Proc_Mnemonic_CS AS Proc_Mnem  
	,RCTP.Clinical_Proc_Name AS Proc_Name    
	,CPRO.Organism_Comment_Text AS Result_Answer_Text
	,FM.Microorganism_Desc AS Microorganism_Name
	,FM.Result_Status_Code
	,FM.Result_Val_Txt AS Result_Notes --this sometimes has identified data
	,FM.Susceptibility_Method_Code
	,FM.Source_System_Original_Code
	,FM.Abnormal_Ind
	,CPPR.Result_Normal_Range_Text AS  Result_Normal_Range_Text
	/*,CPPR.Result_UOM_Amt AS UOM*/
	,RCTP.Clinical_Proc_EMR_ID AS Clinical_Proc_EMR_ID
	,ncm.Standard_Code_Text AS Loinc_Code
	,lnc.LONG_NM AS Loinc_Code_Desc
FROM EDWCDM_Views.Fact_Patient fp

INNER JOIN qwu6617.Pangia3041PopA pop			--update pop
	ON fp.Patient_DW_Id = pop.Patient_DW_Id
	AND fp.Company_Code = pop.Company_Code
	AND fp.Coid = pop.Coid

INNER JOIN EDWCL_Views.Clinical_Registration reg
	ON fp.Patient_DW_Id = reg.Patient_DW_Id
	AND fp.CoID = reg.CoID
	AND fp.company_code = reg.company_code   

INNER JOIN EDWCDM_VIEWS.Clinical_Patient_Proc_Specimen CPPS
	ON fp.Patient_DW_Id = CPPS.Patient_DW_Id
	AND fp.Company_Code = cpps.Company_Code
	AND fp.Coid = cpps.Coid

LEFT JOIN EDWCL_Views.Ref_Specimen_Source rss --tying in this table gives the ability to see each the source of each sample
	ON CPPS.Company_Code = rss.Company_Code
	AND CPPS.Coid = rss.Coid
	AND CPPS.Specimen_Source_Mnemonic_CS = rss.Specimen_Source_Mnemonic

INNER JOIN EDWCDM_PC_Views.Fact_Microorganism FM --tying this table in will give me results values for the blood cultures instead of null values, which is what I was pulling back without this table
	ON FM.COID = CPPS.Coid
	AND FM.Company_Code = CPPS.Company_Code
	AND FM.Patient_DW_ID = CPPS.Patient_DW_Id

INNER JOIN EDWCL_VIEWS.Clinical_Proc_Result_Organism CPRO
	ON CPRO.Patient_DW_Id = CPPS.Patient_DW_Id
	AND CPRO.Specimen_URN=CPPS.Specimen_URN
	AND CPRO.company_code = CPPS.company_Code
	AND CPRO.COID = CPPS.COID

INNER JOIN EDWCDM_VIEWS.Clinical_Patient_Proc_Result CPPR
	ON CPPR.Patient_DW_Id = CPPS.Patient_DW_Id
	AND CPPR.Specimen_URN=CPPS.Specimen_URN
	AND cppr.company_code = cpps.company_Code
	AND CPPR.COID = CPPS.COID
	AND CPPR.Result_Verify_Date BETWEEN '2017-01-01' AND Current_Date		--update start date

INNER JOIN EDWCL_VIEWS.Ref_Clinical_Test_Procedure RCTP
	ON CPPR.COID = RCTP.COID
	AND CPPR.Clinical_Proc_Num = RCTP.Clinical_Proc_Num

LEFT JOIN EDWCL_Views.Ref_Clin_Test_Proc_Nomen tpn
	ON rctp.COID = tpn.COID
	AND rctp.Clinical_Proc_Num = tpn.Clinical_Proc_Num

LEFT JOIN EDWCL_Views.Ref_Clinical_Organism ref
	ON CPPR.COID = ref.COID
	AND CPRO.Organism_Mnemonic_CS = ref.Organism_Mnemonic_CS

LEFT JOIN EDWCL_Views.Ref_Nomenclature_Code_Map ncm
	ON tpn.COID = ncm.COID
	AND tpn.Nomenclature_Code = ncm.Nomenclature_Code
	AND ncm.Standard_Code_Type = 'LOINC'
	AND ncm.Standard_Code NOT  LIKE '%IMO%'
	AND ncm.Active_Ind = 'Y'

LEFT JOIN EDWCDM_Views.RSLT_CD lnc
	ON ncm.Standard_Code_Text = lnc.RSLT_CD
	AND lnc.VLD_TO_TS = '9999-12-31 00:00:00'

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22