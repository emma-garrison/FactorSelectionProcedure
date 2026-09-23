##########################################################################################
# Factor Selection Procedure > 0. Starting point > all-factors estimate
#
# Estimates the model with every candidate factor included. Every score test in the
# procedure starts from this estimate's effects object, switching factors on and off.
# If it cannot be estimated, simulated datasets draw a new model. Saved in checkpoint 1.
##########################################################################################

if (INIT==TRUE && AF==FALSE && Pause==FALSE)
{
  Announce("Starting point","All-factors estimate")
  test<-NULL
  test2<-NULL
  exit<-FALSE

  attempts<-1
  while(is.null(test2) && attempts<=afattempts && Pause==FALSE)
  {
    print(test2)
    print(attempts)
    thisrunstart<-Now()

    this<-DataSet(netname,N,dataf,datas,covariates,varcovariates,dycovariates,vardycovariates)
    mynodes<-this[[1]]
    mydata<-this[[2]]

    myeff<-SettingAllEffects(mydata,includefactors)

    #ALL FACTOR ESTIMATION
    print(paste0("All Factor Test for selection, ",n))
    tryCatch({
      test<-EstimateParameters(netname,mydata,myeff,n3,nsub,n2start,firstg,1,thetabound,time_limit)
    },error=function(cond)
    {
      test<-NULL
    })
    test2<-test

    timer<-RecordStep(timer,thisrunstart)
    if (OutOfTime(timer))
    {
      Pause<-TRUE
    }
    save.image(CheckpointFile(1))

    attempts<-attempts+1
  }
  # Done once there is an estimate or every try has failed. If the job paused before
  # either, the continuing job tries again.
  if (!is.null(test2) || attempts>afattempts)
  {
    AF<-TRUE
    save.image(CheckpointFile(1))
  }
}

#If we fail we can try selecting a new model.
if (g==0)
{
  if (INIT==TRUE && AF==TRUE && Pause==FALSE)
  {
    if (dataset=="individual_model_set" || (dataset=="group_model_set" && n<initializecount))
    {
      if(is.null(test))
      {
        newmodel<-newmodel+1
        print("Trying a new model. Run a new session to try!")
        Pause<-TRUE
        INIT<-FALSE
        AF<-FALSE
        save.image(CheckpointFile(1))
      }
    }
  }
}

#Report on when we fail
if (INIT==TRUE && AF==TRUE && Pause==FALSE)
{
  if (is.null(test))
  {
    #The all factors estimate did not work so we will report and get out.
    exit1<-TRUE
    if (dataset=="real_data")
    {
      print(paste0("Subject, ",Subject," window, ",Window," fails to find all factors estimate."))
    }else
    {
      print(paste0("Instance ",n," fails to find all factors estimate."))
    }
    save.image(CheckpointFile(1))
  } else
  {
    AFS<-TRUE
    save.image(CheckpointFile(1))
  }
}
