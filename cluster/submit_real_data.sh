#!/bin/bash
# Real data: loops through the data. Submits one job array per modality and network; each
# array task is one scan window. Run from the repository root:
#
#   bash cluster/submit_real_data.sh 1-349 1      # windows 1-349, copy 1
#
# Add DRY_RUN=1 in front to print the sbatch commands without submitting.
# Combined runs (TYPE1 3) start from the fMRI and DTI results, so submit them once those finish.

set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 WINDOWS COPY" >&2
    exit 1
fi

WINDOWS=$1  # scan windows to run, passed to sbatch --array
COPY=$2

for TYPE1 in 1 2 3; do                     # 1 = fMRI, 2 = DTI, 3 = combined fMRI + DTI
    for TYPE3 in 1 2 3 4 5 6 7 8; do       # 1 = whole brain, 2-8 = subnetworks 1-7
        CMD=(sbatch --array="$WINDOWS"
             --job-name="RealData_${TYPE1}_${TYPE3}_${COPY}"
             cluster/run_job.slurm real_data "$TYPE1" "$TYPE3" "$COPY")
        if [[ -n "${DRY_RUN:-}" ]]; then echo "${CMD[*]}"; else "${CMD[@]}"; fi
    done
done
