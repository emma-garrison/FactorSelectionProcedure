##########################################################################################
# Candidate factors and randomly selected models
##########################################################################################

Modalities <- function(type1)
{
  # 1 = fMRI, 2 = DTI, 3 = both
  if (type1==1) return ("fMRI")
  if (type1==2) return ("DTI")
  return (c("fMRI","DTI"))
}

FactorSet <- function(modalities,wholebrain)
{
  #This function lists the candidate factors for a run and where they sit in the RSiena effects object.
  # modalities <- "fMRI", "DTI" or c("fMRI","DTI")
  # wholebrain <- TRUE for the whole brain, FALSE for a single functional system
  # Factors are labelled "<factor>,<modality>". In the effects object each modality starts
  # with its rate effect, so for k factors the indices are 2:(k+1) for the first modality
  # and (k+3):(2k+2) for the second. Within a modality RSiena may order the factors
  # differently from the lists in config.R, so use EffectIndices to find a particular one.
  # Whole-brain sets also include the smaller subnetwork set (sub*), used when a whole-brain
  # run goes on to re-run each functional system.
  combined<-length(modalities)==2
  EffectIndex <- function(k)
  {
    if (combined) c(2:(k+1),(k+3):(2*k+2)) else c(2:(k+1))
  }
  Label <- function(factors)
  {
    unlist(lapply(modalities,function(m) paste0(factors,",",m)))
  }

  if (wholebrain)
  {
    factors<-if (combined) cfg$factors$whole_brain_combined else cfg$factors$whole_brain
    subfactors<-if (combined) cfg$factors$subnetwork_combined else cfg$factors$subnetwork
    return (list(factors=factors,facindex=EffectIndex(length(factors)),selfactors=Label(factors),
                 subfactors=subfactors,subfacindex=EffectIndex(length(subfactors)),subselfactors=Label(subfactors)))
  }
  factors<-if (combined) cfg$factors$subnetwork_combined else cfg$factors$subnetwork
  return (list(factors=factors,facindex=EffectIndex(length(factors)),selfactors=Label(factors)))
}

Selection <- function(N,type1,type3,numfactors,rate=NULL,myfactors=NULL,weights=NULL)
{
  #This function randomly chooses a model: which factors are in it and what their weights are.
  # numfactors <- how many factors the model has
  # rate <- base rate for the model (random from cfg$simulation$rates if NULL)
  # myfactors, weights <- set these to fix the factors or weights instead of choosing them randomly
  # The weight of each factor is drawn from its candidate weights in the factor weights file.
  rates<-cfg$simulation$rates
  selfactors<-FactorSet(Modalities(type1),type3==1)$selfactors

  This<-readMat(file.path(cfg$paths$data_dir,cfg$files$factor_weights))
  params<-This[[paste0("factorweights.",as.character(type1),".",as.character(type3))]][,,1]

  if(is.null(rate))
  {
    rate<-sample(rates,1)
  }
  if(is.null(myfactors))
  {
    myfactors<-sample(selfactors,numfactors)
  }
  if(is.null(weights))
  {
    weights<-list()
    for (p in myfactors)
    {
      factor<-sub(",.*","",p)
      modality<-sub(".*,","",p)
      if (factor %in% names(cfg$factor_weight_names))
      {
        factor<-cfg$factor_weight_names[[factor]]
      }
      nm<-paste0(factor,".",modality)
      weight<-sample(params[[nm]],1)
      weights[[p]]=weight
    }
  }

  return (list(rate=rate,factors=myfactors,weights=weights))
}

NumFactorsDistribution <- function(facindex,total,b)
{
  #This function decides how many of the total models have 0, 1, 2, ... factors.
  # facindex <- effect indices of the candidate factors
  # total <- number of models
  # b <- the lower this number the more biased towards lower numbers the probabilities are.
  # Returns a vector whose i-th value is the number of models with i-1 factors.
  bias<-(length(facindex)+2)/(2*b)
  facc<-1:(length(facindex)+1)
  probss<-(-1/(((length(facindex)+2)/2)+bias))*((facc-(((length(facindex)+2)/2))+bias)^2)+((length(facindex)+2)/2)+bias
  S<-sample(1:(length(facindex)+1),total,prob=probss,replace=TRUE)
  numbers<-integer(length(facindex)+1)
  for (i in 1:length(S))
  {
    numbers[S[i]]<-numbers[S[i]]+1
  }
  return (numbers)
}
