##########################################################################################
# Individual model set: this instance's model and simulated window
#
# Instance n draws its own model with numfactorslist[n] factors (random factors, each with
# a weight drawn from the factor weights file). A random real network is time point 1 and
# time point 2 is simulated from it with the model.
##########################################################################################

if (INIT==FALSE)
{
  numfactorslist<-rep(0:(length(numbers)-1),times=numbers)

  modelnumber<-n
  nfac<-numfactorslist[n]
  print(type1)
  sel<-Selection(N,type1,type3,nfac,rate=rate*(N/100))
  setfactors<-sel$weights
  expectedbaserate<-sel$rate
  save(setfactors,expectedbaserate,sel,file=paste0(saveloc,as.character(modelnumber),'.RData'))

  print(paste0('Instance: ',n))
  print('Model:')
  print(setfactors)
}

if (INIT==FALSE && Pause==FALSE)
{
  netname<-as.character(n)
  #Time point 1: a random real network (for combined runs, a random pair of fMRI and DTI networks)
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
    randomnet<-sample(1:length(windowsf),1)
    t1f<-windowsf[[randomnet]][,,1]
    t1s<-windowss[[randomnet]][,,1]
  }
  #Time point 2: simulated from time point 1 with the model
  produced <- ProduceNetworksfromFactors(N,netname,2,t1f,t1s,expectedbaserate,setfactors,covariates,varcovariates,dycovariates,vardycovariates)
  t2f<-produced[[paste0("fMRI_",netname)]][[1]]
  t2s<-produced[[paste0("DTI_",netname)]][[1]]
}
