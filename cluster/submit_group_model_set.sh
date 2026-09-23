#!/bin/bash
# Simulated datasets, group model set: produces and tests the group model time windows.
# Submits one job array per rate, modality and network. Instances 1-7 each draw a model;
# instances 8-357 each simulate another window from one of those models. Run from the
# repository root:
#
#   bash cluster/submit_group_model_set.sh 1               # copy 1, instances 1-357
#   bash cluster/submit_group_model_set.sh 1 1-7           # copy 1, only the model-drawing instances
#
# Add DRY_RUN=1 in front to print the sbatch commands without submitting.
# Instances 8+ load the models saved by instances 1-7, and combined TYPEA 2 loads what
# TYPEA 1 saved, so those need their earlier runs to have got past setup. Combined TYPEA 3
# starts from the TYPEA 1 and 2 results: submit it once they finish.

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $0 COPY [INSTANCES]" >&2
    exit 1
fi

COPY=$1
INSTANCES=${2:-1-357}   # config.R: simulation$group_model_set (7 models x 51 windows)

for RATE in 5 20 35 50 65; do                  # config.R: simulation$rates
    for TYPE1 in 1 2 3; do                     # 1 = fMRI, 2 = DTI, 3 = combined fMRI + DTI
        for TYPE3 in 1 2 3 4 5 6 7 8; do       # 1 = whole brain, 2-8 = subnetworks 1-7
            # Combined runs model fMRI (TYPEA 1) and DTI (TYPEA 2) on their own first
            if [[ $TYPE1 -eq 3 ]]; then TYPEAS="1 2"; else TYPEAS="0"; fi
            for TYPEA in $TYPEAS; do
                CMD=(sbatch --array="$INSTANCES"
                     --job-name="GroupModelSet_${RATE}_${TYPE1}_${TYPE3}_${TYPEA}_${COPY}"
                     cluster/run_job.slurm group_model_set "$RATE" "$TYPE1" "$TYPE3" "$TYPEA" "$COPY")
                if [[ -n "${DRY_RUN:-}" ]]; then echo "${CMD[*]}"; else "${CMD[@]}"; fi
            done
        done
    done
done
