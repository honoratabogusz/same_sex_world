* Tables A.2, B.1-B.4, and B.6-B.8: baseline and robustness specifications






global control_vars_full i.year c.age##c.age i.edu_lvl i.region_id i.hh_age_0_14_d

global control_vars_hh_full i.year  c.min_age##c.min_age c.max_age##c.max_age i.min_edu_lvl i.max_edu_lvl i.region_id i.hh_age_0_14_d



estimates drop _all


foreach rg in developing Europe USA{
	use "../../bld/data/data_individual_`rg'.dta", clear

if "`rg'" == "Europe" {
	gen race_white=.
}

encode region, gen(region_id)
label def ssh_lab 1 "Different-sex couple" 2 "Same-sex couple: men" 3 "Same-sex couple: women"
label def gender_lab 1 "Gender: man" 2 "Gender: woman"
label val couple_type ssh_lab
label val sex gender_lab
keep if urban==1
replace hours_worked=0 if hours_worked==.



preserve 

replace hours_worked=0 if hours_worked==.



gcollapse (min) labor_force couple_type region_id hh_age_0_14_d race_white min_age=age min_edu_lvl=edu_lvl (max) married_couple foreign_bp max_age=age max_edu_lvl=edu_lvl (sum) hours_worked weight_pop, by(hh_id year country_id)
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


    
    eststo est_rob_age_c`country'1: reg labor_force i.couple_type $control_vars_hh_full if country_id=="`country'" & min_age>=25 & max_age<=39 [aweight=weight_pop], vce(cluster hh_id)
    
    su labor_force if country_id=="`country'" & min_age>=25 & max_age<=39 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3) & min_age>=25 & max_age<=39
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_age_c = `mean_outcome'
    estadd scalar Nssh_rob_age_c = `n_ssh'

    eststo est_rob_age_c`country'2: reg hours_worked i.couple_type $control_vars_hh_full if country_id=="`country'" & min_age>=25 & max_age<=39 [aweight=weight_pop], vce(cluster hh_id)
    
    su hours_worked if country_id=="`country'" & min_age>=25 & max_age<=39 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3) & min_age>=25 & max_age<=39
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_age_c = `mean_outcome'
    estadd scalar Nssh_rob_age_c = `n_ssh'
	
    if "`country'" != "BRA" {
    eststo est_rob_mar_c`country'1: reg labor_force i.couple_type $control_vars_hh_full if country_id=="`country'" & married_couple==1  [aweight=weight_pop], vce(cluster hh_id)
	local n_obs = e(N)
	estadd scalar N_rob_mar_c = `n_obs'
	local adjr2 = e(r2_a)
	estadd scalar adjr2_mar_c = `adjr2'
	
    
    su labor_force if country_id=="`country'" & married_couple==1 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3) & married_couple==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_mar_c = `mean_outcome'
    estadd scalar Nssh_rob_mar_c = `n_ssh'

    eststo est_rob_mar_c`country'2: reg hours_worked i.couple_type $control_vars_hh_full if country_id=="`country'" & married_couple==1 [aweight=weight_pop], vce(cluster hh_id)
	local n_obs = e(N)
	estadd scalar N_rob_mar_c = `n_obs'
    local adjr2 = e(r2_a)
	estadd scalar adjr2_mar_c = `adjr2'
    su hours_worked if country_id=="`country'" & married_couple==1 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3) & married_couple==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_mar_c = `mean_outcome'
    estadd scalar Nssh_rob_mar_c = `n_ssh'	
	}
	
	if "`country'" == "BRA" {
    eststo est_rob_mar_c`country'1: reg hours_worked i.region_id
    
    eststo est_rob_mar_c`country'2: reg hours_worked i.region_id

}
	
	
    eststo est_rob_edut_c`country'1: reg labor_force i.couple_type $control_vars_hh_full if country_id=="`country'" & max_edu_lvl==3 [aweight=weight_pop], vce(cluster hh_id)
    
    su labor_force if country_id=="`country'" & max_edu_lvl==3 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3) & max_edu_lvl==3
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_edut_c = `mean_outcome'
    estadd scalar Nssh_rob_edut_c = `n_ssh'

    eststo est_rob_edut_c`country'2: reg hours_worked i.couple_type $control_vars_hh_full if country_id=="`country'" & max_edu_lvl==3 [aweight=weight_pop], vce(cluster hh_id)
    
    su hours_worked if country_id=="`country'" & max_edu_lvl==3 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3) & max_edu_lvl==3
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_edut_c = `mean_outcome'
    estadd scalar Nssh_rob_edut_c = `n_ssh'		
	
	
    eststo est_rob_edunt_c`country'1: reg labor_force i.couple_type $control_vars_hh_full if country_id=="`country'" & max_edu_lvl<3 [aweight=weight_pop], vce(cluster hh_id)
    
    su labor_force if country_id=="`country'" & max_edu_lvl<3 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3) & max_edu_lvl<3
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_edunt_c = `mean_outcome'
    estadd scalar Nssh_rob_edunt_c = `n_ssh'

    eststo est_rob_edunt_c`country'2: reg hours_worked i.couple_type $control_vars_hh_full if country_id=="`country'" & max_edu_lvl<3 [aweight=weight_pop], vce(cluster hh_id)
    
    su hours_worked if country_id=="`country'" & max_edu_lvl<3 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3) & max_edu_lvl<3
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_edunt_c = `mean_outcome'
    estadd scalar Nssh_rob_edunt_c = `n_ssh'
	
	
    
    eststo est_rob_cyrfx_c`country'1: reg labor_force i.couple_type $control_vars_hh_full i.region_id##i.year  if country_id=="`country'" [aweight=weight_pop], vce(cluster hh_id)
    
    su labor_force if country_id=="`country'" [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3)
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_cyrfx_c = `mean_outcome'
    estadd scalar Nssh_rob_cyrfx_c = `n_ssh'

    eststo est_rob_cyrfx_c`country'2: reg hours_worked i.couple_type $control_vars_hh_full i.region_id##i.year  if country_id=="`country'" [aweight=weight_pop], vce(cluster hh_id)
    
    su hours_worked if country_id=="`country'" [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3)
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_cyrfx_c = `mean_outcome'
    estadd scalar Nssh_rob_cyrfx_c = `n_ssh'
	
	
	if "`country'" != "BRA" {
		
	
    eststo est_rob_cimg_c`country'1: reg labor_force i.couple_type $control_vars_hh_full i.foreign_bp  if country_id=="`country'" [aweight=weight_pop], vce(cluster hh_id)
	local n_obs = e(N)
	estadd scalar N_rob_cimg_c = `n_obs'
    local adjr2 = e(r2_a)
	estadd scalar adjr2_cimg_c = `adjr2'
    su labor_force if country_id=="`country'" [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3)
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_cimg_c = `mean_outcome'
    estadd scalar Nssh_rob_cimg_c = `n_ssh'

    eststo est_rob_cimg_c`country'2: reg hours_worked i.couple_type $control_vars_hh_full i.foreign_bp  if country_id=="`country'" [aweight=weight_pop], vce(cluster hh_id)
	local n_obs = e(N)
	estadd scalar N_rob_cimg_c = `n_obs'
    local adjr2 = e(r2_a)
	estadd scalar adjr2_cimg_c = `adjr2'
	
    su hours_worked if country_id=="`country'" [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3)
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_cimg_c = `mean_outcome'
    estadd scalar Nssh_rob_cimg_c = `n_ssh'	
	
		
	}
	
	if "`country'" == "BRA" {
    eststo est_rob_cimg_c`country'1: reg hours_worked i.region_id

    eststo est_rob_cimg_c`country'2: reg hours_worked i.region_id

}
	
	if "`rg'" != "Europe" {
		
	
    eststo est_rob_crace_c`country'1: reg labor_force i.couple_type $control_vars_hh_full i.race_white  if country_id=="`country'" [aweight=weight_pop], vce(cluster hh_id)
    
    su labor_force if country_id=="`country'" [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su labor_force [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3)
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_crace_c = `mean_outcome'
    estadd scalar Nssh_rob_crace_c = `n_ssh'

    eststo est_rob_crace_c`country'2: reg hours_worked i.couple_type $control_vars_hh_full i.race_white  if country_id=="`country'" [aweight=weight_pop], vce(cluster hh_id)
    
    su hours_worked if country_id=="`country'" [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su hours_worked [weight=weight_pop] if country_id=="`country'" & (couple_type==2 | couple_type==3)
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_crace_c = `mean_outcome'
    estadd scalar Nssh_rob_crace_c = `n_ssh'	
	
		
	}
	
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
	
	
	preserve
	gegen min_age = min(age), by(hh_id)
	gegen max_age = max(age), by(hh_id)
	keep if country_id=="`country'" & min_age>=25 & max_age<=39

    eststo est_rob_age_c`country'3: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==1 , vce(cluster hh_id)
    
    su unemp if sex==1  [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_age_c = `mean_outcome'
    estadd scalar Nssh_rob_age_c = `n_ssh'

    eststo est_rob_age_c`country'4: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==2 , vce(cluster hh_id)
    
    su unemp if sex==2 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==2
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_age_c = `mean_outcome'
    estadd scalar Nssh_rob_age_c = `n_ssh'
	
	restore
	
	if "`country'" != "BRA" {
	
	preserve
	keep if country_id=="`country'" & married_couple==1
    eststo est_rob_mar_c`country'3: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==1 , vce(cluster hh_id)
	local n_obs = e(N)
	estadd scalar N_rob_mar_c = `n_obs'
    local adjr2 = e(r2_a)
	estadd scalar adjr2_mar_c = `adjr2'
    su unemp if sex==1  [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_mar_c = `mean_outcome'
    estadd scalar Nssh_rob_mar_c = `n_ssh'

    eststo est_rob_mar_c`country'4: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==2 , vce(cluster hh_id)
	local n_obs = e(N)
	estadd scalar N_rob_mar_c = `n_obs'
    local adjr2 = e(r2_a)
	estadd scalar adjr2_mar_c = `adjr2'
    su unemp if sex==2 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==2
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_mar_c = `mean_outcome'
    estadd scalar Nssh_rob_mar_c = `n_ssh'
	
	restore
	
	}
	
	if "`country'" == "BRA" {
    eststo est_rob_mar_c`country'3: reg unemp i.region_id

    
    eststo est_rob_mar_c`country'4:reg unemp i.region_id

}
	
	
	preserve
	gegen max_edu_lvl = max(edu_lvl), by(hh_id)
	keep if country_id=="`country'" &  max_edu_lvl==3
	
    eststo est_rob_edut_c`country'3: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==1 , vce(cluster hh_id)
    
    su unemp if sex==1  [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_edut_c = `mean_outcome'
    estadd scalar Nssh_rob_edut_c = `n_ssh'

    eststo est_rob_edut_c`country'4: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==2 , vce(cluster hh_id)
    
    su unemp if sex==2 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==2
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_edut_c = `mean_outcome'
    estadd scalar Nssh_rob_edut_c = `n_ssh'
	
	restore	
	
	
	preserve
	gegen max_edu_lvl = max(edu_lvl), by(hh_id)
	keep if country_id=="`country'" &  max_edu_lvl<3
	
    eststo est_rob_edunt_c`country'3: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==1 , vce(cluster hh_id)
    
    su unemp if sex==1  [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_edunt_c = `mean_outcome'
    estadd scalar Nssh_rob_edunt_c = `n_ssh'

    eststo est_rob_edunt_c`country'4: reg unemp i.couple_type $control_vars_full [aweight=weight_pop] if sex==2 , vce(cluster hh_id)
    
    su unemp if sex==2 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==2
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_edunt_c = `mean_outcome'
    estadd scalar Nssh_rob_edunt_c = `n_ssh'
	
	restore	
	
	
    preserve
	keep if country_id=="`country'"
    eststo est_rob_cyrfx_c`country'3: reg unemp i.couple_type $control_vars_full i.region_id##i.year  [aweight=weight_pop] if sex==1, vce(cluster hh_id)
    
    su unemp if sex==1 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_cyrfx_c = `mean_outcome'
    estadd scalar Nssh_rob_cyrfx_c = `n_ssh'

    eststo est_rob_cyrfx_c`country'4: reg unemp i.couple_type $control_vars_full i.region_id##i.year  [aweight=weight_pop] if sex==2 , vce(cluster hh_id)
    
    su unemp if sex==2 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if  (couple_type==2 | couple_type==3) & sex==2
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_cyrfx_c = `mean_outcome'
    estadd scalar Nssh_rob_cyrfx_c = `n_ssh'
	restore
	
	if "`country'" != "BRA" {
		

	preserve
	keep if country_id=="`country'"
    eststo est_rob_cimg_c`country'3: reg unemp i.couple_type $control_vars_full i.foreign_bp  [aweight=weight_pop] if sex==1, vce(cluster hh_id)
    local n_obs = e(N)
	estadd scalar N_rob_cimg_c = `n_obs'
	local adjr2 = e(r2_a)
	estadd scalar adjr2_cimg_c = `adjr2'
    su unemp if sex==1 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_cimg_c = `mean_outcome'
    estadd scalar Nssh_rob_cimg_c = `n_ssh'

    eststo est_rob_cimg_c`country'4: reg unemp i.couple_type $control_vars_full i.foreign_bp [aweight=weight_pop] if sex==2 , vce(cluster hh_id)
    local n_obs = e(N)
	estadd scalar N_rob_cimg_c = `n_obs'
	local adjr2 = e(r2_a)
	estadd scalar adjr2_cimg_c = `adjr2'
	
    su unemp if sex==2 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if  (couple_type==2 | couple_type==3) & sex==2
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_cimg_c = `mean_outcome'
    estadd scalar Nssh_rob_cimg_c = `n_ssh'
	restore
	
	}
	if "`country'" == "BRA" {
    eststo est_rob_cimg_c`country'3: reg unemp i.region_id

    
    eststo est_rob_cimg_c`country'4: reg unemp i.region_id

}
	
	if "`rg'" != "Europe" {
		
	preserve
	keep if country_id=="`country'"
    eststo est_rob_crace_c`country'3: reg unemp i.couple_type $control_vars_full i.race_white  [aweight=weight_pop] if sex==1, vce(cluster hh_id)
    
    su unemp if sex==1 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if (couple_type==2 | couple_type==3) & sex==1
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_crace_c = `mean_outcome'
    estadd scalar Nssh_rob_crace_c = `n_ssh'

    eststo est_rob_crace_c`country'4: reg unemp i.couple_type $control_vars_full i.race_white [aweight=weight_pop] if sex==2 , vce(cluster hh_id)
    
    su unemp if sex==2 [weight=weight_pop]
    local mean_outcome=r(mean)
    
    su unemp [weight=weight_pop] if  (couple_type==2 | couple_type==3) & sex==2
    local n_ssh=r(N)
    
    estadd scalar ymean_rob_crace_c = `mean_outcome'
    estadd scalar Nssh_rob_crace_c = `n_ssh'
	restore
	
	}
}

	
}





	
* Table A.2: Baseline regression results, full controls (fragments 1 and 2)
esttab est_rob_bas_cBEL* est_rob_bas_cBRA* est_rob_bas_cFRA* est_rob_bas_cDEU* using "../../bld/tables/baseline_reg_countries1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_bas_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

esttab est_rob_bas_cNLD* est_rob_bas_cGBR* est_rob_bas_cUSA* est_rob_bas_cURY* using "../../bld/tables/baseline_reg_countries2.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_bas_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc ))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses
	
* Table B.1: Robustness for ages 25-39 (fragments 1 and 2)
esttab est_rob_age_cBEL* est_rob_age_cBRA* est_rob_age_cFRA* est_rob_age_cDEU* using "../../bld/tables/rob_age2539_countries1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_age_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

esttab est_rob_age_cNLD* est_rob_age_cGBR* est_rob_age_cUSA* est_rob_age_cURY* using "../../bld/tables/rob_age2539_countries2.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_age_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc ))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses
	
* Table B.4: Robustness for married couples (fragments 1 and 2)
esttab est_rob_mar_cBEL* est_rob_mar_cBRA* est_rob_mar_cFRA* est_rob_mar_cDEU* using "../../bld/tables/rob_mar_countries1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( adjr2_mar_c ymean_rob_mar_c N_rob_mar_c, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

esttab est_rob_mar_cNLD* est_rob_mar_cGBR* est_rob_mar_cUSA* est_rob_mar_cURY* using "../../bld/tables/rob_mar_countries2.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( adjr2_mar_c ymean_rob_mar_c N_rob_mar_c, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc ))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses
	
* Table B.2: At least one partner with tertiary education (fragments 1 and 2)
esttab est_rob_edut_cBEL* est_rob_edut_cBRA* est_rob_edut_cFRA* est_rob_edut_cDEU* using "../../bld/tables/rob_edut_countries1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_edut_c N_rob_mar_c, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

esttab est_rob_edut_cNLD* est_rob_edut_cGBR* est_rob_edut_cUSA* est_rob_edut_cURY* using "../../bld/tables/rob_edut_countries2.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_edut_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc ))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses
	
* Table B.3: Neither partner with tertiary education (fragments 1 and 2)
esttab est_rob_edunt_cBEL* est_rob_edunt_cBRA* est_rob_edunt_cFRA* est_rob_edunt_cDEU* using "../../bld/tables/rob_edunt_countries1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_edunt_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

esttab est_rob_edunt_cNLD* est_rob_edunt_cGBR* est_rob_edunt_cUSA* est_rob_edunt_cURY* using "../../bld/tables/rob_edunt_countries2.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_edunt_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc ))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

* Table B.6: Region-specific year fixed effects (fragments 1 and 2)
esttab est_rob_cyrfx_cBEL* est_rob_cyrfx_cBRA* est_rob_cyrfx_cFRA* est_rob_cyrfx_cDEU* using "../../bld/tables/rob_cyrfx_countries1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_cyrfx_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

esttab est_rob_cyrfx_cNLD* est_rob_cyrfx_cGBR* est_rob_cyrfx_cUSA* est_rob_cyrfx_cURY* using "../../bld/tables/rob_cyrfx_countries2.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_cyrfx_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc ))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses
	
* Table B.7: Controlling for immigrant status (fragments 1 and 2)
esttab est_rob_cimg_cBEL* est_rob_cimg_cBRA* est_rob_cimg_cFRA* est_rob_cimg_cDEU* using "../../bld/tables/rob_cimg_countries1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( adjr2_cimg_c ymean_rob_cimg_c N_rob_cimg_c, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses

esttab est_rob_cimg_cNLD* est_rob_cimg_cGBR* est_rob_cimg_cUSA* est_rob_cimg_cURY* using "../../bld/tables/rob_cimg_countries2.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( adjr2_cimg_c ymean_rob_cimg_c N_rob_cimg_c, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc ))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses	
	

* Table B.8: Controlling for race
esttab est_rob_crace_cBRA* est_rob_crace_cUSA* est_rob_crace_cURY* using "../../bld/tables/rob_crace_countries1.tex", fragment b(%9.3f) ///
	replace nogap noabbrev label se(%9.3f) star(* 0.10 ** 0.05 *** 0.01)  ///
	stats( r2_a ymean_rob_crace_c N, labels( "Adj. R-Squared" "Mean of outcome" "Observations") fmt( 2 2 %9.0fc))  ///
	keep(2.couple_type 3.couple_type) ///
	order(2.couple_type 3.couple_type)  ///
	collabels(none) nogap mlabels(none) nolines plain parentheses	

