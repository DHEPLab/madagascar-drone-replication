global od = "/Users/takhona/Desktop/Summer 2025/Drone analysis"


/*
SCRIPT: 		Madagascar_May2025_Report_Prep_01_Baseline.do
AUTHOR:			Brian Frizzelle
MODIFIED:       Tara Templin
DATE:			March 24, 2025
LAST UPDATED:	May 4, 2025

This script pulls the baseline variables needed for the March 2025 report for 
Kat.

*/

// Set paths
global ip = "$od/Data"
global dp = "$od/Data"
global op = "$od/Results"

** FACILITY AUDIT MEASURES **
// Open the Facility Audit data
use "$ip/facility_audit_cleaned_20231013_working.dta", clear

** Set value labels
la def yn 0 "No" 1 "Yes", replace

// Merge on Drone flights and districts
merge 1:1 facility_id using "$dp/baseline_drone_treatment_district.dta", ///
	keepusing(District)
drop _merge

// Drop facilities that did not consent
drop if consent == 0

// Keep only those variables needed for this report
** keep facility_id treatment District ///
**	s6_01_* s11_14			///	Outcome 1
**	s4_06					/// Outcome 2
**	s4_07					/// Outcome 3
**	s4_01					/// Outcome 4
**	stock_fp* s2_20_*		/// Outcome 5
**	s2_21_*					/// Outcome 6
**	s2_28_*					/// Outcome 7
**	s2_29_*					/// Outcome 8
**	s1_1a_1-s1_1a_6			/// Outcome 12
**	s1_04					/// Outcome 13
**	s1_12					/// Outcome 14
**	s2_19_c-s2_19_m			/// Outcome 15
**	s2_19_p-s2_19_z			/// Outcome 16
**	s10_01					/// Outcome 17
**	s10_14					/// Outcome 18
**	s11_14					/// Outcome 19
**	s2_02_*					//  Outcome 21

//Added baseline variables
// Staff Present Today

* Calculate the number of provides at each facility
egen NumProviders = rowtotal(s1_1a-s1_1f)
recode NumProviders (0=.)

* Create categories
gen nprv = .
replace nprv = 1 if NumProviders == 1
replace nprv = 2 if inrange(NumProviders, 2, 3)
replace nprv = 3 if inrange(NumProviders, 4, 5)
replace nprv = 4 if inrange(NumProviders, 6, 8)
replace nprv = 5 if NumProviders >= 9 & !missing(NumProviders)
la def nprv 1 "    1 Provider" 2 "    2 - 3 Providers" ///
	3 "    4 - 5 Providers" 4 "    6 - 8 Providers" ///
	5 "    9+ Providers", replace
la val nprv nprv

egen NumPresent = rowtotal(s1_1a_1-s1_1a_6)
recode NumPresent (0=.) if missing(NumProviders)

* Create categories
gen npre = .
replace npre = 0 if NumPresent == 0
replace npre = 1 if NumPresent == 1
replace npre = 2 if inrange(NumPresent, 2, 3)
replace npre = 3 if inrange(NumPresent, 4, 5)
replace npre = 4 if inrange(NumPresent, 6, 8)
replace npre = 5 if NumPresent >= 9 & !missing(NumPresent)
la def npre 0 "    No Providers" 1 "    1 Provider" 2 "    2 Providers" ///
	3 "    3 Providers" 4 "    4 Providers" 5 "    5 Providers" ///
	6 "    6 Providers", replace
la val npre npre


//keep s0_employee nprv npre s1_02 s1_03 s1_04 s1_07 s1_08 s1_09 s1_11 s1_12 s1_13 s1_15

// OUTCOME 1: Out of Stock Vaccines
// Control/Drone/Total (44/42/86)
** Recode and label the variables
recode s6_01_1 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01a)
recode s6_01_2 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01b)
recode s6_01_3 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01c)
recode s6_01_4 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01d)
recode s6_01_5 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01e)
recode s6_01_6 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01f)
recode s6_01_7 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01g)
recode s6_01_8 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01h)
recode s6_01_9 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01i)
recode s6_01_10 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01j)
recode s6_01_11 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(base01k)
la var base01a	"1a. Out of Stock of Vaccine Janssen at Time of Survey"
la var base01b	"1b. Out of Stock of Vaccine AstraZeneca at Time of Survey"
la var base01c	"1c. Out of Stock of Vaccine Pfizer at Time of Survey"
la var base01d	"1d. Out of Stock of Pentavalent (DTC/Hepatitis B/Hib) at Time of Survey"
la var base01e	"1e. Out of Stock of Vaccine Pollio Injectable (VPI) at Time of Survey"
la var base01f	"1f. Out of Stock of Vaccine Pollio Oral (VPO) at Time of Survey"
la var base01g	"1g. Out of Stock of Vaccine Rotarix at Time of Survey"
la var base01h	"1h. Out of Stock of Vaccine Anti Rougeoleux (VAR) at Time of Survey"
la var base01i	"1i. Out of Stock of Vaccine Anti Tetanique (VAT) at Time of Survey"
la var base01j	"1j. Out of Stock of Vaccine Anti Pneumococcique (PCV10) at Time of Survey"
la var base01k	"1k. Out of Stock of Vaccine BCG at Time of Survey"
** Create the combined variable
egen base01 = rowmax(base01d-base01k)
la val base01 yn
la var base01	"1. Out of Stock of Any Vaccine at Time of Survey"
order base01, before(base01d)
** Recode all of the base01* variables to missing if s11_14 is No
foreach v of varlist base01* {
	replace `v' = . if s11_14 == 0
}


// OUTCOME 2: Out of Stock of Malaria Tests at Time of Survey
// Control/Drone/Total (54/53/107)
recode s4_06 (1 2 = 0 "No") (3 = 1 "Yes"), gen(base02)
la var base02	"2. Out of Stock of Malaria Tests at Time of Survey"


// OUTCOME 3: Out of Stock Malaria Tests in 3 Months Before Survey
// Control/Drone/Total (52/53/105)
gen base03 = s4_07
la val base03 yn
la var base03 	"3. Out of Stock of Malaria Tests in the 3 Months Before Survey"


// OUTCOME 4: Out of Stock Antimalarial Medicine at Time of Survey
// Control/Drone/Total (54/53/107)
recode s4_01 (1 2 = 0 "No") (3 = 1 "Yes"), gen(base04)
la var base04 	"4. Out of Stock of Antimalarial Medicine at Time of Survey"


// OUTCOME 5: Out of Stock of Any Contraceptive Method at Time of Survey
// Control/Drone/Total (54/14/68)
** Reshape stock_fp and s2_20 for this one
preserve
** Keep variables of interest
keep facility_id stock_fp* s2_20_*
reshape long stock_fp_ s2_20_, i(facility_id) j(n)
renvars *_, postd(1)
drop if missing(stock_fp)
** Keep only the five methods of interest
keep if inlist(stock_fp, "IMPLANT", "INJECTABLES_-_DEPO PROVERA", ///
	"INJECTABLES_-_SAYANA PRESS", "PILL", "MALE_CONDOM")
** Create a 'stock' variable to enumerate the five methods
gen stock = .
replace stock = 1 if stock_fp == "IMPLANT"
replace stock = 2 if stock_fp == "INJECTABLES_-_DEPO PROVERA"
replace stock = 3 if stock_fp == "INJECTABLES_-_SAYANA PRESS"
replace stock = 4 if stock_fp == "PILL"
replace stock = 5 if stock_fp == "MALE_CONDOM"
** Create an 'oos' variable to indicate the method is out of stock
gen oos = s2_20 == 3
** Drop unneeded variables
drop stock_fp s2_20 n
** Reshape wide
reshape wide oos, i(facility_id) j(stock)
** Recode all missing values to 0 so we get the full 107 represented
recode oos* (.=0)
** Rename the variables
rename oos1 base05a
rename oos2 base05b
rename oos3 base05c
rename oos4 base05d
rename oos5 base05e
** Create the combined variable and reorder it to the front
egen base05 = rowmax(base05a-base05e)
order base05, after(facility_id)
** Label the variables
la var base05	"5. Out of Stock of Any Contraceptive Method at Time of Survey"
la var base05a	"5a. Out of Stock of Implants at Time of Survey"
la var base05b	"5b. Out of Stock of Injectable Depo Provera at Time of Survey"
la var base05c	"5c. Out of Stock of Injectable Syana Press at Time of Survey"
la var base05d	"5d. Out of Stock of Pills at Time of Survey"
la var base05e	"5e. Out of Stock of Male Condoms at Time of Survey"
tempfile b05
save `b05'
restore
** Merge back on to the dataset
merge 1:1 facility_id using `b05'
drop _merge
** Apply value labels
la val base05* yn
** Drop measures from Drone facilities outside of Mahanoro
foreach v of varlist base05* {
	replace `v' = . if treatment == 1 & District != "Mahanoro"
}


// OUTCOME 6: Out of Stock of Any Contraceptive Method in 3 Months Before Survey
// Control/Drone/Total (51/13/64)
egen base06 = rowmax(s2_21_*)
la var base06 	"6. Out of Stock of Any Contraceptive Method in the 3 Months Before Survey"
** Drop measures from Drone facilities outside of Mahanoro
replace base06 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 7: Out of Stock of LARC Removal Supplies at Time of Survey
// Control/Drone/Total (43/14/57)
** Reshape stock_fp and s2_28 for this one
preserve
** Keep variables of interest
keep facility_id stock_fp* s2_28_*
reshape long stock_fp_ s2_28_, i(facility_id) j(n)
renvars *_, postd(1)
drop if missing(stock_fp)
** Keep only the two LARC methods
keep if inlist(stock_fp, "IMPLANT", "IUD")
** Create the variable to indicate the method is out of stock
gen base07 = s2_28 == 3
** Collapse to get the max of base07 by facility
collapse (max) base07, by(facility_id)
** Label 
la var base07 	"7. Out of Stock of LARC Removal Supplies at Time of Survey"
tempfile b07
save `b07'
restore
** Merge back on to the dataset
merge 1:1 facility_id using `b07'
drop _merge
** Apply value labels
la val base07 yn
** Drop measures from Drone facilities outside of Mahanoro
replace base07 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 8: Out of Stock of LARC Removal Supplies in 3 Months Before Survey
// Control/Drone/Total (43/14/57)
** Reshape stock_fp and s2_29 for this one
preserve
** Keep variables of interest
keep facility_id stock_fp* s2_29_*
reshape long stock_fp_ s2_29_, i(facility_id) j(n)
renvars *_, postd(1)
drop if missing(stock_fp)
** Keep only the two LARC methods
keep if inlist(stock_fp, "IMPLANT", "IUD")
** Create the variable to indicate the method is out of stock
gen base08 = s2_29 == 3
** Collapse to get the max of base08 by facility
collapse (max) base08, by(facility_id)
** Label 
la var base08 	"8. Out of Stock of LARC Removal Supplies in the 3 Months Before Survey"
tempfile b08
save `b08'
restore
** Merge back on to the dataset
merge 1:1 facility_id using `b08'
drop _merge
** Apply value labels
la val base08 yn
** Drop measures from Drone facilities outside of Mahanoro
replace base08 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 12: Number of Providers Present Today
// Control/Drone/Total (54/53/107)
egen base12 = rowtotal(s1_1a_1-s1_1a_6)
la var base12 	"12. Number of Providers Present Today"


// OUTCOME 13: Rated Emergency Reordering Procedure Somewhat or Very Easy
// Control/Drone/Total (54/53/107)
recode s1_04 (1 2 3 = 0 "No") (4 5 = 1 "Yes"), gen(base13)
la var base13 "13. Rated Emergency Reordering Procedure Somewhat or Very Easy"


// OUTCOME 14: Ordered Medical Commodities More Frequently Than Every 3 Months
// Control/Drone/Total (54/53/107)
recode s1_12 (5 6 = 0 "No") (1 2 3 4 = 1 "Yes"), gen(base14)
la var base14 "14. Ordered Medical Commodities More Frequently Than Every 3 Months"


// OUTCOME 15: Number of FP Visits Completed in Last Month (All Methods Combined)
// Control/Drone/Total (46/13/59)
** Convert -88 to missing for all variables in this set
foreach v of varlist s2_19_c-s2_19_m {
	recode `v' (-88=.)
}
** Sum the variables
egen base15 = rowtotal(s2_19_c-s2_19_m)
la var base15 "15. Number of FP Visits Completed in Last Month (All Methods Combined)"
** Change zeroes to missing if all component variables are missing
egen nm = rownonmiss(s2_19_c-s2_19_m)
replace base15 = . if nm == 0
drop nm
** Drop measures from Drone facilities outside of Mahanoro
replace base15 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 16: Number of New Clients Receiving FP in the Last Month
// Control/Drone/Total (46/12/58)
** Convert -88 to missing for all variables in this set
foreach v of varlist s2_19_p-s2_19_z {
	recode `v' (-88=.)
}
egen base16 = rowtotal(s2_19_p-s2_19_z)
la var base16 "16. Number of New Clients Receiving FP in the Last Month"
** Change zeroes to missing if all component variables are missing
egen nm = rownonmiss(s2_19_p-s2_19_z)
replace base16 = . if nm == 0
drop nm
** Drop measures from Drone facilities outside of Mahanoro
replace base16 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 17: Out of Stock Prevented Helping a Patient in the Last Six Months
// Control/Drone/Total (54/52/106)
gen base17 = s10_01
la val base17 yn
la var base17 "17. Out of Stock Prevented Helping a Patient in the Last Six Months"


// OUTCOME 18: In Past 6 Months Staff Traveled to District Pharmacy to Place Emergency Order
// Control/Drone/Total (54/53/107)
recode s10_14 (1 = 1 "Yes") (2 99 = 0 "No"), gen(base18)
la var base18 "18. In Past 6 Months Staff Traveled to District Pharmacy to Place Emergency Order"


// OUTCOME 19: Facility Has Working Fridge for Cold Chain Storage
// Control/Drone/Total (54/53/107)
gen base19 = s11_14
la val base19 yn
la var base19 "19. Facility Has Working Fridge for Cold Chain Storage"


// OUTCOME 21: Informal payment for contraception
// Control/Drone/Total (54/14/68)
egen base21 = rowmax(s2_02_*)
la val base21 yn
la var base21 "21. Informal Payment for Contraception"
* Drop measures from Drone facilities outside of Mahanoro
replace base21 = . if treatment == 1 & District != "Mahanoro"


// Keep the baseline variables
keep facility_id treatment base* s0_employee nprv npre s1_02 s1_03 s1_04 s1_07 s1_08 s1_09 s1_11 s1_12 s1_13 s1_15

// Collapse to get mean and counts
// preserve
// collapse (mean) base01x=base01 base01ax=base01a base01bx=base01b base01cx=base01c ///
//collapse (mean) base01x=base01 ///
//	base01dx=base01d base01ex=base01e base01fx=base01f base01gx=base01g ///
//	base01hx=base01h base01ix=base01i base01jx=base01j base01kx=base01k ///
//	base02x=base02 base03x=base03 base04x=base04 base05x=base05 ///
//	base05ax=base05a base05bx=base05b base05cx=base05c base05dx=base05d ///
//	base05ex=base05e base06x=base06 base07x=base07 base08x=base08 ///
//	base12x=base12 base13x=base13 base14x=base14 base15x=base15 base16x=base16 ///
//	base17x=base17 base18x=base18 base19x=base19 base21x=base21 ///
//	(count) base01n=base01 ///
//	base01dn=base01d base01en=base01e base01fn=base01f base01gn=base01g ///
//	base01hn=base01h base01in=base01i base01jn=base01j base01kn=base01k ///
//	base02n=base02 base03n=base03 base04n=base04 base05n=base05 ///
//	base05an=base05a base05bn=base05b base05cn=base05c base05dn=base05d ///
//	base05en=base05e base06n=base06 base07n=base07 base08n=base08 ///
//	base12n=base12 base13n=base13 base14n=base14 base15n=base15 base16n=base16 ///
//	base17n=base17 base18n=base18 base19n=base19 base21n=base21
//gen treatment = 3, before(base01x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) base01x=base01 ///
//	base01dx=base01d base01ex=base01e base01fx=base01f base01gx=base01g ///
//	base01hx=base01h base01ix=base01i base01jx=base01j base01kx=base01k ///
//	base02x=base02 base03x=base03 base04x=base04 base05x=base05 ///
//	base05ax=base05a base05bx=base05b base05cx=base05c base05dx=base05d ///
//	base05ex=base05e base06x=base06 base07x=base07 base08x=base08 ///
//	base12x=base12 base13x=base13 base14x=base14 base15x=base15 base16x=base16 ///
//	base17x=base17 base18x=base18 base19x=base19 base21x=base21 ///
//	(count) base01n=base01 ///
//	base01dn=base01d base01en=base01e base01fn=base01f base01gn=base01g ///
//	base01hn=base01h base01in=base01i base01jn=base01j base01kn=base01k ///
//	base02n=base02 base03n=base03 base04n=base04 base05n=base05 ///
//	base05an=base05a base05bn=base05b base05cn=base05c base05dn=base05d ///
//	base05en=base05e base06n=base06 base07n=base07 base08n=base08 ///
//	base12n=base12 base13n=base13 base14n=base14 base15n=base15 base16n=base16 ///
//	base17n=base17 base18n=base18 base19n=base19 base21n=base21, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\baseline_micro_1_facility.dta", replace

****************************************************************
** CHW QRE MEASURES **
// Open the CHW data
use "$ip\chw_cleaned_20230908_working.dta", clear

** Set value labels
la def yn 0 "No" 1 "Yes", replace

// Merge on Drone flights and districts
drop treatment
merge m:1 facility_id using "$dp\baseline_drone_treatment_district.dta", ///
	keepusing(District treatment)
drop _merge

// Keep only those variables needed for this report
** keep chw_id treatment District s1_service s1_01_14 s1_01_15 s1_04 s1_05


// OUTCOME 9: CHW Out of Stock of Malaria Tests
// Control/Drone/Total (82/68/150)
preserve
keep if s1_service == 14
recode s1_04 (1 2 = 0 "No") (3 = 1 "Yes"), gen(base09)
la var base09	"9. CHW Out of Stock of Malaria Tests"
keep chw_id base09
tempfile b09
save `b09'
restore


// OUTCOME 10: CHW Out of Stock of Malaria Treatment
// Control/Drone/Total (20/26/46)
preserve
keep if s1_service == 15
recode s1_04 (1 2 = 0 "No") (3 = 1 "Yes"), gen(base10)
la var base10	"10. CHW Out of Stock of Malaria Treatment"
keep chw_id base10
tempfile b10
save `b10'
restore


// OUTCOME 11: CHW Out of Stock of Family Planning Methods
// 11.  Control/Drone/Total (82/21/103)
// 11a. Control/Drone/Total (68/15/83)
// 11b. Control/Drone/Total (45/11/56)
// 11c. Control/Drone/Total (66/19/85)
// 11d. Control/Drone/Total (31/8/39)
preserve
** Keep only those records for the four methods of interest
keep if inlist(s1_service, 1, 2, 3, 5)
** Construct the oos variable
gen oos = s1_04 == 3
la val oos yn
** Reshape wide
keep chw_id treatment District s1_service oos
reshape wide oos, i(chw_id treatment District) j(s1_service)
** Rename variables
rename oos1 base11a
rename oos2 base11b
rename oos3 base11c
rename oos5 base11d
la var base11a	"11a. CHW Out of Stock of Injectable Depo Provera"
la var base11b	"11b. CHW Out of Stock of Injectable Sayana Press"
la var base11c	"11c. CHW Out of Stock of Pills"
la var base11d	"11d. CHW Out of Stock of Male Condoms"
** Create the combined variable
egen base11 = rowmax(base11a-base11d)
la val base11 yn
la var base11	"11. CHW Out of Stock of Any of the Four FP Methods"
order base11, before(base11a)
** Drop measures from Drone facilities outside of Mahanoro
foreach v of varlist base11* {
	replace `v' = . if treatment == 1 & District != "Mahanoro"
}
drop treatment District
tempfile b11
save `b11'
restore


// Merge the three temporary datasets together
keep chw_id treatment
duplicates drop
merge 1:1 chw_id using `b09'
drop _merge
merge 1:1 chw_id using `b10'
drop _merge
merge 1:1 chw_id using `b11'
drop _merge


// Collapse to get mean and counts
//preserve
//collapse (mean) base09x=base09 base10x=base10 base11x=base11 ///
//	base11ax=base11a base11bx=base11b base11cx=base11c base11dx=base11d ///
//	(count) base09n=base09 base10n=base10 base11n=base11 ///
//	base11an=base11a base11bn=base11b base11cn=base11c base11dn=base11d
//gen treatment = 3, before(base09x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) base09x=base09 base10x=base10 base11x=base11 ///
//	base11ax=base11a base11bx=base11b base11cx=base11c base11dx=base11d ///
//	(count) base09n=base09 base10n=base10 base11n=base11 ///
//	base11an=base11a base11bn=base11b base11cn=base11c base11dn=base11d, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\baseline_micro_2_chw.dta", replace

****************************************************************
** UAV MEASURES **
// Open the UAV data
use "$ip\uav_cleaned_20240520_working.dta", clear

// Merge on Drone flights and districts
merge m:1 facility_id using "$dp\baseline_drone_treatment_district.dta", ///
	keepusing(District)
drop if _merge == 2
drop _merge

// Keep only those variables needed for this report
** keep provider_id visit_id treatment s1_01

// Create an absent variable
recode s1_01 (1=0 "No") (0=1 "Yes"), gen(absent)
drop s1_01

/*
// Reshape wide
reshape wide absent, i(provider_id) j(visit_id)
*/

// OUTCOME 20: Provider is Absent
// Control/Drone/Total (183/162/345)
la def yn 0 "No" 1 "Yes", replace
gen base20 = absent
// egen base20 = rowmax(absent*)
la val base20 yn
la var base20 "20. Provider is Absent"


// Keep the baseline variables
keep provider_id treatment base*

// Collapse to get mean and count
//preserve
//collapse (mean) base20x=base20 (count) base20n=base20
//gen treatment = 3, before(base20x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) base20x=base20 (count) base20n=base20, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

//foreach z in x n {
//	la var base20`z' "20. Provider is Absent"
//}

// Save
save "$op\baseline_micro_3_uav.dta", replace

****************************************************************
** PROVIDER QRE MEASURES **
// Open the Provider data
use "$ip\provider_survey_CLEAN_20250401_working.dta", clear

// Merge on Drone flights and districts
merge m:1 facility_id using "$dp\baseline_drone_treatment_district.dta", ///
	keepusing(treatment District)
drop if _merge == 2
drop _merge

// Set value labels
la def yn 0 "No" 1 "Yes", replace

// Keep only those variables needed for this report
** keep provider_id treatment District s3_11-s3_16 s4_07 s4_08 s4_10 s6_03 s6_08 s6_14


// OUTCOME 22: Never Encouraged Patient to Choose a Different Method Due to Method Stockouts
// Control/Drone/Total (84/18/102)
recode s3_11 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(base22)
la var base22 "22. Never Encouraged Patient to Choose a Different Method Due to Method Stockouts"
** Drop measures from Drone facilities outside of Mahanoro
replace base22 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 23: Never Encouraged Patient to Use Method Other Than the One Wanted
// Control/Drone/Total (84/18/102)
recode s3_12 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(base23)
la var base23	"23. Never Encouraged Patient to Use Method Other Than the One Wanted"
** Drop measures from Drone facilities outside of Mahanoro
replace base23 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 24: Never Encouraged Patient to Use Long-Acting Method
// Control/Drone/Total (84/18/102)
recode s3_13 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(base24)
la var base24	"24. Never Encouraged Patient to Use Long-Acting Method"
** Drop measures from Drone facilities outside of Mahanoro
replace base24 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 25: Never Encouraged Patient to Use Short-Acting Method
// Control/Drone/Total (84/18/102)
recode s3_14 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(base25)
la var base25	"25. Never Encouraged Patient to Use Short-Acting Method"
** Drop measures from Drone facilities outside of Mahanoro
replace base25 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 26: Never Encouraged Patient to Use Permanent Method
// Control/Drone/Total (84/18/102)
recode s3_15 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(base26)
la var base26	"26. Never Encouraged Patient to Use Permanent Method"
** Drop measures from Drone facilities outside of Mahanoro
replace base26 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 27: Never Encouraged Patient to Use Natural Method
// Control/Drone/Total (84/18/102)
recode s3_16 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(base27)
la var base27	"27. Never Encouraged Patient to Use Natural Method"
** Drop measures from Drone facilities outside of Mahanoro
replace base27 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 28: There are Frequent Out of Stocks of Needed Supplies/Commodities
// Control/Drone/Total (84/84/168)
recode s4_07 (1 2 3 = 1 "Yes") (4 5 = 0 "No"), gen(base28)
la var base28	"28. There are Frequent Out of Stocks of Needed Supplies/Commodities"


// OUTCOME 29: Patients Frequently Leave without their Preferred FP Method
// Control/Drone/Total (84/18/102)
recode s4_08 (1 2 3 = 1 "Yes") (4 5 = 0 "No"), gen(base29)
la var base29	"29. Patients Frequently Leave without their Preferred FP Method"
** Drop measures from Drone facilities outside of Mahanoro
replace base29 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 30: I Feel Like I Have Everything I Need to Provide the Best Care
// Control/Drone/Total (84/84/168)
recode s4_10 (1 2 3 = 1 "Yes") (4 5 = 0 "No"), gen(base30)
la var base30	"30. I Feel Like I Have Everything I Need to Provide the Best Care"


// OUTCOME 31: Provider Received Their Salary Within the Last Month
// Control/Drone/Total (84/84/168)
recode s6_03 (1 = 1 "Yes") (2 3 4 = 0 "No"), gen(base31)
la var base31	"31. Provider Received Their Salary Within the Last Month"


// OUTCOME 32: Provider is Satisfied or Very Satisfied Working Here
// Control/Drone/Total (84/84/168)
recode s6_08 (1 2 = 1 "Yes") (3 4 = 0 "No"), gen(base32)
la var base32 	"32. Provider is Satisfied or Very Satisfied Working Here"


// OUTCOME 33: Number of Days Away from the Facility to Collect Supplies
// Control/Drone/Total (84/84/168)
gen base33 = s6_14
la val base33 yn
la var base33	"33. Mean Number of Days Away from the Facility to Collect Supplies"


// Keep the baseline variables
keep provider_id treatment base*


// Collapse to get means and counts
//preserve
//collapse (mean) base22x=base22 base23x=base23 base24x=base24 base25x=base25 ///
//	base26x=base26 base27x=base27 base28x=base28 base29x=base29 base30x=base30 ///
//	base31x=base31 base32x=base32 base33x=base33 ///
//	(count) base22n=base22 base23n=base23 base24n=base24 base25n=base25 ///
//	base26n=base26 base27n=base27 base28n=base28 base29n=base29 base30n=base30 ///
//	base31n=base31 base32n=base32 base33n=base33
//gen treatment = 3, before(base22x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) base22x=base22 base23x=base23 base24x=base24 base25x=base25 ///
//	base26x=base26 base27x=base27 base28x=base28 base29x=base29 base30x=base30 ///
//	base31x=base31 base32x=base32 base33x=base33 ///
//	(count) base22n=base22 base23n=base23 base24n=base24 base25n=base25 ///
//	base26n=base26 base27n=base27 base28n=base28 base29n=base29 base30n=base30 ///
//	base31n=base31 base32n=base32 base33n=base33, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\baseline_micro_4_provider.dta", replace

****************************************************************
** EXIT CLIENT MEASURES **
// Open the CEI data
use "$ip\cei_cleaned_20230911_working.dta", clear

** Set value labels
la def yn 0 "No" 1 "Yes", replace

// Merge on Drone flights and districts
drop treatment
merge m:1 facility_id using "$dp\baseline_drone_treatment_district.dta", ///
	keepusing(treatment District)
drop if _merge == 2
drop _merge

// Keep only those variables needed for this report
** keep cei_id treatment District s2_01 s2_04 s2_21 s7_* s9_01


// OUTCOME 34: Currently Using Contraception
// Control/Drone/Total (65/21/86)
gen base34 = s2_01
la val base34 yn
la var base34	"34. Currently Using Contraception"
** Drop measures from Drone facilities outside of Mahanoro
replace base34 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 35: Received Preferred Method
// Control/Drone/Total (65/21/86)
gen base35 = s2_04
la val base35 yn
la var base35	"35. Received Preferred Method"
** Drop measures from Drone facilities outside of Mahanoro
replace base35 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 36: Made an Informal Payment for FP
// Control/Drone/Total (65/21/86)
gen base36 = s2_21 > 0 if !missing(s2_21)
la val base36 yn
la var base36	"36. Made an Informal Payment for FP"
** Drop measures from Drone facilities outside of Mahanoro
replace base36 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 37: All Experience of Care Questions That Had at Least 80/20 Variation at Baseline
// Control/Drone/Total (286/280/566)
** NOTE: The variables constructed below are those with no greater than 80% Yes
**		 at baseline
gen base37a = s7_01		// 68.2%
gen base37b = s7_02		// 80.39%
gen base37c = s7_04		// 75.97%
gen base37d = s7_05		// 53.36%
gen base37e = s7_13		// 39.40%
gen base37f = s7_16		// 44.88%
la val base37* yn
la var base37a	"37a. Did the Nurses or Other Providers Introduce Themselves to You?"
la var base37b	"37b. Did the Nurses or Other Providers Call You By Your Name or Child's Name?"
la var base37c	"37c. Did You Feel the Nurses and Other Staff Treated You in a Friendly Manner?"
la var base37d	"37d. Did the Doctors, Nurses and Other Staff Show That They Cared About You?"
la var base37e	"37e. Did the Provider Ask You if You Had Any Questions?"
la var base37f	"37f. Did the Nurses at the Facility Talk to You About How You Were Feeling?"


// OUTCOME 38: Facility Did Not Have the Medicines and Supplies When You Visited
// Control/Drone/Total (286/280/566)
recode s9_01 (1 = 0 "No") (0 = 1 "Yes"), gen(base38)
la var base38	"38. Facility Did Not Have the Medicines and Supplies When You Visited"


// Keep the baseline variables
keep cei_id treatment base*


// Collapse to get means and counts
//preserve
//collapse (mean) base34x=base34 base35x=base35 base36x=base36 base37ax=base37a ///
//	base37bx=base37b base37cx=base37c base37dx=base37d base37ex=base37e ///
//	base37fx=base37f base38x=base38 ///
//	(count) base34n=base34 base35n=base35 base36n=base36 base37an=base37a ///
//	base37bn=base37b base37cn=base37c base37dn=base37d base37en=base37e ///
//	base37fn=base37f base38n=base38
//gen treatment = 3, before(base34x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) base34x=base34 base35x=base35 base36x=base36 base37ax=base37a ///
//	base37bx=base37b base37cx=base37c base37dx=base37d base37ex=base37e ///
//	base37fx=base37f base38x=base38 ///
//	(count) base34n=base34 base35n=base35 base36n=base36 base37an=base37a ///
//	base37bn=base37b base37cn=base37c base37dn=base37d base37en=base37e ///
//	base37fn=base37f base38n=base38, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\baseline_micro_5_cei.dta", replace

****************************************************************
** WOMEN'S QRE MEASURES **
// Open the Women's data
use "$ip/women_cleaned_20240607_working.dta", clear

// Set value labels
la def yn 0 "No" 1 "Yes", replace

// Merge on Drone flights and districts
drop treatment
merge m:1 facility_id using "$dp/baseline_drone_treatment_district.dta", ///
	keepusing(District treatment)
drop _merge

// Keep only those variables needed for this report
/*
keep respondent treatment District ///
	s3_1					/// Outcome 39
	s3_5					/// Outcome 40
	s3_2 s3_3				/// Outcome 41 & 45
**# Bookmark #47
	????					/// Outcome 42
	s3_8					/// Outcome 43
	s3_14					/// Outcome 44
	s3b_2 s3b_3 s3b_4 s3b_5	/// Outcome 46
	s3b_7					/// Outcome 47
	s3b_8					/// Outcome 48
	s3b_16					/// Outcome 49
	s3b_22					/// Outcome 50
	s3b_25					/// Outcome 51
	s10_0					/// Outcome 60
	s10_1					/// Outcome 61
	s10_2					/// Outcome 62
	s10_3					/// Outcome 63
	s10_4					/// Outcome 64
	s10_5					/// Outcome 65
	s10_6					/// Outcome 66
	s10_7					/// Outcome 67
	s10_9					/// Outcome 68
	s10_10					/// Outcome 69
	s11_6					/// Outcome 70
	s11_13 s11_8			/// Outcome 71
	s11_14					/// Outcome 72
	s11_15					/// Outcome 73
	s11_16					/// Outcome 74
	s11_17					/// Outcome 75
	s11_18					//  Outcome 76
*/


* Create categories for age
gen agecat = .
replace agecat = 1 if inrange(s1_3, 15, 19)
replace agecat = 2 if inrange(s1_3, 20, 24)
replace agecat = 3 if inrange(s1_3, 25, 29)
replace agecat = 4 if inrange(s1_3, 30, 34)
replace agecat = 5 if inrange(s1_3, 35, 39)
replace agecat = 6 if inrange(s1_3, 40, 49)
la def agecat 1 "    15 - 19" 2 "    20 - 24" 3 "    25 - 29" ///
	4 "    30 - 34" 5 "    35 - 39" 6 "    40 - 49", replace
la val agecat agecat

// Highest Level of Education Attended
* Create a new categorical variable to hold this information
gen attend = s1_11
recode attend (.=0)
la def attend 0 "    No Education" 1 "    Primary" 2 "    Secondary 1" ///
	3 "    Secondary 2" 4 "    Superior", replace
la val attend attend

// Religion
// Variables s1_17-s1_19 (categorical)
* Relabel variables
la var s1_17 "Religion"
la var s1_18 "Religiosity"
la var s1_19 "Degree Religion Influences Decisions on FP"
replace s1_19 = . if s1_19 < 0

// Total Number of Pregnancies
* Create a new variable to hold this information
recode s2_2 s2_4 s2_6 (.=0) if s2_1 == 1
gen pregs = s2_2 + s2_4 + s2_6, after(s2_1)

* Categorize the variable
recode pregs (6/13=6), gen(pregcat)
la def pregcat 0 "    0" 1 "    1" 2 "    2" 3 "    3" 4 "    4" ///
	5 "    5" 6 "    6 or More", replace
la val pregcat pregcat

// Number of Live Births
recode s2_2 s2_4 (.=0) if s2_1 == 1
gen lbs = s2_2 + s2_4, after(s2_1)

* Categorize the variable
recode lbs (6/13=6), gen(lbcat)
la def lbcat 0 "    0" 1 "    1" 2 "    2" 3 "    3" 4 "    4" ///
	5 "    5" 6 "    6 or More", replace
la val lbcat lbcat

// Number of Living Children
* Set the variable
//s2_2

* Categorize the variable
recode s2_2 (6/13=6), gen(lccat)
la def lccat 0 "    0" 1 "    1" 2 "    2" 3 "    3" 4 "    4" ///
	5 "    5" 6 "    6 or More", replace
la val lccat lccat




// Construct Unmet Need variable
// Create variables for unmet needs
** Months since last birth
gen dmSinceBirth = datediff_frac(s2_8, visit_date, "month")
la var dmSinceBirth "Months since last birth"

** Months since last menstruation event
gen daysSinceLM = .
replace daysSinceLM = s2_15_duration if s2_15 == 5 //		days
replace daysSinceLM = s2_15_duration * 7 if s2_15 == 6 //	weeks
replace daysSinceLM = s2_15_duration * 30 if s2_15 == 7 //	months
replace daysSinceLM = s2_15_duration * 365 if s2_15 == 8 // years
gen monthsActlSinceLM = datediff_frac(s2_15_date, visit_date, "month")
gen dmLastMenstruation = daysSinceLM / 365 * 12
replace dmLastMenstruation = monthsActlSinceLM if missing(dmLastMenstruation)
la var dmLastMenstruation "Months since last menstruation"
drop *SinceLM

** Days and months living together
gen startyear = substr(startday, 1, 4)
destring startyear, replace
gen dyLivingTogether = datediff_frac(s7_4_mnthyear, visit_date, "year") if ///
	s7_4 == 2
replace dyLivingTogether = startyear - s7_4_year if s7_4 == 1
la var dyLivingTogether "Time living together (years)"

** Days since sex
gen ddSinceSex = s7_6_days if s7_6 == 1 
replace ddSinceSex = s7_6_wks * 7 if s7_6 == 2
replace ddSinceSex = s7_6_mnths * 30 if s7_6 == 3
replace ddSinceSex = s7_6_yrs * 365 if s7_6 == 4
la var ddSinceSex "Days since last sex"

** Months to wait before next child
*** Start with answers from S8 Q3
gen dmWaitUntilNextChild = s8_4_mnths
replace dmWaitUntilNextChild = s8_4_yrs * 12 if missing(dmWaitUntilNextChild)
la var dmWaitUntilNextChild "Months would like to wait before (a/another) child"


// Initialize a variable for unmet needs
gen UnmetCat = .
la var UnmetCat "Unmet needs category"
la def UnmetCat ///
	0 "Never Had Sex" ///
	1 "Unmet Need for Spacing" ///
	2 "Unmet Need for Limiting" ///
	3 "Using for Spacing" ///
	4 "Using for Limiting" ///
	7 "No Unmet Need" ///
	8 "Not Sexually Active" ///
	9 "Infecund or Menopausal" ///
	98 "Unmarried - EM Sample or No Data" ///
	99 "Missing", replace
la val UnmetCat UnmetCat

// --- CONTRACEPTIVE USERS - GROUP 1 ---
** Using for Limiting - Does not want more children, sterilized, or infecund
recode UnmetCat (.=4) if ///
	s3_1 == 1 & ///						currently doing something or using FP
	(inlist(s8_2, 2, 3) | /// 			doesn't want another, says can't get pregnant
	s3_5_current == 1) // 				female sterilization
** Using for Spacing - All other contraceptive users
recode UnmetCat (.=3) if s3_1 == 1 		// currently doing something or using FP
										// and any women who did not fit one of 
										// the categories listed above


// --- PREGNANT OF POSTPARTUM AMENNORHEIC - GROUP 2 ---
** Create PPA variable for women who are pregnant or for whom menstruation
**  has not returned since last birth
gen PregPPA = (s2_12 == 1 | s2_11 == 0) | /// 						pregnant OR period not returned
	(dmSinceBirth < dmLastMenstruation & dmSinceBirth < 60 & /// 	months since last birth less than 60
	!missing(dmSinceBirth) & !missing(dmLastMenstruation)) // 		neither variable missing
la var PregPPA "Women is pregnant or postpartum amennorheic"
** Create a second PPA variable for women who are pregnant or PPA for < 24 months
gen PregPPA24 = s2_12 == 1 | /// 				pregnant
	(PregPPA == 1 & dmSinceBirth < 24) //		meets PPA criteria & months since last birth less than 24
la var PregPPA24 "Women is pregnant or postpartum amennorheic for less than 24 months"
la val PregPPA* yn

// Categorize wantedness of current pregnancy/last birth if pregnant/PPA
** Wanted current pregnancy now
gen WantedLast = s2_9 == 1 // currently pregnant, wanted pregnancy
** Wanted current pregnancy later
replace WantedLast = 2 if s2_10 == 1 & /// 		currently pregnant, wanted pregnancy later
	WantedLast == 0 //							does not meet any other prior criteria
** Didn't want current pregnancy
replace WantedLast = 3 if s2_10 == 2 & /// 		currently pregnant, did not want more children
	WantedLast == 0 //							does not meet any other prior criteria
** Wanted last birth now
replace WantedLast = 1 if s2_12 != 1 & /// 		not currently pregnant
	s2_9 == 1 & /// 							for last pregnancy, wanted it at that time
	WantedLast == 0 //							does not meet any other prior criteria
** Wanted last birth later
replace WantedLast = 2 if s2_12 != 1 & /// 		not currently pregnant
	s2_10 == 1 & /// 							for last pregnancy, wanted it later
	WantedLast == 0 //							does not meet any other prior criteria
** Didn't want last birth
replace WantedLast = 3 if s2_12 != 1 & /// 		not currently pregnant
	s2_10 == 2 & /// 							for last pregnancy, did not want more children
	WantedLast == 0 //							does not meet any other prior criteria
** Recode zeroes to missing and assign value labels
recode WantedLast (0=.)
la def WantedLast 1 "Wanted current pregnancy or last birth now" ///
	2 "Wanted current pregnancy or last birth later" ///
	3 "Didn't want current pregnancy or last birth", replace
la val WantedLast WantedLast

// Recode UnmetCat based on Pregnant/PPA and Wantedness
** No unmet need if wanted current pregnancy/last birth at that time
recode UnmetCat (.=7) if PregPPA24 == 1 & WantedLast == 1
** Unmet Need for Spacing - Wanted current pregnancy/last birth later
recode UnmetCat (.=1) if PregPPA24 == 1 & WantedLast == 2
** Unmet Need for Limiting - Didn't want current pregnancy/last birth
recode UnmetCat (.=2) if PregPPA24 == 1 & WantedLast == 3
** Unmet Need Missing
recode UnmetCat (.=99) if PregPPA24 == 1 & missing(WantedLast)


// -- INFECUNDITY - GROUP 3 ---
** Create binary variable for infecund
gen Infecund = 0
la var Infecund "Infecund"
*** BOX 1
**** Married 5+ years ago, no children in past 5 years, never used contraception, 
****  excluding pregnant and PPA less than 24 months
replace Infecund = 1 if inlist(s7_1, 1, 2) & /// 			married/living together
	(dyLivingTogether >= 5 & !missing(dyLivingTogether)) & ///	living together 5+ yrs
	(dmSinceBirth >= 60 & !missing(dmSinceBirth)) & ///		last birth 5+ yrs ago
	s3_4 == 0 & ///											never used contraception
	PregPPA24 == 0
*** BOX 2
**** Declared infecund on future desires for children
replace Infecund = 2 if s8_2 == 3
*** BOX 3
**** Reported menopausal/hysterectomy on reason for not using contraception
// THESE TWO REASONS ARE NOT IN THE DATASET FOR S8 Q6
// replace Infecund = 3 if s11_5primary == 4
*** BOX 4
**** Time since last period is >= 6 months and not PPA
replace Infecund = 4 if dmLastMenstruation >= 6 & ///
	!missing(dmLastMenstruation) & PregPPA == 0
*** BOX 5
**** Reported menopausal/hysterectomy on time since last period
replace Infecund = 5 if s2_15 == 1
**** Never menstruated on time since last birth, unless had a birth in last 5 years
replace Infecund = 5 if s2_15 == 3 & (dmSinceBirth > 60 | ///
	missing(dmSinceBirth))
*** BOX 6
**** Time since last birth >= 60 months ago and last period was before last birth
replace Infecund = 6 if s2_15 == 2 & dmSinceBirth >= 60 & ///
	!missing(dmSinceBirth)
**** Never had a birth, but last period reported as before last birth (mistake?)
replace Infecund = 6 if s2_15 == 2 & missing(dmSinceBirth)
** Exclude pregnant and PPA < 24 months
replace Infecund = 0 if PregPPA24 == 1

** Recode Unmet Status to Infecund or Menopausal if woman is infecund
recode UnmetCat (.=9) if Infecund > 0

** NO NEED for Unmarried Women Who are not Sexually Active
gen SexuallyActive = inrange(ddSinceSex, 0, 30)
la val SexuallyActive yn
*** Never Had Sex - Unmarried/not living together and never had sex, so assume
***   no unmet need
recode UnmetCat (.=0) if s7_1 == 0 & s7_5 == 2
*** Not Sexually Active - Unmarried/not living together, not sexually active in
***   last 30 days, assume no unmet need
recode UnmetCat (.=8) if s7_1 == 0 & SexuallyActive == 0


// --- FECUND WOMEN - GROUP 4 ---
** No Unmet Need - Wants child within 2 years
recode UnmetCat (.=7) if inrange(dmWaitUntilNextChild, 1, 24) | ///
	s8_3 == 3 | ///			Currently pregnant, wants next child "soon/now"
	s8_4 == 3 //		Not pregnant, wants next child "soon/now"
** Unmet Need for Spacing - Wants next child in 2+ years, or wants child and 
**  undecided timing, or undecided if wants child
recode UnmetCat (.=1) if ///
	(dmWaitUntilNextChild > 24 & !missing(dmWaitUntilNextChild)) | ///
	s8_3 == 99 | /// 		Currently pregnant, wants next child "don't know"
	s8_4 == 99 | ///		Not currently pregnant, wants next child "don't know"
	s8_1 == 4 | /// 		Currently pregnant, "undecided/don't know" if wants another
	s8_2 == 4 //			Not currently pregnant, "undecided/don't know" if wants another
** Unmet Need for Limiting - Wants no more children
recode UnmetCat (.=2) if ///
	s8_1 == 2 | /// 		Currently pregnant, does not wants another child
	s8_2 == 2 //			Not currently pregnant, does not wants another child

	
// --- MISSING ---
recode UnmetCat (.=99)


// Create the simpler Unmet variable
recode UnmetCat (1/2=1 "Unmet Need") (else=0 "No Unmet Need"), gen(Unmet)
la var Unmet "Unmet Status"


****************************************************************************

// OUTCOME 39: Currently Using Any Contraceptive Method
// Control/Drone/Total (493/132/625)
recode s3_1 (1 2 = 1 "Yes") (0 = 0 "No"), gen(base39)
la var base39	"39. Currently Using Any Contraceptive Method"
** Drop measures from Drone facilities outside of Mahanoro
replace base39 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 40: Currently Using a Modern Contraceptive Method
// Control/Drone/Total (493/132/625)
** Set this variable as a No only if the women ONLY reports using 15 (Rhythm 
**  method) or 16 (Withdrawal)
gen base40 = s3_5 != "15" & s3_5 != "16" if !missing(s3_5)
** Recode base40 so that anyone who answered s3_1 is represented
recode base40 (.=0) if !missing(s3_1)
la val base40 yn
la var base40	"40. Currently Using a Modern Contraceptive Method"
** Drop measures from Drone facilities outside of Mahanoro
replace base40 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 41: Has Aligned and Preferred Contraceptive Use
// Control/Drone/Total (492/132/624)
** Yes if Using (s3_1) is Yes/Sometimes and Glad Using (s3_3) is Yes, OR
** 		Using (s3_1) is No and Wish Using (s3_2) is No
** No if Using (s3_1) is Yes/Sometimes and Glad Using (s3_3) is No, OR
** 		Using (s3_1) is No and Wish Using (s3_2) is Yes
gen base41 = 1 if (inlist(s3_1, 1, 2) & s3_3 == 1) | (s3_1 == 0 & s3_2 == 0)
replace base41 = 0 if (inlist(s3_1, 1, 2) & s3_3 == 0) | (s3_1 == 0 & s3_2 == 1)
la val base41 yn
la var base41	"41. Has Aligned and Preferred Contraceptive Use"
** Drop measures from Drone facilities outside of Mahanoro
replace base41 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 42: Has Unmet Need for Contraception
// Control/Drone/Total (594/154/748)
gen base42 = Unmet
la val base42 yn
la var base42	"42. Has Unmet Need for Contraception"
** Drop measures from Drone facilities outside of Mahanoro
replace base42 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 43: Obtained Method from Public Facility
// Control/Drone/Total (216/59/275)
recode s3_8 (1 = 1 "Yes") (2 3 = 0 "No"), gen(base43)
la var base43	"43. Obtained Method from Public Facility"
** Drop measures from Drone facilities outside of Mahanoro
replace base43 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 44: Obtained Method from Closest Facility to Home
// Control/Drone/Total (228/65/293)
recode s3_14 (1 = 1 "Yes") (0 = 0 "No") (99=.), gen(base44)
la var base44	"44. Obtained Method from Closest Facility to Home"
** Drop measures from Drone facilities outside of Mahanoro
replace base44 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 45: Among Those Not Using, Wishes They Were Using Contraception
// Control/Drone/Total (265/67/332)
gen base45 = s3_2
la val base45 yn
la var base45	"45. Among Those Not Using, Wishes They Were Using Contraception"
** Drop measures from Drone facilities outside of Mahanoro
replace base45 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 46: Received MII+
// Control/Drone/Total (228/65/293)
gen base46 = s3b_2 == 1 & s3b_3 == 1 & s3b_4 == 1 & s3b_5 == 1
recode base46 (0=.) if missing(s3b_2)
la val base46 yn
la var base46	"46. Received MII+"
** Drop measures from Drone facilities outside of Mahanoro
replace base46 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 47: FP User Would Refer a Friend to the Facility
// Control/Drone/Total (228/65/293)
gen base47 = s3b_7
la val base47 yn
la var base47	"47. FP User Would Refer a Friend to the Facility"
** Drop measures from Drone facilities outside of Mahanoro
replace base47 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 48: Made an Informal Payment
// Control/Drone/Total (183/47/230)
** Only include women who went to a public facility
gen base48 = s3b_8 > 0 & !missing(s3b_8) if s3_8 == 1
la val base48 yn
la var base48	"48. Made an Informal Payment"
** Drop measures from Drone facilities outside of Mahanoro
replace base48 = . if treatment == 1 & District != "Mahanoro"


** OUTCOME 49: There is Another Method They Would Prefer to Use
// Control/Drone/Total (239/54/293)
gen base49 = s3b_16
la val base49 yn
la var base49	"49. There is Another Method They Would Prefer to Use"
** Drop measures from Drone facilities outside of Mahanoro
replace base49 = . if treatment == 1 & District != "Mahanoro"


** OUTCOME 50: Among Users, Felt Had Enough Information to Make a Good Decision
// Control/Drone/Total (228/65/293)
gen base50 = s3b_22
la val base50 yn
la var base50	"50. Among Users, Felt Had Enough Information to Make a Good Decision"
** Drop measures from Drone facilities outside of Mahanoro
replace base50 = . if treatment == 1 & District != "Mahanoro"


** OUTCOME 51: Among Users, Felt They Could Not Say No to Using
// Control/Drone/Total (228/65/293)
recode s3b_25 (1=0 "No") (0=1 "Yes"), gen(base51)
la var base51	"51. Among Users, Felt They Could Not Say No to Using"
** Drop measures from Drone facilities outside of Mahanoro
replace base51 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 60: Sought Healthcare from a Public or Private Facility, Ever
// Control/Drone/Total (594/605/1199)
gen base60 = s10_0
la val base60 yn
la var base60	"60. Sought Healthcare from a Public or Private Facility, Ever"


// OUTCOME 61: Sought Healthcare from a Public Facility the Most Recent Time
// Control/Drone/Total (541/532/1073)
recode s10_1 (1=1 "Yes") (2=0 "No"), gen(base61)
la var base61	"61. Sought Healthcare from a Public Facility the Most Recent Time"


// OUTCOME 62: Strongly Agree Staff Was Friendly
// Control/Drone/Total (479/450/929)
recode s10_2 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(base62)
la var base62	"62. Strongly Agree Staff Was Friendly"


// OUTCOME 63: Strongly Agree Staff Gave All Information Needed
// Control/Drone/Total (479/450/929)
recode s10_3 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(base63)
la var base63	"63. Strongly Agree Staff Gave All Information Needed"


// OUTCOME 64: Strongly Agree Staff Provided High Quality Services
// Control/Drone/Total (479/450/929)
recode s10_4 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(base64)
la var base64	"64. Strongly Agree Staff Provided High Quality Services"


// OUTCOME 65: Strongly Agree Staff Ensured Privacy
// Control/Drone/Total (479/450/929)
recode s10_5 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(base65)
la var base65	"65. Strongly Agree Staff Ensured Privacy"


// OUTCOME 66: Strongly Agree Staff Involved Me in Decisions About My Care
// Control/Drone/Total (479/450/929)
recode s10_6 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(base66)
la var base66	"66. Strongly Agree Staff Involved Me in Decisions About My Care"


// OUTCOME 67: Disagree or Strongly Disagree I Had to Wait a Long Time to Receive Care
// Control/Drone/Total (479/450/929)
recode s10_7 (4 5=1 "Yes") (1/3=0 "No") if s10_1 == 1, gen(base67)
la var base67	"67. Disagree or Strongly Disagree I Had to Wait a Long Time to Receive Care"


// OUTCOME 68: Disagree or Strongly Disagree Staff Did Not Have Methods
// Control/Drone/Total (390/364/754)
recode s10_9 (4 5=1 "Yes") (1/3=0 "No") (6=.) if s10_1 == 1, gen(base68)
la var base68	"68. Disagree or Strongly Disagree Staff Did Not Have Methods"
** Drop measures from Drone facilities outside of Mahanoro
replace base68 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 69: Disagree or Strongly Disagree Staff Did Not Have Vaccines
// Control/Drone/Total (393/367/760)
recode s10_10 (4 5=1 "Yes") (1/3=0 "No") (6=.) if s10_1 == 1, gen(base69)
la var base69	"69. Disagree or Strongly Disagree Staff Did Not Have Vaccines"


// OUTCOME 70: Perceived High Quality Care at the Closest Facility
// Control/Drone/Total (594/605/1199)
recode s11_6 (1=1 "Yes") (2 3=0 "No"), gen(base70)
la var base70	"70. Perceived High Quality Care at the Closest Facility"


// OUTCOME 71: Those Highly Satisfied with Care at Public Facility in Last Year
// Control/Drone/Total (361/319/680)
recode s11_13 (1=1 "Yes") (2/4=0 "No") if s11_8 == 1, gen(base71)
la var base71	"71. Those Highly Satisfied with Care Among Those at Public Facility in Last Year"


// OUTCOME 72: Those Who Rated Care as Excellent Quality at Public Facility in Last Year
// Control/Drone/Total (361/319/680)
recode s11_14 (1=1 "Yes") (2/5=0 "No") if s11_8 == 1, gen(base72)
la var base72	"72. Those Who Rated Care as Excellent Quality at Public Facility in Last Year"


// OUTCOME 73: Those Who Said They Were Treated Very Well by Provider at Public Facility in Last Year
// Control/Drone/Total (361/319/680)
recode s11_15 (1=1 "Yes") (2/3=0 "No") if s11_8 == 1, gen(base73)
la var base73	"73. Those Treated Very Well by Provider at Public Facility in Last Year"


// OUTCOME 74: Those Very Confident They Could Receive Method Next Week at Closest Facility
// Control/Drone/Total (361/68/429)
recode s11_16 (1=1 "Yes") (2/4=0 "No") if s11_8 == 1, gen(base74)
la var base74	"74. Those Very Confident They Could Receive Method Next Week at Closest Facility"
** Drop measures from Drone facilities outside of Mahanoro
replace base74 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 75: Those Very Confident the Closest Facility Has a Reliable Supply of FP
// Control/Drone/Total (361/68/429)
recode s11_17 (1=1 "Yes") (2/4=0 "No") if s11_8 == 1, gen(base75)
la var base75	"75. Those Very Confident the Closest Facility Has a Reliable Supply of FP"
** Drop measures from Drone facilities outside of Mahanoro
replace base75 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 76: Those Very Confident in Receiving Vaccinations at the Closest Facility
// Control/Drone/Total (361/319/680)
recode s11_18 (1=1 "Yes") (2/4=0 "No") if s11_8 == 1, gen(base76)
la var base76	"76. Those Very Confident in Receiving Vaccinations at the Closest Facility"


// OUTCOME 84: Source of Method When Last Obtained
// NOTE: THIS IS ENDLINE ONLY!!
// la var base84	"84. Source of Method When Last Obtained"


// Keep the baseline variables
keep respondent treatment base* agecat attend s1_17 s1_18 s1_19 married s7_3 s2_1 pregcat lbcat lccat


// Collapse to get means and counts
//preserve
//collapse (mean) base39x=base39 base40x=base40 base41x=base41 base42x=base42 ///
//	base43x=base43 base44x=base44 base45x=base45 base46x=base46 base47x=base47 ///
//	base48x=base48 base49x=base49 base50x=base50 base51x=base51 base60x=base60 ///
//	base61x=base61 base62x=base62 base63x=base63 base64x=base64 base65x=base65 ///
//	base66x=base66 base67x=base67 base68x=base68 base69x=base69 base70x=base70 ///
//	base71x=base71 base72x=base72 base73x=base73 base74x=base74 base75x=base75 ///
//	base76x=base76 ///
//	(count) base39n=base39 base40n=base40 base41n=base41 base42n=base42 ///
//	base43n=base43 base44n=base44 base45n=base45 base46n=base46 base47n=base47 ///
//	base48n=base48 base49n=base49 base50n=base50 base51n=base51 base60n=base60 ///
//	base61n=base61 base62n=base62 base63n=base63 base64n=base64 base65n=base65 ///
//	base66n=base66 base67n=base67 base68n=base68 base69n=base69 base70n=base70 ///
//	base71n=base71 base72n=base72 base73n=base73 base74n=base74 base75n=base75 ///
//	base76n=base76
//gen treatment = 3, before(base39x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) base39x=base39 base40x=base40 base41x=base41 base42x=base42 ///
//	base43x=base43 base44x=base44 base45x=base45 base46x=base46 base47x=base47 ///
//	base48x=base48 base49x=base49 base50x=base50 base51x=base51 base60x=base60 ///
//	base61x=base61 base62x=base62 base63x=base63 base64x=base64 base65x=base65 ///
//	base66x=base66 base67x=base67 base68x=base68 base69x=base69 base70x=base70 ///
//	base71x=base71 base72x=base72 base73x=base73 base74x=base74 base75x=base75 ///
//	base76x=base76 ///
//	(count) base39n=base39 base40n=base40 base41n=base41 base42n=base42 ///
//	base43n=base43 base44n=base44 base45n=base45 base46n=base46 base47n=base47 ///
//	base48n=base48 base49n=base49 base50n=base50 base51n=base51 base60n=base60 ///
//	base61n=base61 base62n=base62 base63n=base63 base64n=base64 base65n=base65 ///
//	base66n=base66 base67n=base67 base68n=base68 base69n=base69 base70n=base70 ///
//	base71n=base71 base72n=base72 base73n=base73 base74n=base74 base75n=base75 ///
//	base76n=base76, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op/baseline_micro_6_women.dta", replace


****************************************************************
**# Bookmark #1
** WOMEN'S QRE CHILD-LEVEL VACCINE MEASURES **
// Open the Women's data
use "$ip\women_cleaned_20240607_working.dta", clear

// Merge on Drone flights and districts
drop treatment
merge m:1 facility_id using "$dp\baseline_drone_treatment_district.dta", ///
	keepusing(District treatment)
drop _merge

// Keep only those variables needed for this report
keep respondent treatment District visit_date name_2_* dob_2_* born_type_2_* ///
	s5_1_* s5_2_* s5_3_* s5_4_* s5_4_dob_* s5_5*_day_* s5_7_* s5_10_* ///
	s5_12* s5_18_* s5_20_* s5_21_* s5_23_* s5_24_* s5_26_* s5_27_* s5_29_*

// Reshape long
reshape long name_2_ dob_2_ born_type_2_ s5_1_ s5_2_ s5_3_ s5_4_ s5_4_dob_ ///
	s5_5a_day_ s5_5b_day_ s5_5c_day_ s5_5d_day_ s5_5e_day_ s5_5f_day_ ///
	s5_5g_day_ s5_5h_day_ s5_5i_day_ s5_5j_day_ s5_5k_day_ s5_5l_day_ ///
	s5_5m_day_ s5_5n_day_ s5_5o_day_ s5_5p_day_ s5_5q_day_ s5_7_ s5_10_ ///
	s5_12_ s5_18_ s5_20_ s5_21_ s5_23_ s5_24_ s5_26_ s5_27_ s5_29_, ///
	i(respondent treatment District visit_date) j(n)
renvars *_, postd(1)
drop if missing(name_2)
format %td s5_4_dob
la val s5_3 sec5_3_1
la val s5_4 sec5_4_1
la val s5_7 sec5_7_1

order respondent treatment District visit_date n name_2 dob_2 born_type_2 ///
	s5_1 s5_2 s5_3 s5_4 s5_4_dob s5_5a_day s5_5b_day s5_5c_day s5_5d_day ///
	s5_5e_day s5_5f_day s5_5g_day s5_5h_day s5_5i_day s5_5j_day s5_5k_day ///
	s5_5l_day s5_5m_day s5_5n_day s5_5o_day s5_5p_day s5_5q_day s5_7 s5_10 ///
	s5_12 s5_18 s5_20 s5_21 s5_23 s5_24 s5_26 s5_27 s5_29

** Set value labels
la def yn 0 "No" 1 "Yes", replace
la def yndk 0 "No" 1 "Yes" 99 "Don't Know", replace

// Relabel variables and values
la var s5_1		"Do you have a card or other document where child's vaccinations are written down?"
la var s5_2		"Did you ever have a vaccination card for the child?"
la var s5_3		"May I see the card or other document with the child's vaccinations?"
la var s5_5a_day	"BCG"
la var s5_5b_day	"DPT 1"
la var s5_5c_day	"DPT 2"
la var s5_5d_day	"DPT 3"
la var s5_5e_day	"OPV 0"
la var s5_5f_day	"OPV 1"
la var s5_5g_day	"OPV 2"
la var s5_5h_day	"OPV 3"
la var s5_5i_day	"IPV"
la var s5_5j_day	"Rotavirus 1"
la var s5_5k_day	"Rotavirus 2"
la var s5_5l_day	"Rotavirus 3"
la var s5_5m_day	"Measles 1"
la var s5_5n_day	"Measles 2"
la var s5_5o_day	"Pneumococcal 1"
la var s5_5p_day	"Pneumococcal 2"
la var s5_5q_day	"Pneumococcal 3"
la var s5_10	"Child has received BCG vaccination"
la var s5_12	"Child has received oral polio vaccination"
la var s5_18	"Child has received pentavalent vaccination"
la var s5_20	"Number of times received pentavalent vaccination"
la var s5_21	"Child has received pneumococcal vaccination"
la var s5_23	"Number of times received pneumococcal vaccination"
la var s5_24	"Child has received rotavirus vaccination"
la var s5_26	"Number of times received rotavirus vaccination"
la var s5_27	"Child has received measles vaccination"
la var s5_29	"Number of times received measles vaccination"
la val s5_2 yn
la val s5_10 s5_12 s5_18 s5_21 s5_24 s5_27 yndk
la val s5_20 s5_23 s5_26 s5_29
la val s5_3 sec5_1_4

// Calculate child age in months and years
gen childage_d = datediff_frac(dob_2, visit_date, "day")
gen childage_w = childage_d / 7
gen childage_m = datediff_frac(dob_2, visit_date, "month")
gen childage_y = datediff_frac(dob_2, visit_date, "year")
order childage*, after(n)

// Create flag for the outcome measures
** Create a flag for children aged less than 1 year
gen ageflag = childage_y < 1.0
la val ageflag yn
la var ageflag "Children less than 1 year old"

// OUTCOME 52: Child Never Received a Vaccine to Prevent Disease
// Control/Drone/Total (57/71/128)
** First, get an indicator of the number of non-zero values in the 5a_day vars
egen daysum = rowtotal(s5_5*_day) if !missing(s5_5a_day)
** Next, create an indicator if any of the variables s5_10-s5_27 are yes
recode s5_10 s5_12 s5_18 s5_21 s5_24 s5_27 (99=.)
egen othermax = rowmax(s5_10 s5_12 s5_18 s5_21 s5_24 s5_27)
** Create the outcome variable
gen base52 = daysum == 0 | othermax == 0 if ageflag == 1
recode base52 (0=.) if missing(daysum) & missing(othermax)
la var base52	"52. Child Under 1 Year Old Never Received a Vaccine to Prevent Disease"
drop daysum othermax


// OUTCOME 53: Child Received BCG
// Control/Drone/Total (57/71/128)
gen base53 = (s5_5a_day > 0 & !missing(s5_5a_day)) | s5_10 == 1 if ageflag == 1
la val base53 yn
recode base53 (0=.) if missing(s5_5a_day) & missing(s5_10)
la var base53	"53. Child Under 1 Year Old Received BCG"


// OUTCOME 54a: Child Received at Least One Dose of DTP/Pentavalent
// Control/Drone/Total (57/71/128)
egen daysum = rowtotal(s5_5b_day s5_5c_day s5_5d_day) if !missing(s5_5b_day)
gen base54a = (daysum > 0 & !missing(daysum)) | s5_18 == 1 if ageflag == 1
replace base54a = . if missing(daysum) & missing(s5_18)
la val base54a yn
la var base54a	"54a. Child Under 1 Year Old Received at Least One Dose of DTP/Pentavalent"
drop daysum


// OUTCOME 54b: Child Received Three Doses of DTP/Pentavalent
// Control/Drone/Total (57/71/128)
gen daycount = inrange(s5_5b_day, 1, 44) & inrange(s5_5c_day, 1, 44) & ///
	inrange(s5_5d_day, 1, 44) if !missing(s5_5b_day)
gen base54b = (daycount == 1 & !missing(daycount)) | ///
	(s5_18 == 1 & inrange(s5_20, 3, 6)) if ageflag == 1
replace base54b = . if missing(daycount) & missing(s5_18)
la val base54b yn
la var base54b	"54b. Child Under 1 Year Old Received Three Doses of DTP/Pentavalent"
drop daycount


// OUTCOME 55: Child Received at Least One Dose of Pneumococcal
// Control/Drone/Total (57/69/126)
egen daysum = rowtotal(s5_5o_day s5_5p_day s5_5q_day) if !missing(s5_5o_day)
gen base55 = (daysum > 0 & !missing(daysum)) | s5_21 == 1 if ageflag == 1
replace base55 = . if missing(daysum) & missing(s5_21)
la val base55 yn
la var base55	"55. Child Under 1 Year Old Received at Least One Dose of Pneumococcal"
drop daysum


// OUTCOME 56: Child Received at Least One Dose of Rotavirus
// Control/Drone/Total (56/70/126)
egen daysum = rowtotal(s5_5j_day s5_5k_day s5_5l_day) if !missing(s5_5j_day)
gen base56 = (daysum > 0 & !missing(daysum)) | s5_24 == 1 if ageflag == 1
replace base56 = . if missing(daysum) & missing(s5_24)
la val base56 yn
la var base56	"56. Child Under 1 Year Old Received at Least One Dose of Rotavirus"
drop daysum


// OUTCOME 57: Child Received at Least One Dose of Measles
// Control/Drone/Total (57/70/127)
egen daysum = rowtotal(s5_5m_day s5_5n_day) if !missing(s5_5m_day)
gen base57 = (daysum > 0 & !missing(daysum)) | s5_27 == 1 if ageflag == 1
replace base57 = . if missing(daysum) & missing(s5_27)
la val base57 yn
la var base57	"57. Child Under 1 Year Old Received at Least One Dose of Measles"
drop daysum


// Keep the baseline variables
keep respondent treatment base*


// Collapse to get means and counts
//preserve
//collapse (mean) base52x=base52 base53x=base53 base54ax=base54a ///
//	base54bx=base54b base55x=base55 base56x=base56 base57x=base57 ///
//	(count) base52n=base52 base53n=base53 base54an=base54a base54bn=base54b ///
//	base55n=base55 base56n=base56 base57n=base57
//gen treatment = 3, before(base52x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) base52x=base52 base53x=base53 base54ax=base54a ///
//	base54bx=base54b base55x=base55 base56x=base56 base57x=base57 ///
//	(count) base52n=base52 base53n=base53 base54an=base54a base54bn=base54b ///
//	base55n=base55 base56n=base56 base57n=base57, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\baseline_micro_7_women_child_vaccine.dta", replace


****************************************************************
** WOMEN'S QRE CHILD-LEVEL HEALTH MEASURES **
// Open the Women's data
use "$ip\women_cleaned_20240607_working.dta", clear

// Merge on Drone flights and districts
drop treatment
merge m:1 facility_id using "$dp\baseline_drone_treatment_district.dta", ///
	keepusing(District treatment)
drop _merge

// Keep only those variables needed for this report
keep respondent treatment s6_10_* s6_12_*

// Reshape long
reshape long s6_10_ s6_12_, ///
	i(respondent treatment) j(n)
renvars *_, postd(1)
drop if missing(s6_10)

** Set value labels
la def yn 0 "No" 1 "Yes", replace
la def yndk 0 "No" 1 "Yes" 99 "Don't Know", replace

// Relabel variables and values
la var s6_10	"At any time during the illness, did the child have blood taken?"
la var s6_12	"Were you told by a healthcare provider that the child had malaria?"
la val s6_10 s6_12 yndk


// OUTCOME 58: Among Children with Fever in Last Two Weeks, Pct Who Had Blood Taken
// Control/Drone/Total (89/94/183)
recode s6_10 (1 = 1 "Yes") (0 99 = 0 "No"), gen(base58)
la var base58	"58. Among Children with Fever in Last Two Weeks, Pct Who Had Blood Taken"


// OUTCOME 59: Among Children with Fever in Last Two Weeks, Pct Diagnosed with Malaria
// Control/Drone/Total (89/94/183)
recode s6_12 (1 = 1 "Yes") (0 99 = 0 "No"), gen(base59)
la var base59	"59. Among Children with Fever in Last Two Weeks, Pct Diagnosed with Malaria"


// Keep the baseline variables
keep respondent treatment base*


// Collapse to get means and counts
//preserve
//collapse (mean) base58x=base58 base59x=base59 ///
//	(count) base58n=base58 base59n=base59
//gen treatment = 3, before(base58x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) base58x=base58 base59x=base59 ///
//	(count) base58n=base58 base59n=base59, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\baseline_micro_8_women_child_health.dta", replace


****************************************************************
** WOMEN'S QRE ZERO DOSE AND UNDER-IMMUNIZED **
// Open the Women's data
use "$ip\women_cleaned_20240607_working.dta", clear

// Merge on Drone flights and districts
drop treatment
merge m:1 facility_id using "$dp\baseline_drone_treatment_district.dta", ///
	keepusing(District treatment)
drop _merge

// Keep only those variables needed for this report
keep respondent treatment District visit_date s5_childage_* name_2_* dob_2_* ///
	born_type_2_* s5_1_* s5_5b_day_* s5_5c_day_* s5_5d_day_* s5_18_* s5_20_*

// Reshape long
reshape long name_2_ dob_2_ born_type_2_ s5_childage_ s5_1_ s5_5b_day_ ///
	s5_5c_day_ s5_5d_day_ s5_18_ s5_20_, ///
	i(respondent treatment District visit_date) j(n)
renvars *_, postd(1)
drop if missing(name_2)
destring s5_childage, replace

** Set value labels
la def yn 0 "No" 1 "Yes", replace
la def yndk 0 "No" 1 "Yes" 99 "Don't Know", replace

// Relabel variables and values
la var s5_1			"Do you have a card or other document where child's vaccinations are written down?"
la var s5_5b_day	"DPT 1"
la var s5_5c_day	"DPT 2"
la var s5_5d_day	"DPT 3"
la var s5_18		"Child has received pentavalent vaccination"
la var s5_20		"Number of times received pentavalent vaccination"
la val s5_18 yndk
la val s5_20

// Calculate child age in months and years
gen childage_d = datediff_frac(dob_2, visit_date, "day")
gen childage_w = childage_d / 7
gen childage_m = datediff_frac(dob_2, visit_date, "month")
gen childage_y = datediff_frac(dob_2, visit_date, "year")
order childage*, after(n)

// Create flags for the outcome measures
** Create a flag for children in the range of 18 weeks to less than 1 year
gen ageflag1 = childage_w > 18.0 & childage_y < 1.0
la val ageflag1 yn
la var ageflag1 "Children 18 weeks to less than 1 year"
** Create a flag for children 12 to 23 months
gen ageflag2 = childage_y >= 1.0 & childage_y < 2.0
la val ageflag2 yn
la var ageflag2 "Children 12 to 23 months"


// OUTCOME 78: Zero Dose Rate
// Zero-dose children as infants who have not received the first dose of 
//  diphtheria, tetanus, and pertussis-containing vaccine (DTP1) by the end 
//  of their first year of life.

** 78a: Children 18 Weeks to Less Than 1 Year
gen base78a = s5_5b_day == 0 | s5_18 == 0 if ageflag1 == 1
la val base78a yn
la var base78a	"78a. Zero-Dose Rate Among Children 18 Weeks to Less Than 1 Year Old"

** 78b: Children 12 to 23 Months
gen base78b = s5_5b_day == 0 | s5_18 == 0 if ageflag2 == 1
la val base78b yn
la var base78b	"78b. Zero-Dose Rate Among Children 12 to 23 Months Old"


// OUTCOME 79: Under-Immunized Rate
// Under-immunised children are defined as infants who have not received the 
//  third dose of DTP-containing vaccine (DTP3) by the end of their first 
//  year of life.

** 79a: Children 18 Weeks to Less Than 1 Year
gen vc = s5_5b_day > 0 & s5_5d_day == 0 if !missing(s5_5b_day)
gen vo = s5_18 == 1 & inrange(s5_20, 1, 2) if inlist(s5_18, 0, 1)
gen base79a = vc == 1 | vo == 1 if ageflag1 == 1
la val base79 yn
la var base79a	"79a. Under-Immunized Rate Among Children 18 Weeks to Less Than 1 Year Old"
drop vc vo

** 79b: Children 12 to 23 Months
gen vc = s5_5b_day > 0 & s5_5d_day == 0 if !missing(s5_5b_day)
gen vo = s5_18 == 1 & inrange(s5_20, 1, 2) if inlist(s5_18, 0, 1)
gen base79b = vc == 1 | vo == 1 if ageflag2 == 1
la val base79b yn
la var base79b	"79b. Under-Immunized Rate Among Children 12 to 23 Months Old"
drop vc vo

// Keep the baseline variables
keep respondent treatment base*


// Collapse to get means and counts
//preserve
//collapse (mean) base78ax=base78a base78bx=base78b base79ax=base79a ///
//	base79bx=base79b ///
//	(count) base78an=base78a base78bn=base78b base79an=base79a base79bn=base79b
//gen treatment = 3, before(base78ax)
//tempfile tot
//save `tot'
//restore
//collapse (mean) base78ax=base78a base78bx=base78b base79ax=base79a ///
//	base79bx=base79b ///
//	(count) base78an=base78a base78bn=base78b base79an=base79a base79bn=base79b, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\baseline_micro_9_women_child_zerodose_underimmuniz.dta", replace

