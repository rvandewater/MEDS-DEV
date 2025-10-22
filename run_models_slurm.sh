#!/bin/bash
#SBATCH --job-name=meds_dev_experiments # -J
#SBATCH --partition=gpu # -p
#SBATCH --cpus-per-task=16 # -c
#SBATCH --mem=200gb
#SBATCH --gpus=1
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
export MODEL_NAME="genhpf"
export MODEL_NAME="cehrbert"
export datasets=(
    # "AUMCdb"
    # "eICU"
    "EHRShot"
    # "HIRID"
    # "INSPIRE"
    # "MIMIC-IV"
    "NWICU"
    "SICdb"
)
export base_dir="/sc/home/robin.vandewater/datasets/meds"
export tasks=(
    "abnormal_lab/cbc/leukocytosis/first_24h"
    "abnormal_lab/cbc/thrombocytopenia/first_24h"
    "abnormal_lab/cbc/anemia/first_24h"
    "abnormal_lab/vital/hypotension/first_24h"
    "abnormal_lab/blood_chemistry/metabolic_acidosis/first_24h"
    "abnormal_lab/blood_chemistry/hyponatremia/first_24h"
    "abnormal_lab/blood_chemistry/elevated_creatinine/first_24h"
    "mortality/in_icu/first_24h"
    # "readmission/general_hospital/30d"
)
# export datasets=("HIRID")

for dataset in "${datasets[@]}"; do
    export DATASET_NAME=$dataset
    export DATASET_DIR="$base_dir/$dataset"
    if [ "$MODEL_NAME" != "meds_tab/tiny" ]; then
        # First pretrain the model
        export PRETRAINED_MODEL_DIR="$DATASET_DIR/models/$MODEL_NAME"
        meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" mode=train dataset_type=unsupervised output_dir="$PRETRAINED_MODEL_DIR"
        for task in "${tasks[@]}"; do
            echo "Processing dataset: $DATASET_NAME, task: $task"
            export TASK_NAME=$task
            export LABELS_DIR="$DATASET_DIR/labels/$task"
            export FINETUNED_MODEL_DIR="$DATASET_DIR/models/$TASK_NAME/$MODEL_NAME"
            export PREDICTIONS_DIR="$DATASET_DIR/predictions/$TASK_NAME/$MODEL_NAME"
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=train dataset_type=supervised output_dir="$FINETUNED_MODEL_DIR" model_initialization_dir="$PRETRAINED_MODEL_DIR"
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=predict dataset_type=supervised split=held_out output_dir="$PREDICTIONS_DIR" model_initialization_dir="$FINETUNED_MODEL_DIR"
            echo "Completed dataset: $DATASET_NAME, task: $task"
        done
    else
        for task in "${tasks[@]}"; do
            echo "Processing dataset: $DATASET_NAME, task: $task"
            export TASK_NAME=$task
            export LABELS_DIR="$DATASET_DIR/labels/$task"
            export FINETUNED_MODEL_DIR="$DATASET_DIR/models/$TASK_NAME/$MODEL_NAME"
            export PREDICTIONS_DIR="$DATASET_DIR/predictions/$TASK_NAME/$MODEL_NAME"
            meds-dev-model model="$MODEL_NAME" dataset_dir="$DATASET_DIR" labels_dir="$LABELS_DIR" mode=train dataset_type=supervised output_dir="$FINETUNED_MODEL_DIR" model_initialization_dir="$PRETRAINED_MODEL_DIR"
            echo "Completed dataset: $DATASET_NAME, task: $task"
        done
    fi
done
