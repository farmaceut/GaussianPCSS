# SLURM4Gaussian Support Scripts
This package includes bash scripts useful for working around with Gaussian with SLURM batch system HPCs.

## Package contents

### sub-gaussian.sl
Wraps previously created input file for Gaussian and submit it to the queue. Accepts flags responsible for number of nodes (n), number of cores (p), memory (m; in MB) and walltime (h; currently only hours in the format h:00:00).

_To be implemented:_
- perform formchk on the created .chk file
- remove .core or/and .out file

### esp.sl
Generates two cube files, namely `_density.cube` and `_potential.cube` using SCF that are required to visualize MEP

_To be implemented:_
- ...

### mo.sl
Create .cube files of particular molecular orbitals responsible for excited states transitions. Useful in case of large compounds (e.g. >500 MOs) for which generated .cube file is large and hardly to load in GV6.

To use it the following prelimnaries are need to be done:

1. Duplicate .log file and delete everything before line `Excitation energies and oscillator strengths:` including this line and everything after `This state for optimization and/or second-order correction.` also including this line.

2. Run the following script on the prepared file:
`#!/bin/sh
input="path/to/prepared/file.txt"
touch file_to_store_orbitals_number.txt
while read line; do
  for word in $line; do
    if [[ $word =~ ^[0-9]{3}$ ]]
    then
      if grep -Fxq "$word" orbitals.txt
      then 
        echo "Already exists in file."
      else
        echo $word >> orbitals.txt
      fi
    fi
  done
done < "$input"
`
3. Put the file with number of orbitals to the folder where .fchk is and make it `chmod +x`

4. Run the following script (an assumption is made mo.sl is symlinked)
`while read line; do for word in $line; do mo -n $word name.fchk; done; done < orbitals.txt`

A cube files for these orbitals will be submitted to the queue.

**To faciliate working with them remember to create apropriate symlink in .bash_profile**
`alias command='/PATH/TO/SCRIPT.sl'`
