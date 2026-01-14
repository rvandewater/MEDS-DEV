#!/bin/bash
#SBATCH --job-name=meds_dev_experiments # -J
#SBATCH --partition=gpu # -p
#SBATCH --cpus-per-task=16 # -c
#SBATCH --mem=200gb
#SBATCH --gpus=1
#SBATCH --gpus=a40:1
#SBATCH --output=../%x/%x_%j.log # %x is job-name, %j is job id
#SBATCH --account=sci-lippert
#SBATCH --time=120:00:00 # -t
    # !/bin/bash
    # SBATCH --job-name=meds_dev_experiments # -J
    # SBATCH --partition=cpu # -p
    # SBATCH --cpus-per-task=16 # -c
    # SBATCH --mem=200gb
    # SBATCH --output=../%x/%x_%j.log # %x is job-name, %j is job id
    # SBATCH --account=sci-lippert
    # SBATCH --time=120:00:00 # -t
eval "$(conda shell.bash hook)"
cd ~/projects/MEDS_DEV_NEW || exit
conda activate meds_dev_311

export MODEL_NAME="meds_tab/tiny"
export datasets=(
    # "AUMCdb"
    # "eICU"
    # "EHRShot"
    # "HIRID"
    # "INSPIRE"
    "MIMIC-IV"
    "NWICU"
    "SICdb"
)
export base_dir="/sc/home/robin.vandewater/datasets/meds"
export base_dir="/sc/arion/projects/hpims-hpi/projects/foundation_models_ehr/cohorts/meds_debug/full_omop_25_04_29/MEDS_cohort"
export datasets=("AIRMS")
export tasks=(
    # "mortality/in_icu/first_24h"
    "mount_sinai_adjusted/in_ed_mortality"
)
# export datasets=("HIRID")
for dataset in "${datasets[@]}"; do
    export DATASET_NAME=$dataset
    export DATASET_DIR="$base_dir/$dataset"

    for task in "${tasks[@]}"; do
        echo "Processing dataset: $DATASET_NAME, task: $task"
        export TASK_NAME=$task
        export LABELS_DIR="$DATASET_DIR/labels/$task"
        export FINETUNED_MODEL_DIR="$DATASET_DIR/models/$TASK_NAME/$MODEL_NAME"
        export PREDICTIONS_DIR="$DATASET_DIR/predictions/$TASK_NAME/$MODEL_NAME"
        # Run the meds-dev-task command
        export PRETRAINED_MODEL_DIR="$DATASET_DIR/models/$MODEL_NAME"
        if [ "$MODEL_NAME" != "meds_tab/tiny" ]; then
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" mode=train dataset_type=unsupervised output_dir="$PRETRAINED_MODEL_DIR"
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=train dataset_type=supervised output_dir="$FINETUNED_MODEL_DIR" model_initialization_dir="$PRETRAINED_MODEL_DIR"
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=predict dataset_type=supervised split=held_out output_dir="$PREDICTIONS_DIR" model_initialization_dir="$FINETUNED_MODEL_DIR"
        else
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=train dataset_type=supervised output_dir="$FINETUNED_MODEL_DIR" model_initialization_dir="$PRETRAINED_MODEL_DIR"
        fi
        echo "Completed dataset: $DATASET_NAME, task: $task"
    done
done
