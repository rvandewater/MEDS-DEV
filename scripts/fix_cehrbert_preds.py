from pathlib import Path

import polars as pl

datasets = [
    # "AUMCdb",
    # "eICU",
    # "EHRShot",
    "HIRID",
    # "INSPIRE",
    # "MIMIC-IV",
    # "NWICU",
    # "SICdb"
]

tasks = [
    "abnormal_lab/vital/hypotension/first_24h",
    "abnormal_lab/blood_chemistry/metabolic_acidosis/first_24h",
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h",
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h",
    "abnormal_lab/cbc/leukocytosis/first_24h",
    "abnormal_lab/cbc/thrombocytopenia/first_24h",
    "abnormal_lab/cbc/anemia/first_24h",
    "mortality/in_icu/first_24h",
    "readmission/general_hospital/30d",
]

for dataset in datasets:
    for task in tasks:
        input_path = Path(
            f"/sc/home/robin.vandewater/datasets/meds/{dataset}/models/{task}/cehrbert/first_24h/"
        )
        pred_file = input_path / "test_predictions"
        out_file = input_path / "test_predictions.parquet"
        if pred_file.exists():
            try:
                test_preds = pl.read_parquet(pred_file)
                test_preds = test_preds.with_columns(
                    pl.col("predicted_boolean_value").cast(pl.Boolean),
                    pl.col("predicted_boolean_probability").cast(pl.Float64),
                )
                test_preds.write_parquet(out_file)
                print(f"Fixed and wrote: {out_file}")
            except Exception as e:
                print(f"Error processing {pred_file}: {e}")
        else:
            print(f"File not found: {pred_file}")


# input_path = (
#     f"/sc/home/robin.vandewater/datasets/meds/{dataset}/models//first_24h/cehrbert/first_24h/"
# )

# input_path = Path(input_path)
# test_preds = pl.read_parquet(input_path / "test_predictions")
# # test_preds = test_preds.drop("predicted_boolean_value")
# test_preds = test_preds.with_columns(pl.col("predicted_boolean_value").cast(pl.Boolean))
# # test_preds = test_preds.drop("predicted_boolean_value")
# test_preds = test_preds.with_columns(pl.col("predicted_boolean_probability").cast(pl.Float64))
# test_preds.write_parquet(input_path / "test_predictions.parquet")
# pl.read_parquet(input_path / "test_predictions.parquet")
