"""
DRONE-MED Madagascar: public-data Table 2 replication script.

Purpose
-------
    This script reproduces the main Table 2a ANCOVA and 2b DID estimates from public .dta files.

Inputs expected in --data-dir
-----------------------------
  drone-med_baseline_facility_audit_public.dta
  drone-med_endline_facility_audit_public.dta
  drone-med_baseline_women_public.dta
  drone-med_endline_women_public.dta

Outputs
-------
  table2_public.csv
      The recomputed model outputs for all rows generated from the public .dta
      files, including unmet need from the derived variable Unmet.

Run
-------
python code/drone_med_public_table2_replication.py \
  --data-dir data \
  --output-dir output

Dependencies: pandas, numpy, statsmodels, scipy
"""

from __future__ import annotations

import argparse
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

def read_dta(data_dir: Path, filename: str) -> pd.DataFrame:
    path = data_dir / filename
    if not path.exists():
        raise FileNotFoundError(f"Missing required input file: {path}")

    try:
        df = pd.read_stata(
            path,
            convert_categoricals=False,
            preserve_dtypes=False,
        )
    except Exception as exc:
        raise RuntimeError(f"Failed to read Stata file {path}: {exc}") from exc

    cleaned_columns = [
        str(col).replace("\ufeff", "").strip()
        for col in df.columns
    ]
    if len(set(cleaned_columns)) != len(cleaned_columns):
        raise ValueError(
            f"{filename}: cleaning header whitespace/BOM created duplicate columns."
        )

    df.columns = cleaned_columns
    df.attrs["source_filename"] = filename
    print(f"Read: {path.resolve()} ({len(df):,} rows, {len(df.columns):,} columns)")
    return df


def recode(s: pd.Series, mapping: Iterable[Tuple[Iterable[float], float]]) -> pd.Series:
    out = pd.Series(np.nan, index=s.index, dtype=float)
    for vals, val in mapping:
        out.loc[s.isin(vals)] = val
    return out


def rowmax(df: pd.DataFrame, cols: List[str]) -> pd.Series:
    return df[cols].max(axis=1, skipna=True).where(df[cols].notna().any(axis=1), np.nan)


def make_crosswalk(data_dir: Path) -> pd.DataFrame:
    fac = read_dta(data_dir, "drone-med_baseline_facility_audit_public.dta")
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
    df = read_dta(data_dir, f"drone-med_{wave}_facility_audit_public.dta")
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
    df = add_women_ids(read_dta(data_dir, f"drone-med_{wave}_women_public.dta"), cw)
    out = df[["facility_id", "respondent", "treatment", "facility_type", "district_id"]].copy()

    out[f"{prefix}39"] = recode(df["s3_1"], [([1, 2], 1), ([0], 0)])

    # OUTCOME 40: Currently Using a Modern Contraceptive Method
    # Match the original Stata logic, including Stata string-missing behavior.
    raw_s3_5 = df["s3_5"]
    s3_5_norm = (
        raw_s3_5.astype("string")
        .str.strip()
        .str.replace(r"\.0$", "", regex=True)
    )
    valid_s3_5 = raw_s3_5.notna() & s3_5_norm.notna() & s3_5_norm.ne("")

    modern = pd.Series(np.nan, index=df.index, dtype=float)
    modern.loc[valid_s3_5] = (
        ~s3_5_norm.loc[valid_s3_5].isin(["15", "16"])
    ).astype(float)

    # Stata: recode base/end40 (.=0) if !missing(s3_1)
    modern.loc[modern.isna() & df["s3_1"].notna()] = 0
    out[f"{prefix}40"] = modern

    print(
        f"{wave.capitalize()} outcome 40: "
        f"N={out[f'{prefix}40'].notna().sum():,}; "
        f"empty-string s3_5={s3_5_norm.eq('').fillna(False).sum():,}"
    )

    aligned = pd.Series(np.nan, index=df.index, dtype=float)
    aligned.loc[(df["s3_1"].isin([1, 2]) & (df["s3_3"] == 1)) | ((df["s3_1"] == 0) & (df["s3_2"] == 0))] = 1
    aligned.loc[(df["s3_1"].isin([1, 2]) & (df["s3_3"] == 0)) | ((df["s3_1"] == 0) & (df["s3_2"] == 1))] = 0
    out[f"{prefix}41"] = aligned

    # OUTCOME 42: Has Unmet Need for Contraception
    # The public .dta variable is named Unmet.
    unmet_raw = pd.to_numeric(df["Unmet"], errors="coerce")
    invalid_unmet = unmet_raw.notna() & ~unmet_raw.isin([0, 1])
    if invalid_unmet.any():
        bad = df.loc[invalid_unmet, "Unmet"].value_counts(dropna=False).head(10).to_dict()
        raise ValueError(
            f"{wave} Unmet contains non-binary nonmissing values: {bad}"
        )

    # Match the original Stata pipeline's final recode:
    #   recode UnmetCat (.=99)
    #   recode UnmetCat (1/2=1) (else=0), gen(Unmet)
    n_unmet_missing = int(unmet_raw.isna().sum())
    out[f"{prefix}42"] = unmet_raw.fillna(0).astype(float)

    print(
        f"{wave.capitalize()} outcome 42: "
        f"public Unmet missing={n_unmet_missing:,}; "
        f"pipeline-matched N={out[f'{prefix}42'].notna().sum():,}"
    )

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

    # OUTCOME 68: Disagree or Strongly Disagree Staff Did Not Have Methods
    # Match the Stata recode directly; no extra Mahanoro-only restriction.
    z = pd.Series(np.nan, index=df.index, dtype=float)
    v = df["s10_9"]
    z.loc[m & v.isin([4, 5])] = 1
    z.loc[m & v.isin([1, 2, 3])] = 0
    out[f"{prefix}68"] = z

    print(
        f"{wave.capitalize()} outcome 68: "
        f"N={out[f'{prefix}68'].notna().sum():,}"
    )

    z = pd.Series(np.nan, index=df.index, dtype=float)
    v = df["s10_10"]
    z.loc[m & v.isin([4, 5])] = 1
    z.loc[m & v.isin([1, 2, 3])] = 0
    out[f"{prefix}69"] = z

    return out


def prep_child(data_dir: Path, cw: pd.DataFrame, wave: str) -> pd.DataFrame:
    prefix = "base" if wave == "baseline" else "end"
    df = add_women_ids(read_dta(data_dir, f"drone-med_{wave}_women_public.dta"), cw)
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


def run(data_dir: Path, output_dir: Path) -> None:
    output_dir.mkdir(parents=True, exist_ok=True)
    cw = make_crosswalk(data_dir)

    datasets = {
        "facility": (prep_facility(data_dir, "baseline"), prep_facility(data_dir, "endline"), [1, 2, 3, 4, 5, 6]),
        "women": (
            prep_women(data_dir, cw, "baseline"),
            prep_women(data_dir, cw, "endline"),
            [39, 40, 41, 42, 62, 63, 64, 65, 66, 67, 68, 69],
        ),
        "children": (prep_child(data_dir, cw, "baseline"), prep_child(data_dir, cw, "endline"), [58, 59]),
    }

    pieces = []
    for _, (base, end, ids) in datasets.items():
        pieces.append(ancova(base, end, ids))
        pieces.append(did(base, end, ids))
    recomputed = pd.concat(pieces, ignore_index=True)
    recomputed = recomputed.assign(_sort=table_sort_key(recomputed)).sort_values("_sort").drop(columns="_sort")

    duplicate_rows = recomputed.duplicated(["id", "model"], keep=False)
    if duplicate_rows.any():
        raise AssertionError(
            "Duplicate outcome-model rows found:\n"
            + recomputed.loc[duplicate_rows, ["id", "model", "outcome"]].to_string(index=False)
        )

    recomputed_path = output_dir / "table2_public.csv"
    recomputed.to_csv(recomputed_path, index=False)

    print(f"Wrote: {recomputed_path}")


def main() -> None:
    parser = argparse.ArgumentParser(description="Replicate DRONE-MED Table 2 from public Dataverse .dta files.")
    parser.add_argument("--data-dir", default=".", help="Directory containing the four public Dataverse .dta files.")
    parser.add_argument("--output-dir", default=".", help="Directory where replication CSV outputs should be written.")
    args = parser.parse_args()
    run(Path(args.data_dir), Path(args.output_dir))


if __name__ == "__main__":
    main()
