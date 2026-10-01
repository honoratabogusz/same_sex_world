* Figure 1: population with access to same-sex marriage


global color_dark "0 129 152"
global color_bright "217 240 244"
global color_black "0 0 0"
global color_gr_dark "51 51 51"
global lab_size_main 3.5
global title_size_main 4


set scheme plotplainblind

import delimited "../../bld/data/population_samesex_marriage_world.csv", clear

keep if year>=2000 & year<=2020

gen x_0=0

twoway (line pop_ssm year, msymbol(o) msize(2) mcolor("$color_black") lcolor("$color_black")) (rarea pop_data_all pop_data_fin year, col("$color_bright")) (rarea pop_data_fin x_0 year, col("$color_dark")), xlabel(2000(5)2020,nogrid labsize($lab_size_main)) ytitle("Population (millions)") xtitle("") ylabel(,nogrid  labsize($lab_size_main))  legend(label(1 "Population with same-sex marriage") label(2 "Collected survey data") label(3 "Final sample (high-quality data)") position(6) )
				
* Figure 1: Population of countries with access to same-sex marriage
graph export "../../bld/figures/population_samesex_marriage_world_our_data.png", replace

				


