*===============================================================================
*Last modified: 7/18/2023
*Creates the main figures in the paper
*===============================================================================

clear all

*SPECIFY LOCAL ENVIROMENT
*global LOCALD "...\Replication-folder"

********************************************************************************
*FIGURE 1
use "$LOCALD\Data\main.dta", clear

collapse tp [fw=perwt], by(year sex)
replace tp = tp*100
format tp %10.1f

twoway (connected tp year if sex==0, lcolor(black) lpattern(solid) mcolor(black) mlabel(tp) mlabposition(5) msymbol(diamond) msize(small) lwidth(*1.0)), ///
		ytitle("Female LFP Rate (x 100)",) ylabel(10(10)50.0, angle(0) format(%10.0f)) xlabel(1960(10)2020,) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(off) ///
		scheme(s1mono)
gr export "$LOCALD\Figures\\fig-1-flfp.eps", replace


********************************************************************************
*FIGURE 2 - Histograms FLFP
use "$LOCALD\Data\main.dta", clear

gen N=1
collapse (sum) N (mean) tp [pw=perwt], by(sex year cz)

replace tp = tp*100
format tp %12.0fc

twoway  (hist tp if sex==0 & year==1960, frac bin(20) fcolor(gs14) lcolor(gs14)) /// 
		(hist tp if sex==0 & year==1990, frac bin(20) fcolor(gs10) lcolor(gs10)) ///
		(hist tp if sex==0 & year==2000, frac bin(20) fcolor(gs5) lcolor(gs5)) ///
		(hist tp if sex==0 & year==2015, frac bin(20) fcolor(gs1) lcolor(gs1)), /// 
		legend(region(fcolor(none) lcolor(none)) col(2)) legend(order(1 "1960" 2 "1990" 3 "2000" 4 "2015")) ////
		xtitle("Female LFP Rate") scheme(s1mono)
graph export "$LOCALD\Figures\\fig-2-hist-flfp-by-year.eps", replace


********************************************************************************
*FIGURE 3. MAPS BY CZ AND CENSUS YEARS 
use "$LOCALD\Data\main.dta", clear

preserve
	collapse (mean) tp [pw=perwt], by(sex year cz)
	rename tp tp_cz
	tempfile tp_cz
	save "`tp_cz'"
restore

collapse (mean) tp [pw=perwt], by(sex year cz id2 geolev2)
merge m:1 sex year cz using "`tp_cz'"
drop _merge

replace tp = tp_cz*100
format tp %12.0fc

foreach year in 1960 1970 1990 2000 2010 2015 {
	spmap tp using "$LOCALD\Data\mexico_coord2" if sex==0 & year==`year', id(id2) /// 
		clnumber(7) clmethod(custom) clbreaks(0.0 10.0 20.0 30.0 40.0 50.0 60.0 100) /// 
		fcolor(Greys2) /// 
		legstyle(2) legend(pos(7) size(2.8) region(fcolor(gs15))) ///
		ocolor(white ..) osize(0.001 ..) ////
		legend(size(large)) 
	gr export "$LOCALD\Figures\\fig-3-maps-flfp-`year'.png", replace
}


********************************************************************************
*FIGURE 4. MAPS BY CZ. CHANGE ACROSS YEARS 
use "$LOCALD\Data\main.dta", clear

preserve
	collapse (mean) tp [pw=perwt], by(sex year cz)
	rename tp tp_cz
	tempfile tp_cz
	save "`tp_cz'"
restore

collapse (mean) tp [pw=perwt], by(sex year cz id2 geolev2)
merge m:1 sex year cz using "`tp_cz'"
drop _merge

replace tp = tp_cz*100
format tp %12.0fc

drop tp_cz
reshape wide tp, i(sex id2 cz geolev2) j(year)

gen tp_2015v1960 = tp2015 - tp1960

format tp_2015v1960 %12.0fc

spmap tp_2015v1960 using "$LOCALD\Data\mexico_coord2" if sex==0, id(id2) ///
	clnumber(7) clmethod(custom) clbreaks(-100 0 5 10 15 20 25 30 35 40 100) ///
	fcolor(Greys2) ///
	legstyle(2) legend(pos(7) size(2.8) region(fcolor(gs15))) ///
	ocolor(white ..) osize(0.001 ..) ////
	legend(size(large))
gr export "$LOCALD\Figures\\\fig-4-map-flfp-dif-2015v1960.png", replace


********************************************************************************
*FIGURE 5 - PANEL A: EDUC ATTAINMENT SHARES
use "$LOCALD\Data\main.dta", clear

collapse (mean) educG_1 educG_2 educG_3 [fw=perwt], by(year sex)
foreach var in educG_1 educG_2 educG_3 {
    replace `var' = `var'*100
}

format educG_1 educG_2 educG_3 %10.0f

twoway  (connected educG_1 year if sex==0, lcolor(black) lpattern(solid) mcolor(black) mlabel(educG_1) mlabposition(6)  msymbol(triangle) msize(small) lwidth(*1.0)) ///
		(connected educG_2 year if sex==0, lcolor(black) lpattern(dash)  mcolor(black) mlabel(educG_2) mlabposition(12) msymbol(square)   msize(small) lwidth(*1.0)) ///
		(connected educG_3 year if sex==0, lcolor(gs10)  lpattern(solid) mcolor(gs10)   mlabel(educG_3) mlabposition(4)  msymbol(diamond)  msize(small) lwidth(*1.0)), ///
		ytitle("Share of Females (x 100)",  ) ylabel(,angle(0)) xlabel(1960(10)2020,) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order(1 "Primary or Less" 2 "Secondary" 3 "Tertiary") col(1)) ///
		scheme(s1mono) 
gr export "$LOCALD\Figures\\fig-5-panel-a-educ-shares.eps", replace

*FIGURE 5 - PANEL B: PARTICIPATION BY EDUC ATTAINMENT
use "$LOCALD\Data\main.dta", clear

collapse (mean) tp [fw=perwt], by(year sex educG)
replace tp = tp*100
format tp %10.0f

twoway  (connected tp year if sex==0 & educG==1, lcolor(black) lpattern(solid) mcolor(black) mlabel(tp) mlabposition(6)   msymbol(triangle) msize(small) lwidth(*1.0)) ///
		(connected tp year if sex==0 & educG==2, lcolor(black) lpattern(dash) mcolor(black)  mlabel(tp) mlabposition(12)  msymbol(square)   msize(small) lwidth(*1.0)) ///
		(connected tp year if sex==0 & educG==3, lcolor(gs10)  lpattern(solid) mcolor(gs10)  mlabel(tp) mlabposition(4)   msymbol(diamond)  msize(small) lwidth(*1.0)), ///
		ytitle("Female LFP Rate (x 100)",  ) ylabel(0(20)100,angle(0)) xlabel(1960(10)2020,) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order(1 "Primary or Less" 2 "Secondary" 3 "Tertiary") col(1)) ///
		scheme(s1mono) 
gr export "$LOCALD\Figures\\fig-5-panel-b-flfp-by-educ.eps", replace


********************************************************************************
*FIGURE 6 - PANEL A: FERTILITY SHARES
use "$LOCALD\Data\main.dta", clear

collapse nchlt5 nchltM5 childEverBorn [fw=perwt], by(year sex)

replace childEverBorn =  100*childEverBorn
format nchlt5 nchltM5 %10.1f
format childEverBorn %10.0f

twoway  (connected nchlt5 year if sex==0, lcolor(black) lpattern(solid) mcolor(black) mlabel(nchlt5) mlabposition(6) msymbol(triangle) msize(small) lwidth(*1.0)) ///
		(connected nchltM5 year if sex==0, lcolor(black) lpattern(dash) mcolor(black) mlabel(nchltM5) mlabposition(6) msymbol(square) msize(small) lwidth(*1.0)) ///
		(connected childEverBorn year if sex==0, lcolor(gs10) lpattern(solid) mcolor(gs10) mlabel(childEverBorn)  mlabposition(12) msymbol(diamond) msize(small) lwidth(*1.0) yaxis(2)), ///
		ytitle("Number of Own Children in the Howsehold",) xlabel(1960(10)2020,) ylabel(0(1)3,) ylabel(60(10)100, axis(2)) ytitle("Share with Child Ever Born (x 100)", axis(2)) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(2)) legend(order(1 "Number of Own Children Below Age 5 in Household" 2 "Number of Own Children Above Age 5 in Household" 3 "Child Ever Born (Right Axis)") col(1)) ///
		scheme(s1mono)
gr export "$LOCALD\Figures\\fig-6-panel-a-fertility-shares.eps", replace 

*FIGURE 6 - PANEL B: FLFP by FERTILITY
use "$LOCALD\Data\main.dta", clear

gen dnchlt5=0 if nchlt5!=.
replace dnchlt5=1 if nchlt5>0 & nchlt5!=.

gen dnchltM5=0 if nchltM5!=.
replace dnchltM5=1 if nchltM5>0 & nchltM5!=.

gen tp_dnchlt5 = tp if dnchlt5 == 1
gen tp_dnchltM5 = tp if dnchltM5 == 1
gen tp_childEverBorn = tp if childEverBorn == 1
gen tp_childEverBornN = tp if childEverBorn == 0

collapse (mean) tp_dnchlt5 tp_dnchltM5 tp_childEverBorn tp_childEverBornN [fw=perwt], by(year sex)

foreach var in tp_dnchlt5 tp_dnchltM5 tp_childEverBorn tp_childEverBornN { 
	replace `var' = `var'*100
	}

format tp_dnchlt5 tp_dnchltM5 tp_childEverBorn tp_childEverBornN %10.0f

twoway 	(connected tp_dnchlt5 year if sex==0, lcolor(black) lpattern(solid) mcolor(black) mlabel(tp_dnchlt5)       mlabposition(6)  msymbol(triangle) msize(small) lwidth(*1.0) yaxis(1)) ///
		(connected tp_dnchltM5 year if sex==0, lcolor(black)  lpattern(dash) mcolor(black)  mlabel(tp_dnchltM5)      mlabposition(6)   msymbol(square)   msize(small) lwidth(*1.0) yaxis(1)) ///
		(connected tp_childEverBorn year if sex==0, lcolor(gs10)   lpattern(solid) mcolor(gs10)   mlabel(tp_childEverBorn) mlabposition(12)   msymbol(diamond)  msize(small) lwidth(*1.0) yaxis(1)) ///
		(connected tp_childEverBornN year if sex==0, lcolor(gs10)   lpattern(dash) mcolor(gs10)   mlabel(tp_childEverBornN) mlabposition(12) msymbol(circle)  msize(small) lwidth(*1.0) yaxis(1)), ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ylabel(0(10)70) ///
		legend(region(fcolor(none) lcolor(none)) col(2)) legend(order(1 "With Children Under Age 5 in Household" 2 "With Children Above Age 5 in Household" 3 "With Child Ever Born" 4 "No Child Ever Born") col(1)) ///
		scheme(s1mono)
gr export "$LOCALD\Figures\\fig-6-panel-b-flfp-by-fertility.eps", replace


********************************************************************************
*FIGURE 7 - PANEL A: MARITAL STATUS SHARES
use "$LOCALD\Data\main.dta", clear

collapse (mean) marstG_1 marstG_2 [fw=perwt], by(year sex)

replace marstG_2 = marstG_2*100
replace marstG_1 = marstG_1*100

format marstG_1 marstG_2 %10.0f

twoway 	(connected marstG_2 year if sex ==0, lcolor(black)  lpattern(solid) mcolor(black) mlabel(marstG_2) mlabposition(6)   msymbol(diamond) msize(small) lwidth(*1.0) yaxis(1)), ///
		ytitle("Share of Females Married/Permanent Partner (x 100)",  ) ylabel(,angle(0))  xlabel(1960(10)2020,) ylabel(90(10)60,) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(2)) legend(order(1 "Male" 2 "Female") col(1)) ///
		scheme(s1mono)
gr export "$LOCALD\Figures\\fig-7-panel-a-marital-status-shares.eps", replace

*FIGURE 7 - PANEL B: FLFP by MARITAL STATUS 
use "$LOCALD\Data\main.dta", clear

collapse tp [fw=perwt], by(year sex marstG)
replace tp = tp*100
format tp %10.0f

twoway 	(connected tp year if sex==0 & marstG==1, lcolor(black)  lpattern(solid) mcolor(black) mlabel(tp) mlabposition(12)   msymbol(diamond) msize(small) lwidth(*1.0) yaxis(1)) ///
		(connected tp year if sex==0 & marstG==2, lcolor(black)  lpattern(dash)  mcolor(black)  mlabel(tp) mlabposition(12)   msymbol(square)  msize(small) lwidth(*1.0) yaxis(1)), ///
		ytitle("Female LFP Rate (x 100)",  ) ylabel(0(20)80,angle(0))  xlabel(1960(10)2020,) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) row(2)) legend(order(1 "Single or Divorced" 2 "Married or with Permanent Partner")) ///
		scheme(s1mono)
gr export "$LOCALD\Figures\\fig-7-panel-b-flfp-by-marital-status.eps", replace


********************************************************************************
*FIGURE 8 - Female Employment Share and Occupation Share of Employment
use "$LOCALD\Data\main.dta", clear

*COLLAPSE: YEAR, SEX, OCC
keep if tp==1
gen N=1
collapse (sum) N [fw=perwt], by(year sex occisco)
reshape wide N, i(year occisco) j(sex)
recode N0 N1 (.=0)

*VAR: FEMALE SHARE
gen NTotOcc = N0+N1
gen femShareOcc=N0/(NTotOcc)
gen malShareOcc = 1-femShareOcc
gsort- femShareOcc

replace femShareOcc = femShareOcc*100
format femShareOcc %10.0f

*VAR: OCC SHARE
bys year: egen NOccShare = total(NTotOcc)
replace NOccShare = NTotOcc/NOccShare

replace NOccShare = NOccShare*100
format NOccShare %10.0f

* PANEL A. Female Employment Share in "Male Occupations"
twoway 	(connected femShareOcc year if occisco==7, lcolor(black)  mlabel(femShareOcc) mlabposition(6)   lpattern(solid) mcolor(black) msymbol(triangle) msize(small) lwidth(*1.0)) ///
		(connected femShareOcc year if occisco==1, lcolor(black)   mlabel(femShareOcc) mlabposition(12)   lpattern(dash) mcolor(black)  msymbol(square)   msize(small) lwidth(*1.0)) ///
		(connected femShareOcc year if occisco==8, lcolor(gs10)    mlabel(femShareOcc) mlabposition(6)     lpattern(solid) mcolor(gs10)   msymbol(diamond)  msize(small) lwidth(*1.0)), ///
		ytitle("Female Share X 100", ) ylabel(0(10)50,) xlabel(1960(10)2020,) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order(1 "Crafts and Related Trades" 2 "Managers" 3 "Plant and Machine Operators" )) ///
		scheme(s1mono)
graph export "$LOCALD\Figures\/fig-8-panel-a-empShareFem-maleOcc.eps", replace

* PANEL B. Female Employment Share in "Female Occupations"
twoway 	(connected femShareOcc year if occisco==3, lcolor(black)  mlabel(femShareOcc) mlabposition(6)   lpattern(solid) mcolor(black) msymbol(triangle) msize(small) lwidth(*1.0)) ///
		(connected femShareOcc year if occisco==4, lcolor(black)   mlabel(femShareOcc) mlabposition(12)   lpattern(dash) mcolor(black)  msymbol(square)   msize(small) lwidth(*1.0)) ///
		(connected femShareOcc year if occisco==5, lcolor(gs10)    mlabel(femShareOcc) mlabposition(6)     lpattern(solid) mcolor(gs10)   msymbol(diamond)  msize(small) lwidth(*1.0)), ///
		ytitle("Female Share X 100", ) ylabel(15(10)65,) xlabel(1960(10)2020,) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order(1 "Technicians/Associate Professionals" 2 "Clerks" 3 "Service/Sales")) ///
		scheme(s1mono)
graph export "$LOCALD\Figures\/fig-8-panel-b-empShareFem-femaleOcc.eps", replace

* PANEL C. Occupation Share of Employment, "Male Occupations"
twoway 	(connected NOccShare year if occisco==7, lcolor(black)  mlabel(NOccShare) mlabposition(6)   lpattern(solid) mcolor(black) msymbol(triangle) msize(small) lwidth(*1.0)) ///
		(connected NOccShare year if occisco==1, lcolor(black)   mlabel(NOccShare) mlabposition(12)   lpattern(dash) mcolor(black)  msymbol(square)   msize(small) lwidth(*1.0)) ///
		(connected NOccShare year if occisco==8, lcolor(gs10)    mlabel(NOccShare) mlabposition(6)     lpattern(solid) mcolor(gs10)   msymbol(diamond)  msize(small) lwidth(*1.0)), ///
		ytitle("Occupation Share X 100", axis(1)) ylabel(0(5)25,) xlabel(1960(10)2020,) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order( 1 "Crafts and Related Trades" 2 "Managers" 3 "Plant and Machine Operators")) ///
		scheme(s1mono)
graph export "$LOCALD\Figures\/fig-8-panel-c-empShareOcc-maleOcc.eps", replace

* PANEL D. Occupation Share of Employment, "Female Occupations"
twoway 	(connected NOccShare year if occisco==3, lcolor(black)  mlabel(NOccShare) mlabposition(6)   lpattern(solid) mcolor(black) msymbol(triangle) msize(small) lwidth(*1.0)) ///
		(connected NOccShare year if occisco==4, lcolor(black)   mlabel(NOccShare) mlabposition(12)   lpattern(dash) mcolor(black)  msymbol(square)   msize(small) lwidth(*1.0)) ///
		(connected NOccShare year if occisco==5, lcolor(gs10)    mlabel(NOccShare) mlabposition(6)     lpattern(solid) mcolor(gs10)   msymbol(diamond)  msize(small) lwidth(*1.0)), ///
		ytitle("Occupation Share X 100", ) ylabel(0(5)25,) xlabel(1960(10)2020,) ///
		xlabel(, angle(45)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.25) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order(1 "Technicians/Associate Professionals" 2 "Clerks" 3 "Service/Sales")) ///
		scheme(s1mono)
graph export "$LOCALD\Figures\/fig-8-panel-d-empShareOcc-femaleOcc.eps", replace


********************************************************************************
*FIGURE 9 - Female Employment Share and Sectoral Share of Employment
use "$LOCALD\Data\main.dta", clear

keep if tp==1
gen N=1
collapse (sum) N [fw=perwt], by(year sex indgen)
reshape wide N, i(year indgen) j(sex)
recode N0 N1 (.=0)

*VAR: FEMALE SHARE
gen NTotSec = N0+N1
gen femShareSec=N0/(NTotSec)
gen malShareSec = 1- femShareSec
gsort- femShareSec

replace femShareSec = femShareSec*100
format femShareSec %10.0f

*VAR: SEC SHARE
bys year: egen NSecShare = total(NTotSec)
replace NSecShare = NTotSec/NSecShare

replace NSecShare = NSecShare*100
format NSecShare %10.0f

* PANEL A. Female Employment Share in "Female Sectors"
twoway 	(connected femShareSec year if indgen==50, lcolor(black) mlabel(femShareSec) mlabposition(6) lpattern(solid) mcolor(black) msymbol(circle) msize(small) lwidth(*1.5)) ///
		(connected femShareSec year if indgen==10, lcolor(black)  mlabel(femShareSec) mlabposition(12) lpattern(dash) mcolor(black) msymbol(square) msize(small) lwidth(*1.5)) ///
		(connected femShareSec year if indgen==30, lcolor(gs10)   mlabel(femShareSec) mlabposition(12) lpattern(solid) mcolor(gs10) msymbol(X) msize(small) lwidth(*1.5)), ///
		ytitle("Female Share X 100", ) ylabel(0(10)50,) xlabel(1960(10)2020,) ///
		xlabel(, angle(forty_five)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.5) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order(1  "Construction" 2 "Agriculture, Fishing, and Forestry" 3 "Manufacturing")) ///
		scheme(s1mono)
graph export "$LOCALD\Figures\/fig-9-panel-a-empShareFem-maleSec.eps", replace

* PANEL B. Female Employment Share in "Male Sectors"
twoway 	(connected femShareSec year if indgen==112, lcolor(black) mlabel(femShareSec) mlabposition(6)  lpattern(solid) mcolor(black) msymbol(+) msize(small) lwidth(*1.0)) ///
		(connected femShareSec year if indgen==113, lcolor(black)  mlabel(femShareSec) mlabposition(12) lpattern(dash) mcolor(black) msymbol(circle) msize(small) lwidth(*1.0)) ///
		(connected femShareSec year if indgen==60, lcolor(gs10)    mlabel(femShareSec) mlabposition(12) lpattern(solid) mcolor(gs10) msymbol(square) msize(small) lwidth(*1.0)), ///
		ytitle("Female Share X 100", ) ylabel(20(10)70,) xlabel(1960(10)2020,) ///
		xlabel(, angle(forty_five)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.5) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order(1 "Education" 2 "Health/Social Work" 3 "Wholesale/Retail Trade")) ///
		scheme(s1mono)
graph export "$LOCALD\Figures\/fig-9-panel-b-empShareFem-femaleSec.eps", replace

* PANEL C. Occupation Share of Employment, "Female Sectors"
twoway 	(connected NSecShare year if indgen==50, lcolor(black) mlabel(NSecShare) mlabposition(6) lpattern(solid) mcolor(black) msymbol(circle) msize(small) lwidth(*1.5)) ///
		(connected NSecShare year if indgen==10, lcolor(black)  mlabel(NSecShare) mlabposition(12) lpattern(dash) mcolor(black) msymbol(square) msize(small) lwidth(*1.5)) ///
		(connected NSecShare year if indgen==30, lcolor(gs10)   mlabel(NSecShare) mlabposition(12) lpattern(solid) mcolor(gs10) msymbol(X) msize(small) lwidth(*1.5)), ///
		ytitle("Sector Share X 100", ) ylabel(0(10)40,) xlabel(1960(10)2020,) ///
		xlabel(, angle(forty_five)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.5) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order(1  "Construction" 2 "Agriculture, Fishing, and Forestry" 3 "Manufacturing")) ///
		scheme(s1mono)
graph export "$LOCALD\Figures\/fig-9-panel-c-empShareSec-maleSec.eps", replace

* PANEL D. Occupation Share of Employment, "Male Sectors"
twoway 	(connected NSecShare year if indgen==112, lcolor(black) mlabel(NSecShare) mlabposition(12) lpattern(solid) mcolor(black) msymbol(+) msize(small) lwidth(*1.5)) ///
		(connected NSecShare year if indgen==113, lcolor(black)  mlabel(NSecShare) mlabposition(6) lpattern(dash) mcolor(black) msymbol(circle) msize(small) lwidth(*1.5)) ///
		(connected NSecShare year if indgen==60, lcolor(gs10)  mlabel(NSecShare) mlabposition(6) lpattern(solid) mcolor(gs10) msymbol(square) msize(small) lwidth(*1.5)), ///
		ytitle("Sector Share X 100", ) ylabel(0(10)40,) xlabel(1960(10)2020,) ///
		xlabel(, angle(forty_five)) xtitle("") xline(1990 2000, lpattern(dash) lwidth(*0.5) lcolor(black)) ///
		legend(region(fcolor(none) lcolor(none)) col(1)) legend(order(1 "Education" 2 "Health/Social Work" 3 "Wholesale/Retail Trade")) ///
		scheme(s1mono)
graph export "$LOCALD\Figures\/fig-9-panel-d-empShareSec-femaleSec.eps", replace


********************************************************************************
*FIGURE 10 - Scatters change in FLFP
use "$LOCALD\Data\main.dta", clear

gen N=1

collapse (sum) N educG_1 educG_2 educG_3 marstG_1 childEverBorn (mean) tp nchlt5 marstG_2 [fw=perwt], by(year sex cz)

reshape wide N tp educG_1 educG_2 educG_3 marstG_1 marstG_2 childEverBorn nchlt5, i(cz sex) j(year)

*2015-1960
gen D_FLFP = tp2015 - tp1960
gen D_EdG3 = log(educG_32015+1)- log(educG_31960+1)
gen D_marstG_2 = marstG_22015 - marstG_21960
gen D_nchlt5 = log(nchlt52015) - log(nchlt51970)

*PANEL A. Education
reg D_FLFP D_EdG3 if sex==0, r
local slope : di %4.3f _b[D_EdG3]
local se : di %4.3f _se[D_EdG3]

twoway  (scatter D_FLFP D_EdG3 [w=N1960] if sex==0, sort mcolor(black%60) msymbol(circle_hollow)) ///
		(lfit  D_FLFP D_EdG3 if sex==0, clcolor(black) subtitle(Slope = `slope' [`se'], position(2) ring(0)) ///
		clwidth() clpattern(dash)), ///
		ylabel(-1(0.5)1) xlabel() ///
		ytitle("Change in Female LFP Rate, 1960-2015") xtitle("Change in (Log) Number of Women with Tertiary Education, 1960-2015") ///
		legend(off) ///
		scheme(s1mono) yline(0, lpattern(dash) lwidth(*0.5)) xline(0, lpattern(dash) lwidth(*0.5))
graph export "$LOCALD\Figures\\fig-10-scatter-delta-educ-flfp-cz.eps", replace

*PANEL B. Marital Status
reg D_FLFP D_marstG_2 if sex==0, r
local slope : di %4.3f _b[D_marstG_2]
local se : di %4.3f _se[D_marstG_2]

twoway  (scatter D_FLFP D_marstG_2 [w=N1960] if sex==0, sort mcolor(black%60) msymbol(circle_hollow)) ///
		(lfit  D_FLFP D_marstG_2 if sex==0, clcolor(black) subtitle(Slope = `slope' [`se'], position(2) ring(0)) ///
		clwidth() clpattern(dash)), ///
		ylabel(-1(0.5)1) xlabel() ///
		ytitle("Change in Female LFP Rate, 1960-2015") xtitle("Change in Share of Women Married/Perm. Partner, 1960-2015") ///
		legend(off) ///
		scheme(s1mono) yline(0, lpattern(dash) lwidth(*0.5)) xline(0, lpattern(dash) lwidth(*0.5))
graph export "$LOCALD\Figures\\fig-10-scatter-delta-mstatus-flfp-cz.eps", replace

*PANEL C. Fertility
reg D_FLFP D_nchlt5 if sex==0, r
local slope : di %4.3f _b[D_nchlt5]
local se : di %4.3f _se[D_nchlt5]

twoway  (scatter D_FLFP D_nchlt5 [w=N1970] if sex==0, sort mcolor(black%60) msymbol(circle_hollow)) ///
		(lfit  D_FLFP D_nchlt5 if sex==0, clcolor(black) subtitle(Slope = `slope' [`se'], position(2) ring(0)) ///
		clwidth() clpattern(dash)), ///
		ylabel(-1(0.5)1) xlabel() ///
		ytitle("Change in Female LFP Rate, 1970-2015") xtitle("Change in (Log) Average # Children Below Age 5, 1970-2015") ///
		legend(off) ///
		scheme(s1mono) yline(0, lpattern(dash) lwidth(*0.5)) xline(0, lpattern(dash) lwidth(*0.5))
graph export "$LOCALD\Figures\\fig-10-scatter-delta-fertility-cz.eps", replace