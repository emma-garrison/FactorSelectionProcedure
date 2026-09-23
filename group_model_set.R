##########################################################################################
# Simulated datasets: group model set
#
# A small number of random models (factors and weights) are drawn, and each one produces
# many time point 2s from many different real time point 1s. Every one of those simulated
# windows is run through the Factor Selection Procedure, which shows how consistently the
# procedure recovers the same model.
#
# Instances 1 to the number of models each draw a model; every later instance simulates
# another window from one of those models (config.R: simulation$group_model_set).
#
# Usage:
#   Rscript group_model_set.R JOBID N RATE TYPE1 TYPE3 TYPEA COPY
#
#   JOBID  Slurm job ID; the job works in <scratch_dir>/<JOBID>
#   N      instance
#   RATE   base rate of the simulated networks
#   TYPE1  modality: 1 fMRI, 2 DTI, 3 fMRI and DTI combined
#   TYPE3  network: 1 whole brain, 2-8 one subnetwork (see config.R). Whole-brain
#          runs also run each subnetwork.
#   TYPEA  combined runs (TYPE1 = 3) only, mirroring the real data: 1 = fMRI alone,
#          2 = DTI alone, 3 = both, starting from what 1 and 2 found. 0 otherwise
#   COPY   repeat number: copies share the setup and all-factors estimate but each runs
#          its own Factor Selection Procedure
#
# The job saves checkpoints as it goes. If it runs out of time, submitting it again with
# the same arguments continues where it stopped.
##########################################################################################

dataset<-"group_model_set"
RUN_ARGS<-c("jobID","n","rate","type1","type3","typeA","copy")
scriptfile<-sub("^--file=","",grep("^--file=",commandArgs(trailingOnly=FALSE),value=TRUE))
repo_dir<-dirname(normalizePath(scriptfile))
source(file.path(repo_dir,"setup","start.R"))

###################SETUP###############################
Step("setup/1_reference_data")      # subnetworks, region distances and covariates
Step("setup/2_load_networks")       # every participant's networks, used as time point 1
Step("setup/3_output_location")     # results folder for this run
Step("setup/4_settings")            # procedure settings and candidate factors
Step("setup/5_start_or_continue")   # new job, or continue from a checkpoint

###################NETWORKS###############################
Step("datasets/group_model_set")    # this instance's model and a simulated time point 2

###################FACTOR SELECTION PROCEDURE###############################
Step("factor_selection_procedure/run_factor_selection_procedure")
