*===============================================================================
*Last modified: 7/18/2023
*Import and clean IPUMS Mexican CENSUS databases
*===============================================================================

clear all

*SPECIFY LOCAL ENVIROMENT
*global LOCALD "...\Replication-folder"

use "$LOCALD\Data\IPUMS-original.dta", clear

********************************************************************************
*MERGE: Combine dataset with geographical information and commuting zone classification.

*merging the transitional database
merge m:1 geolev2 using "$LOCALD\Data\trans2.dta"
drop _merge

*merging the shapefile databasestat
merge m:1 id2 using "$LOCALD\Data\mexico_db2.dta"
drop _merge

*merge with commuting zones classification from Faber, M. (2020). Robots and reshoring: Evidence from Mexican labor markets. Journal of International Economics, 127.
merge m:1 geo2_mx using "$LOCALD\Data\crosswalk_geo2_mx_cz.dta"
drop _merge

********************************************************************************
*VAR: recode sex

recode sex (2 = 0 "Female") (1 = 1 "Male") (9 = .), gen(sexo)
drop if sexo == . /*12 observations have missing values for sex*/
drop sex
rename sexo sex

label var sex "=1 if male, =0 if female"

********************************************************************************
*VAR: tp: identifies individuals who are participating in the labor force 

gen tp = .

**1960
replace tp = 0 if year==1960
replace tp = 1 if ((classwkd>=110 & classwkd<=310) | (mx1960a_daywk>0 & mx1960a_daywk<=7) | (mx1960a_lookwork==1 | mx1960a_lookwork==2)) & year==1960

*1970, 1990, 2000, 2010, 2015
replace tp = 1 if (empstat==1 | empstat==2)  & year!=1960
replace tp = 0 if (empstat==3) & year!=1960

replace tp = 1 if (mx1970a_classwkr>=1 & mx1970a_classwkr<=6 & empstat!=1 & empstat!=2) & year==1970

label var tp "=1 if in labor force; =0 otherwise"


********************************************************************************
*VAR: occisco and indgen

replace occisco = . if occisco == 98 | occisco == 99
replace occisco = . if tp==0 /*only individuals classified as being part of the workforce, 416 misclassified*/
label var occisco "1 digit occupation classification, 11 groups" 


replace indgen = . if indgen == 0 | indgen == 999
replace indgen = . if tp==0 /*only individuals classified as being part of the workforce, 416 misclassified*/
label var indgen "1 digit industrial classification, 16 groups"


********************************************************************************
*VAR: educ

recode edattaind (110 120 212 = 1 "Primary or Less") (221 222 311 321 =2 "Secondary") (312 322 400 = 3 "Tertiary") (999=.), gen(educG)
label var educG "=1 if primary; =2 if secondary; =3 if tertiary"

tab educG, gen(educG_)
label var educG_1 "=1 if primary or less; =0 otherwise"
label var educG_2 "=1 if secondary; =0 otherwise"
label var educG_3 "=1 if Tertiary; =0 otherwise"

*VAR: age sq
gen agesq = age*age
label var agesq "age squared"

*VAR: marriage
recode marst (2 = 2 "Married/Perm. Union") (1 3 4 =1 "Single/Separated/Widowed") (9 = .), gen(marstG)
tab marstG, gen(marstG_)

*VAR: children below age 5, above age 5, and childless
recode nchild nchlt5 (10/98 = .)
gen nchltM5 = nchild-nchlt5
label var nchltM5 "number of children above age 5"

recode chborn (98/99 = .)
gen childless = 0 if chborn>= 1 & chborn<=30
replace childless = 1 if chborn==0
label var childless "=1 if Childless; =0 otherwise"

gen childEverBorn =  (1-childless)
label var childEverBorn "=1 if child ever born;=0 otherwise"

********************************************************************************
compress
save "$LOCALD\Data\main.dta", replace
