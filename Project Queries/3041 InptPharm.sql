--Pangia3041 Inpatient Pharmacy

SELECT
	 fp.Coid  AS HospID
	,Substr(Cast(Cast(Trim(OTranslate(reg.Medical_Record_Num,'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ,'')) AS INTEGER) + 135792468 + Cast(fp.Coid AS INTEGER) + 1000000000000 AS CHAR(13)),2,12) AS PtID
	,Cast((fp.Patient_DW_ID (Format '999999999999999999'))  + 135792468 + Cast(fp.Coid AS INTEGER)AS DECIMAL(18,0)) AS AdmtID
	,Cast (rxadm.RX_Admin_Date_Time AS DATE Format 'YYYY-MM-DD') - Cast (fp.Admission_Date AS DATE Format 'YYYY-MM-DD') AS Rel_Admin_Date
	,rxadm.RX_Admin_Date_Time(TIME) AS Admin_Time
	,rcp.Clinical_Phrm_Trade_Name AS Med
	,rcp.Clinical_Phrm_Strength_Amt AS Strength
	,rx.RX_Admin_Route_Mnem_CS AS Route
	,rx.RX_Dose_Desc AS Dose
	,rxadm.RX_Admin_Given_Dose_Amt AS Admin_Dose
	,rxadm.Rx_Admin_UOM AS Admin_UOM
	,rx.Signatura_Mnem_CS AS Freq
	,rx.Schedule_Code AS Sched_Code
	,rx.RX_Order_Type_Mnem_CS AS MedType
	,rx.Clinical_Phrm_Mnem_CS AS PhrmMnem
	,rcp.Generic_Phrm_Mnem_CS AS GenericPhrmMnem
	,rcp.Therapeutic_Cls_Group_Mnem_CS AS TherClsGrp
	,rcp.General_Name_Group_Mnem_CS AS GenNameGrp
	,rcp.Specific_Name_Group_Mnem_CS AS SpecNameGrp
	,Substring (rcp.NDC, 1,11) AS RX_NDC	--sometimes doesn't work so pulled out
FROM EDWCDM_Views.Fact_Patient fp

INNER JOIN EDWCL_Views.Clinical_Registration reg
	ON fp.Patient_DW_Id = reg.Patient_DW_Id
	AND fp.CoID = reg.CoID
	AND reg.Company_Code = 'H'

INNER JOIN qwu6617.Pangia3041PopA pop				--update pop
	ON fp.Patient_DW_Id = pop.Patient_DW_Id
	AND fp.Coid = pop.Coid

INNER JOIN EDWCL_Views.Clinical_Patient_RX rx
	ON fp.Patient_DW_ID = rx.Patient_DW_ID
	AND fp.COID = rx.COID

INNER JOIN EDWCL_Views.Clinical_Patient_RX_Admin rxadm
	ON rx.Patient_DW_ID = rxadm.Patient_DW_ID
	AND rx.COID = rxadm.COID
	AND rx.RX_URN = rxadm.RX_URN
	AND rxadm.RX_Admin_Given_Ind = 'Y'

LEFT JOIN EDWCL_Views.Ref_Clinical_Pharmaceutical rcp
	ON rx.COID = rcp.COID
	AND rx.Clinical_Phrm_Mnem_CS = rcp.Clinical_Phrm_Mnem_CS
	
WHERE TherClsGrp in(
'W1Q',            
'W1A',            
'W1S',            
'W1W',            
'W1Y',            
'W1D',            
'W1J',            
'W1Z',            
'W1C',            
'W1P',            
'W1X',            
'W1K',           
'W1F',            
'W1O',
'W4E', 
'W2A'
)

GROUP BY 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
