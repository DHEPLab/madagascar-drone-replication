capture program drop run_analysis
program define run_analysis
    syntax, basefile(string) endfile(string) idvar(string) outfile(string)

    use "`basefile'", clear
    gen endline = 0
    append using "`endfile'"
    replace endline = 1 if missing(endline)
	
    ds base*
    local basevars `r(varlist)'

    foreach var of local basevars {
        local id = subinstr("`var'", "base", "", .)  
        gen outcome`id' = cond(endline==0, base`id', end`id')
        local varlabel : variable label `var'
        label var outcome`id' "`varlabel'"
    }

   capture confirm string variable `idvar'
    if !_rc {
        display "`idvar' is a string, encoding..."
        encode `idvar', gen(id_numeric)
        xtset id_numeric endline
        local cluster_var id_numeric
    }
    else {
        xtset `idvar' endline
        local cluster_var `idvar'
    }

    tempname results
    postfile `results' str200 Outcome str8 Model Effect_Size Standard_Error P_value Observations ///
    Baseline_Control_Mean Magnitude_Percent using "`outfile'.dta", replace


    foreach var of varlist outcome* {
		** DID with fixed effects
        quietly xtreg `var' i.treatment##i.endline i.s0_employee i.nprv i.npre i.s1_02 i.s1_03 i.s1_04 i.s1_07 i.s1_08 i.s1_09 i.s1_11 i.s1_12 i.s1_13 i.s1_15, fe vce(cluster `idvar')
        local coef = _b[1.treatment#1.endline]
        local se = _se[1.treatment#1.endline]
        local df = e(df_r)
        local t_stat = `coef'/`se'
        local p = 2*ttail(`df', abs(`t_stat'))
        local N = e(N)
        local OutcomeLabel : variable label `var'
		quietly summarize `var' if endline==0 & treatment==0, meanonly
        local baseline_mean = r(mean)
		local magnitude_pct = (`coef' / `baseline_mean') * 100
        post `results' ("`OutcomeLabel'") ("DID") (`coef') (`se') (`p') (`N') (`baseline_mean') (`magnitude_pct')
		
    }
    postclose `results'

    preserve
		use "`outfile'.dta", clear
		export delimited using "`outfile'.csv", replace
	restore
end


capture program drop did_analysis_no_fe
program define did_analysis_no_fe
    syntax, basefile(string) endfile(string) idvar(string) outfile(string)

    use "`basefile'", clear
    gen endline = 0
    append using "`endfile'"
    replace endline = 1 if missing(endline)

    ds base*
    local basevars `r(varlist)'

    foreach var of local basevars {
        local id = subinstr("`var'", "base", "", .)  
        gen outcome`id' = cond(endline==0, base`id', end`id')
        local varlabel : variable label `var'
        label var outcome`id' "`varlabel'"
    }
	local cluster_var `idvar'
   capture confirm string variable `idvar'
    if !_rc {
        display "`idvar' is a string, encoding..."
        encode `idvar', gen(id_numeric)
        local cluster_var id_numeric
    }
    tempname results
    postfile `results' str200 Outcome str8 Model Effect_Size Standard_Error P_value Observations ///
    Baseline_Control_Mean Magnitude_Percent using "`outfile'.dta", replace


    foreach var of varlist outcome* {
		** DID with no fixed effects
        quietly reg `var' i.treatment##i.endline i.s0_employee i.nprv i.npre i.s1_02 i.s1_03 i.s1_04 i.s1_07 i.s1_08 i.s1_09 i.s1_11 i.s1_12 i.s1_13 i.s1_15, vce(cluster `cluster_var')
        local coef = _b[1.treatment#1.endline]
        local se = _se[1.treatment#1.endline]
        local df = e(df_r)
        local t_stat = `coef'/`se'
        local p = 2*ttail(`df', abs(`t_stat'))
        local N = e(N)
        local OutcomeLabel : variable label `var'
		quietly summarize `var' if endline==0 & treatment==0, meanonly
        local baseline_mean = r(mean)
		local magnitude_pct = (`coef' / `baseline_mean') * 100
        post `results' ("`OutcomeLabel'") ("DID") (`coef') (`se') (`p') (`N') (`baseline_mean') (`magnitude_pct')
		
    }
    postclose `results'

    preserve
		use "`outfile'.dta", clear
		export delimited using "`outfile'.csv", replace
	restore
end



capture program drop ancova_analysis
program define ancova_analysis
    syntax, basefile(string) endfile(string) idvar(string) outfile(string)

    use "`basefile'", clear
    merge 1:1 `idvar' using "`endfile'"
	display "merged successfully"
	
   capture confirm string variable `idvar'
    if !_rc {
        display "`idvar' is a string, encoding..."
        encode `idvar', gen(id_numeric)
    }
  
    tempname results
    postfile `results' str200 Outcome str8 Model Effect_Size Standard_Error P_value Observations ///
    Baseline_Control_Mean Magnitude_Percent using "`outfile'.dta", replace

	ds base*
    local basevars `r(varlist)'

    foreach b of local basevars {
		di "basevar is `b'"
        local suf = subinstr("`b'","base","",.)
        local evar = "end`suf'"
		di "endvar is `evar'"

        reg `evar' treatment `b' i.s0_employee i.nprv i.npre i.s1_02 i.s1_03 i.s1_04 i.s1_07 i.s1_08 i.s1_09 i.s1_11 i.s1_12 i.s1_13 i.s1_15, vce(cluster `idvar')
        local coef = _b[treatment]
        local se   = _se[treatment]
        local p    = 2*ttail(e(df_r), abs(`coef'/`se'))
        local N    = e(N)
        local OutcomeLabel : variable label `evar'
		quietly summarize `b' if treatment==0, meanonly
        local baseline_mean = r(mean)
		local magnitude_pct = (`coef' / `baseline_mean') * 100
        post `results' ("`OutcomeLabel'") ("ANCOVA") (`coef') (`se') (`p') (`N') (`baseline_mean') (`magnitude_pct')
		
    }
    postclose `results'

    preserve
		use "`outfile'.dta", clear
		export delimited using "`outfile'.csv", replace
	restore
end


global od = "/Users/takhona/Desktop/Summer 2025/Drone analysis"


/*
SCRIPT: 		Madagascar_Mar2025_Report_Prep_04_Construct_Outcome_Tables.do
AUTHOR:			Brian Frizzelle
DATE:			March 28, 2025
LAST UPDATED:	April 3, 2025

This script combines the baseline and endline datasets from the previous two
scripts, calculates the percent change for each of the outcomes, and exports
the tables needed for the PSI report for Kat.

*/

// Set paths
global ip = "$od/Data"
global op = "$od/Results"


** **********************************************************************************
// Micro 1 Facilities dtas
** **********************************************************************************

run_analysis, basefile("$ip/baseline_micro_1_facility-drop.dta") ///
              endfile("$ip/endline_micro_1_facility.dta") ///
              idvar("facility_id") ///
              outfile("$op/regression_results_1")
did_analysis_no_fe, basefile("$ip/baseline_micro_1_facility-drop.dta") ///
              endfile("$ip/endline_micro_1_facility.dta") ///
              idvar("facility_id") ///
              outfile("$op/regression_results_1_did")
ancova_analysis, basefile("$ip/baseline_micro_1_facility-drop.dta") ///
              endfile("$ip/endline_micro_1_facility.dta") ///
              idvar("facility_id") ///
              outfile("$op/regression_results_1_ancova")
			  
** **********************************************************************************
// Micro 2 CHWs dtas
** **********************************************************************************

run_analysis, basefile("$ip\baseline_micro_2_chw.dta") ///
              endfile("$ip\endline_micro_2_chw.dta") ///
              idvar("chw_id") ///
              outfile("$op\regression_results_2.dta")

** **********************************************************************************
// Micro 3 UAVs dtas
** **********************************************************************************
*** REPEATED TIME
run_analysis, basefile("$ip\baseline_micro_3_uav.dta") ///
              endfile("$ip\endline_micro_3_uav.dta") ///
              idvar("provider_id") ///
              outfile("$op\regression_results_3")
			  
			  
** **********************************************************************************
// Micro 4 provider dtas
** **********************************************************************************

run_analysis, basefile("$ip\baseline_micro_4_provider.dta") ///
              endfile("$ip\endline_micro_4_provider.dta") ///
              idvar("provider_id") ///
              outfile("$op\regression_results_4")	  

** **********************************************************************************
// Micro 5 CEI dtas
** **********************************************************************************

run_analysis, basefile("$ip\baseline_micro_5_cei.dta") ///
              endfile("$ip\endline_micro_5_cei.dta") ///
              idvar("cei_id") ///
              outfile("$op\regression_results_5")	

** **********************************************************************************
// Micro 6 Women dtas
** *********************************************************************************

run_analysis, basefile("$ip\baseline_micro_6_women.dta") ///
              endfile("$ip\endline_micro_6_women.dta") ///
              idvar("respondent") ///
              outfile("$op\regression_results_6")	

** **********************************************************************************
// Micro 7 Child Vaccine dtas
** *********************************************************************************
**** REPEATED TIME
run_analysis, basefile("$ip\baseline_micro_7_women_child_vaccine.dta") ///
              endfile("$ip\endline_micro_7_women_child_vaccine.dta") ///
              idvar("respondent") ///
              outfile("$op\regression_results_7")	

** **********************************************************************************
// Micro 8 Child Health dtas
** *********************************************************************************
**** REPEATED TIME
run_analysis, basefile("$ip\baseline_micro_8_women_child_health.dta") ///
              endfile("$ip\endline_micro_8_women_child_health.dta") ///
              idvar("respondent") ///
              outfile("$op\regression_results_8")	

** **********************************************************************************
// Micro 9 Zero doses dtas
** *********************************************************************************
**** REPEATED TIME
run_analysis, basefile("$ip\baseline_micro_9_women_child_zerodose_underimmuniz.dta") ///
              endfile("$ip\endline_micro_9_women_child_zerodose_underimmuniz.dta") ///
              idvar("respondent") ///
              outfile("$op\regression_results_9")	

			  


// Calculate percent change for all measures as HIGHER is BETTER
// foreach i in 01 01a 01b 01c 01d 01e 01f 01g 01h 01i 01j 01k 02 03 04 05 05a ///
foreach i in 01 01d 01e 01f 01g 01h 01i 01j 01k 02 03 04 05 05a ///
	05b 05c 05d 05e 06 07 08 09 10 11 11a 11b 11c 11d 12 13 14 15 16 17 18 ///
	19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37a 37b 37c 37d ///
	37e 37f 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54a 54b 55 56 57 ///
	58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 78a 78b 79a 79b {
	gen pct`i' = (end`i'x - base`i'x) / base`i'x
}

// Reorder
// foreach k in 01 01a 01b 01c 01d 01e 01f 01g 01h 01i 01j 01k 02 03 04 05 05a ///
foreach k in 01 01d 01e 01f 01g 01h 01i 01j 01k 02 03 04 05 05a ///
	05b 05c 05d 05e 06 07 08 09 10 11 11a 11b 11c 11d 12 13 14 15 16 17 18 ///
	19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37a 37b 37c 37d ///
	37e 37f 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54a 54b 55 56 57 ///
	58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 78a 78b 79a 79b {
	order base`k'n base`k'x end`k'n end`k'x pct`k', last
}
order end77n end77x, after(pct76)

// Save as a temp file
save "$ip\baseline_endline_merged_pct_calculated.dta", replace

******************************************************************************

// Reorganize the baseline and endline means and counts, export to an Excel file
// MEANS
use "$ip\baseline_endline_merged_pct_calculated.dta", clear
keep treatment *x
** Transpose
xpose, clear varname
rename v1 Cntrl_
rename v2 Drone_
rename v3 Total_
rename _varname varname
order varname, first
drop if _n == 1
gen stage = 1 if ustrregexm(varname, "base")
replace stage = 2 if ustrregexm(varname, "end")
replace varname = subinstr(varname, "x", "", .)
replace varname = subinstr(varname, "base", "outcome", .)
replace varname = subinstr(varname, "end", "outcome", .)
replace varname = trim(varname)
** Reshape wide
reshape wide Cntrl_ Drone_ Total_, i(varname) j(stage)
** Rename
renvars *_1 *_2, postf(x)
** Label
merge 1:1 varname using "$ip\excel_labeling.dta"
keep if _merge == 3
drop _merge varname
order label, first
rename label outcome
** Tempfile
tempfile means
save `means'

// COUNTS
use "$ip\baseline_endline_merged_pct_calculated.dta", clear
keep treatment *n
** Transpose
xpose, clear varname
rename v1 Cntrl_
rename v2 Drone_
rename v3 Total_
rename _varname varname
order varname, first
drop if _n == 1
gen stage = 1 if ustrregexm(varname, "base")
replace stage = 2 if ustrregexm(varname, "end")
replace varname = ustrregexra(varname, "n$", "", .)
replace varname = subinstr(varname, "base", "outcome", .)
replace varname = subinstr(varname, "end", "outcome", .)
** Reshape wide
reshape wide Cntrl_ Drone_ Total_, i(varname) j(stage)
** Rename
renvars *_1 *_2, postf(n)
** Label
merge 1:1 varname using "$ip\excel_labeling.dta"
keep if _merge == 3
drop _merge varname
order label, first
rename label outcome
** Tempfile
tempfile ns
save `ns'

// Combine them together
use `ns', clear
merge 1:1 outcome using `means'
drop _merge
** Reorder
order Drone_1n Drone_1x Drone_2n Drone_2x Cntrl_1n Cntrl_1x Cntrl_2n Cntrl_2x ///
	Total_1n Total_1x Total_2n Total_2x, last
** Sort
sort order
drop order

// Export to Excel
export excel "$op\mad_mar2025_report_outputs_unformatted_20250403_v3.xlsx", ///
	first(varl) sheet("Baseline & Endline Outcomes") cell(A3) replace

// Use putexcel to format the Excel file
putexcel set "$op\mad_mar2025_report_outputs_unformatted_20250403_v3.xlsx", ///
	sheet("Baseline & Endline Outcomes") modify
** Add in Treatments in Row 1
putexcel B1 = "Drone"
putexcel F1 = "Control"
putexcel J1 = "Total"
** Add in Baseline and Endline in Row 2
foreach c in B F J {
	putexcel `c'2 = "Baseline"
}
foreach c in D H L {
	putexcel `c'2 = "Endline"
}
** Replace values in Row 3 with just Mean and Std. Dev
foreach c in B D F H J L {
	putexcel `c'3 = "n", italic
}
foreach c in C E G I K M {
	putexcel `c'3 = "Mean", nformat(percent)
}

******************************************************************************

// Reorganize the baseline and endline percent change to export to an Excel file
use "$ip\baseline_endline_merged_pct_calculated.dta", clear
keep treatment pct*
** Transpose
xpose, clear varname
rename v1 Cntrl
rename v2 Drone
rename v3 Total
rename _varname varname
order varname Drone, first
drop if _n == 1
replace varname = subinstr(varname, "pct", "outcome", .)
** Label
la var varname 	"Outcomes"
la var Drone 	"Drone Percent Change"
la var Cntrl 	"Control Percent Change"
la var Tot 		"Total Percent Change"
** Label rows
merge 1:1 varname using "$ip\excel_labeling.dta"
keep if _merge == 3
drop _merge varname
order label, first
rename label outcome
** Sort
sort order
drop order

// Export to Excel
export excel "$op\mad_mar2025_report_outputs_unformatted_20250403_v3.xlsx", ///
	first(varl) sheet("Pct Change Baseline to Endline")

// Use putexcel to format the Excel file
putexcel set "$op\mad_mar2025_report_outputs_unformatted_20250403_v3.xlsx", ///
	sheet("Pct Change Baseline to Endline") modify
** Add in Treatments in Row 1
putexcel B1 = "Drone"
putexcel C1 = "Control"
putexcel D1 = "Total"
** Format cells as percentages
putexcel B2:E99, nformat(percent)
