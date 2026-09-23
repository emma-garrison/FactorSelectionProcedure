##########################################################################################
# Setup 4: settings and candidate factors
##########################################################################################

###################SETTING PARAMETERS###############################
#Standard Rsiena Parameters
n3<-cfg$siena$n3
nsub<-cfg$siena$nsub
n2start<-cfg$siena$n2start
firstg<-cfg$siena$firstg
thetabound<-cfg$siena$thetabound
#Convergence Reduction Rsiena Parameters
n3f<-cfg$siena$reduction$n3
nsubf<-cfg$siena$reduction$nsub
n2startf<-cfg$siena$reduction$n2start
firstgf<-cfg$siena$reduction$firstg
#Procedural Parameters
thresh<-cfg$procedure$p_threshold
reps<-cfg$procedure$reps
time_limit<-cfg$procedure$time_limit
afattempts<-cfg$procedure$all_factors_tries
sameexamples<-cfg$simulation$subnetwork_repeats
initializecount<-0
seedfactors<-c() # factors a combined run starts from ("<factor>,<modality>")

##################FACTOR DETAILS################################
# selfactors are the candidate factors ("<factor>,<modality>") and facindexO their
# positions in the effects object. The sub* versions are for the subnetwork runs
# that follow a whole-brain run.
fs<-FactorSet(Modalities(type1),type3==1)
factors<-fs$factors
facindexO<-fs$facindex
selfactors<-fs$selfactors
subfactors<-fs$subfactors
subfacindex<-fs$subfacindex
subselfactors<-fs$subselfactors

if (type1==3)
{
  # Combined runs: the *R sets are the factors actually searched. The combined group model
  # set first models each modality on its own (TYPEA 1 = fMRI, 2 = DTI), then both (TYPEA 3).
  if (dataset=="group_model_set" && typeA!=3)
  {
    fsR<-FactorSet(if (typeA==1) "fMRI" else "DTI",type3==1)
  }else
  {
    fsR<-fs
  }
  factorsR<-fsR$factors
  facindexR<-fsR$facindex
  selfactorsR<-fsR$selfactors
  subfactorsR<-fsR$subfactors
  subfacindexR<-fsR$subfacindex
  subselfactorsR<-fsR$subselfactors
}

#Simulated datasets: how many of the models have 0, 1, 2, ... factors
if (dataset=="individual_model_set")
{
  Tot<-cfg$simulation$individual_model_set$models
  numbers<-NumFactorsDistribution(facindexO,Tot,cfg$simulation$individual_model_set$bias)
}
if (dataset=="group_model_set")
{
  Tot<-cfg$simulation$group_model_set$windows
  imnum<-cfg$simulation$group_model_set$windows_per_model
  numbers<-NumFactorsDistribution(facindexO,round(Tot/imnum),cfg$simulation$group_model_set$bias)
}
