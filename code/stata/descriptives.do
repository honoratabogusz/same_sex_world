* Tables 4, A.11, A.12, C.1-C.4, D.4-D.6; Figures D.1-D.3 and D.8



clear

global countries "ARG BEL BRA COL FRA DEU IRL MEX NLD GBR URY"
global regions "Europe USA developing"
global variables "age edu_secondary edu_tertiary"
global color_dark "0 129 152"
global color_bright "127 192 203"
global lab_size_main 3.5

set scheme plotplainblind


foreach c in ARG AUT BEL BGR BRA COL CYP CZE DEU ESP EST FRA GBR GRC HRV HUN IRL ITA LTU LUX LVA MEX MLT NLD NOR POL PRT ROU SVK SVN URY USA {
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	keep if urban==1
	keep if single==0	
	preserve
	cap drop nobs
	gen nobs=1
	gcollapse (sum) nobs, by(couple_type year)
	gen country = "`c'"
	save "../../bld/data/counts/`c'_ssh_obs_yrs.dta", replace
	restore
	gen couple_type2=0
	replace couple_type2=1 if couple_type==2 | couple_type==3
	if "`c'"!="ESP"{
	gcollapse couple_type2 [aweight=weight_pop], by(year)
	gen country = "`c'"
	save "../../bld/data/counts/`c'_ssh_obs_yrs_shares.dta", replace
	}
	if "`c'"=="ESP"{
	gcollapse couple_type2, by(year)
	gen country = "`c'"
	save "../../bld/data/counts/`c'_ssh_obs_yrs_shares.dta", replace
	}
}

clear all

foreach c in ARG BEL BRA COL DEU ESP FRA GBR IRL LUX MEX MLT NLD NOR PRT URY USA ZAF{
	cap append using "../../bld/data/counts/`c'_ssh_obs_yrs.dta"
}

keep if couple_type!=1
sort country couple_type year
gcollapse (sum) nobs, by(country)

replace country="Argentina" if country=="ARG"
replace country="Belgium" if country=="BEL"
replace country="Brazil" if country=="BRA"
replace country="Colombia" if country=="COL"
replace country="Germany" if country=="DEU"
replace country="Spain" if country=="ESP"
replace country="France" if country=="FRA"
replace country="United Kingdom" if country=="GBR"
replace country="Ireland" if country=="IRL"
replace country="Luxembourg" if country=="LUX"
replace country="Mexico" if country=="MEX"
replace country="Malta" if country=="MLT"
replace country="Netherlands" if country=="NLD"
replace country="Norway" if country=="NOR"
replace country="Portugal" if country=="PRT"
replace country="Uruguay" if country=="URY"
replace country="United States" if country=="USA"
replace country="South Africa" if country=="ZAF"

sort country

label variable country "Country"
label variable nobs "Observations"

order country nobs 

gen nobs_s = string(nobs, "%9.0fc")
drop nobs

texsave * using "../../bld/tables/table_counts.tex", frag replace

import delimited using "../../bld/tables/table_counts.tex", delimiter(tab) clear
gen keep = strpos(v1, "\tabularnewline") > 0
replace keep = cond(keep == 1, keep, sum(keep))
keep if keep == 1
drop keep
drop if _n == 1 | _n == 2
replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
replace v1 = subinstr(v1, "\\", "", .) if _n == 18
* Table D.4: Number of survey respondents in same-sex couples by country
export delimited "../../bld/tables/table_counts.tex", novarnames replace
	

foreach metric in $variables {
	
	foreach c in $countries{
	cap append using "../../bld/data/data_countries/data_individual_`c'.dta"

	}
	append using "../../bld/data/data_individual_USA.dta"
	keep if urban==1
	gen couple_type_2 = 1 if couple_type==1
	replace couple_type_2 = 2 if couple_type==2 | couple_type==3
			
	gcollapse `metric' [aweight=weight_pop], by(country_id couple_type_2 year)
	keep if couple_type_2!=.
	reshape wide `metric', i(country_id couple_type_2) j(year)
	save "../../bld/data/descriptives/`metric'_mean.dta", replace

	clear
	foreach c in $countries{
		cap append using "../../bld/data/data_countries/data_individual_`c'.dta"

	}
	append using "../../bld/data/data_individual_USA.dta"
	keep if urban==1
	gen couple_type_2 = 1 if couple_type==1
	replace couple_type_2 = 2 if couple_type==2 | couple_type==3

	gen `metric'_mean = `metric'

	gcollapse `metric'_mean [aweight=weight_pop], by(country_id couple_type_2)
	keep if couple_type_2!=.
	save "../../bld/data/descriptives/`metric'_mean_all_years.dta", replace

	clear
	foreach c in $countries{
		cap append using "../../bld/data/data_countries/data_individual_`c'.dta"

	}
	append using "../../bld/data/data_individual_USA.dta"
	keep if urban==1
	gen couple_type_2 = 1 if couple_type==1
	replace couple_type_2 = 2 if couple_type==2 | couple_type==3

	gen `metric'_sd = `metric'
	gcollapse (sd) `metric'_sd [aweight=weight_pop], by(country_id couple_type_2)
	keep if couple_type_2!=.
	save "../../bld/data/descriptives/`metric'_sd_all_years.dta", replace

	use "../../bld/data/descriptives/`metric'_mean.dta", clear
	merge 1:1 country_id couple_type_2 using "../../bld/data/descriptives/`metric'_mean_all_years.dta"
	drop _merge
	merge 1:1 country_id couple_type_2 using "../../bld/data/descriptives/`metric'_sd_all_years.dta"
	drop _merge

	tostring couple_type_2, gen(couple_type_string)
	drop couple_type_2

	replace couple_type_string="DSH" if couple_type_string=="1"
	replace couple_type_string="SSH" if couple_type_string=="2"

	foreach v in "`metric'2015" "`metric'2016" "`metric'2017" "`metric'2018" "`metric'2019" "`metric'_mean" "`metric'_sd" {
		replace `v'=round(`v', 0.01)
	}

	label variable country_id "Country"
	label variable couple_type_string "Couple Type"

	replace country_id="Argentina" if country_id=="ARG"
	replace country_id="Belgium" if country_id=="BEL"
	replace country_id="Brazil" if country_id=="BRA"
	replace country_id="Colombia" if country_id=="COL"
	replace country_id="Germany" if country_id=="DEU"
	replace country_id="France" if country_id=="FRA"
	replace country_id="United Kingdom" if country_id=="GBR"
	replace country_id="Ireland" if country_id=="IRL"
	replace country_id="Mexico" if country_id=="MEX"
	replace country_id="Netherlands" if country_id=="NLD"
	replace country_id="United States" if country_id=="USA"
	replace country_id="Uruguay" if country_id=="URY"

	sort country_id couple_type
	
	save "../../bld/data/descriptives/`metric'_for_latex.dta", replace
	
}


clear

foreach c in $regions{
	cap append using "../../bld/data/data_individual_`c'.dta"

}


use "../../bld/data/descriptives/age_for_latex.dta", clear
merge 1:1 country_id couple_type_string using "../../bld/data/descriptives/edu_secondary_for_latex.dta"
drop _merge
merge 1:1 country_id couple_type_string using "../../bld/data/descriptives/edu_tertiary_for_latex.dta"
drop _merge

gen change_16_15 = age2016 - age2015
gen change_17_16 = age2017 - age2016
gen change_18_17 = age2018 - age2017
gen change_19_18 = age2019 - age2018
gen max_change_age = max(abs(change_16_15), abs(change_17_16), abs(change_18_17), abs(change_19_18))
gen change_share_sd_age = max_change_age/age_sd

keep country_id couple_type_string max_change_age change_share_sd_age edu_secondary2015 edu_secondary2016 edu_secondary2017 edu_secondary2018 edu_secondary2019 edu_secondary_mean edu_secondary_sd edu_tertiary2015 edu_tertiary2016 edu_tertiary2017 edu_tertiary2018 edu_tertiary2019 edu_tertiary_mean edu_tertiary_sd

gen change_16_15 = edu_secondary2016 - edu_secondary2015
gen change_17_16 = edu_secondary2017 - edu_secondary2016
gen change_18_17 = edu_secondary2018 - edu_secondary2017
gen change_19_18 = edu_secondary2019 - edu_secondary2018
gen max_change_edu_secondary = max(abs(change_16_15), abs(change_17_16), abs(change_18_17), abs(change_19_18))
gen change_share_sd_edu_secondary = max_change_edu_secondary/edu_secondary_sd

keep country_id couple_type_string max_change_age  change_share_sd_age max_change_edu_secondary change_share_sd_edu_secondary edu_tertiary2015 edu_tertiary2016 edu_tertiary2017 edu_tertiary2018 edu_tertiary2019 edu_tertiary_mean edu_tertiary_sd

gen change_16_15 = edu_tertiary2016 - edu_tertiary2015
gen change_17_16 = edu_tertiary2017 - edu_tertiary2016
gen change_18_17 = edu_tertiary2018 - edu_tertiary2017
gen change_19_18 = edu_tertiary2019 - edu_tertiary2018
gen max_change_edu_tertiary = max(abs(change_16_15), abs(change_17_16), abs(change_18_17), abs(change_19_18))
gen change_share_sd_edu_tertiary = max_change_edu_tertiary/edu_tertiary_sd

keep country_id couple_type_string max_change_age change_share_sd_age max_change_edu_secondary change_share_sd_edu_secondary max_change_edu_tertiary change_share_sd_edu_tertiary

gen max_change_age_new = string(max_change_age,"%4.2f")
gen change_share_sd_age_new = string(change_share_sd_age,"%4.2f")
gen max_change_edu_sec_new = string(max_change_edu_secondary,"%4.2f")
gen change_share_sd_edu_sec_new = string(change_share_sd_edu_secondary,"%4.2f")
gen max_change_edu_ter_new = string(max_change_edu_tertiary,"%4.2f")
gen change_share_sd_edu_ter_new = string(change_share_sd_edu_tertiary,"%4.2f")

drop max_change_age- change_share_sd_edu_tertiary

drop if couple_type_string == "DSH"
drop couple_type_string

sort country_id



texsave * using "../../bld/tables/table_desc_quality_check.tex", frag replace

import delimited using "../../bld/tables/table_desc_quality_check.tex", clear
gen keep = strpos(v1, "\tabularnewline") > 0
replace keep = cond(keep == 1, keep, sum(keep))
keep if keep == 1
drop keep
drop if _n == 1 | _n == 2
replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
replace v1 = subinstr(v1, "\\", "", .) if _n == 12
* Table D.5: Maximum year-to-year demographic change
export delimited "../../bld/tables/table_desc_quality_check.tex", novarnames replace
	

clear

foreach c in $countries{
	cap append using "../../bld/data/counts/`c'_ssh_obs_yrs_shares.dta"
}
cap append using "../../bld/data/counts/USA_ssh_obs_yrs_shares.dta"
gcollapse (mean) couple_type2, by(country)
save "../../bld/data/counts/country_shares.dta", replace

clear

foreach c in ARG COL MEX URY{
	cap append using "../../bld/data/counts/`c'_ssh_obs_yrs_old_age_shares.dta"
}
foreach y in 2015 2016 2017 2018 2019{
	cap append using "../../bld/data/counts/BRA/BRA_ssh_obs_yrs_old_age_`y'_shares.dta"
}
foreach y in 2015 2016 2017 2018 2019{
	cap append using "../../bld/data/counts/USA/USA_ssh_obs_yrs_old_age_`y'_shares.dta"
}

foreach c in BEL FRA DEU IRL NLD GBR{
	foreach y in 2015 2016 2017 2018 2019{
	cap append using "../../bld/data/counts/Europe/`c'_ssh_obs_yrs_old_age_`y'_shares.dta"
}
}
gcollapse (mean) couple_type2_65plus, by(country)
save "../../bld/data/counts/country_shares_65plus.dta", replace

use "../../bld/data/counts/country_shares.dta", clear
merge 1:1 country using "../../bld/data/counts/country_shares_65plus.dta"
drop _merge

	replace country="Argentina" if country=="ARG"
	replace country="Belgium" if country=="BEL"
	replace country="Brazil" if country=="BRA"
	replace country="Colombia" if country=="COL"
	replace country="Germany" if country=="DEU"
	replace country="France" if country=="FRA"
	replace country="United Kingdom" if country=="GBR"
	replace country="Ireland" if country=="IRL"
	replace country="Mexico" if country=="MEX"
	replace country="Netherlands" if country=="NLD"
	replace country="United States" if country=="USA"
	replace country="Uruguay" if country=="URY"

sort country

replace couple_type2 = couple_type2 * 100
replace couple_type2_65plus = couple_type2_65plus * 100
gen couple_type2_s = string(couple_type2,"%4.2f")
gen couple_type2_65plus_s = string(couple_type2_65plus,"%4.2f")
replace couple_type2_s = couple_type2_s + "%"
replace couple_type2_65plus_s = couple_type2_65plus_s + "%"
drop couple_type2 couple_type2_65plus
order country couple_type2_s couple_type2_65plus_s

label variable country "Country"
label variable couple_type2_s "Aged 18-64"
label variable couple_type2_65plus_s "Aged 65+"

texsave * using "../../bld/tables/table_counts_shares.tex", frag replace

import delimited using  "../../bld/tables/table_counts_shares.tex", clear
gen keep = strpos(v1, "\tabularnewline") > 0
replace keep = cond(keep == 1, keep, sum(keep))
keep if keep == 1
drop keep
drop if _n == 1 | _n == 2
replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
replace v1 = subinstr(v1, "\\", "", .) if _n == 12
* Table D.6: Same-sex-couple share by country and age
export delimited "../../bld/tables/table_counts_shares.tex", novarnames replace


clear

foreach c in AUT BEL BGR CYP CZE DEU ESP EST FRA GBR GRC HRV HUN IRL ITA LTU LUX LVA MLT NLD NOR POL PRT ROU SVK SVN {
	cap append using "../../bld/data/counts/`c'_ssh_obs_yrs.dta"
}

gen couple_type2 = 1 if couple_type == 1
replace couple_type2 = 2 if couple_type != 1

gcollapse (sum) nobs, by(country couple_type2)
reshape wide nobs, i(country) j(couple_type2)
replace nobs2 = 0 if nobs2 == .

gen ssc_marriage = 1 if country == "BEL" | country == "DEU" | country == "FRA" | country == "NLD" | country == "GBR" 
replace ssc_marriage = 2 if country == "ESP" | country == "IRL" | country == "LUX" | country == "MLT" | country == "NOR" | country == "PRT" 
replace ssc_marriage = 3 if ssc_marriage == .

graph bar nobs2, over(country, sort(1) descending lab(angle(45) labsize($lab_size_main))) ytitle("") bar(1, color("$color_dark") lwidth(medium) fintensity(inten100)) ylabel(0(1000)7000, nogrid labsize($lab_size_main)) plotregion(lstyle(none))
* Figure D.1: Same-sex-couple respondent counts in Europe
graph export "../../bld/figures/ssc_ind_counts_eu_lfs.png", width(1058) replace

clear

foreach c in AUT BEL BGR CYP CZE DEU ESP EST FRA GBR GRC HRV HUN IRL ITA LTU LUX LVA MLT NLD NOR POL PRT ROU SVK SVN {
	cap append using "../../bld/data/counts/`c'_ssh_obs_yrs_shares.dta"
} 

gen ssc_marriage = 1 if country == "BEL" | country == "DEU" | country == "FRA" | country == "NLD" | country == "GBR" 
replace ssc_marriage = 2 if country == "ESP" | country == "IRL" | country == "LUX" | country == "MLT" | country == "NOR" | country == "PRT" 
replace ssc_marriage = 3 if ssc_marriage == .

gcollapse (mean) couple_type2, by(ssc_marriage)

lab def ssc_marriage 1 "Legal, final sample" 2 "Legal, low data quality" 3 "Illegal"
lab val ssc_marriage ssc_marriage

graph bar couple_type2, over(ssc_marriage, sort(1) descending lab(labsize($lab_size_main))) ytitle("") bar(1, color("$color_dark") lwidth(medium) fintensity(inten100)) ylabel(0 "0.0%" 0.005 "0.5%" 0.01 "1.0%" 0.015 "1.5%", format(%04.3f) nogrid labsize($lab_size_main)) plotregion(lstyle(none))
* Figure D.2: Same-sex-couple respondent shares by marriage-law status
graph export "../../bld/figures/ssc_ind_shares_eu_lfs.png", width(1058) replace



clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
gen flag = .
replace flag = 1 if (country_id == "USA" & year == 2015)
replace flag = 1 if (country_id == "DEU" & year < 2018)
replace flag = 0 if flag == .
keep if flag == 0
gen edu_primary = 1 if edu_lvl == 1
replace edu_primary = 0 if edu_primary == .
gcollapse (mean) edu_primary edu_secondary edu_tertiary [aweight=weight_pop], by(world_region couple_type married_couple)
keep if married_couple != .
rename edu_primary share1
rename edu_secondary share2
rename edu_tertiary share3
reshape long share, i(world_region married_couple couple_type) j(edu_lvl)
reshape wide share, i(world_region married_couple edu) j(couple_type)
reshape wide share1 share2 share3, i(world_region edu) j(married_couple)
rename share11 married_couple1
rename share21 married_couple2
rename share31 married_couple3
rename share10 cohabitation1
rename share20 cohabitation2
rename share30 cohabitation3
foreach var in cohabitation1 cohabitation2 cohabitation3 married_couple1 married_couple2 married_couple3 {
	replace `var' = `var' * 100 
}
gen married_couple1_s = string(married_couple1,"%4.2f")
gen cohabitation1_s = string(cohabitation1,"%4.2f")
gen married_couple2_s = string(married_couple2,"%4.2f")
gen cohabitation2_s = string(cohabitation2,"%4.2f")
gen married_couple3_s = string(married_couple3,"%4.2f")
gen cohabitation3_s = string(cohabitation3,"%4.2f")
drop cohabitation1 - married_couple3
replace married_couple1_s = married_couple1_s + "%"
replace cohabitation1_s = cohabitation1_s + "%"
replace married_couple2_s = married_couple2_s + "%"
replace cohabitation2_s = cohabitation2_s + "%"
replace married_couple3_s = married_couple3_s + "%"
replace cohabitation3_s = cohabitation3_s + "%"
save "../../bld/data/descriptives/shares_married.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
gen flag = .
replace flag = 1 if (country_id == "USA" & year == 2015)
replace flag = 1 if (country_id == "DEU" & year < 2018)
replace flag = 0 if flag == .
keep if flag == 0
gcollapse (mean) age [aweight=weight_pop], by(world_region couple_type married_couple)
keep if married_couple!=.
reshape wide age, i(world_region couple_type) j(married_couple)
rename age0 cohabitation
rename age1 married_couple
reshape wide married_couple cohabitation, i(world_region) j(couple_type)
gen edu_lvl = 88
gen married_couple1_s = string(married_couple1,"%4.2f")
gen cohabitation1_s = string(cohabitation1,"%4.2f")
gen married_couple2_s = string(married_couple2,"%4.2f")
gen cohabitation2_s = string(cohabitation2,"%4.2f")
gen married_couple3_s = string(married_couple3,"%4.2f")
gen cohabitation3_s = string(cohabitation3,"%4.2f")
drop cohabitation1 - married_couple3
order world_region edu_lvl married_couple1_s cohabitation1_s married_couple2_s cohabitation2_s married_couple3_s cohabitation3_s
save "../../bld/data/descriptives/age_by_married_status.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
gen flag = .
replace flag = 1 if (country_id == "USA" & year == 2015)
replace flag = 1 if (country_id == "DEU" & year < 2018)
replace flag = 0 if flag == .
keep if flag == 0
gen nobs = 1
gcollapse (count) nobs [aweight=weight_pop], by(world_region couple_type married_couple)
keep if married_couple!=.
reshape wide nobs, i(world_region couple_type) j(married_couple)
rename nobs0 cohabitation
rename nobs1 married_couple
reshape wide married_couple cohabitation, i(world_region) j(couple_type)
gen edu_lvl = 99
gen married_couple1_s = string(married_couple1, "%9.0fc")
gen cohabitation1_s = string(cohabitation1, "%9.0fc")
gen married_couple2_s = string(married_couple2, "%9.0fc")
gen cohabitation2_s = string(cohabitation2, "%9.0fc")
gen married_couple3_s = string(married_couple3, "%9.0fc")
gen cohabitation3_s = string(cohabitation3, "%9.0fc")
drop cohabitation1 - married_couple3
order world_region edu_lvl married_couple1_s cohabitation1_s married_couple2_s cohabitation2_s married_couple3_s cohabitation3_s
save "../../bld/data/descriptives/obs_by_married_status.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
gen flag = .
replace flag = 1 if (country_id == "USA" & year == 2015)
replace flag = 1 if (country_id == "DEU" & year < 2018)
replace flag = 0 if flag == .
keep if flag == 0
gcollapse (mean) married_couple [aweight=weight_pop], by(world_region couple_type)
gen cohabitation = 1 - married_couple
reshape wide married_couple cohabitation, i(world_region) j(couple_type)
gen edu_lvl = 111
foreach var in married_couple1 cohabitation1 married_couple2 cohabitation2 married_couple3 cohabitation3 {
	replace `var' = `var' * 100 
}
gen married_couple1_s = string(married_couple1,"%4.2f")
gen cohabitation1_s = string(cohabitation1,"%4.2f")
gen married_couple2_s = string(married_couple2,"%4.2f")
gen cohabitation2_s = string(cohabitation2,"%4.2f")
gen married_couple3_s = string(married_couple3,"%4.2f")
gen cohabitation3_s = string(cohabitation3,"%4.2f")
drop married_couple1 - cohabitation3
replace married_couple1_s = married_couple1_s + "%"
replace cohabitation1_s = cohabitation1_s + "%"
replace married_couple2_s = married_couple2_s + "%"
replace cohabitation2_s = cohabitation2_s + "%"
replace married_couple3_s = married_couple3_s + "%"
replace cohabitation3_s = cohabitation3_s + "%"
order world_region edu_lvl married_couple1_s cohabitation1_s married_couple2_s cohabitation2_s married_couple3_s cohabitation3_s
save "../../bld/data/descriptives/share_by_married_status.dta", replace

foreach region in 1 2 3 {
	use "../../bld/data/descriptives/shares_married.dta", clear
	append using "../../bld/data/descriptives/age_by_married_status.dta"
	append using "../../bld/data/descriptives/obs_by_married_status.dta"
	append using "../../bld/data/descriptives/share_by_married_status.dta"

	keep if world_region==`region'
	drop world_region
	sort edu_lvl
	tostring edu_lvl, replace

	replace edu_lvl="Primary Education" if edu_lvl=="1"
	replace edu_lvl="Secondary Education" if edu_lvl=="2"
	replace edu_lvl="Tertiary Education" if edu_lvl=="3"
	replace edu_lvl="Age" if edu_lvl=="88"
	replace edu_lvl="Observations" if edu_lvl=="99"
	replace edu_lvl="Share" if edu_lvl=="111"

	texsave * using "../../bld/tables/table_marriage_`region'.tex", frag replace
	
	import delimited using "../../bld/tables/table_marriage_`region'.tex", delimiter(tab) clear
	gen keep = strpos(v1, "\tabularnewline") > 0
	replace keep = cond(keep == 1, keep, sum(keep))
	keep if keep == 1
	drop keep
	drop if _n == 1 | _n == 2
	replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
	if `region' == 2 {
		replace v1 = subinstr(v1, "\\", "", .) if _n == 6
	}
	* Table C.1: Selection into marriage (three regional fragments)
	export delimited "../../bld/tables/table_marriage_`region'.tex", novarnames replace
}


clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
gen edu_primary = 1 if edu_lvl == 1
replace edu_primary = 0 if edu_primary == .
gcollapse (mean) edu_primary edu_secondary edu_tertiary [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d != .
rename edu_primary share1
rename edu_secondary share2
rename edu_tertiary share3
reshape long share, i(world_region hh_age_0_14_d couple_type) j(edu_lvl)
reshape wide share, i(world_region hh_age_0_14_d edu) j(couple_type)
reshape wide share1 share2 share3, i(world_region edu) j(hh_age_0_14_d)
rename share11 hh_age_0_14_d1
rename share21 hh_age_0_14_d2
rename share31 hh_age_0_14_d3
rename share10 childless1
rename share20 childless2
rename share30 childless3
foreach var in childless1 childless2 childless3 hh_age_0_14_d1 hh_age_0_14_d2 hh_age_0_14_d3 {
	replace `var' = `var' * 100 
}
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop childless1 - hh_age_0_14_d3
replace hh_age_0_14_d1_s = hh_age_0_14_d1_s + "%"
replace childless1_s = childless1_s + "%"
replace hh_age_0_14_d2_s = hh_age_0_14_d2_s + "%"
replace childless2_s = childless2_s + "%"
replace hh_age_0_14_d3_s = hh_age_0_14_d3_s + "%"
replace childless3_s = childless3_s + "%"
save "../../bld/data/descriptives/shares_children_all.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
gcollapse (mean) age [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d!=.
reshape wide age, i(world_region couple_type) j(hh_age_0_14_d)
rename age0 childless
rename age1 hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 88
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop childless1 - hh_age_0_14_d3
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/age_by_children_status_all.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
gen nobs = 1
gcollapse (count) nobs [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d!=.
reshape wide nobs, i(world_region couple_type) j(hh_age_0_14_d)
rename nobs0 childless
rename nobs1 hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 99
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1, "%9.0fc")
gen childless1_s = string(childless1, "%9.0fc")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2, "%9.0fc")
gen childless2_s = string(childless2, "%9.0fc")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3, "%9.0fc")
gen childless3_s = string(childless3, "%9.0fc")
drop childless1 - hh_age_0_14_d3
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/obs_by_children_status_all.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
gcollapse (mean) hh_age_0_14_d [aweight=weight_pop], by(world_region couple_type)
gen childless = 1 - hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 111
foreach var in hh_age_0_14_d1 childless1 hh_age_0_14_d2 childless2 hh_age_0_14_d3 childless3 {
	replace `var' = `var' * 100 
}
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop hh_age_0_14_d1 - childless3
replace hh_age_0_14_d1_s = hh_age_0_14_d1_s + "%"
replace childless1_s = childless1_s + "%"
replace hh_age_0_14_d2_s = hh_age_0_14_d2_s + "%"
replace childless2_s = childless2_s + "%"
replace hh_age_0_14_d3_s = hh_age_0_14_d3_s + "%"
replace childless3_s = childless3_s + "%"
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/share_by_children_status_all.dta", replace

foreach region in 1 2 3 {
	use "../../bld/data/descriptives/shares_children_all.dta", clear
	append using "../../bld/data/descriptives/age_by_children_status_all.dta"
	append using "../../bld/data/descriptives/obs_by_children_status_all.dta"
	append using "../../bld/data/descriptives/share_by_children_status_all.dta"

	keep if world_region==`region'
	drop world_region
	sort edu_lvl
	tostring edu_lvl, replace

	replace edu_lvl="Primary Education" if edu_lvl=="1"
	replace edu_lvl="Secondary Education" if edu_lvl=="2"
	replace edu_lvl="Tertiary Education" if edu_lvl=="3"
	replace edu_lvl="Age" if edu_lvl=="88"
	replace edu_lvl="Observations" if edu_lvl=="99"
	replace edu_lvl="Share" if edu_lvl=="111"

	texsave * using "../../bld/tables/table_children_all_`region'.tex", frag replace
	
	import delimited using "../../bld/tables/table_children_all_`region'.tex", delimiter(tab) clear
	gen keep = strpos(v1, "\tabularnewline") > 0
	replace keep = cond(keep == 1, keep, sum(keep))
	keep if keep == 1
	drop keep
	drop if _n == 1 | _n == 2
	replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
	if `region' == 2 {
		replace v1 = subinstr(v1, "\\", "", .) if _n == 6
	}
	* Table 4: Selection into parenthood (three regional fragments)
	export delimited "../../bld/tables/table_children_all_`region'.tex", novarnames replace
}


clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
drop if country_id == "BRA"
gen edu_primary = 1 if edu_lvl == 1
replace edu_primary = 0 if edu_primary == .
gcollapse (mean) edu_primary edu_secondary edu_tertiary [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d != .
rename edu_primary share1
rename edu_secondary share2
rename edu_tertiary share3
reshape long share, i(world_region hh_age_0_14_d couple_type) j(edu_lvl)
reshape wide share, i(world_region hh_age_0_14_d edu) j(couple_type)
reshape wide share1 share2 share3, i(world_region edu) j(hh_age_0_14_d)
rename share11 hh_age_0_14_d1
rename share21 hh_age_0_14_d2
rename share31 hh_age_0_14_d3
rename share10 childless1
rename share20 childless2
rename share30 childless3
foreach var in childless1 childless2 childless3 hh_age_0_14_d1 hh_age_0_14_d2 hh_age_0_14_d3 {
	replace `var' = `var' * 100 
}
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop childless1 - hh_age_0_14_d3
replace hh_age_0_14_d1_s = hh_age_0_14_d1_s + "%"
replace childless1_s = childless1_s + "%"
replace hh_age_0_14_d2_s = hh_age_0_14_d2_s + "%"
replace childless2_s = childless2_s + "%"
replace hh_age_0_14_d3_s = hh_age_0_14_d3_s + "%"
replace childless3_s = childless3_s + "%"
save "../../bld/data/descriptives/shares_children_all_bra.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
drop if country_id == "BRA"
gcollapse (mean) age [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d!=.
reshape wide age, i(world_region couple_type) j(hh_age_0_14_d)
rename age0 childless
rename age1 hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 88
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop childless1 - hh_age_0_14_d3
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/age_by_children_status_all_bra.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
drop if country_id == "BRA"
gen nobs = 1
gcollapse (count) nobs [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d!=.
reshape wide nobs, i(world_region couple_type) j(hh_age_0_14_d)
rename nobs0 childless
rename nobs1 hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 99
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1, "%9.0fc")
gen childless1_s = string(childless1, "%9.0fc")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2, "%9.0fc")
gen childless2_s = string(childless2, "%9.0fc")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3, "%9.0fc")
gen childless3_s = string(childless3, "%9.0fc")
drop childless1 - hh_age_0_14_d3
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/obs_by_children_status_all_bra.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
drop if country_id == "BRA"
gcollapse (mean) hh_age_0_14_d [aweight=weight_pop], by(world_region couple_type)
gen childless = 1 - hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 111
foreach var in hh_age_0_14_d1 childless1 hh_age_0_14_d2 childless2 hh_age_0_14_d3 childless3 {
	replace `var' = `var' * 100 
}
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop hh_age_0_14_d1 - childless3
replace hh_age_0_14_d1_s = hh_age_0_14_d1_s + "%"
replace childless1_s = childless1_s + "%"
replace hh_age_0_14_d2_s = hh_age_0_14_d2_s + "%"
replace childless2_s = childless2_s + "%"
replace hh_age_0_14_d3_s = hh_age_0_14_d3_s + "%"
replace childless3_s = childless3_s + "%"
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/share_by_children_status_all_bra.dta", replace

foreach region in 1 2 3 {
	use "../../bld/data/descriptives/shares_children_all_bra.dta", clear
	append using "../../bld/data/descriptives/age_by_children_status_all_bra.dta"
	append using "../../bld/data/descriptives/obs_by_children_status_all_bra.dta"
	append using "../../bld/data/descriptives/share_by_children_status_all_bra.dta"

	keep if world_region==`region'
	drop world_region
	sort edu_lvl
	tostring edu_lvl, replace

	replace edu_lvl="Primary Education" if edu_lvl=="1"
	replace edu_lvl="Secondary Education" if edu_lvl=="2"
	replace edu_lvl="Tertiary Education" if edu_lvl=="3"
	replace edu_lvl="Age" if edu_lvl=="88"
	replace edu_lvl="Observations" if edu_lvl=="99"
	replace edu_lvl="Share" if edu_lvl=="111"

	texsave * using "../../bld/tables/table_children_all_bra_`region'.tex", frag replace
	
	import delimited using "../../bld/tables/table_children_all_bra_`region'.tex", delimiter(tab) clear
	gen keep = strpos(v1, "\tabularnewline") > 0
	replace keep = cond(keep == 1, keep, sum(keep))
	keep if keep == 1
	drop keep
	drop if _n == 1 | _n == 2
	replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
	if `region' == 2 {
		replace v1 = subinstr(v1, "\\", "", .) if _n == 6
	}
	* Table C.2: Selection into parenthood excluding Brazil
	export delimited "../../bld/tables/table_children_all_bra_`region'.tex", novarnames replace
}


clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
keep if married_couple == 1
gen edu_primary = 1 if edu_lvl == 1
replace edu_primary = 0 if edu_primary == .
gcollapse (mean) edu_primary edu_secondary edu_tertiary [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d != .
rename edu_primary share1
rename edu_secondary share2
rename edu_tertiary share3
reshape long share, i(world_region hh_age_0_14_d couple_type) j(edu_lvl)
reshape wide share, i(world_region hh_age_0_14_d edu) j(couple_type)
reshape wide share1 share2 share3, i(world_region edu) j(hh_age_0_14_d)
rename share11 hh_age_0_14_d1
rename share21 hh_age_0_14_d2
rename share31 hh_age_0_14_d3
rename share10 childless1
rename share20 childless2
rename share30 childless3
foreach var in childless1 childless2 childless3 hh_age_0_14_d1 hh_age_0_14_d2 hh_age_0_14_d3 {
	replace `var' = `var' * 100 
}
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop childless1 - hh_age_0_14_d3
replace hh_age_0_14_d1_s = hh_age_0_14_d1_s + "%"
replace childless1_s = childless1_s + "%"
replace hh_age_0_14_d2_s = hh_age_0_14_d2_s + "%"
replace childless2_s = childless2_s + "%"
replace hh_age_0_14_d3_s = hh_age_0_14_d3_s + "%"
replace childless3_s = childless3_s + "%"
save "../../bld/data/descriptives/shares_children_married.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
keep if married_couple == 1
gcollapse (mean) age [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d!=.
reshape wide age, i(world_region couple_type) j(hh_age_0_14_d)
rename age0 childless
rename age1 hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 88
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop childless1 - hh_age_0_14_d3
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/age_by_children_status_married.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
keep if married_couple == 1 
gen nobs = 1
gcollapse (count) nobs [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d!=.
reshape wide nobs, i(world_region couple_type) j(hh_age_0_14_d)
rename nobs0 childless
rename nobs1 hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 99
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1, "%9.0fc")
gen childless1_s = string(childless1, "%9.0fc")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2, "%9.0fc")
gen childless2_s = string(childless2, "%9.0fc")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3, "%9.0fc")
gen childless3_s = string(childless3, "%9.0fc")
drop childless1 - hh_age_0_14_d3
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/obs_by_children_status_married.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
keep if married_couple == 1 
gcollapse (mean) hh_age_0_14_d [aweight=weight_pop], by(world_region couple_type)
gen childless = 1 - hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 111
foreach var in hh_age_0_14_d1 childless1 hh_age_0_14_d2 childless2 hh_age_0_14_d3 childless3 {
	replace `var' = `var' * 100 
}
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop hh_age_0_14_d1 - childless3
replace hh_age_0_14_d1_s = hh_age_0_14_d1_s + "%"
replace childless1_s = childless1_s + "%"
replace hh_age_0_14_d2_s = hh_age_0_14_d2_s + "%"
replace childless2_s = childless2_s + "%"
replace hh_age_0_14_d3_s = hh_age_0_14_d3_s + "%"
replace childless3_s = childless3_s + "%"
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/share_by_children_status_married.dta", replace

foreach region in 1 2 3 {
	use "../../bld/data/descriptives/shares_children_married.dta", clear
	append using "../../bld/data/descriptives/age_by_children_status_married.dta"
	append using "../../bld/data/descriptives/obs_by_children_status_married.dta"
	append using "../../bld/data/descriptives/share_by_children_status_married.dta"

	keep if world_region==`region'
	drop world_region
	sort edu_lvl
	tostring edu_lvl, replace

	replace edu_lvl="Primary Education" if edu_lvl=="1"
	replace edu_lvl="Secondary Education" if edu_lvl=="2"
	replace edu_lvl="Tertiary Education" if edu_lvl=="3"
	replace edu_lvl="Age" if edu_lvl=="88"
	replace edu_lvl="Observations" if edu_lvl=="99"
	replace edu_lvl="Share" if edu_lvl=="111"

	texsave * using "../../bld/tables/table_children_married_`region'.tex", frag replace
	
	import delimited using "../../bld/tables/table_children_married_`region'.tex", delimiter(tab) clear
	gen keep = strpos(v1, "\tabularnewline") > 0
	replace keep = cond(keep == 1, keep, sum(keep))
	keep if keep == 1
	drop keep
	drop if _n == 1 | _n == 2
	replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
	if `region' == 2 {
		replace v1 = subinstr(v1, "\\", "", .) if _n == 6
	}
	* Table C.3: Selection into parenthood among married couples
	export delimited "../../bld/tables/table_children_married_`region'.tex", novarnames replace
}


clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
keep if married_couple == 0
gen edu_primary = 1 if edu_lvl == 1
replace edu_primary = 0 if edu_primary == .
gcollapse (mean) edu_primary edu_secondary edu_tertiary [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d != .
rename edu_primary share1
rename edu_secondary share2
rename edu_tertiary share3
reshape long share, i(world_region hh_age_0_14_d couple_type) j(edu_lvl)
reshape wide share, i(world_region hh_age_0_14_d edu) j(couple_type)
reshape wide share1 share2 share3, i(world_region edu) j(hh_age_0_14_d)
rename share11 hh_age_0_14_d1
rename share21 hh_age_0_14_d2
rename share31 hh_age_0_14_d3
rename share10 childless1
rename share20 childless2
rename share30 childless3
foreach var in childless1 childless2 childless3 hh_age_0_14_d1 hh_age_0_14_d2 hh_age_0_14_d3 {
	replace `var' = `var' * 100 
}
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop childless1 - hh_age_0_14_d3
replace hh_age_0_14_d1_s = hh_age_0_14_d1_s + "%"
replace childless1_s = childless1_s + "%"
replace hh_age_0_14_d2_s = hh_age_0_14_d2_s + "%"
replace childless2_s = childless2_s + "%"
replace hh_age_0_14_d3_s = hh_age_0_14_d3_s + "%"
replace childless3_s = childless3_s + "%"
save "../../bld/data/descriptives/shares_children_unmarried.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
keep if married_couple == 0
gcollapse (mean) age [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d!=.
reshape wide age, i(world_region couple_type) j(hh_age_0_14_d)
rename age0 childless
rename age1 hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 88
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop childless1 - hh_age_0_14_d3
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/age_by_children_status_unmarried.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
keep if married_couple == 0
gen nobs = 1
gcollapse (count) nobs [aweight=weight_pop], by(world_region couple_type hh_age_0_14_d)
keep if hh_age_0_14_d!=.
reshape wide nobs, i(world_region couple_type) j(hh_age_0_14_d)
rename nobs0 childless
rename nobs1 hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 99
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1, "%9.0fc")
gen childless1_s = string(childless1, "%9.0fc")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2, "%9.0fc")
gen childless2_s = string(childless2, "%9.0fc")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3, "%9.0fc")
gen childless3_s = string(childless3, "%9.0fc")
drop childless1 - hh_age_0_14_d3
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/obs_by_children_status_unmarried.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
keep if married_couple == 0
gcollapse (mean) hh_age_0_14_d [aweight=weight_pop], by(world_region couple_type)
gen childless = 1 - hh_age_0_14_d
reshape wide hh_age_0_14_d childless, i(world_region) j(couple_type)
gen edu_lvl = 111
foreach var in hh_age_0_14_d1 childless1 hh_age_0_14_d2 childless2 hh_age_0_14_d3 childless3 {
	replace `var' = `var' * 100 
}
gen hh_age_0_14_d1_s = string(hh_age_0_14_d1,"%4.2f")
gen childless1_s = string(childless1,"%4.2f")
gen hh_age_0_14_d2_s = string(hh_age_0_14_d2,"%4.2f")
gen childless2_s = string(childless2,"%4.2f")
gen hh_age_0_14_d3_s = string(hh_age_0_14_d3,"%4.2f")
gen childless3_s = string(childless3,"%4.2f")
drop hh_age_0_14_d1 - childless3
replace hh_age_0_14_d1_s = hh_age_0_14_d1_s + "%"
replace childless1_s = childless1_s + "%"
replace hh_age_0_14_d2_s = hh_age_0_14_d2_s + "%"
replace childless2_s = childless2_s + "%"
replace hh_age_0_14_d3_s = hh_age_0_14_d3_s + "%"
replace childless3_s = childless3_s + "%"
order world_region edu_lvl hh_age_0_14_d1_s childless1_s hh_age_0_14_d2_s childless2_s hh_age_0_14_d3_s childless3_s
save "../../bld/data/descriptives/share_by_children_status_unmarried.dta", replace

foreach region in 1 2 3 {
	use "../../bld/data/descriptives/shares_children_unmarried.dta", clear
	append using "../../bld/data/descriptives/age_by_children_status_unmarried.dta"
	append using "../../bld/data/descriptives/obs_by_children_status_unmarried.dta"
	append using "../../bld/data/descriptives/share_by_children_status_unmarried.dta"

	keep if world_region==`region'
	drop world_region
	sort edu_lvl
	tostring edu_lvl, replace

	replace edu_lvl="Primary Education" if edu_lvl=="1"
	replace edu_lvl="Secondary Education" if edu_lvl=="2"
	replace edu_lvl="Tertiary Education" if edu_lvl=="3"
	replace edu_lvl="Age" if edu_lvl=="88"
	replace edu_lvl="Observations" if edu_lvl=="99"
	replace edu_lvl="Share" if edu_lvl=="111"

	texsave * using "../../bld/tables/table_children_unmarried_`region'.tex", frag replace
	
	import delimited using "../../bld/tables/table_children_unmarried_`region'.tex", delimiter(tab) clear
	gen keep = strpos(v1, "\tabularnewline") > 0
	replace keep = cond(keep == 1, keep, sum(keep))
	keep if keep == 1
	drop keep
	drop if _n == 1 | _n == 2
	replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
	if `region' == 2 {
		replace v1 = subinstr(v1, "\\", "", .) if _n == 6
	}
	* Table C.4: Selection into parenthood among unmarried couples
	export delimited "../../bld/tables/table_children_unmarried_`region'.tex", novarnames replace
}


clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
gen temp = 1 if hh_age_0_14_nonch_d == 1
replace temp = 2 if hh_age_0_14_d == 1 & hh_age_0_14_nonch_d == 0
replace temp = 3 if hh_age_0_14_d == 0
gen edu_primary = 1 if edu_lvl == 1
replace edu_primary = 0 if edu_primary == .
gcollapse (mean) edu_primary edu_secondary edu_tertiary [aweight=weight_pop], by(world_region couple_type temp)
rename edu_primary num1
rename edu_secondary num2
rename edu_tertiary num3
reshape long num, i(world_region temp couple_type) j(edu_lvl)
reshape wide num, i(world_region couple_type edu) j(temp)
reshape wide num1 num2 num3, i(world_region edu) j(couple_type)
foreach var in num11 num21 num31 num12 num22 num32 num13 num23 num33 {
	replace `var' = `var' * 100 
}
foreach var in num11 num21 num31 num12 num22 num32 num13 num23 num33 {
	gen `var'_s = string(`var',"%4.2f") 
}
drop num11 - num33
foreach var in num11_s num21_s num31_s num12_s num22_s num32_s num13_s num23_s num33_s {
	replace `var' = `var' + "%"
}
save "../../bld/data/descriptives/shares_nonchildren_all.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
} 
keep if urban==1
gen temp = 1 if hh_age_0_14_nonch_d == 1
replace temp = 2 if hh_age_0_14_d == 1 & hh_age_0_14_nonch_d == 0
replace temp = 3 if hh_age_0_14_d == 0
gcollapse (mean) age [aweight=weight_pop], by(world_region couple_type temp)
rename age num
reshape wide num, i(world_region couple_type) j(temp)
reshape wide num1 num2 num3, i(world_region) j(couple_type)
gen edu_lvl = 88
foreach var in num11 num21 num31 num12 num22 num32 num13 num23 num33 {
	gen `var'_s = string(`var',"%4.2f") 
}
drop num11 - num33
save "../../bld/data/descriptives/age_by_nonchildren_status_all.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
gen temp = 1 if hh_age_0_14_nonch_d == 1
replace temp = 2 if hh_age_0_14_d == 1 & hh_age_0_14_nonch_d == 0
replace temp = 3 if hh_age_0_14_d == 0
gen num = 1
gcollapse (count) num [aweight=weight_pop], by(world_region couple_type temp)
reshape wide num, i(world_region couple_type) j(temp)
reshape wide num1 num2 num3, i(world_region) j(couple_type)
gen edu_lvl = 99
foreach var in num11 num21 num31 num12 num22 num32 num13 num23 num33 {
	gen `var'_s = string(`var',"%9.0fc") 
}
drop num11 - num33
save "../../bld/data/descriptives/obs_by_nonchildren_status_all.dta", replace

clear
foreach r in $regions {
	cap append using "../../bld/data/data_individual_`r'.dta"
}
keep if urban==1
gen num1 = 1 if hh_age_0_14_nonch_d == 1
gen num2 = 1 if hh_age_0_14_d == 1 & hh_age_0_14_nonch_d == 0
gen num3 = 1 if hh_age_0_14_d == 0
replace num1 = 0 if num1 == .
replace num2 = 0 if num2 == .
replace num3 = 0 if num3 == .
gcollapse (mean) num1 num2 num3 [aweight=weight_pop], by(world_region couple_type)
reshape wide num1 num2 num3, i(world_region) j(couple_type)
gen edu_lvl = 111
foreach var in num11 num21 num31 num12 num22 num32 num13 num23 num33 {
	replace `var' = `var' * 100 
}
foreach var in num11 num21 num31 num12 num22 num32 num13 num23 num33 {
	gen `var'_s = string(`var',"%4.2f") 
}
drop num11 - num33
foreach var in num11_s num21_s num31_s num12_s num22_s num32_s num13_s num23_s num33_s {
	replace `var' = `var' + "%"
}
save "../../bld/data/descriptives/share_by_nonchildren_status_all.dta", replace

foreach region in 1 2 3 {
	use "../../bld/data/descriptives/shares_nonchildren_all.dta", clear
	append using "../../bld/data/descriptives/age_by_nonchildren_status_all.dta"
	append using "../../bld/data/descriptives/obs_by_nonchildren_status_all.dta"
	append using "../../bld/data/descriptives/share_by_nonchildren_status_all.dta"

	keep if world_region==`region'
	drop world_region
	sort edu_lvl
	tostring edu_lvl, replace

	replace edu_lvl="Primary Education" if edu_lvl=="1"
	replace edu_lvl="Secondary Education" if edu_lvl=="2"
	replace edu_lvl="Tertiary Education" if edu_lvl=="3"
	replace edu_lvl="Age" if edu_lvl=="88"
	replace edu_lvl="Observations" if edu_lvl=="99"
	replace edu_lvl="Share" if edu_lvl=="111"

	texsave * using "../../bld/tables/table_nonchildren_all_`region'.tex", frag replace
	
	import delimited using "../../bld/tables/table_nonchildren_all_`region'.tex", delimiter(tab) clear
	gen keep = strpos(v1, "\tabularnewline") > 0
	replace keep = cond(keep == 1, keep, sum(keep))
	keep if keep == 1
	drop keep
	drop if _n == 1 | _n == 2
	replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
	if `region' == 2 {
		replace v1 = subinstr(v1, "\\", "", .) if _n == 6
	}
	* Table A.12: Own children versus relatives' children
	export delimited "../../bld/tables/table_nonchildren_all_`region'.tex", novarnames replace
}




clear
foreach data in under_15_couple_type_eu_lfs under_15_couple_type_BRA under_15_couple_type_URY under_15_couple_type_USA {
	cap append using "../../bld/data/descriptives/under_15/`data'.dta"
} 

replace child = child * 100
replace other_relative = other_relative * 100
replace other_non_relative = other_non_relative * 100

gen child_s = string(child,"%4.2f")
replace child_s = child_s + "%"

gen other_relative_s = string(other_relative,"%4.2f")
replace other_relative_s = other_relative_s + "%"

gen other_non_relative_s = string(other_non_relative,"%4.2f")
replace other_non_relative_s = other_non_relative_s + "%"

drop child other_relative other_non_relative

reshape wide child_s other_relative_s other_non_relative_s, i(COUNTRY) j(couple_type)

replace COUNTRY="Belgium" if COUNTRY=="BEL"
replace COUNTRY="Brazil" if COUNTRY=="BRA"
replace COUNTRY="Germany" if COUNTRY=="DEU"
replace COUNTRY="France" if COUNTRY=="FRA"
replace COUNTRY="United Kingdom" if COUNTRY=="GBR"
replace COUNTRY="Netherlands" if COUNTRY=="NLD"
replace COUNTRY="United States" if COUNTRY=="USA"
replace COUNTRY="Uruguay" if COUNTRY=="URY"

texsave * using "../../bld/tables/table_under_15_couple_type.tex", frag replace
import delimited using "../../bld/tables/table_under_15_couple_type.tex", delimiter(tab) clear
gen keep = strpos(v1, "\tabularnewline") > 0
replace keep = cond(keep == 1, keep, sum(keep))
keep if keep == 1
drop keep
drop if _n == 1 | _n == 2
replace v1 = subinstr(v1, "\tabularnewline", "\\", .) 
replace v1 = subinstr(v1, "\\", "", .) if _n == 8
* Table A.11: Relationship of people under 15 to household head
export delimited "../../bld/tables/table_under_15_couple_type.tex", novarnames replace


use "../../bld/data/descriptives/BRA_ssc_old_young_shares.dta", clear
append using "../../bld/data/descriptives/URY_ssc_old_young_shares.dta"
append using  "../../bld/data/descriptives/USA_ssc_old_young_shares.dta"

graph bar couple_type20 couple_type21, over(COUNTRY, label(labsize($lab_size_main))) ///
ylabel(0 "0.0%" 0.002 "0.2%" 0.004 "0.4%" 0.006 "0.6%" 0.008 "0.8%" 0.01 "1.0%" 0.012 "1.2%", nogrid labsize($lab_size_main)) ///
legend(order(1 "20-64 years old" 2 "65 years old or more" ) cols(4) ring(1) position(6) size($lab_size_main)) ///
bar(1, color("$color_dark") lwidth(medium) fintensity(inten100)) bar(2, color(black) lwidth(medium) fintensity(inten100)) 
* Figure D.8: Same-sex-couple share by age group
graph export "../../bld/figures/bar_couples_share_prime_age_old_age.png", replace width(1058)


clear
foreach data in hh_head_all_couples_eu_lfs hh_head_all_couples_URY hh_head_all_couples_USA {
	cap append using "../../bld/data/descriptives/hh_head_all_couples/`data'.dta"
} 

graph bar relation, over(COUNTRY, sort(1) descending label(labsize($lab_size_main))) ytitle("") bar(1, color("$color_dark") lwidth(medium) fintensity(inten100)) ylabel(0 "0%" 0.2 "20%" 0.4 "40%" 0.6 "60%" 0.8 "80%" 1 "100%", format(%03.2f) nogrid labsize($lab_size_main)) plotregion(lstyle(none))
* Figure D.3: Household-head couples as a share of all couples
graph export "../../bld/figures/hh_head_all_couples.png", width(1058) replace

