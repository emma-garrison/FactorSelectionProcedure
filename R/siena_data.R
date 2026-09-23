##########################################################################################
# Building RSiena data sets and effect objects
##########################################################################################

DataSet <- function(name,N,dataf,datas,covariates,varcovariates,dycovariates,vardycovariates)
{
  #This function creates the dataset in Rsiena from the matrix.

  #data is a Matrix that is NxNxM where N is the number of nodes and M is the number of observations.
  #data <- array(data, dim = c(N,N,M))
  #name <- is the participant name
  mynodes<-sienaNodeSet(N,nodeSetName="Regions")
  params<-list()
  if (is.null(dataf)==FALSE)
  {
    mynetsf <- sienaDependent(dataf,type="oneMode",nodeSet="Regions",allowOnly=FALSE)
    params[[paste0("fMRI_",name)]]=mynetsf
  }
  if (is.null(datas)==FALSE)
  {
    mynetss <- sienaDependent(datas,type="oneMode",nodeSet="Regions",allowOnly=FALSE)
    params[[paste0("DTI_",name)]]=mynetss
  }

  index<-1
  #covariates is a list of lists each of the sublist contains two strings (name,'continuous' or 'categorical') and a vector of length N. The vectors are full of the covariate values for all the nodes.
  for (v in covariates)
  {
    params[[v[[1]]]]<-coCovar(v[[3]], centered=TRUE, nodeSet="Regions", warn = TRUE)
    index <- index+1
  }
  #varcovariates is a list of lists each of the sublist contains a string and a NxM matrix. The matrices contain the variable covariates for each node (rows) and each time point (columns)
  for (v in varcovariates)
  {
    params[[v[[1]]]]<-varCovar(v[[3]], centered=TRUE, nodeSet="Regions", warn = TRUE)
    index <- index+1
  }
  #dycovariates is a list of lists each of the sublist contains a string and an NxN matrix. The matrices are full of the covariate values for all pairs of nodes (the matrix).
  for (v in dycovariates)
  {
    params[[v[[1]]]]<-coDyadCovar(v[[3]], centered=TRUE, nodeSet=c("Regions","Regions"), warn = TRUE)
    index <- index+1
  }
  #vardycovariates is a list of lists each of the sublist contains a string and an NxNxM matrix. The matrices contain the variable covariates for each pair of nodes (NxN) and each time point (xM)
  for (v in vardycovariates)
  {
    params[[v[[1]]]]<-varDyadCovar(v[[3]], centered=TRUE, nodeSet=c("Regions","Regions"), warn = TRUE)
    index <- index+1
  }

  params[['nodeSets']]<-list(mynodes)
  mydata <- do.call(sienaDataCreate,params)
  print(mydata)
  return (list(mynodes, mydata))
}

SettingAllEffects <- function(mydata,factors)
{
  #This function sets all the effects that are currently on the vector allfactors.
  #mydata <- an Rsiena object
  #allfactors <- c(all the factors as strings)

  myeff <- getEffects(mydata)
  myeff$include[myeff$shortName=="density"]=FALSE
  name<-substr(myeff$name[[1]],unlist(gregexpr("_",myeff$name[[1]]))+1,nchar(myeff$name[[1]]))
  for (f in factors)
  {
    myeff$include[[intersect(intersect(which(myeff$name==paste0(substr(f,unlist(gregexpr(',',f))+1,nchar(f)),"_",name)),which(myeff$shortName==substr(f,1,unlist(gregexpr(',',f))-1))),which(myeff$type=="eval"))]]=TRUE
  }

  return (myeff)
}
