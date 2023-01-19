#!/bin/bash

#SBATCH --job-name fix21
#SBATCH --nodes=1
#SBATCH --ntasks=24
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --partition=amilan
#SBATCH --time=12:00:00
#SBATCH --qos normal
#SBATCH --chdir=/projects/cgibbs10@colostate.edu/projs/BOCCRank/
#SBATCH --output=data-raw/tune/fix21.out
#SBATCH --error=data-raw/tune/fix21.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=connor.gibbs@colostate.edu

module purge
source /curc/sw/anaconda3/latest
conda activate cgibbsenv_burn

Rscript inst/scripts/fix_tune_results.R --year=2021 --seed=6262
