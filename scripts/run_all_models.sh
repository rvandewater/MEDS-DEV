#!/bin/bash

current_path=$(pwd) # Dynamically set the current directory path
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <MODEL_NAME>"
    exit 1
fi
export MODEL_NAME=$1
if [[ "$MODEL_NAME" == "genhpf" || "$MODEL_NAME" == "cehrbert" ]]; then
    sbatch --job-name="${MODEL_NAME}_HIRID" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" HIRID
    sbatch --job-name="${MODEL_NAME}_MIMIC-IV" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" MIMIC-IV
    sbatch --job-name="${MODEL_NAME}_INSPIRE" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" INSPIRE
    sbatch --job-name="${MODEL_NAME}_NWICU" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" NWICU
    sbatch --job-name="${MODEL_NAME}_SICdb" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" SICdb
    sbatch --job-name="${MODEL_NAME}_AUMCdb" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" AUMCdb
    sbatch --job-name="${MODEL_NAME}_eICU" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" eICU
    sbatch --job-name="${MODEL_NAME}_EHRShot" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" EHRShot
else
    sbatch --job-name="${MODEL_NAME}_HIRID" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" HIRID
    sbatch --job-name="${MODEL_NAME}_MIMIC-IV" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" MIMIC-IV
    sbatch --job-name="${MODEL_NAME}_INSPIRE" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" INSPIRE
    sbatch --job-name="${MODEL_NAME}_NWICU" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" NWICU
    sbatch --job-name="${MODEL_NAME}_SICdb" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" SICdb
    sbatch --job-name="${MODEL_NAME}_AUMCdb" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" AUMCdb
    sbatch --job-name="${MODEL_NAME}_eICU" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" eICU
    sbatch --job-name="${MODEL_NAME}_EHRShot" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" EHRShot
fi
echo "Submitted jobs for model: $MODEL_NAME"
