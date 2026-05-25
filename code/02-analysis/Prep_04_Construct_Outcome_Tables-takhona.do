capture program drop did_analysis_no_fe
program define did_analysis_no_fe
    syntax, basefile(string) endfile(string) idvar(string) outfile(string)

    use "`basefile'", clear
    gen endline = 0
    append using "`endfile'"
    replace endline = 1 if missing(endline)
	cap drop _m
	cap merge m:1 respondent using "$repo/data/raw/respondent_info.dta", nogen force
	merge m:1 facility_id using "$repo/data/raw/district_info.dta", nogen force
    ds base*
    local basevars `r(varlist)'

	foreach var of local basevars {
        local id = subinstr("`var'", "base", "", .)  
        
        * Check if the endline variable actually exists before generating the outcome
        capture confirm variable end`id'
        if !_rc {
            gen outcome`id' = cond(endline==0, `var', end`id')
            local varlabel : variable label `var'
            label var outcome`id' "`varlabel'"
        }
        else {
            display as text "Note: end`id' not found in endline data. Skipping outcome generation for `var'."
        }
    }
	local cluster_var `idvar'
    capture confirm string variable `idvar'
    if !_rc {
        display "`idvar' is a string, encoding..."
        encode `idvar', gen(id_numeric)
        local cluster_var id_numeric
    }
	egen strata = group(district_id facility_type)
    tempname results
    postfile `results' str200 Outcome str8 Model Effect_Size Standard_Error P_value Observations ///
    Baseline_Control_Mean Magnitude_Percent using "`outfile'.dta", replace


    foreach var of varlist outcome* {
		** DID with no fixed effects
        reg `var' i.treatment##i.endline i.strata, vce(cluster facility_id)
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
	cap drop _m
	cap merge 1:1 respondent using "$repo/data/raw/respondent_info.dta", nogen force
	merge m:1 facility_id using "$repo/data/raw/district_info.dta", nogen force
	egen strata = group(district_id facility_type)
	ds base* 
	local basevars `r(varlist)'
	collapse (mean) `basevars', by(facility_id strata treatment)
	rename base* basebar*
	duplicates drop facility_id, force 
	tempfile basebar 
	save `basebar', replace 
	use "`endfile'", clear
	cap drop _m
	cap merge 1:1 respondent using "$repo/data/raw/respondent_info.dta", nogen force
	merge m:1 facility_id using `basebar'
	display "merged successfully"
	
   capture confirm string variable `idvar'
    if !_rc {
        display "`idvar' is a string, encoding..."
        encode `idvar', gen(id_numeric)
    }
  
    tempname results
    postfile `results' str200 Outcome str8 Model Effect_Size Standard_Error P_value Observations ///
    Baseline_Control_Mean Magnitude_Percent using "`outfile'.dta", replace

	ds basebar*
    local basevars `r(varlist)'

    foreach b of local basevars {
		di "basevar is `b'"
        local suf = subinstr("`b'","basebar","",.)
        local evar = "end`suf'"
		capture confirm variable `evar'
        if !_rc {
            di "Running ANCOVA for `evar'..."

        reg `evar' treatment `b' i.strata, vce(cluster facility_id)
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
	else {
             display as text "Note: `evar' not found. Skipping ANCOVA for `b'."
        }
    }
	
    postclose `results'

    preserve
		use "`outfile'.dta", clear
		export delimited using "`outfile'.csv", replace
	restore
end


global od = "$repo"


/*
SCRIPT: 		Madagascar_Mar2025_Report_Prep_04_Construct_Outcome_Tables.do
AUTHOR:			Brian Frizzelle
MODIFIED: 		Takhona Hlatshwako
DATE:			March 28, 2025
LAST UPDATED:	May 24, 2026


*/

** **********************************************************************************
// Micro 1 Facilities dtas
** **********************************************************************************

did_analysis_no_fe, basefile("$dp/baseline_micro_1_facility.dta") ///
              endfile("$dp/endline_micro_1_facility.dta") ///
              idvar("facility_id") ///
              outfile("$op/regression_results_1_did")
ancova_analysis, basefile("$dp/baseline_micro_1_facility.dta") ///
              endfile("$dp/endline_micro_1_facility.dta") ///
              idvar("facility_id") ///
              outfile("$op/regression_results_1_ancova")
 

			  
** **********************************************************************************
// Micro 6 Women dtas
** *********************************************************************************

did_analysis_no_fe, basefile("$dp/baseline_micro_6_women.dta") ///
              endfile("$dp/endline_micro_6_women.dta") ///
              idvar("respondent") ///
              outfile("$op/regression_results_6_did")	
ancova_analysis, basefile("$dp/baseline_micro_6_women.dta") ///
              endfile("$dp/endline_micro_6_women.dta") ///
              idvar("respondent") ///
              outfile("$op/regression_results_6_ancova")
			  
			  
**********************************************************************************
// Micro 8 Child Health dtas
** *********************************************************************************
**** REPEATED TIME
did_analysis_no_fe, basefile("$dp/baseline_micro_8_women_child_health.dta") ///
              endfile("$dp/endline_micro_8_women_child_health.dta") ///
              idvar("respondent") ///
              outfile("$op/regression_results_8_did")	

ancova_analysis, basefile("$dp/baseline_micro_8_women_child_health.dta") ///
              endfile("$dp/endline_micro_8_women_child_health.dta") ///
              idvar("respondent") ///
              outfile("$op/regression_results_8_ancova")	

** 
			  
			  

