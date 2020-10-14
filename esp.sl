#!/usr/bin/env bash

INPUT_FILE=${@: -1}
OUTPUT_DENSITY_FILE=${INPUT_FILE/.fchk/_density.cube}
OUTPUT_POTENTIAL_FILE=${INPUT_FILE/.fchk/_potential.cube}

echo "#!/bin/bash" > SLURM_ESP_${INPUT_FILE}
echo "#SBATCH --nodes=1" >> SLURM_ESP_${INPUT_FILE}
echo "#SBATCH --ntasks-per-node=12" >> SLURM_ESP_${INPUT_FILE}
echo "#SBATCH --mem=10gb" >> SLURM_ESP_${INPUT_FILE}
echo "#SBATCH --time=01:00:00" >> SLURM_ESP_${INPUT_FILE}

echo >> SLURM_ESP_${INPUT_FILE}

echo "_SLURM_MEM=10gb" >> SLURM_ESP_${INPUT_FILE}

echo "module load gaussian" >> SLURM_ESP_${INPUT_FILE}
echo "cubegen 1 Density=SCF ${INPUT_FILE} ${OUTPUT_DENSITY_FILE}" >> SLURM_ESP_${INPUT_FILE}
echo "cubegen 1 Potential=SCF ${INPUT_FILE} ${OUTPUT_POTENTIAL_FILE}" >> SLURM_ESP_${INPUT_FILE}

echo "rm -f SLURM_ESP_${INPUT_FILE}" >> SLURM_ESP_${INPUT_FILE}

sbatch SLURM_ESP_${INPUT_FILE}
