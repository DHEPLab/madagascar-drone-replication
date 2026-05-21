# Analytical Changelog — Original Submission vs R1

This document is the principal Reviewer 2 deliverable, alongside the reproducibility package. It must explain, clearly and concretely, every analytical change made between the original submission and the R1 revision. The two changes Reviewer 2 specifically flagged are at the top.

> **Editor / AE direction:** "Referee 2 notes substantial changes in sample size (~380 to ~2800 observations), changes in point estimates and standard errors, and possible duplication/errors in the ANCOVA and DID tables. Please: clearly explain the analytical changes between versions, verify and correct the ANCOVA/DID tables and results, and provide code and a reproducibility package to ensure the findings can be independently verified."

---

## 1. Women's outcomes: sample-size change N=380 → N=2800

**Reviewer 2:** flagged the sample-size jump and the corresponding movement in point estimates and standard errors.

**Working hypotheses (to confirm by re-running the prep code):**

- **H1. Inclusion criteria changed between versions.** The most likely explanation. If the R1 prep code applies a different restriction (for example, expanding the window of eligible women, or relaxing a complete-case requirement) the analytic N would grow. Inspect `code/01-prep/` for inclusion logic and diff against any R0 prep code Takhona archived.
- **H2. Panel / long-form vs cross-section restructuring.** Plausible alternative: women's outcomes in R0 were collapsed to one row per woman (cross-section) whereas R1 keeps multiple observations per woman (long-form panel by visit). N=2800 is roughly 7.4 × N=380, which is consistent with multiple observations per individual if average waves per woman are between 7 and 8.

**Diagnostic plan:**

1. Run the R1 prep code from `data/raw/`. Record the analytic N at each restriction step.
2. Compare to the R0 numbers reported in the original manuscript Table 1.
3. Identify the precise step where the two N values diverge.
4. Document the change as either (a) inclusion-criteria revision (state the old and new rules and the substantive rationale) or (b) panel-vs-cross-section restructuring (state the unit of observation in each version and confirm the standard errors cluster appropriately).

**Resolution:** _to be written after diagnostic_

---

## 2. Table 2 ANCOVA vs DID duplication

**Reviewer 2:** "the ANCOVA and DID results in Table 2 appear to be copy/paste identical records of each other."

**Working hypothesis:** copy-paste error in manuscript preparation, not a methods bug. Sean's read of the comment is that the underlying analyses are likely distinct in Takhona's scripts; the duplication appears to be a transcription issue when the Table 2 was assembled.

**Diagnostic plan:**

1. Locate Takhona's ANCOVA code (`code/02-analysis/` candidate).
2. Locate Takhona's DID code (`code/02-analysis/` candidate).
3. Run both. Compare coefficients and standard errors.
4. If estimates differ (expected): correct Table 2 to show the true DID column.
5. If estimates are identical (unexpected): inspect the DID specification — most likely the script is mis-specified (for example, omitting the post-period interaction) and producing a parallel ANCOVA. Diagnose, correct, re-run.

**Resolution:** _to be written after diagnostic_

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
