##########################################################################################
# Start of every job: read the run arguments, load the settings and functions, and move to
# the job's scratch folder. Sourced by real_data.R, individual_model_set.R and
# group_model_set.R, which set dataset and RUN_ARGS first.
##########################################################################################

library(RSiena)
library(R.matlab)
library(R.utils)
library(parallel)
library(foreach)
library(doParallel)

###################RUN ARGUMENTS###############################
args<-commandArgs(trailingOnly=TRUE)
if (length(args)!=length(RUN_ARGS))
{
  stop(paste0("Usage: Rscript ",dataset,".R ",paste(toupper(RUN_ARGS),collapse=" ")))
}
jobID<-args[1]
for (i in 2:length(RUN_ARGS))
{
  assign(RUN_ARGS[i],as.numeric(args[i]))
}
# Arguments a dataset does not use
if (!("rate" %in% RUN_ARGS)) rate<-0
if (!("typeA" %in% RUN_ARGS)) typeA<-0

print(paste0("Dataset: ",dataset))
print(jobID)
print(n)
print(rate)

###################CODE###############################
source(file.path(repo_dir,"config.R"))
for (f in list.files(file.path(repo_dir,"R"),pattern="\\.R$",full.names=TRUE))
{
  source(f)
}
source(file.path(repo_dir,"factor_selection_procedure","2_motion_to_reconsider.R"))

Step <- function(name)
{
  # Runs one step of the procedure. Steps share the global environment, which is what the
  # checkpoints save and restore.
  source(file.path(repo_dir,paste0(name,".R")),local=globalenv())
}

setwd(file.path(cfg$paths$scratch_dir,jobID))
