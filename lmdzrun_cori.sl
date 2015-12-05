#!/bin/bash -l

#SBATCH -p debug
#SBATCH -N 1
#SBATCH -t 00:30:00
#SBATCH -J LMDZ_RUN

module swap PrgEnv-pgi PrgEnv-gnu
cd $SLURM_SUBMIT_DIR   # optional, since this is the default behavior
srun -n 32 ./gcm.e