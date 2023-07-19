*================================
*Last modified: 7/18/2023
*The program generates the shape files in Stata format for the maps
*================================

clear all

*SPECIFY LOCAL ENVIROMENT
*global LOCALD "...\Replication-folder"

********************************************************************************
*SECOND GEOGRAPHIC LEVEL

*translate the files from second shapefile
shp2dta using "$LOCALD\Data\geo2_mx1960_2015.shp", database("$LOCALD\Data\mexico_db2.dta") coordinates("$LOCALD\Data\mexico_coord2.dta") genid(id2) replace

*opens new shapefile dataset
use "$LOCALD\Data\mexico_db2", clear

*destring geographical variable an create a second transitional database
rename GEOLEVEL2 geolev2
destring geolev2, replace
save "$LOCALD\Data\mexico_db2", replace

keep geolev2 id2
save "$LOCALD\Data\trans2.dta", replace