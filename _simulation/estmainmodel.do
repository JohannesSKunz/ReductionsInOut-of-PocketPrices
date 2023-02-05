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
use sim_data.dta, clear 
* Start with usual data set including: id time age y x
keep id time age y x

sca window = 350
sca m = 90 // upper bound hole
sca n = 90 // lower bound hole		
		

* Define hole using prespecified BW 		
g age_m = age + m
g age_n = age - n		

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



