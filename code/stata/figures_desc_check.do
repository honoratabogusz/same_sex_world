* Figures A.1, D.5-D.7, and D.9


global countries "ARG BEL BRA COL FRA DEU IRL MEX NLD GBR URY"
global regions "Europe USA developing"


global color_dark "0 129 152"
global color_black "0 0 0"
global lab_size_main 3.5



	
 	foreach c in $countries {
		
		use "../../bld/data/data_countries/data_hh_`c'.dta", clear
		keep if urban == 1
		
		gen DSC = 1 if couple_type==1
		gen SSC = 1 if couple_type==2 | couple_type==3
		
		gcollapse (sum) SSC DSC [aweight=weight_pop], by(country_id year)
		
		gen SSC_ratio = SSC / (SSC+DSC)
				
		twoway connected SSC_ratio year, title(`c') msymbol(o) msize(3) mcolor("$color_black") lcolor("$color_black") lwidth(thick) xlabel(2015(1)2019, nogrid labsize($lab_size_main)) ytitle("") xtitle("") ylabel(0 "0%" 0.01 "1%" 0.02 "2%",nogrid  labsize($lab_size_main)) legend(off) plotregion(lstyle(none)) name(`c', replace)
		
	}

	
	
 	foreach c in USA {
		use "../../bld/data/data_hh_`c'.dta", clear
		keep if urban == 1

		gen DSC = 1 if couple_type==1
		gen SSC = 1 if couple_type==2 | couple_type==3
		
		gcollapse (sum) SSC DSC [aweight=weight_pop], by(year)
		
		gen SSC_ratio = SSC / (SSC+DSC)
				
		twoway connected SSC_ratio year, title(`c') msymbol(o) msize(3) mcolor("$color_black") lcolor("$color_black") lwidth(thick) xlabel(2015(1)2019, nogrid labsize($lab_size_main)) ytitle("") xtitle("") ylabel(0 "0%" 0.01 "1%" 0.02 "2%",nogrid  labsize($lab_size_main)) legend(off) plotregion(lstyle(none)) name(`c', replace)
		
	}
	
	graph combine ARG BEL BRA COL FRA DEU IRL MEX NLD GBR URY USA
	* Figure D.9: Share of same-sex couples in all couples by country and year
	graph export "../../bld/figures/SSC_ratio_all.pdf", replace
	
	




 	foreach c in $countries {
		
		use "../../bld/data/data_countries/data_individual_`c'.dta", clear
		keep if urban==1
		gen couple_type_2 = .
		replace couple_type_2=1 if couple_type==1
		replace couple_type_2=2 if couple_type==2 | couple_type==3
		
		gcollapse edu_secondary edu_tertiary age [aweight=weight_pop], by(country_id couple_type_2 year)
		
		keep if couple_type_2!=.
		
		foreach var in edu_secondary edu_tertiary {

		twoway (connected `var' year if couple_type_2==1, msymbol(o) msize(3) mcolor("$color_dark") lcolor("$color_dark") lwidth(thick)) (connected `var' year if couple_type_2==2, msymbol(o) msize(3) mcolor("$color_black") lcolor("$color_black") lwidth(thick)), title(`c') xlabel(2015(1)2019, nogrid labsize($lab_size_main)) ytitle("") xtitle("") ylabel(0 "0%" 0.5 "50%" 1 "100%",  nogrid format(%03.1f) labsize($lab_size_main)) legend(off row(1) position(6) size($lab_size_main) label(1 "DSC") label(2 "SSC")) plotregion(lstyle(none)) name(`c'_`var', replace)
			
		}
		
		
		twoway (connected age year if couple_type_2==1, msymbol(o) msize(3) mcolor("$color_dark") lcolor("$color_dark") lwidth(thick)) (connected age year if couple_type_2==2, msymbol(o) msize(3) mcolor("$color_black") lcolor("$color_black") lwidth(thick)), title(`c') xlabel(2015(1)2019, nogrid labsize($lab_size_main)) ytitle("") xtitle("") ylabel(30(5)45,nogrid  labsize($lab_size_main))  legend(off row(1) position(6) size($lab_size_main) label(1 "DSC") label(2 "SSC")) plotregion(lstyle(none)) name(`c'_age, replace)
		

	}

		
 	foreach c in USA {
		use "../../bld/data/data_individual_`c'.dta", clear
		keep if urban==1
		gen couple_type_2 = .
		replace couple_type_2=1 if couple_type==1
		replace couple_type_2=2 if couple_type==2 | couple_type==3
		
		gcollapse edu_secondary edu_tertiary age [aweight=weight_pop], by(couple_type_2 year)
		
		keep if couple_type_2!=.
		
		foreach var in edu_secondary edu_tertiary {

		twoway (connected `var' year if couple_type_2==1, msymbol(o) msize(3) mcolor("$color_dark") lcolor("$color_dark") lwidth(thick)) (connected `var' year if couple_type_2==2, msymbol(o) msize(3) mcolor("$color_black") lcolor("$color_black") lwidth(thick)), title(`c') xlabel(2015(1)2019, nogrid labsize($lab_size_main)) ytitle("") xtitle("") ylabel(0 "0%" 0.5 "50%" 1 "100%",  nogrid format(%03.1f)labsize($lab_size_main)) legend(off row(1) position(6) size($lab_size_main) label(1 "DSC") label(2 "SSC")) plotregion(lstyle(none)) name(`c'_`var', replace)
			
		}
		
		
		twoway (connected age year if couple_type_2==1, msymbol(o) msize(3) mcolor("$color_dark") lcolor("$color_dark") lwidth(thick)) (connected age year if couple_type_2==2, msymbol(o) msize(3) mcolor("$color_black") lcolor("$color_black") lwidth(thick)), title(`c') xlabel(2015(1)2019, nogrid labsize($lab_size_main)) ytitle("") xtitle("") ylabel(30(5)45,nogrid  labsize($lab_size_main)) legend(off row(1) position(6) size($lab_size_main) label(1 "DSC") label(2 "SSC")) plotregion(lstyle(none)) name(`c'_age, replace)
		

	}
	
	grc1leg ARG_edu_secondary BEL_edu_secondary BRA_edu_secondary COL_edu_secondary FRA_edu_secondary DEU_edu_secondary IRL_edu_secondary MEX_edu_secondary NLD_edu_secondary GBR_edu_secondary URY_edu_secondary USA_edu_secondary
	* Figure D.6: Share with secondary education by couple type, country, and year
	graph export "../../bld/figures/edu_secondary_all.pdf", replace
	
	grc1leg ARG_edu_tertiary BEL_edu_tertiary BRA_edu_tertiary COL_edu_tertiary FRA_edu_tertiary DEU_edu_tertiary IRL_edu_tertiary MEX_edu_tertiary NLD_edu_tertiary GBR_edu_tertiary URY_edu_tertiary USA_edu_tertiary
	* Figure D.7: Share with tertiary education by couple type, country, and year
	graph export "../../bld/figures/edu_tertiary_all.pdf", replace

	grc1leg ARG_age BEL_age BRA_age COL_age FRA_age DEU_age IRL_age MEX_age NLD_age GBR_age URY_age USA_age
	* Figure D.5: Average age by couple type, country, and year
	graph export "../../bld/figures/age_all.pdf", replace
	
	

	
	clear all
	foreach c in $regions {
		cap append using "../../bld/data/data_hh_`c'.dta", force
	}	
		
	gen couple_type_2 = 1 if couple_type==1
	replace couple_type_2 = 2 if couple_type==2 | couple_type==3
	
	gcollapse urban [aweight=weight_pop_hh], by(country_id couple_type_2)
		
	keep if couple_type_2!=.
		
	reshape wide urban, i(country_id) j(couple_type_2)
			
	graph bar urban1 urban2, over(country_id, sort(2) descending label(labsize($lab_size_main))) ytitle("") bar(1, color("$color_dark") lwidth(medium) fintensity(inten100)) bar(2, color("$color_black") lwidth(medium) fintensity(inten100)) ylabel(0 "0%" 0.5 "50%" 1 "100%",  nogrid format(%03.1f) nogrid labsize($lab_size_main)) legend(row(1) position(6) size($lab_size_main) label(1 "DSC") label(2 "SSC")) plotregion(lstyle(none))
		
	* Figure A.1: Urban population share by couple type
	graph export "../../bld/figures/urban_all_countries_sample.png", width(1058) replace








