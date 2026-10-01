* Dependency: pooled descriptive and selection tables


clear

foreach cntry in BRA URY{
	cap append using "../../bld/data/data_countries/data_individual_`cntry'.dta"
}

save "../../bld/data/data_individual_developing.dta", replace


clear

foreach cntry in BRA URY{
	cap append using "../../bld/data/data_countries/data_hh_`cntry'.dta"
}

save "../../bld/data/data_hh_developing.dta", replace


clear

foreach cntry in BEL DEU FRA GBR NLD{
	cap append using "../../bld/data/data_countries/data_individual_`cntry'.dta"
}

save "../../bld/data/data_individual_Europe.dta", replace


clear

foreach cntry in BEL DEU FRA GBR NLD{
	cap append using "../../bld/data/data_countries/data_hh_`cntry'.dta"
}

save "../../bld/data/data_hh_Europe.dta", replace


