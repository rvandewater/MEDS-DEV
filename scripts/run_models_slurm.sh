#!/bin/bash
#SBATCH --partition=gpu-batch # -p
#SBATCH --cpus-per-task=8 # -c
#SBATCH --mem=100gb
#SBATCH --gpus=1
########## SBATCH --gpus=a40:1
#SBATCH --output=logs/%x_%j.log # %x is job-name, %j is job id
#SBATCH --account=sci-lippert
#SBATCH --time=96:00:00 # -t
#SBATCH -C 'GPU_SKU:A40|GPU_SKU:V100'
#SBATCH --shell=/bin/bash

# run with: sbatch run_models_slurm.sh cehrbert HIRID MIMIC-IV

# Initialize conda:
# eval "$(conda shell.bash hook)"

# Initialize conda - use the correct path to conda.sh

# shellcheck disable=SC1091
# source /sc/home/robin.vandewater/conda3/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"

cd ~/projects/MEDS_DEV_NEW || exit
conda activate meds_dev_311

# Verify conda activation
if [ -z "$CONDA_DEFAULT_ENV" ]; then
    echo "Error: Failed to activate conda environment"
    exit 1
fi

export MODEL_NAME="meds_tab/tiny"
# export MODEL_NAME="genhpf"
# export MODEL_NAME="cehrbert"
AVAILABLE_MODELS=("meds_tab/tiny" "cehrbert" "genhpf")

# Validate and parse arguments
if [ "$#" -lt 2 ]; then
    echo "Usage: $0 <MODEL_NAME> <DATASET_1> [<DATASET_2> ...]"
    exit 1
fi

export MODEL_NAME=$1
if [[ ! " ${AVAILABLE_MODELS[*]} " =~ ${MODEL_NAME} ]]; then
    echo "Error: Invalid MODEL_NAME '${MODEL_NAME}'. Available models are: ${AVAILABLE_MODELS[*]}"
    exit 1
fi
shift # Remove MODEL_NAME from arguments
AVAILABLE_DATASETS=("AUMCdb" "eICU" "EHRShot" "HIRID" "INSPIRE" "MIMIC-IV" "NWICU" "SICdb")
# Validate input datasets
export datasets=()
for dataset in "$@"; do
    if [[ " ${AVAILABLE_DATASETS[*]} " =~ ${dataset} ]]; then
        datasets+=("$dataset")
    else
        echo "Error: Invalid dataset '${dataset}'. Available datasets are: ${AVAILABLE_DATASETS[*]}"
        exit 1
    fi
done
export base_dir="/sc/home/robin.vandewater/datasets/meds"
export tasks=(
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "abnormal_lab/blood_chemistry/metabolic_acidosis/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "abnormal_lab/blood_chemistry/hyperkalemia/first_24h"
    "abnormal_lab/blood_chemistry/hypoglycemia/first_24h"
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
    "mortality/in_icu/first_24h"
    "readmission/general_hospital/30d"

)
# Common debug print
debug_print_env() {
    echo "===== DEBUG ENV ====="
    echo "MODEL_NAME=$MODEL_NAME"
    echo "DATASET_NAME=$DATASET_NAME"
    echo "DATASET_DIR=$DATASET_DIR"
    echo "PRETRAINED_MODEL_DIR=$PRETRAINED_MODEL_DIR"
    echo "TASK_NAME=$TASK_NAME"
    echo "LABELS_DIR=$LABELS_DIR"
    echo "FINETUNED_MODEL_DIR=$FINETUNED_MODEL_DIR"
    echo "PREDICTIONS_DIR=$PREDICTIONS_DIR"
    echo "OUTPUT_DIR=$OUTPUT_DIR"
    echo "EVALUATION_DIR=$EVALUATION_DIR"
    echo "====================="
}
for dataset in "${datasets[@]}"; do
    export DATASET_NAME=$dataset
    export DATASET_DIR="$base_dir/$dataset"
    if [ "$MODEL_NAME" = "cehrbert" ]; then
        # First pretrain the model
        export PRETRAINED_MODEL_DIR="$DATASET_DIR/models/$MODEL_NAME"
        meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" mode=train dataset_type=unsupervised output_dir="$PRETRAINED_MODEL_DIR"
        for task in "${tasks[@]}"; do
            # Fine-tune the model
            echo "Processing dataset: $DATASET_NAME, task: $task, model: $MODEL_NAME"
            export TASK_NAME=$task
            export LABELS_DIR="$DATASET_DIR/labels/$task"
            if [ ! -d "$LABELS_DIR" ]; then
                echo "Skipping: $LABELS_DIR does not exist"
                continue
            fi
            export FINETUNED_MODEL_DIR="$DATASET_DIR/models/$TASK_NAME/$MODEL_NAME"
            export PREDICTIONS_DIR="$DATASET_DIR/predictions/$TASK_NAME/$MODEL_NAME"
            debug_print_env
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=train dataset_type=supervised output_dir="$FINETUNED_MODEL_DIR" model_initialization_dir="$PRETRAINED_MODEL_DIR"
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=predict dataset_type=supervised split=held_out output_dir="$PREDICTIONS_DIR" model_initialization_dir="$FINETUNED_MODEL_DIR"
            echo "Completed dataset: $DATASET_NAME, task: $task"
        done
    elif [ "$MODEL_NAME" = "genhpf" ]; then
        # First set pretrained model dir
        for task in "${tasks[@]}"; do
            echo "Processing dataset: $DATASET_NAME, task: $task, model: $MODEL_NAME"
            export TASK_NAME=$task
            export LABELS_DIR="$DATASET_DIR/labels/$task"
            if [ ! -d "$LABELS_DIR" ]; then
                echo "Skipping: $LABELS_DIR does not exist"
                continue
            fi
            export OUTPUT_DIR="$DATASET_DIR/models/$TASK_NAME/$MODEL_NAME"
            export PREDICTIONS_DIR="$DATASET_DIR/predictions/$TASK_NAME/$MODEL_NAME"
            export FINETUNED_MODEL_DIR="$DATASET_DIR/models/$TASK_NAME/$MODEL_NAME"
            export EVALUATION_DIR="$DATASET_DIR/results/${TASK_NAME}/${MODEL_NAME}"
            echo "Cleaning up directories before training..."
            rm -rf "$OUTPUT_DIR"
            rm -rf "$FINETUNED_MODEL_DIR"
            rm -rf "$PREDICTIONS_DIR"
            # Train the model (supervised)
            debug_print_env
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=train dataset_type=supervised output_dir="$OUTPUT_DIR" model_initialization_dir="$FINETUNED_MODEL_DIR"
            # Predict with the trained model
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=predict dataset_type=supervised split=held_out output_dir="$PREDICTIONS_DIR" model_initialization_dir="$FINETUNED_MODEL_DIR"
            rm -rf "$EVALUATION_DIR"
            meds-dev-evaluation predictions_path="$PREDICTIONS_DIR/predictions.parquet" output_dir="$EVALUATION_DIR/held_out"
            echo "Completed dataset: $DATASET_NAME, task: $task"
        done
    else
        for task in "${tasks[@]}"; do
            echo "Processing dataset: $DATASET_NAME, task: $task"
            export TASK_NAME=$task
            export LABELS_DIR="$DATASET_DIR/labels/$task"
            export FINETUNED_MODEL_DIR="$DATASET_DIR/models/$TASK_NAME/$MODEL_NAME"
            export PREDICTIONS_DIR="$DATASET_DIR/predictions/$TASK_NAME/$MODEL_NAME"
            debug_print_env
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=train dataset_type=supervised output_dir="$FINETUNED_MODEL_DIR" model_initialization_dir="$PRETRAINED_MODEL_DIR"
            echo "Completed dataset: $DATASET_NAME, task: $task"
        done
    fi
done
