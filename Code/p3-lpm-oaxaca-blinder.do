*================================
*Last modified: 7/18/2023
*Estimate linear probability models for participation and run the Oaxaca-Blinder decomposition
*================================

clear all

*SPECIFY LOCAL ENVIROMENT
*global LOCALD "...\Replication-folder"

********************************************************************************
*TABLE 1. PROBABILITY OF PARTICIPATING IN THE LABOR FORCE

use "$LOCALD\Data\main.dta", clear

*REGRESSIONS
egen cz_year = group(cz year)
gen POP=1

*REG: 1960-2015
xi: reghdfe tp i.educG i.marstG childEverBorn age agesq [pw=perwt] if sex==0 & (year>=1960 & year<=2015), a(cz_year) cl(cz)
	estadd local CFE   " "
	estadd local TFE   "\cmark"
	su tp [fw=perwt] if e(sample)
	local meanTP: display %9.0f r(mean)
	estadd local meanTP `meanTP'
est store OLS0

*REG: 1970-2015
xi: reghdfe tp i.educG i.marstG childEverBorn nchlt5 nchltM5 age agesq [pw=perwt] if sex==0 & (year>=1970 & year<=2015), a(cz_year) cl(cz)
	estadd local CFE   " "
	estadd local TFE   "\cmark"
	su tp [fw=perwt] if e(sample)
	local meanTP: display %9.0f r(mean)
	estadd local meanTP `meanTP'
est store OLS0B

*REG: by year
xi: reghdfe tp i.educG i.marstG childEverBorn age agesq [pw=perwt] if sex==0 & year==1960, a(cz) cl(cz)
	estadd local CFE  "\cmark"
	estadd local TFE  " "
	su tp [fw=perwt] if e(sample)
	local meanTP: display %9.0f r(mean)
	estadd local meanTP `meanTP'
est store OLS0_1960

foreach year in 1970 1990 2000 2010 2015 {
	xi: reghdfe tp i.educG i.marstG childEverBorn nchlt5 nchltM5 age agesq [pw=perwt] if sex==0 & year==`year', a(cz) cl(cz)
		estadd local CFE  "\cmark"
		estadd local TFE  " "
	su tp [fw=perwt] if e(sample)
	local meanTP: display %9.0f r(mean)
	estadd local meanTP `meanTP'
	est store OLS0_`year'
}

esttab OLS0 OLS0B OLS0_1960 OLS0_1970 OLS0_1990 OLS0_2000 OLS0_2010 OLS0_2015 using "$LOCALD\Figures\\tab-1-flfp-liner-probability.tex", ///
	mgroups("\shortstack{Dep Var: =1 if in Labor Force}", pattern(1 0 0 0 0 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mtitles("\shortstack{1960-2015}" "\shortstack{1970-2015}" "\shortstack{1960}" "\shortstack{1970}" "\shortstack{1990}" "\shortstack{2000}" "\shortstack{2010}" "\shortstack{2015}" ) ///
	keep(  _IeducG_2 _IeducG_3 _ImarstG_2 childEverBorn nchlt5 nchltM5 age agesq) ///
	order( _IeducG_2 _IeducG_3 _ImarstG_2 childEverBorn nchlt5 nchltM5 age agesq) ///
	coeflabels( ///
		_IeducG_2		 "\hspace{0.1cm} =1 if Secondary" ///
		_IeducG_3		 "\hspace{0.1cm} =1 if Tertiary" ///
		_ImarstG_2		 "\hspace{0.1cm} =1 if Married" ///
		childEverBorn	 "\hspace{0.1cm} =1 if Child Ever Born" ///
		nchlt5 			 "\hspace{0.1cm} N. Children $\leq$ 5" ///
		nchltM5			 "\hspace{0.1cm} N. Children $>$ 5" ///
		age				 "\hspace{0.1cm} Age" ///
		agesq			 "\hspace{0.1cm} Age Squared" ///
		_cons			 "\hspace{0.1cm} Constant") ///
	refcat(_IeducG_2 "\textbf{Education}" _ImarstG_2 "\textbf{Marital Status}" childEverBorn "\textbf{Fertility}" age "\textbf{Age/Experience}", nolabel) ///
	nodepvars se r2 star(* 0.10 ** 0.05 *** 0.001) eqlabels("") replace b(2) se(2) f nonumbers ///
	stats(meanTP TFE CFE, fmt(%10.0fc %10.2fc) ///
	labels("Observations" "Commuting Zone $\times$ Year FE" "Commuting Zone FE"))
*/

********************************************************************************
*TABLE 2. OAXACA-BLINDER DECOMPOSITION


use "$LOCALD\Data\main.dta", clear
tab geolev1, gen(g_)

*DECOMP: OAXACA BLINDER DECOMPOSITION
gen oaxaca1 =.
replace oaxaca1 =1 if year==1960
replace oaxaca1 =2 if year==2015

gen oaxaca2 =.
replace oaxaca2 =1 if year==1970
replace oaxaca2 =2 if year==2015

gen oaxaca3 =.
replace oaxaca3 =1 if year==1960
replace oaxaca3 =2 if year==1990

gen oaxaca4 =.
replace oaxaca4 =1 if year==1970
replace oaxaca4 =2 if year==1990

gen oaxaca5 =.
replace oaxaca5 =1 if year==1990
replace oaxaca5 =2 if year==2000

gen oaxaca6 =.
replace oaxaca6 =1 if year==2000
replace oaxaca6 =2 if year==2015


*Decomposition using 1960 (no information on nchlt5 nchltM5)
foreach sex in 0 {
	foreach group in 1 3 {
	xi: oaxaca tp (Education: educG_2 educG_3) ///
				  (Marital Status: marstG_2) ///
				  (Children: childEverBorn) ///
				  (FE: g_2-g_32) ///
				  (Age: age agesq) ///
				  [pw=perwt] if sex==`sex', by(oaxaca`group') swap cluster(geolev1) pooled relax
		est store OAXACA`group'`sex'
	}
}

*All other deomcposition
foreach sex in 0 {
	foreach group in 2 4 5 6 {
	xi: oaxaca tp (Education: educG_2 educG_3) ///
				  (Marital Status: marstG_2) ///
				  (Children: childEverBorn nchlt5 nchltM5) ///
				  (FE: g_2-g_32) ///
				  (Age: age agesq) ///
				  [pw=perwt] if sex==`sex', by(oaxaca`group') swap cluster(geolev1) pooled relax
		est store OAXACA`group'`sex'
	}
}


esttab  OAXACA10 OAXACA20 OAXACA30 OAXACA40 OAXACA50 OAXACA60 using "$LOCALD\Figures\\tab-2-OAXACA.tex", ///
		mgroups("\shortstack{$\Delta$ Female LFP Rate}", pattern(1 0 0 0 1 0 0 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
		mtitles("\shortstack{1960-2015}" "\shortstack{1970-2015}" "\shortstack{1960-1970}" "\shortstack{1970-1990}" "\shortstack{1990-2000}" "\shortstack{2000-2010}" "\shortstack{2010-2015}") ///
		nodepvars se r2 star(* 0.10 ** 0.05 *** 0.001) eqlabels("") replace b(3) se(3) f nonumbers ///
		stats(N , fmt(%10.0fc %10.3fc) ///
		labels("Observations"))

*/
