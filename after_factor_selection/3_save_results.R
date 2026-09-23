##########################################################################################
# After the Factor Selection Procedure 3: save the results
#
# One .mat file per instance and copy with the networks, the factors found (determined...)
# and, for the simulated datasets, the model that generated the networks (goal...).
##########################################################################################

if (reducing)
{
  if(exit1==FALSE && exit2==FALSE && exit3==FALSE)
  {
    # Split the estimates into rates and factor weights, named "<modality>_<factor>"
    finalweights<-list()
    finalfactors<-c()
    finalerrors<-list()
    rates<-list()
    rateerrors<-list()
    iv<-1
    for (p in 1:length(testresult$effects$include==TRUE))
    {
      if(testresult$effects$shortName[[p]]!="Rate")
      {
        thename<-testresult$effects$name[[p]]
        theshortname<-testresult$effects$shortName[[p]]
        thefactorname<-paste0(substr(thename,1,unlist(gregexpr('_',thename))[[1]]-1),'_',theshortname)
        finalfactors[iv]<-thefactorname
        finalweights[thefactorname]<-testresult$theta[p]
        finalerrors[thefactorname]<-testresult$se[p]
        iv<-iv+1
      }else
      {
        thename<-testresult$effects$name[[p]]
        rates[substr(thename,1,unlist(gregexpr('_',thename))[[1]]-1)]<-testresult$theta[p]
        rateerrors[substr(thename,1,unlist(gregexpr('_',thename))[[1]]-1)]<-testresult$se[p]
      }
    }

    # The two networks that were modelled. Combined runs save the fMRI networks as t1/t2
    # and the DTI networks as t1DTI/t2DTI.
    modelled<-if (!is.null(dataf)) dataf else datas
    t1<-modelled[,,1]
    t2<-modelled[,,2]
    networks<-list(t1density=100*sum(t1)/(N*(N-1)),
                   t2density=100*sum(t2)/(N*(N-1)),
                   t1=t1,
                   t2=t2)
    if (!is.null(dataf) && !is.null(datas))
    {
      networks<-c(networks,list(t1DTIdensity=100*sum(datas[,,1])/(N*(N-1)),
                                t2DTIdensity=100*sum(datas[,,2])/(N*(N-1)),
                                t1DTI=datas[,,1],
                                t2DTI=datas[,,2]))
    }
    
    # Real data: the participant's ages. Simulated datasets: the model that generated the networks (goal).
    if (dataset=="real_data")
    {
      about<-list(age1=age1,age2=age2)
    }else
    {
      about<-list(goalrate=sel$rate,
                  goalfactors=sel$factors,
                  goalweights=sel$weights)
      if (dataset=="group_model_set")
      {
        about<-c(list(modelnumber=modelnumber),about)
      }
    }
    
    # The factors found
    found<-list(determinedrates=rates,
                determinedrateerrors=rateerrors,
                determinedfactors=finalfactors,
                determinedweights=finalweights,
                determinederrors=finalerrors,
                determinedconvergence=testresult$tconv.max)
    
    do.call(writeMat,c(list(ResultFile(saveloc,dataset,n,modelnumber,copy),N=N),networks,about,found))
    if(g!=0)
    {
      Exceptions<-rbind(Exceptions,(facindex %in% exceptions)*1)
    }
  }else
  {
    print("Failure")
  }
}
