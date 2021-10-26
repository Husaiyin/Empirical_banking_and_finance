clear all
set more off
cd "C:\Users\Konrad\Dropbox\Postdoc\Teaching Empirical Banking\Tutorials\"


use "Tutorial 6/dataEmpBF_Tutorial6", replace

xtset  firmid quarter





*------------------------------------------
// 1) Getting to know the data / descriptives
*------------------------------------------

sutex2 networth - relativecovenantbreach8, minmax 

* basic data preparation 
program define trimming
egen p_1=pctile(`1'),p(5)
egen p_99=pctile(`1'),p(95)
replace `1'=. if `1'>p_99|`1'<p_1
drop p_1 p_99
end

trimming inv 
trimming diff_net_worth
trimming macroq 
trimming cashflow 
trimming networth 

 * how many firm violate a covenant 
tab covenantbreach 

* Compare characteristics of firms breaching a covenant vs the others replicate Table IV
latabstat diff_net_worth investment macroq cashflow, by(covenantbreach) s(mean median) nototal format(%9.2f)





*------------------------------------------
// 2) Check whether RDD works 
*------------------------------------------

* a) firms breaching a covenant are different from those not. Threfore we cannot just compare the two groups of firms to find the causal effect of a covenant breach. We will use the discontinuity introduced by the threshold to get to a causal interpretation.

* b ) this is a sharp design

* replicate Figure 1 Panel B and 
* look for jumps in other co-variates 
preserve 
keep if relativecovenantbreach8!=.
collapse (mean) inv macroq cashflow, by(relativecovenantbreach8)
drop if relativecovenantbreach8 > 4

line macroq relativecovenantbreach8, xline(0) xline(1) name(g1,replace) nodraw
line cashflow relativecovenantbreach8, xline(0) xline(1) name(g2,replace) nodraw
line inv relativecovenantbreach8, xline(0) xline(1) name(g3,replace) nodraw

graph combine g1 g2  g3
restore 



* manipulation around the threshold? 
hist diff_net_worth, xline(0)

hist diff_net_worth if diff_net_worth < 200, xline(0)
* compare this to the graph in Berg(2018): there rating 

*------------------------------------------
// 3) Regression 1: RDD versions
*------------------------------------------

* simplest version: linear y/x relationship 
reghdfe inv  covenantbreach networth, absorb(quarter firmid ) cluster(firmid)
est store regi 
* relax the linear assumption
gen networth2 = networth^2
gen networth3 = networth^3
gen networth4 = networth^4

reghdfe inv  covenantbreach networth*, absorb(quarter firmid ) cluster(firmid)
est store regii 

* most general form: polynomial terms can differ to the left and right 
* we use the normalizaton: 
gen diff_net_worth2 = diff_net_worth^2
gen diff_net_worth3 = diff_net_worth^3
gen diff_net_worth4 = diff_net_worth^4

reghdfe inv  i.covenantbreach##c.diff_net_worth*, absorb(quarter firmid ) cluster(firmid)
est store regiii 

esttab regi regii regiii 

* could add controls

* maybe exaggerated with ^3 and ^4 controls? 
reghdfe inv  i.covenantbreach##c.diff_net_worth i.covenantbreach##c.diff_net_worth2, absorb(quarter firmid ) cluster(firmid)


* GRAPHICAL EVidence 
reghdfe inv, absorb(quarter firmid ) savefe resid 
predict ihat, resid 

lowess ihat diff_net_worth if percdistance < 0.15, xline(0)  



*------------------------------------------
// 4) Regression 2: 
*------------------------------------------

* restrict sample to firms close to the threshold 
gen percdistance = abs(diff_net_worth)/networth 

summarize percdistance, detail 

reghdfe inv  covenantbreach networth if percdistance < 0.15, absorb(quarter firmid ) cluster(firmid)

reghdfe inv  covenantbreach networth* if percdistance < 0.15, absorb(quarter firmid ) cluster(firmid)


reghdfe inv  i.covenantbreach##c.diff_net_worth* if percdistance < 0.15, absorb(quarter firmid ) cluster(firmid)







