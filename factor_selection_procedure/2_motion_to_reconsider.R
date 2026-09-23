##########################################################################################
# Factor Selection Procedure > 2. Motion to Reconsider
#
# Every time a factor is added to the model (by All-Pairs Initialization or Factor Addition),
# every factor in the model is score-tested again with all the others kept in. Any factor
# whose p-value is now above the threshold is dropped.
#
# This file defines the function; the steps that use it are
#   1_all_pairs_initialization/3_motion_to_reconsider.R
#   3_factor_addition/3_motion_to_reconsider.R
##########################################################################################

MotionToReconsider <- function(test,exceptions,facindex,thresh,netname,mydata,est,repeats,numattempts)
{
  #This function re-tests every factor in the model (exceptions) with all the others kept in.
  #Any factor that is no longer significant (p-value above thresh) is taken back out.
  # test <- the all-factors estimate, whose effects object is edited for each test
  # exceptions <- effect indices of the factors currently in the model
  # Returns the edited effects object, the factors still in the model, the re-test results
  # and how many estimations needed a last try without the time limit.
  print("MOTION TO RECONSIDER")
  ReconChi<-rep(NA,length=facindex[[length(facindex)]])
  ReconP<-rep(NA,length=facindex[[length(facindex)]])
  fallbacks<-0

  for (e in exceptions[1:length(exceptions)])
  {
    print(e)
    test$effects$include[facindex[!(facindex %in% exceptions)]]<-FALSE
    test$effects$fix[facindex[!(facindex %in% exceptions)]]<-FALSE
    test$effects$test[facindex[!(facindex %in% exceptions)]]<-FALSE
    test$effects$include[facindex[(facindex %in% exceptions)]]<-TRUE
    test$effects$fix[facindex[(facindex %in% exceptions)]]<-FALSE
    test$effects$test[facindex[(facindex %in% exceptions)]]<-FALSE

    test$effects$fix[e]<-TRUE
    test$effects$test[e]<-TRUE
    scored<-ScoreTestEffect(netname,mydata,test$effects,est,repeats,numattempts)
    fallbacks<-fallbacks+scored$fallbacks
    ReconChi[e]<-mean(scored$chisquare)
    ReconP[e]<-mean(scored$pvalue)
  }
  print(ReconP)
  cuts<-which(ReconP>thresh)
  for (t in cuts)
  {
    print("Reconsidering:")
    print(t)
    exceptions<-exceptions[which(exceptions==t)*-1]
  }
  return (list(test=test,exceptions=exceptions,ReconChi=ReconChi,ReconP=ReconP,fallbacks=fallbacks))
}
