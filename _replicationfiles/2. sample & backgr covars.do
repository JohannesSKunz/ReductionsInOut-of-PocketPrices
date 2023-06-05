
******************************************
*** do file created August, 2019 ******
*** copayments 85+ *********
*** 
//// the sample 
use SCB_backgr_ind.dta

destring gender, replace
destring backg, replace
destring region2013, replace
destring region2014, replace
destring region2015, replace
destring region2016, replace
destring region2017, replace
destring birthyear, replace

drop AterPnr SenPnr birthmonth birthdate
save sample.dta


/// the dates - 
rename birthday birthday_
gen birthday=date(birthday_,"YMD")
/// format into readable dates
format birthday %td
drop birthday_

/// the 85th birthday
/// separate and add 85 years
gen bd_year=year(birthday)+85
gen bd_month=month(birthday)
gen bd_day=day(birthday)
/// combine day month year to for date of 85th birthday
gen bd85 = mdy(bd_month, bd_day, bd_year)
/// 29feb is making life difficult
/// set 85th birthday at 1 march 2017 for those born 29feb1932
replace bd85 = td(01mar2017) if birthday==td(29feb1932)
format bd85 %td
drop bd_year bd_month bd_day

/// the 84th birthday - to make comparisons
/// separate and add 84 years
gen bd_year=year(birthday)+84
gen bd_month=month(birthday)
gen bd_day=day(birthday)
/// combine day month year to for date of 85th birthday
gen bd84 = mdy(bd_month, bd_day, bd_year)
format bd84 %td
drop bd_year bd_month bd_day

***********************************************
**** date and age functions...
/// age at visit using personage
ssc install personage 
/// the exact age
personage birthday date, gen(age1 age2 age3)

******************************************************

/// death date
rename deathdate deathd
gen deathdate=date(deathd,"YMD")
format deathdate %td
drop deathd
/// migration dates
rename reg_migr_date1 regmigrdate1 
gen reg_migr_date1=date(regmigrdate1,"YMD")
format reg_migr_date1 %td
drop regmigrdate1
destring region_orig1, replace
destring region_dest1, replace
/// 2
rename reg_migr_date2 regmigrdate2 
gen reg_migr_date2=date(regmigrdate2,"YMD")
format reg_migr_date2 %td
drop regmigrdate2
destring region_orig2, replace
destring region_dest2, replace
/// 3
rename reg_migr_date3 regmigrdate3 
gen reg_migr_date3=date(regmigrdate3,"YMD")
format reg_migr_date3 %td
drop regmigrdate3
destring region_orig3, replace
destring region_dest3, replace
/// migration dates em/im
rename migr_date1 migrdate1
gen migr_date1=date(migrdate1,"YMD")
format migr_date1 %td
rename migr_date2 migrdate2
gen migr_date2=date(migrdate2,"YMD")
format migr_date2 %td
rename migr_date3 migrdate3
gen migr_date3=date(migrdate3,"YMD")
format migr_date3 %td
rename migr_date4 migrdate4
gen migr_date4=date(migrdate4,"YMD")
format migr_date4 %td
drop migrdate1
drop migrdate2 migrdate4 migrdate3


/// count the number of migrations
drop migr
gen migr1=1
replace migr1=0 if reg_migr_date1==. 
gen migr2=1
replace migr2=0 if reg_migr_date2==. 
gen migr3=1
replace migr3=0 if reg_migr_date3==. 
gen migr4=1
replace migr4=0 if migr_date1==. 
gen migr5=1
replace migr5=0 if migr_date2==. 
gen migr6=1
replace migr6=0 if migr_date3==. 
gen migr7=1
replace migr7=0 if migr_date4==. 
gen migr=migr1+migr2+migr3+migr4+migr5+migr6+migr7
drop migr1 migr2 migr3 migr4 migr5 migr6 migr7

/////
order id birthday birthyear gender backg kids  deathdate mort migr ///
 reg_migr_date1 region_orig1 region_dest1 reg_migr_date2 region_orig2 region_dest2 reg_migr_date3 ////
region_orig3 region_dest3 migr migr_date1 em_im1 migr_date2 em_im2 migr_date3 em_im3 migr_date4 em_im4


/// sort out the region-problem for the movers... 
/// region2013 is the correct region to use to calc cell_death and cell_migr if never moved. 
gen reg_resi=region2013 if migr==0
/// for those that due migrate during the time period, I have to go through what region to use

/// migr==1 (emmigration) - region2013 is correct
replace reg_resi=region2013 if migr==1 & em_im1=="Utv" 
/// 156 ind
/// migr==1 (within swe) - region2013 is correct for those that doesn't move from sthlm/vgr to vgr/sthlm
replace reg_resi=region2013 if migr==1 & region_orig1==1 & region_dest1!=14 
/// 334 ind
replace reg_resi=region2013 if migr==1 & region_orig1==14 & region_dest1!=1
/// 193 ind
/// move sthlm-vgr or vrg-sthlm in 2014 or 2015 - use region of destination
replace reg_resi=region_dest1 if migr==1 & region_dest1==1 & reg_migr_date1<td(01jan2016)
replace reg_resi=region_dest1 if migr==1 & region_dest1==14 & reg_migr_date1<td(01jan2016)
/// move sthl-vgr in 2016 - use region of origin
replace reg_resi=region_orig1 if migr==1 & region_dest1==14 & reg_migr_date1>=td(01jan2016) & reg_migr_date1<td(01jan2017)
/// move vgr-sthlm in 2016 - use region of destination
replace reg_resi=region_dest1 if migr==1 & region_dest1==1 & reg_migr_date1>=td(01jan2016) & reg_migr_date1<td(01jan2017)
/// move sthlm-vgr or vrg-sthlm in 2017- use region of origin
replace reg_resi=region_orig1 if migr==1 & region_dest1==1 & reg_migr_date1>=td(01jan2017)
replace reg_resi=region_orig1 if migr==1 & region_dest1==14 & reg_migr_date1>=td(01jan2017)

/// migr==2
/// if move from sthlm-other-sthlm or vgr-other-sthlm use region_orig1
replace reg_resi=region_orig1 if migr==2 & region_orig1==region_dest2
/// move sthlm-other-vgr
replace reg_resi=region_dest2 if migr==2 & region_orig1==1 & region_dest2==14
/// move vgr-other-emmi or sthlm-other-emmi
replace reg_resi=region_orig1 if migr==2 & region_orig1==14 & em_im1=="Utv"
replace reg_resi=region_orig1 if migr==2 & region_orig1==1 & em_im1=="Utv"
/// move sthlm-emmi-sthlm or vgr-emmi-vgr
replace reg_resi=region2013 if migr==2 & em_im1=="Utv" & em_im2=="Inv"

/// migr==3
/// move sthlm-other-sthlm-other or vgr-pthr-vgr-other
replace reg_resi=region_orig1 if migr==3 & region_orig1==region_orig3
/// move sthlm-other-sthlm-emmi
replace reg_resi=region_orig1 if migr==3 & region_orig1==region_dest2
/// emmi-vgr-other or emmi-other-vgr or emmi-immi-emmi use region2013
replace reg_resi=region2013 if migr==3 & em_im1=="Utv" & em_im2=="Inv"

/// migr==4 
replace reg_resi=region2013 if migr==4

save sample.dta, replace

order id birthday birthyear gender backg region2013 region2014 region2015 region2016 region2017 reg_resi hit

************************

/// the deathdate and migr dates, on what cell_day?

/// cell_death in relation to 85 bd
gen cell_death85=deathdate-bd85
/// cell_death in relation to 84 bd
gen cell_death84=deathdate-bd84


/// migration dates only in relation to 85 bd 
gen cell85_reg_migr1=reg_migr_date1-bd85 
gen cell85_reg_migr2=reg_migr_date2-bd85 
gen cell85_reg_migr3=reg_migr_date3-bd85 
gen cell85_migr1=migr_date1-bd85 
gen cell85_migr2=migr_date2-bd85 
gen cell85_migr3=migr_date3-bd85 
gen cell85_migr4=migr_date4-bd85 
/// migration dates only in relation to 84 bd 
gen cell84_reg_migr1=reg_migr_date1-bd84 
gen cell84_reg_migr2=reg_migr_date2-bd84 
gen cell84_reg_migr3=reg_migr_date3-bd84 
gen cell84_migr1=migr_date1-bd84 
gen cell84_migr2=migr_date2-bd84 
gen cell84_migr3=migr_date3-bd84 
gen cell84_migr4=migr_date4-bd84


* in relation to 85th who is to be included +/-1 years 
/// mark up inclusion/exclusion due to death or migration
gen incl_1y85=1
label variable incl_1y85 "indivual included in +/-1 years of 85 bd "
/// people who die before -1y
replace incl_1y85=0 if cell_death85<-365

/// migr==1
/// people who migrate only once and before time period
replace incl_1y85=0 if migr==1 & cell85_reg_migr1<-365 & region_dest1>1 & region_dest1!=14 
/// emmigrated before
replace incl_1y85=0 if migr==1 & cell85_migr1<-365 
/// migr==2 - just a few with 2 or more... 
/// move from sthlm-other-sthlm or vgr-other-vgr or vgr-other-sthlm or sthlm-other-vgr
/// and doesnt return within +-2y
replace incl_1y85=0 if migr==2 & cell85_reg_migr1<-365 & cell85_reg_migr2>365 & region_dest2==1 
replace incl_1y85=0 if migr==2 & cell85_reg_migr1<-365 & cell85_reg_migr2>365 & region_dest2==14 
/// move vgr-other-emmi or sthlm-other-emmi
replace incl_1y85=0 if migr==2 & cell85_reg_migr1<-365 & cell85_migr1<-365 
/// emmmi before 2y, immi after 2y
replace incl_1y85=0 if migr==2 & cell85_migr1<-365 & cell85_migr2>365 & em_im2=="Inv"
/// migr==3 move 
replace incl_1y85=0 if migr==3 & cell85_reg_migr3<-365 & region_dest3>1 & region_dest3!=14 
replace incl_1y85=0 if migr==3 & cell85_reg_migr1<-365 & cell85_reg_migr2<-365 & cell85_migr1<-365 
replace incl_1y85=0 if migr==3 & cell85_reg_migr1<-365 & cell85_migr1<-365 & cell85_migr2<-365
replace incl_1y85=0 if migr==3 & cell85_migr1<-365 & cell85_migr2<-365 & cell85_migr3<-365
/// migr==4 utv-inv-uvt-inv innan 6m ok 
replace incl_1y85=0 if migr==4 & cell85_migr4<-365


/// order and compress
order id birthday birthyear reg_resi gender backg kids hit bd85 bd84 deathdate cell_death85 cell_death84
sort id
compress
save sample.dta, replace





/// background variables
/// bring in variables from sample.dta to cells_1y.dta
use sample.dta
/// variables to keep 
keep id reg_resi birthyear gender bd85 cell_death85 cell85_reg_migr1 cell85_migr1 incl_1y85 migr
save temp.dta, replace

/// merge sample vars into cells_2y_base.dta
use cells_1y_base.dta
merge m:1 id using temp.dta
drop _merge
save cells_new_1y.dta

/// create running variable for time (cell_time)
/// gen cell_time
gen date = bd85+cell_day
format date %td
gen cell_time = date-td(01jan2016)
label variable cell_time "running time in relation to 1 jan 2016"
label variable cell_day "running time in relation to 85 bd"


/// Inclusion, of inds of each cell
/// put missing in incl_1y85 for people who die or migrate or cant be followed in data
* those who shouldnt be included for the whole period
replace incl_1y85=. 	if incl_1y85==0
* those who are included for part of the period
/// people who die +/- 1y   - use cell_death85
replace incl_1y85=. 	if cell_death85<cell_day
/// people who migrate and doesnt return, migr==1 
/// regional migr
replace incl_1y85=. 	if migr==1 & cell85_reg_migr1<cell_day
/// emmigr
replace incl_1y85=. 	if migr==1 & cell85_migr1<cell_day
/// migr>=2 ignore

* can follow all 1 year after 85 bd? no. 
///  b.1933 85bd in 2018
 replace incl_1y85=. 	if cell_day > (td(31dec2018)-bd85)
/// can follow all 1 year before 85 bd? no.
///  b.1930 85bd in 2015 --  VGR (Sthlm OK)
/// for vgr: data from 1jan2015
replace incl_1y85=. 	if cell_day < (td(01jan2015)-bd85) & reg_resi==14

* censor 4 months before hit by policy
gen incl_1y85_cens=incl_1y85
/// those born 1930 & 1931 - hit by policy Jan 1 - censor them from Sept 1 the year before
/// for sthlm b.1930: hit by polic Jan 1 2016, censor from Sept 1 2015
replace incl_1y85_cens=. if cell_time > (td(31aug2015)-td(01jan2016)) & reg_resi==1 & birthyear==1930
/// for vgr b.1930 & 1931: hit by polic Jan 1 2017, censor from Sept 1 2016
replace incl_1y85_cens=. 	if cell_time > (td(01sep2016)-td(01jan2017)+365) & reg_resi==14 & birthyear<=1931
label variable incl_1y85 "var to calc number of individuals per daycell -based on cell 85"
label variable incl_1y85_cens "censoring sept-dec 2015/2016"


/// drop other vars that aren't needed for regressions
drop migr gender cell85_reg_migr1 cell85_migr1 cell_death85
order id cell_day cell_week cell_month no_fee cell_time date bd85 reg_resi birthyear
compress
save cells_new_1y.dta








