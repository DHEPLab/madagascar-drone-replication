/*
SCRIPT: 		Prep_01_Baseline.do
AUTHOR:			Brian Frizzelle & Tara Templin
MODIFIED:       Takhona Hlatshwako
DATE:			March 24, 2025
LAST UPDATED:	May 28, 2026
*/


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


// OUTCOME 6: Out of Stock of Any Contraceptive Method in 3 Months Before Survey
// Control/Drone/Total (51/13/64)
egen base06 = rowmax(s2_21_*)
la var base06 	"6. Out of Stock of Any Contraceptive Method in the 3 Months Before Survey"


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

// Save
save "$dp/baseline_micro_1_facility.dta", replace


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



// OUTCOME 42: Has Unmet Need for Contraception
// Control/Drone/Total (594/154/748)
gen base42 = Unmet
la val base42 yn
la var base42	"42. Has Unmet Need for Contraception"
** Drop measures from Drone facilities outside of Mahanoro



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


// Keep the baseline variables
keep respondent treatment base* agecat attend s1_17 s1_18 s1_19 married s7_3 s2_1 pregcat lbcat lccat s3_5_current 


// Save
save "$dp/baseline_micro_6_women.dta", replace

****************************************************************

****************************************************************
** WOMEN'S QRE CHILD-LEVEL HEALTH MEASURES **
// Open the Women's data
use "$ip/women_cleaned_20240607_working.dta", clear

// Merge on Drone flights and districts
drop treatment
merge m:1 facility_id using "$dp/baseline_drone_treatment_district.dta", ///
	keepusing(District treatment facility_id)
drop _merge

// Keep only those variables needed for this report
keep facility_id respondent treatment s6_10_* s6_12_*

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
keep facility_id respondent treatment base*


// Save
save "$dp/baseline_micro_8_women_child_health.dta", replace
