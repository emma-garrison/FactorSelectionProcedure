##########################################################################################
# Factor Selection Procedure > Preparation > start or continue
#
# exceptions holds the effect indices of the factors in the current model. Everything from
# here on is saved in checkpoint 2, which is separate for each copy.
##########################################################################################

exit2<-FALSE
exit3<-FALSE
final<-NULL

# Whether the Factor Selection Procedure still has work to do for this group
searching<-INIT==TRUE && AF==TRUE && AFS==TRUE && PP==FALSE && Pause==FALSE

if (searching)
{
  if (dataset=="real_data")
  {
    print(paste0("Factor Selection Procedure for Subject: ",Subject," Window: ",Window," ."))
  }else
  {
    print(paste0("Factor Selection Procedure for Instance: ",n))
  }

  if(file.exists(CheckpointFile(2)))
  {
    #This means we had something to load for the second part of this process
    LoadCheckpoint(CheckpointFile(2))
    Pause<-FALSE
    n3<-cfg$siena$n3_search
    timer<-RestartTimer(timer)
    print("CONTINUING 2")
  } else
  {
    exit<-FALSE
    # Combined runs start from the factors found for each modality on its own
    exceptions<-as.list(EffectIndices(test$effects,seedfactors[seedfactors %in% includefactors]))
    if (length(exceptions)!=0)
    {
      print("Starting from factors:")
      print(seedfactors[seedfactors %in% includefactors])
    }
    override<-1
    ChiMat<-matrix(NA,nrow=facindex[[length(facindex)]],ncol=facindex[[length(facindex)]])
    PMat<-matrix(NA,nrow=facindex[[length(facindex)]],ncol=facindex[[length(facindex)]])
    cfacindex<-facindex
    Pause<-FALSE
    AF<-TRUE
    APMTR<-FALSE
    PP<-FALSE
    PS<-FALSE
    MTR<-TRUE
    numattempts<-cfg$procedure$search_attempts
    repeats<-cfg$procedure$search_repeats
    exit1<-FALSE
    exit2<-FALSE
    exit3<-FALSE
    n3<-cfg$siena$n3_search
    print("INITIALIZING 2")
    save.image(CheckpointFile(2))
  }

  # Estimation settings for every score test
  est<-list(n3=n3,nsub=nsub,n2start=n2start,firstg=firstg,reps=reps,thetabound=thetabound,time_limit=time_limit)

  test$effects$include[unlist(exceptions)]<-TRUE
  test$effects$fix[unlist(exceptions)]<-FALSE
  test$effects$test[unlist(exceptions)]<-FALSE

  # Combined runs that start from earlier factors skip the pair scoring
  seeded<-length(exceptions)!=0
}
