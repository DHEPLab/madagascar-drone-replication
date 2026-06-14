#!/usr/bin/env python3
"""
DRONE-MED Madagascar: public-data Table 2 replication / QA script.

Purpose
-------
This script checks whether the public UNC Dataverse .tab files can reproduce the
main Table 2 ANCOVA and DID estimates. It generates the former helper data
internally from the public files:
  - facility_id / district_id / facility_type / treatment crosswalk
  - endline women facility_id from hhid-derived fokontany_id

Important limitations documented by the replication check
---------------------------------------------------------
1. Unmet need for contraception (outcome 42) is not regenerated here because the
   public women .tab files do not include the exact date fields used by the
   original Stata unmet-need algorithm. Add a public-safe derived variable
   (base42/end42 or unmet_need) to reproduce this row exactly.
2. To match the current Table 2 output, the perceived availability of family
   planning methods outcome (outcome 68) applies the legacy Mahanoro-only
   treatment-arm restriction in both baseline and endline. This should be
   confirmed against the intended ITT specification.
3. Child outcome model estimates match Table 2, but the attached table's ANCOVA
   baseline-control means use a slightly different display denominator than the
   model-recomputed public-data denominator. This affects only the display
   baseline mean and percent-of-baseline columns for the two child ANCOVA rows.

Inputs expected in --data-dir
-----------------------------
  drone-med_baseline_facility_audit_public.tab
  drone-med_endline_facility_audit_public.tab
  drone-med_baseline_women_public.tab
  drone-med_endline_women_public.tab

Outputs
-------
  table2_public_recomputed_core.csv
      The recomputed model outputs for all rows that can be generated from the
      public .tab files, excluding unmet need.

  table2_public_validation.csv
      A row-by-row comparison to the current attached Table 2 values, rounded to
      the table precision. Includes the unmet-need rows as "not reproducible from
      current public tabs" and flags the child ANCOVA baseline-mean display issue.

Dependencies: pandas, numpy, statsmodels, scipy
"""

from __future__ import annotations

import argparse
import os
import re
from pathlib import Path
from typing import Dict, Iterable, List, Tuple

import numpy as np
import pandas as pd
import statsmodels.api as sm
from scipy import stats


OUTCOME_LABELS: Dict[int, str] = {
    1: "Out of Stock of Any Vaccine at Time of Survey",
    2: "Out of Stock of Malaria Tests at Time of Survey",
    3: "Out of Stock of Malaria Tests in the 3 Months Before Survey",
    4: "Out of Stock of Antimalarial Medicine at Time of Survey",
    5: "Out of Stock of Any Contraceptive Method at Time of Survey",
    6: "Out of Stock of Any Contraceptive Method in the 3 Months Before Survey",
    39: "Currently Using Any Contraceptive Method",
    40: "Currently Using a Modern Contraceptive Method",
    41: "Has Aligned and Preferred Contraceptive Use",
    42: "Has Unmet Need for Contraception",
    58: "Among Children with Fever in Last Two Weeks, Pct Who Had Blood Taken",
    59: "Among Children with Fever in Last Two Weeks, Pct Diagnosed with Malaria",
    62: "Strongly Agree Staff Was Friendly",
    63: "Strongly Agree Staff Gave All Information Needed",
    64: "Strongly Agree Staff Provided High Quality Services",
    65: "Strongly Agree Staff Ensured Privacy",
    66: "Strongly Agree Staff Involved Me in Decisions About My Care",
    67: "Disagree or Strongly Disagree I Had to Wait a Long Time to Receive Care",
    68: "Disagree or Strongly Disagree Staff Did Not Have Methods",
    69: "Disagree or Strongly Disagree Staff Did Not Have Vaccines",
}

FAMILY_BY_ID: Dict[int, str] = {
    **{i: "Facility Survey Outcomes" for i in [1, 2, 3, 4, 5, 6]},
    **{i: "Women Survey Outcomes" for i in [39, 40, 41, 42, 62, 63, 64, 65, 66, 67, 68, 69]},
    **{i: "Children's Outcomes" for i in [58, 59]},
}

TABLE_ORDER = [39, 40, 41, 42, 62, 63, 64, 65, 66, 67, 68, 69, 1, 2, 3, 4, 5, 6, 58, 59]

# Current attached Table 2 values, to displayed precision, for QA comparison.
TARGET_DISPLAY_ROWS = [
    # id, model, effect, se, p, n, baseline mean, percent
    (39, "ANCOVA", 0.018, 0.024, 0.464, 2879, 0.458, 3.924),
    (40, "ANCOVA", 0.021, 0.024, 0.398, 2879, 0.457, 4.507),
    (41, "ANCOVA", 0.007, 0.015, 0.628, 2871, 0.830, 0.873),
    (42, "ANCOVA", -0.004, 0.012, 0.740, 3377, 0.136, -2.861),
    (62, "ANCOVA", 0.050, 0.037, 0.177, 2616, 0.582, 8.658),
    (63, "ANCOVA", -0.011, 0.036, 0.767, 2616, 0.468, -2.255),
    (64, "ANCOVA", 0.017, 0.032, 0.595, 2616, 0.353, 4.851),
    (65, "ANCOVA", 0.034, 0.035, 0.339, 2616, 0.460, 7.282),
    (66, "ANCOVA", 0.017, 0.036, 0.634, 2616, 0.374, 4.553),
    (67, "ANCOVA", 0.020, 0.007, 0.006, 2616, 0.015, 130.226),
    (68, "ANCOVA", -0.044, 0.070, 0.535, 1306, 0.816, -5.374),
    (69, "ANCOVA", -0.032, 0.026, 0.213, 2214, 0.882, -3.659),
    (1, "ANCOVA", 0.011, 0.092, 0.906, 83, 0.523, 2.083),
    (2, "ANCOVA", -0.075, 0.047, 0.111, 107, 0.037, -203.755),
    (3, "ANCOVA", -0.015, 0.039, 0.701, 98, 0.038, -38.871),
    (4, "ANCOVA", -0.036, 0.038, 0.356, 107, 0.093, -38.424),
    (5, "ANCOVA", 0.018, 0.055, 0.748, 107, 0.685, 2.593),
    (6, "ANCOVA", -0.155, 0.096, 0.111, 89, 0.549, -28.183),
    (58, "ANCOVA", -0.057, 0.059, 0.332, 362, 0.611, -9.373),
    (59, "ANCOVA", -0.090, 0.058, 0.123, 362, 0.400, -22.604),
    (39, "DID", -0.005, 0.035, 0.894, 3890, 0.465, -1.009),
    (40, "DID", 0.000, 0.036, 0.999, 3890, 0.462, -0.006),
    (41, "DID", 0.061, 0.029, 0.039, 3881, 0.827, 7.411),
    (42, "DID", 0.006, 0.021, 0.768, 4576, 0.136, 4.459),
    (62, "DID", 0.104, 0.061, 0.091, 3559, 0.587, 17.745),
    (63, "DID", 0.038, 0.057, 0.513, 3559, 0.472, 7.978),
    (64, "DID", 0.048, 0.053, 0.366, 3559, 0.355, 13.577),
    (65, "DID", 0.083, 0.052, 0.115, 3559, 0.461, 18.019),
    (66, "DID", 0.040, 0.050, 0.422, 3559, 0.376, 10.684),
    (67, "DID", 0.018, 0.011, 0.124, 3559, 0.017, 105.589),
    (68, "DID", -0.055, 0.084, 0.512, 1787, 0.808, -6.866),
    (69, "DID", 0.010, 0.037, 0.781, 3000, 0.883, 1.174),
    (1, "DID", -0.048, 0.148, 0.747, 178, 0.523, -9.178),
    (2, "DID", -0.055, 0.057, 0.336, 216, 0.037, -149.057),
    (3, "DID", -0.148, 0.066, 0.027, 207, 0.038, -385.742),
    (4, "DID", -0.057, 0.074, 0.441, 216, 0.093, -61.887),
    (5, "DID", 0.079, 0.110, 0.471, 216, 0.685, 11.576),
    (6, "DID", -0.129, 0.126, 0.308, 194, 0.549, -23.529),
    (58, "DID", 0.193, 0.093, 0.039, 626, 0.596, 32.486),
    (59, "DID", 0.130, 0.094, 0.171, 626, 0.404, 32.136),
]


def read_tab(data_dir: Path, filename: str) -> pd.DataFrame:
    path = data_dir / filename
    if not path.exists():
        raise FileNotFoundError(f"Missing required input file: {path}")
    return pd.read_csv(path, sep="\t", low_memory=False)


def recode(s: pd.Series, mapping: Iterable[Tuple[Iterable[float], float]]) -> pd.Series:
    out = pd.Series(np.nan, index=s.index, dtype=float)
    for vals, val in mapping:
        out.loc[s.isin(vals)] = val
    return out


def rowmax(df: pd.DataFrame, cols: List[str]) -> pd.Series:
    return df[cols].max(axis=1, skipna=True).where(df[cols].notna().any(axis=1), np.nan)


def make_crosswalk(data_dir: Path) -> pd.DataFrame:
    fac = read_tab(data_dir, "drone-med_baseline_facility_audit_public.tab")
    cw = fac[["facility_id", "facility_type", "region", "district", "treatment"]].copy()
    cw = cw.rename(columns={"region": "region_id", "district": "district_id"})
    cw["commune_id"] = (cw["facility_id"] % 100000 // 1000).astype(int)
    cw["fokontany_id"] = (cw["facility_id"] % 1000).astype(int)
    cw = cw.drop_duplicates("facility_id")
    assert not cw["facility_id"].duplicated().any()
    assert not cw["fokontany_id"].duplicated().any()
    return cw


def strata_key(df: pd.DataFrame) -> pd.Series:
    # String keys make dummy construction deterministic and independent of numeric labels.
    return pd.Series(list(zip(df["district_id"], df["facility_type"])), index=df.index).astype(str)


def add_women_ids(df: pd.DataFrame, cw: pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    if "facility_id" not in df.columns:
        # Public endline women file: recover the cluster/fokontany identifier from hhid.
        df["fokontany_id"] = np.floor(df["hhid"] / 1000).astype(int)
        df = df.merge(cw[["fokontany_id", "facility_id", "facility_type", "district_id"]],
                      on="fokontany_id", how="left")
        if df["facility_id"].isna().any():
            raise RuntimeError("Failed to recover facility_id for one or more endline women records.")
    else:
        df = df.merge(cw[["facility_id", "facility_type", "district_id"]],
                      on="facility_id", how="left", suffixes=("", "_cw"))
        if "facility_type_cw" in df:
            df["facility_type"] = df["facility_type_cw"]
        if "district_id_cw" in df:
            df["district_id"] = df["district_id_cw"]
    return df


def prep_facility(data_dir: Path, wave: str) -> pd.DataFrame:
    prefix = "base" if wave == "baseline" else "end"
    df = read_tab(data_dir, f"drone-med_{wave}_facility_audit_public.tab")
    df = df[df["consent"] != 0].copy()
    out = df[["facility_id", "treatment", "facility_type", "district"]].rename(columns={"district": "district_id"}).copy()

    for i, letter in zip(range(1, 12), "abcdefghijk"):
        out[f"{prefix}01{letter}"] = recode(df[f"s6_01_{i}"], [([1, 2, 4], 0), ([3], 1)])
    out[f"{prefix}01"] = rowmax(out, [f"{prefix}01{x}" for x in "defghijk"])
    out.loc[df["s11_14"] == 0, [c for c in out.columns if c.startswith(f"{prefix}01")]] = np.nan

    out[f"{prefix}02"] = recode(df["s4_06"], [([1, 2], 0), ([3], 1)])
    out[f"{prefix}03"] = df["s4_07"].astype(float)
    out[f"{prefix}04"] = recode(df["s4_01"], [([1, 2], 0), ([3], 1)])

    # Public method-code mapping used to reproduce Table 2 main contraceptive-stock row:
    # 3 implant, 5 Depo Provera, 6 Sayana Press, 7 pill, 9 male condom.
    fp_codes = [3, 5, 6, 7, 9]
    for j, code in enumerate(fp_codes, start=1):
        out[f"{prefix}05_{j}"] = np.nan
        for slot in range(1, 9):
            method_col = f"s2_20_stock_fp_{slot}"
            status_col = f"s2_20_{slot}"
            if method_col in df.columns and status_col in df.columns:
                mask = df[method_col] == code
                out.loc[mask, f"{prefix}05_{j}"] = (df.loc[mask, status_col] == 3).astype(float)
        out[f"{prefix}05_{j}"] = out[f"{prefix}05_{j}"].fillna(0)
    out[f"{prefix}05"] = rowmax(out, [f"{prefix}05_{j}" for j in range(1, 6)])

    prior_stock_cols = [c for c in df.columns if re.fullmatch(r"s2_21_\d+", c)]
    out[f"{prefix}06"] = rowmax(df, prior_stock_cols)

    keep = ["facility_id", "treatment", "district_id", "facility_type"] + [f"{prefix}{i:02d}" for i in range(1, 7)]
    return out[keep].copy()


def prep_women(data_dir: Path, cw: pd.DataFrame, wave: str) -> pd.DataFrame:
    prefix = "base" if wave == "baseline" else "end"
    df = add_women_ids(read_tab(data_dir, f"drone-med_{wave}_women_public.tab"), cw)
    out = df[["facility_id", "respondent", "treatment", "facility_type", "district_id"]].copy()

    out[f"{prefix}39"] = recode(df["s3_1"], [([1, 2], 1), ([0], 0)])

    modern = pd.Series(np.nan, index=df.index, dtype=float)
    s = df["s3_5"].astype("object")
    modern.loc[s.notna()] = (~s.loc[s.notna()].astype(str).isin(["15", "16"])).astype(float)
    modern.loc[modern.isna() & df["s3_1"].notna()] = 0
    out[f"{prefix}40"] = modern

    aligned = pd.Series(np.nan, index=df.index, dtype=float)
    aligned.loc[(df["s3_1"].isin([1, 2]) & (df["s3_3"] == 1)) | ((df["s3_1"] == 0) & (df["s3_2"] == 0))] = 1
    aligned.loc[(df["s3_1"].isin([1, 2]) & (df["s3_3"] == 0)) | ((df["s3_1"] == 0) & (df["s3_2"] == 1))] = 0
    out[f"{prefix}41"] = aligned

    # Outcome 42 intentionally not generated: public files lack exact date elements.

    for num, col in [(62, "s10_2"), (63, "s10_3"), (64, "s10_4"), (65, "s10_5"), (66, "s10_6")]:
        z = pd.Series(np.nan, index=df.index, dtype=float)
        m = df["s10_1"] == 1
        v = df[col]
        z.loc[m & (v == 1)] = 1
        z.loc[m & (v.isin([2, 3, 4, 5]))] = 0
        out[f"{prefix}{num}"] = z

    z = pd.Series(np.nan, index=df.index, dtype=float)
    m = df["s10_1"] == 1
    v = df["s10_7"]
    z.loc[m & v.isin([4, 5])] = 1
    z.loc[m & v.isin([1, 2, 3])] = 0
    out[f"{prefix}67"] = z

    z = pd.Series(np.nan, index=df.index, dtype=float)
    v = df["s10_9"]
    z.loc[m & v.isin([4, 5])] = 1
    z.loc[m & v.isin([1, 2, 3])] = 0
    # Legacy Mahanoro-only treatment-arm restriction needed to match current Table 2.
    z.loc[(df["treatment"] == 1) & (out["district_id"] != 3)] = np.nan
    out[f"{prefix}68"] = z

    z = pd.Series(np.nan, index=df.index, dtype=float)
    v = df["s10_10"]
    z.loc[m & v.isin([4, 5])] = 1
    z.loc[m & v.isin([1, 2, 3])] = 0
    out[f"{prefix}69"] = z

    return out


def prep_child(data_dir: Path, cw: pd.DataFrame, wave: str) -> pd.DataFrame:
    prefix = "base" if wave == "baseline" else "end"
    df = add_women_ids(read_tab(data_dir, f"drone-med_{wave}_women_public.tab"), cw)
    child_nums = sorted({int(c.split("_")[-1]) for c in df.columns if c.startswith("s6_10_") and c.split("_")[-1].isdigit()})

    rows = []
    for n in child_nums:
        tmp = df[["facility_id", "respondent", "treatment", "facility_type", "district_id"]].copy()
        tmp["s6_10"] = df[f"s6_10_{n}"]
        tmp["s6_12"] = df[f"s6_12_{n}"]
        rows.append(tmp)
    long = pd.concat(rows, ignore_index=True)
    long = long[long["s6_10"].notna()].copy()

    out = long[["facility_id", "respondent", "treatment", "facility_type", "district_id"]].copy()
    out[f"{prefix}58"] = np.where(long["s6_10"] == 1, 1, np.where(long["s6_10"].isin([0, 99]), 0, np.nan))
    out[f"{prefix}59"] = np.where(long["s6_12"] == 1, 1, np.where(long["s6_12"].isin([0, 99, -999]), 0, np.nan))
    return out


def regress_cluster(y: pd.Series, X: pd.DataFrame, cluster: pd.Series) -> Tuple[sm.regression.linear_model.RegressionResultsWrapper, pd.DataFrame]:
    data = pd.concat([y.rename("y"), X, cluster.rename("cluster")], axis=1).dropna()
    Xv = data.drop(columns=["y", "cluster"]).astype(float)
    # Mimic Stata behavior by dropping all-zero dummy columns in the estimation sample.
    zero_cols = [c for c in Xv.columns if c != "const" and np.isclose(Xv[c].abs().sum(), 0)]
    if zero_cols:
        Xv = Xv.drop(columns=zero_cols)
    result = sm.OLS(data["y"].astype(float), Xv).fit(
        cov_type="cluster",
        cov_kwds={"groups": data["cluster"], "use_correction": True},
    )
    return result, data


def ancova(base: pd.DataFrame, end: pd.DataFrame, outcome_ids: Iterable[int]) -> pd.DataFrame:
    b = base.copy()
    b["strata"] = pd.factorize(strata_key(b), sort=True)[0] + 1
    basevars = []
    for oid in outcome_ids:
        suffix = f"{oid:02d}" if oid < 10 else str(oid)
        if f"base{suffix}" in b.columns:
            basevars.append(f"base{suffix}")
    basebar = b.groupby(["facility_id", "strata", "treatment"], as_index=False)[basevars].mean()
    basebar = basebar.rename(columns={v: "basebar" + v.replace("base", "") for v in basevars})
    df = end.merge(basebar, on="facility_id", how="left", suffixes=("", "_base"))

    rows = []
    for oid in outcome_ids:
        suffix = f"{oid:02d}" if oid < 10 else str(oid)
        endvar = f"end{suffix}"
        basevar = f"basebar{suffix}"
        if endvar not in df.columns or basevar not in df.columns:
            continue
        sub = df[["facility_id", "treatment", "strata", endvar, basevar]].copy()
        X = pd.DataFrame({"const": 1.0, "treatment": sub["treatment"].astype(float), basevar: sub[basevar].astype(float)})
        dummies = pd.get_dummies(sub["strata"].astype("Int64"), drop_first=True, dtype=float, prefix="strata")
        X = pd.concat([X.reset_index(drop=True), dummies.reset_index(drop=True)], axis=1)
        result, used = regress_cluster(sub[endvar].reset_index(drop=True), X, sub["facility_id"].reset_index(drop=True))
        coef = float(result.params["treatment"])
        se = float(result.bse["treatment"])
        G = int(used["cluster"].nunique())
        p = float(2 * stats.t.sf(abs(coef / se), G - 1))
        baseline_mean = float(df.loc[df["treatment"] == 0, basevar].mean())
        rows.append(make_row(oid, "ANCOVA", coef, se, p, int(result.nobs), baseline_mean))
    return pd.DataFrame(rows)


def did(base: pd.DataFrame, end: pd.DataFrame, outcome_ids: Iterable[int]) -> pd.DataFrame:
    b = base.copy(); b["endline"] = 0
    e = end.copy(); e["endline"] = 1
    stack = pd.concat([b, e], ignore_index=True, sort=False)
    rows = []
    for oid in outcome_ids:
        suffix = f"{oid:02d}" if oid < 10 else str(oid)
        basevar = f"base{suffix}"
        endvar = f"end{suffix}"
        if basevar not in stack.columns or endvar not in stack.columns:
            continue
        df = stack[["facility_id", "treatment", "district_id", "facility_type", "endline", basevar, endvar]].copy()
        df["y"] = np.where(df["endline"] == 0, df[basevar], df[endvar])
        X = pd.DataFrame({
            "const": 1.0,
            "treatment": df["treatment"].astype(float),
            "endline": df["endline"].astype(float),
        })
        X["interaction"] = X["treatment"] * X["endline"]
        dummies = pd.get_dummies(strata_key(df), drop_first=True, dtype=float, prefix="strata")
        X = pd.concat([X.reset_index(drop=True), dummies.reset_index(drop=True)], axis=1)
        result, used = regress_cluster(df["y"].reset_index(drop=True), X, df["facility_id"].reset_index(drop=True))
        coef = float(result.params["interaction"])
        se = float(result.bse["interaction"])
        G = int(used["cluster"].nunique())
        p = float(2 * stats.t.sf(abs(coef / se), G - 1))
        baseline_mean = float(df.loc[(df["endline"] == 0) & (df["treatment"] == 0), "y"].mean())
        rows.append(make_row(oid, "DID", coef, se, p, int(result.nobs), baseline_mean))
    return pd.DataFrame(rows)


def make_row(oid: int, model: str, effect: float, se: float, p: float, n: int, baseline_mean: float) -> Dict[str, object]:
    return {
        "id": oid,
        "family": FAMILY_BY_ID[oid],
        "outcome": OUTCOME_LABELS[oid],
        "model": model,
        "effect_size": effect,
        "standard_error": se,
        "p_value": p,
        "observations": n,
        "baseline_control_mean": baseline_mean,
        "effect_pct_baseline_control_mean": effect / baseline_mean * 100 if baseline_mean not in [0, np.nan] else np.nan,
    }


def table_sort_key(df: pd.DataFrame) -> pd.Series:
    order = {oid: i for i, oid in enumerate(TABLE_ORDER)}
    model_order = {"ANCOVA": 0, "DID": 1}
    return df["model"].map(model_order) * 100 + df["id"].map(order)


def target_display_df() -> pd.DataFrame:
    cols = ["id", "model", "target_effect", "target_se", "target_p", "target_n", "target_baseline_mean", "target_pct"]
    t = pd.DataFrame(TARGET_DISPLAY_ROWS, columns=cols)
    t["family"] = t["id"].map(FAMILY_BY_ID)
    t["outcome"] = t["id"].map(OUTCOME_LABELS)
    return t


def validate_against_display(recomputed: pd.DataFrame) -> pd.DataFrame:
    target = target_display_df()
    v = target.merge(recomputed, on=["id", "model", "family", "outcome"], how="left")

    for col in ["effect_size", "standard_error", "p_value", "baseline_control_mean", "effect_pct_baseline_control_mean"]:
        v[f"{col}_display"] = v[col].round(3)
    v["observations_display"] = v["observations"]

    v["effect_match_3dp"] = v["effect_size_display"].eq(v["target_effect"])
    v["se_match_3dp"] = v["standard_error_display"].eq(v["target_se"])
    v["p_match_3dp"] = v["p_value_display"].eq(v["target_p"])
    v["n_match"] = v["observations_display"].eq(v["target_n"])
    v["baseline_mean_match_3dp"] = v["baseline_control_mean_display"].eq(v["target_baseline_mean"])
    v["pct_match_3dp"] = v["effect_pct_baseline_control_mean_display"].eq(v["target_pct"])

    v["status"] = "matches Table 2 at displayed precision"
    v.loc[v["id"].eq(42), "status"] = "cannot regenerate from current public tabs: exact unmet-need date inputs are absent"
    v.loc[v["id"].isin([58, 59]) & v["model"].eq("ANCOVA"), "status"] = (
        "model estimate matches; baseline mean/percent display denominator differs"
    )

    # Flag any other mismatch.
    match_cols = ["effect_match_3dp", "se_match_3dp", "p_match_3dp", "n_match"]
    main_model_match = v[match_cols].all(axis=1)
    v.loc[~main_model_match & ~v["id"].eq(42), "status"] = "model estimate mismatch: investigate"

    sort = table_sort_key(v.rename(columns={"model": "model"}))
    return v.assign(_sort=sort).sort_values("_sort").drop(columns="_sort")


def run(data_dir: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    cw = make_crosswalk(data_dir)

    datasets = {
        "facility": (prep_facility(data_dir, "baseline"), prep_facility(data_dir, "endline"), [1, 2, 3, 4, 5, 6]),
        "women": (prep_women(data_dir, cw, "baseline"), prep_women(data_dir, cw, "endline"), [39, 40, 41, 62, 63, 64, 65, 66, 67, 68, 69]),
        "children": (prep_child(data_dir, cw, "baseline"), prep_child(data_dir, cw, "endline"), [58, 59]),
    }

    pieces = []
    for _, (base, end, ids) in datasets.items():
        pieces.append(ancova(base, end, ids))
        pieces.append(did(base, end, ids))
    recomputed = pd.concat(pieces, ignore_index=True)
    recomputed = recomputed.assign(_sort=table_sort_key(recomputed)).sort_values("_sort").drop(columns="_sort")

    recomputed_path = output_dir / "table2_public_recomputed_core.csv"
    recomputed.to_csv(recomputed_path, index=False)

    validation = validate_against_display(recomputed)
    validation_path = output_dir / "table2_public_validation.csv"
    validation.to_csv(validation_path, index=False)

    # Human-readable summary.
    print(f"Wrote: {recomputed_path}")
    print(f"Wrote: {validation_path}")
    print("\nValidation status counts:")
    print(validation["status"].value_counts(dropna=False).to_string())
    print("\nRows requiring author/GRA confirmation:")
    print(validation.loc[validation["status"] != "matches Table 2 at displayed precision",
                         ["id", "model", "outcome", "status"]].to_string(index=False))


def main() -> None:
    parser = argparse.ArgumentParser(description="Replicate DRONE-MED Table 2 from public Dataverse .tab files.")
    parser.add_argument("--data-dir", default=".", help="Directory containing the four public Dataverse .tab files.")
    parser.add_argument("--output-dir", default=".", help="Directory where replication CSV outputs should be written.")
    args = parser.parse_args()
    run(Path(args.data_dir), Path(args.output_dir))


if __name__ == "__main__":
    main()
