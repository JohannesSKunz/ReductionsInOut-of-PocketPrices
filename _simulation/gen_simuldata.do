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

		save sim_data, replace 
		
