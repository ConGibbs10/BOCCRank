#!/bin/bash

#SBATCH --job-name new_edges
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --partition shas
#SBATCH --time=12:00:00
#SBATCH --qos normal
#SBATCH --chdir=/scratch/summit/cgibbs10@colostate.edu/projs/LP-CTA/
#SBATCH --output=data-raw/edge_containment/new_edges.out
#SBATCH --error=data-raw/edge_containment/new_edges.err
#SBATCH --mail-type=ALL
#SBATCH --mail-user=connor.gibbs@colostate.edu

module purge
source /curc/sw/anaconda3/latest
conda activate cgibbsenv_burn

Rscript inst/scripts/edge_containment.R
