#!/bin/bash
#SBATCH --time=168:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=9gb

# Runs one parameter combination of one dataset as a job array; each array task is one
# instance (N). Normally launched by the submit_*.sh scripts. Submit from the repository root:
#
#   sbatch --array=1-50  cluster/run_job.slurm real_data 2 7 1                # TYPE1 TYPE3 COPY
#   sbatch --array=1-200 cluster/run_job.slurm individual_model_set 35 2 7 1  # RATE TYPE1 TYPE3 COPY
#   sbatch --array=1-357 cluster/run_job.slurm group_model_set 35 2 7 0 1     # RATE TYPE1 TYPE3 TYPEA COPY

SCRIPT=$1
shift
PARAMS=$(IFS=_; echo "$*")

echo "Running ${SCRIPT} with params ${PARAMS}, task ${SLURM_ARRAY_TASK_ID}"
echo "Starting run at $(date) on $(hostname)"

module load R/4.4.1

Rscript "${SCRIPT}.R" "${SLURM_JOB_ID}" "${SLURM_ARRAY_TASK_ID}" "$@" \
    > ~/"${SCRIPT}_${PARAMS}_${SLURM_ARRAY_TASK_ID}.out" 2>&1

echo "Finished run at $(date)"
