##########################################################################################
# Factor Selection Procedure > 1. All-Pairs Initialization > first and second factor
#
# First factor: the one with the lowest average p-value across all pairs (ties broken by the
# highest chi-square). Second factor: the one with the lowest p-value alongside the first.
# Each is only added if its p-value is below the threshold, so 0, 1 or 2 factors are added.
# With fewer than 2 the procedure ends here.
##########################################################################################

choosing<-FALSE
secondadded<-FALSE
if (searching && !seeded && Pause==FALSE && APMTR==FALSE)
{
  choosing<-TRUE
  thisrunstart<-Now()
  Announce("All-Pairs Initialization","First factor")
  P<-colMeans(PMat,na.rm = TRUE)
  Chi<-colMeans(ChiMat,na.rm = TRUE)

  Bool<-P<thresh & !is.na(P)

  print(P)

  if (any(na.exclude(Bool)))
  {
    mins<-which(P==min(na.exclude(P)))
    theone<-which(Chi==max(na.exclude(Chi[mins])))
    if (length(theone)>1)
    {
      theone<-sample(theone,1)
    }
    if (Bool[theone])
    {
      print("First Factor:")
      print(theone)
      exceptions<-append(exceptions,theone)

      Announce("All-Pairs Initialization","Second factor")
      P1=PMat[theone,]
      Chi1=ChiMat[theone,]

      Bool1<-P1<thresh & !is.na(P1)

      print(P1)
      if (any(na.exclude(Bool1)))
      {
        mins<-which(P1==min(na.exclude(P1)))
        nextone<-which(Chi1==max(na.exclude(Chi1[mins])))
        if (length(nextone)>1)
        {
          nextone<-sample(nextone,1)
        }
        if (Bool1[nextone])
        {
          print("Second Factor:")
          print(nextone)
          exceptions<-append(exceptions,nextone)
          secondadded<-TRUE
        } else
        {
          print("Only One Factor")
          exit<-TRUE
          print(exceptions)
        }
      } else
      {
        print("Only One Factor")
        exit<-TRUE
        print(exceptions)
      }

    } else
    {
      exit<-TRUE
      print("No Factors Here")
      print(exceptions)
    }
  } else
  {
    print("No Factors Here")
    exit<-TRUE
    print(exceptions)
  }
}
