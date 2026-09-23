##########################################################################################
# Factor Selection Procedure > 0. Starting point > prepare the networks
#
# Group 0 is the network chosen by TYPE3. Groups 1-7 cut the whole-brain networks down to
# one functional system and use the smaller subnetwork factor set.
##########################################################################################

# Which modalities are modelled: combined model selection models fMRI (TYPEA 1) or DTI
# (TYPEA 2) alone before modelling both
usef<-type1==1 || (type1==3 && typeA!=2)
uses<-type1==2 || (type1==3 && typeA!=1)

if(g==0)
{
  print("Run Everything Normally")
  if (type3==1)
  {
    N<-cfg$num_regions
    FSname<-NULL
    FSCovarList<-list("FunctionalSystems","categorical",FS)
    covariates<-list(FSCovarList)
    varcovariates<-list()
    DistDyCovarList<-list("Distance","continuous",DistMat)
    dycovariates<-list(DistDyCovarList)
    vardycovariates<-list()
  }
  dataf<-if (usef) array(c(t1f,t2f), dim=c(N,N,2)) else NULL
  datas<-if (uses) array(c(t1s,t2s), dim=c(N,N,2)) else NULL

  includefactors<-selfactors
  facindex<-facindexO
  saveloc<-originalsaveloc
  save.image(CheckpointFile(0))

  if (type1==3)
  {
    includefactors<-selfactorsR
    facindex<-facindexR
  }
}else
{
  print("Run A Subnet")
  N<-sum(FS==g)
  dataf<-if (usef) array(c(t1f[FS==g,FS==g],t2f[FS==g,FS==g]), dim=c(N,N,2)) else NULL
  datas<-if (uses) array(c(t1s[FS==g,FS==g],t2s[FS==g,FS==g]), dim=c(N,N,2)) else NULL

  covariates<-list()
  varcovariates<-list()
  SubDistMat=DistMat[FS==g,FS==g]
  DistDyCovarList<-list("Distance","continuous",SubDistMat)
  dycovariates<-list(DistDyCovarList)
  vardycovariates<-list()

  includefactors<-subselfactors
  facindex<-subfacindex
  if (type1==3)
  {
    includefactors<-subselfactorsR
    facindex<-subfacindexR
  }

  saveloc<-gsub('Window', paste0(FSnames[g],"Window"), originalsaveloc)
  print(saveloc)

  ChiMat<-matrix(NA,nrow=facindex[[length(facindex)]],ncol=facindex[[length(facindex)]])
  PMat<-matrix(NA,nrow=facindex[[length(facindex)]],ncol=facindex[[length(facindex)]])
  cfacindex<-facindex
}
