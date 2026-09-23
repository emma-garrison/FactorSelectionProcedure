##########################################################################################
# After the Factor Selection Procedure 2: convergence reduction
#
# Re-estimates the final model from its own estimates until it converges well.
##########################################################################################

reducing<-INIT==TRUE && AF==TRUE && AFS==TRUE && PP==TRUE && PS==TRUE && Pause==FALSE
if (reducing)
{
  if (dataset=="real_data")
  {
    print(paste0("Convergence Reduction 1 Subject: ",Subject," Window: ",Window," ."))
  }else
  {
    print(paste0("Convergence Reduction 1 Instance: ",n," ."))
  }

  final$testresults$effects$initialValue<-final$testresults$theta

  tryCatch({
    testresult1<-EstimateParameters(netname,mydata,final$testresults$effects,n3,nsub,n2start,firstg,reps,thetabound)
  },error=function(cond)
  {
    exit3<<-TRUE
    if (dataset=="real_data")
    {
      print(paste0("Subject, ",Subject," window, ",Window," fails to find determined estimate."))
    }else
    {
      print(paste0("Instance ",n," fails to find determined estimate."))
    }
  })

  if (exit3==FALSE)
  {
    if (dataset=="real_data")
    {
      print(paste0("Convergence Reduction 2 Subject: ",Subject," Window: ",Window," ."))
    }else
    {
      print(paste0("Convergence Reduction 2 Instance: ",n," ."))
    }

    # Re-estimate from the previous estimates with the convergence reduction settings
    attempts<-1
    testresult2<-testresult1
    while(testresult2$tconv.max>cfg$siena$target_convergence && attempts<=afattempts)
    {
      testresult2$effects$initialValue<-testresult2$theta
      tryCatch({
        testresult3<-EstimateParameters(netname,mydata,testresult2$effects,n3f,nsubf,n2startf,firstgf,reps,thetabound)
      },error=function(cond)
      {
        if (dataset=="real_data")
        {
          print(paste0("Subject, ",Subject," window, ",Window," fails to reduce determined estimate."))
        }else
        {
          print(paste0("Instance ",n," fails to reduce determined estimate."))
        }
        testresult3<-testresult2
      })
      testresult2<-testresult3
      attempts<-attempts+1
    }

    if(!is.null(testresult2))
    {
      testresult<-testresult2
    } else
    {
      testresult<-testresult1
    }
  }

}
