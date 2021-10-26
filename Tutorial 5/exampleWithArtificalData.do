clear all 

*---------------------------------------
// ARTIFICAL DATA 1
*---------------------------------------

input t y str6 state
-5 10 "b"
-4 11 "b"
-3 12 "b"
-2 13 "b"
-1 14 "b"
0 15 "b"
1 16 "b"
2 17 "b"
3 18 "b"
4 19 "b"
5 20 "b"
-5 12 "a"
-4 13 "a"
-3 14 "a"
-2 15 "a"
-1 16 "a"
0 17 "a"
1 23 "a" // A permanent increase of y by 5 units 
2 24 "a"
3 25 "a"
4 26 "a"
5 27 "a"
end
* NOTE: the data are slightly different from the one used during the lecture

*-------------------------------------------
// BASELINE 
*-------------------------------------------

twoway (line y t if state =="a") (line y t if state =="b")

gen recap = 0
replace recap = 1 if t >0 & state =="a"
reghdfe y recap, absorb(t state) savefe resid
*predict fe, d

*-------------------------------------------
// GRANGER CAUSALITY TEST 
*-------------------------------------------
gen l1recap = recap
replace l1recap = 0 if t==1 

gen f1recap = recap
replace f1recap = 1 if t==0 &  state =="a"

reghdfe y f1recap recap l1recap, absorb(t state) 


* further illustration: 
* even though f1recap and l1recap could explain the increase in y after recap in state a, see here
reghdfe y f1recap l1recap, absorb(t state) 
* the variable "recap" can explain it perfectly (in this artifical example) therefore, when minimizing squared residuals all the effect will be picked up by "recap" and nothing by f1recap and l1recap 
reghdfe y f1recap recap l1recap, absorb(t state) 



*-------------------------------------------
* EVENT STUDY TYPE REGRESSION 
*-------------------------------------------
gen recap_event = 0
replace recap_event = 1 if t ==1 & state =="a"

*gen f1recap_event = 0
*replace  f1recap_event = 1 if t ==0 & state =="a"

*gen l1recap_event = 0
*replace l1recap_event = 1 if t ==2 & state =="a"


reghdfe y recap_event, absorb(t state) savefe resid


*---------------------------------------
// ARTIFICAL DATA 2
*---------------------------------------
*  CHANGE THE DATA: SITUATION WHERE THE LAG PICKS UP SOMETHING
clear all 

input t y str6 state
-5 10 "b"
-4 11 "b"
-3 12 "b"
-2 13 "b"
-1 14 "b"
0 15 "b"
1 16 "b"
2 17 "b"
3 18 "b"
4 19 "b"
5 20 "b"
-5 12 "a"
-4 13 "a"
-3 14 "a"
-2 15 "a"
-1 16 "a"
0 17 "a"
1 23 "a" // A permanent increase of y by 5 units 
2 26 "a" // Another permanent increase of y by 2 units 
3 27 "a"
4 28 "a"
5 29 "a"
end

twoway (line y t if state =="a") (line y t if state =="b")

*-------------------------------------------
// GRANGER CAUSALITY TEST 
*-------------------------------------------
gen recap = 0
replace recap = 1 if t >0 & state =="a"

gen l1recap = recap
replace l1recap = 0 if t==1 

gen f1recap = recap
replace f1recap = 1 if t==0 &  state =="a"

reghdfe y f1recap recap l1recap, absorb(t state) 

* here recap can no longer perfectly explain the change, and we do find an lagged effect of recap! 


*---------------------------------------
// ARTIFICAL DATA 3
*---------------------------------------

* CHANGE THE DATA: EVENT STUDY 

clear all 

input t y str6 state
-5 10 "b"
-4 11 "b"
-3 12 "b"
-2 13 "b"
-1 14 "b"
0 15 "b"
1 16 "b"
2 17 "b"
3 18 "b"
4 19 "b"
5 20 "b"
-5 12 "a"
-4 13 "a"
-3 14 "a"
-2 15 "a"
-1 16 "a"
0 17 "a"
1 23 "a" // TRUE effect: recap increases y by an additional 5, but only for one period
2 19 "a"
3 20 "a"
4 21 "a"
5 22 "a"
end
twoway (line y t if state =="a") (line y t if state =="b")

*----------------------------------------
// Baseline: permanent effect? 
*----------------------------------------
gen recap = 0
replace recap = 1 if t >0 & state =="a"

reghdfe y recap, absorb(t state) savefe resid

*----------------------------------------
// EVENT STUDY: here the right tool 
*----------------------------------------
gen recap_event = 0
replace recap_event = 1 if t ==1 & state =="a"

reghdfe y recap_event, absorb(t state) savefe resid

