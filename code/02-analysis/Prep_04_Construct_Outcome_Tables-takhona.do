// ============================================================
// Build crosswalk from baseline facility audit
// ============================================================
capture program drop make_crosswalk
program define make_crosswalk
    syntax, datadir(string) outfile(string)

    use "$ip/drone-med_baseline_facility_audit_public.dta", clear
    keep facility_id facility_type region district treatment
    rename region   region_id
    rename district district_id

    gen commune_id   = floor(mod(facility_id, 100000) / 1000)
    gen fokontany_id = mod(facility_id, 1000)

    duplicates drop facility_id, force
    isid facility_id
    isid fokontany_id

    save "`outfile'", replace
end


// ============================================================
// Add facility identifiers to women/child data
// ============================================================
capture program drop add_women_ids
program define add_women_ids
    syntax, crosswalk(string)

    capture confirm variable facility_id
    if _rc {
        ** facility_id absent: recover from hhid via fokontany_id
        gen fokontany_id = floor(hhid / 1000)
        merge m:1 fokontany_id using "`crosswalk'", ///
            keepusing(facility_id facility_type district_id) nogen
    }
    else {
        ** facility_id present: merge in facility_type and district_id only
        merge m:1 facility_id using "`crosswalk'", ///
            keepusing(facility_type district_id) nogen update replace
    }

    ** Normalize facility_type: women files use 'type'
    capture confirm variable facility_type
    if _rc {
        capture rename type facility_type
        if _rc {
            display as error "Neither facility_type nor type found after crosswalk merge."
            exit 111
        }
    }
end


// ============================================================
// Shared normalization program
// Call after use/append to standardize variable names
// ============================================================
capture program drop normalize_ids
program define normalize_ids

    ** Normalize district variable name
    capture confirm variable district_id
    if _rc {
        capture rename district district_id
        if _rc {
            display as error "Neither district_id nor district found in data."
            exit 111
        }
    }

    ** Normalize facility_type variable name
    ** (women files use 'type' instead of 'facility_type')
    capture confirm variable facility_type
    if _rc {
        capture rename type facility_type
        if _rc {
            display as error "Neither facility_type nor type found in data."
            exit 111
        }
    }

end


// ============================================================
// ANALYSIS: Difference-in-Differences
// ============================================================
capture program drop did_analysis_no_fe
program define did_analysis_no_fe
    syntax, basefile(string) endfile(string) outfile(string) ///
        [idvar(string) crosswalk(string)]

    ** --- Load and prep baseline ---
    use "`basefile'", clear
    if "`crosswalk'" != "" {
        add_women_ids, crosswalk("`crosswalk'")
    }
    normalize_ids
    gen endline = 0
    tempfile base_prepped
    save `base_prepped', replace

    ** --- Load and prep endline, then append baseline ---
    ** Separating load/prep before append ensures add_women_ids
    ** and normalize_ids act on each wave independently,
    ** which is required when endline lacks facility_id
    use "`endfile'", clear
    if "`crosswalk'" != "" {
        add_women_ids, crosswalk("`crosswalk'")
    }
    normalize_ids
    gen endline = 1
    append using `base_prepped'

    ds base*
    local basevars `r(varlist)'

    foreach var of local basevars {
        local id = subinstr("`var'", "base", "", .)
        capture confirm variable end`id'
        if !_rc {
            gen outcome`id' = cond(endline==0, `var', end`id')
            local varlabel : variable label `var'
            label var outcome`id' "`varlabel'"
        }
        else {
            display as text "Note: end`id' not found. Skipping outcome`id'."
        }
    }

    egen strata = group(district_id facility_type)

    tempname results
    postfile `results' str200 Outcome str8 Model Effect_Size Standard_Error ///
        P_value Observations Baseline_Control_Mean Magnitude_Percent ///
        using "`outfile'.dta", replace

    foreach var of varlist outcome* {
        capture reg `var' i.treatment##i.endline i.strata, vce(cluster facility_id)
        if _rc {
            display as text "Note: regression failed for `var'. Skipping."
            continue
        }
        capture local coef = _b[1.treatment#1.endline]
        if _rc {
            display as text "Note: 1.treatment#1.endline dropped for `var'. Skipping."
            continue
        }
        local se     = _se[1.treatment#1.endline]
        local df     = e(df_r)
        local t_stat = `coef' / `se'
        local p      = 2 * ttail(`df', abs(`t_stat'))
        local N      = e(N)
        local OutcomeLabel : variable label `var'
        quietly summarize `var' if endline==0 & treatment==0, meanonly
        local baseline_mean = r(mean)
        local magnitude_pct = (`coef' / `baseline_mean') * 100
        post `results' ("`OutcomeLabel'") ("DID") (`coef') (`se') (`p') ///
            (`N') (`baseline_mean') (`magnitude_pct')
    }

    postclose `results'

    preserve
        use "`outfile'.dta", clear
        export delimited using "`outfile'.csv", replace
    restore
end


// ============================================================
// ANALYSIS: ANCOVA
// ============================================================
capture program drop ancova_analysis
program define ancova_analysis
    syntax, basefile(string) endfile(string) outfile(string) [crosswalk(string)]

    ** --- Build facility-level baseline means ---
    use "`basefile'", clear
    if "`crosswalk'" != "" {
        add_women_ids, crosswalk("`crosswalk'")
    }
    normalize_ids
    egen strata = group(district_id facility_type)
    ds base*
    local basevars `r(varlist)'
    collapse (mean) `basevars', by(facility_id strata treatment)
    rename base* basebar*
    duplicates drop facility_id, force
    tempfile basebar
    save `basebar', replace

    ** --- Load endline and merge facility-level baseline means ---
    use "`endfile'", clear
    if "`crosswalk'" != "" {
        add_women_ids, crosswalk("`crosswalk'")
    }
    normalize_ids
    merge m:1 facility_id using `basebar', nogen
    display "merged successfully"

    tempname results
    postfile `results' str200 Outcome str8 Model Effect_Size Standard_Error ///
        P_value Observations Baseline_Control_Mean Magnitude_Percent ///
        using "`outfile'.dta", replace

    ds basebar*
    local basevars `r(varlist)'

    foreach b of local basevars {
        di "basevar is `b'"
        local suf  = subinstr("`b'", "basebar", "", .)
        local evar = "end`suf'"
        capture confirm variable `evar'
        if !_rc {
            di "Running ANCOVA for `evar'..."
            capture reg `evar' treatment `b' i.strata, vce(cluster facility_id)
            if _rc {
                display as text "Note: regression failed for `evar'. Skipping."
                continue
            }
            capture local coef = _b[treatment]
            if _rc {
                display as text "Note: treatment coefficient dropped for `evar'. Skipping."
                continue
            }
            local se   = _se[treatment]
            local p    = 2 * ttail(e(df_r), abs(`coef' / `se'))
            local N    = e(N)
            local OutcomeLabel : variable label `evar'
            quietly summarize `b' if treatment==0, meanonly
            local baseline_mean = r(mean)
            local magnitude_pct = (`coef' / `baseline_mean') * 100
            post `results' ("`OutcomeLabel'") ("ANCOVA") (`coef') (`se') (`p') ///
                (`N') (`baseline_mean') (`magnitude_pct')
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
LAST UPDATED:	June 17, 2026


*/

** First build the crosswalk (once, before analysis calls)
make_crosswalk, datadir("$ip") outfile("$dp/crosswalk.dta")

** **********************************************************************************
// Micro 1 Facilities dtas
** **********************************************************************************

did_analysis_no_fe, basefile("$dp/baseline_micro_1_facility.dta") ///
              endfile("$dp/endline_micro_1_facility.dta") ///
              outfile("$op/regression_results_1_did")
ancova_analysis, basefile("$dp/baseline_micro_1_facility.dta") ///
              endfile("$dp/endline_micro_1_facility.dta") ///
              outfile("$op/regression_results_1_ancova")
 

			  
** **********************************************************************************
// Micro 6 Women dtas
** *********************************************************************************

			  
did_analysis_no_fe, basefile("$dp/baseline_micro_6_women.dta")  ///
    endfile("$dp/endline_micro_6_women.dta")                     ///
    outfile("$op/regression_results_6_did")                      ///
    crosswalk("$dp/crosswalk.dta")

ancova_analysis,   basefile("$dp/baseline_micro_6_women.dta")   ///
    endfile("$dp/endline_micro_6_women.dta")                     ///
    outfile("$op/regression_results_6_ancova")                   ///
    crosswalk("$dp/crosswalk.dta")
			  
			  
**********************************************************************************
// Micro 8 Child Health dtas
** *********************************************************************************
**** REPEATED TIME
did_analysis_no_fe, basefile("$dp/baseline_micro_8_women_child_health.dta") ///
              endfile("$dp/endline_micro_8_women_child_health.dta") ///
              outfile("$op/regression_results_8_did")				///
				crosswalk("$dp/crosswalk.dta")

ancova_analysis, basefile("$dp/baseline_micro_8_women_child_health.dta") ///
              endfile("$dp/endline_micro_8_women_child_health.dta") ///
              outfile("$op/regression_results_8_ancova")			///
				crosswalk("$dp/crosswalk.dta")

** 
			  
			  

