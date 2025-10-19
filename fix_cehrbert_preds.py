from pathlib import Path

import polars as pl

input_path = (
    "/sc/home/robin.vandewater/datasets/meds/AUMCdb/models/mortality/in_icu/first_24h/cehrbert/first_24h/"
)
input_path = Path(input_path)
test_preds = pl.read_parquet(input_path / "test_predictions")
# test_preds = test_preds.drop("predicted_boolean_value")
test_preds = test_preds.with_columns(pl.col("predicted_boolean_value").cast(pl.Boolean))
test_preds = test_preds.with_columns(pl.col("predicted_boolean_probability").cast(pl.Float64))
test_preds.write_parquet(input_path / "test_predictions.parquet")
pl.read_parquet(input_path / "test_predictions.parquet")
