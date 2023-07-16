*Load dataset
ssc install csdid
ssc install drdid
ssc install reghdfe
net install ddtiming, from(https://tgoldring.com/code
use "https://github.com/Mixtape-Sessions/Advanced-DID/raw/main/Exercises/Data/ehec_data.dta", clear

replace yexp2 = 3000 if yexp2 == .

**Estimate ATT(g,t) using Callaway and Sant's Anna's estimator
csdid dins, ivar(stfips) time(year) gvar(yexp2) notyet



preserve

keep if year == 2013 | year == 2014
gen treated = (yexp2 == 2014)

// calculate means
sum dins if year == 2013 & treated == 0
loc dins_00 = r(mean)
sum dins if year == 2014 & treated == 0
loc dins_01 = r(mean)
sum dins if year == 2013 & treated == 1
loc dins_10 = r(mean)
sum dins if year == 2014 & treated == 1
loc dins_11 = r(mean)
loc att_2014_2014 = (`dins_11' - `dins_10') - (`dins_01' - `dins_00')
disp "ATT(2014, 2014): `att_2014_2014'"

restore


**Aggregate the ATT(g,t)

* dynamic aggregation
csdid dins, ivar(stfips) time(year) gvar(yexp2) notyet

qui: estat event
csdid_plot

*simple aggregation
estat simple


** Two-way fixed effect
gen postTreated = year >= yexp2 & (yexp2 != 3000)

reghdfe dins i.postTreated, absorb(stfips year) vce(cluster stfips)

**Bacon's decomposition
xtset stfips year

ddtiming dins postTreated, i(stfips) t(year)


*Only use not-yet-treated
drop if yexp2 == 3000
qui: csdid dins, ivar(stfips) time(year) gvar(yexp2) notyet

qui: estat event
csdid_plot

estat simple

reghdfe dins i.postTreated, absorb(stfips year) vce(cluster stfips)

ddtiming dins postTreated, i(stfips) t(year)

**Ever bigger problem if the treatment effect changes significantly with time
gen relativeTime = year - yexp2
replace relativeTime = . if yexp2 == 3000
gen dins2 = dins + (relativeTime>0) * relativeTime * 0.01

qui: csdid dins2, ivar(stfips) time(year) gvar(yexp2) notyet
estat simple

qui: estat event
csdid_plot

reghdfe dins2 i.postTreated, absorb(stfips year) vce(cluster stfips)

*Bacon's decomposition-Negative weight
ddtiming dins2 postTreated, i(stfips) t(year)



* reghdfe
ssc install reghdfe

* honestdid
net install honestdid, from("https://raw.githubusercontent.com/mcaceresb/stata-honestdid/main") replace
honestdid _plugin_check

* csdid 
net install csdid, from ("https://raw.githubusercontent.com/friosavila/csdid_drdid/main/code/") replace

use "https://raw.githubusercontent.com/Mixtape-Sessions/Advanced-DID/main/Exercises/Data/ehec_data.dta", clear

* Keep years before 2016. Drop the 2016 cohort
keep if (year < 2016) & (missing(yexp2) | (yexp2 != 2015))

* Create a treatment dummy
gen D = (yexp2 == 2014)
gen Dyear = cond(D, year, 2013)

* Run the TWFE spec
reghdfe dins b2013.Dyear, absorb(stfips year) cluster(stfips) noconstant

coefplot, vertical yline(0) ciopts(recast(rcap)) xlabel(,angle(45)) ytitle("Estimate and 95% Conf. Int.") title("Effect on dins")

honestdid, pre(1/5) post(7/8) mvec(0.5(0.5)2)

honestdid, cached coefplot xtitle("M") ytitle("95% Robust CI")

* Run the sensitivity analysis using smoothness boundness 
honestdid, pre(1/5) post(6/7) mvec(0(0.01)0.05) delta(sd) omit coefplot xtitle("M") ytitle("95% Robust CI")



