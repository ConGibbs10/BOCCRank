#!/bin/bash

#SBATCH --job-name tune21
#SBATCH --array=1-100
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --partition=amilan
#SBATCH --time=24:00:00
#SBATCH --qos normal
#SBATCH --chdir=/projects/cgibbs10@colostate.edu/projs/BOCCRank/
#SBATCH --output=data-raw/tune/2021/msgs/%a.out
#SBATCH --error=data-raw/tune/2021/msgs/%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=connor.gibbs@colostate.edu

module purge
source /curc/sw/anaconda3/latest
conda activate cgibbsenv_burn

Rscript inst/scripts/tune_xgboost.R --index=$SLURM_ARRAY_TASK_ID --year=2021 --nreps=100 --seed=6262
