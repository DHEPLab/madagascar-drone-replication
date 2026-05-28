
/*
SCRIPT: 		Prep_02_Endline.do
AUTHOR:			Brian Frizzelle & Tara Templin
DATE:			March 28, 2025
MODIFIED:		Takhona Hlatshwako
LAST UPDATED:	May 28, 2026

*/

** FACILITY AUDIT MEASURES **
// Open the Facility Audit data
use "$ip/endline_facility_audit_cleaned_05032025_final.dta", clear

** Set value labels
la def yn 0 "No" 1 "Yes", replace

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



// OUTCOME 6: Out of Stock of Any Contraceptive Method in 3 Months Before Survey
// Control/Drone/Total (47/12/59)
egen end06 = rowmax(s2_21_*)
la var end06 "6. Out of Stock of Any Contraceptive Method in the 3 Months Before Survey"



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


// Save
save "$dp/endline_micro_1_facility.dta", replace


****************************************************************
** WOMEN'S QRE MEASURES **
// Open the Women's data
use "$ip/endline_women_20250310_final.dta", clear

// Set value labels
la def yn 0 "No" 1 "Yes", replace


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



// OUTCOME 40: Currently Using a Modern Contraceptive Method
// Control/Drone/Total (1404/381/1785)
** Set this variable as a No only if the women ONLY reports using 15 (Rhythm 
**  method) or 16 (Withdrawal)
gen end40 = s3_5 != "15" & s3_5 != "16" if !missing(s3_5)
** Recode base40 so that anyone who answered s3_1 is represented
recode end40 (.=0) if !missing(s3_1)
la val end40 yn
la var end40	"40. Currently Using a Modern Contraceptive Method"




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



// OUTCOME 42: Has Unmet Need for Contraception
// Control/Drone/Total (1673/434/2107)
gen end42 = Unmet
la val end42 yn
la var end42	"42. Has Unmet Need for Contraception"


// OUTCOME 43: Obtained Method from Public Facility
// Control/Drone/Total (675/216/891)
recode s3_8 (1 = 1 "Yes") (2 3 -777 = 0 "No"), gen(end43)
la var end43	"43. Obtained Method from Public Facility"



// OUTCOME 44: Obtained Method from Closest Facility to Home
// Control/Drone/Total (735/227/962)
recode s3_14 (1 = 1 "Yes") (0 = 0 "No") (-999=.), gen(end44)
la var end44	"44. Obtained Method from Closest Facility to Home"



// OUTCOME 45: Among Those Not Using, Wishes They Were Using Contraception
// Control/Drone/Total (668/160/828)
gen end45 = s3_2
la val end45 yn
la var end45	"45. Among Those Not Using, Wishes They Were Using Contraception"



// OUTCOME 46: Received MII+
// Control/Drone/Total (736/221/957)
gen end46 = s3b_2 == 1 & s3b_3 == 1 & s3b_4 == 1 & s3b_5 == 1
recode end46 (0=.) if missing(s3b_2)
la val end46 yn
la var end46	"46. Received MII+"


// OUTCOME 47: FP User Would Refer a Friend to the Facility
// Control/Drone/Total (736/221/957)
gen end47 = s3b_7
la val end47 yn
la var end47	"47. FP User Would Refer a Friend to the Facility"


// OUTCOME 48: Made an Informal Payment
// Control/Drone/Total (539/160/699)
** Only include women who went to a public facility
recode s3b_8 (.f=0)
gen end48 = s3b_8 > 0 & !missing(s3b_8) if s3_8 == 1
la val end48 yn
la var end48	"48. Made an Informal Payment"


** OUTCOME 49: There is Another Method They Would Prefer to Use
// Control/Drone/Total (736/221/957)
gen end49 = s3b_16
la val end49 yn
la var end49	"49. There is Another Method They Would Prefer to Use"



** OUTCOME 50: Among Users, Felt Had Enough Information to Make a Good Decision
// Control/Drone/Total (736/221/957)
gen end50 = s3b_22
la val end50 yn
la var end50	"50. Among Users, Felt Had Enough Information to Make a Good Decision"


** OUTCOME 51: Among Users, Felt They Could Not Say No to Using
// Control/Drone/Total (736/221/957)
recode s3b_25 (1=0 "No") (0=1 "Yes"), gen(end51)
la var end51	"51. Among Users, Felt They Could Not Say No to Using"


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



// OUTCOME 75: Those Very Confident the Closest Facility Has a Reliable Supply of FP
// Control/Drone/Total (1051/230/1281)
recode s11_17 (1=1 "Yes") (2/4=0 "No") if s11_8 == 1, gen(end75)
la var end75	"75. Those Very Confident the Closest Facility Has a Reliable Supply of FP"


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
keep respondent treatment end* agecat attend s1_17 s1_18 s1_19 married s7_3 s2_1 pregcat lbcat lccat s3_5_current


// Save
save "$dp/endline_micro_6_women.dta", replace


****************************************************************
****************************************************************
** WOMEN'S QRE CHILD-LEVEL HEALTH MEASURES **
// Open the Women's data
use "$ip/endline_women_20250310_final.dta", clear

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
// Control/Drone/Total (214/229/443)
recode s6_10 (1 = 1 "Yes") (0 99 = 0 "No"), gen(end58)
la var end58	"58. Among Children with Fever in Last Two Weeks, Pct Who Had Blood Taken"


// OUTCOME 59: Among Children with Fever in Last Two Weeks, Pct Diagnosed with Malaria
// Control/Drone/Total (214/229/443)
recode s6_12 (1 = 1 "Yes") (0 -999 = 0 "No"), gen(end59)
la var end59	"59. Among Children with Fever in Last Two Weeks, Pct Diagnosed with Malaria"


// Keep the endline variables
keep facility_id respondent treatment end*


// Save
save "$dp/endline_micro_8_women_child_health.dta", replace
