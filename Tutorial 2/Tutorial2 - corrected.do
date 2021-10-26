clear all
set more off
cd "C:\Users\Konrad\Dropbox\Postdoc\Teaching Empirical Banking\Tutorials\Tutorial 2"

log using empbf_tutorial2, replace text

* A very, very minimal solution

*------------------------------------
// 1. Regression 1
*------------------------------------

*a)
use  dataEmpBF_Tutorial2

*b)
reg gdpgrowth public_banks_1970 loggdp_1960, robust

*c) 

* In table V the relationship is negative, here positive

*------------------------------------
// 2. Descriptive statistics
*------------------------------------

*a) 
summarize _all

*b)
scatter public_banks_1970 gdpgrowth

* c) 
drop if public_banks_1970 > 1
* % cannot be higher than 100

* d)
scatter public_banks_1970 gdpgrowth


*------------------------------------
// 3. Regression 2
*------------------------------------

* a) 
reg gdpgrowth public_banks_1970 loggdp_1960, robust
* ols estimates average effects - the average is sensitive to extreme values

* b) 
* Why not: because they didn't find any data (see lecture)
* Why prefereable: to avoid reverse causality problems, i.e. low growth in the early 1960s might have led to high government share of bank ownership in 1970 and not the other way round. This could be excluded by using 1960 share. 

* c) 
* yes, we can reject the H0 of coefficients being equal to zero for public_banks_1970 at 1%, loggdp_1960 at 5%

* d) 
* public_banks_1970 is negative: the higher the share the government own of banks in 1970, the lower average growth between 1960-1995
* loggdp_1960 is negative: the higher 1960 loggdp, the lower average growth 1960-85. Poorer countries have been catching up - convergence result

* e) 
* The R2 is 12%

*------------------------------------
// 4. Regression 3
*------------------------------------

* a) 
reg gdpgrowth public_banks_1970 loggdp_1960 schooling  birth_rate_1970, robust
* it makes sense to include those variables because they 1) almost certainly matter for gdpgrowth and 2) they are possibly correlated with public_banks_1970. Not including them might create an omitted variable bias

*b) 
* all coefficients are significantly differrent from 0 at 1%, except for schooling which is not significant at any level. 


* c)
* public_banks_1970 and loggdp_1960, same sign, see above
* birth_rate_1970: negative, a higher birth rate in 1970 might lead to lower per capita GDP growth 

* economic size: 
gen insample = e(sample)

su gdpgrowth public_banks_1970 loggdp_1960 birth_rate_1970 if insample==1

* there are many ways to do this: here, I use the "1 standard deviation increase in x leads to a decrease of z standard deviations in gdpgrowth"

* public_banks_1970: (0.35*-0.026)/0.023 = -0.4  sd
* birth_rate_1970: (12.94*-0.00167)/0.023 = -0.932 sd

* different because the rhs variable is in logs: look at a 10% change in loggdp_1960:

* loggdp_1960: (0.1*-0.019)/0.023 = -0.08   sd



* d)

* H0: schooling =0 and  birth_rate_1970=0, HA: either schooling !=0 and/or  birth_rate_1970!=0

test (schooling=0)  (birth_rate_1970=0) 
test schooling  birth_rate_1970 // this way of writing also tests whether the two are jointly equal to zero
* Result: H0 is rejected at 1%. we conclude that the two coefficients are not jointly equal to zero


/*
WRONG:

test schooling = birth_rate_1970

* H0: schooling = birth_rate_1970, HA: schooling != birth_rate_1970
* F-test, F(2,78)

END WRONG
*/


* e) 
* The adjusted R2
* Regression 2: 
qui: reg gdpgrowth public_banks_1970 loggdp_1960, robust
disp e(r2_a) // 10%

qui: reg gdpgrowth public_banks_1970 loggdp_1960 schooling  birth_rate_1970, robust
disp e(r2_a) // 52%





*------------------------------------
// 5. Regression 4
*------------------------------------

* a)
* Section 2 of the article
/* However, the differences between public and private banks should be less pronounced
in well-developed financial systems because public banks benefit from high
standards in the financial sector. Even if incentives are distorted, the manager of a
public bank is more likely to adopt new risk management techniques if they are readily
available at relatively low implementation costs. Likewise, in mature financial systems,
public banks benefit from knowledge inflows through well-trained job-market
candidates and experienced employees from private competitors. Moreover, welldeveloped
financial systems are typically marked by better regulation and prudential
supervision, which tend to eliminate quality differentials between state-owned and
private banks, in particular with regard to risk management techniques. Finally, competition
may be stronger in highly developed financial systems, forcing public banks
to provide a higher intermediation quality. These arguments suggest that the negative
effect of public ownership on economic growth may be expected to be less pronounced
in highly developed financial systems.7
*/

* b)
reg gdpgrowth  loggdp_1960   c.public_banks_1970##c.private_credit_1960, robust

* c)

* the coef "public_banks_1970" by itself tells us the marginal impact of public ownership of banks when private_credit_1960 = 0
su private_credit_1960 // no country has zero private credit / GDP 

* the coef "private_credit_1960" by itself tells us the marginal impact of higher private credit / GDP when public ownership of banks = 0

su public_banks_1970 // there is at least one country with zero public ownership 


* d) 

* we cannot really interpret the sign unless we fix one of the two variables at a certain values

* e) 

* holding all other variables at the mean
margins , dydx(public_banks_1970) atmeans // continuous

* f) 

* at the mean of initial GDP and the entire distribution of private_credit_1960
margins , dydx(public_banks_1970) ///
at((mean) loggdp_1960 private_credit_1960=(0.01(0.05)1.3)) continuous
marginsplot, level(90) yline(0)

* negative and significant impact for low levels of credit / GDP
* no significant impact for intermediate levels of credit / GDP
* positive and significant impact for high levels of credit / GDP



*------------------------------------
// 6. Regression 5
*------------------------------------

*a ) 
gen nooecd = 0
replace nooecd = 1 if oecd ==0

reg gdpgrowth  loggdp_1960 public_banks_1970 nooecd c.loggdp_1960#oecd  c.public_banks_1970#oecd, robust

* b) 
* constant: average gdp growth for oecd countries when all x variables are at 0
* non-oecd dummy: for non oecd country the constant plus the non-oecd dummy are the average gdp growth when all x variables are at 0 


* c) 
* interaction term indicates the oecd specific change in the slope of public_banks_1970 and loggdp_1960 when a country is a member of the oecd
* i.e. the overall effect for oecd countries is: public_banks_1970 + public_banks_1970*oecd 
* 

*------------------------------------
// 7. Regression 6
*------------------------------------

* a) 
reg gdpgrowth  nooecd oecd  ///
c.loggdp_1960#oecd  c.public_banks_1970#oecd, noconstant robust


* b) 
* oecd dummy: average gdp growth when all x variables are at 0 for oecd countries  (corresponds to constant in Regression 5)
* non- oecd dummy: average gdp growth when all x variables are at 0 for non-oecd countries (corresponds to constant + non-oecd dummy in Regression 5)

* c) 
reg gdpgrowth  nooecd oecd  ///
c.loggdp_1960#oecd  c.public_banks_1970#oecd,  robust
* collinearity: oecd + non-oecd = constant


* d) 
* The two regression produce the same results: in regression 5 the main coefficients are for the reference group (non-oecd countries) and the interaction term have to be added to get the slopes for oece countries 
* in regressin 6 there is no reference group and the slopes for both groups can be directly read from the output

* NOTE I: R2 is not the same without a constant (or even with a manual constant): 
reg gdpgrowth
gen const = 1
reg gdpgrowth const, noconstant 

* NOTE II: What would happen if you had three groups and you run exactly the same regression? Would the results still be the same? 



log close





  