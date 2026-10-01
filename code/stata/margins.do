* Figures 2-6: labor force, hours, secondary-worker share, and unemployment margins

clear

global control_vars i.year c.age##c.age i.edu_lvl i.region_id
global control_vars_nld i.year c.age##c.age i.edu_lvl
global control_vars_full i.year c.age##c.age i.edu_lvl i.region_id i.hh_age_0_14_d 
global control_vars_full_nld i.year c.age##c.age i.edu_lvl i.hh_age_0_14_d

global control_vars_hh i.year c.min_age##c.min_age c.max_age##c.max_age i.min_edu_lvl i.max_edu_lvl i.region_id
global control_vars_hh_nld i.year c.min_age##c.min_age c.max_age##c.max_age i.min_edu_lvl i.max_edu_lvl
global control_vars_hh_full i.year c.min_age##c.min_age c.max_age##c.max_age i.min_edu_lvl i.max_edu_lvl i.region_id i.hh_age_0_14_d
global control_vars_hh_full_nld i.year c.min_age##c.min_age c.max_age##c.max_age i.min_edu_lvl i.max_edu_lvl i.hh_age_0_14_d

global lab_size_main 4.5
global lab_size_legend 3.5

foreach c in BEL BRA DEU FRA GBR NLD URY USA {
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type  region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	reg labor_force i.couple_type [aweight=weight_pop], vce(cluster hh_id)
	margins couple_type, post	
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 m_3 v_1 v_2 v_3
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	replace v_3 = . in 1
	replace v_3 = . in 2
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	gen se_3 = sqrt(v_3)
	foreach var in m_1 m_2 m_3 v_1 v_2 v_3 se_1 se_2 se_3 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen lb_3 = m_3 - 1.96 * se_3
	gen ub_3 = m_3 + 1.96 * se_3
	gen model = 1
	save ../../bld/data/margins/ls_model1_`c', replace
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type  region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	if "`c'"!="NLD"{
		reg labor_force i.couple_type $control_vars_hh [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg labor_force i.couple_type $control_vars_hh_nld [aweight=weight_pop], vce(cluster hh_id)
	}
	margins couple_type, post
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 m_3 v_1 v_2 v_3
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	replace v_3 = . in 1
	replace v_3 = . in 2
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	gen se_3 = sqrt(v_3)
	foreach var in m_1 m_2 m_3 v_1 v_2 v_3 se_1 se_2 se_3 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen lb_3 = m_3 - 1.96 * se_3
	gen ub_3 = m_3 + 1.96 * se_3
	gen model = 2
	save ../../bld/data/margins/ls_model2_`c', replace
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type  region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	if "`c'"!="NLD"{
		reg labor_force i.couple_type $control_vars_hh_full [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg labor_force i.couple_type $control_vars_hh_full_nld [aweight=weight_pop], vce(cluster hh_id)
	}	
	margins couple_type, post
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 m_3 v_1 v_2 v_3
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	replace v_3 = . in 1
	replace v_3 = . in 2
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	gen se_3 = sqrt(v_3)
	foreach var in m_1 m_2 m_3 v_1 v_2 v_3 se_1 se_2 se_3 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen lb_3 = m_3 - 1.96 * se_3
	gen ub_3 = m_3 + 1.96 * se_3
	gen model = 3
	save ../../bld/data/margins/ls_model3_`c', replace
	
	use ../../bld/data/margins/ls_model1_`c', clear
	append using ../../bld/data/margins/ls_model2_`c'
	append using ../../bld/data/margins/ls_model3_`c'
	drop v_1 v_2 v_3
	reshape long m_ se_ lb_ ub_, i(model) j(couple_type)

	gen no_ = .
	replace no_ = model       if couple_type==2   
	replace no_ = model + 5   if couple_type==3   

	quietly su m_ if model==1 & couple_type==1, meanonly
	scalar ref_dsc   = r(mean)
	
	twoway ///
		(bar m_ no_ if !missing(no_), fcolor(gs12) lcolor(none)) ///
		(bar m_ no_ if inlist(no_,1,6), color("0 129 152")) ///
		(bar m_ no_ if inlist(no_,2,7), color("51 224 255")) ///
		(bar m_ no_ if inlist(no_,3,8), color("128 236 255")) ///
		(rcap lb_ ub_ no_, lcolor(black)) ///
		(function y = ref_dsc,   range(0.5 8.5) lpattern(shortdash) lcolor("128 0 0")) ///
		, ///
		xlabel(none) ///
		text(1.0 2 "Men", size($lab_size_main)) text(1.0 7 "Women", size($lab_size_main)) ///
		xsize(16) ysize(14) ylabel(0 "0" 0.25 "25%" 0.5 "50%" 0.75 "75%" 1 "100%", nogrid labsize($lab_size_main)) ///
		legend(order(2 "Unconditional" 3 "+ Basic Controls" 4 "+ Children") ///
		 cols(3) ring(1) position(6) size($lab_size_legend)) ///
		name(margins_ls_`c', replace)
	* Figure 2: Labor force participation, both partners active (eight country panels)
	graph export "../../bld/figures/margins_ls_`c'.pdf", replace
}

foreach c in BEL BRA DEU FRA GBR NLD URY USA {
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type  region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	reg hours_worked i.couple_type [aweight=weight_pop], vce(cluster hh_id)
	margins couple_type, post	
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 m_3 v_1 v_2 v_3
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	replace v_3 = . in 1
	replace v_3 = . in 2
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	gen se_3 = sqrt(v_3)
	foreach var in m_1 m_2 m_3 v_1 v_2 v_3 se_1 se_2 se_3 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen lb_3 = m_3 - 1.96 * se_3
	gen ub_3 = m_3 + 1.96 * se_3
	gen model = 1
	save ../../bld/data/margins/hw_model1_`c', replace
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type  region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	if "`c'"!="NLD"{
		reg hours_worked i.couple_type $control_vars_hh [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg hours_worked i.couple_type $control_vars_hh_nld [aweight=weight_pop], vce(cluster hh_id)
	}
	margins couple_type, post
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 m_3 v_1 v_2 v_3
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	replace v_3 = . in 1
	replace v_3 = . in 2
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	gen se_3 = sqrt(v_3)
	foreach var in m_1 m_2 m_3 v_1 v_2 v_3 se_1 se_2 se_3 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen lb_3 = m_3 - 1.96 * se_3
	gen ub_3 = m_3 + 1.96 * se_3
	gen model = 2
	save ../../bld/data/margins/hw_model2_`c', replace
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type  region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	if "`c'"!="NLD"{
		reg hours_worked i.couple_type $control_vars_hh_full [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg hours_worked i.couple_type $control_vars_hh_full_nld [aweight=weight_pop], vce(cluster hh_id)
	}	
	margins couple_type, post
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 m_3 v_1 v_2 v_3
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	replace v_3 = . in 1
	replace v_3 = . in 2
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	gen se_3 = sqrt(v_3)
	foreach var in m_1 m_2 m_3 v_1 v_2 v_3 se_1 se_2 se_3 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen lb_3 = m_3 - 1.96 * se_3
	gen ub_3 = m_3 + 1.96 * se_3
	gen model = 3
	save ../../bld/data/margins/hw_model3_`c', replace
	
	use ../../bld/data/margins/hw_model1_`c', clear
	append using ../../bld/data/margins/hw_model2_`c'
	append using ../../bld/data/margins/hw_model3_`c'
	drop v_1 v_2 v_3
	reshape long m_ se_ lb_ ub_, i(model) j(couple_type)

	gen no_ = .
	replace no_ = model       if couple_type==2   
	replace no_ = model + 5   if couple_type==3   

	quietly su m_ if model==1 & couple_type==1, meanonly
	scalar ref_dsc   = r(mean)
		
	twoway ///
		(bar m_ no_ if !missing(no_), fcolor(gs12) lcolor(none)) ///
		(bar m_ no_ if inlist(no_,1,6), color("0 129 152")) ///
		(bar m_ no_ if inlist(no_,2,7), color("51 224 255")) ///
		(bar m_ no_ if inlist(no_,3,8), color("128 236 255")) ///
		(rcap lb_ ub_ no_, lcolor(black)) ///
		(function y = ref_dsc,   range(0.5 8.5) lpattern(shortdash) lcolor("128 0 0")) ///
		, ///
		xlabel(none) ///
		text(80 2 "Men", size($lab_size_main)) text(80 7 "Women", size($lab_size_main)) ///
		xsize(16) ysize(14) ylabel(0(20)80, nogrid labsize($lab_size_main)) ///
		legend(order(2 "Unconditional" 3 "+ Basic Controls" 4 "+ Children") ///
		 cols(3) ring(1) position(6) size($lab_size_legend)) ///
		name(margins_hw_`c', replace)

	* Figure 3: Total hours worked (eight country panels)
	graph export "../../bld/figures/margins_hw_`c'.pdf", replace
}

foreach c in BEL BRA DEU FRA GBR NLD URY USA {
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta if sex==1, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta if sex==1, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	reg unemp i.couple_type [aweight=weight_pop], vce(cluster hh_id)
	margins couple_type, post	
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 v_1 v_2
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	foreach var in m_1 m_2 v_1 v_2 se_1 se_2 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen model = 1
	gen sex = 1
	save ../../bld/data/margins/unemp_model1_men_`c', replace
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta if sex==2, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta if sex==2, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	reg unemp i.couple_type [aweight=weight_pop], vce(cluster hh_id)
	margins couple_type, post	
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 v_1 v_2
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	foreach var in m_1 m_2 v_1 v_2 se_1 se_2 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen model = 1
	gen sex = 2
	save ../../bld/data/margins/unemp_model1_women_`c', replace	
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta if sex==1, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta if sex==1, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	if "`c'"!="NLD"{
		reg unemp i.couple_type $control_vars [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg unemp i.couple_type $control_vars_nld [aweight=weight_pop], vce(cluster hh_id)
	}
	margins couple_type, post	
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 v_1 v_2
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	foreach var in m_1 m_2 v_1 v_2 se_1 se_2 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen model = 2
	gen sex = 1
	save ../../bld/data/margins/unemp_model2_men_`c', replace
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta if sex==2, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta if sex==2, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	if "`c'"!="NLD"{
		reg unemp i.couple_type $control_vars [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg unemp i.couple_type $control_vars_nld [aweight=weight_pop], vce(cluster hh_id)
	}
	margins couple_type, post	
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 v_1 v_2
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	foreach var in m_1 m_2 v_1 v_2 se_1 se_2 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen model = 2
	gen sex = 2
	save ../../bld/data/margins/unemp_model2_women_`c', replace
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta if sex==1, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta if sex==1, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	if "`c'"!="NLD"{
		reg unemp i.couple_type $control_vars_full [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg unemp i.couple_type $control_vars_full_nld [aweight=weight_pop], vce(cluster hh_id)
	}
	margins couple_type, post	
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 v_1 v_2
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	foreach var in m_1 m_2 v_1 v_2 se_1 se_2 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen model = 3
	gen sex = 1
	save ../../bld/data/margins/unemp_model3_men_`c', replace
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta if sex==2, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta if sex==2, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	if "`c'"!="NLD"{
		reg unemp i.couple_type $control_vars_full [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg unemp i.couple_type $control_vars_full_nld [aweight=weight_pop], vce(cluster hh_id)
	}
	margins couple_type, post	
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 v_1 v_2
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	foreach var in m_1 m_2 v_1 v_2 se_1 se_2 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen model = 3
	gen sex = 2
	save ../../bld/data/margins/unemp_model3_women_`c', replace
	
	use ../../bld/data/margins/unemp_model1_men_`c', clear
	append using ../../bld/data/margins/unemp_model1_women_`c'
	append using ../../bld/data/margins/unemp_model2_men_`c'
	append using ../../bld/data/margins/unemp_model2_women_`c'
	append using ../../bld/data/margins/unemp_model3_men_`c'
	append using ../../bld/data/margins/unemp_model3_women_`c'

	drop v_1 v_2
	reshape long m_ se_ lb_ ub_, i(model sex) j(couple_type)
	
	gen no_ = .
	replace no_ = model       if sex==1 & couple_type==2   
	replace no_ = model + 3   if sex==2 & couple_type==2   

	quietly su m_ if model==1 & couple_type==1 & sex==1, meanonly
	scalar ref_men   = r(mean)
	quietly su m_ if model==1 & couple_type==1 & sex==2, meanonly
	scalar ref_women = r(mean)
	
	foreach sx_l in 1 2{
	preserve
	keep if sex==`sx_l'
	drop  no_
	gen no_=.
	replace no_=model   if couple_type==2
	quietly su m_ if model==1 & couple_type==1 & sex==`sx_l', meanonly
	scalar ref_dsc   = r(mean)
		twoway ///
		(bar m_ no_ if !missing(no_), fcolor(gs12) lcolor(none)) ///
		(bar m_ no_ if inlist(no_,1), color("0 129 152")) ///
		(bar m_ no_ if inlist(no_,2), color("51 224 255")) ///
		(bar m_ no_ if inlist(no_,3), color("128 236 255")) ///
		(rcap lb_ ub_ no_, lcolor(black)) ///
		(function y = ref_dsc,   range(0.5 3.5) lpattern(shortdash) lcolor("128 0 0")) ///
		, ///
		xlabel(none) ///
		xsize(16) ysize(14) ylabel(0 "0" 0.02 "2%" 0.04 "4%" 0.06 "6%" 0.08 "8%", nogrid labsize($lab_size_main)) ///
		ytitle("") xtitle(" ") ///
		legend(order(2 "Unconditional" 3 "+ Basic Controls" 4 "+ Children") ///
		 cols(3) ring(1) position(6) size($lab_size_legend)) ///
		name(margins_unemp_s`sx_l'_`c', replace)
	* Figures 5 and 6: Unemployment for men and women (eight country panels each)
	graph export "../../bld/figures/margins_unemp_s`sx_l'_`c'.pdf", replace
	
	restore
	}
}

foreach c in BEL BRA DEU FRA GBR NLD URY USA {
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type  region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	gen hw_share=min_hours_worked/hours_worked
	reg hw_share i.couple_type [aweight=weight_pop], vce(cluster hh_id)
	margins couple_type, post	
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 m_3 v_1 v_2 v_3
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	replace v_3 = . in 1
	replace v_3 = . in 2
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	gen se_3 = sqrt(v_3)
	foreach var in m_1 m_2 m_3 v_1 v_2 v_3 se_1 se_2 se_3 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen lb_3 = m_3 - 1.96 * se_3
	gen ub_3 = m_3 + 1.96 * se_3
	gen model = 1
	save ../../bld/data/margins/hw_secondary_model1_`c', replace
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type  region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	gen hw_share=min_hours_worked/hours_worked
	if "`c'"!="NLD"{
		reg hw_share i.couple_type $control_vars_hh [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg hw_share i.couple_type $control_vars_hh_nld [aweight=weight_pop], vce(cluster hh_id)
	}
	margins couple_type, post
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 m_3 v_1 v_2 v_3
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	replace v_3 = . in 1
	replace v_3 = . in 2
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	gen se_3 = sqrt(v_3)
	foreach var in m_1 m_2 m_3 v_1 v_2 v_3 se_1 se_2 se_3 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen lb_3 = m_3 - 1.96 * se_3
	gen ub_3 = m_3 + 1.96 * se_3
	gen model = 2
	save ../../bld/data/margins/hw_secondary_model2_`c', replace
	
	if "`c'"!="USA"{
		use ../../bld/data/data_countries/data_individual_`c'.dta, clear
	}	
	if "`c'"=="USA"{
		use ../../bld/data/data_individual_`c'.dta, clear
	}
	encode region, gen(region_id)
	keep if urban==1
	replace hours_worked=0 if hours_worked==.
	gcollapse (min) labor_force couple_type  region_id hh_age_0_14 hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
	gen hw_share=min_hours_worked/hours_worked
	if "`c'"!="NLD"{
		reg hw_share i.couple_type $control_vars_hh_full [aweight=weight_pop], vce(cluster hh_id)
	}
	if "`c'"=="NLD"{
		reg hw_share i.couple_type $control_vars_hh_full_nld [aweight=weight_pop], vce(cluster hh_id)
	}	
	margins couple_type, post
	matrix m = r(b)
	svmat m, names(m_)
	matrix v = r(V)
	svmat v, names(v_)
	keep m_1 m_2 m_3 v_1 v_2 v_3
	duplicates drop
	replace v_1 = . in 2
	replace v_1 = . in 3
	replace v_2 = . in 1
	replace v_2 = . in 3
	replace v_3 = . in 1
	replace v_3 = . in 2
	gen se_1 = sqrt(v_1)
	gen se_2 = sqrt(v_2)
	gen se_3 = sqrt(v_3)
	foreach var in m_1 m_2 m_3 v_1 v_2 v_3 se_1 se_2 se_3 {
		replace `var' = `var'[_n-1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
		replace `var' = `var'[_n+1] if missing(`var')
	}
	duplicates drop
	gen lb_1 = m_1 - 1.96 * se_1
	gen ub_1 = m_1 + 1.96 * se_1
	gen lb_2 = m_2 - 1.96 * se_2
	gen ub_2 = m_2 + 1.96 * se_2
	gen lb_3 = m_3 - 1.96 * se_3
	gen ub_3 = m_3 + 1.96 * se_3
	gen model = 3
	save ../../bld/data/margins/hw_secondary_model3_`c', replace
	
	use ../../bld/data/margins/hw_secondary_model1_`c', clear
	append using ../../bld/data/margins/hw_secondary_model2_`c'
	append using ../../bld/data/margins/hw_secondary_model3_`c'
	drop v_1 v_2 v_3
	reshape long m_ se_ lb_ ub_, i(model) j(couple_type)

	gen no_ = .
	replace no_ = model       if couple_type==2   
	replace no_ = model + 5   if couple_type==3   

	quietly su m_ if model==1 & couple_type==1, meanonly
	scalar ref_dsc   = r(mean)
		
	twoway ///
		(bar m_ no_ if !missing(no_), fcolor(gs12) lcolor(none)) ///
		(bar m_ no_ if inlist(no_,1,6), color("0 129 152")) ///
		(bar m_ no_ if inlist(no_,2,7), color("51 224 255")) ///
		(bar m_ no_ if inlist(no_,3,8), color("128 236 255")) ///
		(rcap lb_ ub_ no_, lcolor(black)) ///
		(function y = ref_dsc,   range(0.5 8.5) lpattern(shortdash) lcolor("128 0 0")) ///
		, ///
		xlabel(none) ///
		text(0.4 2 "Men", size($lab_size_main)) text(0.4 7 "Women", size($lab_size_main)) ///
		xsize(16) ysize(14) ylabel(0 "0" 0.1 "10%" 0.2 "20%" 0.3 "30%" 0.4 "40%", nogrid labsize($lab_size_main)) ///
		legend(order(2 "Unconditional" 3 "+ Basic Controls" 4 "+ Children") ///
		 cols(3) ring(1) position(6) size($lab_size_legend)) ///
		name(margins_hw_secondary_`c', replace)

	* Figure 4: Hours worked by the secondary worker (eight country panels)
	graph export "../../bld/figures/margins_hw_secondary_`c'.pdf", replace

}
