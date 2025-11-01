import os

import polars as pl


def aggregate_labels(directory):
    """Walks the given directory looking for label files as parquet, then aggregates them into a single Polars
    DataFrame with added 'task' and 'split' columns.

    Args:
        directory (str): The root directory to walk.

    Returns:
        pl.DataFrame: The aggregated DataFrame from all found parquet files.
    """
    dfs = []
    for root, _dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".parquet"):
                path = os.path.join(root, file)
                # Parse task and split from path: assuming .../task/split/file.parquet
                parts = path.split("/")
                task = parts[-5] + "_" + parts[-4] + "_" + parts[-3]  # task is 3 levels up from file
                split = parts[-2]  # split is 2 levels up
                df = pl.read_parquet(path)
                df = df.with_columns(pl.lit(task).alias("task"), pl.lit(split).alias("split"))
                # print(f"Loaded {path} with shape {df.shape}, task={task}, split={split}")
                dfs.append(df)
    if dfs:
        # Concatenate all DataFrames vertically (assuming same schema)
        return pl.concat(dfs)
    else:
        return pl.DataFrame()


def process_labels():
    """Processes the aggregated labels DataFrame to convert multi-class labels into boolean labels for each
    unique value.

    Returns:
        pl.DataFrame: The processed DataFrame with boolean labels.
    """
    all_dataset_tasks = []
    for dataset in ["AUMCdb", "eICU", "EHRShot", "HIRID", "INSPIRE", "MIMIC-IV", "NWICU", "SICdb"]:
        tasks = aggregate_labels(f"/sc/home/robin.vandewater/datasets/meds/{dataset}/labels")
        # Add dataset column
        tasks = tasks.with_columns(pl.lit(dataset).alias("dataset"))
        if len(tasks) == 0 or "task" not in tasks.columns:
            continue
        tasks = (
            tasks.group_by(["task", "split", "boolean_value", "dataset"])
            .agg(pl.len())
            .sort(["dataset", "task", "split"])
        )
        all_dataset_tasks.append(tasks)
    # Concatenate all DataFrames, allowing mismatched schemas
    all_dataset_tasks = pl.concat(all_dataset_tasks, how="diagonal")
    return all_dataset_tasks


# Execute the function
all_dataset_tasks = process_labels()
all_dataset_tasks.write_parquet("all_dataset_tasks.parquet")

for item in all_dataset_tasks:
    print(item)
with pl.Config(tbl_rows=1000, tbl_cols=10, fmt_str_lengths=1000, tbl_width_chars=1000):
    # for col in all_dataset_tasks.get_column_names():
    #     if col not in ["task", "split", "boolean_value", "dataset"]:
    #         all_dataset_tasks = all_dataset_tasks.with_columns(
    #             pl.col(col).cast(pl.Datetime)
    #         )
    print(all_dataset_tasks)
