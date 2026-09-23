##########################################################################################
# Setup 1: reference data
#
# Every brain region belongs to one of seven subnetworks. Whole-brain models use the
# subnetwork of each region as a node covariate and the distance between regions as
# a dyadic covariate; subnetwork models keep only that system's regions.
##########################################################################################

SNFile<-read.delim(file.path(cfg$paths$data_dir,cfg$files$subnetworks),header=FALSE,sep = "\t")
SN<-c(SNFile[[2]])
SNnames<-cfg$subnetworks
DistTab<-read.csv(file.path(cfg$paths$data_dir,cfg$files$distance_matrix),header=FALSE)
DistMat<-array(unlist(DistTab),dim = dim(DistTab))

if (type3==1)
{
  SNname<-NULL
  N<-cfg$num_regions
  SNCovarList<-list("Subnetworks","categorical",SN)
  covariates<-list(SNCovarList)
  varcovariates<-list()
  DistDyCovarList<-list("Distance","continuous",DistMat)
  dycovariates<-list(DistDyCovarList)
  vardycovariates<-list()
}else
{
  SNname<-SNnames[type3-1]
  N<-sum(SN==(type3-1))
  covariates<-list()
  varcovariates<-list()
  SubDistMat=DistMat[SN==(type3-1),SN==(type3-1)]
  DistDyCovarList<-list("Distance","continuous",SubDistMat)
  dycovariates<-list(DistDyCovarList)
  vardycovariates<-list()
}
