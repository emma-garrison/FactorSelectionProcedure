##########################################################################################
# Setup 1: reference data
#
# Every brain region belongs to one of seven functional systems. Whole-brain models use the
# functional system of each region as a node covariate and the distance between regions as
# a dyadic covariate; functional system models keep only that system's regions.
##########################################################################################

FSFile<-read.delim(file.path(cfg$paths$data_dir,cfg$files$functional_systems),header=FALSE,sep = "\t")
FS<-c(FSFile[[2]])
FSnames<-cfg$functional_systems
DistTab<-read.csv(file.path(cfg$paths$data_dir,cfg$files$distance_matrix),header=FALSE)
DistMat<-array(unlist(DistTab),dim = dim(DistTab))

if (type3==1)
{
  FSname<-NULL
  N<-cfg$num_regions
  FSCovarList<-list("FunctionalSystems","categorical",FS)
  covariates<-list(FSCovarList)
  varcovariates<-list()
  DistDyCovarList<-list("Distance","continuous",DistMat)
  dycovariates<-list(DistDyCovarList)
  vardycovariates<-list()
}else
{
  FSname<-FSnames[type3-1]
  N<-sum(FS==(type3-1))
  covariates<-list()
  varcovariates<-list()
  SubDistMat=DistMat[FS==(type3-1),FS==(type3-1)]
  DistDyCovarList<-list("Distance","continuous",SubDistMat)
  dycovariates<-list(DistDyCovarList)
  vardycovariates<-list()
}
