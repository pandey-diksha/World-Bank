* Title: Running statistical tests on the Enterprise Surveys dataset
* Author: Diksha Pandey
* Date created: January 28, 2023
* Last modified on: February 27, 2023
* Description: This file contains the Stata code for generating descriptive statistics on the characteristics of manufacturing firms operating in developing countries that have been surveyed by the World Bank's Enterprise Surveys (2006-2021). It also includes summary statistics on water-related variables of interest, as well as data cleaning and regression analysis.


clear
set more off
set matsize 10000
set maxvar 32000

*set working directory
cd "C:\Users\DIKSHA\Downloads\World Bank\Documentation for Brown\stata"

*load data
use "C:\Users\DIKSHA\Downloads\World Bank\Documentation for Brown\stata\data\water_latest_survey_years_w_external_variables.dta", clear

*specify the survey design characteristics
svyset idstd[pw=wt_rs], strata(strata_all) singleunit(scaled)

*add labels to variables
label variable idstd "unique identifier"
label variable wbcode "world bank country codes"
label variable country_only "country name"
label variable svyyear "latest survey year"
label variable country "country name and latest survey year"
label variable region "six regional units of world bank"
label variable graft3 "bribery incidence"

*add textual labels to variables with numeric codes
label define sector_labels 1 "Manufacturing" 2 "Retail" 3 "Other Services"
label values sector_3 sector_labels

label define size_labels 1 "Small(<20)" 2 "Medium(20-99)" 3 "Large(100 and over)"
label values size size_labels

label define ownership_labels 0 "Domestic" 100 "Foreign"
label values ownership ownership_labels

label define exporter_labels 0 "Non-exporter" 100 "Exporter"
label values exporter exporter_labels


*****************************************************************
*gender-related variables
*****************************************************************


label variable gend1 "female participation in ownership" 
*percentage of female ownership = b4a%
label variable gend2 "permanent full-time female workers"
label variable gend3 "permanent full-time female non-production workers"
label variable gend4 "female top manager"
label variable gend5 "permanent full-time female production workers" 
label variable gend6 "majority female ownership" 

*generate new variables based on above

recode gend1 (100=1), gen (femowner_d)
label var femowner_d "female owner Y/N"

recode gend4 (100=1), gen(femmngr_d)
label var femmngr_d "female top manager Y/N"

recode gend6 (100=1), gen (femmaj_d)
label var femmaj_d "majority female ownership Y/N"

/*
gen femown_pct= b4a if b4a >=0 & b4a!=.
bys country: egen flag=mean(b4a)
replace femown_pct=. if flag==.
drop flag
label var femown_pct "Percent of Owners that are Female"

gen menown_pct = 100 - femown_pct if femown_pct!=.
label var menown_pct "Percent of Owners that are Male"

gen menown_pct = 100 - femown_pct if femown_pct!=.
label var menown_pct "Percent of Owners that are Male"

gen malemngr_d = 1 if femmngr_d==0
replace malemngr_d = 0 if femmngr_d==1
label var malemngr_d  "Male top manager Y/N"

gen maleowner_d = 1 if femowner_d==0
replace maleowner_d=0 if femowner_d==1
label var maleowner_d "Firm has only male owners Y/N"
*/


*****************************************************************
*water-related variables
*****************************************************************


label variable water_perm_d "applied for water permit in last 2 years Y/N"
label variable wtr_deny "water application denied Y/N"
label variable wtr_proc "water application in process Y/N"
label variable wtrdys_wait "no of days for water connection"

label variable wtrshrt_d "experienced water shortage Y/N (manf only)"
label variable wtrinc "average no of incidents of water shortages per month (only manf firms that faced shortages)"
label variable wtrinc_a "average no of incidents of water shortages per month (no shortage:0)(manf only)"
label variable wtrdur "average duration of water shortage (only manf firms that faced shortages)"
*label variable wtrdur_a "average duration of water shortage (no shortage:0)(manf only)"
label variable waterbribe_d "informal payment requested for water connection Y/N"
label var lnwtrinc_a "log of average no of incidents of water shortages per month"
label var lnwtrdur_a "log of average duration of water shortage"


**# Bookmark #1


*****************************************************************
*generate descriptive & summary statistics
*****************************************************************


*distribution of countries by region
tabulate country if region == 1
*repeat above for all six regions

*number of manufacturing firms in the dataset
count if sector_3 == 1

*distribution of manufacturing firms by region and size
tabulate region if sector_3 == 1
tabulate size if sector_3 == 1

*convert categorical variables into numeric variables
encode country_only, gen(country_enc)
encode wbcode, gen(country_code)
encode income_group, gen(income_enc)

*calculate survey-weighted means for subgroups
svy: mean wtrshrt_d, over(size)
svy: mean wtrshrt_d, over(region size)
svy: mean wtrshrt_d, over(size sector_3)
svy: mean wtrshrt_d, over(size exporter)
svy: mean wtrshrt_d, over(size ownership)
svy: mean wtrshrt_d, over(size femowner_d)
svy: mean wtrshrt_d, over(size femmngr_d)

// svy: mean waterbribe_d, over(region size)
// svy: mean waterbribe_d, over(size sector_3)
// svy: mean waterbribe_d, over(size exporter)
// svy: mean waterbribe_d, over(size ownership)
// svy: mean waterbribe_d, over(size femowner_d)
// svy: mean waterbribe_d, over(size femmngr_d)
//
// svy: mean wtrdur, over(region size)
// svy: mean wtrinc, over(region size)
//
// svy: mean wtrdur, over(size sector_3)
// svy: mean wtrinc, over(size sector_3)
//
// svy: mean wtrdur, over(size exporter)
// svy: mean wtrinc, over(size exporter)
//
// svy: mean wtrdur, over(size ownership)
// svy: mean wtrinc, over(size ownership)
//
// svy: mean wtrdur, over(size femowner_d)
// svy: mean wtrinc, over(size femowner_d)
//
// svy: mean wtrdur, over(size femmngr_d)
// svy: mean wtrinc, over(size femmngr_d)
//
// svy: mean wtrshrt_d, over(size)
// svy: mean waterbribe_d, over(size)
// svy: mean wtrdur, over(size)
// svy: mean wtrinc, over(size)
//
// svy: mean wtrshrt_d, over(region)
// svy: mean waterbribe_d, over(region)
// svy: mean wtrdur, over(region)
// svy: mean wtrinc, over(region)
//
// svy: mean wtrshrt_d, over(sector_3)
// svy: mean waterbribe_d, over(sector_3)
// svy: mean wtrdur, over(sector_3)
// svy: mean wtrinc, over(sector_3)
//
// svy: mean wtrshrt_d, over(exporter)
// svy: mean waterbribe_d, over(exporter)
// svy: mean wtrdur, over(exporter)
// svy: mean wtrinc, over(exporter)
//
// svy: mean wtrshrt_d, over(ownership)
// svy: mean waterbribe_d, over(ownership)
// svy: mean wtrdur, over(ownership)
// svy: mean wtrinc, over(ownership)
//
// svy: mean wtrshrt_d, over(femowner_d)
// svy: mean waterbribe_d, over(femowner_d)
// svy: mean wtrdur, over(femowner_d)
// svy: mean wtrinc, over(femowner_d)
//
// svy: mean wtrshrt_d, over(femmngr_d)
// svy: mean waterbribe_d, over(femmngr_d)
// svy: mean wtrdur, over(femmngr_d)
// svy: mean wtrinc, over(femmngr_d)
//
// svy: mean wtrshrt_d, over(region femowner_d)
// svy: mean waterbribe_d, over(region femowner_d)
// svy: mean wtrdur, over(region femowner_d)
// svy: mean wtrinc, over(region femowner_d)
//
// svy: mean wtrshrt_d, over(region femmngr_d)
// svy: mean waterbribe_d, over(region femmngr_d)
// svy: mean wtrdur, over(region femmngr_d)
// svy: mean wtrinc, over(region femmngr_d)
//
// svy: mean wtrshrt_d, over(income_enc)
// svy: mean waterbribe_d, over(income_enc)
// svy: mean wtrdur, over(income_enc)
// svy: mean wtrinc, over(income_enc)
//
// svy: mean wtrshrt_d, over(region)
// svy: mean waterbribe_d, over(region)
// svy: mean wtrdur, over(region)
// svy: mean wtrinc, over(region)
//
// svy: mean waterbribe_d, over(region size)
// svy: mean waterbribe_d, over(size sector_3)
// svy: mean waterbribe_d, over(size exporter)
// svy: mean waterbribe_d, over(size ownership)
// svy: mean waterbribe_d, over(size femowner_d)
// svy: mean waterbribe_d, over(size femmngr_d)
//
// svy: mean wtrdur, over(region size)
// svy: mean wtrinc, over(region size)
//
// svy: mean wtrdur, over(size sector_3)
// svy: mean wtrinc, over(size sector_3)
//
// svy: mean wtrdur, over(size exporter)
// svy: mean wtrinc, over(size exporter)
//
// svy: mean wtrdur, over(size ownership)
// svy: mean wtrinc, over(size ownership)
//
// svy: mean wtrdur, over(size femowner_d)
// svy: mean wtrinc, over(size femowner_d)
//
// svy: mean wtrdur, over(size femmngr_d)
// svy: mean wtrinc, over(size femmngr_d)
//
// svy: mean wtrshrt_d, over(size)
// svy: mean waterbribe_d, over(size)
// svy: mean wtrdur, over(size)
// svy: mean wtrinc, over(size)
//
// svy: mean wtrshrt_d, over(region)
// svy: mean waterbribe_d, over(region)
// svy: mean wtrdur, over(region)
// svy: mean wtrinc, over(region)
//
// svy: mean wtrshrt_d, over(sector_3)
// svy: mean waterbribe_d, over(sector_3)
// svy: mean wtrdur, over(sector_3)
// svy: mean wtrinc, over(sector_3)
//
// svy: mean wtrshrt_d, over(exporter)
// svy: mean waterbribe_d, over(exporter)
// svy: mean wtrdur, over(exporter)
// svy: mean wtrinc, over(exporter)
//
// svy: mean wtrshrt_d, over(ownership)
// svy: mean waterbribe_d, over(ownership)
// svy: mean wtrdur, over(ownership)
// svy: mean wtrinc, over(ownership)
//
// svy: mean wtrshrt_d, over(femowner_d)
// svy: mean waterbribe_d, over(femowner_d)
// svy: mean wtrdur, over(femowner_d)
// svy: mean wtrinc, over(femowner_d)
//
// svy: mean wtrshrt_d, over(femmngr_d)
// svy: mean waterbribe_d, over(femmngr_d)
// svy: mean wtrdur, over(femmngr_d)
// svy: mean wtrinc, over(femmngr_d)
//
// svy: mean wtrshrt_d, over(region femowner_d)
// svy: mean waterbribe_d, over(region femowner_d)
// svy: mean wtrdur, over(region femowner_d)
// svy: mean wtrinc, over(region femowner_d)
//
// svy: mean wtrshrt_d, over(region femmngr_d)
// svy: mean waterbribe_d, over(region femmngr_d)
// svy: mean wtrdur, over(region femmngr_d)
// svy: mean wtrinc, over(region femmngr_d)
//
// svy: mean wtrshrt_d, over(income_enc)
// svy: mean waterbribe_d, over(income_enc)
// svy: mean wtrdur, over(income_enc)
// svy: mean wtrinc, over(income_enc)
//
// svy: mean wtrshrt_d, over(region)
// svy: mean waterbribe_d, over(region)
// svy: mean wtrdur, over(region)
// svy: mean wtrinc, over(region)
//
// svy: mean avg_water_shortage_duration, over(region)
// svy: mean avg_water_shortage_duration, over(income_enc)
// svy: mean avg_water_shortage_duration, over(exporter)
// svy: mean avg_water_shortage_duration, over(ownership)
// svy: mean avg_water_shortage_duration, over(size)
// svy: mean avg_water_shortage_duration, over(country_code)
// svy: mean avg_water_shortage_duration, over(femowner_d)
// svy: mean avg_water_shortage_duration, over(femmngr_d)
//
// svy: mean avg_water_shortage_duration, over(region)
// svy: mean avg_water_shortage_duration, over(income_enc)
// svy: mean avg_water_shortage_duration, over(exporter)
// svy: mean avg_water_shortage_duration, over(ownership)
// svy: mean avg_water_shortage_duration, over(size)
// svy: mean avg_water_shortage_duration, over(country_code)
// svy: mean avg_water_shortage_duration, over(femowner_d)
// svy: mean avg_water_shortage_duration, over(femmngr_d)


*****************************************************************
*regression analysis
*****************************************************************


est clear
eststo: svy: regress wtrshrt_d i.merged_size i.income_enc i.exporter i.ownership i.femowner_d i.femmngr_d i.femmaj_d i.region gdp_per_capita2014
eststo: svy: regress wtrinc i.merged_size i.income_enc i.exporter i.ownership i.femowner_d i.femmngr_d i.femmaj_d i.region gdp_per_capita2014
eststo: svy: regress wtrdur i.merged_size i.income_enc i.exporter i.ownership i.femowner_d i.femmngr_d i.femmaj_d i.region gdp_per_capita2014