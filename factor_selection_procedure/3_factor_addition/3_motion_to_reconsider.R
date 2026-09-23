##########################################################################################
# Factor Selection Procedure > 3. Factor Addition > Motion to Reconsider
#
# After each factor is added, every factor in the model is re-tested with the others kept
# in (2_motion_to_reconsider.R).
##########################################################################################

if (adding)
{
  if (added)
  {
    Announce("Factor Addition","Motion to Reconsider")
    recon<-MotionToReconsider(test,exceptions,facindex,thresh,netname,mydata,est,repeats,numattempts)
    test<-recon$test
    exceptions<-recon$exceptions
    ReconChi<-recon$ReconChi
    ReconP<-recon$ReconP
    override<-override+recon$fallbacks
  }

  timer<-RecordStep(timer,thisrunstart)
  MTR<-TRUE

  #Decide if Continuing
  if (OutOfTime(timer))
  {
    Pause<-TRUE
    print("PAUSED")
  }

  save.image(CheckpointFile(2))
}
