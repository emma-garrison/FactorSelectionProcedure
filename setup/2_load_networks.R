##########################################################################################
# Setup 2: load the real networks
#
# Loads every participant's network windows for the modality (fMRI, DTI, or both paired by
# scan age). Real data runs analyse one of these windows; the simulated datasets use a random
# one as time point 1.
##########################################################################################

fmrilocation<-file.path(cfg$paths$data_dir,cfg$networks$fMRI)
dtilocation<-file.path(cfg$paths$data_dir,cfg$networks$DTI)

windowsf<-NULL
windowss<-NULL

#Functional
if (type1==1)
{
  folderhead<-"fMRI"
  loaded<-LoadWindows(fmrilocation,FS,type3,N)
  Ages1f<-loaded$ages1
  Ages2f<-loaded$ages2
  windowsf<-loaded$windows
  setnumbersf<-loaded$setnumbers
  netnamesf<-loaded$netnames
}

#Structural
if (type1==2)
{
  folderhead<-"DTI"
  loaded<-LoadWindows(dtilocation,FS,type3,N)
  Ages1s<-loaded$ages1
  Ages2s<-loaded$ages2
  windowss<-loaded$windows
  setnumberss<-loaded$setnumbers
  netnamess<-loaded$netnames
}

#Combined
if (type1==3)
{
  folderhead<-"Combined"
  loaded<-LoadPairedWindows(fmrilocation,dtilocation,
                            DatasetFolder("fMRI","real_data"),
                            DatasetFolder("DTI","real_data"),
                            FS,FSname,dataset,type3,N,copy)
  list2env(loaded,envir=globalenv())
}
rm(loaded)
