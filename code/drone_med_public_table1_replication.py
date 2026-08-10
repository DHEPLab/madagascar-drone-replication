#!/usr/bin/env python3
"""Reproduce DRONE-MED manuscript Table 1a and Table 1b from public .tab files.

Required inputs:
  drone-med_baseline_facility_audit_public.tab
  drone-med_baseline_women_public.tab

No private helper .dta files are used.

Outputs:
  table_1a_public.csv
  table_1b_public.csv
  table_1_numeric_long.csv
  table_1_run_log.txt

Run
-------
python code/drone_med_public_table1_replication.py \
  --output-dir output
  
  """

from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any

import numpy as np
import pandas as pd
from scipy.stats import chi2_contingency, ttest_ind


FACILITY_FILENAME = "data/drone-med_baseline_facility_audit_public.tab"
WOMEN_FILENAME = "data/drone-med_baseline_women_public.tab"


def require_columns(df: pd.DataFrame, columns: list[str], name: str) -> None:
    missing = [c for c in columns if c not in df.columns]
    if missing:
        raise ValueError(f"{name} is missing required columns: {', '.join(missing)}")


def format_p(p: float) -> str:
    # Mirrors the mixed precision in the manuscript table, while using
    # conventional rounding of the recomputed statistic.
    if not np.isfinite(p):
        return ""
    if p < 0.005:
        return "0.00"
    if p < 0.10:
        text = f"{p:.3f}".rstrip("0").rstrip(".")
        if "." in text and len(text.split(".")[1]) < 2:
            text += "0" * (2 - len(text.split(".")[1]))
        return text
    return f"{p:.2f}"


def n_pct(n: int, denominator: int, decimals: int = 1) -> str:
    return f"{n} ({100*n/denominator:.{decimals}f}%)" if denominator else ""


def categorical_block(
    df: pd.DataFrame,
    variable: str,
    characteristic: str,
    levels: list[tuple[Any, str]],
    total_decimals: int = 1,
) -> tuple[list[dict[str, Any]], list[dict[str, Any]]]:
    valid = df[variable].notna()
    cross = pd.crosstab(df.loc[valid, variable], df.loc[valid, "treatment"])
    p = float(chi2_contingency(cross, correction=False).pvalue)

    den = {
        "drone": int(((df.treatment == 1) & valid).sum()),
        "control": int(((df.treatment == 0) & valid).sum()),
        "total": int(valid.sum()),
    }

    display, numeric = [], []
    for i, (code, label) in enumerate(levels):
        counts = {
            "drone": int(((df.treatment == 1) & (df[variable] == code)).sum()),
            "control": int(((df.treatment == 0) & (df[variable] == code)).sum()),
            "total": int((df[variable] == code).sum()),
        }
        display.append({
            "Characteristic": characteristic if i == 0 else "",
            "Level": label,
            "Drone": n_pct(counts["drone"], den["drone"], 1),
            "Control": n_pct(counts["control"], den["control"], 1),
            "Total": n_pct(counts["total"], den["total"], total_decimals),
            "p-value": format_p(p) if i == 0 else "",
        })
        numeric.append({
            "characteristic": characteristic,
            "level": label,
            "statistic_type": "n_percent",
            "drone_n": counts["drone"],
            "drone_denominator": den["drone"],
            "drone_percent": 100*counts["drone"]/den["drone"],
            "control_n": counts["control"],
            "control_denominator": den["control"],
            "control_percent": 100*counts["control"]/den["control"],
            "total_n": counts["total"],
            "total_denominator": den["total"],
            "total_percent": 100*counts["total"]/den["total"],
            "p_value": p if i == 0 else np.nan,
        })
    return display, numeric


def continuous_row(
    df: pd.DataFrame, variable: str, characteristic: str
) -> tuple[dict[str, Any], dict[str, Any]]:
    drone = df.loc[(df.treatment == 1) & df[variable].notna(), variable].astype(float)
    control = df.loc[(df.treatment == 0) & df[variable].notna(), variable].astype(float)
    total = df.loc[df[variable].notna(), variable].astype(float)
    p = float(ttest_ind(drone, control, equal_var=True).pvalue)

    display = {
        "Characteristic": characteristic,
        "Level": "",
        "Drone": f"{drone.mean():.2f} ({drone.std(ddof=1):.2f})",
        "Control": f"{control.mean():.2f} ({control.std(ddof=1):.2f})",
        "Total": f"{total.mean():.2f} ({total.std(ddof=1):.2f})",
        "p-value": format_p(p),
    }
    numeric = {
        "characteristic": characteristic,
        "level": "",
        "statistic_type": "mean_sd",
        "drone_n": len(drone),
        "drone_mean": drone.mean(),
        "drone_sd": drone.std(ddof=1),
        "control_n": len(control),
        "control_mean": control.mean(),
        "control_sd": control.std(ddof=1),
        "total_n": len(total),
        "total_mean": total.mean(),
        "total_sd": total.std(ddof=1),
        "p_value": p,
    }
    return display, numeric


def prepare_facility(raw: pd.DataFrame) -> pd.DataFrame:
    required = [
        "consent", "treatment", "s0_employee",
        *[f"s1_1{x}" for x in "abcdef"],
        *[f"s1_1a_{i}" for i in range(1, 7)],
        "s1_02", "s1_03", "s1_04", "s1_07", "s1_08", "s1_09",
        "s1_11", "s1_12", "s1_13", "s1_15",
    ]
    require_columns(raw, required, "baseline facility audit")
    df = raw.loc[raw.consent == 1].copy()

    assigned = df[[f"s1_1{x}" for x in "abcdef"]].fillna(0).sum(axis=1)
    df["providers_assigned"] = np.select(
        [assigned.eq(1), assigned.between(2,3), assigned.between(4,5),
         assigned.between(6,8), assigned.ge(9)],
        [1,2,3,4,5], default=np.nan
    )

    present = df[[f"s1_1a_{i}" for i in range(1,7)]].fillna(0).sum(axis=1)
    df["providers_present"] = np.select(
        [present.eq(0), present.eq(1), present.between(2,3),
         present.between(4,5), present.between(6,8), present.ge(9)],
        [0,1,2,3,4,5], default=np.nan
    )
    return df


def build_table_1a(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    specs = [
        ("s0_employee", "Employee Assisting with Interview/Audit",
         [(1,"In-charge/manager"),(2,"Staff")]),
        ("providers_assigned", "Number of Providers Currently Assigned",
         [(2,"2 - 3 Providers"),(3,"4 - 5 Providers"),(4,"6 - 8 Providers"),(5,"9+ Providers")]),
        ("providers_present", "Number of Providers Present Today",
         [(0,"No Providers"),(1,"1 Provider"),(2,"2 Providers"),(3,"3 Providers"),(4,"4 Providers")]),
        ("s1_02", "Designee In Charge of Stock Management",
         [(1,"Doctor"),(2,"Nurse"),(3,"Dispenser"),(5,"Community health worker"),(7,"Midwife")]),
        ("s1_03", "Designee Has Enough Dedicated Work Hours for Inventory Management",
         [(0,"No"),(1,"Yes")]),
        ("s1_04", "Rating of Emergency Re-Ordering Procedure",
         [(1,"Very challenging"),(2,"Somewhat challenging"),(3,"Neutral"),(4,"Somewhat easy"),(5,"Very easy")]),
        ("s1_07", "Facility Has Electricity", [(0,"No"),(1,"Yes")]),
        ("s1_08", "Facility Has Running Water", [(0,"No"),(1,"Yes")]),
        ("s1_09", "Facility Has Hand-Washing Facility", [(0,"No"),(1,"Yes")]),
        ("s1_11", "Frequency of Medical Commodities/Supplies Checked",
         [(1,"Once a day"),(2,"Once or twice a week"),(3,"Once or twice a month"),(6,"Once or twice a year")]),
        ("s1_12", "Frequency of Medical Commodities/Supplies Ordered",
         [(2,"Once or twice a week"),(3,"Once or twice a month"),(4,"Every other month"),
          (5,"Every three months"),(6,"Once or twice a year")]),
        ("s1_13", "Facility Has Service Roster Displayed", [(0,"No"),(1,"Yes")]),
        ("s1_15", "Facility Has System to Solicit Client Opinions", [(0,"No"),(1,"Yes")]),
    ]
    display, numeric = [], []
    for variable, characteristic, levels in specs:
        d, n = categorical_block(df, variable, characteristic, levels)
        display.extend(d); numeric.extend(n)

    out = pd.DataFrame(display)
    out.columns = [
        "Characteristic", "Level", "Drone (N=53)", "Control (N=54)",
        "Total (N=107)", "p-value"
    ]
    num = pd.DataFrame(numeric)
    num.insert(0, "table", "Table 1a")
    return out, num


def prepare_women(raw: pd.DataFrame) -> pd.DataFrame:
    required = [
        "treatment", "s1_3", "s1_11", "s1_17", "s1_18", "s1_19",
        "s7_1", "s7_3", "s2_1", "s2_2", "s2_4", "s2_6",
        "s3_1", "s3_2", "s3_3", "s3_5_current",
    ]
    require_columns(raw, required, "baseline women")
    df = raw.copy()

    df["age_category"] = pd.cut(
        df.s1_3, bins=[14,19,24,29,34,39,49], labels=[1,2,3,4,5,6]
    ).astype(float)
    df["education_category"] = df.s1_11.fillna(0)
    df["married_or_cohabiting"] = df.s7_1.isin([1,2]).astype(int)

    living = df.s2_2.copy()
    dead = df.s2_4.copy()
    losses = df.s2_6.copy()
    for x in (living, dead, losses):
        x.loc[(df.s2_1 == 1) & x.isna()] = 0
    df["pregnancies_topcoded_6"] = (living + dead + losses).clip(upper=6)

    living2 = df.s2_2.copy()
    dead2 = df.s2_4.copy()
    for x in (living2, dead2):
        x.loc[(df.s2_1 == 1) & x.isna()] = 0
    df["live_births_topcoded_6"] = (living2 + dead2).clip(upper=6)
    df["living_children_topcoded_6"] = df.s2_2.clip(upper=6)

    df["using_any_contraception"] = np.nan
    df.loc[df.s3_1.isin([1,2]), "using_any_contraception"] = 1
    df.loc[df.s3_1.eq(0), "using_any_contraception"] = 0

    df["aligned_preferred_use"] = np.nan
    df.loc[
        (df.s3_1.isin([1,2]) & df.s3_3.eq(1)) |
        (df.s3_1.eq(0) & df.s3_2.eq(0)),
        "aligned_preferred_use"
    ] = 1
    df.loc[
        (df.s3_1.isin([1,2]) & df.s3_3.eq(0)) |
        (df.s3_1.eq(0) & df.s3_2.eq(1)),
        "aligned_preferred_use"
    ] = 0
    df["wishes_using_contraception"] = df.s3_2
    return df


def build_table_1b(df: pd.DataFrame) -> tuple[pd.DataFrame, pd.DataFrame]:
    before = [
        ("age_category","Age",[(1,"15 - 19"),(2,"20 - 24"),(3,"25 - 29"),
                              (4,"30 - 34"),(5,"35 - 39"),(6,"40 - 49")],1),
        ("education_category","Highest Level of Education Attended",
         [(0,"No Education"),(1,"Primary"),(2,"Secondary 1"),(3,"Secondary 2")],1),
        ("s1_17","Religion",
         [(1,"Catholic"),
          (2,"Church of Jesus Christ in Madagascar (FJKM)/Malagasy Lutheran Church (FLM)/Angli"),
          (3,"Muslim"),(4,"Traditional/Animalist"),
          (5,"Fiangonana zandriny (Apokalipsy,Jesosy Mamonjy,Pentekotista,FPVM…)"),
          (6,"No religion")],1),
        ("s1_18","Religiosity",
         [(1,"Strongly religious"),(2,"Somewhat religious"),(3,"Not at all religious")],1),
        ("s1_19","Degree Religion Influences Decisions on FP",
         [(1,"Never"),(2,"Somewhat"),(3,"Often/frequently"),(4,"Always"),(99,"Don’t know (about FP)")],1),
        ("married_or_cohabiting","Marital Status",[(0,"No"),(1,"Yes")],1),
        ("s7_3","Marital Status Among Those Not Married",
         [(1,"Widowed"),(2,"Divorced"),(3,"Separated")],1),
        ("s2_1","Ever Given Birth",[(0,"No"),(1,"Yes")],1),
    ]
    after = [
        ("using_any_contraception","Currently Using Any Contraceptive Method",[(0,"No"),(1,"Yes")],1),
        ("aligned_preferred_use","Has Aligned and Preferred Contraceptive Use",[(0,"No"),(1,"Yes")],1),
        ("wishes_using_contraception",
         "Among Those Not Using, Wishes They Were Using Contraception",[(0,"No"),(1,"Yes")],1),
        ("s3_5_current","Family planning method used",
         [(5,"Injectable (regular)"),(6,"Injectable (Sayana Press)"),(7,"Implant"),
          (8,"Daily pill"),(9,"Male condom"),(11,"Emergency pill"),
          (13,"Standard Days Method"),(14,"Breastfeeding / LAM"),
          (15,"Rhythm method"),(16,"Withdrawal"),(77,"Other (Specify)")],2),
    ]

    display, numeric = [], []
    for variable, characteristic, levels, decimals in before:
        d, n = categorical_block(df, variable, characteristic, levels, decimals)
        display.extend(d); numeric.extend(n)

    for variable, characteristic in [
        ("pregnancies_topcoded_6","Total Number of Pregnancies"),
        ("live_births_topcoded_6","Number of Live Births"),
        ("living_children_topcoded_6","Number of Living Children"),
    ]:
        d, n = continuous_row(df, variable, characteristic)
        display.append(d); numeric.append(n)

    for variable, characteristic, levels, decimals in after:
        d, n = categorical_block(df, variable, characteristic, levels, decimals)
        display.extend(d); numeric.extend(n)

    out = pd.DataFrame(display)
    out.columns = [
        "Characteristic", "Level", "Drone (N=605)", "Control (N=594)",
        "Total (N=1,199)", "p-value"
    ]
    num = pd.DataFrame(numeric)
    num.insert(0, "table", "Table 1b")
    return out, num


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--data-dir", type=Path, default=Path("."))
    parser.add_argument("--facility-file", type=Path)
    parser.add_argument("--women-file", type=Path)
    parser.add_argument("--output-dir", type=Path, default=Path("output/table1_public"))
    args = parser.parse_args()

    facility_path = args.facility_file or args.data_dir / FACILITY_FILENAME
    women_path = args.women_file or args.data_dir / WOMEN_FILENAME
    args.output_dir.mkdir(parents=True, exist_ok=True)

    facility_raw = pd.read_csv(facility_path, sep="\t", low_memory=False)
    women_raw = pd.read_csv(women_path, sep="\t", low_memory=False)
    facility = prepare_facility(facility_raw)
    women = prepare_women(women_raw)

    assert len(facility) == 107
    assert facility.treatment.value_counts().to_dict() == {0:54, 1:53}
    assert len(women) == 1199
    assert women.treatment.value_counts().to_dict() == {1:605, 0:594}

    t1a, n1a = build_table_1a(facility)
    t1b, n1b = build_table_1b(women)
    numeric = pd.concat([n1a, n1b], ignore_index=True, sort=False)

    t1a.to_csv(args.output_dir / "table_1a_public.csv", index=False)
    t1b.to_csv(args.output_dir / "table_1b_public.csv", index=False)
    numeric.to_csv(args.output_dir / "table_1_numeric_long.csv", index=False)

    log = [
        "DRONE-MED Table 1 public-data replication",
        f"Facility input: {facility_path}",
        f"Women input: {women_path}",
        "Facility sample: N=107 (drone=53, control=54) after excluding consent==0",
        "Women sample: N=1,199 (drone=605, control=594)",
        "Categorical tests: Pearson chi-square without continuity correction",
        "Continuous tests: pooled-variance two-sample t test",
        "Pregnancy, live-birth, and living-child counts are top-coded at 6",
        "No private helper datasets used.",
    ]
    (args.output_dir / "table_1_run_log.txt").write_text("\n".join(log) + "\n")
    print("\n".join(log))


if __name__ == "__main__":
    main()
