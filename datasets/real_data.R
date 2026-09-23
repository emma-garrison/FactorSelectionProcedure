##########################################################################################
# Real data: the networks of window n
#
# The two scans of the n-th window across all participants. Combined runs also start from
# the factors the fMRI and DTI real data runs found for the same window.
##########################################################################################

if (INIT==FALSE && Pause==FALSE)
{
  netname<-as.character(n)
  if (type1==1)
  {
    t1f<-windowsf[[n]][,,1]
    t2f<-windowsf[[n]][,,2]
    t1s<-NULL
    t2s<-NULL
    age1<-Ages1f[n]
    age2<-Ages2f[n]
  }
  if (type1==2)
  {
    t1s<-windowss[[n]][,,1]
    t2s<-windowss[[n]][,,2]
    t1f<-NULL
    t2f<-NULL
    age1<-Ages1s[n]
    age2<-Ages2s[n]
  }
  if (type1==3)
  {
    t1f<-windowsf[[n]][,,1]
    t2f<-windowsf[[n]][,,2]
    t1s<-windowss[[n]][,,1]
    t2s<-windowss[[n]][,,2]
    age1<-Ages1f[n]
    age2<-Ages2f[n]
    facts_f<-factorsf[[n]]
    facts_s<-factorss[[n]]
    seedfactors<-c(seedfactors,FactorLabels(facts_f),FactorLabels(facts_s))
  }
}
