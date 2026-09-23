##########################################################################################
# Estimating RSiena models and score-testing factors
##########################################################################################

EstimateParameters <- function(name,mydata,myeff,n3,nsub,n2start,firstg,reps,thetabound,time_limit=NULL)
{
  #This function estimates the parameters the number of times suggested by the reps. This is to prevent those really weird ones where a convergence is not found or a really high convergences is found but it doesn't reflect the whole estimation.
  # name <- string of the participant name
  # mydata <- an Rsiena object
  # myeff <- an Rsiena object
  # n3 <- a number describing how many times to test the network in phase 3 (this is adjusted when working to lower convergence)
  # nsub <- a number describing the number of subphases used in phase 2 (this is adjusted when working to lower convergence)
  # n2start <- a number describing how big the subphases are in phase 2 (this is adjusted when working to lower convergence) except that the number fed here describes how many time bigger it is than the default not the number itself.
  # firstg <- a number describing something in phase 2 (this is adjusted when working to lower convergence)
  # rep <- a number describing how many times to run the estimation to prevent weird stuff
  tries<-list()
  cons<-c()
  catch_error<<-FALSE

  numfactors=length(which(myeff$include==TRUE))-1

  if (!is.null(time_limit))
  {
    setTimeLimit(elapsed = (reps*(20*numfactors+time_limit)), transient = TRUE)
  }
  n2start=n2start*(sum(myeff$include, na.rm=TRUE)+7)*2.52 #calculate the actual n2start from the multiplier

  t<-1
  while (t <= reps)
  {
    print(t)
    tryCatch({
      myalgorithm <- sienaAlgorithmCreate(projname = name,n3=n3,nsub=nsub,firstg=firstg,cond=FALSE,n2start=n2start) #creates the Rsiena algorithm based on the parameters set here

      ans <- siena07(myalgorithm, data = mydata, effects = myeff, silent=TRUE, batch=TRUE, verbose=FALSE, thetaBound = thetabound) #This tries to estimate if it doesn't work this will try again. If it happens more than once it will crash out.

      tries[[t]]<-ans
      cons[t]<-ans$tconv.max
      print(ans$tconv.max)
      if(ans$tconv.max<5)
      {
        t<-reps
      }
      t<-t+1
    }, error = function(ex){
      print("ERROR!!")
      tries[[t]]<<-"Error"
      cons[t]<<-1000000
      t<<-t+1
      firstg<<-0.005
      n3<-5000
    })
  }

  print(cons)
  if (!is.null(time_limit))
  {
    on.exit(setTimeLimit(elapsed = -1))
  }

  index<-which(cons==min(cons)) #find the lowest convergence of all the tries
  if(min(cons)==1000000)
  {
    return (NULL)
  } else
  {
    return (tries[[index]])
  }

}

JustBase <- function(name,mydata,myeff,n3,nsub,n2start,firstg,reps)
{
  # Not used by the procedure.
  myeff$include[myeff$shortName=="density"]=FALSE
  tryCatch({
    justbase<-EstimateParameters(name,mydata,myeff,n3,nsub,n2start,firstg,reps,thetabound)
    base1<-justbase$theta[1]
    base2<-justbase$theta[2]
  },error=function(cond)
  {
    base1<-NULL
    base2<-NULL
  })
  return (list(base1,base2))
}

ScoreTestEffect <- function(netname,mydata,effects,est,repeats,numattempts)
{
  #This function score-tests the effects marked with test=TRUE in effects. The model is estimated with those effects fixed at 0 and the score test says whether adding them would improve the model.
  # effects <- an Rsiena effects object with the tested effects set to include, fix and test
  # est <- list of estimation settings (n3, nsub, n2start, firstg, reps, thetabound, time_limit)
  # repeats <- how many score tests to run so the results can be averaged
  # numattempts <- how many times to try each estimation before one last try without the time limit
  # Returns the chi-square and p-value of each repeat and how many times the last try was needed.
  chisquare<-c()
  pvalue<-c()
  fallbacks<-0
  this<-1
  while(this<=repeats)
  {
    test2<-NULL
    attempts<-1
    while(is.null(test2) && attempts<=numattempts)
    {
      tryCatch({
        test2<-EstimateParameters(netname,mydata,effects,est$n3,est$nsub,est$n2start,est$firstg,est$reps,est$thetabound,est$time_limit)
      },error=function(cond)
      {
        test2<-NULL
      })
      attempts<-attempts+1
    }
    if (is.null(test2))
    {
      fallbacks<-fallbacks+1
      tryCatch({
        test2<-EstimateParameters(netname,mydata,effects,est$n3,est$nsub,est$n2start,est$firstg,est$reps,est$thetabound)
      },error=function(cond)
      {
        test2<-NULL
      })
    }
    result<-score.Test(test2)
    chisquare[this]<-result$chisquare
    pvalue[this]<-result$pvalue
    this<-this+1
  }
  return (list(chisquare=chisquare,pvalue=pvalue,fallbacks=fallbacks))
}
