* Figure 7: unemployment accounting for occupational segregation

set scheme plotplainblind


foreach c in USA BEL DEU FRA GBR NLD URY{
	use "../../bld/data/unemp_risk_analysis_`c'.dta", clear
	sort sex couple_type
	gen no1 = _n
	replace no1=3 if no1==2
	gen no2 = _n

	replace no1=no1+3 if sex==2
	replace no2=no2+3 if sex==2
	replace no1=8 if no1==7
	
	twoway (bar unemp no1 if no1==1, color(black)) ///
(bar unemp_occ_risk no2 if no2==2, color("128 236 255")) (bar unemp no1 if no1==3, color("0 129 152")) ///
(bar unemp no1 if no1==6, color(black)) ///
(bar unemp_occ_risk no2 if no2==7, color("128 236 255")) (bar unemp no1 if no1==8, color("0 129 152")), ///
xlabel(none) ylabel(0 "0%" 0.02 "2%" 0.04 "4%" 0.06 "6%" 0.08 "8%", nogrid labsize(3.5)) xsize(16) ysize(14) xtitle(" ") ytitle("Unemployment rate" " ", size(3.5)) ///
legend(order(1 "DSC: actual" 2 "SSC: occupational risk" 3 "SSC: actual") cols(4) ring(1) position(6) size(3.2)) ///
text(0.09 2 "Men", size(4.5)) text(0.09 7 "Women", size(4.5)) ///
graphregion(margin(t+10))
* Figure 7: Unemployment accounting for occupational segregation (country panels)
graph export           "../../bld/figures/bar_unemp_rate_occ_country_`c'.png", replace width(5000)
}

foreach c in BRA{
	use "../../bld/data/unemp_risk_analysis_`c'.dta", clear
	sort sex couple_type
	gen no1 = _n
	replace no1=3 if no1==2
	gen no2 = _n

	replace no1=no1+3 if sex==2
	replace no2=no2+3 if sex==2
	replace no1=8 if no1==7
	
	twoway (bar unemp no1 if no1==1, color(black)) ///
(bar unemp_occ_risk no2 if no2==2, color("128 236 255")) (bar unemp no1 if no1==3, color("0 129 152")) ///
(bar unemp no1 if no1==6, color(black)) ///
(bar unemp_occ_risk no2 if no2==7, color("128 236 255")) (bar unemp no1 if no1==8, color("0 129 152")), ///
xlabel(none) ylabel(0 "0%" 0.02 "2%" 0.04 "4%" 0.06 "6%" 0.08 "8%", nogrid labsize(3.5)) xsize(16) ysize(14) xtitle(" ") ytitle("Unemployment rate" " ", size(3.5)) ///
legend(order(1 "DSC: actual" 2 "SSC: occupational risk" 3 "SSC: actual") cols(4) ring(1) position(6) size(3.2)) ///
text(0.13 2 "Men", size(4.5)) text(0.13 7 "Women", size(4.5)) ///
graphregion(margin(t+10))
* Figure 7: Unemployment accounting for occupational segregation (Brazil panel)
graph export           "../../bld/figures/bar_unemp_rate_occ_country_`c'.png", replace width(5000)
}




