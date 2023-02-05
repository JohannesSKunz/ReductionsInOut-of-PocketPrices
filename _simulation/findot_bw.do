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
cd "/Users/jkun0001/Dropbox/github/ReductionsInOut-of-PocketPrices/_simulation/"

* -----------------------------------------
use sim_data.dta, clear 
	* Start with usual data set including: id time age y x
	keep id time age y x

* Windoe 
sca window = 350
sca m = 90 // upper bound hole
	loc m = 90
sca n = 90 // lower bound hole		
	loc n = 90		

* Find optimal BW 	
cap prog drop my_BWfind 		
		prog def my_BWfind 
		
		* Define hole using prespecified BW 		
		g age_m = age + `1'
		g age_n = age - `2'		

		* Centered around thier birthday 
		g PostBd = age >= 0
		g agePostBd = age*PostBd		
				
		* Auxiliary variables 
		g period1 = age_m < 0
		g period4 = age_n > 0
		g period1age = period1*age_m
		g period4age = period4*age_n		
				
		* -----------------------------------------
		* Reg 	
		reg y PostBd age agePostBd period1age period4age x time 
		
		drop age_m age_n PostBd agePostBd period1 period4 period1age period4age //Could do locals
	end 

	
*set scalars away from optimal
scalar maxR2=0
scalar minAIC=1000000000000
scalar minBIC=1000000000000
scalar maxLL=-1000000000000000	

* Define output marix 
matrix R2=J(20,20,.)	
matrix AIC_mat=J(20,20,.)	
matrix BIC_mat=J(20,20,.)	
matrix LL_mat=J(20,20,.)		

forval m = 60(20)180  {
	forval n = 60(20)180  {
	* matrix notations
	local k=`m'/10
	local l=`n'/10

		my_BWfind `m' `n'
		
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
		mat S = r(S)
		scalar AIC=S[1,5]
		scalar BIC=S[1,6]
		scalar  LL=S[1,3]
		matrix AIC_mat[`k',`l']=S[1,5]
		matrix BIC_mat[`k',`l']=S[1,6]
		matrix  LL_mat[`k',`l']=S[1,3]
		
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
		
		
		exit 
forvalues m=90 {
	*forvalues n=90 { 
		noi di "+"
		my_BWfind `m' 90
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
				
