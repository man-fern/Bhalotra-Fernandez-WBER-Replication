*================================
*Last modified: 7/18/2023
*Cronstruct the shift-share variables for occupations and sectors
*================================

clear all

*SPECIFY LOCAL ENVIROMENT
*global LOCALD "...\Replication-folder"

********************************************************************************
* VAR and DATASET: SHIFT-SHARE VARIABLE - OCCUPATION
use perwt sex cz geo1_mx year tp occisco using "$LOCALD\Data\main.dta", clear

rename cz m
rename geo1_mx s
rename year t
rename occisco k
sort t
egen tb =group(t) /*sequental values for panel*/

keep if tp==1
drop if m == . | k == .

gen N=1
collapse (sum) N [fw=perwt], by(t tb m k sex)
reshape wide N, i(t tb m k) j(sex)
recode N0 N1 (.=0)

reshape wide N0 N1, i(t tb m) j(k) /*balance panel*/
reshape long N0 N1, i(t tb m) j(k)
recode N0 N1 (.=0)

*VAR: FEMALE SHARE
gen N_mkt = N0+N1
gen Z_mkt=N0/(N_mkt)
recode Z_mkt (.=0)
gen LogN_mkt = log(N_mkt+1)
gen logN0_mkt = log(N0+1)

*VAR: Dx_m,t
egen mk = group(m k)
sort tb
xtset mk tb
gen Dx_mkt_obs = logN0_mkt-l.logN0_mkt
bys t m: egen Dx_mt_obs = total(Dx_mkt_obs), missing
drop Dx_mkt_obs

sort mk tb
gen Dx_mkt = l.Z_mkt*(LogN_mkt-l.LogN_mkt)
bys t m: egen Dx_mt = total(Dx_mkt), missing
drop Dx_mkt

*VAR: Z_mkt for different base years 1960-2015
foreach base in 1960 1970 1990 2000 2010 2015 {
	gen Z_mkt_`base'_temp = Z_mkt if t==`base'
	bys m k: egen Z_mkt_`base' = mean(Z_mkt_`base'_temp)
	drop Z_mkt_`base'_temp
}
egen Z_mkt_mean = rowmean(Z_mkt_1960 Z_mkt_1970 Z_mkt_1990)
drop Z_mkt_1960-Z_mkt_2015

*VAR: B_mkt_o
bys k t: egen N_kt = total(N_mkt), missing
gen N_kt_mm = N_kt - N_mkt /*total change except for municipality m*/
gen LogN_kt_mm = log(N_kt_mm+1)

xtset mk tb
gen B_mkt_omean = l.Z_mkt_mean*(LogN_kt_mm-l.LogN_kt_mm)
bys t m: egen B_mt_omean = total(B_mkt_omean), missing

xtset mk tb
gen B_mkt_o = l.Z_mkt*(LogN_kt_mm-l.LogN_kt_mm)
bys t m: egen B_mt_o = total(B_mkt_o), missing

*COLLAPSE
collapse (mean) Dx_mt_obs Dx_mt B_mt_omean B_mt_o, by(m t)

*DATABASE
compress
save "$LOCALD\Data\BartikOcc.dta", replace


********************************************************************************
* VAR and DATASET: SHIFT-SHARE VARIABLE - SECTOR
use perwt sex cz geo1_mx year tp indgen using "$LOCALD\Data\main.dta", clear

rename cz m
rename geo1_mx s
rename year t
rename indgen k
sort t
egen tb =group(t) /*sequental values for panel*/

keep if tp==1
drop if m == . | k == .

gen N=1
collapse (sum) N [fw=perwt], by(t tb m k sex)
reshape wide N, i(t tb m k) j(sex)
recode N0 N1 (.=0)

reshape wide N0 N1, i(t tb m) j(k) /*balance panel*/
reshape long N0 N1, i(t tb m) j(k)
recode N0 N1 (.=0)

*VAR: FEMALE SHARE
gen N_mkt = N0+N1
gen Z_mkt=N0/(N_mkt)
recode Z_mkt (.=0)
gen LogN_mkt = log(N_mkt+1)
gen logN0_mkt = log(N0+1)

*VAR: Dx_m,t
egen mk = group(m k)
sort tb
xtset mk tb
gen Dx_mkt_obs = logN0_mkt-l.logN0_mkt
bys t m: egen Dx_mt_obs = total(Dx_mkt_obs), missing
drop Dx_mkt_obs

sort mk tb
gen Dx_mkt = l.Z_mkt*(LogN_mkt-l.LogN_mkt)
bys t m: egen Dx_mt = total(Dx_mkt), missing
drop Dx_mkt

*VAR: Z_mkt for different base years 1960-2015
foreach base in 1960 1970 1990 2000 2010 2015 {
	gen Z_mkt_`base'_temp = Z_mkt if t==`base'
	bys m k: egen Z_mkt_`base' = mean(Z_mkt_`base'_temp)
	drop Z_mkt_`base'_temp
}
egen Z_mkt_mean = rowmean(Z_mkt_1960 Z_mkt_1970 Z_mkt_1990)
drop Z_mkt_1960-Z_mkt_2015

*VAR: B_mkt_o
bys k t: egen N_kt = total(N_mkt), missing
gen N_kt_mm = N_kt - N_mkt /*total change except for municipality m*/
gen LogN_kt_mm = log(N_kt_mm+1)

xtset mk tb
gen B_mkt_smean = l.Z_mkt_mean*(LogN_kt_mm-l.LogN_kt_mm)
bys t m: egen B_mt_smean = total(B_mkt_smean), missing

xtset mk tb
gen B_mkt_s = l.Z_mkt*(LogN_kt_mm-l.LogN_kt_mm)
bys t m: egen B_mt_s = total(B_mkt_s), missing

*COLLAPSE
collapse (mean) Dx_mt_obs Dx_mt B_mt_smean B_mt_s, by(m t)

*DATABASE
compress
save "$LOCALD\Data\BartikSec.dta", replace


********************************************************************************
* JOIN DATASETS
use perwt sex cz geo1_mx year tp educG_1 educG_2 educG_3 marstG_2 nchlt5 childEverBorn using "$LOCALD\Data\main.dta", clear

rename cz m
rename geo1_mx s
bys m: egen s2 = mode(s) /*some municipalities are in different states but in the same commuting zones. We take the most common state*/
rename year t
drop if m == . | tp == . 

gen N=1
collapse (sum) N educG_1 educG_2 educG_3 (mean) tp marstG_2 nchlt5 childEverBorn [fw=perwt], by(t m s2 sex)

reshape wide tp N educG_1 educG_2 educG_3 marstG_2 childEverBorn nchlt5, i(t m s2) j(sex)
drop if tp0==.

drop N1 educG_11 educG_21 educG_31 tp1 marstG_21 nchlt51 childEverBorn1

drop if N0 == .
drop if marstG_20 == .
gen N=N0

*SET PANEL
sort t
egen tb =group(t) /*sequental values for panel*/
egen ts=group(t s2)
xtset m tb

*VAR: DELTA FLFP
gen Dy_mt = tp0-l.tp0

*VARS: VECTOR OF CONTROLS
foreach var in educG_10 educG_20 educG_30 nchlt50 {
	replace `var' = log(`var'+1)
	gen D`var'_mt = `var'-l.`var'
}

foreach var in childEverBorn0 marstG_20 {
	gen D`var'_mt = `var'-l.`var'
}

keep m s2 t ts Dy_mt DeducG_10_mt DeducG_20_mt DeducG_30_mt Dnchlt50_mt DchildEverBorn0_mt DmarstG_20_mt N

merge 1:1 m t using "$LOCALD\Data\BartikOcc.dta"
drop _merge

merge 1:1 m t using "$LOCALD\Data\BartikSec.dta"
drop _merge

keep if Dy_mt!=. & Dx_mt_obs!=. & B_mt_omean!=. & B_mt_smean!=.

*SAVE DATASET
compress
save "$LOCALD\Data\BartikFull.dta", replace