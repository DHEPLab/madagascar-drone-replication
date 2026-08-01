# Wings of Access — Madagascar Drone Cluster RCT Replication Package

## Repository layout

```
madagascar-drone-replication/
├── data/
│   ├── raw/        # Original extracts (gitignored)
│   └── clean/      # Derived analytic datasets (gitignored)
├── code/
│   ├── 01-prep/    # Data preparation: cleaning, merging, restriction
│   ├── 02-analysis/# ANCOVA, difference-in-differences, robustness
│   └── 03-output/  # Table and figure generation
├── output/
    ├── tables/     # Final tables (Table 1, Table 2, etc.)
    └── figures/    # Final figures

```

## How to run

1. **Configure paths.** Open `code/00_config.do` and edit the `$repo` macro to point at your local clone. This file is the single place where local paths are set.
2. **Place raw data.** Download files into `data/raw/`, or set `$ip` in `code/00_config.do` to point directly at the data location. 
3. **Run in numbered order:**
   - `code/00_config.do` — sets global path macros (run every session before anything else).
   - `code/01-prep/_var_labels.do` — variable-label utility, called by the prep scripts.
   - `code/01-prep/Prep_01_Baseline-takhona.do` — builds baseline outcome-family datasets (`baseline_1_facility.dta` through `baseline_9_*.dta`).
   - `code/01-prep/Prep_02_Endline-takhona.do` — builds endline outcome-family datasets.
   - `code/02-analysis/Prep_04_Construct_Outcome_Tables-takhona.do` — ANCOVA and DID analyses for facility and child outcomes.
   - `code/02-analysis/Prep_04_Construct_Outcome_Tables_Women-takhona.do` — stacked-panel DID-FE analysis for women's outcomes.
   - `code/03-output/build_table_2.do` — reads the canonical `regression_results_*.csv` files and renders Table 2 in three formats (long, wide, and a paste-ready formatted version). .

Outputs land in `output/tables/` (`regression_results_<family>_<estimator>.csv`, `table_2_*.csv`) and `output/figures/`.
