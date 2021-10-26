clear all
set more off
cd "C:\Users\Konrad\Dropbox\Postdoc\Teaching Empirical Banking\Tutorials\"


use "Tutorial 5/dataEmpBF_Tutorial5", replace

xtset  state year

*-------------------------------------
// Data & Descriptives
*-------------------------------------

* deregulation year dummy

* distribution of deregulation events over time
hist year if ind_deregYear ==1, discrete
tab year if ind_deregYear ==1

* pre-trend plot
*- not possible because of the staggered introduction

*-------------------------------------
// Replicate Paper Result
*-------------------------------------

reghdfe GDPgr i.ind_dereg if ind_deregYear==0,   absorb(state year) vce(robust)

// Clustered S.E.
reghdfe GDPgr  i.ind_dereg if ind_deregYear==0,   absorb(state year) vce(cluster  state)
reghdfe GDPgr  i.ind_dereg if ind_deregYear==0,   absorb(state year) vce(cluster year state)




*-------------------------------------
// Granger causality
*-------------------------------------

reghdfe GDPgr l(0/2).ind_dereg f(1/2).ind_dereg, absorb(state year) vce(robust)



gen ind_dereg1 = f2.ind_dereg
gen ind_dereg2 = f1.ind_dereg
gen ind_dereg3 = ind_dereg
gen ind_dereg4 = l1.ind_dereg
gen ind_dereg5 = l2.ind_dereg

reghdfe GDPgr ind_dereg1 ind_dereg2 ind_dereg3 ind_dereg4 ind_dereg5, absorb(state year) vce(robust)

coefplot,  drop(_cons)   vertical   yline(0) ci(95)





* this is different: event study
reghdfe GDPgr l(0/2).ind_deregYear f(1/2).ind_deregYear ///
, absorb(state year) vce(robust)


*-------------------------------------
// State specific Time trend
*-------------------------------------

reghdfe GDPgr c.year#i.state i.ind_dereg if ind_deregYear==0,   absorb(state year) vce(robust)



*-------------------------------------
// Region-Year FE
*-------------------------------------

reghdfe GDPgr  i.ind_dereg if ind_deregYear==0 & region!=0,   absorb(state year region#year) vce(robust)

reghdfe GDPgr  i.ind_dereg if ind_deregYear==0 & region!=0,   absorb(state  region#year) vce(robust)

* gives the same result ! 

reghdfe GDPgr  i.ind_dereg if ind_deregYear==0 & region!=0,   absorb(state year i.region#i.year) vce(robust)



































