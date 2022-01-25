// Set working directory
cd "Y:\Downloads"
// install additional packages
ssc install estout, replace
ssc install reghdfe, replace
ssc install ftools, replace
// load data
use "Y:\Downloads\dataEmpBF_Tutorial5.dta"
// Task 2
estpost summarize  
esttab using sumr.tex, cells("count mean sd min max") noobs
// Task 2b
ge dereg_year=ind_deregYear*year
histogram dereg_year if dereg_year>0, bin(15) percent ///
ytitle(Percent share of those who lifted restrictions (after 1972)) ///
xtitle(Year of deregulation)
// Task 3a
drop if dereg_year>0 
reghdfe GDPgr ind_dereg, a(state year) vce(r)
est sto m1
// Task 3d
reghdfe GDPgr ind_dereg, a(state year) vce(cluster state year)
est sto m2
esttab m1 m2 using reg1.tex, se obslast scalar(F) r2 ///
title("Regression 1") replace
// Task 4a
use "Y:\Downloads\dataEmpBF_Tutorial5.dta", clear
destring deregulationInfo, g(dereg_year) force
ge lead_helper=dereg_year-2
ge lag_helper=dereg_year+2
ge lead= year==lead_helper & lead_helper>1000
ge lag= year==lag_helper & lead_helper>1000
reghdfe GDPgr ind_dereg ind_deregYear lead lag, a(state year) ///
vce(cluster state year)
est sto m3
esttab m3 using reg2.tex, se obslast scalar(F) r2 ///
title("Regression 2") replace
drop if ind_deregYear>0
// Task 5a
levelsof state, local(levels) 
foreach i of local levels{
ge d_`i'=state==`i'
ge trend_`i'=d_`i'*year
}
reghdfe GDPgr ind_dereg trend*, a(state year) vce(cluster state year)
est sto m4
esttab m4 using reg3.tex, se obslast scalar(F) r2 ///
title("Regression 3") replace
// Task 6a
drop if region==0
reghdfe GDPgr ind_dereg, a(state year region#year) vce(cluster state year)
est sto m5
esttab m5 using reg4.tex, se obslast scalar(F) r2 ///
title("Regression 4") replace
// task 7
use "Y:\Downloads\dataEmpBF_Tutorial5.dta", clear
drop if ind_dereg==1
destring deregulationInfo, replace force
bysort deregulationInfo year: egen gr_avg=mean(GDPgr)
sort deregulationInfo year
quietly by deregulationInfo year:  gen dup = cond(_N==1,0,_n)
drop if dup>1
levelsof deregulationInfo, local(levels) 
foreach i of local levels{
ge till_`i'=gr_avg if deregulationInfo==`i'
}
line till* year
