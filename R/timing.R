##########################################################################################
# Keeping track of time
#
# The cluster stops jobs at the walltime limit. After every step the procedure checks
# whether another step of average length would still fit; if not, it saves a checkpoint
# and stops so the job can be resubmitted and continue.
##########################################################################################

StartTimer <- function(limit)
{
  # limit <- seconds this job may run before it should pause
  return (list(limit=limit,start=as.numeric(Sys.time(),units="secs"),runs=c(),average=NA,remaining=limit))
}

RestartTimer <- function(timer)
{
  # Called when a resubmitted job continues from a checkpoint: the clock starts again but
  # the step durations recorded so far are kept.
  timer$start<-as.numeric(Sys.time(),units="secs")
  return (timer)
}

RecordStep <- function(timer,stepstart)
{
  # Records how long the step that started at stepstart took.
  stepend<-as.numeric(Sys.time(),units="secs")
  thisrun<-stepend-stepstart
  print("This Run Takes")
  print(thisrun)
  timer$runs<-c(timer$runs,thisrun)
  timer$average<-mean(timer$runs)
  print("The Average Run Takes")
  print(timer$average)
  totaltime<-stepend-timer$start
  print("This is How Long We've Been Working")
  print(totaltime)
  timer$remaining<-timer$limit-totaltime
  print("This is How Much Time Is Remaining")
  print(timer$remaining)
  return (timer)
}

OutOfTime <- function(timer)
{
  # TRUE if another step of average length would not finish in the time left.
  return (timer$average>timer$remaining)
}

Now <- function()
{
  return (as.numeric(Sys.time(),units="secs"))
}
