* Tables: individual and household outcome regressions and gender gaps






global control_vars_full i.year c.age##c.age i.edu_lvl i.region_id i.hh_age_0_14_d

global control_vars_hh_full i.year  c.min_age##c.min_age c.max_age##c.max_age i.min_edu_lvl i.max_edu_lvl i.region_id i.hh_age_0_14_d



estimates drop _all


foreach rg in developing Europe USA{
	use "../../bld/data/data_individual_`rg'.dta", clear

encode region, gen(region_id)
label def ssh_lab 1 "Different-sex couple" 2 "Same-sex couple: men" 3 "Same-sex couple: women"
label def gender_lab 1 "Gender: man" 2 "Gender: woman"
label val couple_type ssh_lab
label val sex gender_lab
keep if urban==1
replace hours_worked=0 if hours_worked==.



* Tables A.9 and A.10: self-employment by gender and country
levelsof country_id if inlist(country_id, "BEL", "BRA", "FRA", "DEU", "NLD", "GBR", "USA", "URY"), local(countries)

foreach country of local countries {
    
    eststo est_selfemp_men_c`country': reg selfemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==1 & country_id=="`country'", vce(cluster hh_id)
    
    su selfemp [weight=weight_pop] if sex==1 & country_id=="`country'"
    local mean_outcome=r(mean)
    
    su selfemp [weight=weight_pop] if sex==1 & couple_type==2 & country_id=="`country'"
    local n_ssh=r(N)
    
    estadd scalar ymean_self_men_cntry = `mean_outcome'
    estadd scalar Nssh_self_men_cntry = `n_ssh'
    
    eststo est_selfemp_women_c`country': reg selfemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==2 & country_id=="`country'", vce(cluster hh_id)
    
    su selfemp [weight=weight_pop] if sex==2 & country_id=="`country'"
    local mean_outcome=r(mean)
    
    su selfemp [weight=weight_pop] if sex==2 & couple_type==3 & country_id=="`country'"
    local n_ssh=r(N)
    
    estadd scalar ymean_self_women_cntry = `mean_outcome'
    estadd scalar Nssh_self_women_cntry = `n_ssh'
}

* Tables A.4 and A.5: individual labor-force participation by gender and country
levelsof country_id if inlist(country_id, "BEL", "BRA", "FRA", "DEU", "NLD", "GBR", "USA", "URY"), local(countries)

foreach country of local countries {
    
    eststo est_lf_ind_m_c`country': reg labor_force i.couple_type $control_vars_full [aweight=weight_pop] if sex==1 & country_id=="`country'", vce(cluster hh_id)
    
    su labor_force [weight=weight_pop] if sex==1 & country_id=="`country'"
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if sex==1 & couple_type==2 & country_id=="`country'"
    local n_ssh=r(N)
    
    estadd scalar ymean_lf_ind_m_c = `mean_outcome'
    estadd scalar Nssh_lf_ind_m_c = `n_ssh'
    
    eststo est_lf_ind_w_c`country': reg labor_force i.couple_type $control_vars_full [aweight=weight_pop] if sex==2 & country_id=="`country'", vce(cluster hh_id)
    
    su labor_force [weight=weight_pop] if sex==2 & country_id=="`country'"
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if sex==2 & couple_type==3 & country_id=="`country'"
    local n_ssh=r(N)
    
    estadd scalar ymean_lf_ind_w_c = `mean_outcome'
    estadd scalar Nssh_lf_ind_w_c = `n_ssh'
}


* Tables A.6 and A.7: individual hours worked by gender and country
foreach country of local countries {
    
    eststo est_hw_ind_m_c`country': reg hours_worked i.couple_type $control_vars_full [aweight=weight_pop] if sex==1 & country_id=="`country'", vce(cluster hh_id)
    
    su hours_worked [weight=weight_pop] if sex==1 & country_id=="`country'"
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if sex==1 & couple_type==2 & country_id=="`country'"
    local n_ssh=r(N)
    
    estadd scalar ymean_hw_ind_m_c = `mean_outcome'
    estadd scalar Nssh_hw_ind_m_c = `n_ssh'
    
    eststo est_hw_ind_w_c`country': reg hours_worked i.couple_type $control_vars_full [aweight=weight_pop] if sex==2 & country_id=="`country'", vce(cluster hh_id)
    
    su hours_worked [weight=weight_pop] if sex==2 & country_id=="`country'"
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if sex==2 & couple_type==3 & country_id=="`country'"
    local n_ssh=r(N)
    
    estadd scalar ymean_hw_ind_w_c = `mean_outcome'
    estadd scalar Nssh_hw_ind_w_c = `n_ssh'
}


* Table A.8: gender gaps in labor supply by country and couple type
levelsof country_id if inlist(country_id, "BEL", "BRA", "FRA", "DEU", "NLD", "GBR", "USA", "URY"), local(countries)

foreach country of local countries {
	
	preserve
	keep if (couple_type==2 | couple_type==3) & country_id=="`country'"
	replace hours_worked=0 if hours_worked==.
	

	
	eststo est_ggaps_c`country'1: reg labor_force i.sex $control_vars_full [aweight=weight_pop], vce(cluster hh_id)

	su labor_force [weight=weight_pop]
local mean_outcome=r(mean)
    estadd scalar ymean_ggaps_c = `mean_outcome'
	
    eststo est_ggaps_c`country'2: reg hours_worked i.sex $control_vars_full [aweight=weight_pop], vce(cluster hh_id)
	su hours_worked [weight=weight_pop]
local mean_outcome=r(mean)
estadd scalar ymean_ggaps_c = `mean_outcome'
    restore
	
		preserve
	keep if (couple_type==1) & country_id=="`country'"
	replace hours_worked=0 if hours_worked==.
	

	
	eststo est_ggaps_c`country'3: reg labor_force i.sex $control_vars_full [aweight=weight_pop], vce(cluster hh_id)

	su labor_force [weight=weight_pop]
local mean_outcome=r(mean)
    estadd scalar ymean_ggaps_c = `mean_outcome'
	
    eststo est_ggaps_c`country'4: reg hours_worked i.sex $control_vars_full [aweight=weight_pop], vce(cluster hh_id)
	su hours_worked [weight=weight_pop]
local mean_outcome=r(mean)
estadd scalar ymean_ggaps_c = `mean_outcome'
    restore
	
	
}



preserve 

replace hours_worked=0 if hours_worked==.



gcollapse (min) couple_type region_id hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl min_hours_worked=hours_worked (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
label val couple_type ssh_lab


* Table A.3: secondary worker's share of household hours
gen hw_share=min_hours_worked/hours_worked

levelsof country_id if inlist(country_id, "BEL", "BRA", "FRA", "DEU", "NLD", "GBR", "USA", "URY"), local(countries)

foreach country of local countries {
    
    eststo est_hw_share_c`country': reg hw_share i.couple_type $control_vars_hh_full if country_id=="`country'" [aweight=weight_pop], vce(cluster hh_id)
    
    su hw_share if country_id=="`country'" [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su hw_share [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3)
    local n_ssh=r(N)
    
    estadd scalar ymean_hw_share_c = `mean_outcome'
    estadd scalar Nssh_hw_share_c = `n_ssh'
}



restore

	
}





label val couple_type ssh_lab


	
* Table A.9: Self-employment, men
esttab est_selfemp_men_cBEL est_selfemp_men_cBRA est_selfemp_men_cFRA est_selfemp_men_cDEU est_selfemp_men_cNLD est_selfemp_men_cGBR est_selfemp_men_cUSA  est_selfemp_men_cURY using "../../bld/tables/table_selfemp_men_countries.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_self_men_cntry Nssh_self_men_cntry N, labels( "Adj. R-Squared" "Mean of outcome" "Observations (same-sex couples)" "Observations") fmt( 2 2 %9.0fc %9.0fc))  ///
	keep(2.couple_type) ///
	order(2.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

* Table A.10: Self-employment, women
esttab est_selfemp_women_cBEL est_selfemp_women_cBRA est_selfemp_women_cFRA est_selfemp_women_cDEU est_selfemp_women_cNLD est_selfemp_women_cGBR est_selfemp_women_cUSA  est_selfemp_women_cURY using "../../bld/tables/table_selfemp_women_countries.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_self_women_cntry Nssh_self_women_cntry N, labels( "Adj. R-Squared" "Mean of outcome" "Observations (same-sex couples)" "Observations") fmt( 2 2 %9.0fc %9.0fc))  ///
	keep(3.couple_type) ///
	order(3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses
	
	
* Table A.3: Secondary worker's share of household hours
esttab est_hw_share_cBEL est_hw_share_cBRA est_hw_share_cFRA est_hw_share_cDEU est_hw_share_cNLD est_hw_share_cGBR est_hw_share_cUSA est_hw_share_cURY using "../../bld/tables/table_hw_share_countries.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_hw_share_c Nssh_hw_share_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations (same-sex couples)" "Observations") fmt( 2 2 %9.0fc %9.0fc))  ///
	keep(3.couple_type 2.couple_type) ///
	order(3.couple_type 2.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses	
	
	
	
* Table A.4: Individual labor-force participation, men
esttab est_lf_ind_m_cBEL est_lf_ind_m_cBRA est_lf_ind_m_cFRA est_lf_ind_m_cDEU est_lf_ind_m_cNLD est_lf_ind_m_cGBR est_lf_ind_m_cUSA est_lf_ind_m_cURY using "../../bld/tables/table_lf_ind_men_countries.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_lf_ind_m_c Nssh_lf_ind_m_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations (same-sex couples)" "Observations") fmt( 2 2 %9.0fc %9.0fc))  ///
	keep(2.couple_type) ///
	order(2.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses	
	
* Table A.5: Individual labor-force participation, women
esttab est_lf_ind_w_cBEL est_lf_ind_w_cBRA est_lf_ind_w_cFRA est_lf_ind_w_cDEU est_lf_ind_w_cNLD est_lf_ind_w_cGBR est_lf_ind_w_cUSA est_lf_ind_w_cURY using "../../bld/tables/table_lf_ind_women_countries.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_lf_ind_w_c Nssh_lf_ind_w_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations (same-sex couples)" "Observations") fmt( 2 2 %9.0fc %9.0fc))  ///
	keep(3.couple_type) ///
	order(3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses	

* Table A.6: Individual hours worked, men
esttab est_hw_ind_m_cBEL est_hw_ind_m_cBRA est_hw_ind_m_cFRA est_hw_ind_m_cDEU est_hw_ind_m_cNLD est_hw_ind_m_cGBR est_hw_ind_m_cUSA est_hw_ind_m_cURY using "../../bld/tables/table_hw_ind_men_countries.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_hw_ind_m_c Nssh_hw_ind_m_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations (same-sex couples)" "Observations") fmt( 2 2 %9.0fc %9.0fc))  ///
	keep(2.couple_type) ///
	order(2.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses	
	
* Table A.7: Individual hours worked, women
esttab est_hw_ind_w_cBEL est_hw_ind_w_cBRA est_hw_ind_w_cFRA est_hw_ind_w_cDEU est_hw_ind_w_cNLD est_hw_ind_w_cGBR est_hw_ind_w_cUSA est_hw_ind_w_cURY using "../../bld/tables/table_hw_ind_women_countries.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_hw_ind_w_c Nssh_hw_ind_w_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations (same-sex couples)" "Observations") fmt( 2 2 %9.0fc %9.0fc))  ///
	keep(3.couple_type) ///
	order(3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses
	
	
* Table A.8: Gender gaps in labor supply (fragments 1 and 2)
esttab est_ggaps_cBEL* est_ggaps_cBRA* est_ggaps_cFRA* est_ggaps_cDEU* using "../../bld/tables/ggaps_countries_1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_ggaps_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc ))  ///
	keep(2.sex) ///
	order(2.sex)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

esttab est_ggaps_cNLD* est_ggaps_cGBR* est_ggaps_cUSA* est_ggaps_cURY* using "../../bld/tables/ggaps_countries_2.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_ggaps_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.sex) ///
	order(2.sex)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses
	


