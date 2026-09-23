##########################################################################################
# Factor Selection Procedure > 1. All-Pairs Initialization > score all pairs
#
# For every pair of candidate factors (a, b): put a in the model and score-test b. This
# gives a matrix of chi-squares (ChiMat) and p-values (PMat) with a row for each a.
# Each a is one step, run in parallel over b; cfacindex holds the a's still to do, so a
# continuing job skips the finished ones.
##########################################################################################

if (searching && !seeded)
{
  Announce("All-Pairs Initialization","Score all pairs")
  print(cfacindex)
  for (a in cfacindex)
  {
    if (Pause==FALSE)
    {
      print(a)
      thisrunstart<-Now()
      clu<-makeCluster(2)
      registerDoParallel(clu)
      each<-foreach(iii=1:length(facindex),.combine=cbind,.errorhandling="pass")%dopar%{
        b<-facindex[iii]
        print(b)
        library(RSiena)
        library(R.matlab)
        library(R.utils)
        library(parallel)
        library(foreach)
        library(doParallel)
        temp1<-NA
        temp2<-NA
        print("ALL PAIRS")
        if (a %in% exceptions==FALSE & b %in% exceptions==FALSE)
        {
          if(a != b)
          {
            # a is in the model, b is tested, every other candidate is left out
            test$effects$include[a]<-TRUE
            test$effects$fix[a]<-FALSE
            test$effects$test[a]<-FALSE
            test$effects$include[b]<-TRUE
            print(a)
            print(b)

            test$effects$include[facindex[!(facindex %in% exceptions) & facindex!=a & facindex!=b]]<-FALSE

            test$effects$fix[b]<-TRUE
            test$effects$test[b]<-TRUE
            scored<-ScoreTestEffect(netname,mydata,test$effects,est,repeats,numattempts)
            temp1<-scored$chisquare
            temp2<-scored$pvalue
          }
        }

        myreturn<-list(temp1,temp2)
        return(myreturn)
      }
      stopCluster(clu)

      for (iii in 1:(length(facindex)))
      {
        b<-facindex[iii]
        if (a %in% exceptions==FALSE & b %in% exceptions==FALSE)
        {
          if(a != b)
          {
            print(b)
            ChiMat[a,b]<-mean(na.exclude(each[[1,iii]]))
            PMat[a,b]<-mean(na.exclude(each[[2,iii]]))
          }
        }
      }

      timer<-RecordStep(timer,thisrunstart)

      if(which(cfacindex==a)==length(cfacindex))
      {
        print("End of a and b")
        #we want to skip this loop now because we finished it
        cfacindex<-c()
      }else
      {
        print("End of b NOT End of a")
        #move on to next outer
        cfacindex<-cfacindex[(which(cfacindex==a)+1):(length(cfacindex))]
      }

      #Decide if Continuing
      if (OutOfTime(timer))
      {
        #If pausing, save cfacindex as the remaining outers
        Pause<-TRUE
        print("PAUSED")
      }

      save.image(CheckpointFile(2))
    }
  }
}
