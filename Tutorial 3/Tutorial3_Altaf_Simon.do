// load data and set WD
cd "Z:\Downloads"
use dataEmpBF_Tutorial3.dta
// creating scatterplot and simple regressionline for gdpgrowth and private_credit_1960
twoway scatter gdpgrowth private_credit_1960 || lfit gdpgrowth private_credit_1960
// regression of gdpgrowth on private_credit_1960 with loggdp_1960 as a control var
reg gdpgrowth private_credit_1960 loggdp_1960, robust
// check correlations
corr private_credit_1960 loggdp_1960
// summary statisctics for variables related to legal o.
su leg*
// mean private_credit_1960 for all legal o.
ssc install coefplot, replace
quietly: reg private_credit_1960 legor_*, nocons
coefplot
// Regression 2
ivregress 2sls gdpgrowth loggdp_1960 (private_credit_1960 = legor_ge), vce(robust)
// summary statistics of first stage regression
estat firststage
// endogenity test, was the IV really necessary?
estat endog
// test for over identification
estat overid
// Regression 3
ivregress 2sls gdpgrowth loggdp_1960 (private_credit_1960 = legor_uk legor_fr legor_so legor_ge), vce(robust)
// summary statistics of first stage regression
estat firststage
// endogenity test, was the IV really necessary?
estat endog
// test for over identification
estat overid
// Regression 4
ivregress 2sls gdpgrowth loggdp_1960 (private_credit_1960 public_banks_1970 = legor_uk legor_fr legor_so legor_ge), vce(robust)
// summary statistics of first stage regressions
estat firststage
// endogenity test, was the IV really necessary?
estat endog
// test for over identification
estat overid
// Regression 5
reg gdpgrowth private_credit_1960 loggdp_1960 legor_uk legor_fr legor_so legor_ge, robust

// check again tasks 4e) and 5f)

ssc install ranktest 
ssc install ivreg2
ivreg2 gdpgrowth loggdp_1960 (private_credit_1960 = legor_ge), robust
ivreg2 gdpgrowth loggdp_1960 (private_credit_1960 = legor_uk legor_fr legor_so legor_ge), robust

