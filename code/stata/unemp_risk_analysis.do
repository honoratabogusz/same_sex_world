* Figure 7, Figure D.10, Table D.7, and Table D.8 inputs and outputs


foreach r  in developing Europe USA{
	use "../../bld/data/data_individual_`r'.dta"  , clear
	keep if urban==1
	levelsof country_id if inlist(country_id, "BEL", "BRA", "FRA", "DEU", "NLD", "GBR", "USA", "URY"), local(countries_all)
	foreach c of local countries_all{

		preserve
		keep if country_id=="`c'"
		replace unemp_occ_risk=. if employed!=1
		su unemp [aweight=weight_pop] if sex==1 & couple_type==1 
		local unemp_act=r(mean)
		su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 
		local unemp_pred=r(mean)
		gen corr_men=`unemp_pred'/ `unemp_act' 
		replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1

		su unemp [aweight=weight_pop] if sex==2 & couple_type==1
		local unemp_act=r(mean)
		su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1
		local unemp_pred=r(mean)
		gen corr_women=`unemp_pred'/ `unemp_act' 
		replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2

		gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type)
	
		save "../../bld/data/unemp_risk_analysis_`c'.dta", replace

	
	restore
	}

}





use "../../bld/data/data_individual_developing.dta", clear
keep if urban==1
replace unemp_occ_risk=. if employed!=1
su unemp [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==3
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==3
local unemp_pred=r(mean)
gen corr_men=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1 & world_region==3

su unemp [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==3
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==3
local unemp_pred=r(mean)
gen corr_women=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2 & world_region==3

gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type world_region)

gen weight_pop=1
gen employed=1
append using "../../bld/data/data_individual_Europe.dta"

drop if urban==0
replace unemp_occ_risk=. if employed!=1
su unemp [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==1
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==1
local unemp_pred=r(mean)
gen corr_men=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1 & world_region==1

su unemp [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==1
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==1
local unemp_pred=r(mean)
gen corr_women=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2 & world_region==1

gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type world_region)

gen weight_pop=1
gen employed=1
append using "../../bld/data/data_individual_USA.dta"
drop if urban==0
replace unemp_occ_risk=. if employed!=1
su unemp [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==2
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==2
local unemp_pred=r(mean)
gen corr_men=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1 & world_region==2

su unemp [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==2
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==2
local unemp_pred=r(mean)
gen corr_women=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2 & world_region==2

gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type world_region)

save "../../bld/data/unemp_risk_analysis.dta", replace






use "../../bld/data/data_individual_developing.dta", clear
keep if edu_lvl==3
drop if urban==0
replace unemp_occ_risk=. if employed!=1
su unemp [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==3
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==3
local unemp_pred=r(mean)
gen corr_men=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1 & world_region==3

su unemp [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==3
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==3
local unemp_pred=r(mean)
gen corr_women=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2 & world_region==3

gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type world_region)

gen weight_pop=1
gen employed=1
gen edu_lvl=3
append using "../../bld/data/data_individual_Europe.dta"
keep if edu_lvl==3
drop if urban==0
replace unemp_occ_risk=. if employed!=1
su unemp [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==1
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==1
local unemp_pred=r(mean)
gen corr_men=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1 & world_region==1

su unemp [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==1
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==1
local unemp_pred=r(mean)
gen corr_women=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2 & world_region==1

gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type world_region)

gen weight_pop=1
gen employed=1
gen edu_lvl=3
append using "../../bld/data/data_individual_USA.dta"
keep if edu_lvl==3
drop if urban==0
replace unemp_occ_risk=. if employed!=1
su unemp [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==2
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==2
local unemp_pred=r(mean)
gen corr_men=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1 & world_region==2

su unemp [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==2
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==2
local unemp_pred=r(mean)
gen corr_women=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2 & world_region==2

gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type world_region)

save "../../bld/data/unemp_risk_analysis_edu_tertiary.dta", replace




use "../../bld/data/data_individual_developing.dta", clear
keep if edu_lvl==2
drop if urban==0
replace unemp_occ_risk=. if employed!=1
su unemp [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==3
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==3
local unemp_pred=r(mean)
gen corr_men=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1 & world_region==3

su unemp [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==3
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==3
local unemp_pred=r(mean)
gen corr_women=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2 & world_region==3

gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type world_region)

gen weight_pop=1
gen employed=1
gen edu_lvl=2
append using "../../bld/data/data_individual_Europe.dta"
keep if edu_lvl==2
drop if urban==0
replace unemp_occ_risk=. if employed!=1
su unemp [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==1
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==1
local unemp_pred=r(mean)
gen corr_men=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1 & world_region==1

su unemp [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==1
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==1
local unemp_pred=r(mean)
gen corr_women=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2 & world_region==1

gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type world_region)

gen weight_pop=1
gen employed=1
gen edu_lvl=2
append using "../../bld/data/data_individual_USA.dta"
keep if edu_lvl==2
drop if urban==0
replace unemp_occ_risk=. if employed!=1
su unemp [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==2
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==1 & couple_type==1 & world_region==2
local unemp_pred=r(mean)
gen corr_men=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_men if sex==1 & world_region==2

su unemp [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==2
local unemp_act=r(mean)
su unemp_occ_risk [aweight=weight_pop] if sex==2 & couple_type==1 & world_region==2
local unemp_pred=r(mean)
gen corr_women=`unemp_pred'/ `unemp_act' 
replace unemp_occ_risk = unemp_occ_risk/corr_women if sex==2 & world_region==2

gcollapse unemp unemp_occ_risk [aweight=weight_pop], by(sex couple_type world_region)

save "../../bld/data/unemp_risk_analysis_edu_secondary.dta", replace






foreach r  in developing Europe USA{
	use "../../bld/data/data_individual_`r'.dta"  , clear
	keep if urban==1
	replace unemp_occ_risk=. if employed!=1
	keep if labor_force==1
	keep if urban==1
	cap drop age_group
	gen age_group=.
	replace age_group=1 if age>=20 & age<=29
	replace age_group=2 if age>=30 & age<=39
	replace age_group=3 if age>=40 & age<=49
	replace age_group=4 if age>=50 & age<=64

	gen unemp_w = unemp*weight_pop
	gen unemp_occ_risk_w = unemp_occ_risk*weight_pop
	
	levelsof country_id if inlist(country_id, "BEL", "BRA", "FRA", "DEU", "NLD", "GBR", "USA", "URY"), local(countries_all)
	foreach c of local countries_all{

		preserve
		keep if country_id=="`c'"
		gcollapse (sum) unemp_w unemp_occ_risk_w weight_pop, by(sex edu_lvl age_group)

		gen unemp = unemp_w/weight_pop
		gen unemp_occ_risk = unemp_occ_risk/weight_pop

		reg unemp unemp_occ_risk [aweight=weight_pop]
		local r2_u = e(r2)
		local r2_u = string(`r2_u', "%3.2f")
		twoway (scatter unemp unemp_occ_risk [w=weight_pop], msymbol(circle) mcolor("0 129 152 %30")) (lfit unemp unemp_occ_risk [w=weight_pop], lpattern(solid)), ylabel(0(0.05)0.2,nogrid) xtitle("Predicted unemployment rate") ytitle("Unemployment rate") xlabel(0(0.01)0.06, nogrid) legend(off) text(0.18 0.05 "{it:R-squared = `r2_u'}", size(*2))
* Figure D.10: Actual and predicted occupational unemployment risk (country panels)
graph export           "../../bld/figures/scatter_unemp_occ_risk_`c'.png", replace width(5000)

	
	restore
	}

}






mat B=J(3,3,0)

use "../../bld/data/data_individual_developing.dta", clear
keep if urban==1
keep if isco_3d!=. & employed==1

duncan isco_3d sex [aweight=weight_pop ]

matrix B[1,1] = r(D)[1,2]

duncan isco_3d couple_type if sex==1 [aweight=weight_pop ]

matrix B[2,1] = r(D)[1,2]

duncan isco_3d couple_type if sex==2 [aweight=weight_pop ]

matrix B[3,1] = r(D)[1,2]

use "../../bld/data/data_individual_Europe.dta", clear
keep if urban==1
keep if isco_3d!=. & employed==1

duncan isco_3d sex [aweight=weight_pop ]

matrix B[1,2] = r(D)[1,2]

duncan isco_3d couple_type if sex==1 [aweight=weight_pop ]

matrix B[2,2] = r(D)[1,2]

duncan isco_3d couple_type if sex==2 [aweight=weight_pop ]

matrix B[3,2] = r(D)[1,2]

use "../../bld/data/data_individual_USA.dta", clear
keep if urban==1
keep if occsoc!="     0" & employed==1

duncan occsoc sex [aweight=weight_pop ]

matrix B[1,3] = r(D)[1,2]

duncan occsoc couple_type if sex==1 [aweight=weight_pop ]

matrix B[2,3] = r(D)[1,2]

duncan occsoc couple_type if sex==2 [aweight=weight_pop ]

matrix B[3,3] = r(D)[1,2]

* Table D.7: Occupational segregation by relationship type
esttab matrix(B, fmt(3 3 3)) using "../../bld/tables/table_occ_segregation_duncan.tex", tex replace ///
collabels(none) nogap mlabels(none) nolines plain parentheses fragment ///
coeflabels(r1 "Occupational segregation by gender" r2 "Occupational segregation by relationship type: men" r3 "Occupational segregation by relationship type: women") 



mat C=J(2,3,0)

use "../../bld/data/data_individual_developing.dta", clear
keep if urban==1
keep if isco_3d!=.

duncan isco_3d sex [aweight=weight_pop ]

preserve
drop if sex==1 & couple_type==2
drop if sex==2 & couple_type==1

duncan isco_3d sex [aweight=weight_pop ]

restore

preserve
drop if sex==1 & couple_type==1
drop if sex==2 & couple_type==3

duncan isco_3d sex [aweight=weight_pop ]

restore

preserve
keep if couple_type==1

duncan isco_3d sex [aweight=weight_pop ]
matrix C[1,1] = r(D)[1,2]

restore

preserve
drop if couple_type==1


duncan isco_3d sex [aweight=weight_pop ]
matrix C[2,1] = r(D)[1,2]

restore

use "../../bld/data/data_individual_Europe.dta", clear
keep if urban==1
keep if isco_3d!=.

duncan isco_3d sex [aweight=weight_pop ]

preserve
drop if sex==1 & couple_type==2
drop if sex==2 & couple_type==1

duncan isco_3d sex [aweight=weight_pop ]

restore

preserve
drop if sex==1 & couple_type==1
drop if sex==2 & couple_type==3

duncan isco_3d sex [aweight=weight_pop ]

restore

preserve
keep if couple_type==1

duncan isco_3d sex [aweight=weight_pop ]
matrix C[1,2] = r(D)[1,2]

restore

preserve
drop if couple_type==1


duncan isco_3d sex [aweight=weight_pop ]
matrix C[2,2] = r(D)[1,2]

restore


use "../../bld/data/data_individual_USA.dta", clear
keep if urban==1
keep if occsoc!="     0"
duncan occsoc sex [aweight=weight_pop ]

preserve
drop if sex==1 & couple_type==2
drop if sex==2 & couple_type==1

duncan occsoc sex [aweight=weight_pop ]

restore

preserve
drop if sex==1 & couple_type==1
drop if sex==2 & couple_type==3

duncan occsoc sex [aweight=weight_pop ]

restore

preserve
keep if couple_type==1

duncan occsoc sex [aweight=weight_pop ]
matrix C[1,3] = r(D)[1,2]

restore

preserve
drop if couple_type==1


duncan occsoc sex [aweight=weight_pop ]
matrix C[2,3] = r(D)[1,2]

restore

* Table D.8: Occupational segregation by gender and couple type
esttab matrix(C, fmt(3 3 3)) using "../../bld/tables/table_occ_segregation_duncan_gender.tex", tex replace ///
collabels(none) nogap mlabels(none) nolines plain parentheses fragment ///
coeflabels(r1 "Occupational segregation by gender: different-sex couples" r2 "Occupational segregation by gender: same-sex couples" ) 


