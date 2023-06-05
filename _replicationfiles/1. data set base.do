
******************************************
*** Naimi Johansson *****
*** do file created Nov, 2019 ******
*** copayments 85+ *********
*** organize the data Ver 3.0



*******************************************************
/// create set with one observation for ind and each cell_day 
/// age-running variable (cell_day)
/// time-running variable + pre-post 1/1 2016
/// merge in vars of visits (outp_visits.dta) then vars on ind (sample.dta)
/// for as many cell_days as I want to study
*******************************************************

/// create set on individual level & daycells +/-2 years and +/-1 year 
/// define weeks and months in relation to day of visits and 85 bd
/// hit on bd85 - cell_day==0
/// week -1 to be cell_day -7 - -1 
/// week 0 to be cell_day 0-6
/// week 1 to be cell_day 7-13

/// month -1 to be cell_day -30 to -1
/// month 0 to be cell_day 0 to 29
/// month  1 to be cell_day 30 to 59 

/// one set with weeks and days
clear
set obs 66592
gen id=_n
/// expand by the number of weeks - 211
expand 211
sort id
/// generate cell_weeks for each individual
bysort id: gen cell_week=_n-106
/// now expand again by number of days per week i.e. 7
expand 7 if cell_week!=0
sort id cell_week 
/// generate cell_days 
bysort id: gen cell_day=_n-736
compress 
save temp.dta, replace

/// another set with months and days 
clear
set obs 66592
gen id=_n
/// expand by the number of months 51
expand 51 
sort id
/// generate cell_month for each individual
bysort id: gen cell_month=_n-26
/// now expand again by number of days per month, assuing 30 days 
/// but let cell_month 0 just have one observation
expand 30 if cell_month!=0
sort id cell_month
/// generate cell_days 
bysort id: gen cell_day=_n-751
compress 

/// merge months weeks and days into one set
merge 1:1 id cell_day using temp.dta
order id cell_d cell_w cell_m
sort id cell_day
drop if cell_day<-730
drop if cell_day>730
drop _merge

/// indicator for no-fee
gen no_fee=0
replace no_fee=1 if cell_day>=0
replace no_fee=. if cell_day==0
label variable no_fee "indicator for pre/post 85 bd and no-fee-policy"

* add helping vars for kinks 
/// running variables for kinks
g cell_kink_m = cell_day + 90
g cell_kink_n = cell_day - 90 
label variable cell_kink_m "running var in relation to start of donut hole"
label variable cell_kink_n "running var in relation to end of donut hole"
/// 4 periods indicators
g p1 = cell_kink_m < 0
g p2 = cell_kink_m >= 0 & cell_day <0
g p3 = cell_kink_n < 0 & cell_day >=0
g p4 = cell_kink_n >= 0
label variable p1 "indicator for period 1"
label variable p2 "indicator for period 2"
label variable p3 "indicator for period 3"
label variable p4 "indicator for period 4"
/// create 4 complementary running vars -- depending on donut hole width
g cell_kink_p1 = p1*cell_kink_m
g cell_kink_p2 = p2*cell_kink_m
g cell_kink_p3 = p3*cell_kink_n
g cell_kink_p4 = p4*cell_kink_n
label variable cell_kink_p1 "period 1 running var in relation to donut hole"
label variable cell_kink_p2 "period 2 running var in relation to donut hole"
label variable cell_kink_p3 "period 3 running var in relation to donut hole"
label variable cell_kink_p4 "period 4 running var in relation to donut hole"

*save
compress
save cells_2y_base.dta 
keep if cell_day>=-365 & cell_day<=365
save cells_1y_base.dta
