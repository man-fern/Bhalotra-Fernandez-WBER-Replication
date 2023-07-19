*================================
*Last modified: 7/18/2023
*Estimate the shift share regressions and the demand-side decompositions
*================================

clear all

*SPECIFY LOCAL ENVIROMENT
*global LOCALD "...\Replication-folder"


******************************************************************************** 
*TABLE 3. SHIFT-SHARE REGRESSIONS

use "$LOCALD\Data\BartikFull.dta", clear

global CONTROLS "DeducG_10_mt DeducG_20_mt DeducG_30_mt DchildEverBorn0_mt DmarstG_20_mt"
global FE "ts m"
global SE "ts m"
global WEIGHT " "


*TABLE: COLUMNS 1-3 - OBSERVED
*COL 1: CORRELATION
reghdfe Dy_mt Dx_mt $WEIGHT, noa cl($SE)
	estadd local MFE  " "
	estadd local TSFE " "
	estadd local CONT " "
est store CORR

*COL 2: FE
reghdfe Dy_mt Dx_mt $WEIGHT, a($FE) cl($SE)
	estadd local MFE  "\cmark"
	estadd local TSFE "\cmark"
	estadd local CONT " "
est store FE

*COL 3: FE + CONTROLS
reghdfe Dy_mt Dx_mt $CONTROLS $WEIGHT, a($FE) cl($SE)
	estadd local MFE  "\cmark"
	estadd local TSFE "\cmark"
	estadd local CONT "\cmark"
est store FE_CONT

*TABLE: COLUMNS 4-6 - OCCUPATIONS
*COL 4: CORRELATION
reghdfe Dy_mt B_mt_omean $WEIGHT, noa cl($SE)
	estadd local MFE  " "
	estadd local TSFE " "
	estadd local CONT " "
est store CORR_O

*COL 5: FE
reghdfe Dy_mt B_mt_omean $WEIGHT, a($FE) cl($SE)
	estadd local MFE  "\cmark"
	estadd local TSFE "\cmark"
	estadd local CONT " "
est store FE_O

*COL 6: FE + CONTROLS
reghdfe Dy_mt B_mt_omean $CONTROLS $WEIGHT, a($FE) cl($SE)
	estadd local MFE  "\cmark"
	estadd local TSFE "\cmark"
	estadd local CONT "\cmark"
est store FE_CONT_O

*TABLE: COLUMNS 7-9 - SECTORS
*COL 4: CORRELATION
reghdfe Dy_mt B_mt_smean $WEIGHT, noa cl($SE)
	estadd local MFE  " "
	estadd local TSFE " "
	estadd local CONT " "
est store CORR_S

*COL 5: FE
reghdfe Dy_mt B_mt_smean $WEIGHT, a($FE) cl($SE)
	estadd local MFE  "\cmark"
	estadd local TSFE "\cmark"
	estadd local CONT " "
est store FE_S

*COL 6: FE + CONTROLS
reghdfe Dy_mt B_mt_smean $CONTROLS $WEIGHT, a($FE) cl($SE)
	estadd local MFE  "\cmark"
	estadd local TSFE "\cmark"
	estadd local CONT "\cmark"
est store FE_CONT_S

*COL 7: FE + CONTROLS + BOTH
reghdfe Dy_mt B_mt_smean B_mt_omean $CONTROLS $WEIGHT, a($FE) cl($SE)
	estadd local MFE  "\cmark"
	estadd local TSFE "\cmark"
	estadd local CONT "\cmark"
est store FE_CONT_OS


esttab FE FE_CONT FE_O FE_CONT_O FE_S FE_CONT_S FE_CONT_OS using "$LOCALD\Figures\tab-3-shift-share.tex", ///
	mgroups("\shortstack{Overall \\ $\Delta$ Demand}" "\shortstack{ $\Delta$ Occupation \\ Composition}" "\shortstack{$\Delta$ Sectoral \\ Composition}" "\shortstack{$\Delta$ Occupation and \\ Sectoral \\ Composition}", pattern(1 0 1 0 1 0 1) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///
	mtitles("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") ///
	keep(Dx_mt B_mt_omean B_mt_smean) ///
	order(Dx_mt B_mt_omean B_mt_smean) ///
	coeflabels( ///
		Dx_mt		"\shortstack{$\Delta$ Female \\ Labor Demand \\ ($\Delta L^{f}_{m,t}$)}" ///
		B_mt_omean	"\shortstack{Predicted $\Delta$ Female \\ Labor Demand \\ by Occ. Composition \\ ($B^{occ}_{m,t}$)}" ///
		B_mt_smean	"\shortstack{Predicted $\Delta$ Female \\ Labor Demand \\ by Sec. Composition \\ ($B^{sec}_{m,t}$)}") ///
	refcat(Dx_mt " ", nolabel) ///
	nodepvars se r2 star(* 0.10 ** 0.05 *** 0.001) eqlabels("") replace b(3) se(3) f nonumbers ///
	stats(N MFE TSFE CONT, fmt(%10.0fc) ///
	labels("Observations" "CZ FE" "Year $\times$ State FE" "Supply-Side Controls"))


******************************************************************************** 
*TABLE 4. DEMAND-SIDE EFFECTS

global CONTROLS "DeducG_10_mt DeducG_20_mt DeducG_30_mt DchildEverBorn0_mt DmarstG_20_mt"
global FE "ts m"
global SE "ts m"
global WEIGHT " "

set seed 123456
forvalues boots = 1(1)1000 {
    tempfile boots_`boots'
    use "$LOCALD\Data\BartikFull.dta", clear
	*bsample, strata(t)
	bsample, cluster(m)

	reghdfe Dy_mt B_mt_omean B_mt_smean $CONTROLS $WEIGHT, a($FE) cl($SE)
		gen preChange1 = _b[B_mt_omean]*B_mt_omean
		gen preChange2 = _b[B_mt_smean]*B_mt_smean
		gen preChange3 = preChange1 + preChange2

	drop if t==1960
	collapse (mean) preChange1 preChange2 preChange3 [fw=N], by(t)

	reshape long preChange, i(t) j(group)
	replace preChange = preChange*100

	reshape wide preChange, i(group) j(t)
	label define group 1 "Occ" 2 "Sec" 3 "Total"
	label value group group

	egen preChange1960_2015 = rowtotal(preChange1970 preChange1990 preChange2000 preChange2010 preChange2015)
	egen preChange1970_2015 = rowtotal(preChange1990 preChange2000 preChange2010 preChange2015)
	egen preChange1960_1990 = rowtotal(preChange1970 preChange1990)
	egen preChange1970_1990 = rowtotal(preChange1990)
	egen preChange1990_2000 = rowtotal(preChange2000)
	egen preChange2000_2015 = rowtotal(preChange2010 preChange2015)

	gen bsample = `boots'

	save "`boots_`boots''"
}

use "`boots_1'", clear
forvalues boots = 2(1)1000 {
	append using "`boots_`boots''"
}

display in red "Occupations"
su preChange1960_2015 preChange1970_2015 preChange1960_1990 preChange1970_1990 preChange1990_2000 preChange2000_2015 if group==1

display in red "Sectors"
su preChange1960_2015 preChange1970_2015 preChange1960_1990 preChange1970_1990 preChange1990_2000 preChange2000_2015 if group==2

display in red "Total"
su preChange1960_2015 preChange1970_2015 preChange1960_1990 preChange1970_1990 preChange1990_2000 preChange2000_2015 if group==3
