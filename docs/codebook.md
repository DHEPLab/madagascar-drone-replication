# Codebook — Madagascar Drone RCT Replication Package

Status: **placeholder**. Populate once Takhona's scripts and the SharePoint data extracts are loaded into `data/raw/`.

## File inventory (to be filled)

| File (in `data/raw/`) | Source on SharePoint | Unit of observation | Wave / period | Notes |
|---|---|---|---|---|
| _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |

## Variable dictionary (to be filled)

For each analytic variable used in the manuscript, document:

- **Variable name** (as it appears in the cleaned analytic file)
- **Label** (human-readable description)
- **Source raw file** and source variable name
- **Derivation** (formula, recoding rules, or one-line description of construction)
- **Allowed values** (range, factor levels, or "see source")
- **Used in** (table or figure number)

| Variable | Label | Source file | Source var | Derivation | Allowed values | Used in |
|---|---|---|---|---|---|---|
| _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ | _TBD_ |

## Inclusion / exclusion criteria

The N=380 → N=2800 change for women's outcomes is the central analytical question for the R1 response. This section must, at minimum:

1. State the **R0 inclusion criteria** (rules used in the original submission).
2. State the **R1 inclusion criteria** (rules used in the revised analysis).
3. Tabulate the analytic sample at each restriction step, for each outcome family (women's outcomes; children's outcomes; facility-level outcomes).

A consort-style flow diagram from raw sample to analytic sample is suggested.

## Software environment

| Tool | Version | Notes |
|---|---|---|
| Stata | _TBD_ | Required if any `.do` scripts are present |
| R | _TBD_ | Required if any `.R` scripts are present |
| R packages | _TBD_ | List with versions, ideally via `renv::snapshot()` or session info |

## Random seeds

Document all `set seed` or `set.seed()` values used in the analytical pipeline so stochastic outputs (bootstraps, permutation tests, simulations) are reproducible.

| Script | Seed | Reason |
|---|---|---|
| _TBD_ | _TBD_ | _TBD_ |
