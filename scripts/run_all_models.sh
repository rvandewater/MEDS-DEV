#!/bin/bash

current_path=$(pwd) # Dynamically set the current directory path
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <MODEL_NAME>"
    exit 1
fi
export MODEL_NAME=$1

sbatch "${current_path}/run_models_slurm.sh" "$MODEL_NAME" HIRID
sbatch "${current_path}/run_models_slurm.sh" "$MODEL_NAME" MIMIC-IV
sbatch "${current_path}/run_models_slurm.sh" "$MODEL_NAME" INSPIRE
sbatch "${current_path}/run_models_slurm.sh" "$MODEL_NAME" NWICU
sbatch "${current_path}/run_models_slurm.sh" "$MODEL_NAME" SICdb
sbatch "${current_path}/run_models_slurm.sh" "$MODEL_NAME" AUMCdb

# sbatch "${current_path}"/run_models_slurm.sh "$MODEL_NAME" eICU
# sbatch "${current_path}"/run_models_slurm.sh "$MODEL_NAME" EHRShot
