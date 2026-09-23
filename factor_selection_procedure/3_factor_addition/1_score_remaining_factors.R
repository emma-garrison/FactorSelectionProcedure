##########################################################################################
# Factor Selection Procedure > 3. Factor Addition > score the remaining factors
#
# Score-tests every factor not yet in the model against the current model.
##########################################################################################

test$effects$include[unlist(exceptions)]<-TRUE
test$effects$fix[unlist(exceptions)]<-FALSE
test$effects$test[unlist(exceptions)]<-FALSE

if (Pause==FALSE && MTR==TRUE)
{
  Announce("Factor Addition","Score the remaining factors")
  Chi1<-rep(NA,length=facindex[[length(facindex)]])
  P1<-rep(NA,length=facindex[[length(facindex)]])

  thisrunstart<-Now()

  clu<-makeCluster(1)
  registerDoParallel(clu)
  each<-foreach(iii=1:length(facindex),.errorhandling="pass")%dopar%{
    library(RSiena)
    library(R.matlab)
    library(R.utils)
    library(parallel)
    library(foreach)
    library(doParallel)
    a<-facindex[iii]
    temp1<-NA
    temp2<-NA
    if (a %in% exceptions==FALSE)
    {
      test$effects$include[a]<-TRUE
      test$effects$fix[a]<-TRUE
      test$effects$test[a]<-TRUE

      test$effects$include[facindex[!(facindex %in% exceptions) & facindex!=a]]<-FALSE

      scored<-ScoreTestEffect(netname,mydata,test$effects,est,repeats,numattempts)
      temp1<-scored$chisquare
      temp2<-scored$pvalue
    }
    myreturn<-list(temp1,temp2)
    return(myreturn)
  }
  stopCluster(clu)
  for (iii in 1:length(facindex))
  {
    a<-facindex[[iii]]
    if (a %in% exceptions==FALSE)
    {
      print(a)
      Chi1[a]<-mean(na.exclude(each[[iii]][[1]]))
      P1[a]<-mean(na.exclude(each[[iii]][[2]]))
    }
  }

  Bool1<-P1<thresh & !is.na(P1)

  print(P1)

  timer<-RecordStep(timer,thisrunstart)

  MTR<-FALSE

  #Decide if Continuing
  if (OutOfTime(timer))
  {
    Pause<-TRUE
    print("PAUSED")
  }
  save.image(CheckpointFile(2))
}
