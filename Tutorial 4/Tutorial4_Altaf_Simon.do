// Set working directory
cd "Y:\Downloads"
// install additional packages
ssc install estout, replace
ssc install reghdfe, replace
ssc install ftools, replace
// load data
use "Y:\Downloads\dataEmpBF_Tutorial4.dta"
// Task 1a
estpost summarize  // should delete observations with NAs
esttab using sumr.tex, cells("count mean sd min max") noobs
// Task 1b
twoway scatter logGDP_future private_credit_past ///
|| lfit logGDP_future private_credit_past 
corr logGDP_future private_credit_past
// Task 2a
reghdfe logGDP_future private_credit_past, a(c)
est sto m1
esttab m1 using reg1.tex, se obslast scalar(F) r2 ///
title("Regression 1") replace
// Task 2b
reg logGDP_future private_credit_past i.CountryCode, robust 
est sto m2
esttab m2 using reg2.tex, se obslast scalar(F) r2 ///
title("Regression 2") replace
// Task 2c
by c, sort : summarize logGDP_future private_credit_past
foreach i in logGDP_future private_credit_past{
egen mean_`i'=mean(`i'), by(c)
ge demeaned_`i'=`i'-mean_`i'
}
reg demeaned_logGDP_future demeaned_private_credit_past, robust
est sto m3
esttab m3 using reg3.tex, se obslast scalar(F) r2 ///
title("Regression 3") replace
// Task 3a
reghdfe logGDP_future private_credit_past, a(c) //i
est sto d1
reghdfe logGDP_future private_credit_past, a(c) vce(r) //ii
//  Warning: in a FE panel regression, using robust will lead to
//         inconsistent standard errors if for every fixed effect, the other
//         dimension is fixed.  For instance, in an standard panel with
//         individual and time fixed effects, we require both the number of
//         individuals and time periods to grow asymptotically.  If that is not
//         the case, an alternative may be to use clustered errors, which as
//         discussed below will still have their own asymptotic requirements.
//         For a discussion, see Stock and Watson, "Heteroskedasticity-robust
//         standard errors for fixed-effects panel-data regression,"
//         Econometrica 76 (2008): 155-174
est sto d2
reghdfe logGDP_future private_credit_past, a(c) vce(cluster c) //iii
est sto d3
reghdfe logGDP_future private_credit_past, a(c) vce(cluster c year) //iv
est sto d4
esttab d1 d2 d3 d4 using reg4.tex, se obslast scalar(F) r2 ///
title("Regression 4") replace
// Task 4a
reghdfe logGDP_future household_credit_past, ///
a(c) vce(cluster c year) // HH
est sto f1
reghdfe logGDP_future firm_credit_past, ///
a(c) vce(cluster c year) // Firm
est sto f2
reghdfe logGDP_future household_credit_past firm_credit_past, ///
a(c) vce(cluster c year) // Firm and HH
est sto f3
reghdfe logGDP_future household_credit_past firm_credit_past, ///
a(c year) vce(cluster c year) // Firm and HH and additional year FE
est sto f4
esttab f1 f2 f3 f4 using reg4.tex, se obslast scalar(F) r2 ///
title("Regression 5") replace
// Task 4b
reghdfe logGDP_future household_credit_past firm_credit_past, ///
a(c) vce(cluster c year) // Firm and HH
test firm_credit_past==household_credit_past
// Task 4c
reghdfe logGDP_future household_credit_past firm_credit_past, a(c year) ///
vce(cluster c year) // Firm and HH and additional year FE



