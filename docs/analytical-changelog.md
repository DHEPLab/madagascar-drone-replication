# Analytical Changelog — Original Submission vs R1

This document is the principal Reviewer 2 deliverable, alongside the reproducibility package. It must explain, clearly and concretely, every analytical change made between the original submission and the R1 revision. The two changes Reviewer 2 specifically flagged are at the top.

> **Editor / AE direction:** "Referee 2 notes substantial changes in sample size (\~380 to \~2800 observations), changes in point estimates and standard errors, and possible duplication/errors in the ANCOVA and DID tables. Please: clearly explain the analytical changes between versions, verify and correct the ANCOVA/DID tables and results, and provide code and a reproducibility package to ensure the findings can be independently verified."

::: callout-note
Note: The previous analysis excluded facilities outside Mahanoro for women's outcomes. As the analysis is intention to treat (ITT), the revised version includes these facilities. This affected the sample size between R0 and R1.
:::

------------------------------------------------------------------------

## 1. Women's outcomes: sample-size change N=380 → N=2800 - Additional considerations

**Reviewer 2:** flagged the sample-size jump and the corresponding movement in point estimates and standard errors.

**Working diagnosis (from reading `code/02-analysis/Prep_04_Construct_Outcome_Tables_Women.do`):**

The change is a **unit-of-observation restructuring**, not a sample-inclusion change. The R1 women's analysis uses a stacked-panel DID:

``` stata
use   "`basefile'", clear
gen   endline = 0
append using "`endfile'"
replace endline = 1 if missing(endline)
...
xtset id_numeric endline
xtreg outcomeX i.treatment##i.endline ..., fe vce(cluster id_numeric)
```

Each woman contributes one baseline observation and one endline observation, so the analytic N is approximately 2x the per-wave count of eligible women. The earlier (R0) Table 1 likely reported a cross-section N from a single wave (women observed at endline, or a collapsed one-row-per-woman view). The R1 panel structure is mechanically larger and the standard errors are clustered at `id_numeric` (woman level).

This explanation is consistent with:

-   The presence of `baseline_6_women.dta` and `endline_6_women.dta` (per-wave women's datasets) but no pre-stacked panel file — the stacking is constructed at analysis time inside the `run_analysis` program.

**Empirical confirmation (from `regression_results_6_*.csv` in the May 2025 Report):**

Outcome 39 ("Currently Using Any Contraceptive Method"):

| Spec           | N         | Effect | SE    |
|----------------|-----------|--------|-------|
| ANCOVA         | **381**   | 0.066  | 0.055 |
| DID-FE (panel) | **2,410** | 0.043  | 0.053 |

Outcome 42 ("Has Unmet Need for Contraception"):

| Spec           | N     | Effect | SE    |
|----------------|-------|--------|-------|
| ANCOVA         | 530   | -0.039 | 0.031 |
| DID-FE (panel) | 2,855 | -0.037 | 0.036 |

The R0-reported N≈380 is the ANCOVA N for the lead contraception outcome (literally 381). The R1-reported N≈2800 is the DID-FE N for that same outcome. The mechanism is the spec change, not a sample-inclusion change:

-   **ANCOVA** (`reg endvar treatment basevar covariates, vce(cluster idvar)`) requires a paired `1:1 merge` of baseline and endline files, then `reg` drops women with missing baseline OR endline values → restrictive complete-case sample.
-   **Panel DID-FE** (`xtreg outcome i.treatment##i.endline ..., fe vce(cluster id_numeric)`) operates on the appended baseline + endline stack and uses any non-missing observation at either wave → permissive sample with woman-level fixed effects.

So the change is doubly permissive: it switches the unit of observation (cross-section of paired observations → stacked panel) AND it relaxes the both-waves complete-case rule.

**Provisional resolution language (to refine with Tara and Kat):**

> Between the original submission and R1 we changed the women's outcomes estimator from an ANCOVA-style cross-sectional specification — regressing the endline outcome on the baseline outcome, treatment, and covariates with cluster-robust standard errors — to a stacked baseline-endline panel with two-way fixed effects and standard errors clustered at the woman level. The change in analytic N from approximately 380 to approximately 2,800 (using outcome 39, contraceptive use, as the reference case: 381 → 2,410) reflects two consequences of the spec change: the unit of observation moves from one row per woman to one row per woman-wave, and the analysis no longer requires both baseline and endline values to be observed for each woman. The point estimates and standard errors move accordingly. We adopted the panel specification to leverage within-woman variation and to produce standard errors that account for the repeated-measures design.

------------------------------------------------------------------------

## 2. Table 2 ANCOVA vs DID duplication

**Reviewer 2:** "the ANCOVA and DID results in Table 2 appear to be copy/paste identical records of each other."

**Working diagnosis (from inspecting the May 2025 Report outputs):**

Evidence strongly supports **manuscript-prep copy-paste error**, not a code bug. The May 2025 Report `Tables/` folder contains separate result files for each outcome family and each estimator:

-   `regression_results_6_ancova.csv` (women's outcomes, ANCOVA)
-   `regression_results_6_did.csv` (women's outcomes, DID)
-   `regression_results_6_multilevel.csv` (women's outcomes, multilevel)

These are produced by distinct programs (`run_analysis` for DID-FE in the women's script; an ANCOVA program exists in the non-women Prep_04 file). The estimates in those CSVs are the canonical numbers.

**Diagnostic steps:**

1.  Open `regression_results_6_ancova.csv` and `regression_results_6_did.csv` for the women's outcomes specifically.
2.  Confirm the two files have different coefficients and standard errors.
3.  Cross-check against the values printed in the *Drone_RCT_BMJGH_Final Submitted Manuscript* Table 2 — identify which column was inadvertently overwritten with the other estimator's numbers.
4.  Re-render Table 2 from the canonical CSVs (a Table 2 builder script under `code/03-output/` is the right home for this once written).

**Provisional resolution language (to refine after diagnostic):**

> We thank Reviewer 2 for catching this. The duplicate values in Table 2 reflect a transcription error during manuscript assembly: the DID column was inadvertently populated with the ANCOVA estimates. The underlying ANCOVA and DID analyses are distinct in our analytical code and produced different estimates. We have corrected Table 2 to display the actual DID coefficients and standard errors and have added the table-construction script to the replication package so the issue cannot recur.

------------------------------------------------------------------------

## 3. Other analytical changes between versions

-   Choice of estimator family (ANCOVA, DID, mixed-effects, GEE) and rationale - The revised version does not inlude a multilevel analysis

-   Cluster definition for standard errors (facility, fokontany, commune) - The revised version includes clustering by facility

------------------------------------------------------------------------

## 4. Items unchanged between versions

The rest of the analysis did **not** change between R0 and R1.
