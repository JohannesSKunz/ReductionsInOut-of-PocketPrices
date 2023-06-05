


************************************************************
/// Find the optimal Donut hole (m & nn)
* grid search for optimal m and n based on R2, LL, AIC & BIC
clear all
set more off 
set seed 1
use cells_new_2y_st3133.dta

* run on 1 year window
keep if cell_day>=-365 & cell_day<=365
drop if incl_2y_85==.

*set scalars away from optimal
scalar maxR2=0
scalar minAIC=1000000000000
scalar minBIC=1000000000000
scalar maxLL=-1000000000000000

*scanning through 20 (200 if every day) options each for m and n and generating the matrix to store all the values 
matrix R2=J(20,20,.)	
matrix AIC_mat=J(20,20,.)	
matrix BIC_mat=J(20,20,.)	
matrix LL_mat=J(20,20,.)	

*scanning for optimal cut point every 10 days between 60 & 180 days away from the threshold
*the loop takes about 6-7 hours.  m=60(10)180
forvalues m=60(10)180 {
forvalues n=60(10)180 { 

di "m = "`m'
di "n = "`n'
* Auxiliary variables 
replace cell_kink_m = cell_day + `m'
replace cell_kink_n = cell_day - `n'
replace p2 = cell_kink_m >= 0 & cell_day <0
replace p3 = cell_kink_n < 0 & cell_day >=0
replace cell_kink_p2 = p2*cell_kink_m
replace cell_kink_p3 = p3*cell_kink_n

* matrix notations
local k=`m'/10
local l=`n'/10

* Reg 	
reg prim											///
	c.cell_day##no_fee 	cell_kink_p2 cell_kink_p3 	///
	c.cell_time										///
	, cluster(id) baselevel	
*store R2
matrix R2[`k',`l']=e(r2)

*store only the value of m and n which optimises according to each criteria (so I don't need to search for it in the final maxtrix)
if e(r2)>maxR2 {
scalar m_R2=`m' 
scalar n_R2=`n' 
scalar maxR2=e(r2) 
}

* save AIC BIC & LL in each matrix, row k(=m/10) and column l(=n/10)
estat ic
scalar AIC=r(S)[1,5]
scalar BIC=r(S)[1,6]
scalar LL=r(S)[1,3]
matrix AIC_mat[`k',`l']=r(S)[1,5]
matrix BIC_mat[`k',`l']=r(S)[1,6]
matrix LL_mat[`k',`l']=r(S)[1,3]

* store only the lowest AIC in scalar
if AIC<minAIC {
scalar m_AIC=`m' 
scalar n_AIC=`n' 
scalar minAIC=AIC
}

if BIC<minBIC {
scalar m_BIC=`m' 
scalar n_BIC=`n' 
scalar minBIC=BIC
}

if LL>maxLL {
scalar m_LL=`m' 
scalar n_LL=`n' 
scalar maxLL=LL 
}


}
}

* Reporting the optimal m and n according to each criteria
di " m=" m_AIC " n=" n_AIC  "  minAIC: " minAIC
di " m=" m_BIC " n=" n_BIC  "  minBIC: " minBIC
di " m=" m_LL  " n=" n_LL    "  maxLL: " maxLL
di " m=" m_R2  " n=" n_R2    "  maxR2: " maxR2

matrix list AIC_mat
matrix list BIC_mat





**********************************************************************
* New: Find the optimal Donut hole (m & nn) 	Extended search: every 10 days between 10 & 180 days
* grid search for optimal m and n based on R2, LL, AIC & BIC
clear all
set more off 
set seed 1
use cells_new_1y_st3133.dta
///use cells_new_1y_vgr3233.dta

* drop missing
drop if incl_1y85==.

*set scalars away from optimal
scalar maxR2=0
scalar minAIC=1000000000000
scalar minBIC=1000000000000
scalar maxLL=-1000000000000000

*scanning through 20 (200 if every day) options each for m and n and generating the matrix to store all the values 
matrix R2=J(20,20,.)	
matrix AIC_mat=J(20,20,.)	
matrix BIC_mat=J(20,20,.)	
matrix LL_mat=J(20,20,.)	

*scanning for optimal cut point every 10 days between 10 & 180 days away from the threshold
*extend search of m closer to the threshold
forvalues m=10(10)180 {
forvalues n=10(10)180 { 

di "m = "`m'
di "n = "`n'
* Auxiliary variables 
replace cell_kink_m = cell_day + `m'
replace cell_kink_n = cell_day - `n'
replace p2 = cell_kink_m >= 0 & cell_day <0
replace p3 = cell_kink_n < 0 & cell_day >=0
replace cell_kink_p2 = p2*cell_kink_m
replace cell_kink_p3 = p3*cell_kink_n

* matrix notations
local k=`m'/10
local l=`n'/10

* Reg 	
reg prim											///
	c.cell_day##no_fee 	cell_kink_p2 cell_kink_p3 	/// 
	c.cell_time										///
	, cluster(id) baselevel	
*store R2
matrix R2[`k',`l']=e(r2)

*store only the value of m and n which optimises according to each criteria (so I don't need to search for it in the final maxtrix)
if e(r2)>maxR2 {
scalar m_R2=`m' 
scalar n_R2=`n' 
scalar maxR2=e(r2) 
}

* save AIC BIC & LL in each matrix, row k(=m/10) and column l(=n/10)
estat ic
scalar AIC=r(S)[1,5]
scalar BIC=r(S)[1,6]
scalar LL=r(S)[1,3]
matrix AIC_mat[`k',`l']=r(S)[1,5]
matrix BIC_mat[`k',`l']=r(S)[1,6]
matrix LL_mat[`k',`l']=r(S)[1,3]

* store only the lowest AIC in scalar
if AIC<minAIC {
scalar m_AIC=`m' 
scalar n_AIC=`n' 
scalar minAIC=AIC
}

if BIC<minBIC {
scalar m_BIC=`m' 
scalar n_BIC=`n' 
scalar minBIC=BIC
}

if LL>maxLL {
scalar m_LL=`m' 
scalar n_LL=`n' 
scalar maxLL=LL 
}


}
}

* Reporting the optimal m and n according to each criteria
di " m=" m_AIC " n=" n_AIC  "  minAIC: " minAIC
di " m=" m_BIC " n=" n_BIC  "  minBIC: " minBIC
di " m=" m_LL  " n=" n_LL    "  maxLL: " maxLL
di " m=" m_R2  " n=" n_R2    "  maxR2: " maxR2

matrix list AIC_mat
matrix list BIC_mat
}
