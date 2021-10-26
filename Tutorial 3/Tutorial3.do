clear all
set more off
cd "C:\Users\Konrad\Dropbox\Postdoc\Teaching Empirical Banking\Tutorials\"


use "Tutorial 3/dataEmpBF_Tutorial3", replace





*--------------------------------------------------
// 2)  Regression 1: OLS 
*--------------------------------------------------

* a) 
twoway (scatter gdpgrowth private_credit_1960 ) (lfit gdpgrowth private_credit_1960 )

* b) 
reg gdpgrowth private_credit_1960 loggdp_1960 , robust

* c)
corr private_credit_1960 loggdp_1960
corr gdpgrowth loggdp_1960

* d) Beta coefficients to get the economic size
reg gdpgrowth private_credit_1960 loggdp_1960 , robust beta

est store reg1

*--------------------------------------------------
// 3) The Instrument
*--------------------------------------------------

* d) 
summarize legor_*

* e) 
graph bar private_credit_1960, over(legor)


*--------------------------------------------------
// 2SLS: just one instrument
*--------------------------------------------------

* a) 

*ivregress 2sls gdpgrowth loggdp_1960 (private_credit_1960 = legor_ge loggdp_1960)

ivreg2  gdpgrowth loggdp_1960 (private_credit_1960 = legor_ge loggdp_1960), robust
est store reg2

* b)
esttab reg*


* e) first stage to test the first requirement
reg private_credit_1960  legor_ge loggdp_1960, robust






*--------------------------------------------------
// 2SLS: all instruments
*--------------------------------------------------

* a) 
*ivregress 2sls gdpgrowth loggdp_1960 (private_credit_1960 = legor_* loggdp_1960)
*reg private_credit_1960   legor_uk legor_fr legor_so legor_ge  loggdp_1960
ivreg2  gdpgrowth loggdp_1960 (private_credit_1960 = legor_uk legor_fr legor_so legor_ge loggdp_1960), robust
est store reg3

* here "loggdp_1960" is included automatically in the first stage as well, but don't forget to include it, if you run the first stage manually!
ivreg2  gdpgrowth loggdp_1960 (private_credit_1960 = legor_uk legor_fr legor_so legor_ge ), robust



* Aside: 2SLS by hand *****
reg private_credit_1960  legor_uk legor_fr legor_so legor_ge loggdp_1960, robust
predict yhat, xb
reg gdpgrowth loggdp_1960 yhat

twoway (line private_credit_1960 private_credit_1960) (scatter  yhat private_credit_1960, ytitle("Yhat") mlabel(country_name)) 

* right of 45 degree line: legal origins underpredict  private to credit to GDP
* left of 45 degree line: legal origins overpredict  private to credit to GDP

* This plot shows you the difference between endogenous and exogenous component of private credit to GDP, as predicted by a country's legal origin

* example: China in 1960 has a higer private credit to GDP than what its socialist legal origin would predict
* 		   for the IV we only use the predicted value that is, hopefully, exogenous to other factors affecting GDP 

* c) 
esttab reg*


* f) FIRST REQUIREMENT: strong first stage
reg  private_credit_1960  legor_uk legor_fr legor_so legor_ge loggdp_1960, robust
test (legor_uk=0) (legor_fr=0) (legor_so=0) (legor_ge=0)

* f) SECOND REQUIREMENT: exclusion restriction
// H0 : at least one instrument is not exogenous
*estat overid
* see output of ivreg2: 

* manual version: Sargan statistic (without robust errors)
ivreg2  gdpgrowth loggdp_1960 (private_credit_1960 = legor_uk legor_fr legor_so legor_ge loggdp_1960)
predict residuals, resid
reg residuals legor_uk legor_fr legor_so legor_ge loggdp_1960
* Intuition: the residuals include the endogenous part
* the more the supposedly exogenous variables can account for the variation in the endogenous part, the more likely we have to reject H_0 of all instruments being truly exogenous
local teststat = `e(N)'*`e(r2)'
disp "`teststat'"

* manual version: Hansen J-Statistic (robust errors)
* ->  "the minimized value of the GMM criterion function"
* we will not do that manually 


* h) Test for endogeneity of regressors

//H0 : δ1 = 0: if we can reject, then the variable private credit is endogenous

* (does not work with robust)
ivreg2  gdpgrowth loggdp_1960 (private_credit_1960 = legor_uk legor_fr legor_so legor_ge loggdp_1960)
ivendog
* or (works with robust)
qui: reg  private_credit_1960  legor_uk legor_fr legor_so legor_ge loggdp_1960, robust
predict v, resid
qui: reg gdpgrowth loggdp_1960 private_credit_1960 v, robust 
test v 
* or (works with robust)
ivregress 2sls gdpgrowth loggdp_1960 (private_credit_1960 = legor_uk legor_fr legor_so legor_ge loggdp_1960) , robust
estat endogenous



*--------------------------------------------------
// 2SLS: all instruments & two endogenous variables
*--------------------------------------------------

* a) 
*ivregress 2sls gdpgrowth loggdp_1960 (private_credit_1960 public_banks_1970 = legor_* loggdp_1960)
ivreg2 gdpgrowth loggdp_1960 (private_credit_1960 public_banks_1970 = legor_* loggdp_1960), robust  
est store reg4

betacoef 

esttab reg*


*--------------------------------------------------
// Back to OLS
*--------------------------------------------------

* a) 
reg gdpgrowth loggdp_1960 private_credit_1960  legor_* ,robust













