#!/bin/bash

sbatch run_models_slurm.sh HIRID
sbatch run_models_slurm.sh MIMIC-IV
sbatch run_models_slurm.sh INSPIRE
sbatch run_models_slurm.sh NWICU
sbatch run_models_slurm.sh SICdb
sbatch run_models_slurm.sh AUMCdb
# sbatch run_models_slurm.sh eICU
# sbatch run_models_slurm.sh EHRShot
