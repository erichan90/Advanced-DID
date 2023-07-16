use "https://raw.githubusercontent.com/Mixtape-Sessions/Advanced-DID/main/Exercises/Data/ehec_data.dta", clear

* Keep years before 2016. Drop the 2016 cohort
keep if (year < 2016) & (missing(yexp2) | (yexp2 != 2015))

* Create a treatment dummy
gen D = (yexp2 == 2014)
gen Dyear = cond(D, year, 2013)

* Run the TWFE spec
reghdfe dins b2013.Dyear, absorb(stfips year) cluster(stfips) noconstant

coefplot, vertical yline(0) ciopts(recast(rcap)) xlabel(,angle(45)) ytitle("Estimate and 95% Conf. Int.") title("Effect on dins")
quietly graph export twfe.svg, replace


import delimited "C:\Users\xuhans\Desktop\Core_projects\ready_mix\outputs\event_study_parallel.csv", clear 

encode d_week,gen(d_week2)


*14 is the number for week 2023-01-08, one week before the treatment
reghdfe readyhours b17.d_week2, absorb(siteid dategranularity) cluster(siteid) noconstant
*F test for insignificance 
test i1.d_week2 i2.d_week2 i3.d_week2 i4.d_week2 i5.d_week2 i6.d_week2 i7.d_week2 i8.d_week2 i9.d_week2 i10.d_week2 i11.d_week2 i12.d_week2 i13.d_week2 i14.d_week2 i15.d_week2 i16.d_week2

coefplot, vertical yline(0) ciopts(recast(rcap)) xlabel(,angle(45)) ytitle("Estimate and 95% Conf. Int.") title("Effect on %Ready Hours")  
quietly graph export twfe.svg, replace



import excel "C:\Users\xuhans\Desktop\Core_projects\ready_mix\outputs\inputs_comparison_2023_q1.xlsx", sheet("Sheet1") firstrow clear


tab site_type,gen(type_)

rename type_1 ARS
rename type_2 IXD
rename type_3 RELO
rename type_4 TSSL
rename type_5 USNS

global inputs Day_Hours_Share Day_Acceptance Night_Acceptance Ready_Associate_Share Avg_Weekly_Work_Hours_Lost attrition_FT_replace attrition_FLEXRT_replace attrition_FLEXPT_replace weekly_worked_hours_FT_replace weekly_worked_hours_FLEXRT_repla weekly_worked_hours_FLEXPT_repla run_rate ARS IXD RELO TSSL USNS

global varlabels  Day_Acceptance "Acceptance rate for Day Shift" ///
				  Night_Acceptance "Acceptance rate for Night Shift" ///
				  attrition_FT_replace "Full-Time Attrition%" ///
				  attrition_FLEXRT_replace "Reduced-Time Attrition%" ///
				  attrition_FLEXPT_replace "Part-Time Attrition%" ///
				  weekly_worked_hours_FT_replace "Full-Time Hours of Work" ///
				  weekly_worked_hours_FLEXRT_repla "Reduced-Time Hours of Work" ///
				  weekly_worked_hours_FLEXPT_repla "Part-time Hours of Work" ///
				  run_rate "Full-time Max Day 1 Start" ///
				  ARS "AR Sortable" ///
				  IXD "IXD" ///
				  RELO "RELO" ///
				  TSSL "Sortable" ///
				  USNS "Non Sortable"



*Treatment
eststo treatment: qui estpost summarize $inputs if Treatment=="Treated"

*Control
eststo control: qui estpost summarize $inputs if Treatment=="Control"
 
*ttest differences in means 
eststo diff: quietly estpost ttest  $inputs, by(Treatment) unequal 

esttab treatment control diff  using "C:\Users\xuhans\Desktop\Core_projects\ready_mix\outputs\2023_Q1_Balance_Table.rtf", replace ///
		cells("mean(pattern(1 1 0) fmt(2)) b(star pattern(0 0 1) fmt(2)) t(pattern(0 0 1) par fmt(2))") ///
	   label varlabels( $varlabels )
	   

import excel "C:\Users\xuhans\Desktop\Core_projects\ready_mix\outputs\inputs_comparison_2023_q2.xlsx", sheet("Sheet1") firstrow clear

tab Site_Type,gen(type_)

rename type_1 ARS
rename type_2 IXD
rename type_3 RELO
rename type_4 TSSL
rename type_5 USNS

global inputs2 Day_Hours_Share Day_Acceptance Night_Acceptance Ready_Associate_Share Avg_Weekly_Work_Hours_Lost Attrition_FT Attrition_FLEXRT Attrition_FLEXPT Weekly_Worked_Hours_FT Weekly_Worked_Hours_FLEXRT Weekly_Worked_Hours_FLEXPT run_rate ARS IXD RELO TSSL USNS


global varlabels2 Day_Acceptance "Acceptance rate for Day Shift" ///
				  Night_Acceptance "Acceptance rate for Night Shift" ///
				  Attrition_FT "Full-Time Attrition%" ///
				  Attrition_FLEXRT "Reduced-Time Attrition%" ///
				  Attrition_FLEXPT  "Part-Time Attrition%" ///
				  Weekly_Worked_Hours_FT "Full-Time Hours of Work" ///
				  Weekly_Worked_Hours_FLEXRT "Reduced-Time Hours of Work" ///
				  Weekly_Worked_Hours_FLEXPT "Part-time Hours of Work" ///
				  run_rate "Full-time Max Day 1 Start" ///
				  ARS "AR Sortable" ///
				  IXD "IXD" ///
				  RELO "RELO" ///
				  TSSL "Sortable" ///
				  USNS "Non Sortable"


*Treatment
eststo treatment: qui estpost summarize $inputs2 if Q2_treatment=="Treated"

*Control
eststo control: qui estpost summarize $inputs2 if Q2_treatment=="Control"
 
*ttest differences in means 
eststo diff: quietly estpost ttest  $inputs2, by(Q2_treatment) unequal 

esttab treatment control diff  using "C:\Users\xuhans\Desktop\Core_projects\ready_mix\outputs\2023_Q2_Balance_Table.rtf", replace ///
	   cells("mean(pattern(1 1 0) fmt(2)) b(star pattern(0 0 1) fmt(2)) t(pattern(0 0 1) par fmt(2))") ///
	   label varlabels( $varlabels2)
	   