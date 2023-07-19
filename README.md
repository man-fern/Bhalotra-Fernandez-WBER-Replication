# The Rise in Women's Labor Force Participation in Mexico- Supply vs Demand Factors

## Authors

* Sonia Bhalotra, University of Warwick
* Manuel Fernández, Universidad de los Andes

## Replication Instructions

### Software and Packages:

To run the code, you will need to have the following software and packages installed on your machine:

* Stata (version 16 or later)
  * Additional packages: *shp2dta*, *spmap*, *estout*, *reghdfe*, *oaxaca*

## Steps to Replicate

**Step 1**: Run the '*p0a-shape-maps.do*' Stata do-file to generate shape files in DTA format.

* **Inputs:** 
    * DS1: SHP file '*geo2_mx1960_2015.shp*'
    * DS2: DBF '*geo2_mx1960_2015.dbf*'
* **Outputs:** 
    * DS3: DTA file '*mexico_coord2.dta*' 
    * DS4: DTA file '*mexico_db2.dta*'
    * DS5: DTA file '*trans2.dta*'

* **Source:** The SHP and DBF files are provided by [IPUMS-International-gis](https://international.ipums.org/international/gis.shtml). They include the second-level subnational administrative units in Mexico, known as 'municipios,' in which the household was enumerated. The information is harmonized by IPUMS. 

**Step 2**: Run the '*p1-import-clean-data.do*' Stata do-file to clean the original IPUMS Mexican Census database, construct variables of interest, and save the main database in DTA format. The script merges the '*IPUMS-original.dta*' database with '*mexico_db2.dta*' created in Step 1 and with '*crosswalk_geo2_mx_cz.dta*'. The latter is taken from Faber, M. (2020) and contains a crosswalk between municipalities and commuting zones. 

* **Inputs:** 
    * DS6: Data file '*IPUMS-original.dta*' 
    * DS4: Data file '*mexico_db2.dta*' 
    * DS7: Data file '*crosswalk_geo2_mx_cz.dta*'
* **Outputs:** 
    * DS8: Data file '*Main.dta*' 

* **Source:** The '*IPUMS-original.dta*' contains a subset of variables from the 1960, 1970, 1990, 2000, 2010, and 2015 Mexican Census samples provided by [IPUMS-International](https://international.ipums.org/international/). The '*crosswalk_geo2_mx_cz.dta*' comes from the replication files of Faber (2020).


**Step 3**: Run the 'p2-tables-figures.do' Stata do-file to create the figures and maps displayed in the paper.

* **Inputs:** 
    * DS8: Data file '*Main.dta*'
    * DS3: Data file '*mexico_coord2*'
* **Outputs:** 
    * Figures 1-10 in the paper.

* **Notes:** The do-file is divided into ten sections, each corresponding to one of the figures in the paper. The sections can be executed independently.


**Step 4**: Run the '*p3-lpm-oaxaca-blinder*' Stata do-file to estimate the linear probability models relating labor force participation to observable characteristics. The second part of the do-file estimates the Oaxaca-Blinder decomposition.

* **Inputs:** 
    * DS8: Data file '*Main.dta*'
* **Outputs:** 
    * Tables 1 and 2 in the paper.

* **Notes:** The do-file is divided into two sections, each corresponding to Table 1 or 2 of the paper. The sections can be executed independently.


**Step 5** Run the '*p4a-shift-share-var*' Stata do-file to create the shift-share variables for occupations and sectors.

* **Inputs:** 
    * DS8: Data file '*Main.dta*'
* **Outputs:** 
    * DS9:  Data file '*BartikOcc.dta*'
    * DS10: Data file '*BartikSec.dta*'
    * DS11: Data file '*BartikFull.dta*'

* **Notes:** The do-file is divided into three sections. The first section creates the shift-share variable associated with occupations at the CZ level, saving the result in the '*BartikOcc.dta*'. The second section creates the shift-share variables associated with sectors at the CZ level, saving the result in the '*BartikSec.dta*'. The last section collapses the '*Main.dta*' dataset at the commuting zone*census year level, constructs the relevant variables for the analysis, and merges the resulting database with '*BartikOcc.dta*' and '*BartikFull.dta*'.


**Step 6** Run the '*p4b-shift-share-estimate*' Stata do-file to estimate the shift-share regressions.

* **Inputs:** 
    * DS11: Data file '*BartikFull.dta*'
* **Outputs:** 
    * Tables 3 and 4 in the paper

* **Notes:** The do-file is divided into 2 three sections. The first section estimates the shift-share regressions. The second section does the demand-side decomposition analysis.
