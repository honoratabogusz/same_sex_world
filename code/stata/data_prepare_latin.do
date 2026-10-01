* Dependency: all retained Brazil and Uruguay exhibits and appendix counts

do "config.do"
label def ssh_lab 1 "Different-sex couple" 2 "Men same-sex couple" 3 "Women same-sex couple", replace



foreach y in 15{
	foreach q in 1 2{
		use "$raw_data/ARG/Individual_t`q'`y'.dta", clear
		rename *, lower 
		gen year = 2000+`y'
		gen quarter=`q'
		gen hh_id=codusu+"20"+"`y'"+"`q'"
		keep year quarter hh_id ch03 ch04 ch06 ch07 ch08 ch15 pondera region nivel_ed estado cat_ocup pp3e_tot pp3f_tot pp06c pp06d p21 tot_p12 mas_500
		
		save "../../bld/data/ARG/`y'_`q'", replace
	}
}


foreach y in 16{
	foreach q in 2 3 4{
		import delimited "$raw_data/ARG/usu_individual_t`q'`y'.txt", clear
		rename *, lower 
		gen year = 2000+`y'
		gen quarter=`q'
		gen hh_id=codusu+"20"+"`y'"+"`q'"
		keep year quarter hh_id ch03 ch04 ch06 ch07 ch08 ch15 pondera region nivel_ed estado cat_ocup pp3e_tot pp3f_tot pp06c pp06d p21 tot_p12  mas_500
		save "../../bld/data/ARG/`y'_`q'", replace
	}
}

foreach y in 17 18 19{
	foreach q in 1 2 3 4{
		import delimited "$raw_data/ARG/usu_individual_t`q'`y'.txt", clear
		rename *, lower 
		gen year = 2000+`y'
		gen quarter=`q'
		gen hh_id=codusu+"20"+"`y'"+"`q'"
		keep year quarter hh_id ch03 ch04 ch06 ch07 ch08 ch15 pondera region nivel_ed estado cat_ocup pp3e_tot pp3f_tot pp06c pp06d p21 tot_p12 mas_500 
		save "../../bld/data/ARG/`y'_`q'", replace
	}
}

clear

foreach y in 15{
    foreach q in 1 2{ 
		qui append using "../../bld/data/ARG/`y'_`q'.dta"
	}
}

foreach y in 16{
    foreach q in 2 3 4{ 
		qui append using "../../bld/data/ARG/`y'_`q'.dta"

	}
}

foreach y in 17 18 19{
    foreach q in  1 2 3 4{ 
		qui append using "../../bld/data/ARG/`y'_`q'.dta"
	}
}

replace hh_id = "ARG"+hh_id
gen world_region=3
gegen weight_sum = sum(pondera), by(year)
gen weight_adj=pondera/weight_sum
replace weight_adj=weight_adj/5
gen pop_2017=44044.811
gen weight_pop=weight_adj*pop_2017

tostring(region), gen(region_str)
drop region
gen region="ARG"+region_str

gen age=ch06
gen sex=ch04
gen rel_arg=ch03


gen urban=1

gen age_0_14=0
replace age_0_14=1 if age>=0 & age<=14
gen age_15_19=0
replace age_15_19=1 if age>=15 & age<=19
gen age_20_64=0
replace age_20_64=1 if age>=20 & age<=64
gen age_65plus=0
replace age_65plus=1 if age>=65 & age!=.

foreach var in age_0_14 age_15_19 age_20_64 age_65plus{
	gegen hh_`var' = sum(`var'), by(hh_id)
	gen hh_`var'_d=.
	replace hh_`var'_d=0 if hh_`var'==0
	replace hh_`var'_d=1 if hh_`var'>0 & hh_`var'!=.
}

keep if rel_arg==1 | rel_arg==2

gen count_obs=1
gegen count_s = total(count_obs), by(hh_id)
keep if count_s==1 | count_s==2

gegen min_age = min(age), by(hh_id)
gegen max_age = max(age), by(hh_id)


gen single=0
replace single=1 if count_s==1

gegen mean_sex = mean(sex), by(hh_id)

cap drop couple_type
gen couple_type=.
replace couple_type=1 if mean_sex==1.5
replace couple_type=2 if mean_sex==1
replace couple_type=3 if mean_sex==2
replace couple_type=. if single==1
label val couple_type ssh_lab		

preserve
keep if min_age>=65 &  max_age<=99
keep if single==0
keep if urban==1		
gen couple_type2=0
replace couple_type2=1 if couple_type==2 | couple_type==3
gcollapse couple_type2 [aweight=weight_pop], by(year)
gen country = "ARG"
rename couple_type2 couple_type2_65plus
save "../../bld/data/counts/ARG_ssh_obs_yrs_old_age_shares.dta", replace
restore


keep if min_age>=20 & max_age<=64

cap drop mar_x
gen mar_x=0
replace mar_x=1 if ch07==2
gegen mar_x_mean=mean(mar_x), by(hh_id)
gen married_couple=0
replace married_couple=1 if mar_x_mean==1

gen foreign_bp=.
replace foreign_bp=0 if ch15>=1 & ch15<=3
replace foreign_bp=1 if ch15>=4 & ch15<=9
gegen foreign_bp_any=max(foreign_bp), by(hh_id)

gcollapse (mean) world_region pop_2017 year quarter single couple_type  urban hh_age* married_couple foreign_bp_any (sum) weight_adj weight_pop, by(hh_id region)

foreach var in weight_adj weight_pop{
	rename `var' `var'_hh
}

gen country_id="ARG"

save "../../bld/data/data_countries/data_hh_ARG.dta", replace


clear

foreach y in 15{
    foreach q in 1 2{ 
		qui append using "../../bld/data/ARG/`y'_`q'.dta"
	}
}

foreach y in 16{
    foreach q in 2 3 4{ 
		qui append using "../../bld/data/ARG/`y'_`q'.dta"

	}
}

foreach y in 17 18 19{
    foreach q in  1 2 3 4{ 
		qui append using "../../bld/data/ARG/`y'_`q'.dta"
	}
}

drop region
replace hh_id = "ARG"+hh_id
gen rel_arg=ch03
gegen weight_sum = sum(pondera), by(year)
gen weight_adj=pondera/weight_sum
replace weight_adj=weight_adj/5
drop weight_sum

keep if rel_arg==1 | rel_arg==2
gen age=ch06
gen sex=ch04
merge m:1 hh_id using "../../bld/data/data_countries/data_hh_ARG.dta", nogen
gen weight_pop=weight_adj*pop_2017
keep if single==0



gen edu_lvl=.
replace edu_lvl=1 if nivel_ed>=1 & nivel_ed<=3
replace edu_lvl=2 if nivel_ed>=4 & nivel_ed<=5
replace edu_lvl=3 if nivel_ed==6

gen edu_secondary=.
replace edu_secondary=1 if edu_lvl==2
replace edu_secondary=0 if edu_lvl==1 | edu_lvl==3

gen edu_tertiary=.
replace edu_tertiary=1 if edu_lvl==3
replace edu_tertiary=0 if edu_lvl==1 | edu_lvl==2

gen foreign_bp=.
replace foreign_bp=0 if ch15>=1 & ch15<=3
replace foreign_bp=1 if ch15>=4 & ch15<=9

gen lab_status=estado

gen labor_force=.
replace labor_force=1 if estado==1 | estado==2
replace labor_force=0 if estado==3

gen unemp=.
replace unemp=1 if estado==2
replace unemp=0 if estado==1

gen employed=.
replace employed=1 if estado==1
replace employed=0 if estado==2 | estado==3

cap drop selfemp
gen selfemp=.
replace selfemp=1 if cat_ocup>=1 & cat_ocup<=2 & employed==1
replace selfemp=0 if cat_ocup==3 & employed==1

replace pp3e_tot=0 if pp3e_tot==. | pp3e_tot==999
replace pp3f_tot=0 if pp3f_tot==. | pp3f_tot==999

gen hours_worked_act=pp3e_tot+pp3f_tot

gen informal_emp=.
replace informal_emp=1 if employed==1 & ch08==4
replace informal_emp=0 if employed==1 & ch08!=4  & ch08!=9  & ch08!=.


gen exch_rate_2015=8.9207

gen inflation=.
qui replace inflation = 825.3 if year==2015
qui replace inflation = 1164.7 if year==2016
qui replace inflation = 1467.6 if year==2017
qui replace inflation = 2084.4 if year==2018
qui replace inflation = 3109.9 if year==2019

qui replace inflation=inflation/825.3

foreach var in  pp06c pp06d p21 tot_p12{
	replace `var'=0 if `var'==. | `var'<0
}


gen earnings_bus = (pp06c+pp06d)/inflation
gen earnings_wage = (p21+tot_p12)/inflation
gen earnings_all = earnings_bus+earnings_wage

gen hwage = (12*earnings_wage)/(52*hours_worked_act)
replace hwage=. if hwage==0
_pctile hwage, percentiles(99.75)
replace hwage=r(r1) if hwage>=r(r1) & hwage!=.
_pctile hwage, percentiles(1)
replace hwage=r(r1) if hwage<=r(r1) & hwage!=.

gen ln_hwage = ln(hwage)

foreach var in earnings_all earnings_bus earnings_wage{
	replace `var'=`var'/12
	_pctile `var', percentiles(99.75)
	replace `var'=r(r1) if `var'>=r(r1) & hwage!=.
}

gen miss_any=0
replace miss_any=1 if region=="" | edu_lvl==. | lab_status==. | weight_pop==. | weight_pop==0
gegen miss_sum = total(miss_any), by(hh_id)
keep if miss_sum==0


keep hh_id country_id world_region pop_2017 year quarter single couple_type region urban hh_age*  married_couple foreign_bp_any weight_adj* weight_pop* sex age edu_lvl edu_secondary edu_tertiary foreign_bp lab_status labor_force employed unemp hours_worked_act selfemp informal_emp earnings_bus earnings_wage earnings_all hwage ln_hwage

save "../../bld/data/data_countries/data_individual_ARG.dta", replace








foreach y in 2015 2016 2017 2018 2019{
	use "$raw_data/BRA/pnadcontinua/PNADC_trimestral_`y'.dta", clear
	rename *, lower 
	gen year = ano
	gen quarter=trimestre
	tostring hous_id, gen(hous_id_str) format("%12.0f")
	tostring year, gen(year_str)
	tostring quarter, gen(quarter_str)
	gen hh_id= "BRA" + year_str+quarter_str+hous_id_str
	gen age=year-v20082
	keep year quarter hh_id age v2007 v2005 v2010 v1027 v3003 v3003a v3009 v3009a uf v1022 v4001 v4002 v4003 v4005 v4012 vd4020 vd4031 vd4012 v4071 v4077 v4010 
	save "../../bld/data/BRA/`y'.dta", replace
}

clear

foreach y in 2015 2016 2017 2018 2019{
use "../../bld/data/BRA/`y'.dta", clear


gen world_region=3
gegen weight_sum = sum(v1027)
gen weight_adj=v1027/weight_sum
gen pop_2017=207833.825
gen weight_pop=weight_adj*pop_2017



gen sex=v2007
gen rel_bra=v2005
drop v2007 v2005
gen weight_sample=v1027

tostring(uf), gen(region_str)
gen region="BRA"+region_str


gen urban=.
replace urban=0 if v1022==2
replace urban=1 if v1022==1

gen age_0_14=0
replace age_0_14=1 if age>=0 & age<=14
gen age_15_19=0
replace age_15_19=1 if age>=15 & age<=19
gen age_20_64=0
replace age_20_64=1 if age>=20 & age<=64
gen age_65plus=0
replace age_65plus=1 if age>=65 & age!=.

gen age_0_14_nonch=0
replace age_0_14_nonch=1 if age>=0 & age<=14 & rel_bra!=4 & rel_bra!=5 & rel_bra!=6


foreach var in age_0_14 age_15_19 age_20_64 age_65plus{
	gegen hh_`var' = sum(`var'), by(hh_id)
	gen hh_`var'_d=.
	replace hh_`var'_d=0 if hh_`var'==0
	replace hh_`var'_d=1 if hh_`var'>0 & hh_`var'!=.
}

gegen hh_age_0_14_nonch_d = max(age_0_14_nonch), by(hh_id)

gen age_temp_x=.
replace age_temp_x=age if rel_bra>=4 & rel_bra<=6
gegen age_ch_oldest = max(age_temp_x), by(hh_id)
drop age_temp_x

preserve
	
keep if age_0_14==1
keep hh_id rel_bra 
gen relation_child = .
replace relation_child=1 if rel_bra>=4 & rel_bra<=6
replace relation_child=2 if inlist(rel_bra,8,10,11,12,14)
replace relation_child=3 if inlist(rel_bra,7,9,15,16,17,18,19)
	
save "../../bld/data/BRA/data_under15_BRA_`y'.dta", replace
	
restore



keep if rel_bra==1 | rel_bra==2 | rel_bra==3

gen count_obs=1
gegen count_s = total(count_obs), by(hh_id)
keep if count_s==1 | count_s==2

gegen min_age = min(age), by(hh_id)
gegen max_age = max(age), by(hh_id)



gen single=0
replace single=1 if count_s==1

gegen mean_sex = mean(sex), by(hh_id)

cap drop couple_type
gen couple_type=.
replace couple_type=1 if mean_sex==1.5
replace couple_type=2 if mean_sex==1
replace couple_type=3 if mean_sex==2
replace couple_type=. if single==1
label val couple_type ssh_lab	

preserve
keep if  min_age>=65 &  max_age<=99
keep if urban==1		
keep if single==0
gen couple_type2=0
replace couple_type2=1 if couple_type==2 | couple_type==3
gcollapse couple_type2 [aweight=weight_pop], by(year)
gen country = "BRA"
rename couple_type2 couple_type2_65plus
save "../../bld/data/counts/BRA/BRA_ssh_obs_yrs_old_age_`y'_shares.dta", replace
restore

	preserve 
	gen old_age=.
	replace old_age=0 if min_age>=20 & max_age<=64
	replace old_age=1 if min_age>=65 & max_age<=99
	keep if old_age!=.
	keep if urban==1
	keep if single==0


	gen couple_type2_x=0
	replace couple_type2_x=1 if (couple_type==2 | couple_type==3) & rel_bra==3
	gegen couple_type2=max(couple_type2_x), by(hh_id)	
	gcollapse couple_type2 [aweight=weight_pop], by(old_age year)
	gen COUNTRY = "BRA"
	reshape wide couple_type2, i(COUNTRY year)  j(old_age)
	save "../../bld/data/descriptives/BRA_ssc_old_young_`y'_shares.dta", replace
	restore


keep if min_age>=20 & max_age<=64

cap drop ssm_direct
gen ssm_rel_x=0
replace ssm_rel_x=1 if rel_bra==3
gegen ssm_direct=max(ssm_rel_x), by(hh_id)



gcollapse (mean) world_region pop_2017 year quarter single couple_type urban hh_age* ssm_direct age_ch_oldest (sum) weight_adj weight_pop, by(hh_id region)

foreach var in weight_adj weight_pop{
	rename `var' `var'_hh
}

gen country_id="BRA"

save "../../bld/data/BRA/data_hh_BRA_`y'.dta", replace


}

clear




foreach y in 2015 2016 2017 2018 2019{
use "../../bld/data/BRA/`y'.dta", clear


gen sex=v2007
gen rel_bra=v2005
gegen weight_sum = sum(v1027)
gen weight_adj=v1027/weight_sum
drop weight_sum


keep if rel_bra==1 | rel_bra==2 | rel_bra==3

merge m:1 hh_id using "../../bld/data/BRA/data_hh_BRA_`y'.dta", nogen
gen weight_pop=weight_adj*pop_2017
keep if single==0

gen edu_lvl=.
replace edu_lvl=1 if v3003>=1 & v3003<=6
replace edu_lvl=2 if  v3003==7
replace edu_lvl=3 if v3003>=8 & v3003<=9
replace edu_lvl=1 if v3009>=1 & v3009<=6
replace edu_lvl=2 if v3009>=7 & v3009<=9
replace edu_lvl=3 if v3009>=10 & v3009<=12

replace edu_lvl=1 if v3003a>=1 & v3003a<=7
replace edu_lvl=2 if  v3003a>=8 & v3003a<=9
replace edu_lvl=3 if  v3003a>=10 & v3003a<=11
replace edu_lvl=1 if  v3009a>=1 & v3009a<=8
replace edu_lvl=2 if  v3009a>=9 & v3009a<=11
replace edu_lvl=3 if  v3009a>=12 & v3009a<=15

gen edu_secondary=.
replace edu_secondary=1 if edu_lvl==2
replace edu_secondary=0 if edu_lvl==1 | edu_lvl==3

gen edu_tertiary=.
replace edu_tertiary=1 if edu_lvl==3
replace edu_tertiary=0 if edu_lvl==1 | edu_lvl==2

gen race_white=0
replace race_white=1 if v2010==1

gen employed=0
replace employed=1 if v4001==1 | v4002==1 | v4003==1 | v4005==1

gen unemp=.
replace unemp=0 if emp==1
replace unemp=1 if v4071==1 & v4077==1
gen labor_force=0
replace labor_force=1 if emp==1 | unemp==1

gen lab_status=.
replace lab_status=1 if employed==1
replace lab_status=2 if unemp==1
replace lab_status=3 if labor_force==0



gen exch_rate_2015=3.336

gen inflation=.
qui replace inflation = 1.384 if year==2015
qui replace inflation = 1.505 if year==2016
qui replace inflation = 1.557 if year==2017
qui replace inflation = 1.614 if year==2018
qui replace inflation = 1.674 if year==2019

replace inflation = inflation/1.384	
	
	
gen incwage=vd4020*12
gen incwage_inf=incwage/inflation
replace incwage_inf=incwage_inf/exch_rate_2015

replace incwage_inf=0 if employed!=1

gen hours_worked=vd4031
gen hwyear=52*hours_worked

qui gen hwage = incwage_inf / hwyear
replace hwage=. if hwage==0
_pctile hwage, percentiles(99.75)
replace hwage=r(r1) if hwage>=r(r1) & hwage!=.
_pctile hwage, percentiles(1)
replace hwage=r(r1) if hwage<=r(r1) & hwage!=.


gen ln_hwage = ln(hwage)

gen earnings_all = incwage_inf/12
_pctile earnings_all, percentiles(99.75)
replace earnings_all=r(r1) if earnings_all>=r(r1) & earnings_all!=.
replace earnings_all=0 if employed!=1

	
cap drop selfemp
gen selfemp=.
replace selfemp=0 if v4012>=1 &  v4012<=4 & employed==1
replace selfemp=1 if v4012>=5 &  v4012<=6 & employed==1

gen miss_any=0
replace miss_any=1 if region=="" | edu_lvl==. | lab_status==. | weight_pop==. | weight_pop==0
gegen miss_sum = total(miss_any), by(hh_id)
keep if miss_sum==0


gen informal_emp=.
replace informal_emp=1 if employed==1 & vd4012==2
replace informal_emp=0 if employed==1 & vd4012==1

gen isco_3d = floor(v4010/10)
merge m:1 isco_3d using "../../bld/data/unempl_rates_eu_lfs.dta"
drop if _merge==2
drop _merge


keep hh_id country_id world_region pop_2017 year quarter single couple_type region age_ch_oldest urban hh_age* ssm_direct weight_adj* weight_pop* sex age edu_lvl edu_secondary edu_tertiary race_white lab_status labor_force employed unemp hours_worked hwage ln_hwage earnings_all selfemp informal_emp isco_3d unemp_occ_risk

save "../../bld/data/BRA/data_individual_BRA_`y'.dta", replace
}


clear
foreach y in 2015 2016 2017 2018 2019 {
	append using "../../bld/data/BRA/data_hh_BRA_`y'.dta"
	
}

replace weight_adj_hh=weight_adj_hh/5
replace weight_pop_hh=weight_pop_hh/5

save "../../bld/data/data_countries/data_hh_BRA.dta", replace

clear
foreach y in 2015 2016 2017 2018 2019 {
	append using "../../bld/data/BRA/data_individual_BRA_`y'.dta"
}

replace weight_adj_hh=weight_adj_hh/5
replace weight_pop_hh=weight_pop_hh/5
replace weight_adj=weight_adj/5
replace weight_pop=weight_pop/5


save "../../bld/data/data_countries/data_individual_BRA.dta", replace



clear
foreach y in 2015 2016 2017 2018 2019 {
	cap append using "../../bld/data/BRA/data_under15_BRA_`y'.dta"
	
}

merge m:1 hh_id using "../../bld/data/data_countries/data_hh_BRA.dta"
keep if _merge==3
keep if single==0
keep if urban==1
gen COUNTRY=country_id
tabulate relation_child, generate(rel_ch)
gcollapse rel_ch* [aweight=weight_pop], by(COUNTRY couple_type)

rename rel_ch1 child
rename rel_ch2 other_relative
rename rel_ch3 other_non_relative
keep COUNTRY couple_type child other_relative other_non_relative
* Table A.11 input
save "../../bld/data/descriptives/under_15/under_15_couple_type_BRA.dta", replace


clear
foreach y in 2015 2016 2017 2018 2019 {
	append using "../../bld/data/descriptives/BRA_ssc_old_young_`y'_shares.dta"
	
}
collapse couple_type20 couple_type21, by(COUNTRY)
* Figure D.8 input
save "../../bld/data/descriptives/BRA_ssc_old_young_shares.dta", replace 

global var_raw_col year month hh_id p6040 p6050 fex_c_2011 p6020 p6210 dpto urban

* Colombia raw files: the file names contain accented letters ("Área",
* "Características") whose encoding depends on how the archives were
* unzipped. Files are therefore located by wildcard patterns that avoid
* the accented letters, and a missing file stops the script with a clear
* message instead of silently reusing the data already in memory.

* Find exactly one file matching a pattern in a folder and load it
capture program drop col_load
program define col_load
    args folder pattern
    local files : dir "`folder'" files "`pattern'", respectcase
    local n : word count `files'
    if `n' != 1 {
        display as error `"Expected one file matching "`pattern'" in `folder', found `n'"'
        exit 601
    }
    local f : word 1 of `files'
    if strpos(lower("`pattern'"), ".txt") {
        import delimited "`folder'/`f'", clear
    }
    else {
        use "`folder'/`f'", clear
    }
end

* Load the three area files for one month:
* 01 = Área (urban), 02 = Cabecera (urban), 03 = Resto (rural)
capture program drop col_month
program define col_month
    args y m
    local folder "$raw_data/COL/`y'_`m'/data"
    * Raw files are .txt up to August 2017 and .dta afterwards
    local ext = cond(`y' <= 2016 | (`y' == 2017 & real("`m'") <= 8), "txt", "dta")
    local i = 0
    foreach part in "*rea" "Cabecera" "Resto" {
        local ++i
        col_load "`folder'" "`part' - Caracter*Personas*.`ext'"
        rename *, lower
        tostring directorio, gen(directorio_str)
        gen hh_id = directorio_str + "`y'" + "`m'" + "0`i'"
        gen year = `y'
        gen month = "`m'"
        gen urban = ("`part'" != "Resto")
        cap tostring dpto, replace
        keep $var_raw_col
        save "../../bld/data/COL/`y'_`m'_0`i'", replace
    }
end

foreach y in 2015 2016 2017 2018 2019 {
    foreach m in 01 02 03 04 05 06 07 08 09 10 11 12 {
        col_month `y' `m'
    }
}


clear

foreach y in 2015 2016 2017 2018 2019{
    foreach m in 01 02 03 04 05 06 07 08 09 10 11 12{ 
		foreach tp in 1 2 3{
			qui append using "../../bld/data/COL/`y'_`m'_0`tp'.dta"
		}
	}
}

replace hh_id="COL" + hh_id

gegen weight_sum = sum(fex_c_2011), by(year)
gen weight_adj=fex_c_2011/weight_sum
replace weight_adj=weight_adj/5
gen pop_2017=48909.839
gen weight_pop=weight_adj*pop_2017

gen world_region=3

replace dpto="05" if dpto=="5"
replace dpto="08" if dpto=="8"
gen region="COL"+dpto

gen age=p6040
gen sex=p6020
gen rel_col=p6050


gen age_0_14=0
replace age_0_14=1 if age>=0 & age<=14
gen age_15_19=0
replace age_15_19=1 if age>=15 & age<=19
gen age_20_64=0
replace age_20_64=1 if age>=20 & age<=64
gen age_65plus=0
replace age_65plus=1 if age>=65 & age!=.

foreach var in age_0_14 age_15_19 age_20_64 age_65plus{
	gegen hh_`var' = sum(`var'), by(hh_id)
	gen hh_`var'_d=.
	replace hh_`var'_d=0 if hh_`var'==0
	replace hh_`var'_d=1 if hh_`var'>0 & hh_`var'!=.
}


keep if rel_col==1 | rel_col==2

gen count_obs=1
gegen count_s = total(count_obs), by(hh_id)
keep if count_s==1 | count_s==2

gegen min_age = min(age), by(hh_id)
gegen max_age = max(age), by(hh_id)

gen single=0
replace single=1 if count_s==1

gegen mean_sex = mean(sex), by(hh_id)
cap drop couple_type
gen couple_type=.
replace couple_type=1 if mean_sex==1.5
replace couple_type=2 if mean_sex==1
replace couple_type=3 if mean_sex==2
replace couple_type=. if single==1
label val couple_type ssh_lab

preserve
keep if min_age>=65 & max_age<=99
keep if urban==1
keep if single==0
gen couple_type2=0
replace couple_type2=1 if couple_type==2 | couple_type==3
gcollapse couple_type2 [aweight=weight_pop], by(year)
gen country = "COL"
rename couple_type2 couple_type2_65plus
save  "../../bld/data/counts/COL_ssh_obs_yrs_old_age_shares.dta", replace
restore


keep if min_age>=20 & max_age<=64

gcollapse (mean) world_region pop_2017 year single couple_type  urban hh_age* (sum) weight_adj weight_pop, by(hh_id region)

foreach var in weight_adj weight_pop{
	rename `var' `var'_hh
}

gen country_id="COL"

save "../../bld/data/data_countries/data_hh_COL.dta", replace


clear

foreach y in 2015 2016 2017 2018 2019{
    foreach m in 01 02 03 04 05 06 07 08 09 10 11 12{ 
		foreach tp in 1 2 3{
			qui append using "../../bld/data/COL/`y'_`m'_0`tp'.dta"
		}
	}
}

replace hh_id = "COL"+hh_id
gen age=p6040
gen sex=p6020
gen rel_col=p6050
gegen weight_sum = sum(fex_c_2011), by(year)
gen weight_adj=fex_c_2011/weight_sum
replace weight_adj=weight_adj/5
drop weight_sum

keep if rel_col==1 | rel_col==2
merge m:1 hh_id using "../../bld/data/data_countries/data_hh_COL.dta", nogen
gen weight_pop=weight_adj*pop_2017
keep if single==0



gen edu_lvl=.
replace edu_lvl=1 if p6210>=1 & p6210<=4
replace edu_lvl=2 if p6210==5
replace edu_lvl=3 if p6210==6

gen edu_secondary=.
replace edu_secondary=1 if edu_lvl==2
replace edu_secondary=0 if edu_lvl==1 | edu_lvl==3

gen edu_tertiary=.
replace edu_tertiary=1 if edu_lvl==3
replace edu_tertiary=0 if edu_lvl==1 | edu_lvl==2

gen miss_any=0
replace miss_any=1 if region=="" | edu_lvl==.  | weight_pop==. | weight_pop==0
gegen miss_sum = total(miss_any), by(hh_id)
keep if miss_sum==0


keep hh_id country_id world_region pop_2017 year single couple_type region urban hh_age* weight_adj* weight_pop* sex age edu_lvl edu_secondary edu_tertiary

save "../../bld/data/data_countries/data_individual_COL.dta", replace







use "$raw_data/MEX/ipumsi_00052.dta", clear


keep if  inlist(geo1_mx, 484009,484023,484005,484008, 484018,484014) | inlist(geo1_mx, 484004, 484006, 484016, 484017, 484002)

tostring(serial), gen(serial_str)
tostring(sample), gen(sample_str)

gen hh_id="MEX"+serial_str+sample_str

gen quarter = substr(sample_str,-1,.)
destring quarter, replace

gen world_region=3
gegen weight_sum = sum(perwt), by(year)
gen weight_adj=perwt/weight_sum
replace weight_adj=weight_adj/5
gen pop_2017=38097.315
gen weight_pop=weight_adj*pop_2017

tostring geo1_mx, gen(region_str)
gen region="MEX"+region_str

gen urb_temp=.
replace urb_temp=0 if urban==1
replace urb_temp=1 if urban==2
drop urban
gen urban=urb_temp


gen age_0_14=0
replace age_0_14=1 if age>=0 & age<=14
gen age_15_19=0
replace age_15_19=1 if age>=15 & age<=19
gen age_20_64=0
replace age_20_64=1 if age>=20 & age<=64
gen age_65plus=0
replace age_65plus=1 if age>=65 & age!=.

foreach var in age_0_14 age_15_19 age_20_64 age_65plus{
	gegen hh_`var' = sum(`var'), by(hh_id)
	gen hh_`var'_d=.
	replace hh_`var'_d=0 if hh_`var'==0
	replace hh_`var'_d=1 if hh_`var'>0 & hh_`var'!=.
}


keep if sex==1 | sex==2

keep if related==1000 | related==2000 | related==2200

gen count_obs=1
gegen count_s = total(count_obs), by(hh_id)
keep if count_s==1 | count_s==2

gegen min_age = min(age), by(hh_id)
gegen max_age = max(age), by(hh_id)



gen single=0
replace single=1 if count_s==1

gegen mean_sex = mean(sex), by(hh_id)

cap drop couple_type
gen couple_type=.
replace couple_type=1 if mean_sex==1.5
replace couple_type=2 if mean_sex==1
replace couple_type=3 if mean_sex==2
replace couple_type=. if single==1
label val couple_type ssh_lab	


preserve
keep if  min_age>=65 &  max_age<=99
keep if urban==1	
keep if single==0
gen couple_type2=0
replace couple_type2=1 if couple_type==2 | couple_type==3
gcollapse couple_type2 [aweight=weight_pop], by(year)
gen country = "MEX"
rename couple_type2 couple_type2_65plus
save "../../bld/data/counts/MEX_ssh_obs_yrs_old_age_shares.dta", replace
restore


keep if min_age>=20 & max_age<=64

gcollapse (mean) quarter world_region pop_2017 year single couple_type  urban hh_age* (sum) weight_adj weight_pop, by(hh_id region)

foreach var in weight_adj weight_pop{
	rename `var' `var'_hh
}

gen country_id="MEX"

save "../../bld/data/data_countries/data_hh_MEX.dta", replace


use "$raw_data/MEX/ipumsi_00052.dta", clear


keep if  inlist(geo1_mx, 484009,484023,484005,484008, 484018,484014) | inlist(geo1_mx, 484004, 484006, 484016, 484017, 484002)

tostring(serial), gen(serial_str)
tostring(sample), gen(sample_str)

gen hh_id="MEX"+serial_str+sample_str

gegen weight_sum = sum(perwt), by(year)
gen weight_adj=perwt/weight_sum
replace weight_adj=weight_adj/5
drop weight_sum


keep if related==1000 | related==2000 | related==2200

drop urban

merge m:1 hh_id using "../../bld/data/data_countries/data_hh_MEX.dta", nogen
gen weight_pop=weight_adj*pop_2017
keep if single==0

gen edu_lvl=.
replace edu_lvl=1 if edattain==1 | edattain==2
replace edu_lvl=2 if edattain==3
replace edu_lvl=3 if edattain==4

gen edu_secondary=.
replace edu_secondary=1 if edu_lvl==2
replace edu_secondary=0 if edu_lvl==1 | edu_lvl==3

gen edu_tertiary=.
replace edu_tertiary=1 if edu_lvl==3
replace edu_tertiary=0 if edu_lvl==1 | edu_lvl==2

gen labor_force=.
replace labor_force=1 if empstat==1 | empstat==2
replace labor_force=0 if empstat==3

gen unemp=.
replace unemp=1 if empstat==2
replace unemp=0 if empstat==1

gen employed=.
replace employed=0 if empstat==3 | empstat==2
replace employed=1 if empstat==1

gen lab_status=empstat

gen miss_any=0
replace miss_any=1 if region=="" | edu_lvl==. | lab_status==. | weight_pop==. | weight_pop==0
gegen miss_sum = total(miss_any), by(hh_id)
keep if miss_sum==0

keep hh_id quarter country_id world_region pop_2017 year single couple_type region urban hh_age* weight_adj* weight_pop* sex age edu_lvl edu_secondary edu_tertiary lab_status labor_force employed unemp

save "../../bld/data/data_countries/data_individual_MEX.dta", replace




foreach y in 2015 2016 2017 2018 2019{
	import spss using "$raw_data/URY/HyP_`y'_Terceros.sav", clear
	gen sex=e26
	gen age=e27
	gen year=`y'
	gen hh_id=numero
	gen rel_ury=e30
	gen month=mes
	gen quarter=.
	replace quarter=1 if month>=1 & month<=3
	replace quarter=2 if month>=4 & month<=6
	replace quarter=3 if month>=7 & month<=9
	replace quarter=4 if month>=10 & month<=12


	save "../../bld/data/URY/`y'.dta", replace
}

clear

foreach y in 2015 2016 2017 2018 2019{
	append using "../../bld/data/URY/`y'.dta"
}

replace hh_id = "URY"+hh_id

gen world_region=3
gen wght=1
gegen weight_sum = sum(wght), by(year)
gen weight_adj=wght/weight_sum
replace weight_adj=weight_adj/5
gen pop_2017=3436.645
gen weight_pop=weight_adj*pop_2017

gen region=estred13
replace region=1 if region>=1 & region<=6
tostring region, gen(region_str)
drop region
gen region = "URY"+region_str

gen urban=.
replace urban=0 if region_4==4
replace urban=1 if region_4>=1 & region_4<=3


gen age_0_14=0
replace age_0_14=1 if age>=0 & age<=14
gen age_15_19=0
replace age_15_19=1 if age>=15 & age<=19
gen age_20_64=0
replace age_20_64=1 if age>=20 & age<=64
gen age_65plus=0
replace age_65plus=1 if age>=65 & age!=.

gen age_0_14_nonch=0
replace age_0_14_nonch=1 if age>=0 & age<=14 & rel_ury!=3 & rel_ury!=4 & rel_ury!=5

foreach var in age_0_14 age_15_19 age_20_64 age_65plus{
	gegen hh_`var' = sum(`var'), by(hh_id)
	gen hh_`var'_d=.
	replace hh_`var'_d=0 if hh_`var'==0
	replace hh_`var'_d=1 if hh_`var'>0 & hh_`var'!=.
}

gegen hh_age_0_14_nonch_d = max(age_0_14_nonch), by(hh_id)

gen age_temp_x=.
replace age_temp_x=age if rel_ury>=3 & rel_ury<=5
gegen age_ch_oldest = max(age_temp_x), by(hh_id)
drop age_temp_x

preserve
	
keep if age_0_14==1
keep hh_id rel_ury 
gen relation_child = .
replace relation_child=1 if rel_ury>=3 & rel_ury<=5
replace relation_child=2 if inlist(rel_ury,7,9,11,12)
replace relation_child=3 if inlist(rel_ury,6,8,10,13,14)
	
save "../../bld/data/URY/data_under15_URY.dta", replace
	
restore


preserve

keep if e33==1
keep if urban==1
keep if age>=20 & age<=64
gen COUNTRY="URY"
gen relation=0
replace relation=1 if rel_ury==1 | rel_ury==2 
gcollapse relation [aweight=weight_adj], by(COUNTRY)
* Figure D.3 input
save "../../bld/data/descriptives/hh_head_all_couples/hh_head_all_couples_URY.dta", replace

restore



keep if rel_ury==1 | rel_ury==2 

gen count_obs=1
gegen count_s = total(count_obs), by(hh_id)
keep if count_s==1 | count_s==2

gegen min_age = min(age), by(hh_id)
gegen max_age = max(age), by(hh_id)



gen single=0
replace single=1 if count_s==1

gegen mean_sex = mean(sex), by(hh_id)

cap drop couple_type
gen couple_type=.
replace couple_type=1 if mean_sex==1.5
replace couple_type=2 if mean_sex==1
replace couple_type=3 if mean_sex==2
replace couple_type=. if single==1
label val couple_type ssh_lab	

preserve
keep if  min_age>=65 &  max_age<=99
keep if urban==1
keep if single==0	
gen couple_type2=0
replace couple_type2=1 if couple_type==2 | couple_type==3
gcollapse couple_type2 [aweight=weight_pop], by(year)
gen country = "URY"
rename couple_type2 couple_type2_65plus
save "../../bld/data/counts/URY_ssh_obs_yrs_old_age_shares.dta", replace
restore

preserve 
gen old_age=.
replace old_age=0 if min_age>=20 & max_age<=64
replace old_age=1 if min_age>=65 & max_age<=99
keep if old_age!=.
keep if urban==1
keep if single==0

keep if e35>=2 & e35<=7
gen couple_type2=0
replace couple_type2=1 if (couple_type==2 | couple_type==3) & (e35==3 | e35==5 | e35==7)

gcollapse couple_type2 [aweight=weight_pop], by(old_age)
gen COUNTRY = "URY"
reshape wide couple_type2, i(COUNTRY)  j(old_age)
* Figure D.8 input
save "../../bld/data/descriptives/URY_ssc_old_young_shares.dta", replace
restore



keep if min_age>=20 & max_age<=64

cap drop ssm_direct
cap drop ssm_rel_x
gen ssm_rel_x=0
replace ssm_rel_x=1 if e35==5 | e35==7 | e35==3
gegen ssm_direct=min(ssm_rel_x), by(hh_id)
replace ssm_direct=. if year==2015

cap drop foreign_bp_any
cap drop foreign_bp
gen foreign_bp=0
replace foreign_bp=1 if e37==4
gegen foreign_bp_any=max(foreign_bp), by(hh_id)

cap drop married_couple
cap drop married_x
gen married_x=0
replace married_x=1 if e35==1 | e35==4 | e35==5 | e37==3
gegen married_couple=min(married_x), by(hh_id)

gcollapse (mean) world_region pop_2017 year quarter single couple_type  urban hh_age* ssm_direct married_couple foreign_bp_any age_ch_oldest (sum) weight_adj weight_pop, by(hh_id region)

foreach var in weight_adj weight_pop{
	rename `var' `var'_hh
}

gen country_id="URY"

save "../../bld/data/data_countries/data_hh_URY.dta", replace


clear

foreach y in 2015 2016 2017 2018 2019{
	append using "../../bld/data/URY/`y'.dta"
}

replace hh_id = "URY"+hh_id

gen wgt=1
gegen weight_sum = sum(wgt), by(year)
gen weight_adj=wgt/weight_sum
replace weight_adj=weight_adj/5
drop weight_sum

keep if rel_ury==1 | rel_ury==2 

merge m:1 hh_id using "../../bld/data/data_countries/data_hh_URY.dta", nogen
gen weight_pop=weight_adj*pop_2017
keep if single==0

gen edu_lvl=.
replace edu_lvl=1 if e197==1 | e197==2  | e197==3
replace edu_lvl=2 if e201==2 | e212==2 | e215==1 | e218==1 | e221==1 | e224==1
replace edu_lvl=3 if e215==2 | e218==2 | e221==2 | e224==2
gen edu_secondary=.
replace edu_secondary=1 if edu_lvl==2
replace edu_secondary=0 if edu_lvl==1 | edu_lvl==3

gen edu_tertiary=.
replace edu_tertiary=1 if edu_lvl==3
replace edu_tertiary=0 if edu_lvl==1 | edu_lvl==2

gen foreign_bp=0
replace foreign_bp=1 if e37==4

gen race_white=0
replace race_white=1 if e29_6==3

gen emp=.
replace emp=1 if year==2019 &  (f269==1 | f270==1 | f273==1)
replace emp=1 if year>=2015 & year<=2018 &  (f66==1 | f67==1 | f68==1)

gen unemp=.
replace unemp=1 if f106==1 & f107==1
replace unemp=0 if emp==1
gen labor_force=0
replace labor_force=1 if emp==1 | unemp==1
gen employed=0
replace employed=1 if emp==1
gen lab_status=.
replace lab_status=1 if employed==1
replace lab_status=2 if unemp==1
replace lab_status=3 if labor_force==0



gen exch_rate_2015=41.430

gen inflation=.
qui replace inflation = 1.501 if year==2015
qui replace inflation = 1.646 if year==2016
qui replace inflation = 1.748 if year==2017
qui replace inflation = 1.881 if year==2018
qui replace inflation = 2.029 if year==2019

replace inflation = inflation/1.501	

egen incwage=rowtotal(g126_1 g126_2 g126_3 g126_4 g126_5 g126_6 g126_7 g134_1 g134_2 g134_3 g134_4 g134_5 g134_6 g134_7)
replace incwage=12*incwage
gen incwage_inf=incwage/inflation
replace incwage_inf=incwage_inf/exch_rate_2015

replace incwage_inf=0 if employed!=1

gen hours_worked=f85+f98
gen hwyear=52*hours_worked

qui gen hwage = incwage_inf / hwyear
replace hwage=. if hwage==0
_pctile hwage, percentiles(99.75)
replace hwage=r(r1) if hwage>=r(r1) & hwage!=.
_pctile hwage, percentiles(1)
replace hwage=r(r1) if hwage<=r(r1) & hwage!=.

gen ln_hwage = ln(hwage)

gen earnings_wage = incwage_inf/12
_pctile earnings_wage, percentiles(99.75)
replace earnings_wage=r(r1) if earnings_wage>=r(r1)

gen earnings_bus = g142/(inflation*exch_rate_2015)
_pctile earnings_bus, percentiles(99.75)
replace earnings_bus=r(r1) if earnings_bus>=r(r1)

gen earnings_all = incwage_inf/12 + (g142/(inflation*exch_rate_2015))
_pctile earnings_all, percentiles(99.75)
replace earnings_all=r(r1) if earnings_all>=r(r1)  & earnings_all!=.

foreach var in earnings_all earnings_bus earnings_wage{
		replace `var'=0 if employed!=1
}

	
cap drop selfemp
gen selfemp=.
replace selfemp=0 if f73>=1 &  f73<=3 & employed==1
replace selfemp=1 if f73>=4 &  f73<=6 & employed==1

gen informal_emp=.
replace informal_emp=1 if employed==1 & (f268==2 | f263==2)
replace informal_emp=0 if employed==1 & informal_emp==.

destring f71_2, replace
gen isco_3d = floor(f71_2/10)
merge m:1 isco_3d using "../../bld/data/unempl_rates_eu_lfs.dta"
drop if _merge==2
drop _merge


gen miss_any=0
replace miss_any=1 if region=="" | edu_lvl==. | lab_status==. | weight_pop==. | weight_pop==0
gegen miss_sum = total(miss_any), by(hh_id)
keep if miss_sum==0

keep hh_id country_id world_region pop_2017 year quarter single couple_type region age_ch_oldest urban ssm_direct married_couple foreign_bp_any race_white hh_age* weight_adj* weight_pop* sex age edu_lvl edu_secondary edu_tertiary foreign_bp lab_status labor_force employed unemp hours_worked hwage ln_hwage earnings_bus earnings_wage earnings_all selfemp informal_emp isco_3d unemp_occ_risk

save "../../bld/data/data_countries/data_individual_URY.dta", replace




clear
use "../../bld/data/URY/data_under15_URY.dta"

merge m:1 hh_id using "../../bld/data/data_countries/data_hh_URY.dta"
keep if _merge==3
keep if single==0
gen COUNTRY=country_id
tabulate relation_child, generate(rel_ch)
gcollapse rel_ch* [aweight=weight_pop], by(COUNTRY couple_type)

rename rel_ch1 child
rename rel_ch2 other_relative
rename rel_ch3 other_non_relative
keep COUNTRY couple_type child other_relative other_non_relative
* Table A.11 input
save "../../bld/data/descriptives/under_15/under_15_couple_type_URY.dta", replace
