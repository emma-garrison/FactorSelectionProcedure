##########################################################################################
# Finding factors by name
##########################################################################################

FactorLabels <- function(facts)
{
  #This function turns factor names saved in a results file ("<modality>_<factor>") into
  #candidate factor labels ("<factor>,<modality>").
  labels<-c()
  for (fact in facts)
  {
    labels<-c(labels,paste0(substr(fact,unlist(gregexpr('_',fact))[[1]]+1,nchar(fact)),",",substr(fact,1,unlist(gregexpr('_',fact))[[1]]-1)))
  }
  return (labels)
}

EffectIndices <- function(effects,labels)
{
  #This function finds where factors (labelled "<factor>,<modality>") are in an estimate's
  #effects object. RSiena does not always order effects like the factor lists in config.R
  #(it doesn't for combined models), so they are looked up by name.
  effectlabels<-paste0(effects$shortName,",",sub("_.*","",effects$name))
  return (which(effectlabels %in% labels & effects$type=="eval"))
}
