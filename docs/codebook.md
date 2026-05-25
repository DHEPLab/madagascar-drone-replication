# Codebook — Madagascar Drone RCT Replication Package

Status: **partial**. Scripts are in place (see `code/`); raw data file inventory still needs Takhona's confirmation against the OneDrive source.

## OneDrive source paths (canonical)

| Asset | Location |
|----|----|
| Scripts (R1 source) | OneDrive › *Tumlinson, Kat - Madagascar Drone Project* › *Data* › *Analysis and Reports* › *May 2025 Report* › *Scripts* |
| Raw data (baseline) | OneDrive › *Tumlinson, Kat - Madagascar Drone Project* › *Data* › *Baseline Data* |
| Raw data (endline) | OneDrive › *Tumlinson, Kat - Madagascar Drone Project* › *Data* › *Endline Data* |
| Working intermediates | OneDrive › *Data* › *Analysis and Reports* › *May 2025 Report* › *Working* |
| Result tables | OneDrive › *Data* › *Analysis and Reports* › *May 2025 Report* › *Tables* |

## Outcome-family numbering (inferred from `.dta` filenames)

The prep scripts produce per-family intermediate files using a stable numeric index. This index appears in result filenames (`regression_results_<N>_<estimator>.csv`) and is the canonical reference.

| \# | Family | Baseline file | Endline file |
|----|----|----|----|
| 1 | Facility | `baseline_1_facility.dta` | `endline_1_facility.dta` |
| 2 | CHW (community health worker) | `baseline_2_chw.dta` | `endline_2_chw.dta` |
| 3 | UAV (drone operations) | `baseline_3_uav.dta` | `endline_3_uav.dta` |
| 4 | Provider | `baseline_4_provider.dta` | `endline_4_provider.dta` |
| 5 | CEI | `baseline_5_cei.dta` | `endline_5_cei.dta` |
| 6 | Women | `baseline_6_women.dta` | `endline_6_women.dta` |
| 7 | Women + child vaccine | `baseline_7_women_child_vaccine.dta` | `endline_7_women_child_vaccine.dta` |
| 8 | Women + child health | `baseline_8_women_child_health.dta` | `endline_8_women_child_health.dta` |
| 9 | Women + child zerodose / underimmunized | `baseline_9_women_child_zerodose_underimmuniz.dta` | `endline_9_women_child_zerodose_underimmuniz.dta` |

::: callout-note
1, 6, and 8 are the only relevant/reproduced analyses for the current paper.
:::

Each family also has a `*_micro_*` variant in the OneDrive `Working/` folder. Takhona to confirm: are the `_micro_*` files the per-individual disaggregations of the family-level rollups, or a parallel naming for a different aggregation level?

::: callout-note
The micro files pull and clean the specicific variables used for each analysis from the raw data files below --\>
:::

## File inventory (raw → analytic)

The scripts expect raw `.dta` extracts in `data/raw/` (or wherever `$ip` points in `code/00_config.do`) including, at minimum:

-   `facility_audit_cleaned_20231013_working.dta`
-   `baseline_drone_treatment_district.dta`
-   `women_cleaned_20240607_working.dta`
-   `endline_facility_audit_cleaned_05032025_final.dta`
-   `endline_women_20250310_final.dta`

Takhona to complete the full list once she runs `code/01-prep/Prep_01_Baseline-takhona.do` and `Prep_02_Endline-takhona.do` against a clean checkout and logs which files are read.

| File (in `data/raw/`) | Used by script | Unit of observation | Wave | Notes |
|----|----|----|----|----|
| `facility_audit_cleaned_20231013_working.dta` | Prep_01_Baseline | facility | baseline | confirmed by code inspection |
| `baseline_drone_treatment_district.dta` | Prep_01_Baseline | facility | baseline | confirmed; provides treatment + district merge |
| `women_cleaned_20240607_working.dta` | Prep_01_Baseline | women | baseline |  |
| `endline_facility_audit_cleaned_05032025_final.dta` | Prep_02_Endline | facility | endline |  |
| `endline_women_20250310_final.dta` | Prep_02_Endline | women | endline |  |
| `respondent_info` | Prep_04_Outcome | facility,women | baseline,endline |  |
| `district_info` | Prep_04_Outcome | facility,women | baseline,endline |  |

## Variable dictionary (to be filled)

For each analytic variable used in the manuscript, document:

-   **Variable name** (as it appears in the cleaned analytic file)
-   **Label** (human-readable description)
-   **Source raw file** and source variable name
-   **Derivation** (formula, recoding rules, or one-line description of construction)
-   **Allowed values** (range, factor levels, or "see source")
-   **Used in** (table or figure number)

| Variable | Label | Source file | Source var | Derivation | Allowed values | Used in |
|----------|-------|-------------|------------|------------|----------------|---------|
| *TBD*    | *TBD* | *TBD*       | *TBD*      | *TBD*      | *TBD*          | *TBD*   |

## Inclusion / exclusion criteria

The N=380 → N=2800 change for women's outcomes is the central analytical question for the R1 response. This section must, at minimum:

1.  State the **R0 inclusion criteria** (rules used in the original submission).
2.  State the **R1 inclusion criteria** (rules used in the revised analysis).
3.  Tabulate the analytic sample at each restriction step, for each outcome family (women's outcomes; children's outcomes; facility-level outcomes).

A consort-style flow diagram from raw sample to analytic sample is suggested.

## Software environment

| Tool  | Version | Notes                                     |
|-------|---------|-------------------------------------------|
| Stata | 19.5    | Required if any `.do` scripts are present |

## Random seeds

No seeds used.
