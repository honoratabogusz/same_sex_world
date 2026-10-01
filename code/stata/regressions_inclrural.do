* Table B.5: robustness including rural areas






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
replace hours_worked=0 if hours_worked==.



preserve 

replace hours_worked=0 if hours_worked==.



gcollapse (min) labor_force couple_type region_id hh_age_0_14_d min_age=age min_edu_lvl=edu_lvl (max) max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
label val couple_type ssh_lab




levelsof country_id if inlist(country_id, "BEL", "BRA", "FRA", "DEU", "NLD", "GBR", "USA", "URY"), local(countries)

foreach country of local countries {
	
	
	
    
    eststo est_rob_bas_c`country'1: reg labor_force i.couple_type $control_vars_hh_full if country_id=="`country'" [aweight=weight_pop], vce(cluster hh_id)
    
    su labor_force if country_id=="`country'" [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3)
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_bas_c = `mean_outcome'
    estadd scalar Nssh_rob_bas_c = `n_ssh'

    eststo est_rob_bas_c`country'2: reg hours_worked i.couple_type $control_vars_hh_full if country_id=="`country'" [aweight=weight_pop], vce(cluster hh_id)
    
    su hours_worked if country_id=="`country'" [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3)
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_bas_c = `mean_outcome'
    estadd scalar Nssh_rob_bas_c = `n_ssh'


	
}


restore


levelsof country_id if inlist(country_id, "BEL", "BRA", "FRA", "DEU", "NLD", "GBR", "USA", "URY"), local(countries)

foreach country of local countries {
	
    preserve
	keep if country_id=="`country'"
    eststo est_rob_bas_c`country'3: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==1, vce(cluster hh_id)
    
    su unemp if sex==1 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_bas_c = `mean_outcome'
    estadd scalar Nssh_rob_bas_c = `n_ssh'

    eststo est_rob_bas_c`country'4: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==2 , vce(cluster hh_id)
    
    su unemp if sex==2 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if  (couple_type==2 | couple_type==3) & sex==2
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_bas_c = `mean_outcome'
    estadd scalar Nssh_rob_bas_c = `n_ssh'
	restore

}

	
}





	
* Table B.5: Robustness including rural areas (fragments 1 and 2)
esttab est_rob_bas_cBEL* est_rob_bas_cBRA* est_rob_bas_cFRA* est_rob_bas_cDEU* using "../../bld/tables/rob_rural_countries1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_bas_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

esttab est_rob_bas_cNLD* est_rob_bas_cGBR* est_rob_bas_cUSA* est_rob_bas_cURY* using "../../bld/tables/rob_rural_countries2.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_bas_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc ))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses
	

