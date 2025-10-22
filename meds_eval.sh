#!/bin/bash
# Base directory for datasets
export tasks=(
    "abnormal_lab/vital/hypotension/first_24h"
    "abnormal_lab/blood_chemistry/metabolic_acidosis/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
    "abnormal_lab/cbc/anemia/first_24h"
    "mortality/in_icu/first_24h"
    "readmission/general_hospital/30d"
)
export base_dir="/sc/home/robin.vandewater/datasets/meds"
export MODEL_NAME="meds_tab/tiny"
for dataset in "${datasets[@]}"; do
    export DATASET_DIR="$base_dir/$dataset"
    for TASK_NAME in "${tasks[@]}"; do
        echo "Processing task: $TASK_NAME"
        if [ "$MODEL_NAME" == "meds_tab/tiny" ]; then
            export FINETUNED_MODEL_DIR="$DATASET_DIR/models/${TASK_NAME}/${MODEL_NAME}"
            export predictions_path=
        elif [ "$MODEL_NAME" == "cehrbert" ]; then
            export FINETUNED_MODEL_DIR="$DATASET_DIR/models/${TASK_NAME}/${MODEL_NAME}/first_24h/"
        fi
        export FINETUNED_MODEL_DIR="$DATASET_DIR/models/${TASK_NAME}/${MODEL_NAME}"
        export EVALUATION_DIR="$DATASET_DIR/results/${TASK_NAME}/${MODEL_NAME}"

        # Extract results for both held_out and tuning sets
        meds-dev-evaluation predictions_path="$FINETUNED_MODEL_DIR""/results/**/best_trial/held_out_predictions.parquet" output_dir="$EVALUATION_DIR/held_out"
        meds-dev-evaluation predictions_path="$FINETUNED_MODEL_DIR""/results/**/best_trial/tuning_predictions.parquet" output_dir="$EVALUATION_DIR/tuning"
    done
done

# CEHRBERT Eval
export base_dir="/sc/home/robin.vandewater/datasets/meds"
export TASK_NAME="mortality/in_icu/first_24h"
export DATASET_DIR="$base_dir/eICU"
export MODEL_NAME="cehrbert"
# Because we need to fix schema with fix_cehrbert_preds.py
# predictions or models
for TASK_NAME in "${tasks[@]}"; do
    echo "Processing task: $TASK_NAME"
    for dataset in "${datasets[@]}"; do
        export DATASET_DIR="$base_dir/$dataset"
        export FINETUNED_MODEL_DIR=$DATASET_DIR/predictions/${TASK_NAME}/${MODEL_NAME}/predictions.parquet
        export EVALUATION_DIR=$DATASET_DIR/results/${TASK_NAME}/${MODEL_NAME}
        meds-dev-evaluation predictions_path="$FINETUNED_MODEL_DIR" output_dir="$EVALUATION_DIR/held_out"
    done
done

# GENHPF Eval
meds-dev-evaluation predictions_path="$FINETUNED_MODEL_DIR" output_dir="$EVALUATION_DIR/held_out"
export datasets=(
    "AUMCdb"
    "eICU"
    "EHRShot"
    "HIRID"
    "INSPIRE"
    "MIMIC-IV"
    "NWICU"
    "SICdb"
)
for TASK_NAME in "${tasks[@]}"; do
    echo "Processing task: $TASK_NAME"
    for dataset in "${datasets[@]}"; do
        export DATASET_DIR="$base_dir/$dataset"
        # export DATASET_DIR="$base_dir/AUMCdb"
        export MODEL_NAME="genhpf"
        export FINETUNED_MODEL_DIR="$DATASET_DIR/predictions/$TASK_NAME/$MODEL_NAME/predictions.parquet"
        export EVALUATION_DIR="$DATASET_DIR/results/${TASK_NAME}/${MODEL_NAME}"
        meds-dev-evaluation predictions_path="$FINETUNED_MODEL_DIR" output_dir="$EVALUATION_DIR/held_out"
    done
done
