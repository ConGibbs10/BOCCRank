#!/bin/bash

#SBATCH --job-name rank21
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --partition=amilan
#SBATCH --time=1:00:00
#SBATCH --qos normal
#SBATCH --chdir=/projects/cgibbs10@colostate.edu/projs/BOCCRank/
#SBATCH --output=data-raw/rankings/rank21.out
#SBATCH --error=data-raw/rankings/rank21.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=connor.gibbs@colostate.edu

module purge
source /curc/sw/anaconda3/latest
conda activate cgibbsenv_burn

Rscript inst/scripts/rank_clusters.R --year=2021 --seed=6262
