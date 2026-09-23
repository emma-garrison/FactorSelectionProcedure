##########################################################################################
# Setup 5: new job, or continue from a checkpoint
#
# Checkpoint 0 holds the networks (and, for the simulated datasets, the model) chosen for
# this instance; checkpoint 1 holds the all-factors estimate. Both are shared by all copies.
##########################################################################################

###################INITIALIZING###############################
timer<-StartTimer(cfg$procedure$job_hours*3600)

if(file.exists(CheckpointFile(0)))
{
  LoadCheckpoint(CheckpointFile(0))
  Pause<-FALSE # a paused job is continuing now
  print("CONTINUING 0")
  timer<-RestartTimer(timer)
}else
{
  print("INITIALIZING 0")
  INIT<-FALSE
  AF<-FALSE
  AFS<-FALSE
  PP<-FALSE
  PS<-FALSE
  Pause<-FALSE
  newmodel<-0
  attempts<-1
  # Groups to run: 0 is the network chosen by TYPE3, 1-7 are subnetworks.
  # Whole-brain group model set runs do every subnetwork first, then the whole brain.
  if (dataset=="group_model_set" && type3==1)
  {
    groups<-c(rep(1:length(SNnames), each=sameexamples),0)
  }else
  {
    groups<-c(0)
  }
}

if(file.exists(CheckpointFile(1)))
{
  LoadCheckpoint(CheckpointFile(1))
  Pause<-FALSE # a paused job, or one that asked for a new model, is continuing now
  print("CONTINUING 1")
  timer<-RestartTimer(timer)
}else
{
  print("INITIALIZING 1")
  attempts<-1
  Exceptions<-c()
  exit1<-FALSE
  AF<-FALSE
  AFS<-FALSE
}

