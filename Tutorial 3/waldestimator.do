clear all
set more off
cd "C:\Users\Konrad\Dropbox\Postdoc\Teaching Empirical Banking\Tutorials\Tutorial 3\"


use "dataEmpBF_Tutorial3", replace


// NOTE: no covariate in these regressions for simplicity

*------------------------------------------
// ONE DUMMY VARIABLE IV ONLY
*------------------------------------------
ivreg2  gdpgrowth  (private_credit_1960 = legor_fr ), robust

* first stage 
reg private_credit_1960 legor_fr, robust
predict yhat_fr, xb
scatter yhat_fr private_credit_1960
bys legor_fr: summarize private_credit_1960 

* second stage 
reg gdpgrowth yhat_fr, robust  // wrong standard erros, but same coefficient



*------------------------------------------
// SEVERAL DUMMY VARIABLES IV
*------------------------------------------

ivreg2  gdpgrowth  (private_credit_1960 = legor_uk legor_fr legor_so legor_ge ), robust

* first stage 
reg private_credit_1960 legor_uk legor_fr legor_so legor_ge, robust
predict yhat_all, xb
scatter yhat_all private_credit_1960

bys legor: summarize private_credit_1960 






*------------------------------------------
// AVERAGES BY LEGAL ORIGIN
*------------------------------------------

global legal  legor_uk legor_fr legor_so legor_ge legor_sc

foreach v of global legal {
	preserve 
	
	reg private_credit_1960 `v'
	gen obs = 1

	collapse (sum)  obs (mean) gdpgrowth  private_credit_1960, by(`v')
	gen id = 1
	reshape wide gdpgrowth  private_credit_1960 obs , j(`v') i(id)
	gen name = "`v'"
	save temp/`v', replace
	restore 

}

drop _all

foreach v of global legal {
	append using temp/`v'
}


*------------------------------------------
// COMPUTE IV ESTIMATORS
*------------------------------------------

// the Wald estimators	
gen wald = (gdpgrowth1 - gdpgrowth0)/(private_credit_19601- private_credit_19600)

gen numerator = gdpgrowth1 - gdpgrowth0
gen denominator = private_credit_19601- private_credit_19600


// Constructing 2SLS by aggregating IV estimates
twoway (scatter gdpgrowth1 private_credit_19601,mlabel(name)) (lfit gdpgrowth1 private_credit_19601)
graph export iv_group_data.pdf

reg gdpgrowth1 private_credit_19601 [weight = obs1] // exactly the same!