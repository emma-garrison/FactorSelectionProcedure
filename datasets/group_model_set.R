##########################################################################################
# Group model set: this instance's model and simulated window
#
# Instances 1 to initializecount each draw a model. Every later instance loads one of those
# models (imnum instances per model) and simulates another window from it: a random real
# network is time point 1 and time point 2 is simulated from it with the model.
#
# Combined runs share one model and one pair of simulated networks between the fMRI
# (TYPEA 1), DTI (TYPEA 2) and combined (TYPEA 3) runs, mirroring the real data.
##########################################################################################

if (INIT==FALSE)
{
  initializecount<-sum(numbers)
  numfactorslist<-c(rep(0:(length(numbers)-1),times=numbers),rep(0:(length(numbers)-1),times=numbers*imnum))
  modelloc<-gsub('(fMRI|DTI)Window','Window',saveloc)

  if(n<=initializecount)
  {
    #This instance draws the model
    modelnumber<-n
    nfac<-numfactorslist[n]
    sel<-Selection(N,type1,type3,nfac,rate=rate*(N/100))
    setfactors<-sel$weights
    expectedbaserate<-sel$rate
    instance<-1
    if (type1==3 && typeA!=1)
    {
      # The fMRI run already drew this model
      load(paste0(modelloc,as.character(modelnumber),'.RData'))
    }else
    {
      save(setfactors,expectedbaserate,sel,file=paste0(modelloc,as.character(modelnumber),'.RData'))
    }
    print('Model:')
    print(setfactors)
  } else
  {
    #Another window from a model drawn by an earlier instance
    modelnumber<-ceiling((n-initializecount)/imnum)
    load(paste0(modelloc,as.character(modelnumber),'.RData'))
    print('Model:')
    print(setfactors)
    instance<-(((n-initializecount)-1) %% imnum)+2
  }

  print(paste0('Model: ',modelnumber))
  print(paste0('Instance: ',instance))
  print(paste0('Overall Instance: ',n))
  if(type3!=1)
  {
    print(paste0('Subnet: ',FSname))
  }
}

if (INIT==FALSE && Pause==FALSE)
{
  netname<-as.character(n)
  if(type1==1)
  {
    randomnet<-sample(1:length(windowsf),1)
    t1f<-windowsf[[randomnet]][,,1]
    t1s<-NULL
  }
  if(type1==2)
  {
    randomnet<-sample(1:length(windowss),1)
    t1s<-windowss[[randomnet]][,,1]
    t1f<-NULL
  }
  if(type1==3)
  {
    # The fMRI run simulates both networks and saves them for the DTI and combined runs
    networksfile<-paste0(gsub('(fMRI|DTI)Window','Window',saveloc),as.character(n),'Networks.RData')
    if(typeA==1)
    {
      randomnet<-sample(1:length(windowsf),1)
      t1f<-windowsf[[randomnet]][,,1]
      t1s<-windowss[[randomnet]][,,1]

      produced <- ProduceNetworksfromFactors(N,netname,2,t1f,t1s,expectedbaserate,setfactors,covariates,varcovariates,dycovariates,vardycovariates)
      t2f<-produced[[paste0("fMRI_",netname)]][[1]]
      t2s<-produced[[paste0("DTI_",netname)]][[1]]

      save(t1f,t2f,t1s,t2s,randomnet,file=networksfile)
      t1s<-NULL
      t2s<-NULL
    }else if (typeA==2)
    {
      load(networksfile)
      t1f<-NULL
      t2f<-NULL
    }else
    {
      # Both modalities: start from the factors the fMRI and DTI runs found
      load(networksfile)
      readinf<-readMat(ResultFile(gsub('Window',"fMRIWindow",saveloc),dataset,n,modelnumber,copy))
      facts_f<-readinf$determinedfactors
      readins<-readMat(ResultFile(gsub('Window',"DTIWindow",saveloc),dataset,n,modelnumber,copy))
      facts_s<-readins$determinedfactors
      seedfactors<-c(seedfactors,FactorLabels(facts_f),FactorLabels(facts_s))
    }
  }else
  {
    #Time point 2: simulated from time point 1 with the model
    produced <- ProduceNetworksfromFactors(N,netname,2,t1f,t1s,expectedbaserate,setfactors,covariates,varcovariates,dycovariates,vardycovariates)
    t2f<-produced[[paste0("fMRI_",netname)]][[1]]
    t2s<-produced[[paste0("DTI_",netname)]][[1]]
  }
}
