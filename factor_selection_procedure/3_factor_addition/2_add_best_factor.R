##########################################################################################
# Factor Selection Procedure > 3. Factor Addition > add the best factor
#
# Adds the factor with the lowest p-value (ties broken by the highest chi-square) if it is
# below the threshold. If none is, the Factor Selection Procedure is finished.
##########################################################################################

adding<-Pause==FALSE && MTR==FALSE
added<-FALSE
if (adding)
{
  thisrunstart<-Now()
  Announce("Factor Addition","Add the best factor")
  if (any(Bool1))
  {
    print(P1)
    mins<-which(P1==min(na.exclude(P1)))
    theone<-which(Chi1==max(na.exclude(Chi1[mins])))
    if (length(theone)>1)
    {
      theone<-sample(theone,1)
    }
    if (Bool1[theone])
    {
      print("Next Factor:")
      print(theone)
      exceptions<-append(exceptions,theone)
      added<-TRUE
    } else
    {
      print("No More Factors")
      exit<-TRUE
      print(exceptions)
    }
  } else
  {
    print("No More Factors")
    exit<-TRUE
    print(exceptions)
  }
}
