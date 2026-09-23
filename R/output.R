##########################################################################################
# Where results and checkpoints are written
##########################################################################################

DATASET_FOLDERS<-c(real_data="RealDataResults",
                   individual_model_set="IndividualModelSetResults",
                   group_model_set="GroupModelSetResults")

DatasetFolder <- function(folderhead,dataset)
{
  # <results_dir>/<fMRI|DTI|Combined><RealData|IndividualModelSet|GroupModelSet>Results/
  return (paste0(cfg$paths$results_dir,'/',folderhead,DATASET_FOLDERS[[dataset]],'/'))
}

ResultsFolder <- function(folderhead,dataset,rate,Subject=NULL)
{
  # Real data:            <dataset folder>/<participant>/
  # Simulated datasets:   <dataset folder>/Rate<rate>/
  if (dataset=="real_data")
  {
    return (paste0(DatasetFolder(folderhead,dataset),Subject,'/'))
  }
  return (paste0(DatasetFolder(folderhead,dataset),'Rate',as.character(rate),'/'))
}

OutputLocation <- function(folderhead,dataset,type3,typeA,rate,FSname,Subject=NULL,Window=NULL)
{
  #This function creates the results folder for this run and returns the prefix every output file name starts with.
  # Functional system runs get their own sub-folder (simulated datasets) or file prefix (real data).
  # Combined group model set runs mark the modality modelled: fMRIWindow (typeA 1), DTIWindow (typeA 2).
  folder<-ResultsFolder(folderhead,dataset,rate,Subject)
  dir.create(folder,showWarnings=FALSE,recursive=TRUE)
  if (dataset=="real_data")
  {
    return (paste0(folder,FSname,'Window',as.character(Window),'_'))
  }
  if (type3!=1)
  {
    folder<-paste0(folder,FSname,'/')
    dir.create(folder,showWarnings=FALSE,recursive=TRUE)
  }
  prefix<-''
  if (dataset=="group_model_set" && typeA==1) prefix<-'fMRI'
  if (dataset=="group_model_set" && typeA==2) prefix<-'DTI'
  return (paste0(folder,prefix,'Window'))
}

CheckpointFile <- function(stage)
{
  # The procedure saves its whole state after every step so a job that runs out of time can pick up where it stopped.
  # Stage 0 (setup) and 1 (all-factors estimate) are shared by all copies of an instance.
  # Stage 2 (the Factor Selection Procedure and final model) is separate for each copy, so copies repeat it from the same start.
  if (stage==2)
  {
    return (paste0(saveloc,as.character(n),'_copy',as.character(copy),'Data2.RData'))
  }
  return (paste0(saveloc,as.character(n),'Data',as.character(stage),'.RData'))
}

LoadCheckpoint <- function(file)
{
  # Loads a checkpoint into the global environment. A checkpoint holds every variable,
  # including the run arguments, settings and functions of the job that saved it, so those
  # are put back afterwards. Otherwise a copy that loads a checkpoint saved by another copy
  # would take on its copy number, and code changes would not apply to continuing jobs.
  keep<-c(RUN_ARGS,"RUN_ARGS","dataset","cfg","repo_dir")
  keep<-c(keep,Filter(function(x) is.function(get(x,envir=globalenv())),ls(globalenv())))
  saved<-mget(keep,envir=globalenv())
  load(file,envir=globalenv())
  list2env(saved,envir=globalenv())
  invisible(NULL)
}

ResultFile <- function(saveloc,dataset,n,modelnumber,copy)
{
  # Final results: <saveloc><n>_copy<copy>.mat, or <saveloc><model>_<n>_copy<copy>.mat for the group model set.
  if (dataset=="group_model_set")
  {
    return (paste0(saveloc,as.character(modelnumber),'_',as.character(n),'_copy',as.character(copy),'.mat'))
  }
  return (paste0(saveloc,as.character(n),'_copy',as.character(copy),'.mat'))
}

MarkCompleted <- function(folderhead,dataset,rate,callit)
{
  # Writes <results folder>/Completed/<callit>.txt so finished runs are easy to count.
  folder<-if (dataset=="real_data") DatasetFolder(folderhead,dataset) else ResultsFolder(folderhead,dataset,rate)
  dir.create(paste0(folder,'Completed/'),showWarnings=FALSE,recursive=TRUE)
  fileConn<-file(paste0(folder,'Completed/',callit,'.txt'))
  writeLines("Completed", fileConn)
  close(fileConn)
}

Announce <- function(part,step)
{
  # Marks in the log where the procedure is, e.g. "All-Pairs Initialization > Score all pairs".
  print(paste0("==== ",part," > ",step," ===="))
}
