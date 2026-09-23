##########################################################################################
# After the Factor Selection Procedure 1: the final model
#
# Estimates the model with the factors the Factor Selection Procedure chose. If it can't be
# estimated, simulated datasets draw a new model.
##########################################################################################

# Skipped if a continuing job already has the final model
if (INIT==TRUE && AF==TRUE && AFS==TRUE && PP==TRUE && Pause==FALSE && is.null(final))
{
  if (dataset=="real_data")
  {
    print(paste0("Compiling Factors for Subject: ",Subject," Window: ",Window," ."))
  }else
  {
    print(paste0("Compiling Factors for Instance: ",n))
  }

  thisrunstart<-Now()

  test$effects$include[facindex[!(facindex %in% exceptions)]]<-FALSE

  test$effects$include[facindex[(facindex %in% exceptions)]]<-TRUE
  test$effects$fix[facindex[(facindex %in% exceptions)]]<-FALSE
  test$effects$test[facindex[(facindex %in% exceptions)]]<-FALSE

  test2<-NULL
  attempts<-1

  print(test$effects)

  while(is.null(test2) && attempts<=afattempts)
  {
    tryCatch({
      test2<-EstimateParameters(netname,mydata,test$effects,cfg$siena$n3_final,nsub,n2start,firstg,1,thetabound)
    },error=function(cond)
    {
      test2<-NULL
    })
    attempts<-attempts+1
  }

  if (!is.null(test2))
  {
    final<-list(factorlist=exceptions,testresults=test2)
  } else
  {
    final<-NULL
  }

  timer<-RecordStep(timer,thisrunstart)
  print("Procedure is done! Only convergence reduction left")

  #Decide if Continuing
  if (OutOfTime(timer))
  {
    Pause<-TRUE
    print("PAUSED")
  }
  save.image(CheckpointFile(2))
}

#If we fail we can try selecting a new model.
if (INIT==TRUE && AF==TRUE && AFS==TRUE && PP==TRUE && Pause==FALSE)
{
  if (dataset=="individual_model_set" || (dataset=="group_model_set" && n<initializecount))
  {
    if(is.null(final))
    {
      newmodel<-newmodel+1
      print("Trying a new model. Run a new session to try!")
      Pause<-TRUE
      INIT<-FALSE
      AF<-FALSE
      PP<-FALSE
      PS<-FALSE
      save.image(CheckpointFile(1))
    }
  }
}

#Report on when we fail
if (INIT==TRUE && AF==TRUE && AFS==TRUE && PP==TRUE && Pause==FALSE)
{
  if (is.null(final))
  {
    exit2<-TRUE
    if (dataset=="real_data")
    {
      print(paste0("Subject, ",Subject," window, ",Window," fails to find set of factors."))
    }else
    {
      print(paste0("Instance ",n," fails to find set of factors."))
    }
    save.image(CheckpointFile(2))
  } else
  {
    PS<-TRUE
    save.image(CheckpointFile(2))
  }
}
