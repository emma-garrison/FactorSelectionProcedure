##########################################################################################
# Real data
#
# Runs the Factor Selection Procedure on one participant's scan window: which network
# formation factors explain how their brain network changed between two scans?
#
# Usage:
#   Rscript real_data.R JOBID N TYPE1 TYPE3 COPY
#
#   JOBID  Slurm job ID; the job works in <scratch_dir>/<JOBID>
#   N      the N-th scan window across all participants
#   TYPE1  modality: 1 fMRI, 2 DTI, 3 fMRI and DTI combined (needs the fMRI and DTI
#          results for the same window and COPY)
#   TYPE3  network: 1 whole brain, 2-8 one functional system (see config.R)
#   COPY   repeat number: copies share the setup and all-factors estimate but each runs
#          its own Factor Selection Procedure
#
# The job saves checkpoints as it goes. If it runs out of time, submitting it again with
# the same arguments continues where it stopped.
##########################################################################################

dataset<-"real_data"
RUN_ARGS<-c("jobID","n","type1","type3","copy")
scriptfile<-sub("^--file=","",grep("^--file=",commandArgs(trailingOnly=FALSE),value=TRUE))
repo_dir<-dirname(normalizePath(scriptfile))
source(file.path(repo_dir,"setup","start.R"))

###################SETUP###############################
Step("setup/1_reference_data")      # functional systems, region distances and covariates
Step("setup/2_load_networks")       # every participant's networks for this modality
Step("setup/3_output_location")     # results folder for this run
Step("setup/4_settings")            # procedure settings and candidate factors
Step("setup/5_start_or_continue")   # new job, or continue from a checkpoint

###################NETWORKS###############################
Step("datasets/real_data")          # the two scans of window N

###################FACTOR SELECTION PROCEDURE###############################
Step("factor_selection_procedure/run_factor_selection_procedure")
