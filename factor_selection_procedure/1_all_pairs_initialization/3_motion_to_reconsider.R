##########################################################################################
# Factor Selection Procedure > 1. All-Pairs Initialization > Motion to Reconsider
#
# Once two factors are in, each is re-tested with the other kept in (2_motion_to_reconsider.R).
# Combined runs that start from earlier factors skip the pair scoring and begin here instead,
# reconsidering the factors they start from.
##########################################################################################

if (choosing)
{
  if (secondadded)
  {
    Announce("All-Pairs Initialization","Motion to Reconsider")
    recon<-MotionToReconsider(test,exceptions,facindex,thresh,netname,mydata,est,repeats,numattempts)
    test<-recon$test
    exceptions<-recon$exceptions
    ReconChi<-recon$ReconChi
    ReconP<-recon$ReconP
    override<-override+recon$fallbacks
  }

  APMTR<-TRUE

  timer<-RecordStep(timer,thisrunstart)
  print("End of All-Pairs Initialization")

  #Decide if Continuing
  if (OutOfTime(timer))
  {
    Pause<-TRUE
    print("PAUSED (for timing)")
  } else
  {
    print("PAUSED (everyone pauses here so we can ask for fewer resources)")
  }

  save.image(CheckpointFile(2))
}

if (searching && seeded && APMTR==FALSE)
{
  Announce("All-Pairs Initialization","Motion to Reconsider on the starting factors")
  recon<-MotionToReconsider(test,exceptions,facindex,thresh,netname,mydata,est,repeats,numattempts)
  test<-recon$test
  exceptions<-recon$exceptions
  ReconChi<-recon$ReconChi
  ReconP<-recon$ReconP
  override<-override+recon$fallbacks
}
