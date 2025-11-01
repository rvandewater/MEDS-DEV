#!/bin/bash
export current_path=result=${result:-/}
sbatch "${current_path}"/run_models_slurm.sh HIRID
sbatch "${current_path}"/run_models_slurm.sh MIMIC-IV
sbatch "${current_path}"/run_models_slurm.sh INSPIRE
sbatch "${current_path}"/run_models_slurm.sh NWICU
sbatch "${current_path}"/run_models_slurm.sh SICdb
sbatch "${current_path}"/run_models_slurm.sh AUMCdb
# sbatch "${current_path}"/run_models_slurm.sh eICU
# sbatch "${current_path}"/run_models_slurm.sh EHRShot
