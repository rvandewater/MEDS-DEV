#!/bin/bash

current_path=$(pwd) # Dynamically set the current directory path
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <MODEL_NAME>"
    exit 1
fi
export MODEL_NAME=$1
if [[ "$MODEL_NAME" == "genhpf" || "$MODEL_NAME" == "cehrbert" ]]; then
    # sbatch --job-name="${MODEL_NAME}_HIRID" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" HIRID
    # sbatch --job-name="${MODEL_NAME}_MIMIC-IV" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" MIMIC-IV
    sbatch --job-name="${MODEL_NAME}_INSPIRE" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" INSPIRE
    sbatch --job-name="${MODEL_NAME}_NWICU" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" NWICU
    sbatch --job-name="${MODEL_NAME}_SICdb" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" SICdb
    sbatch --job-name="${MODEL_NAME}_AUMCdb" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" AUMCdb
    sbatch --job-name="${MODEL_NAME}_eICU" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" eICU
    sbatch --job-name="${MODEL_NAME}_EHRShot" "${current_path}/run_models_slurm.sh" "$MODEL_NAME" EHRShot
elif [ "$MODEL_NAME" == "meds_tab/tiny" ]; then
    log_name="meds_tab_tiny"
    sbatch --job-name="${log_name}_HIRID" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" HIRID
    sbatch --job-name="${log_name}_MIMIC-IV" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" MIMIC-IV
    sbatch --job-name="${log_name}_INSPIRE" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" INSPIRE
    sbatch --job-name="${log_name}_NWICU" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" NWICU
    sbatch --job-name="${log_name}_SICdb" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" SICdb
    sbatch --job-name="${log_name}_AUMCdb" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" AUMCdb
    sbatch --job-name="${log_name}_eICU" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" eICU
    sbatch --job-name="${log_name}_EHRShot" "${current_path}/run_models_slurm_cpu.sh" "$MODEL_NAME" EHRShot
else
    echo "Error: Invalid MODEL_NAME '${MODEL_NAME}'. Available models are: meds_tab/tiny, cehrbert, genhpf"
    exit 1
fi
echo "Submitted jobs for model: $MODEL_NAME"
