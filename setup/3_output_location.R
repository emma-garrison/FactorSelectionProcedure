##########################################################################################
# Setup 3: where this run's results go
#
# saveloc is the start of every file name this run writes (checkpoints and results).
##########################################################################################

Subject<-NULL
Window<-NULL
if (dataset=="real_data")
{
  # Instance n is the n-th window across all participants
  if (type1!=2)
  {
    Subject<-netnamesf[[n]]
    Window<-setnumbersf[[n]][2]
  }else
  {
    Subject<-netnamess[[n]]
    Window<-setnumberss[[n]][2]
  }
  print(paste0("Subject: ",Subject))
  print(paste0("Window: ",Window))
  print(paste0("Overall Window: ",n))
  if (type3!=1)
  {
    print(paste0("Subnet: ",SNname))
  }
}

saveloc<-OutputLocation(folderhead,dataset,type3,typeA,rate,SNname,Subject,Window)
originalsaveloc<-saveloc
