#!/bin/bash

#SBATCH --job-name zcc19
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=250G
#SBATCH --partition smem
#SBATCH --account csu-summit-fhw
#SBATCH --time=72:00:00
#SBATCH --qos condo
#SBATCH --chdir=/scratch/summit/cgibbs10@colostate.edu/projs/LP-CTA/
#SBATCH --output=data-raw/zcmod/2019/msgs/%a.out
#SBATCH --error=data-raw/zcmod/2019/msgs/%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=connor.gibbs@colostate.edu

module purge
source /curc/sw/anaconda3/latest
conda activate cgibbsenv_burn

Rscript inst/scripts/cluster_zcmod.R --year=2019 --seed=6262 --nreps=10
