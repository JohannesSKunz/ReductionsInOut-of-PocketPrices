

******************************************
*** Naimi Johansson *****
*** do file created June, 2020 ******
*** copayments 85+ *********
*** Regressions + graphs Ver 4.0


use cells_new_1y_st3133.dta, clear

/// nofee
gen no_fee=.
replace no_fee=0 if cell_day<0
replace no_fee=1 if cell_day>0

/// replace running variables for kinks
* set donut kink points
sca m = 110 // kink before threshold
sca nn = 130 // kink after threshold
replace cell_kink_m = cell_day + m
replace cell_kink_n = cell_day - nn 
replace p2 = cell_kink_m >= 0 & cell_day <0
replace p3 = cell_kink_n < 0 & cell_day >=0
replace cell_kink_p2 = p2*cell_kink_m
replace cell_kink_p3 = p3*cell_kink_n


*******************************************************************
/// Regression base + delay & shift area
/// Linear
reg prim										///
	c.cell_day##no_fee 		///
	cell_kink_p2 			///
	cell_kink_p3 			///
	if cell_day>=-365 & cell_day<=365	///
	, robust baselevel	

/// delay & shift --- Linear
/// area A
lincom  -0.5*_b[cell_kink_p2]*m*m
display r(estimate)
display r(se)
display r(p)
/// area B
lincom  -0.5*_b[cell_kink_p3]*nn*nn
display r(estimate)
display r(se)
display r(p)
/// diff A-B
lincom  -0.5*m*m*_b[cell_kink_p2]+0.5*nn*nn*_b[cell_kink_p3]
display r(estimate)
display r(se)
display r(p)
di r(lb)
di r(ub)



*********************************************************************
*** Loop regression for various donut holes
	use cells_new_1y_st3133.dta
* matrix to store goodness-of-fit 
	matrix good_fit = J(6, 4, .)	
	matrix colnames good_fit = R2 ll AIC BIC 
* matrix to store delay areas
	matrix delay = J(6, 6, .)
	matrix colnames delay = delay se p shift se p 
	matrix delay_diff = J(6, 5, .)
	matrix colnames delay_diff = diff se p ci_min ci_max

* LOCALS AND LOOP 
**********************************************************
* SET OUTCOME 	 		
	local outcome 			prim 
* SET SAMPLE LABEL		
	local samp_lab 			st
* WINDOW						 
	local window 			cell_day>=-365 & cell_day<=365		
	local win_lab	 		1y
* FUNCTIONAL FORM OF CELL_DAY & CELL_KINK P2 & P3  
	local func 				c.cell_day##no_fee  cell_kink_p2  cell_kink_p3
	local func_lab			lin
* ADJUSTMENT FOR TIME 
	local time_covar		c.cell_time
* LOOP DONUT HOLE 	[`m' for kink pre/post policy ]
	forvalues m=60(30)150  {
* Notations for the matrix
	local k=`m'/30
	
* Replace running variables for kinks
		replace cell_kink_m = cell_day + `m'
		replace cell_kink_n = cell_day - `m' 
		replace p2 = cell_kink_m >= 0 & cell_day <0
		replace p3 = cell_kink_n < 0 & cell_day >=0
		replace cell_kink_p2 = p2*cell_kink_m
		replace cell_kink_p3 = p3*cell_kink_n
* REGRESS 
eststo kr_`samp_lab'`outcome'_`func_lab'`win_lab'd`m'`m' : ///	
	reg `outcome' 				///
		`func'					///
		`time_covar'			///
		if `window'				///
		, cluster(id) baselevel	
* save R2 AIC BIC & LL in each matrix, row k(=m-9) and column l(=n-9)
	matrix good_fit[`k',1]=e(r2)
		estat ic
		scalar AIC=r(S)[1,5]
		scalar BIC=r(S)[1,6]
		scalar LL=r(S)[1,3]
		matrix good_fit[`k',2]=r(S)[1,3]	
		matrix good_fit[`k',3]=r(S)[1,5]
		matrix good_fit[`k',4]=r(S)[1,6] */
* Save values of areas A & B & diff --- Linear
/// area A (m)
	lincom  -0.5*_b[cell_kink_p2]*`m'*`m'*10000
		matrix delay[`k',1] = r(estimate)
		matrix delay[`k',2] = r(se)
		matrix delay[`k',3] = r(p)
/// area B (nn)
	lincom  -0.5*_b[cell_kink_p3]*`m'*`m'*10000
		matrix delay[`k',4] = r(estimate)
		matrix delay[`k',5] = r(se)
		matrix delay[`k',6] = r(p)
/// diff A-B
	lincom  (-0.5*`m'*`m'*_b[cell_kink_p2]+0.5*`m'*`m'*_b[cell_kink_p3])*10000
		matrix delay_diff[`k',1] = r(estimate)
		matrix delay_diff[`k',2] = r(se)
		matrix delay_diff[`k',3] = r(p)
		matrix delay_diff[`k',4] = r(lb)
		matrix delay_diff[`k',5] = r(ub)
} 

/// results tables
matrix list good_fit	
matrix list delay
matrix list delay_diff
* regression tables
esttab 	kr_* 		///	
	using "results.rtf", se r2 aic nopar star b(a5)		/// 
	mti(kr_*  )
**********************************************************************





***************************************************************************
* For graphs: Run the regression, estimate fitted values, collapse to draw graph 
use cells_new_1y_st3133.dta
* SET OUTCOME 	 	
	local outcome 			prim 
* SET SAMPLE LABEL	
	local samp_lab 			st
* WINDOW 		 
	local win_lab			1y
* DONUT HOLE [`m' for kink pre policy `nn' for kink post policy]
	local m 				110		
	local nn				130
* FUNCTIONAL FORM OF CELL_DAY   
	local func_lab			lin
	local age_func	 		c.cell_day##no_fee  
* FUNCTIONAL FORM OF CELL_KINK	
	local kink_func			cell_kink_p2 cell_kink_p3 
* EXTRAPOLATION OF PERIOD 1 & 4 
	local ext				_b[cell_day]*cell_day + _b[1.no_fee]*no_fee + _b[1.no_fee#c.cell_day]*no_fee*cell_day 
* ADJUSTMENT FOR TIME (assuming linear trend)
	local time_covar		c.cell_time
	local time_adj 		 	(_b[cell_time]*cell_time)
* REPLACE running variables for kinks
	replace cell_kink_m = cell_day + `m'
	replace cell_kink_n = cell_day - `nn' 
	replace p2 = cell_kink_m >= 0 & cell_day <0
	replace p3 = cell_kink_n < 0 & cell_day >=0
	replace cell_kink_p2 = p2*cell_kink_m
	replace cell_kink_p3 = p3*cell_kink_n

* REGRESS 
reg `outcome' 			///
	`age_func'			///
	`kink_func'			///
	`time_covar'		///
		, cluster(id) baselevel
* Adjusted y and adjusted fit (adjusted for time trend)
	* Fitted values (y_hat)
	predict fit , xb	
	* Adjusted y 		(y - time_adj) 
	gen y_adj = `outcome' - `time_adj' 
	* Adjusted fit 	(y_hat - time_adj)
	gen fit_adj = fit - `time_adj' 			
* Extrapolations of fitted values (from period 1 to 2 and 4 to 3)
	gen ext = _b[_cons] + `ext' 
* Mark as missing 
	replace y_adj=. 	if incl_1y85==.
	replace fit_adj=. 	if incl_1y85==.
	replace ext=. 		if incl_1y85==.	
		keep id cell_day cell_week cell_month y_adj fit_adj ext
		save temp_cells.dta, replace

* COLLAPSE   
	* 1. Collapse on cellday: fit_adj ext
	collapse (mean) fit_adj ext , by (cell_day cell_week cell_month)
		sort cell_day
		order cell_day cell_week cell_month 
		save temp_cellday.dta, replace	
	* 2. Collapse on week: 	y_adj
	use temp_cells.dta
		collapse (mean) y_adj, by (cell_week)
	* merge into temp_cellday
	merge 1:m cell_week using temp_cellday.dta
		sort cell_day
		order cell_day cell_week cell_month y_adj fit_adj 
		drop _merge
	* scale up by 10000 (visits per day per 10000 people)
		replace y_adj 	= y_adj*10000
		replace fit_adj = fit_adj*10000
		replace ext 	= ext*10000
	* drop all but 1 obs for each week
	forvalues i=1/105 {
		replace y_adj=. if cell_week==`i' ///
		& cell_day>(((`i'-1)*7)+4) 		 
		replace y_adj=. if cell_week==`i' ///
		& cell_day<(((`i'-1)*7)+4) 		 
		}
	forvalues i=-105/-1 {
		replace y_adj=. if cell_week==`i' ///
		& cell_day>(((`i'+1)*7)-4) 		 
		replace y_adj=. if cell_week==`i' ///
		& cell_day<(((`i'+1)*7)-4) 		 
		}	
	* Label & rename
		label variable y_adj 	"Kr `samp_lab' `outcome' `func_lab' `win_lab' m`m'n`nn'"
		label variable fit_adj 	"Kr fit `samp_lab' `outcome' `func_lab' `win_lab' m`m'n`nn'"
		label variable ext 		"Kr extrapol. `samp_lab' `outcome' `func_lab' `win_lab' m`m'n`nn'"
		rename y_adj 			Kr_`samp_lab'`outcome'_`func_lab'`win_lab'm`m'n`nn'
		rename fit_adj 			fitKr_`samp_lab'`outcome'_`func_lab'`win_lab'm`m'n`nn'
		rename ext 				Kr_ext_`samp_lab'`outcome'_`func_lab'`win_lab'm`m'n`nn'
* Save cellday_adj.dta
	sort cell_day
	order cell_day cell_week cell_month 
	save cellday_adj.dta

* UPDATE DONUT HOLE TO FIT GRAPH
use cellday_adj.dta, clear
* size of donut hole
	local m 				110		
	local nn				130
* Replace running variables for kinks
	replace cell_kink_m = cell_day + `m'
	replace cell_kink_n = cell_day - `nn' 
	replace p1 = cell_kink_m < 0
	replace p2 = cell_kink_m >= 0 & cell_day <0
	replace p3 = cell_kink_n < 0 & cell_day >=0
	replace p4 = cell_kink_n >= 0
* save	
	save cellday_adj.dta, replace

*** MAIN GRAPH
* Primary care, Linear 1y m110 n130  
twoway (scatter Kr_st3133prim_lin1ym110n130 cell_day  , 	msize(small) color(ebblue)) 								///  
	|| (line fitKr_st3133prim_lin1ym110n130 cell_day if cell_day<0, lcolor(black) lwidth(medium)) 						///
	|| (line fitKr_st3133prim_lin1ym110n130 cell_day if cell_day>0, lcolor(black) lwidth(medium)) 						///
	|| (line Kr_ext1_st3133prim_lin1ym110n130 cell_day if p2==1	, lpattern(shortdash) lcolor(black) lwidth(medium)) 	///
	|| (line Kr_ext4_st3133prim_lin1ym110n130 cell_day if p3==1	, lpattern(shortdash)	lcolor(black) lwidth(medium)) 	///
		if cell_day>-365 & cell_day<365 & cell_day!=0 				///
		,	 /// title("Primary care visits Sthlm",  size(medium)) 	/// 
			xline(0, lcolor(red) lp(dash) lwidth(vthin)) 			/// 
			xtitle("Days to 85 bd", size(medium)) 					///
			xlabel(-360(60)360, labsize(small) format(%9.4g)) 		/// 
			ytitle("Visits per 10,000", size(medium)) 				///
			ylabel(250(10)280, nogrid labsize(small) ) 				/// 
			legend(order (1 "Weekly average" 2 "Fitted line" 4 "Extrapolation")) /// 
			legend(cols (4) size(small)) 							///
			graphregion(color(white)) plotregion(lcolor(black))







**************************************************************************
/// Quaratic functional form
* regression base
reg prim										///
	c.cell_day##no_fee 	c.cell_day#c.cell_day##no_fee				///
	cell_kink_p2 c.cell_kink_p2#c.cell_kink_p2 	///
	cell_kink_p3 c.cell_kink_p3#c.cell_kink_p3	///
	if cell_day>=-365 & cell_day<=365	///
	, robust baselevel	
estat ic

/// delay & shift area--- quadratic 
/// area A
lincom  -0.5*_b[cell_kink_p2]*m*m-(1/3)*_b[c.cell_kink_p2#c.cell_kink_p2]*m*m*m
display r(estimate)
display r(se)
display r(p)

/// area B
lincom  -0.5*_b[cell_kink_p3]*nn*nn-(1/3)*_b[c.cell_kink_p3#c.cell_kink_p3]*nn*nn*nn
display r(estimate)
display r(se)
display r(p)

/// diff A-B
lincom  -0.5*m*m*_b[cell_kink_p2]-(1/3)*m*m*m*_b[c.cell_kink_p2#c.cell_kink_p2]+0.5*nn*nn*_b[cell_kink_p3]+(1/3)*nn*nn*nn*_b[c.cell_kink_p3#c.cell_kink_p3]
display r(estimate)
display r(se)
display r(p)
display r(lb)
display r(ub)


	

	
