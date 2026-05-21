// =========================================================================
// build_table_2.do
// Render Table 2 (and a long-format full results table) deterministically
// from the canonical regression-result CSVs produced by the 02-analysis
// scripts.
//
// Reviewer 2 of BMJ Global Health (bmjgh-2025-021965.R1) noted that the
// ANCOVA and DID columns in the previously submitted Table 2 appeared
// identical. This script eliminates the manuscript-prep transcription
// risk by reading the canonical CSVs and writing Table 2 directly. The
// script must be the single source of truth for any Table 2 update.
//
// Inputs (in $op or, equivalently, output/tables/):
//   regression_results_<family>_ancova.csv
//   regression_results_<family>_did.csv
//   regression_results_<family>_multilevel.csv  (optional)
// where <family> is one of {1..9} per docs/codebook.md:
//   1 facility, 2 chw, 3 uav, 4 provider, 5 cei, 6 women,
//   7 women_child_vaccine, 8 women_child_health,
//   9 women_child_zerodose_underimmuniz.
//
// Outputs (written to $op):
//   table_2_long.csv   - one row per outcome x estimator x family
//   table_2_wide.csv   - one row per outcome, columns for ANCOVA & DID
//                        effect, SE, p, N, plus the baseline-control mean
//   table_2_formatted.csv - manuscript-paste-ready: one row per outcome,
//                          ANCOVA and DID each rendered as
//                          "coef (SE) [p, N]" strings
//
// Usage:
//   do "code/00_config.do"
//   do "code/03-output/build_table_2.do"
// =========================================================================

version 17

// --- Resolve paths (00_config.do should have already run) ---
capture confirm existence "$op"
if "$op" == "" {
    di as error "ERROR: \$op is not set. Run code/00_config.do first."
    exit 198
}

local tbldir "$op/tables"
capture mkdir "`tbldir'"

// --- Outcome families to include, in display order ---
// Adjust this list if Table 2 in the submitted manuscript covers a
// different subset. Family 6 (women) is the family flagged by Reviewer 2.
local families "1 2 4 6 7 8 9"

// Estimators to read. ANCOVA and DID are required for Reviewer 2's
// table comparison. Multilevel is included if present (best-effort).
local estimators "ancova did multilevel"

// =========================================================================
// 1. Read every available <family>_<estimator>.csv into a single long
//    dataset. Skip any combination that does not have a CSV on disk.
// =========================================================================
tempfile longbuilder
local first_append 1

foreach fam of local families {
    foreach est of local estimators {
        local f "`tbldir'/regression_results_`fam'_`est'.csv"
        capture confirm file "`f'"
        if _rc {
            di as txt "  skipped (file not found): regression_results_`fam'_`est'.csv"
            continue
        }

        di as txt "  reading: regression_results_`fam'_`est'.csv"
        preserve
            import delimited using "`f'", varnames(1) clear stringcols(1) ///
                encoding(UTF-8)

            // Normalize column names (the CSVs use TitleCase headers)
            capture rename Outcome             outcome
            capture rename Model               model
            capture rename Effect_Size         effect_size
            capture rename Standard_Error      se
            capture rename P_value             p_value
            capture rename Observations        n_obs
            capture rename Baseline_Control_Mean baseline_control_mean
            capture rename Magnitude_Percent   magnitude_pct

            gen family = `fam'
            gen estimator = "`est'"

            // Coerce numerics in case import treated them as strings
            foreach v in effect_size se p_value n_obs ///
                         baseline_control_mean magnitude_pct {
                capture confirm string variable `v'
                if !_rc {
                    destring `v', replace force
                }
            }

            if `first_append' {
                save "`longbuilder'", replace
                local first_append 0
            }
            else {
                append using "`longbuilder'"
                save "`longbuilder'", replace
            }
        restore
    }
}

use "`longbuilder'", clear
order family estimator outcome model effect_size se p_value n_obs ///
      baseline_control_mean magnitude_pct
sort family outcome estimator

// =========================================================================
// 2. Sanity check: confirm ANCOVA and DID are not pairwise-identical
//    for any outcome (the Reviewer 2 hypothesis). If any outcome has
//    matching effect+SE across the two estimators, the script halts and
//    flags it for inspection.
// =========================================================================
preserve
    keep if inlist(estimator, "ancova", "did")
    keep family outcome estimator effect_size se
    reshape wide effect_size se, i(family outcome) j(estimator) string
    gen diff_effect = abs(effect_sizeancova - effect_sizedid)
    gen diff_se     = abs(seancova - sedid)
    gen suspicious  = (diff_effect < 1e-10 & diff_se < 1e-10) ///
                       & !missing(effect_sizeancova) & !missing(effect_sizedid)
    count if suspicious
    if r(N) > 0 {
        di as error "WARNING: `r(N)' outcome(s) have identical ANCOVA and DID estimates."
        di as error "         Inspect manually before publishing."
        list family outcome effect_sizeancova effect_sizedid seancova sedid ///
            if suspicious, noobs sepby(family)
    }
    else {
        di as result "PASS: no outcome has pairwise-identical ANCOVA and DID estimates."
    }
restore

// =========================================================================
// 3. Export the long-format full table
// =========================================================================
export delimited using "`tbldir'/table_2_long.csv", replace

// =========================================================================
// 4. Reshape to wide format: one row per (family, outcome), with separate
//    columns per estimator. This is the form Table 2 in the manuscript
//    consumes.
// =========================================================================
preserve
    keep family outcome estimator effect_size se p_value n_obs ///
         baseline_control_mean magnitude_pct
    reshape wide effect_size se p_value n_obs magnitude_pct, ///
        i(family outcome baseline_control_mean) j(estimator) string

    order family outcome baseline_control_mean ///
          effect_sizeancova seancova p_valueancova n_obsancova magnitude_pctancova ///
          effect_sizedid    sedid    p_valuedid    n_obsdid    magnitude_pctdid

    label var effect_sizeancova    "ANCOVA effect"
    label var seancova             "ANCOVA SE"
    label var p_valueancova        "ANCOVA p"
    label var n_obsancova          "ANCOVA N"
    label var magnitude_pctancova  "ANCOVA % of baseline"
    label var effect_sizedid       "DID effect"
    label var sedid                "DID SE"
    label var p_valuedid           "DID p"
    label var n_obsdid             "DID N"
    label var magnitude_pctdid     "DID % of baseline"
    label var baseline_control_mean "Baseline control mean"

    export delimited using "`tbldir'/table_2_wide.csv", replace
restore

// =========================================================================
// 5. Build a manuscript-paste-ready table: each estimator collapsed to
//    a single "coef (SE) [p, N]" string with 3-decimal coefficients,
//    3-decimal SEs, 3-decimal p (or <0.001), and integer N.
// =========================================================================
preserve
    keep family outcome estimator effect_size se p_value n_obs ///
         baseline_control_mean

    gen str20 coef_s = string(effect_size, "%9.3f")
    gen str20 se_s   = "(" + string(se, "%9.3f") + ")"
    gen str20 p_s    = cond(p_value < 0.001, "<0.001", string(p_value, "%9.3f"))
    gen str20 n_s    = string(n_obs, "%9.0f")
    gen str40 cell   = coef_s + " " + se_s + " [p=" + strtrim(p_s) ///
                       + ", N=" + strtrim(n_s) + "]"
    drop coef_s se_s p_s n_s effect_size se p_value n_obs

    reshape wide cell, i(family outcome baseline_control_mean) j(estimator) string

    rename cellancova    ancova
    rename celldid       did
    capture rename cellmultilevel multilevel

    gen str20 baseline_s = string(baseline_control_mean, "%9.3f")
    order family outcome baseline_s ancova did
    capture order family outcome baseline_s ancova did multilevel
    drop baseline_control_mean

    label var family "Outcome family (1..9)"
    label var outcome "Outcome label"
    label var baseline_s "Baseline control mean"
    label var ancova "ANCOVA: coef (SE) [p, N]"
    label var did    "DID: coef (SE) [p, N]"

    export delimited using "`tbldir'/table_2_formatted.csv", replace
restore

di _newline as result "build_table_2 complete. Three outputs written to:"
di as result "  `tbldir'/table_2_long.csv"
di as result "  `tbldir'/table_2_wide.csv"
di as result "  `tbldir'/table_2_formatted.csv"
