##########################################################################################
# Loading the participants' networks
#
# Each participant folder holds Window*.mat files. Each window is a pair of networks from
# two scans (Network1, Network2) with the participant's age at each scan (Age1, Age2).
##########################################################################################

SubNetwork <- function(net,FS,type3)
{
  # Keeps only the regions of functional system type3-1 (type3 = 1 keeps the whole brain).
  if (type3!=1)
  {
    return (net[FS==(type3-1),FS==(type3-1)])
  }
  return (net)
}

LoadWindows <- function(location,FS,type3,N)
{
  #This function reads every network window for one modality.
  # location <- folder with one sub-folder per participant
  # Returns the windows (NxNx2 arrays) with the ages, participant IDs and (participant, window)
  # numbers of each.
  participants<-list.files(location)
  ages1<-c()
  ages2<-c()
  windows<-list()
  setnumbers<-list()
  netnames<-list()
  for (subject in 1:length(participants))
  {
    timewindows<-list.files(paste0(location,'/',participants[subject]),pattern = "^Window.*\\.mat$")
    if (length(timewindows)!=0)
    {
      for (timewindow in 1:length(timewindows))
      {
        tryCatch({
          mytimewin<-readMat(paste0(location,'/',participants[subject],'/',timewindows[timewindow]))
          age1<-mytimewin$Age1[1]
          age2<-mytimewin$Age2[1]
          t1<-SubNetwork(mytimewin$Network1,FS,type3)
          t2<-SubNetwork(mytimewin$Network2,FS,type3)
          ages1[length(windows)+1]<-age1
          ages2[length(windows)+1]<-age2
          setnumbers[[length(windows)+1]]<-c(subject,timewindow)
          netnames[[length(windows)+1]]<-mytimewin$ID.subject[1]
          windows[[length(windows)+1]]<-array(c(t1,t2), dim=c(N,N,2))
        },error=function(cond)
        {
          print("skip this")
        })
      }
    }
  }
  return (list(ages1=ages1,ages2=ages2,windows=windows,setnumbers=setnumbers,netnames=netnames))
}

LoadPairedWindows <- function(locationf,locations,resultlocationf,resultlocations,FS,FSname,dataset,type3,N,copy)
{
  #This function reads the fMRI and DTI windows of every participant with both, and pairs up
  #windows whose scan ages match.
  # locationf, locations <- fMRI and DTI network folders
  # resultlocationf, resultlocations <- fMRI and DTI real data results folders; for real data
  #   runs the factors found there (by the same copy) are returned too, to seed the combined model
  # Returns the matched windows for each modality with their ages, IDs, (participant, window)
  # numbers and previous factors.
  participantsf<-list.files(locationf)
  participantss<-list.files(locations)

  Ages1f<-c()
  Ages2f<-c()
  windowsf<-list()
  setnumbersf<-list()
  netnamesf<-list()
  factorsf<-list()
  Ages1s<-c()
  Ages2s<-c()
  windowss<-list()
  setnumberss<-list()
  netnamess<-list()
  factorss<-list()

  for (subject in 1:length(participantsf))
  {
    if(participantsf[subject]%in%participantss)
    {
      subjects<-which(participantss==participantsf[subject])

      timewindowsf<-list.files(paste0(locationf,'/',participantsf[subject]),pattern = "^Window.*\\.mat$")
      timewindowss<-list.files(paste0(locations,'/',participantss[subjects]),pattern = "^Window.*\\.mat$")
      if (dataset=="real_data")
      {
        resultpattern<-paste0("^",FSname,"Window.*_copy",copy,"\\.mat$")
        resultwindowsf<-list.files(paste0(resultlocationf,'/',participantsf[subject]),pattern = resultpattern)
        resultwindowss<-list.files(paste0(resultlocations,'/',participantss[subjects]),pattern = resultpattern)
      }
      if (length(timewindowsf)!=0 && length(timewindowss)!=0)
      {
        subjectnamef<-c()
        age1f<-c()
        age2f<-c()
        rage1f<-c()
        rage2f<-c()
        fprevfactors<-list()
        t1f<-list()
        t2f<-list()
        subjectnames<-c()
        age1s<-c()
        age2s<-c()
        rage1s<-c()
        rage2s<-c()
        sprevfactors<-list()
        t1s<-list()
        t2s<-list()

        for (timewindow in 1:length(timewindowsf))
        {
          tw<-1
          tryCatch({
            mytimewinf<-readMat(paste0(locationf,'/',participantsf[subject],'/',timewindowsf[timewindow]))
            subjectnamef[timewindow]<-mytimewinf$ID.subject[1]
            age1f[timewindow]<-mytimewinf$Age1[1]
            age2f[timewindow]<-mytimewinf$Age2[1]
            t1<-SubNetwork(mytimewinf$Network1,FS,type3)
            t2<-SubNetwork(mytimewinf$Network2,FS,type3)
            t1f[[timewindow]]<-t1
            t2f[[timewindow]]<-t2
          },error=function(cond)
          {
            print("skip this")
          })
        }
        for (timewindow in 1:length(timewindowss))
        {
          tryCatch({
            mytimewins<-readMat(paste0(locations,'/',participantss[subjects],'/',timewindowss[timewindow]))
            subjectnames[timewindow]<-mytimewins$ID.subject[1]
            age1s[timewindow]<-mytimewins$Age1[1]
            age2s[timewindow]<-mytimewins$Age2[1]
            t1<-SubNetwork(mytimewins$Network1,FS,type3)
            t2<-SubNetwork(mytimewins$Network2,FS,type3)
            t1s[[timewindow]]<-t1
            t2s[[timewindow]]<-t2
          },error=function(cond)
          {
            print("skip this")
          })
        }
        if (dataset=="real_data")
        {
          for (timewindow in 1:length(resultwindowsf))
          {
            tryCatch({
              mytimewinf<-readMat(paste0(resultlocationf,'/',participantsf[subject],'/',resultwindowsf[timewindow]))
              rage1f[timewindow]<-mytimewinf$age1
              rage2f[timewindow]<-mytimewinf$age2
              fprevfactors[[timewindow]]<-mytimewinf$determinedfactors
            },error=function(cond)
            {
              print("skip this")
            })
          }
          for (timewindow in 1:length(resultwindowss))
          {
            tryCatch({
              mytimewins<-readMat(paste0(resultlocations,'/',participantss[subjects],'/',resultwindowss[timewindow]))
              rage1s[timewindow]<-mytimewins$age1
              rage2s[timewindow]<-mytimewins$age2
              sprevfactors[[timewindow]]<-mytimewins$determinedfactors
            },error=function(cond)
            {
              print("skip this")
            })
          }
        }
        # Pair up fMRI and DTI windows taken at the same ages
        for (f in 1:length(age1f))
        {
          for (s in 1:length(age1s))
          {
            if(age1f[f]==age1s[s] && age2f[f]==age2s[s])
            {
              Ages1f[length(windowsf)+1]<-age1f[f]
              Ages2f[length(windowsf)+1]<-age2f[f]
              setnumbersf[[length(windowsf)+1]]<-c(subject,tw)
              netnamesf[[length(windowsf)+1]]<-subjectnamef[f]
              windowsf[[length(windowsf)+1]]<-array(c(t1f[[f]],t2f[[f]]), dim=c(N,N,2))
              Ages1s[length(windowss)+1]<-age1s[s]
              Ages2s[length(windowss)+1]<-age2s[s]
              setnumberss[[length(windowss)+1]]<-c(subject,tw)
              netnamess[[length(windowss)+1]]<-subjectnames[s]
              windowss[[length(windowss)+1]]<-array(c(t1s[[s]],t2s[[s]]), dim=c(N,N,2))
              tw<-tw+1
              if (dataset=="real_data")
              {
                # The factors the fMRI and DTI real data runs found for this window (none if there is no result)
                prevf<-NULL
                for (rf in seq_along(rage1f))
                {
                  if(age1f[f]==rage1f[rf] && age2f[f]==rage2f[rf])
                  {
                    prevf<-fprevfactors[[rf]]
                  }
                }
                prevs<-NULL
                for (rs in seq_along(rage1s))
                {
                  if(age1s[s]==rage1s[rs] && age2s[s]==rage2s[rs])
                  {
                    prevs<-sprevfactors[[rs]]
                  }
                }
                factorsf[length(windowsf)]<-list(prevf)
                factorss[length(windowss)]<-list(prevs)
              }
            }
          }
        }
      }
    }
  }
  return (list(Ages1f=Ages1f,Ages2f=Ages2f,windowsf=windowsf,setnumbersf=setnumbersf,netnamesf=netnamesf,factorsf=factorsf,
               Ages1s=Ages1s,Ages2s=Ages2s,windowss=windowss,setnumberss=setnumberss,netnamess=netnamess,factorss=factorss))
}

PullNetwork <- function(subject,participants,grandlocation)
{
  # Not used by the procedure. Reads the T*.dat network files of one participant.
  timepoints<-list.files(paste0(grandlocation,'/',participants[subject]),pattern = "^T.*\\.dat$")
  timematrices<-list()
  for (timepoint in 1:length(timepoints))
  {
    tryCatch({
      timematrices[[timepoint]] <- as.matrix(read.table(paste0(grandlocation,'/',participants[subject],'/',timepoints[timepoint])))
    },error=function(cond)
    {
      print("skip this")
    })
  }
  return (timematrices)
}
