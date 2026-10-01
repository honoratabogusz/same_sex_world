* Dependency: all retained United States exhibits and appendix counts

do "config.do"
label def ssh_lab 1 "Different-sex couple" 2 "Men same-sex couple" 3 "Women same-sex couple", replace



use "../../data/raw/soc10_isco08.dta", clear

gen isco_3d = floor(isco08/10)

merge m:1 isco_3d using "../../bld/data/unempl_rates_eu_lfs.dta"

keep if _merge==3

rename soc10 occsoc
collapse unemp_occ_risk, by(occsoc)

tostring occsoc, replace

save "../../bld/data/soc10_unemp_occ_risk.dta", replace

preserve 
generate occ4= substr(occsoc,1,4)
collapse unemp_occ_risk, by(occ4)
gen  occsoc = occ4+"XX"
keep occsoc unemp_occ_risk
save "../../bld/data/soc10_xx_unemp_occ_risk.dta", replace

restore

preserve 
generate occ5= substr(occsoc,1,5)
collapse unemp_occ_risk, by(occ5)
gen  occsoc = occ5+"X"
keep occsoc unemp_occ_risk
save "../../bld/data/soc10_x_unemp_occ_risk.dta", replace

restore

append using "../../bld/data/soc10_xx_unemp_occ_risk.dta"
append using "../../bld/data/soc10_x_unemp_occ_risk.dta"
save "../../bld/data/occsoc_2010_unemp_occ_risk.dta", replace

use "../../data/raw/soc18_soc10_diff.dta", clear
tostring occsoc, replace
tostring occsoc_18, replace
merge m:1 occsoc using "../../bld/data/occsoc_2010_unemp_occ_risk.dta"
keep if _merge==3
collapse unemp_occ_risk, by(occsoc_18)
rename occsoc_18 occsoc
append using "../../bld/data/occsoc_2010_unemp_occ_risk.dta"
collapse unemp_occ_risk, by(occsoc)
save   "../../bld/data/occsoc_2018_unemp_occ_risk.dta", replace


foreach y in 2015 2016 2017 2018 2019 {
	
	use if multyear==`y' using "$raw_data/USA/usa_00001.dta", clear 
	tostring serial, gen(serial_str)
	gen hh_id = "USA"+serial_str
	replace year=multyear
	gen world_region=2
	gegen weight_sum = sum(perwt),by(year)
	gen weight_adj=perwt/weight_sum
	replace weight_adj=weight_adj/5
	gen pop_2017=325122.128
	gen weight_pop=weight_adj*pop_2017

	su density, d
	gen urban=.
	replace urban=0 if density>=0 & density<=r(p25)
	replace urban=1 if density>=r(p25) & density!=.
	
	gen age_0_14=0
	replace age_0_14=1 if age>=0 & age<=14
	gen age_15_19=0
	replace age_15_19=1 if age>=15 & age<=19
	gen age_20_64=0
	replace age_20_64=1 if age>=20 & age<=64
	gen age_65plus=0
	replace age_65plus=1 if age>=65 & age!=.
	
	gen age_0_14_nonch=0
	replace age_0_14_nonch=1 if age>=0 & age<=14 & related!=301 & related!=302 & related!=303

	foreach var in age_0_14 age_15_19 age_20_64 age_65plus{
		gegen hh_`var' = sum(`var'), by(hh_id)
		gen hh_`var'_d=.
		replace hh_`var'_d=0 if hh_`var'==0
		replace hh_`var'_d=1 if hh_`var'>0 & hh_`var'!=.
	}
	gegen hh_age_0_14_nonch_d = max(age_0_14_nonch), by(hh_id)
	
	gen age_temp_x=.
	replace age_temp_x=age if related>=301 & related<=303
	gegen age_ch_oldest = max(age_temp_x), by(hh_id)
	drop age_temp_x
	
	preserve
	
	keep if age_0_14==1
	keep hh_id related 
	gen relation_child = .
	replace relation_child=1 if related>=301 & related<=303
	replace relation_child=2 if inlist(related,701,901,1001)
	replace relation_child=3 if inlist(related,401,801,1115,1242,1260,1270,1301)
	
	save "../../bld/data/USA/data_under15_USA_`y'.dta", replace
	
	restore
	
	

	preserve

	keep if sploc!=0
	keep if urban==1
	keep if age>=20 & age<=64
	gen COUNTRY="USA"
	gen relation=0
	replace relation=1 if related==101 | related==201 | related==1114
	gcollapse relation [aweight=weight_adj], by(COUNTRY)
	save "../../bld/data/descriptives/hh_head_all_couples/hh_head_all_couples_USA`y'.dta", replace

restore


	keep if related==101 | related==201 | related==1114

	gen count_obs=1
	gegen count_s = total(count_obs), by(hh_id)
	keep if count_s==1 | count_s==2

	gegen min_age = min(age), by(hh_id)
	gegen max_age = max(age), by(hh_id)



	gen single=0
	replace single=1 if count_s==1

	gegen mean_sex = mean(sex), by(hh_id)
	cap drop couple_type
	gen couple_type=.
	replace couple_type=1 if mean_sex==1.5
	replace couple_type=2 if mean_sex==1
	replace couple_type=3 if mean_sex==2
	replace couple_type=. if single==1
	label val couple_type ssh_lab
	
	preserve 
	keep if min_age>=65 & max_age<=99
	keep if urban==1
	keep if single==0
	gen couple_type2=0
	replace couple_type2=1 if couple_type==2 | couple_type==3
	gcollapse couple_type2 [aweight=weight_pop], by(year)
	gen country = "USA"
	rename couple_type2 couple_type2_65plus
	save "../../bld/data/counts/USA/USA_ssh_obs_yrs_old_age_`y'_shares.dta", replace
	restore
	
	preserve 
	gen old_age=.
	replace old_age=0 if min_age>=20 & max_age<=64
	replace old_age=1 if min_age>=65 & max_age<=99
	keep if old_age!=.
	keep if urban==1
	keep if single==0
	cap drop mar_x
	gen mar_x=0
	replace mar_x=1 if marst==1 | marst==2
	gegen mar_x_mean=mean(mar_x), by(hh_id)
	gen married_couple=0
	replace married_couple=1 if mar_x_mean==1
	keep if married_couple==1
	gen couple_type2=0
	replace couple_type2=1 if (couple_type==2 | couple_type==3) & married_couple==1 & ssmc==2
	gcollapse couple_type2 [aweight=weight_pop], by(old_age year)
	gen COUNTRY = "USA"
	reshape wide couple_type2, i(COUNTRY year)  j(old_age)
	save "../../bld/data/descriptives/USA_ssc_old_young_`y'_shares.dta", replace
	restore
	
	
	keep if min_age>=20 & max_age<=64

	gen region=statefip
	
	drop if region==.
	tostring region, gen(region_str)
	replace region_str="USA" + region_str
	drop region
	rename region_str region
	
	cap drop ssm_direct
	gen ssm_direct=0
	replace ssm_direct=1 if ssmc==2
	
	cap drop mar_x
	gen mar_x=0
	replace mar_x=1 if marst==1 | marst==2
	gegen mar_x_mean=mean(mar_x), by(hh_id)
	gen married_couple=0
	replace married_couple=1 if mar_x_mean==1
	
	gen foreign_bp=.
	replace foreign_bp=0 if bpl>=1 & bpl<150
	replace foreign_bp=1 if bpl>=150 & bpl<=950
	gegen foreign_bp_any=max(foreign_bp), by(hh_id)
	

	gcollapse (mean) world_region pop_2017 year single couple_type  urban hh_age* ssm_direct married_couple foreign_bp_any age_ch_oldest (sum) weight_adj weight_pop, by(hh_id region)

	foreach var in weight_adj weight_pop{
		rename `var' `var'_hh
	}

	gen country_id="USA"

	save "../../bld/data/USA/data_hh_USA_`y'.dta", replace

	cap drop nobs
	gen nobs=2



	use if multyear==`y' using "$raw_data/USA/usa_00001.dta", clear 
	tostring serial, gen(serial_str)
	gen hh_id = "USA"+serial_str
	gegen weight_sum = sum(perwt), by(year)
	gen weight_adj=perwt/weight_sum
	replace weight_adj=weight_adj/5
	drop weight_sum
	
	keep if related==101 | related==201 | related==1114
	drop year
	merge m:1 hh_id using "../../bld/data/USA/data_hh_USA_`y'.dta", nogen
	gen weight_pop=weight_adj*pop_2017
	keep if single==0

	gen edu_lvl=.
	replace edu_lvl=1 if educ>=1 & educ<=5
	replace edu_lvl=2 if educ>=6 & educ<=9
	replace edu_lvl=3 if educ>=10 & educ<=11

	gen edu_secondary=.
	replace edu_secondary=1 if edu_lvl==2
	replace edu_secondary=0 if edu_lvl==1 | edu_lvl==3

	gen edu_tertiary=.
	replace edu_tertiary=1 if edu_lvl==3
	replace edu_tertiary=0 if edu_lvl==1 | edu_lvl==2
	
	gen foreign_bp=.
	replace foreign_bp=0 if bpl>=1 & bpl<150
	replace foreign_bp=1 if bpl>=150 & bpl<=950
	
	gen foreign_cit=0
	replace foreign_cit=1 if citizen==3
	
	gen race_white=0
	replace race_white=1 if race==1

	gen lab_status=empstat

	gen labor_force=.
	replace labor_force=1 if empstat==1 | empstat==2
	replace labor_force=0 if empstat==3

	gen employed=.
	replace employed=1 if empstat==1
	replace employed=0 if empstat==2 | empstat==3

	gen unemp=.
	replace unemp=1 if empstat==2
	replace unemp=0 if empstat==1

	
 
	qui gen hweek = uhrswork
 	qui gen nweek = . if wkswork2==0
	qui replace nweek = 7 if wkswork2==1
	qui replace nweek = 20 if wkswork2==2
	qui replace nweek = 33 if wkswork2==3
	qui replace nweek = 43.5 if wkswork2==4
	qui replace nweek = 48.5 if wkswork2==5
	qui replace nweek = 51 if wkswork2==6
	

	
	foreach var in incwage incbus00{
	    replace `var'=. if `var'==999999
		replace `var'=0 if `var'<=0 & `var'!=0
	}
	
	
	
	
	gen inflation=.
	qui replace inflation = 1.376 if year==2015
	qui replace inflation = 1.394 if year==2016
	qui replace inflation = 1.424 if year==2017
	qui replace inflation = 1.458 if year==2018
	qui replace inflation = 1.485 if year==2019
	
	replace inflation = inflation/1.376
	
	qui gen incwage_inf = incwage/inflation
	replace incwage_inf=0 if employed!=1


	qui gen hwage = incwage_inf / (hweek*nweek)
	
	
	replace hwage=. if hwage==0
	_pctile hwage, percentiles(99.75)
	replace hwage=r(r1) if hwage>=r(r1) & hwage!=.
	_pctile hwage, percentiles(1)
	replace hwage=r(r1) if hwage<=r(r1) & hwage!=.
	
	
	gen ln_hwage = ln(hwage)
	
	
	
	gen earnings_all = (incwage+incbus00)/inflation
	gen earnings_bus = incbus00/inflation
	gen earnings_wage = incwage/inflation
	foreach var in earnings_all earnings_bus earnings_wage{
	    replace `var'=`var'/12
		_pctile `var', percentiles(99.75)
		replace `var'=r(r1) if `var'>=r(r1) & `var'!=.
		replace `var'=0 if employed!=1
	}
	
	
	qui gen hours_worked = uhrswork
	
	
	cap drop selfemp
	gen selfemp=.
	replace selfemp=0 if classwkr==2 & employed==1
	replace selfemp=1 if classwkr==1 & employed==1
	
	
	if `y'<=2017{
		merge m:1 occsoc using "../../bld/data/occsoc_2010_unemp_occ_risk.dta"
	}
	if `y'>=2018{
		merge m:1 occsoc using "../../bld/data/occsoc_2018_unemp_occ_risk.dta"
	}	
	
	
	gen miss_any=0
	replace miss_any=1 if region=="" | edu_lvl==. | lab_status==. | weight_pop==.
	gegen miss_sum = total(miss_any), by(hh_id)
	keep if miss_sum==0


	keep hh_id country_id world_region pop_2017 year single couple_type region urban age_ch_oldest hh_age*  ssm_direct married_couple foreign_bp_any weight_adj* weight_pop* sex age edu_lvl edu_secondary edu_tertiary foreign_bp foreign_cit race_white lab_status labor_force employed unemp hours_worked hwage ln_hwage earnings_all earnings_bus earnings_wage hours_worked selfemp unemp_occ_risk occsoc
 
	save "../../bld/data/USA/data_individual_USA_`y'.dta", replace

}

clear
foreach y in 2015 2016 2017 2018 2019 {
	cap append using "../../bld/data/USA/data_hh_USA_`y'.dta"
	
}

save "../../bld/data/data_hh_USA.dta", replace

clear
foreach y in 2015 2016 2017 2018 2019 {
	cap append using "../../bld/data/USA/data_individual_USA_`y'.dta"
	
}

save "../../bld/data/data_individual_USA.dta", replace


clear
foreach y in 2015 2016 2017 2018 2019 {
	cap append using "../../bld/data/USA/data_under15_USA_`y'.dta"
	
}

merge m:1 hh_id using "../../bld/data/data_hh_USA.dta"
keep if _merge==3
keep if single==0
keep if urban==1
gen COUNTRY=country_id
tabulate relation_child, generate(rel_ch)
gcollapse rel_ch* [aweight=weight_pop], by(COUNTRY couple_type)

rename rel_ch1 child
rename rel_ch2 other_relative
rename rel_ch3 other_non_relative
keep COUNTRY couple_type child other_relative other_non_relative
* Table A.11 input
save "../../bld/data/descriptives/under_15/under_15_couple_type_USA.dta", replace

clear

foreach y in 2015 2016 2017 2018 2019 {
	append using "../../bld/data/descriptives/USA_ssc_old_young_`y'_shares.dta"
	
}
collapse couple_type20 couple_type21, by(COUNTRY)
* Figure D.8 input
save "../../bld/data/descriptives/USA_ssc_old_young_shares.dta", replace 

clear
foreach y in 2015 2016 2017 2018 2019 {
	append using "../../bld/data/descriptives/hh_head_all_couples/hh_head_all_couples_USA`y'.dta"
	
}
collapse relation, by(COUNTRY)

* Figure D.3 input
save "../../bld/data/descriptives/hh_head_all_couples/hh_head_all_couples_USA.dta", replace



