##########################################################################################
# Simulated datasets: individual model set
#
# Each instance draws its own random model (factors and weights), takes a random real
# network as time point 1, simulates time point 2 from the model, and runs the Factor
# Selection Procedure on it. Comparing the factors found with the model's factors shows how
# well the procedure recovers the factors that generated a network.
#
# Usage:
#   Rscript individual_model_set.R JOBID N RATE TYPE1 TYPE3 COPY
#
#   JOBID  Slurm job ID; the job works in <scratch_dir>/<JOBID>
#   N      instance, 1 to the number of models (config.R: simulation$individual_model_set)
#   RATE   base rate of the simulated networks
#   TYPE1  modality: 1 fMRI, 2 DTI, 3 fMRI and DTI combined
#   TYPE3  network: 1 whole brain, 2-8 one functional system (see config.R)
#   COPY   repeat number: copies share the setup and all-factors estimate but each runs
#          its own Factor Selection Procedure
#
# The job saves checkpoints as it goes. If it runs out of time, submitting it again with
# the same arguments continues where it stopped.
##########################################################################################

dataset<-"individual_model_set"
RUN_ARGS<-c("jobID","n","rate","type1","type3","copy")
scriptfile<-sub("^--file=","",grep("^--file=",commandArgs(trailingOnly=FALSE),value=TRUE))
repo_dir<-dirname(normalizePath(scriptfile))
source(file.path(repo_dir,"setup","start.R"))

###################SETUP###############################
Step("setup/1_reference_data")      # functional systems, region distances and covariates
Step("setup/2_load_networks")       # every participant's networks, used as time point 1
Step("setup/3_output_location")     # results folder for this run
Step("setup/4_settings")            # procedure settings and candidate factors
Step("setup/5_start_or_continue")   # new job, or continue from a checkpoint

###################NETWORKS###############################
Step("datasets/individual_model_set") # draw a model and simulate time point 2

###################FACTOR SELECTION PROCEDURE###############################
Step("factor_selection_procedure/run_factor_selection_procedure")
