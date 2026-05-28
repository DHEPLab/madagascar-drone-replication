# Codebook — Madagascar Drone RCT Replication Package

## Source paths (canonical)

| Asset | Location |
|------------------------------------|------------------------------------|
| Scripts (R1 source) | OneDrive › *Tumlinson, Kat - Madagascar Drone Project* › *Data* › *Analysis and Reports* › *May 2025 Report* › *Scripts* |
| Raw data (baseline) | OneDrive › *Tumlinson, Kat - Madagascar Drone Project* › *Data* › *Baseline Data* |
| Raw data (endline) | OneDrive › *Tumlinson, Kat - Madagascar Drone Project* › *Data* › *Endline Data* |
| Working intermediates | OneDrive › *Data* › *Analysis and Reports* › *May 2025 Report* › *Working* |
| Result tables | OneDrive › *Data* › *Analysis and Reports* › *May 2025 Report* › *Tables* |

## Outcome-family numbering (inferred from `.dta` filenames)

The prep scripts produce per-family intermediate files using a stable numeric index. This index appears in result filenames (`regression_results_<N>_<estimator>.csv`) and is the canonical reference.

| \# | Family | Baseline file | Endline file |
|------------------|------------------|------------------|------------------|
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
Files 1, 6, and 8 are the only relevant/reproduced analyses for the current paper.
:::

Each family also has a `*_micro_*` variant. The micro files pull and clean the specific variables used for each analysis from the raw data files below. :::

## File inventory (raw → analytic)

The scripts expect raw `.dta` extracts in `data/raw/` (or wherever `$ip` points in `code/00_config.do`) including, at minimum:

-   `facility_audit_cleaned_20231013_working.dta`

-   `baseline_drone_treatment_district.dta`

-   `women_cleaned_20240607_working.dta`

-   `endline_facility_audit_cleaned_05032025_final.dta`

-   `endline_women_20250310_final.dta`

| File (in `data/raw/`) | Used by script | Unit of observation | Wave | Notes |
|---------------|---------------|---------------|---------------|---------------|
| `facility_audit_cleaned_20231013_working.dta` | Prep_01_Baseline | facility | baseline | confirmed by code inspection |
| `baseline_drone_treatment_district.dta` | Prep_01_Baseline | facility | baseline | confirmed; provides treatment + district merge |
| `women_cleaned_20240607_working.dta` | Prep_01_Baseline | women | baseline | confirmed by code inspection |
| `endline_facility_audit_cleaned_05032025_final.dta` | Prep_02_Endline | facility | endline | confirmed by code inspection |
| `endline_women_20250310_final.dta` | Prep_02_Endline | women | endline | confirmed by code inspection |
| `respondent_info` | Prep_04_Outcome | facility,women | baseline,endline | confirmed by code inspection |
| `district_info` | Prep_04_Outcome | facility,women | baseline,endline | confirmed by code inspection |

## Variable dictionary

| Variable | Label | Source file | Source var | Derivation | Allowed values | Used in |
|-----------|-----------|-----------|-----------|-----------|-----------|-----------|
| `base01`, `end01` | 1\. Out of Stock of Any Vaccine at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01a`, `end01a` | 1a. Out of Stock of Vaccine Janssen at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01b`, `end01b` | 1b. Out of Stock of Vaccine AstraZeneca at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01c`, `end01c` | 1c. Out of Stock of Vaccine Pfizer at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01d`, `end01d` | 1d. Out of Stock of Pentavalent (DTC/Hepatitis B/Hib) at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01e`, `end01e` | 1e. Out of Stock of Vaccine Pollio Injectable (VPI) at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01f`, `end01f` | 1f. Out of Stock of Vaccine Pollio Oral (VPO) at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01g`, `end01g` | 1g. Out of Stock of Vaccine Rotarix at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01h`, `end01h` | 1h. Out of Stock of Vaccine Anti Rougeoleux (VAR) at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01i`, `end01i` | 1i. Out of Stock of Vaccine Anti Tetanique (VAT) at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01j`, `end01j` | 1j. Out of Stock of Vaccine Anti Pneumococcique (PCV10) at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base01k`, `end01k` | 1k. Out of Stock of Vaccine BCG at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base02`, `end02` | 2\. Out of Stock of Malaria Tests at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base03`, `end03` | 3\. Out of Stock of Malaria Tests in the 3 Months Before Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base04`, `end04` | 4\. Out of Stock of Antimalarial Medicine at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base05`, `end05` | 5\. Out of Stock of Any Contraceptive Method at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base05a`, `end05a` | 5a. Out of Stock of Implants at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base05b`, `end05b` | 5b. Out of Stock of Injectable Depo Provera at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base05c`, `end05c` | 5c. Out of Stock of Injectable Syana Press at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base05d`, `end05d` | 5d. Out of Stock of Pills at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base05e`, `end05e` | 5e. Out of Stock of Male Condoms at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base06`, `end06` | 6\. Out of Stock of Any Contraceptive Method in the 3 Months Before Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base07`, `end07` | 7\. Out of Stock of LARC Removal Supplies at Time of Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base08`, `end08` | 8\. Out of Stock of LARC Removal Supplies in the 3 Months Before Survey | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base09`, `end09` | 9\. CHW Out of Stock of Malaria Tests | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base10`, `end10` | 10\. CHW Out of Stock of Malaria Treatment | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base11`, `end11` | 11\. CHW Out of Stock of Any of the Four FP Methods | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base11a`, `end11a` | 11a. CHW Out of Stock of Injectable Depo Provera | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base11b`, `end11b` | 11b. CHW Out of Stock of Injectable Sayana Press | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base11c`, `end11c` | 11c. CHW Out of Stock of Pills | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base11d`, `end11d` | 11d. CHW Out of Stock of Male Condoms | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base12`, `end12` | 12\. Number of Providers Present Today | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | Numeric (Count) | Table 2 |
| `base13`, `end13` | 13\. Rated Emergency Reordering Procedure Somewhat or Very Easy | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base14`, `end14` | 14\. Ordered Medical Commodities More Frequently Than Every 3 Months | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base15`, `end15` | 15\. Number of FP Visits Completed in Last Month (All Methods Combined) | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | Numeric (Count) | Table 2 |
| `base16`, `end16` | 16\. Number of New Clients Receiving FP in the Last Month | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | Numeric (Count) | Table 2 |
| `base17`, `end17` | 17\. Out of Stock Prevented Helping a Patient in the Last Six Months | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base18`, `end18` | 18\. In Past 6 Months Staff Traveled to District Pharmacy to Place Emergency Order | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base19`, `end19` | 19\. Facility Has Working Fridge for Cold Chain Storage | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base20`, `end20` | 20\. Provider is Absent | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base21`, `end21` | 21\. Informal Payment for Contraception | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base22`, `end22` | 22\. Never Encouraged Patient to Choose a Different Method Due to Method Stockouts | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base23`, `end23` | 23\. Never Encouraged Patient to Use Method Other Than the One Wanted | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base24`, `end24` | 24\. Never Encouraged Patient to Use Long-Acting Method | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base25`, `end25` | 25\. Never Encouraged Patient to Use Short-Acting Method | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base26`, `end26` | 26\. Never Encouraged Patient to Use Permanent Method | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base27`, `end27` | 27\. Never Encouraged Patient to Use Natural Method | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base28`, `end28` | 28\. There are Frequent Out of Stocks of Needed Supplies/Commodities | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base29`, `end29` | 29\. Patients Frequently Leave without their Preferred FP Method | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base30`, `end30` | 30\. I Feel Like I Have Everything I Need to Provide the Best Care | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base31`, `end31` | 31\. Provider Received Their Salary Within the Last Month | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base32`, `end32` | 32\. Provider is Satisfied or Very Satisfied Working Here | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base33`, `end33` | 33\. Mean Number of Days Away from the Facility to Collect Supplies | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | Numeric (Continuous) | Table 2 |
| `base34`, `end34` | 34\. Currently Using Contraception | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base35`, `end35` | 35\. Received Preferred Method | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base36`, `end36` | 36\. Made an Informal Payment for FP | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base37a`, `end37a` | 37a. Did the Nurses or Other Providers Introduce Themselves to You? | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base37b`, `end37b` | 37b. Did the Nurses or Other Providers Call You By Your Name or Child's Name? | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base37c`, `end37c` | 37c. Did You Feel the Nurses and Other Staff Treated You in a Friendly Manner? | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base37d`, `end37d` | 37d. Did the Doctors, Nurses and Other Staff Show That They Cared About You? | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base37e`, `end37e` | 37e. Did the Provider Ask You if You Had Any Questions? | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base37f`, `end37f` | 37f. Did the Nurses at the Facility Talk to You About How You Were Feeling? | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base38`, `end38` | 38\. Facility Did Not Have the Medicines and Supplies When You Visited | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base39`, `end39` | 39\. Currently Using Any Contraceptive Method | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base40`, `end40` | 40\. Currently Using a Modern Contraceptive Method | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base41`, `end41` | 41\. Has Aligned and Preferred Contraceptive Use | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base42`, `end42` | 42\. Has Unmet Need for Contraception | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base43`, `end43` | 43\. Obtained Method from Public Facility | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base44`, `end44` | 44\. Obtained Method from Closest Facility to Home | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base45`, `end45` | 45\. Among Those Not Using, Wishes They Were Using Contraception | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base46`, `end46` | 46\. Received MII+ | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base47`, `end47` | 47\. FP User Would Refer a Friend to the Facility | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base48`, `end48` | 48\. Made an Informal Payment | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base49`, `end49` | 49\. There is Another Method They Would Prefer to Use | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base50`, `end50` | 50\. Among Users, Felt Had Enough Information to Make a Good Decision | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base51`, `end51` | 51\. Among Users, Felt They Could Not Say No to Using | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base52`, `end52` | 52\. Child Never Received a Vaccine to Prevent Disease | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base53`, `end53` | 53\. Child Received BCG | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base54`, `end54` | 54\. Child Received Pentavalent | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base55`, `end55` | 55\. Child Received Pneumococcal | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base56`, `end56` | 56\. Child Received Rotavirus | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base57`, `end57` | 57\. Child Received Measles | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base58`, `end58` | 58\. Among Children with Fever in Last Two Weeks, Pct Who Had Blood Taken | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | Numeric (%) | Table 2 |
| `base59`, `end59` | 59\. Among Children with Fever in Last Two Weeks, Pct Diagnosed with Malaria | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | Numeric (%) | Table 2 |
| `base60`, `end60` | 60\. Sought Healthcare from a Public or Private Facility, Ever | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base61`, `end61` | 61\. Sought Healthcare from a Public Facility the Most Recent Time | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base62`, `end62` | 62\. Strongly Agree Staff Was Friendly | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base63`, `end63` | 63\. Strongly Agree Staff Gave All Information Needed | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base64`, `end64` | 64\. Strongly Agree Staff Provided High Quality Services | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base65`, `end65` | 65\. Strongly Agree Staff Ensured Privacy | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base66`, `end66` | 66\. Strongly Agree Staff Involved Me in Decisions About My Care | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base67`, `end67` | 67\. Disagree or Strongly Disagree I Had to Wait a Long Time to Receive Care | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base68`, `end68` | 68\. Disagree or Strongly Disagree Staff Did Not Have Methods | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base69`, `end69` | 69\. Disagree or Strongly Disagree Staff Did Not Have Vaccines | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base70`, `end70` | 70\. Perceived High Quality Care at the Closest Facility | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base71`, `end71` | 71\. Those Highly Satisfied with Care Among Those at Public Facility in Last Year | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base72`, `end72` | 72\. Those Who Rated Care as Excellent Quality at Public Facility in Last Year | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base73`, `end73` | 73\. Those Treated Very Well by Provider at Public Facility in Last Year | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base74`, `end74` | 74\. Those Very Confident They Could Receive Method Next Week at Closest Facility | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base75`, `end75` | 75\. Those Very Confident the Closest Facility Has a Reliable Supply of FP | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base76`, `end76` | 76\. Those Very Confident in Receiving Vaccinations at the Closest Facility | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |
| `base77`, `end77` | 77\. Obtained Last Method from Community Health Worker | `Prep_01_Baseline.do`, `Prep_02_Endline.do` | *Raw survey var* | *Recoded in prep script* | 0/1 (no/yes) | Table 2 |

## Inclusion / exclusion criteria

All randomized facilities included in the analyses.

## Software environment

| Tool  | Version | Notes                                     |
|-------|---------|-------------------------------------------|
| Stata | 19.5    | Required if any `.do` scripts are present |
