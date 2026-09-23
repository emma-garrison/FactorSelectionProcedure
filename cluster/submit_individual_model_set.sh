#!/bin/bash
# Simulated datasets, individual model set: produces and tests the individual time windows.
# Submits one job array per rate, modality and network; each array task draws its own model
# and simulates one window. Run from the repository root:
#
#   bash cluster/submit_individual_model_set.sh 1          # copy 1, instances 1-200
#   bash cluster/submit_individual_model_set.sh 1 1-50     # copy 1, instances 1-50 only
#
# Add DRY_RUN=1 in front to print the sbatch commands without submitting.

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 COPY [INSTANCES]" >&2
    exit 1
fi

COPY=$1
INSTANCES=${2:-1-200}   # one per model (config.R: simulation$individual_model_set$models)

for RATE in 5 20 35 50 65; do                  # config.R: simulation$rates
    for TYPE1 in 1 2 3; do                     # 1 = fMRI, 2 = DTI, 3 = combined fMRI + DTI
        for TYPE3 in 1 2 3 4 5 6 7 8; do       # 1 = whole brain, 2-8 = subnetworks 1-7
            CMD=(sbatch --array="$INSTANCES"
                 --job-name="IndividualModelSet_${RATE}_${TYPE1}_${TYPE3}_${COPY}"
                 cluster/run_job.slurm individual_model_set "$RATE" "$TYPE1" "$TYPE3" "$COPY")
            if [[ -n "${DRY_RUN:-}" ]]; then echo "${CMD[*]}"; else "${CMD[@]}"; fi
        done
    done
done
