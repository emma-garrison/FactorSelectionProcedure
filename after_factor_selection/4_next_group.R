##########################################################################################
# After the Factor Selection Procedure 4: move on to the next group, or mark the run as completed
##########################################################################################

print(h)
if(Pause==FALSE)
{
  if (h!=length(groups))
  {
    if(length(groups)>1)
    {
      INIT<-TRUE
      exit<-FALSE
      exceptions<-list()
      override<-1
      Pause<-FALSE
      AF<-FALSE
      AFS<-FALSE
      APMTR<-FALSE
      PP<-FALSE
      PS<-FALSE
      MTR<-TRUE
      numattempts<-cfg$procedure$subnet_attempts
      print("REINITIALIZING FOR SUBNET RUNS")
      save.image(CheckpointFile(2))
    }
  } else
  {
    print("All Done Y'all!!!")
    if (INIT==TRUE && AF==TRUE && PP==TRUE && Pause==FALSE)
    {
      callit<-paste0(FSname,as.character(n),'_copy',as.character(copy))
      MarkCompleted(folderhead,dataset,rate,callit)
    }
  }
  h<-h+1
}
