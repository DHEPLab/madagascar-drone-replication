# Wings of Access — Madagascar Drone Cluster RCT Replication Package

Replication code and documentation for **"Wings of Access: A Cluster RCT on Drone-Based Medical Commodity Delivery in Remote Madagascar"**, BMJ Global Health (manuscript ID `bmjgh-2025-021965.R1`).

This repository accompanies the R1 revision submitted in response to the 2026-05-19 major-revision decision. It exists primarily to address Reviewer 2's request for a reproducibility package and to document the analytical changes between submission versions.

## Authorship

- **Lead / corresponding:** Kat Tumlinson (`ktumlin@email.unc.edu`)
- **Analyst:** Takhona Grace Hlatshwako (`takhona@live.unc.edu`)
- **Co-author:** Tara Templin (`ttemplin@unc.edu`)
- **Co-author:** Sean Sylvia (`sysylvia@email.unc.edu`)

Repository structure and documentation scaffolded by Sean (mentor). Analytical code authored by Takhona.

## Citation

> Tumlinson K, Hlatshwako TG, Templin T, Sylvia S. Wings of Access: A Cluster RCT on Drone-Based Medical Commodity Delivery in Remote Madagascar. *BMJ Global Health* (under revision, 2026).

## Repository layout

```
madagascar-drone-replication/
├── data/
│   ├── raw/        # Original extracts from SharePoint (gitignored)
│   └── clean/      # Derived analytic datasets (gitignored)
├── code/
│   ├── 01-prep/    # Data preparation: cleaning, merging, restriction
│   ├── 02-analysis/# ANCOVA, difference-in-differences, robustness
│   └── 03-output/  # Table and figure generation
├── output/
│   ├── tables/     # Final tables (Table 1, Table 2, etc.)
│   └── figures/    # Final figures
└── docs/
    ├── codebook.md                  # Variable definitions and provenance
    ├── analytical-changelog.md      # R1 vs original analytical diff (Reviewer 2 ask)
    └── mentoring-brief-for-takhona.md # Sean's scaffolding notes for Takhona
```

Raw data and derived analytic datasets are kept out of version control. The canonical raw data live on UNC SharePoint at *ktumlin/Madagascar Drone Project/Data*; the canonical Stata/R scripts live at *ktumlin/Scripts*. Refer to `docs/codebook.md` for the file inventory once data are loaded.

## How to run

1. Place raw SharePoint extracts in `data/raw/` (see `docs/codebook.md` for expected files).
2. Run scripts in numbered order:
   - `code/01-prep/` — produces cleaned analytic datasets in `data/clean/`
   - `code/02-analysis/` — produces ANCOVA and DID estimates
   - `code/03-output/` — produces tables and figures in `output/`

A consolidated runner script will be added once the script inventory is mapped (see `docs/mentoring-brief-for-takhona.md`).

## Replication checklist

Targets for the R1 reproducibility package:

- [ ] Codebook complete (variable name, label, source file, derivation, allowed values)
- [ ] Analytical changelog narrative documents the N=380 → N=2800 change for women's outcomes between submission versions
- [ ] Table 2 ANCOVA and DID estimates produced independently by separate scripts (confirms or refutes the suspected copy-paste in the prior manuscript)
- [ ] Scripts run end-to-end from `data/raw/` without manual intervention
- [ ] Random seeds set where stochastic procedures are used
- [ ] Software versions documented in `docs/codebook.md` (Stata, R, package versions)
- [ ] README run instructions verified on a clean checkout

## Reviewer-driven analytical questions

Two items from Reviewer 2 require the dry-run to inspect, not just describe:

1. **Sample-size change 380 → 2800 (women's outcomes).** Diagnose whether the change reflects an inclusion-criteria revision between versions or a panel/long-form vs cross-section restructuring of the women's outcomes dataset.
2. **Table 2 ANCOVA vs DID duplication.** Reviewer 2 observed that the DID column appears identical to the ANCOVA column. Run both estimators independently and confirm or correct.

See `docs/analytical-changelog.md` for the working narrative.

## License

License selection deferred to corresponding author (Kat Tumlinson).
