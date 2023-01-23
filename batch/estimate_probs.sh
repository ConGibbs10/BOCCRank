#!/bin/bash

#SBATCH --job-name eprobs
#SBATCH --nodes=1
#SBATCH --ntasks=32
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --partition=amilan
#SBATCH --time=12:00:00
#SBATCH --qos normal
#SBATCH --chdir=/projects/cgibbs10@colostate.edu/projs/BOCCRank/
#SBATCH --output=eprobs.out
#SBATCH --error=eprobs.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=connor.gibbs@colostate.edu

module purge
source /curc/sw/anaconda3/latest
conda activate cgibbsenv_burn

Rscript inst/scripts/estimate_probs.R
