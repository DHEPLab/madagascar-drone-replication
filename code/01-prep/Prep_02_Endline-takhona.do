global od = "/Users/takhona/Desktop/Summer 2025/Drone analysis"


/*
SCRIPT: 		Madagascar_Mar2025_Report_Prep_02_Endline.do
AUTHOR:			Brian Frizzelle
DATE:			March 28, 2025
LAST UPDATED:	April 3, 2025

This script pulls the endline variables needed for the March 2025 report for 
Kat.

*/

// Set paths
global ip = "$od/Data"
global dp = "$od/Data"
global op = "$od/Results"

** FACILITY AUDIT MEASURES **
// Open the Facility Audit data
use "$ip/endline_facility_audit_cleaned_05032025_final.dta", clear

** Set value labels
la def yn 0 "No" 1 "Yes", replace

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




// OUTCOME 1: Out of Stock Vaccines
// Control/Drone/Total (46/46/92)
** Recode and label the variables
recode s6_01_1 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01a)
recode s6_01_2 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01b)
recode s6_01_3 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01c)
recode s6_01_4 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01d)
recode s6_01_5 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01e)
recode s6_01_6 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01f)
recode s6_01_7 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01g)
recode s6_01_8 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01h)
recode s6_01_9 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01i)
recode s6_01_10 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01j)
recode s6_01_11 (1 2 4 = 0 "No") (3 = 1 "Yes"), gen(end01k)
la var end01a	"1a. Out of Stock of Vaccine Janssen at Time of Survey"
la var end01b	"1b. Out of Stock of Vaccine AstraZeneca at Time of Survey"
la var end01c	"1c. Out of Stock of Vaccine Pfizer at Time of Survey"
la var end01d	"1d. Out of Stock of Pentavalent (DTC/Hepatitis B/Hib) at Time of Survey"
la var end01e	"1e. Out of Stock of Vaccine Pollio Injectable (VPI) at Time of Survey"
la var end01f	"1f. Out of Stock of Vaccine Pollio Oral (VPO) at Time of Survey"
la var end01g	"1g. Out of Stock of Vaccine Rotarix at Time of Survey"
la var end01h	"1h. Out of Stock of Vaccine Anti Rougeoleux (VAR) at Time of Survey"
la var end01i	"1i. Out of Stock of Vaccine Anti Tetanique (VAT) at Time of Survey"
la var end01j	"1j. Out of Stock of Vaccine Anti Pneumococcique (PCV10) at Time of Survey"
la var end01k	"1k. Out of Stock of Vaccine BCG at Time of Survey"
** Create the combined variable
egen end01 = rowmax(end01d-end01k)
la val end01 yn
la var end01	"1. Out of Stock of Any Vaccine at Time of Survey"
order end01, before(end01d)
** Recode all of the end01* variables to missing if s11_14 is No
foreach v of varlist end01* {
	replace `v' = . if s11_14 == 0
}


// OUTCOME 2: Out of Stock of Malaria Tests at Time of Survey
// Control/Drone/Total (54/55/109)
recode s4_06 (1 2 = 0 "No") (3 = 1 "Yes"), gen(end02)
la var end02	"2. Out of Stock of Malaria Tests at Time of Survey"


// OUTCOME 3: Out of Stock Malaria Tests in 3 Months Before Survey
// Control/Drone/Total (48/54/102)
gen end03 = s4_07
la val end03 yn
la var end03 	"3. Out of Stock of Malaria Tests in the 3 Months Before Survey"


// OUTCOME 4: Out of Stock Antimalarial Medicine at Time of Survey
// Control/Drone/Total (54/55/109)
recode s4_01 (1 2 = 0 "No") (3 = 1 "Yes"), gen(end04)
la var end04 	"4. Out of Stock of Antimalarial Medicine at Time of Survey"


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
rename oos1 end05a
rename oos2 end05b
rename oos3 end05c
rename oos4 end05d
rename oos5 end05e
** Create the combined variable and reorder it to the front
egen end05 = rowmax(end05a-end05e)
order end05, after(facility_id)
** Label the variables
la var end05	"5. Out of Stock of Any Contraceptive Method at Time of Survey"
la var end05a	"5a. Out of Stock of Implants at Time of Survey"
la var end05b	"5b. Out of Stock of Injectable Depo Provera at Time of Survey"
la var end05c	"5c. Out of Stock of Injectable Syana Press at Time of Survey"
la var end05d	"5d. Out of Stock of Pills at Time of Survey"
la var end05e	"5e. Out of Stock of Male Condoms at Time of Survey"
tempfile b05
save `b05'
restore
** Merge back on to the dataset
merge 1:1 facility_id using `b05'
drop _merge
** Apply value labels
la val end05* yn
** Drop measures from Drone facilities outside of Mahanoro
foreach v of varlist end05* {
	replace `v' = . if treatment == 1 & District != "Mahanoro"
}


// OUTCOME 6: Out of Stock of Any Contraceptive Method in 3 Months Before Survey
// Control/Drone/Total (47/12/59)
egen end06 = rowmax(s2_21_*)
la var end06 "6. Out of Stock of Any Contraceptive Method in the 3 Months Before Survey"
** Drop measures from Drone facilities outside of Mahanoro
replace end06 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 7: Out of Stock of LARC Removal Supplies at Time of Survey
// Control/Drone/Total (48/14/68)
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
gen end07 = s2_28 == 3
** Collapse to get the max of end07 by facility
collapse (max) end07, by(facility_id)
** Label 
la var end07 "7. Out of Stock of LARC Removal Supplies at Time of Survey"
tempfile b07
save `b07'
restore
** Merge back on to the dataset
merge 1:1 facility_id using `b07'
drop _merge
** Apply value labels
la val end07 yn
** Drop measures from Drone facilities outside of Mahanoro
replace end07 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 8: Out of Stock of LARC Removal Supplies in 3 Months Before Survey
// Control/Drone/Total (48/14/68)
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
gen end08 = s2_29 == 3
** Collapse to get the max of end08 by facility
collapse (max) end08, by(facility_id)
** Label 
la var end08 "8. Out of Stock of LARC Removal Supplies in the 3 Months Before Survey"
tempfile b08
save `b08'
restore
** Merge back on to the dataset
merge 1:1 facility_id using `b08'
drop _merge
** Apply value labels
la val end08 yn
** Drop measures from Drone facilities outside of Mahanoro
replace end08 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 12: Number of Providers Present Today
// Control/Drone/Total (54/55/109)
egen end12 = rowtotal(s1_1a_1-s1_1a_6)
la var end12 "12. Number of Providers Present Today"


// OUTCOME 13: Rated Emergency Reordering Procedure Somewhat or Very Easy
// Control/Drone/Total (54/55/109)
recode s1_04 (1 2 3 = 0 "No") (4 5 = 1 "Yes"), gen(end13)
la var end13 "13. Rated Emergency Reordering Procedure Somewhat or Very Easy"


// OUTCOME 14: Ordered Medical Commodities More Frequently Than Every 3 Months
// Control/Drone/Total (54/55/109)
recode s1_12 (5 6 = 0 "No") (1 2 3 4 = 1 "Yes"), gen(end14)
la var end14 "14. Ordered Medical Commodities More Frequently Than Every 3 Months"


// OUTCOME 15: Number of FP Visits Completed in Last Month (All Methods Combined)
// Control/Drone/Total (51/14/65)
** Convert -88 to missing for all variables in this set
foreach v of varlist s2_19_c-s2_19_m {
	recode `v' (-88=.)
}
** Sum the variables
egen end15 = rowtotal(s2_19_c-s2_19_m)
la var end15 "15. Number of FP Visits Completed in Last Month (All Methods Combined)"
** Change zeroes to missing if all component variables are missing
egen nm = rownonmiss(s2_19_c-s2_19_m)
replace end15 = . if nm == 0
drop nm
** Drop measures from Drone facilities outside of Mahanoro
replace end15 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 16: Number of New Clients Receiving FP in the Last Month
// Control/Drone/Total (51/14/65)
** Convert -88 to missing for all variables in this set
foreach v of varlist s2_19_p-s2_19_z {
	recode `v' (-88=.)
}
egen end16 = rowtotal(s2_19_p-s2_19_z)
la var end16 "16. Number of New Clients Receiving FP in the Last Month"
** Change zeroes to missing if all component variables are missing
egen nm = rownonmiss(s2_19_p-s2_19_z)
replace end16 = . if nm == 0
drop nm
** Drop measures from Drone facilities outside of Mahanoro
replace end16 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 17: Out of Stock Prevented Helping a Patient in the Last Six Months
// Control/Drone/Total (54/55/109)
gen end17 = s10_01
la val end17 yn
la var end17 "17. Out of Stock Prevented Helping a Patient in the Last Six Months"


// OUTCOME 18: In Past 6 Months Staff Traveled to District Pharmacy to Place Emergency Order
// Control/Drone/Total (54/55/109)
recode s10_14 (1 = 1 "Yes") (-999 2 = 0 "No"), gen(end18)
la var end18 "18. In Past 6 Months Staff Traveled to District Pharmacy to Place Emergency Order"


// OUTCOME 19: Facility Has Working Fridge for Cold Chain Storage
// Control/Drone/Total (54/55/109)
gen end19 = s11_14
la val end19 yn
la var end19 "19. Facility Has Working Fridge for Cold Chain Storage"


// OUTCOME 21: Informal payment for contraception
// Control/Drone/Total (54/14/68)
egen end21 = rowmax(s2_02_*)
la val end21 yn
la var end21 "21. Informal Payment for Contraception"
* Drop measures from Drone facilities outside of Mahanoro
replace end21 = . if treatment == 1 & District != "Mahanoro"


// Keep the endline variables
keep facility_id treatment end* s0_employee nprv npre s1_02 s1_03 s1_04 s1_07 s1_08 s1_09 s1_11 s1_12 s1_13 s1_15

// Collapse to get means and counts
//preserve
// collapse (mean) end01x=end01 end01ax=end01a end01bx=end01b end01cx=end01c ///
//collapse (mean) end01x=end01 ///
//	end01dx=end01d end01ex=end01e end01fx=end01f end01gx=end01g ///
//	end01hx=end01h end01ix=end01i end01jx=end01j end01kx=end01k ///
//	end02x=end02 end03x=end03 end04x=end04 end05x=end05 ///
//	end05ax=end05a end05bx=end05b end05cx=end05c end05dx=end05d ///
//	end05ex=end05e end06x=end06 end07x=end07 end08x=end08 ///
//	end12x=end12 end13x=end13 end14x=end14 end15x=end15 end16x=end16 ///
//	end17x=end17 end18x=end18 end19x=end19 end21x=end21 ///
//	(count) end01n=end01 ///
//	end01dn=end01d end01en=end01e end01fn=end01f end01gn=end01g ///
//	end01hn=end01h end01in=end01i end01jn=end01j end01kn=end01k ///
//	end02n=end02 end03n=end03 end04n=end04 end05n=end05 ///
//	end05an=end05a end05bn=end05b end05cn=end05c end05dn=end05d ///
//	end05en=end05e end06n=end06 end07n=end07 end08n=end08 ///
//	end12n=end12 end13n=end13 end14n=end14 end15n=end15 end16n=end16 ///
//	end17n=end17 end18n=end18 end19n=end19 end21n=end21
//gen treatment = 3, before(end01x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) end01x=end01 ///
//	end01dx=end01d end01ex=end01e end01fx=end01f end01gx=end01g ///
//	end01hx=end01h end01ix=end01i end01jx=end01j end01kx=end01k ///
//	end02x=end02 end03x=end03 end04x=end04 end05x=end05 ///
//	end05ax=end05a end05bx=end05b end05cx=end05c end05dx=end05d ///
//	end05ex=end05e end06x=end06 end07x=end07 end08x=end08 ///
//	end12x=end12 end13x=end13 end14x=end14 end15x=end15 end16x=end16 ///
//	end17x=end17 end18x=end18 end19x=end19 end21x=end21 ///
//	(count) end01n=end01 ///
//	end01dn=end01d end01en=end01e end01fn=end01f end01gn=end01g ///
//	end01hn=end01h end01in=end01i end01jn=end01j end01kn=end01k ///
//	end02n=end02 end03n=end03 end04n=end04 end05n=end05 ///
//	end05an=end05a end05bn=end05b end05cn=end05c end05dn=end05d ///
//	end05en=end05e end06n=end06 end07n=end07 end08n=end08 ///
//	end12n=end12 end13n=end13 end14n=end14 end15n=end15 end16n=end16 ///
//	end17n=end17 end18n=end18 end19n=end19 end21n=end21, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

drop end01a end01b end01c 

// Save
save "$op/endline_micro_1_facility.dta", replace

****************************************************************
** CHW QRE MEASURES **
// Open the CHW data
use "$ip\endline_chw_cleaned_28012025_final.dta", clear

** Set value labels
la def yn 0 "No" 1 "Yes", replace

// Keep only those variables needed for this report
keep chw_id treatment District s1_service* s1_01_14 s1_01_15 s1_04* s1_05*


// OUTCOME 9: CHW Out of Stock of Malaria Tests
// Control/Drone/Total (58/52/110)
preserve
keep chw_id s1_service_* s1_04_*
reshape long s1_service_ s1_04_, i(chw_id) j(n)
renvars *_, postd(1)
drop if missing(s1_service)
keep if s1_service == 14
recode s1_04 (1 2 = 0 "No") (3 = 1 "Yes"), gen(end09)
la var end09	"9. CHW Out of Stock of Malaria Tests"
keep chw_id end09
tempfile b09
save `b09'
restore


// OUTCOME 10: CHW Out of Stock of Malaria Treatment
// Control/Drone/Total (31/26/57)
preserve
keep chw_id s1_service_* s1_04_*
reshape long s1_service_ s1_04_, i(chw_id) j(n)
renvars *_, postd(1)
drop if missing(s1_service)
keep if s1_service == 15
recode s1_04 (1 2 = 0 "No") (3 = 1 "Yes"), gen(end10)
la var end10	"10. CHW Out of Stock of Malaria Treatment"
keep chw_id end10
tempfile b10
save `b10'
restore


// OUTCOME 11: CHW Out of Stock of Family Planning Methods
// 11.  Control/Drone/Total (66/21/87)
// 11a. Control/Drone/Total (60/19/79)
// 11b. Control/Drone/Total (41/14/55)
// 11c. Control/Drone/Total (48/17/65)
// 11d. Control/Drone/Total (34/9/43)
preserve
keep chw_id treatment District s1_service_* s1_04_*
reshape long s1_service_ s1_04_, i(chw_id treatment District) j(n)
renvars *_, postd(1)
drop if missing(s1_service)
** Keep only those records for the four methods of interest
keep if inlist(s1_service, 1, 2, 3, 5)
** Construct the oos variable
gen oos = s1_04 == 3
la val oos yn
** Reshape wide
keep chw_id treatment District s1_service oos
reshape wide oos, i(chw_id treatment District) j(s1_service)
** Rename variables
rename oos1 end11a
rename oos2 end11b
rename oos3 end11c
rename oos5 end11d
la var end11a	"11a. CHW Out of Stock of Injectable Depo Provera"
la var end11b	"11b. CHW Out of Stock of Injectable Sayana Press"
la var end11c	"11c. CHW Out of Stock of Pills"
la var end11d	"11d. CHW Out of Stock of Male Condoms"
** Create the combined variable
egen end11 = rowmax(end11a-end11d)
la val end11 yn
la var end11	"11. CHW Out of Stock of Any of the Four FP Methods"
order end11, before(end11a)
** Drop measures from Drone facilities outside of Mahanoro
foreach v of varlist end11* {
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


// Collapse to get means and counts
//preserve
//collapse (mean) end09x=end09 end10x=end10 end11x=end11 ///
//	end11ax=end11a end11bx=end11b end11cx=end11c end11dx=end11d ///
//	(count) end09n=end09 end10n=end10 end11n=end11 ///
//	end11an=end11a end11bn=end11b end11cn=end11c end11dn=end11d
//gen treatment = 3, before(end09x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) end09x=end09 end10x=end10 end11x=end11 ///
//	end11ax=end11a end11bx=end11b end11cx=end11c end11dx=end11d ///
//	(count) end09n=end09 end10n=end10 end11n=end11 ///
//	end11an=end11a end11bn=end11b end11cn=end11c end11dn=end11d, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\endline_micro_2_chw.dta", replace

****************************************************************
** UAV MEASURES **
// Open the UAV data
use "$ip\endline_UAV_CLEAN_VISITS_1_2_12032025_final.dta", clear

// Keep only those variables needed for this report
keep provider_id visit_id treatment s1_01

// Create an absent variable
recode s1_01 (1=0 "No") (0=1 "Yes"), gen(absent)
drop s1_01

/*
// Reshape wide
reshape wide absent, i(provider_id) j(visit_id)
*/

// OUTCOME 20: Provider is Absent
// Control/Drone/Total (155/144/299)
la def yn 0 "No" 1 "Yes", replace
gen end20 = absent
// egen end20 = rowmax(absent*)
la val end20 yn
la var end20 "20. Provider is Absent"


// Keep the endline variables
keep provider_id treatment end*

// Collapse to get means and counts
//preserve
//collapse (mean) end20x=end20 (count) end20n=end20
//gen treatment = 3, before(end20x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) end20x=end20 (count) end20n=end20, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

//foreach z in x n {
//	la var end20`z' "20. Provider is Absent"
//}

// Save
save "$op\endline_micro_3_uav.dta", replace

****************************************************************
** PROVIDER QRE MEASURES **
// Open the Provider data
use "$ip\endline_provider_survey_CLEAN_18022025_visit2_11032025_final.dta", clear

// Set value labels
la def yn 0 "No" 1 "Yes", replace

// Keep only those variables needed for this report
keep provider_id treatment District s3_11-s3_16 s4_07 s4_08 s4_10 s6_03 s6_08 s6_14


// OUTCOME 22: Never Encouraged Patient to Choose a Different Method Due to Method Stockouts
// Control/Drone/Total (79/21/100)
recode s3_11 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(end22)
la var end22 "22. Never Encouraged Patient to Choose a Different Method Due to Method Stockouts"
** Drop measures from Drone facilities outside of Mahanoro
replace end22 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 23: Never Encouraged Patient to Use Method Other Than the One Wanted
// Control/Drone/Total (79/21/100)
recode s3_12 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(end23)
la var end23	"23. Never Encouraged Patient to Use Method Other Than the One Wanted"
** Drop measures from Drone facilities outside of Mahanoro
replace end23 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 24: Never Encouraged Patient to Use Long-Acting Method
// Control/Drone/Total (79/21/100)
recode s3_13 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(end24)
la var end24	"24. Never Encouraged Patient to Use Long-Acting Method"
** Drop measures from Drone facilities outside of Mahanoro
replace end24 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 25: Never Encouraged Patient to Use Short-Acting Method
// Control/Drone/Total (79/21/100)
recode s3_14 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(end25)
la var end25	"25. Never Encouraged Patient to Use Short-Acting Method"
** Drop measures from Drone facilities outside of Mahanoro
replace end25 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 26: Never Encouraged Patient to Use Permanent Method
// Control/Drone/Total (79/21/100)
recode s3_15 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(end26)
la var end26	"26. Never Encouraged Patient to Use Permanent Method"
** Drop measures from Drone facilities outside of Mahanoro
replace end26 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 27: Never Encouraged Patient to Use Natural Method
// Control/Drone/Total (79/21/100)
recode s3_16 (1 2 3 = 0 "No") (4 = 1 "Yes"), gen(end27)
la var end27	"27. Never Encouraged Patient to Use Natural Method"
** Drop measures from Drone facilities outside of Mahanoro
replace end27 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 28: There are Frequent Out of Stocks of Needed Supplies/Commodities
// Control/Drone/Total (79/79/158)
recode s4_07 (1 2 3 = 1 "Yes") (4 5 = 0 "No"), gen(end28)
la var end28	"28. There are Frequent Out of Stocks of Needed Supplies/Commodities"


// OUTCOME 29: Patients Frequently Leave without their Preferred FP Method
// Control/Drone/Total (79/21/100)
recode s4_08 (1 2 3 = 1 "Yes") (4 5 = 0 "No"), gen(end29)
la var end29	"29. Patients Frequently Leave without their Preferred FP Method"
** Drop measures from Drone facilities outside of Mahanoro
replace end29 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 30: I Feel Like I Have Everything I Need to Provide the Best Care
// Control/Drone/Total (79/79/158)
recode s4_10 (1 2 3 = 1 "Yes") (4 5 = 0 "No"), gen(end30)
la var end30	"30. I Feel Like I Have Everything I Need to Provide the Best Care"


// OUTCOME 31: Provider Received Their Salary Within the Last Month
// Control/Drone/Total (79/79/158)
recode s6_03 (1 = 1 "Yes") (2 3 4 = 0 "No"), gen(end31)
la var end31	"31. Provider Received Their Salary Within the Last Month"


// OUTCOME 32: Provider is Satisfied or Very Satisfied Working Here
// Control/Drone/Total (79/79/158)
recode s6_08 (1 2 = 1 "Yes") (3 4 = 0 "No"), gen(end32)
la var end32 	"32. Provider is Satisfied or Very Satisfied Working Here"


// OUTCOME 33: Number of Days Away from the Facility to Collect Supplies
// Control/Drone/Total (79/79/158)
gen end33 = s6_14
la val end33 yn
la var end33	"33. Mean Number of Days Away from the Facility to Collect Supplies"


// Keep the endline variables
keep provider_id treatment end*


// Collapse to get means and counts
//preserve
//collapse (mean) end22x=end22 end23x=end23 end24x=end24 end25x=end25 ///
//	end26x=end26 end27x=end27 end28x=end28 end29x=end29 end30x=end30 ///
//	end31x=end31 end32x=end32 end33x=end33 ///
//	(count) end22n=end22 end23n=end23 end24n=end24 end25n=end25 ///
//	end26n=end26 end27n=end27 end28n=end28 end29n=end29 end30n=end30 ///
//	end31n=end31 end32n=end32 end33n=end33
//gen treatment = 3, before(end22x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) end22x=end22 end23x=end23 end24x=end24 end25x=end25 ///
//	end26x=end26 end27x=end27 end28x=end28 end29x=end29 end30x=end30 ///
//	end31x=end31 end32x=end32 end33x=end33 ///
//	(count) end22n=end22 end23n=end23 end24n=end24 end25n=end25 ///
//	end26n=end26 end27n=end27 end28n=end28 end29n=end29 end30n=end30 ///
//	end31n=end31 end32n=end32 end33n=end33, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\endline_micro_4_provider.dta", replace

****************************************************************
** EXIT CLIENT MEASURES **
// Open the CEI data
use "$ip\endline_cei_cleaned_28022025_final.dta", clear

** Set value labels
la def yn 0 "No" 1 "Yes", replace

// Keep only those variables needed for this report
keep cei_id treatment District s2_01 s2_04 s2_21 s7_* s9_01


// OUTCOME 34: Currently Using Contraception
// Control/Drone/Total (79/18/97)
gen end34 = s2_01
la val end34 yn
la var end34	"34. Currently Using Contraception"
** Drop measures from Drone facilities outside of Mahanoro
replace end34 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 35: Received Preferred Method
// Control/Drone/Total (79/18/97)
gen end35 = s2_04
la val end35 yn
la var end35	"35. Received Preferred Method"
** Drop measures from Drone facilities outside of Mahanoro
replace end35 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 36: Made an Informal Payment for FP
// Control/Drone/Total (79/18/97)
recode s2_21 (.f=0)
gen end36 = s2_21 > 0 if !missing(s2_21)
la val end36 yn
la var end36	"36. Made an Informal Payment for FP"
** Drop measures from Drone facilities outside of Mahanoro
replace end36 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 37: All Experience of Care Questions That Had at Least 80/20 Variation at endline
// Control/Drone/Total (283/293/576)
** NOTE: The variables constructed below are those with no greater than 80% Yes
**		 at endline
gen end37a = s7_01		// 68.2%
gen end37b = s7_02		// 80.39%
gen end37c = s7_04		// 75.97%
gen end37d = s7_05		// 53.36%
gen end37e = s7_13		// 39.40%
gen end37f = s7_16		// 44.88%
la val end37* yn
la var end37a	"37a. Did the Nurses or Other Providers Introduce Themselves to You?"
la var end37b	"37b. Did the Nurses or Other Providers Call You By Your Name or Child's Name?"
la var end37c	"37c. Did You Feel the Nurses and Other Staff Treated You in a Friendly Manner?"
la var end37d	"37d. Did the Doctors, Nurses and Other Staff Show That They Cared About You?"
la var end37e	"37e. Did the Provider Ask You if You Had Any Questions?"
la var end37f	"37f. Did the Nurses at the Facility Talk to You About How You Were Feeling?"


// OUTCOME 38: Facility Did Not Have the Medicines and Supplies When You Visited
// Control/Drone/Total (283/293/576)
recode s9_01 (1 = 0 "No") (0 = 1 "Yes"), gen(end38)
la var end38	"38. Facility Did Not Have the Medicines and Supplies When You Visited"


// Keep the endline variables
keep cei_id treatment end*


// Collapse to get means and counts
//preserve
//collapse (mean) end34x=end34 end35x=end35 end36x=end36 end37ax=end37a ///
//	end37bx=end37b end37cx=end37c end37dx=end37d end37ex=end37e ///
//	end37fx=end37f end38x=end38 ///
//	(count) end34n=end34 end35n=end35 end36n=end36 end37an=end37a ///
//	end37bn=end37b end37cn=end37c end37dn=end37d end37en=end37e ///
//	end37fn=end37f end38n=end38
//gen treatment = 3, before(end34x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) end34x=end34 end35x=end35 end36x=end36 end37ax=end37a ///
//	end37bx=end37b end37cx=end37c end37dx=end37d end37ex=end37e ///
///	end37fx=end37f end38x=end38 ///
//	(count) end34n=end34 end35n=end35 end36n=end36 end37an=end37a ///
//	end37bn=end37b end37cn=end37c end37dn=end37d end37en=end37e ///
//	end37fn=end37f end38n=end38, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\endline_micro_5_cei.dta", replace

****************************************************************
** WOMEN'S QRE MEASURES **
// Open the Women's data
use "$ip/endline_women_20250310_final.dta", clear

// Set value labels
la def yn 0 "No" 1 "Yes", replace

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
gen dmSinceBirth = datediff_frac(s2_8, startdate, "month")
la var dmSinceBirth "Months since last birth"

** Months since last menstruation event
gen daysSinceLM = .
replace daysSinceLM = s2_15_duration if s2_15 == 5 //		days
replace daysSinceLM = s2_15_duration * 7 if s2_15 == 6 //	weeks
replace daysSinceLM = s2_15_duration * 30 if s2_15 == 7 //	months
replace daysSinceLM = s2_15_duration * 365 if s2_15 == 8 // years
gen monthsActlSinceLM = datediff_frac(s2_15_date, startdate, "month")
gen dmLastMenstruation = daysSinceLM / 365 * 12
replace dmLastMenstruation = monthsActlSinceLM if missing(dmLastMenstruation)
la var dmLastMenstruation "Months since last menstruation"
drop *SinceLM
** Recalculate dmLastMenstruation using enddate if the current value is < 0
replace dmLastMenstruation = datediff_frac(s2_15_date, enddate, "month") if ///
	dmLastMenstruation < 0

** Days and months living together
gen startyear = year(startdate)
gen dyLivingTogether = datediff_frac(s7_4_mnthyear, startdate, "year") if ///
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

// Recode UnmetCat endd on Pregnant/PPA and Wantedness
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
	s8_4 == 3 //			Not pregnant, wants next child "soon/now"
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
// Control/Drone/Total (1404/381/1785)
recode s3_1 (1 2 = 1 "Yes") (0 = 0 "No"), gen(end39)
la var end39	"39. Currently Using Any Contraceptive Method"
** Drop measures from Drone facilities outside of Mahanoro
replace end39 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 40: Currently Using a Modern Contraceptive Method
// Control/Drone/Total (1404/381/1785)
** Set this variable as a No only if the women ONLY reports using 15 (Rhythm 
**  method) or 16 (Withdrawal)
gen end40 = s3_5 != "15" & s3_5 != "16" if !missing(s3_5)
** Recode base40 so that anyone who answered s3_1 is represented
recode end40 (.=0) if !missing(s3_1)
la val end40 yn
la var end40	"40. Currently Using a Modern Contraceptive Method"
** Drop measures from Drone facilities outside of Mahanoro
replace end40 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 41: Has Aligned and Preferred Contraceptive Use
// Control/Drone/Total (1403/375/1778)
** Yes if Using (s3_1) is Yes/Sometimes and Glad Using (s3_3) is Yes, OR
** 		Using (s3_1) is No and Wish Using (s3_2) is No
** No if Using (s3_1) is Yes/Sometimes and Glad Using (s3_3) is No, OR
** 		Using (s3_1) is No and Wish Using (s3_2) is Yes
gen end41 = 1 if (inlist(s3_1, 1, 2) & s3_3 == 1) | (s3_1 == 0 & s3_2 == 0)
replace end41 = 0 if (inlist(s3_1, 1, 2) & s3_3 == 0) | (s3_1 == 0 & s3_2 == 1)
la val end41 yn
la var end41	"41. Has Aligned and Preferred Contraceptive Use"
** Drop measures from Drone facilities outside of Mahanoro
replace end41 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 42: Has Unmet Need for Contraception
// Control/Drone/Total (1673/434/2107)
gen end42 = Unmet
la val end42 yn
la var end42	"42. Has Unmet Need for Contraception"
** Drop measures from Drone facilities outside of Mahanoro
replace end42 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 43: Obtained Method from Public Facility
// Control/Drone/Total (675/216/891)
recode s3_8 (1 = 1 "Yes") (2 3 -777 = 0 "No"), gen(end43)
la var end43	"43. Obtained Method from Public Facility"
** Drop measures from Drone facilities outside of Mahanoro
replace end43 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 44: Obtained Method from Closest Facility to Home
// Control/Drone/Total (735/227/962)
recode s3_14 (1 = 1 "Yes") (0 = 0 "No") (-999=.), gen(end44)
la var end44	"44. Obtained Method from Closest Facility to Home"
** Drop measures from Drone facilities outside of Mahanoro
replace end44 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 45: Among Those Not Using, Wishes They Were Using Contraception
// Control/Drone/Total (668/160/828)
gen end45 = s3_2
la val end45 yn
la var end45	"45. Among Those Not Using, Wishes They Were Using Contraception"
** Drop measures from Drone facilities outside of Mahanoro
replace end45 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 46: Received MII+
// Control/Drone/Total (736/221/957)
gen end46 = s3b_2 == 1 & s3b_3 == 1 & s3b_4 == 1 & s3b_5 == 1
recode end46 (0=.) if missing(s3b_2)
la val end46 yn
la var end46	"46. Received MII+"
** Drop measures from Drone facilities outside of Mahanoro
replace end46 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 47: FP User Would Refer a Friend to the Facility
// Control/Drone/Total (736/221/957)
gen end47 = s3b_7
la val end47 yn
la var end47	"47. FP User Would Refer a Friend to the Facility"
** Drop measures from Drone facilities outside of Mahanoro
replace end47 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 48: Made an Informal Payment
// Control/Drone/Total (539/160/699)
** Only include women who went to a public facility
recode s3b_8 (.f=0)
gen end48 = s3b_8 > 0 & !missing(s3b_8) if s3_8 == 1
la val end48 yn
la var end48	"48. Made an Informal Payment"
** Drop measures from Drone facilities outside of Mahanoro
replace end48 = . if treatment == 1 & District != "Mahanoro"


** OUTCOME 49: There is Another Method They Would Prefer to Use
// Control/Drone/Total (736/221/957)
gen end49 = s3b_16
la val end49 yn
la var end49	"49. There is Another Method They Would Prefer to Use"
** Drop measures from Drone facilities outside of Mahanoro
replace end49 = . if treatment == 1 & District != "Mahanoro"


** OUTCOME 50: Among Users, Felt Had Enough Information to Make a Good Decision
// Control/Drone/Total (736/221/957)
gen end50 = s3b_22
la val end50 yn
la var end50	"50. Among Users, Felt Had Enough Information to Make a Good Decision"
** Drop measures from Drone facilities outside of Mahanoro
replace end50 = . if treatment == 1 & District != "Mahanoro"


** OUTCOME 51: Among Users, Felt They Could Not Say No to Using
// Control/Drone/Total (736/221/957)
recode s3b_25 (1=0 "No") (0=1 "Yes"), gen(end51)
la var end51	"51. Among Users, Felt They Could Not Say No to Using"
** Drop measures from Drone facilities outside of Mahanoro
replace end51 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 60: Sought Healthcare from a Public or Private Facility, Ever
// Control/Drone/Total (1673/1704/3377)
gen end60 = s10_0
la val end60 yn
la var end60	"60. Sought Healthcare from a Public or Private Facility, Ever"


// OUTCOME 61: Sought Healthcare from a Public Facility the Most Recent Time
// Control/Drone/Total (1615/1617/3232)
recode s10_1 (1=1 "Yes") (2=0 "No"), gen(end61)
la var end61	"61. Sought Healthcare from a Public Facility the Most Recent Time"


// OUTCOME 62: Strongly Agree Staff Was Friendly
// Control/Drone/Total (1359/1271/2630)
recode s10_2 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(end62)
la var end62	"62. Strongly Agree Staff Was Friendly"


// OUTCOME 63: Strongly Agree Staff Gave All Information Needed
// Control/Drone/Total (1359/1271/2630)
recode s10_3 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(end63)
la var end63	"63. Strongly Agree Staff Gave All Information Needed"


// OUTCOME 64: Strongly Agree Staff Provided High Quality Services
// Control/Drone/Total (1359/1271/2630)
recode s10_4 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(end64)
la var end64	"64. Strongly Agree Staff Provided High Quality Services"


// OUTCOME 65: Strongly Agree Staff Ensured Privacy
// Control/Drone/Total (1359/1271/2630)
recode s10_5 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(end65)
la var end65	"65. Strongly Agree Staff Ensured Privacy"


// OUTCOME 66: Strongly Agree Staff Involved Me in Decisions About My Care
// Control/Drone/Total (1359/1271/2630)
recode s10_6 (1=1 "Yes") (2/5=0 "No") if s10_1 == 1, gen(end66)
la var end66	"66. Strongly Agree Staff Involved Me in Decisions About My Care"


// OUTCOME 67: Disagree or Strongly Disagree I Had to Wait a Long Time to Receive Care
// Control/Drone/Total (1359/1271/2630)
recode s10_7 (4 5=1 "Yes") (1/3=0 "No") if s10_1 == 1, gen(end67)
la var end67	"67. Disagree or Strongly Disagree I Had to Wait a Long Time to Receive Care"


// OUTCOME 68: Disagree or Strongly Disagree Staff Did Not Have Methods
// Control/Drone/Total (1070/249/1319)
recode s10_9 (4 5=1 "Yes") (1/3=0 "No") (6=.) if s10_1 == 1, gen(end68)
la var end68	"68. Disagree or Strongly Disagree Staff Did Not Have Methods"
** Drop measures from Drone facilities outside of Mahanoro
replace end68 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 69: Disagree or Strongly Disagree Staff Did Not Have Vaccines
// Control/Drone/Total (1157/1083/2240)
recode s10_10 (4 5=1 "Yes") (1/3=0 "No") (6=.) if s10_1 == 1, gen(end69)
la var end69	"69. Disagree or Strongly Disagree Staff Did Not Have Vaccines"


// OUTCOME 70: Perceived High Quality Care at the Closest Facility
// Control/Drone/Total (1673/1704/3377)
recode s11_6 (1=1 "Yes") (2 3=0 "No"), gen(end70)
la var end70	"70. Perceived High Quality Care at the Closest Facility"


// OUTCOME 71: Those Highly Satisfied with Care at Public Facility in Last Year
// Control/Drone/Total (1051/939/1990)
recode s11_13 (1=1 "Yes") (2/4=0 "No") if s11_8 == 1, gen(end71)
la var end71	"71. Those Highly Satisfied with Care Among Those at Public Facility in Last Year"


// OUTCOME 72: Those Who Rated Care as Excellent Quality at Public Facility in Last Year
// Control/Drone/Total (1051/939/1990)
recode s11_14 (1=1 "Yes") (2/5=0 "No") if s11_8 == 1, gen(end72)
la var end72	"72. Those Who Rated Care as Excellent Quality at Public Facility in Last Year"


// OUTCOME 73: Those Who Said They Were Treated Very Well by Provider at Public Facility in Last Year
// Control/Drone/Total (1051/939/1990)
recode s11_15 (1=1 "Yes") (2/3=0 "No") if s11_8 == 1, gen(end73)
la var end73	"73. Those Treated Very Well by Provider at Public Facility in Last Year"


// OUTCOME 74: Those Very Confident They Could Receive Method Next Week at Closest Facility
// Control/Drone/Total (1051/230/1281)
recode s11_16 (1=1 "Yes") (2/4=0 "No") if s11_8 == 1, gen(end74)
la var end74	"74. Those Very Confident They Could Receive Method Next Week at Closest Facility"
** Drop measures from Drone facilities outside of Mahanoro
replace end74 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 75: Those Very Confident the Closest Facility Has a Reliable Supply of FP
// Control/Drone/Total (1051/230/1281)
recode s11_17 (1=1 "Yes") (2/4=0 "No") if s11_8 == 1, gen(end75)
la var end75	"75. Those Very Confident the Closest Facility Has a Reliable Supply of FP"
** Drop measures from Drone facilities outside of Mahanoro
replace end75 = . if treatment == 1 & District != "Mahanoro"


// OUTCOME 76: Those Very Confident in Receiving Vaccinations at the Closest Facility
// Control/Drone/Total (1051/939/1990)
recode s11_18 (1=1 "Yes") (2/4=0 "No") if s11_8 == 1, gen(end76)
la var end76	"76. Those Very Confident in Receiving Vaccinations at the Closest Facility"


// OUTCOME 84: Source of Method When Last Obtained
// Control/Drone/Total (675/747/1422)
// NOTE: THIS IS ENDLINE ONLY!!
recode s3_8a (5 = 1 "Yes") (nonmiss = 0 "No"), gen(end77)
la var end77	"77. Obtained Last Method from Community Health Worker"


// Keep the endline variables
keep respondent treatment end* agecat attend s1_17 s1_18 s1_19 married s7_3 s2_1 pregcat lbcat lccat


// Collapse to get means and counts
//preserve
//collapse (mean) end39x=end39 end40x=end40 end41x=end41 end42x=end42 ///
//	end43x=end43 end44x=end44 end45x=end45 end46x=end46 end47x=end47 ///
//	end48x=end48 end49x=end49 end50x=end50 end51x=end51 end60x=end60 ///
//	end61x=end61 end62x=end62 end63x=end63 end64x=end64 end65x=end65 ///
//	end66x=end66 end67x=end67 end68x=end68 end69x=end69 end70x=end70 ///
//	end71x=end71 end72x=end72 end73x=end73 end74x=end74 end75x=end75 ///
//	end76x=end76 end77x=end77 ///
//	(count) end39n=end39 end40n=end40 end41n=end41 end42n=end42 ///
//	end43n=end43 end44n=end44 end45n=end45 end46n=end46 end47n=end47 ///
//	end48n=end48 end49n=end49 end50n=end50 end51n=end51 end60n=end60 ///
//	end61n=end61 end62n=end62 end63n=end63 end64n=end64 end65n=end65 ///
//	end66n=end66 end67n=end67 end68n=end68 end69n=end69 end70n=end70 ///
//	end71n=end71 end72n=end72 end73n=end73 end74n=end74 end75n=end75 ///
//	end76n=end76 end77n=end77
//gen treatment = 3, before(end39x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) end39x=end39 end40x=end40 end41x=end41 end42x=end42 ///
//	end43x=end43 end44x=end44 end45x=end45 end46x=end46 end47x=end47 ///
//	end48x=end48 end49x=end49 end50x=end50 end51x=end51 end60x=end60 ///
//	end61x=end61 end62x=end62 end63x=end63 end64x=end64 end65x=end65 ///
//	end66x=end66 end67x=end67 end68x=end68 end69x=end69 end70x=end70 ///
//	end71x=end71 end72x=end72 end73x=end73 end74x=end74 end75x=end75 ///
//	end76x=end76 end77x=end77 ///
//	(count) end39n=end39 end40n=end40 end41n=end41 end42n=end42 ///
//	end43n=end43 end44n=end44 end45n=end45 end46n=end46 end47n=end47 ///
//	end48n=end48 end49n=end49 end50n=end50 end51n=end51 end60n=end60 ///
//	end61n=end61 end62n=end62 end63n=end63 end64n=end64 end65n=end65 ///
//	end66n=end66 end67n=end67 end68n=end68 end69n=end69 end70n=end70 ///
//	end71n=end71 end72n=end72 end73n=end73 end74n=end74 end75n=end75 ///
//	end76n=end76 end77n=end77, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op/endline_micro_6_women.dta", replace


****************************************************************
** WOMEN'S QRE CHILD-LEVEL VACCINE MEASURES **
**# Bookmark #1
// Open the Women's data
use "$ip\endline_women_20250310_final.dta", clear

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
la def yndk 0 "No" 1 "Yes" -999 "Don't Know", replace

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
gen childage_d = datediff_frac(s5_4_dob, visit_date, "day")
gen childage_w = childage_d / 7
gen childage_m = datediff_frac(s5_4_dob, visit_date, "month")
gen childage_y = datediff_frac(s5_4_dob, visit_date, "year")
order childage*, after(n)

// Create flag for the outcome measures
** Create a flag for children aged less than 1 year
gen ageflag = childage_y < 1.0
la val ageflag yn
la var ageflag "Children less than 1 year old"


// OUTCOME 52: Child Never Received a Vaccine to Prevent Disease
// Control/Drone/Total (157/190/347)
** First, get an indicator of the number of non-zero values in the 5a_day vars
egen daysum = rowtotal(s5_5*_day) if !missing(s5_5a_day)
** Next, create an indicator if any of the variables s5_10-s5_27 are yes
recode s5_10-s5_27 (-999=.)
egen othermax = rowmax(s5_10-s5_27)
** Create the outcome variable
gen end52 = daysum == 0 | othermax == 0 if ageflag == 1
recode end52 (0=.) if missing(daysum) & missing(othermax)
la val end52 yn
la var end52	"52. Child Under 1 Year Old Never Received a Vaccine to Prevent Disease"
drop daysum othermax


// OUTCOME 53: Child Received BCG
// Control/Drone/Total (156/188/344)
gen end53 = (s5_5a_day > 0 & !missing(s5_5a_day)) | s5_10 == 1 if ageflag == 1
la val end53 yn
recode end53 (0=.) if missing(s5_5a_day) & missing(s5_10)
la var end53	"53. Child Under 1 Year Old Received BCG"


// OUTCOME 54a: Child Received at Least One Dose of DTP/Pentavalent
// Control/Drone/Total (155/189/344)
egen daysum = rowtotal(s5_5b_day s5_5c_day s5_5d_day) if !missing(s5_5b_day)
gen end54a = (daysum > 0 & !missing(daysum)) | s5_18 == 1 if ageflag == 1
replace end54a = . if missing(daysum) & missing(s5_18)
la val end54a yn
la var end54a	"54a. Child Under 1 Year Old Received at Least One Dose of DTP/Pentavalent"
drop daysum


// OUTCOME 54b: Child Received Three Doses of DTP/Pentavalent
// Control/Drone/Total (155/189/344)
gen daycount = inrange(s5_5b_day, 1, 44) & inrange(s5_5c_day, 1, 44) & ///
	inrange(s5_5d_day, 1, 44) if !missing(s5_5b_day)
gen end54b = (daycount == 1 & !missing(daycount)) | ///
	(s5_18 == 1 & inrange(s5_20, 3, 6)) if ageflag == 1
replace end54b = . if missing(daycount) & missing(s5_18)
la val end54b yn
la var end54b	"54b. Child Under 1 Year Old Received Three Doses of DTP/Pentavalent"
drop daycount


// OUTCOME 55: Child Received Pneumococcal
// Control/Drone/Total (156/189/345)
egen daysum = rowtotal(s5_5o_day s5_5p_day s5_5q_day) if !missing(s5_5o_day)
gen end55 = (daysum > 0 & !missing(daysum)) | s5_21 == 1 if ageflag == 1
replace end55 = . if missing(daysum) & missing(s5_21)
la val end55 yn
la var end55	"55. Child Under 1 Year Old Received at Least One Dose of Pneumococcal"
drop daysum


// OUTCOME 56: Child Received Rotavirus
// Control/Drone/Total (151/188/339)
egen daysum = rowtotal(s5_5j_day s5_5k_day s5_5l_day) if !missing(s5_5j_day)
gen end56 = (daysum > 0 & !missing(daysum)) | s5_24 == 1 if ageflag == 1
replace end56 = . if missing(daysum) & missing(s5_24)
la val end56 yn
la var end56	"56. Child Under 1 Year Old Received at Least One Dose of Rotavirus"
drop daysum


// OUTCOME 57: Child Received Measles
// Control/Drone/Total (155/187/342)
egen daysum = rowtotal(s5_5m_day s5_5n_day) if !missing(s5_5m_day)
gen end57 = (daysum > 0 & !missing(daysum)) | s5_27 == 1 if ageflag == 1
replace end57 = . if missing(daysum) & missing(s5_27)
la val end57 yn
la var end57	"57. Child Under 1 Year Old Received at Least One Dose of Measles"
drop daysum


// Keep the endline variables
keep respondent treatment end*


// Collapse to get means and counts
//preserve
//collapse (mean) end52x=end52 end53x=end53 end54ax=end54a end54bx=end54b ///
//	end55x=end55 end56x=end56 end57x=end57 ///
//	(count) end52n=end52 end53n=end53 end54an=end54a end54bn=end54b ///
//	 end55n=end55 end56n=end56 end57n=end57
//gen treatment = 3, before(end52x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) end52x=end52 end53x=end53 end54ax=end54a end54bx=end54b ///
//	end55x=end55 end56x=end56 end57x=end57 ///
//	(count) end52n=end52 end53n=end53 end54an=end54a end54bn=end54b ///
//	 end55n=end55 end56n=end56 end57n=end57, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\endline_micro_7_women_child_vaccine.dta", replace

****************************************************************
** WOMEN'S QRE CHILD-LEVEL HEALTH MEASURES **
// Open the Women's data
use "$ip\endline_women_20250310_final.dta", clear

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
// Control/Drone/Total (214/229/443)
recode s6_10 (1 = 1 "Yes") (0 99 = 0 "No"), gen(end58)
la var end58	"58. Among Children with Fever in Last Two Weeks, Pct Who Had Blood Taken"


// OUTCOME 59: Among Children with Fever in Last Two Weeks, Pct Diagnosed with Malaria
// Control/Drone/Total (214/229/443)
recode s6_12 (1 = 1 "Yes") (0 -999 = 0 "No"), gen(end59)
la var end59	"59. Among Children with Fever in Last Two Weeks, Pct Diagnosed with Malaria"


// Keep the endline variables
keep respondent treatment end*


// Collapse to get means and counts
//preserve
//collapse (mean) end58x=end58 end59x=end59 ///
//	(count) end58n=end58 end59n=end59
//gen treatment = 3, before(end58x)
//tempfile tot
//save `tot'
//restore
//collapse (mean) end58x=end58 end59x=end59 ///
//	(count) end58n=end58 end59n=end59, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\endline_micro_8_women_child_health.dta", replace


****************************************************************
** WOMEN'S QRE ZERO DOSE AND UNDER-IMMUNIZED **
// Open the Women's data
use "$ip\endline_women_20250310_final.dta", clear

// Keep only those variables needed for this report
keep respondent treatment District visit_date s5_childage_* name_2_* s5_4_dob_* ///
	born_type_2_* s5_1_* s5_5b_day_* s5_5c_day_* s5_5d_day_* s5_18_* s5_20_*

// Reshape long
reshape long name_2_ s5_4_dob_ born_type_2_ s5_childage_ s5_1_ s5_5b_day_ ///
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
gen childage_d = datediff_frac(s5_4_dob, visit_date, "day")
gen childage_w = childage_d / 7
gen childage_m = datediff_frac(s5_4_dob, visit_date, "month")
gen childage_y = datediff_frac(s5_4_dob, visit_date, "year")
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
gen end78a = s5_5b_day == 0 | s5_18 == 0 if ageflag1 == 1
la val end78a yn
la var end78a	"78a. Zero-Dose Rate Among Children 18 Weeks to Less Than 1 Year Old"

** 78b: Children 12 to 23 Months
gen end78b = s5_5b_day == 0 | s5_18 == 0 if ageflag2 == 1
la val end78b yn
la var end78b	"78b. Zero-Dose Rate Among Children 12 to 23 Months Old"


// OUTCOME 79: Under-Immunized Rate
// Under-immunised children are defined as infants who have not received the 
//  third dose of DTP-containing vaccine (DTP3) by the end of their first 
//  year of life.

** 79a: Children 18 Weeks to Less Than 1 Year
gen vc = s5_5b_day > 0 & s5_5d_day == 0 if !missing(s5_5b_day)
gen vo = s5_18 == 1 & inrange(s5_20, 1, 2) if inlist(s5_18, 0, 1)
gen end79a = vc == 1 | vo == 1 if ageflag1 == 1
la val end79 yn
la var end79a	"79a. Under-Immunized Rate Among Children 18 Weeks to Less Than 1 Year Old"
drop vc vo

** 79b: Children 12 to 23 Months
gen vc = s5_5b_day > 0 & s5_5d_day == 0 if !missing(s5_5b_day)
gen vo = s5_18 == 1 & inrange(s5_20, 1, 2) if inlist(s5_18, 0, 1)
gen end79b = vc == 1 | vo == 1 if ageflag2 == 1
la val end79b yn
la var end79b	"79b. Under-Immunized Rate Among Children 12 to 23 Months Old"
drop vc vo

// Keep the endline variables
keep respondent treatment end*


// Collapse to get means and counts
//preserve
//collapse (mean) end78ax=end78a end78bx=end78b end79ax=end79a ///
//	end79bx=end79b ///
//	(count) end78an=end78a end78bn=end78b end79an=end79a end79bn=end79b
//gen treatment = 3, before(end78ax)
//tempfile tot
//save `tot'
//restore
//collapse (mean) end78ax=end78a end78bx=end78b end79ax=end79a ///
//	end79bx=end79b ///
//	(count) end78an=end78a end78bn=end78b end79an=end79a end79bn=end79b, ///
//	by(treatment)
//append using `tot'
//la def treatment 3 "Total", modify

// Save
save "$op\endline_micro_9_women_child_zerodose_underimmuniz.dta", replace


