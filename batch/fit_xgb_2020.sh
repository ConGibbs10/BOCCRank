#!/bin/bash

#SBATCH --job-name fit20
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --partition=amilan
#SBATCH --time=12:00:00
#SBATCH --qos normal
#SBATCH --chdir=/projects/cgibbs10@colostate.edu/projs/BOCCRank/
#SBATCH --output=data-raw/tune/fit20.out
#SBATCH --error=data-raw/tune/fit20.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=connor.gibbs@colostate.edu

module purge
source /curc/sw/anaconda3/latest
conda activate cgibbsenv_burn

Rscript inst/scripts/choose_xgboost.R --year=2020 --seed=6262
