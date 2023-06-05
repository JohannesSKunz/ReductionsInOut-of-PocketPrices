

******************************************
*** Naimi Johansson 			*********
*** copayments 85+ 				*********
*** Organize visits data		*********
*** do file created Sept, 2020 	*********



*** clean up STHLM visits
/// dataset with sthlm visits
use outp_sthlm.dta
sort lopnr bdat
order lopnr ar alder bdat vardniva btyp vdg1  taxa
	  
/// rename 
rename lopnr id
rename ar year
rename alder age
rename bdat date
rename vardniva level
rename btyp contact
rename vdg1 staff1
rename vdg2 staff2
rename vdg3 staff3
rename vdg4 staff4
rename vdg5 staff5
rename taxa copay_type

rename kombika provider_comb
rename inr provider
rename driftform public
rename velak primaryc_list
rename husl gp_list
rename spec field 
rename avdtyp clinic_type
rename akut emerg
rename lkomm munici_prov


****** defining the visits 
/// check the homevisits 
/// btyp== 2
gen homevisit=0
replace homevisit=1 if contact=="2" /// homevisits
replace homevisit=1 if contact=="H" /// homevisits - TEAM visit in home
replace homevisit=2 if btyp=="0" // ordinary visits - NEW visit
replace homevisit=2 if btyp=="1" // ordinary visits - FOLLOW UP visit
replace homevisit=2 if btyp=="8" // ordinary visits - GROUP visit
replace homevisit=2 if btyp=="A" // ordinary visits - TEAM visit
replace homevisit=2 if btyp=="B" // ordinary visits - GROUP-TEAM visit
tab homevisit 

gen phys=0
replace phys=1 if staff1<"69"
gen staff=0
/// physicians
replace staff=1 if staff1<"69"
/// nurses
replace staff=2 if staff1=="70"
replace staff=2 if staff1=="89"
/// USK
replace staff=3 if staff1=="91"

drop homevisit


/// variable for visit
/// btyp contact 0,1,8,A,B - all are visits at health care facility - use them all
/// btyp contact 2,H - homevisits -- use only those by physicians (to align with VGR data)
gen visit=0
replace visit=1 if contact=="0"
replace visit=1 if contact=="1"
replace visit=1 if contact=="8"
replace visit=1 if contact=="A"
replace visit=1 if contact=="B"
/// home visits by physician 
replace visit=1 if contact=="2" & staff1>="01" & staff1<="69"
replace visit=1 if contact=="H" & staff1>="01" & staff1<="69"
/// add var for homevisit
gen homevisit=0
replace homevisit=1 if contact=="2" 
replace homevisit=1 if contact=="H" 

***************************
/// keep only visit==1 
/// drop all obs other 
keep if visit==1
sort id date

/// a variable identifying the visit
gen visit_id=_n
/// in order to enable to merge back with visit details


/// the copayment variable
/// most common is 1, 2, 3, 6, 8, 10, 11, 
gen copay_name="other"
replace copay_name="primary" if copay_type==1
replace copay_name="specialist" if copay_type==2
replace copay_name="emergency" if copay_type==3
replace copay_name="no fee" if copay_type==6
replace copay_name="stop loss" if copay_type==8
replace copay_name="up to stop loss" if copay_type==10
replace copay_name="medical service" if copay_type==11
replace copay_name="other fees" if copay_type==15
replace copay_name="ref. to spec" if copay_type==22
/// the amount in SEK
gen copay=. 
replace copay=200 if copay_type==1
replace copay=350 if copay_type==2
replace copay=400 if copay_type==3
replace copay=0 if copay_type==6
replace copay=0 if copay_type==8
label variable copay "approx. amount in SEK"
compress
save outp_sthlm_nj.dta, replace


/// emergency visits & planned vs unplanned visits 

/// kombika consists of INR (5 digits), KLIN (3 digits) and AVD (1-3 digits)
gen klin=substr(provider_comb,6,3)
gen avd=substr(provider_comb,9,3)

/// most are missing details on type of clinic..
/// clinic_type=43 is emergency deparment  , about 23,000 visits
gen clinic_type_n="Departm." 		if clinic_type=="40"
gen clinic_type_n="Emerg. departm." if clinic_type=="43"		//Akutmottagning
gen clinic_type_n="Primary care emerg." if clinic_type=="45"	//Jourmottagning (oftast primärvård
gen clinic_type_n="Simple emerg." 	if clinic_type=="46"		//Lättakut
gen clinic_type_n="Local emerg." 	if clinic_type=="48"		//Närakut
gen clinic_type_n="Med service" 	if clinic_type=="50"		//Medicinsk service
/// clinic_type 43, 45, 46 and 48 are different type of emergency dept. or "jourmottagning/närakut"


/// 2 variations of emergency coding
/// 1. using emerg==J - 219,564 visits
/// 2. using codes from clinic_type and klin (emerg=J or N)
/// clinic_type == 43,45,46 & 48 & klin==046

/// mark up emergency visits & unplanned visits
/// MARK UP 
/// 2 variations of emergency coding
/// 1. using emerg==J - 219,564 visits (booked at least one day in advance)
/// 2. using codes from clinic_type and klin (emerg=J or N)
/// clinic_type == 43,45,46 & 48 & klin==046

gen emerg_d1=0
replace emerg_d1=1 if emerg=="J"
rename emerg_d1 unplanned 
label variable unplanned "visit not planned one day before (1), planned at least the day before (0)"

gen emerg_d2=0
/// clinic_type 43, 45, 46 and 48 are different type of emergency dept. 
replace emerg_d2=1 if clinic_type=="43"
replace emerg_d2=1 if clinic_type=="45"
replace emerg_d2=1 if clinic_type=="46"
replace emerg_d2=1 if clinic_type=="48"
/// klin=046 is emergency dept. 
replace emerg_d2=1 if klin=="046"
label variable emerg_d2 "visit at emerg. dept. or jourmottagning"


/// First visit vs Follow up visit 
gen firstvisit=. 
replace firstvisit=1 if contact=="0" // ordinary visits - NEW visit
replace firstvisit=0 if contact=="1" // ordinary visits - FOLLOW UP visit
label variable firstvisit "new visit (1) vs follow up visit (0)"
tab firstvisit, miss

*save
save outp_sthlm_nj.dta, replace



*** VGR visits ****
cd ""
/// create data set with outpatient visits VGR
///  orginal data
use vgr_full_set.dta
sort id date

/// only the visits
keep if contact_c=="B"

/// drop variables related to inpatient care
drop visit_date adm_date disc_date inp adm_type_code adm_type_name dis_type_code dis_type_name
/// drop some string variables
drop contact_name visit_name staff_name planned_n ///
provider_n field_c field_n clinic_c clinic_n care_type primaryc_n

/// level (primary/county/region/national)
gen prim=0
replace prim=1 if level=="P"

/// staff_c (09 nurse etc/10 physician )
gen physic=0
replace physic=1 if staff_c=="10"
/// those with missing - assumed to be "other staff"

/// visits made in other regions?
/// there are NONE

/// the copayment variables
gen copay_name=""
replace copay_name="stop loss" if copay_type=="Frikort"
replace copay_name="yes" if copay_type=="Ja"
replace copay_name="no fee other" if copay_type=="Annan orsak, t ex vÃ¤rnplikt"
replace copay_name="no fee 85" if copay_type=="Ingen avgift, 85 och Ã¤ldre"

*save
save outp_vgr_nj.dta



**** Merge Sthlm & VGR visits into outp_visits data set
*************************
/// merge sthlm and vgr visits into one data set
/// VGR data
use outp_vgr_nj.dta
/// drop irrelevant vars for now
keep id date prim physic  planned  copay_name copay vega_id
order id date prim physic  planned  copay_name copay vega_id

/// make the date into same format
rename date date_
gen date=date(date_,"YMD")
format date %td
order id date date_
drop date_
/// region indicator
gen reg_visit=14
save temp.dta 

/// the sthlm data
use outp_sthlm_nj.dta
keep id date level physic staff1 copay_name copay visit_id homevisit unplanned emerg_d2 firstvisit
gen reg_visit=1
/// make the date into same format as in vgr
tostring date, gen(date_) format("%12.0f") 
replace date_=substr(date_,1,4)+"-"+substr(date_,5,2)+"-"+substr(date_,7,2)
drop date

gen date=date(date_,"YMD")
format date %td
order id date date_
drop date_
///rename
gen prim=.
replace prim=1 if level=="01"
replace prim=0 if level=="02"
/// drop some other
drop level staff1 
order id date prim physic copay_name copay visit_id reg_visit
save temp2.dta


use temp.dta
//// now append sthlm into vgr
append using temp2.dta
sort id date
order id date prim physic reg_visit homevisit emerg_d2 firstvisit unplanned planned copay_name copay
rename visit_id st_visit_id
rename vega_id vgr_visit_id

/// planned & unplanned 
rename planned planned_vg
gen planned=.
replace planned=1 if planned_vg=="P"
replace planned=0 if planned_vg=="O"
replace planned=1 if unplanned==0
replace planned=0 if unplanned==1
label variable planned "visit planned day before (1), or unplanned (0) admin persepctive"
drop unplanned planned_vg
order id date prim physic reg_visit homevisit emerg_d2 firstvisit planned copay_name copay

compress 
save outp_visits.dta


****************************
/// merge outp_visits.dta with sample.dta to get birthdates to calculate day cells

/// bring in birthdate
use sample.dta
keep id reg_resi birthday birthyear bd85 bd84 bd83 bd85 bd86
save temp.dta, replace
use outp_visits.dta
merge m:1 id using temp.dta

drop if _merge==2
drop _merge
order id birthday birthyear  
sort id date


/// daycell at visit in relation to 85 bd
gen cell_85=date-bd85
label variable cell_85 "age cell in relation to 85th birthday"

/// daycell at visit in relation to other birthdays
gen cell_83=date-bd83
gen cell_84=date-bd84
gen cell_86=date-bd86
label variable cell_83 "age cell in relation to 83rd birthday"
label variable cell_84 "age cell in relation to 84th birthday"
label variable cell_86 "age cell in relation to 86th birthday"
compress


/// calculate the number of visits per ind per day 
bysort id date: gen visit=_N
label variable visit "number of visits by cellday"
tab visit, miss
compress 
/// there are multiple visits in one day
/// some of these are in VGR team visits, meeting multiple staff
/// in STHLM team visits might be recorded on one row, as they have multiple variables for staff... 

order id birthday visit cell_85
sort id date

/// the weekday & month of the visit
gen weekday= dow(date)
gen weekday_n="" 
replace weekday_n="Su" if weekday==0
replace weekday_n="Mo" if weekday==1
replace weekday_n="Tu" if weekday==2
replace weekday_n="We" if weekday==3
replace weekday_n="Th" if weekday==4
replace weekday_n="Fr" if weekday==5
replace weekday_n="Sa" if weekday==6
compress  

/// the month of the visit
gen month=month(date)

save outp_visits.dta, replace
************************************************************




/// adding the number of visits per daycell into cells_new_1y.dta
/// using cell_85: visits in relation to 85 bd 
/// the visits data set, only +/-365 cells
use outp_visits.dta
drop if cell_85<-365
drop if cell_85>365
keep id date visit prim physic homevisit emerg_d2 firstvisit planned cell_85
sort id date
save outp_visits_temp.dta, replace

/// visits to primary care physician
/// calc the number of visits per cell_day
keep if prim==1 & physic==1
sort id date
bysort id cell_85: gen visits=_N
keep id cell_85 visits
bysort id cell_85: gen count=_n
drop if count>1
drop count
rename cell_85 cell_day
save temp.dta, replace
/// merge into cells_new_1y   
use cells_new_1y.dta
merge 1:1 id cell_day using temp.dta
replace visits=0 if _merge==1
drop _merge 
/// mark up visits as missing (rather than 0) when people have died or move away
/// same as inclusion variable 
replace visits=. if incl_1y85==.
/// rename and label 
label variable visits "number of visits to GP (incl phys homev) - in relation to 85 bd"
rename visits PrPh
compress
save cells_new_1y.dta, replace

/// repeat for visits to specialist physician
/// calc the number of visits per cell_day
use outp_visits_temp.dta
keep if prim==0 & physic==1
sort id date
bysort id cell_85: gen visits=_N
keep id cell_85 visits
bysort id cell_85: gen count=_n
drop if count>1
drop count
rename cell_85 cell_day
save temp.dta, replace
/// merge into cells_new_1y   
use cells_new_1y.dta
merge 1:1 id cell_day using temp.dta
replace visits=0 if _merge==1
drop _merge 
/// mark up visits as missing (rather than 0) when people have died or move away
/// same as inclusion variable 
replace visits=. if incl_1y85==.
/// rename and label 
label variable visits "number of visits to Specialist - in relation to 85 bd"
rename visits spec
compress
save cells_new_1y.dta, replace

/// repeat for visits to other staff spec. care
/// calc the number of visits per cell_day
use outp_visits_temp.dta
keep if prim==0 & physic==0
sort id date
bysort id cell_85: gen visits=_N
keep id cell_85 visits
bysort id cell_85: gen count=_n
drop if count>1
drop count
rename cell_85 cell_day
save temp.dta, replace
/// merge into cells_new_1y   
use cells_new_1y.dta
merge 1:1 id cell_day using temp.dta
replace visits=0 if _merge==1
drop _merge 
/// mark up visits as missing (rather than 0) when people have died or move away
/// same as inclusion variable 
replace visits=. if incl_1y85==.
/// rename and label 
label variable visits "number of visits to other staff in specialized care - in relation to 85 bd"
rename visits SpOth
compress
save cells_new_1y.dta, replace

/// repeat for visits to other staff primary care
/// calc the number of visits per cell_day
use outp_visits_temp.dta
keep if prim==1 & physic==0
sort id date
bysort id cell_85: gen visits=_N
keep id cell_85 visits
bysort id cell_85: gen count=_n
drop if count>1
drop count
rename cell_85 cell_day
save temp.dta, replace
/// merge into cells_new_1y   
use cells_new_1y.dta
merge 1:1 id cell_day using temp.dta
replace visits=0 if _merge==1
drop _merge 
/// mark up visits as missing (rather than 0) when people have died or move away
/// same as inclusion variable 
replace visits=. if incl_1y85==.
/// rename and label 
label variable visits "number of visits to other staff in primary care - in relation to 85 bd"
rename visits PrOth
* primary & spec 
gen prim = PrPh + PrOth
gen spec_all = Spec + oth_spec
compress
save cells_new_1y.dta, replace

/// repeat for emergency visits -- only in sthlm data
// visit made at emergency department/jourmottagn
use outp_visits_temp.dta
sort id cell_85
keep if emerg_d2>0
drop if emerg_d2==.
bysort id cell_85: gen emerg=_N
bysort id cell_85: gen count=_n
tab count
drop if count>1
keep id emerg cell_85
rename cell_85 cell_day
save temp.dta, replace
/// merge into cells_new_2y   
use cells_new_1y.dta
merge 1:1 id cell_day using temp.dta
replace emerg=0 if _merge==1
drop _merge 
/// mark up visits as missing (rather than 0) when people have died or move away
/// same as inclusion variable 
replace emerg=. if incl_1y85==.
/// label 
label variable emerg "emergency visits STHLM (at emergency department/jourmottagn)"
compress
save cells_new_1y.dta, replace




