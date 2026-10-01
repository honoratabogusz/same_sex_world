* Figures 7 and D.10; Tables D.7 and D.8 dependency

do "config.do"
clear



foreach c in BE DE FR NL UK {
	foreach y in 2015 2016 2017 2018 2019 {
		import delimited "$raw_data_unemp/`c'`y'_y.csv", clear
		keep qhhnum hhseqnum country year age coeff ilostat isco3d iscopr3d
		
		if "`c'" == "FR" {
			replace coeff = 1
		}
		
		keep if age >= 20 & age <= 64 
		keep if ilostat == 1 | ilostat == 2 
	
		replace isco3d = . if isco3d == 999
		replace iscopr3d = . if iscopr3d == 999
		gen isco_3d = .
		replace isco_3d = isco3d if ilostat == 1
		replace isco_3d = iscopr3d if ilostat == 2
		gen unemp_occ_risk = 1 if ilostat == 2
		replace unemp_occ_risk = 0 if ilostat == 1
		egen weight_sum = total(coeff)
		gen weight_adj = coeff/weight_sum
		
		gen pop_2017=.
		
		if "`c'" == "BE" {
			replace pop_2017 = 11375158
		}
		
		if "`c'" == "DE" {
			replace pop_2017 = 82657002
		}
		
		if "`c'" == "FR" {
			replace pop_2017 = 66918020
		}
		
		if "`c'" == "NL" {
			replace pop_2017 = 17131296
		}
		
		if "`c'" == "UK" {
			replace pop_2017 = 66058859
		}
		
		gen weight_pop=weight_adj*pop_2017
		
		keep isco_3d weight_pop unemp_occ_risk
		drop if isco_3d==.
		save "../../bld/data/unempl_rates_eu_lfs/`c'`y'.dta", replace	
	}
}

clear

foreach c in BE DE FR NL UK {
	foreach y in 2015 2016 2017 2018 2019 {
		cap append using "../../bld/data/unempl_rates_eu_lfs/`c'`y'.dta"
	}
}

preserve

gen count=1

gcollapse (sum) count, by(isco_3d)

save "../../bld/data/unempl_rates_eu_lfs_counts.dta", replace	
	

restore

gcollapse unemp_occ_risk [aweight=weight_pop], by(isco_3d)

merge 1:1 isco_3d using  "../../bld/data/unempl_rates_eu_lfs_counts.dta", nogen

keep if count>=1000
drop count

save "../../bld/data/unempl_rates_eu_lfs.dta", replace	
	



