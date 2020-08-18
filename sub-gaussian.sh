#!/usr/bin/env bash

# default values
nvalue=1
pvalue=4
mvalue=8000
tvalue=168

file=${@: -1}

echo "${file}"

if ! [[ -f ${@: -1} ]]; then
    echo "No file or invalid input."
    exit 1
fi

while getopts ':n:p:m:t:' OPTION; do
  case ${OPTION} in
    n )
      nvalue="$OPTARG"
      echo "${OPTARG} node/s were set manually."
      ;;
    p )
      pvalue="$OPTARG"
      echo "${OPTARG} core/s per node were set manually."
      ;;
    m )
      mvalue="$OPTARG"
      echo "${OPTARG} memory (in MB) was set manually."
      ;;
    t )
      tvalue="$OPTARG"
      echo "${OPTARG} hour/s were set manually."
      ;;
    \? )
      echo "Improper flags submitted.Script usage: $(basename $0) [-n] [-p] [-m] [-t]."
      exit 1
      ;;
    esac
done
shift "$(($OPTIND -1))"

echo "Script will created with:"
echo "- $nvalue nodes,"
echo "$pvalue cores per node,"
echo "$mvalue memory (in MB), in total,"
echo "and for $tvalue hours."

#new script writing

echo "#!/bin/bash" > SLURM_$file
echo "#SBATCH --nodes=${nvalue}" >> SLURM_$file
echo "#SBATCH --ntasks-per-node=${pvalue}" >> SLURM_$file
echo "#SBATCH --mem=${mvalue}mb" >> SLURM_$file
echo "#SBATCH --time=${tvalue}:00:00" >> SLURM_$file
echo >> SLURM_$file
echo "_SLURM_MEM=${mvalue}mb" >> SLURM_$file
echo >> SLURM_$file
echo "module load gaussian" >> SLURM_$file
echo >> SLURM_$file
echo "export TMPDIR=\"/tmp/lustre_shared/$USER/gaussian/${file/.inp/}_\$SLURM_JOBID\"" >> SLURM_$file
echo "mkdir -p \${TMPDIR}" >> SLURM_$file
echo >> SLURM_$file
echo "GAUSS_MEMDEF=\${_SLURM_MEM}" >> SLURM_$file
echo "GAUSS_SCRDIR=\${TMPDIR}" >> SLURM_$file
echo "export GAUSS_MEMDEF GAUSS_SCRDIR" >> SLURM_$file
echo >> SLURM_$file
echo "GAUSS_MAXDISK=1000gb" >> SLURM_$file
echo >> SLURM_$file
echo "cat << EOF > \${TMPDIR}/Default.Route" >> SLURM_$file
echo "-M- \${GAUSS_MEMDEF}" >> SLURM_$file
echo "-P- \${SLURM_NTASKS}" >> SLURM_$file
echo "-#- MaxDisk=\${GAUSS_MAXDISK}" >> SLURM_$file
echo "EOF" >> SLURM_$file
echo >> SLURM_$file
echo "INPUT_DIR=\"$PWD\"" >> SLURM_$file
echo "INPUT_FILE=\"${file}\"" >> SLURM_$file
echo "OUTPUT_FILE=\"${file/.inp/.log}\"" >> SLURM_$file
echo >> SLURM_$file
echo "cp \${INPUT_DIR}/\${INPUT_FILE} \${TMPDIR}" >> SLURM_$file
echo >> SLURM_$file
echo "cd \$TMPDIR" >> SLURM_$file
echo >> SLURM_$file
echo "g09 < \${INPUT_FILE} > \${OUTPUT_FILE}" >> SLURM_$file
echo >> SLURM_$file
echo "cp -r \$TMPDIR \$SLURM_SUBMIT_DIR" >> SLURM_$file
echo "rm -rf \$TMPDIR" >> SLURM_$file
echo "rm -f \${INPUT_DIR}/\${INPUT_FILE}" >> SLURM_$file
echo "rm -f \${INPUT_DIR}/SLURM_$file" >> SLURM_$file

sbatch SLURM_$file
