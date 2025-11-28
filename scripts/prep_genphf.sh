#!/bin/bash
#SBATCH --partition=cpu # -p
#SBATCH --cpus-per-task=32 # -c
#SBATCH --mem=300gb
#SBATCH --output=logs/%x_%j.log # %x is job-name, %j is job id
#SBATCH --account=sci-lippert
#SBATCH --time=168:00:00 # -t
#SBATCH -C 'ARCH:X86'

# run with: sbatch run_models_slurm.sh cehrbert HIRID MIMIC-IV

# Initialize conda:
# eval "$(conda shell.bash hook)"

# Initialize conda - use the correct path to conda.sh
# shellcheck source=supported_tasks.sh
# shellcheck disable=SC1091
# source /sc/home/robin.vandewater/conda3/etc/profile.d/conda.sh
eval "$(conda shell.bash hook)"
set -euo pipefail

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
source "$PWD/scripts/supported_tasks.sh"

# Function to get supported tasks based on input
get_supported_tasks() {
    local dataset=$1
    case $dataset in
        "AUMCdb") echo "${AUMCdb[@]}" ;;
        "EHRShot") echo "${EHRShot[@]}" ;;
        "HIRID") echo "${HIRID[@]}" ;;
        "INSPIRE") echo "${INSPIRE[@]}" ;;
        "MIMIC-IV") echo "${MIMIC_IV[@]}" ;;
        "NWICU") echo "${NWICU[@]}" ;;
        "SICdb") echo "${SICdb[@]}" ;;
        "eICU") echo "${eICU[@]}" ;;
        "MSHS") echo "${MSHS[@]}" ;;
        *) echo "Unknown dataset: $dataset" ;;
    esac
}


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
    readarray -t tasks < <(get_supported_tasks "$dataset")
    echo "Using dataset $dataset with tasks: ${tasks[*]}"
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
        if [ -f "$PREDICTIONS_DIR/predictions.parquet" ]; then
            echo "Skipping: $task because $PREDICTIONS_DIR/predictions.parquet already exists"
            continue
        fi
        echo "Cleaning up directories before training..."
        rm -rf "$OUTPUT_DIR"
        rm -rf "$FINETUNED_MODEL_DIR"
        rm -rf "$PREDICTIONS_DIR"
        # Train the model (supervised)
        debug_print_env
        genhpf-preprocess-meds \
        "$DATASET_DIR/data" \
        "--cohort=$LABELS_DIR" \
        "--metadata_dir=$DATASET_DIR/metadata" \
        "--output_dir=$OUTPUT_DIR/data" \
        "--workers=32" \
        "--debug=False" \
        "--skip-if-exists"
    done
done
# for task in "${tasks[@]}"; do
#   export DATASET_NAME="$dataset"
#   export DATASET_DIR="$base_dir/$dataset"
#   export TASK_NAME="$task"
#   export LABELS_DIR="$DATASET_DIR/labels/$task"
#   export OUTPUT_DIR="$DATASET_DIR/models/$TASK_NAME/$MODEL_NAME"
#   export PREDICTIONS_DIR="$DATASET_DIR/predictions/$TASK_NAME/$MODEL_NAME"
#   export FINETUNED_MODEL_DIR="$DATASET_DIR/models/$TASK_NAME/$MODEL_NAME"
#   export EVALUATION_DIR="$DATASET_DIR/results/${TASK_NAME}/${MODEL_NAME}"
#   for task in "${tasks[@]}"; do
#     if [ -f "$PREDICTIONS_DIR/predictions.parquet" ]; then
#         echo "Skipping: $task because $PREDICTIONS_DIR/predictions.parquet already exists"
#         continue
#     fi
#     genhpf-preprocess-meds \
#       "$DATASET_DIR/data" \
#       "--cohort=$LABELS_DIR" \
#       "--metadata_dir=$DATASET_DIR/metadata" \
#       "--output_dir=$OUTPUT_DIR/data" \
#       "--workers=32" \
#       "--debug=False" \
#       "--skip-if-exists"
