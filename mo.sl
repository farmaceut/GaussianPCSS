#!/usr/bin/env bash

nvalue=1

while getopts ':n:' OPTION; do
 case ${OPTION} in
  n )
   nvalue="$OPTARG"
   ;;
 esac
done
shift "$(($OPTIND -1))" 

INPUT_FILE=${@: -1}
OUTPUT_MO_FILE=${INPUT_FILE/.fchk/}_${nvalue}.cube

echo "#!/bin/bash" > SLURM_MO_${nvalue}.inp
echo "#SBATCH --nodes=1" >> SLURM_MO_${nvalue}.inp
echo "#SBATCH --ntasks-per-node=12" >> SLURM_MO_${nvalue}.inp
echo "#SBATCH --mem=10gb" >> SLURM_MO_${nvalue}.inp
echo "#SBATCH --time=01:00:00" >> SLURM_MO_${nvalue}.inp

echo >> SLURM_MO_${nvalue}.inp

echo "_SLURM_MEM=10gb" >> SLURM_MO_${nvalue}.inp

echo "module load gaussian" >> SLURM_MO_${nvalue}.inp
echo "cubegen 1 MO=${nvalue} ${INPUT_FILE} ${OUTPUT_MO_FILE}" >> SLURM_MO_${nvalue}.inp

echo "rm -f SLURM_MO_${nvalue}.inp" >> SLURM_MO_${nvalue}.inp

sbatch SLURM_MO_${nvalue}.inp
