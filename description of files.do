


* Generate working dataset

"1. data set base.do"
*** in this dofile, I set up the structure for the data set "cells_1y_base.dta". 730 observations per individual, one observation per day in relation to the 85th birthday.

"2. sample & backgr covars.do"
*** in this dofile, I prepare the sample's background characteristics e.g. date of 85th birthday "sample.dta", and merge the relevant variables onto "cells_new_1y.dta". 

"3. organize visits data.dofile"
*** in this dofile, I prepare the data sets of visits (visits by date), and merge in variables from "sample.dta" to calculate visits by cellday (day in relation to 85th birthday)


* Dofiles for analysis

"4. Search for optimal donut hole.do"
*** in this dofile, I search for the optimal donut hole (minimizing AIC/BIC)

"5. regression base.do"
*** this dofile contains the main code for the regression analysis, a regression loop for various donut holes and, a post-estimation of fitted values to draw graphical results 