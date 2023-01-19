#!/bin/bash

#SBATCH --job-name zcm20
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=250G
#SBATCH --partition smem
#SBATCH --account csu-summit-fhw
#SBATCH --time=24:00:00
#SBATCH --qos condo
#SBATCH --chdir=/scratch/summit/cgibbs10@colostate.edu/projs/LP-CTA/
#SBATCH --output=data-raw/zcmod/2020/msgs/%a.out
#SBATCH --error=data-raw/zcmod/2020/msgs/%a.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=connor.gibbs@colostate.edu

module purge
source /curc/sw/anaconda3/latest
conda activate cgibbsenv_burn

Rscript inst/scripts/compute_zcmod_matrix.R --year=2020 --seed=6262
