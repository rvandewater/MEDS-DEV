import argparse
import glob
import json
import os

import polars as pl


# base_dir = "/sc/home/robin.vandewater/datasets/meds/"
# # base_dir = "/sc/arion/projects/hpims-hpi/projects/foundation_models_ehr/ehrshot/meds_data/
# # split/models/aggregated_results/mount_sinai_adjusted/"
def aggregate_results(base_dir: str, output_path: str):
    results = []
    # Use glob to find all results.json files recursively
    for json_path in glob.glob(f"{base_dir}/**/results.json", recursive=True):
        print(f"Found results.json at {json_path}")
        with open(json_path) as f:
            data = json.load(f)
        # Use relative path for uniqueness
        rel_dir = os.path.relpath(os.path.dirname(json_path), base_dir)
        row = {"dir": rel_dir}
        for group in ["samples_equally_weighted", "subjects_equally_weighted"]:
            for metric, value in data.get(group, {}).items():
                row[f"{group}_{metric}"] = value
        results.append(row)

    df = pl.DataFrame(results)
    with pl.Config(tbl_rows=100, tbl_cols=10, fmt_str_lengths=100, tbl_width_chars=1000):
        print(df)
    # output_path = "/sc/home/robin.vandewater/datasets/meds/aggregated_meds_eval_results.parquet"
    # output_path = "/sc/arion/projects/hpims-hpi/projects/foundation_models_ehr/cohorts/meds_debug
    # /full_omop_25_04_29/MEDS_cohort/"
    df.write_parquet(output_path)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--base_dir", type=str, required=False, help="Base directory to search for results.json files."
    )
    parser.add_argument(
        "--output_path", type=str, required=False, help="Output path for the aggregated results parquet file."
    )
    args = parser.parse_args()
    if args.base_dir is None:
        raise ValueError("base_dir must be specified.")
    if args.output_path is None:
        raise ValueError("output_path must be specified.")
    aggregate_results(args.base_dir, args.output_path)


if __name__ == "__main__":
    main()
