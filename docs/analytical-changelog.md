# Analytical Changelog — Original Submission vs R1

This document is the principal Reviewer 2 deliverable, alongside the reproducibility package. It must explain, clearly and concretely, every analytical change made between the original submission and the R1 revision. The two changes Reviewer 2 specifically flagged are at the top.

> **Editor / AE direction:** "Referee 2 notes substantial changes in sample size (~380 to ~2800 observations), changes in point estimates and standard errors, and possible duplication/errors in the ANCOVA and DID tables. Please: clearly explain the analytical changes between versions, verify and correct the ANCOVA/DID tables and results, and provide code and a reproducibility package to ensure the findings can be independently verified."

---

## 1. Women's outcomes: sample-size change N=380 → N=2800

**Reviewer 2:** flagged the sample-size jump and the corresponding movement in point estimates and standard errors.

**Working diagnosis (from reading `code/02-analysis/Prep_04_Construct_Outcome_Tables_Women-takhona.do`):**

The change is a **unit-of-observation restructuring**, not a sample-inclusion change. Takhona's R1 women's analysis uses a stacked-panel DID:

```stata
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

- The standalone `Prep_04_Construct_Outcome_Tables_Women-takhona.do` file (separate from the non-women Prep_04), which exists *only* in the R1 Takhona lineage and not in the May 2025 Kat lineage.
- The presence of `baseline_6_women.dta` and `endline_6_women.dta` (per-wave women's datasets) but no pre-stacked panel file — the stacking is constructed at analysis time inside the `run_analysis` program.

**Open question (verify before drafting response):**

- Is the per-wave women's N approximately 1400? If yes, 2 × 1400 = 2800 closes the arithmetic exactly.
- Was the R0 N=380 a different subset (for example, only those with complete information on a particular outcome, or only women observed at both waves under a stricter complete-case rule)?

**Diagnostic steps (still required):**

1. Run `code/01-prep/Prep_01_Baseline-takhona.do` and `code/01-prep/Prep_02_Endline-takhona.do` to confirm per-wave women's sample sizes.
2. Compare against the R0 Table 1 number (380) and identify whether R0 used a single-wave cross-section, a both-waves intersection, or a different complete-case rule.
3. State the unit of observation, the clustering level, and the rationale in the response letter.

**Provisional resolution language (to refine after diagnostic):**

> Between the original submission and R1 we restructured the women's outcomes analysis from a single-wave cross-sectional ANCOVA-style sample to a stacked baseline-endline panel with two-way fixed effects and standard errors clustered at the woman level. The change in analytic N from approximately 380 to approximately 2,800 reflects this unit-of-observation change, not an expansion of inclusion criteria. We made this change to leverage the within-woman variation that the panel structure makes available and to produce standard errors that account for the repeated-measures design.

---

## 2. Table 2 ANCOVA vs DID duplication

**Reviewer 2:** "the ANCOVA and DID results in Table 2 appear to be copy/paste identical records of each other."

**Working diagnosis (from inspecting the May 2025 Report outputs):**

Evidence strongly supports **manuscript-prep copy-paste error**, not a code bug. The May 2025 Report `Tables/` folder contains separate result files for each outcome family and each estimator:

- `regression_results_6_ancova.csv` (women's outcomes, ANCOVA)
- `regression_results_6_did.csv` (women's outcomes, DID)
- `regression_results_6_multilevel.csv` (women's outcomes, multilevel)

These are produced by distinct programs (`run_analysis` for DID-FE in the women's script; an ANCOVA program exists in the non-women Prep_04 file). The estimates in those CSVs are the canonical numbers.

**Diagnostic steps:**

1. Open `regression_results_6_ancova.csv` and `regression_results_6_did.csv` for the women's outcomes specifically.
2. Confirm the two files have different coefficients and standard errors.
3. Cross-check against the values printed in the *Drone_RCT_BMJGH_Final Submitted Manuscript* Table 2 — identify which column was inadvertently overwritten with the other estimator's numbers.
4. Re-render Table 2 from the canonical CSVs (a Table 2 builder script under `code/03-output/` is the right home for this once written).

**Provisional resolution language (to refine after diagnostic):**

> We thank Reviewer 2 for catching this. The duplicate values in Table 2 reflect a transcription error during manuscript assembly: the DID column was inadvertently populated with the ANCOVA estimates. The underlying ANCOVA and DID analyses are distinct in our analytical code and produced different estimates. We have corrected Table 2 to display the actual DID coefficients and standard errors and have added the table-construction script to the replication package so the issue cannot recur.

---

## 3. Other analytical changes between versions

Document any other change Takhona made between submission versions. Examples to check:

- Outcome variable definitions (re-coding, censoring, or transformation)
- Choice of estimator family (ANCOVA, DID, mixed-effects, GEE) and rationale
- Cluster definition for standard errors (facility, fokontany, commune)
- Multiple-testing correction (or absence of one) for outcome families
- Pre-specified vs exploratory outcomes — only flag if a previously exploratory outcome was elevated, or vice versa
- Robustness checks added in R1

For each change: short paragraph stating what changed, why, and the effect on the headline result.

---

## 4. Items unchanged between versions

A short paragraph listing the analytical choices that did **not** change between R0 and R1. This reassures the reviewer that the changes are scoped, not a wholesale re-analysis.
