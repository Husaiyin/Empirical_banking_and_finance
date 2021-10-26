clear all
set more off
cd "C:\Users\Konrad\Dropbox\Postdoc\Teaching Empirical Banking\Tutorials\"


use "Tutorial 4/dataEmpBF_Tutorial4", replace


*---------------------------------------
// 1 DATA & Descriptives
*---------------------------------------
xtset  CountryCode year

summarize _all

*gen check = household_credit + firm_credit
*gen diff = abs(private_credit-check)

twoway (scatter logGDP_future private_credit_past) (lfit logGDP_future private_credit_past)

corr logGDP_future private_credit_past 

line private_credit year, by(c)

* variable definition
*gen logGDP_future = (f3.logGDP - logGDP)*100
*gen private_credit_past = l1.private_credit - l4.private_credit

*---------------------------------------
// 2 Regression 1: FE mechanics
*---------------------------------------

* Basic fixed effects
reghdfe logGDP_future private_credit_past, absorb(CountryCode) 
reg logGDP_future private_credit_past i.CountryCode, beta  // size



* Dummy regression
reg logGDP_future private_credit_past i.CountryCode

* to get exactly the same coefficent!
gen insample = e(sample)
keep if insample 

* De-mean regression
bys CountryCode: egen logGDP_future_mean = mean(logGDP_future)
bys CountryCode: egen private_credit_past_mean = mean(private_credit_past)

gen logGDP_future_demeaned = logGDP_future - logGDP_future_mean
gen private_credit_past_demeaned =  private_credit_past - private_credit_past_mean

reg logGDP_future_demeaned private_credit_past_demeaned





*---------------------------------------
// 2 Regression 2: clustering
*---------------------------------------

reghdfe logGDP_future private_credit_past, absorb(CountryCode) 
est store reg1

reghdfe logGDP_future private_credit_past, absorb(CountryCode)  vce(robust)
est store reg2

reghdfe logGDP_future private_credit_past, absorb(CountryCode)  vce(cluster CountryCode)
est store reg3

reghdfe logGDP_future private_credit_past, absorb(CountryCode) vce(cluster CountryCode year)
est store reg4

esttab reg1 reg2 reg3 reg4, se 

* wrong clustering
reghdfe logGDP_future private_credit_past, absorb(CountryCode) vce(cluster CountryCode#year)
est store reg5

esttab reg*, se 

* note: if you use xtreg: 
xtreg logGDP_future private_credit_past, fe  vce(robust) // gives you clustered s. e. !




*---------------------------------------
// 3 Regression 3: replicating Mian & Sufi
*---------------------------------------

* column 2
reghdfe logGDP_future household_credit_past, absorb(CountryCode) vce(cluster CountryCode year)
* to get s.e. as in the paper: 
xtivreg2 logGDP_future household_credit_past, fe cluster( CountryCode year)

est store regx1

* column 3
reghdfe logGDP_future firm_credit_past, absorb(CountryCode) vce(cluster CountryCode year)
est store regx2

* column 4
reghdfe logGDP_future household_credit_past firm_credit_past, absorb(CountryCode) vce(cluster CountryCode year)
est store regx3

test household_credit_past = firm_credit_past

esttab regx*





* year FE
reghdfe logGDP_future household_credit_past firm_credit_past, absorb(CountryCode year) vce(cluster CountryCode year)









*----------------------------------------------



* economic disasters  detail
summarize logGDP_future, detail 

gen disaster = 0
replace disaster = 1 if logGDP_future <= -8.342

tab disaster if logGDP_future!=.

tostring year, gen(yearString)
gen id = c + "_"+ yearString
tab id if disaster ==1

* strong increases in credit to GDP
hist private_credit_past
summarize private_credit_past, detail

gen strongCreditIncr = 0
replace strongCreditIncr = 1 if private_credit_past > 54.3

tab id if strongCreditIncr ==1


*------------------------------------
// 
qui: reghdfe logGDP_future private_credit_past, absorb(CountryCode year) vce(cluster CountryCode)
est store reg1clusterYearFE

qui: reghdfe logGDP_future private_credit_past, absorb(CountryCode year) vce(cluster CountryCode year)
est store reg2clusterYearFE

qui: reghdfe logGDP_future private_credit_past, absorb(CountryCode ) vce(cluster CountryCode)
est store reg1cluster

qui: reghdfe logGDP_future private_credit_past, absorb(CountryCode ) vce(cluster CountryCode year)
est store reg2cluster


esttab reg1clusterYearFE reg2clusterYearFE reg1cluster reg2cluster, se 
