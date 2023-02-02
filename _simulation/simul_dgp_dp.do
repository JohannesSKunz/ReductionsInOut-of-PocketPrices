* -----------------------------------------
* Smulation kinked Dount RDD 
* Johansson et al 2023 
* -----------------------------------------

clear all
set more off 
set obs 100
set seed 1


* -----------------------------------------
* Settings
*cd "/Users/johanneskunz/Google Drive/Courses/Monash/Lecture_SoO/"

sca window = 350
sca m = 90 // upper bound hole
sca n = 90 // lower bound hole

* -----------------------------------------
* DGP

g id = _n
* darw time, 
g time = round(runiform()*10,1)

* daily data
expand 700
bys id: g age= _n - window
g age_m = age + m
g age_n = age - n
bys id: replace time = time[_n-1]+1 if _n>1

* Centered around thier birthday 
g PostBd = age >= 0
g agePostBd = age*PostBd

* Auxiliary variables 
g period1 = age_m < 0
g period4 = age_n > 0
g period1age = period1*age_m
g period4age = period4*age_n

* Random variables  
g  e = rnormal(0,0.001)
g  x = rnormal(0,0.5)

g  y = 256.89 + 22.43*PostBd - 0.116*age + 0.02262*agePostBd ///
		+ 0.1254*period1age + 0.101*period4age + 10*x + 0.001*time + e

		
* -----------------------------------------
* Figure 
bys age : egen y_mean = mean(y)
bys age : g t=_n

* Reg 	
reg y PostBd age agePostBd period1age period4age x time 

su time 
sca meantime = r(mean)*_b[time]
di meantime

su x 
sca meanx = r(mean)*_b[x]
di meanx

loc p1 =  - m
loc p2 =    n

loc start = - window
loc end   =   window

tw  (scatter y_mean age if t==1, m(Oh) mc(gs12) msiz(small)) ///
	(function y = (_b[_cons] + meantime + meanx -`p1'*_b[period1age])+ (_b[period1age] + _b[age])*(x) , range(`start' 0) ) ///
	(function y = (_b[_cons] + meantime + meanx) + (_b[age])*(x) , range(`p1' 0) ) ///
	(function y = (_b[_cons] + _b[PostBd] + meantime + meanx) + (_b[agePostBd]  + _b[age])*(x)    , range(0 `p2') ) ///
	(function y = (_b[_cons] + _b[PostBd] + meantime + meanx -`p2'*_b[period4age]) + (_b[period4age] + _b[agePostBd] + _b[age])*(x) , range(0 `end') ) ///
		, xline(0, lcolor(red) lp(dash)) ///
		  xline(`p1', lcolor(gs8) lp(dot)) ///
		  xline(`p2', lcolor(gs8) lp(dot)) ///
		  xtitle("Days till co-payment eligibility ends", size(small)) ///
		  ytitle("HC use per 10,000", size(small)) ///	
		  xlab(`start'(50)`end') ///
		  scheme(s2mono) graphregion(color(white)) bgcolor(white) ///
		  legend(off)


* -----------------------------------------		  
* Effects 
sca longrun  = (_b[_cons] + _b[PostBd] + meantime + meanx -`p2'*_b[period4age]) - (_b[_cons] + meantime + meanx -`p1'*_b[period1age])
di longrun	
	  
sca shortrun =  _b[PostBd]
di 	shortrun	  
* -----------------------------------------		  
* Area 
sca lower_triang =  0.5*m*(m*_b[period1age])
di lower_triang

sca upper_triang =  0.5*n*(n*_b[period4age])
di upper_triang

di "People that dont need to go any more " lower_triang - upper_triang

	
