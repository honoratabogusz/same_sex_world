* Table 3 inputs: descriptive statistics by couple type and country
*
* Creates, for every country in each regional analysis dataset,
*   ../../bld/data/descriptives/desc_stats_individual_<country>_men.dta
*   ../../bld/data/descriptives/desc_stats_individual_<country>_women.dta
*   ../../bld/data/descriptives/desc_stats_individual_<country>_nobs.dta
*   ../../bld/data/descriptives/desc_stats_hh_<country>.dta
* which code/python/descriptive_tables.py turns into the Table 3 TeX fragments.
*
* The code is taken from the "Individual-level descriptives" and
* "Household-level descriptives" blocks of the authors' original
* regressions_coefplots.do. In that file these blocks sat between the
* regressions, which did not change the data, so they are reproduced here
* without the regressions. The sample is the same: urban couples from the
* regional analysis datasets, with the household-level data built by the same
* collapse as in the household regressions.


* descriptive_tables.py looks up rows by these couple-type labels, so every
* saved file must carry them. gcollapse can discard label definitions, so
* they are (re)defined and attached right before each save, and checked.
capture program drop label_couple_type
program define label_couple_type
	label def ssh_lab 1 "Different-sex couple" 2 "Same-sex couple: men" 3 "Same-sex couple: women", replace
	label val couple_type ssh_lab
	assert `"`: label (couple_type) 1'"' == "Different-sex couple"
end

foreach rg in developing Europe USA {

	use "../../bld/data/data_individual_`rg'.dta", clear
	keep if urban==1
	encode region, gen(region_id)
	label_couple_type

	levelsof country_id, local(levels_countries_x)

	** Individual-level descriptives

	foreach c of local levels_countries_x {
		di "`c'"
		preserve
		keep if country_id=="`c'"
		keep if sex==1
		gcollapse unemp labor_force age edu_secondary edu_tertiary [aweight=weight_pop], by(couple_type)
		label_couple_type
		save "../../bld/data/descriptives/desc_stats_individual_`c'_men.dta", replace
		restore

		preserve
		keep if country_id=="`c'"
		keep if sex==2
		gcollapse unemp labor_force age edu_secondary edu_tertiary [aweight=weight_pop], by(couple_type)
		label_couple_type
		save "../../bld/data/descriptives/desc_stats_individual_`c'_women.dta", replace
		restore

		preserve
		keep if country_id=="`c'"
		gen count=1
		gcollapse (sum) count weight_pop, by(couple_type)
		label_couple_type
		save "../../bld/data/descriptives/desc_stats_individual_`c'_nobs.dta", replace
		restore
	}

	** Household-level data (as for the household regressions)

	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	* Store couple_type as an integer with its value labels, which
	* descriptive_tables.py uses as row names
	replace couple_type = round(couple_type)
	recast byte couple_type, force
	label_couple_type
	gen hw_share= min_hours_worked/hours_worked

	gen edu_3_3=0
	replace edu_3_3=1 if min_edu_lvl==3 & max_edu_lvl==3
	gen edu_3_2=0
	replace edu_3_2=1 if min_edu_lvl==2 & max_edu_lvl==3
	gen edu_3_1=0
	replace edu_3_1=1 if min_edu_lvl==1 & max_edu_lvl==3
	gen edu_2_2=0
	replace edu_2_2=1 if min_edu_lvl==2 & max_edu_lvl==2
	gen edu_2_1=0
	replace edu_2_1=1 if min_edu_lvl==1 & max_edu_lvl==2
	gen edu_1_1=0
	replace edu_1_1=1 if min_edu_lvl==1 & max_edu_lvl==1

	foreach x in 1 2 3 {
		gen max_edu_`x'=0
		replace max_edu_`x'=1 if max_edu_lvl==`x'
		gen min_edu_`x'=0
		replace min_edu_`x'=1 if min_edu_lvl==`x'
	}

	** Household-level descriptives

	foreach c of local levels_countries_x {
		di "`c'"
		preserve
		keep if country_id=="`c'"
		gcollapse labor_force hours_worked hw_share min_age max_age edu_3_3 edu_3_2 edu_3_1 edu_2_2 edu_2_1 edu_1_1 max_edu_3 max_edu_2 max_edu_1 min_edu_3 min_edu_2 min_edu_1 hh_age_0_14_d [aweight=weight_pop], by(couple_type)
		label_couple_type
		save "../../bld/data/descriptives/desc_stats_hh_`c'.dta", replace
		restore
	}
}
