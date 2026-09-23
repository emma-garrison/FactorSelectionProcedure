##########################################################################################
# Simulating networks from a known model
##########################################################################################

ProduceNetworksfromFactors <- function(N,name,numnets,t1f=NULL,t1s=NULL,baserate,setfactors,covariates=list(),varcovariates=list(),dycovariates=list(),vardycovariates=list())
{
  #This function produces networks based on a list of set factors with values.
  # N <- number of nodes in the network
  # name <- the name of the test or the name of the participant
  # numnets <- the number of networks that you would like to produce
  # t1 <- matrix of the original time point adjacency matrix
  # baserate <- a number representing the set base rate for the prduced networks.
  # setfactors <- this is a list with short names of factors as the list value names and set values as the list values. ex. list(density<-1) This would set the density factor to 1
  if(is.null(t1f)==FALSE)
  {
    t2f <- t1f
    x <- sample(1:N,(N/2))
    y <- sample(1:N,(N/2))

    for(i in 1:(N/2))
    {
      if (x[i]!=y[i])
      {
        if (t2f[x[i],y[i]]==0) t2f[x[i],y[i]] <- 1 else  t2f[x[i],y[i]] <- 0
        if (t2f[y[i],x[i]]==0) t2f[y[i],x[i]] <- 1 else  t2f[y[i],x[i]] <- 0
        if (length(varcovariates)>0)
        {
          for (vi in 1:length(varcovariates))
          {
            print("this")
            v<-varcovariates[[vi]]
            varcovariates[[vi]][[3]]<-matrix(cbind(t(v[[3]]),t(sample(v[[3]],N))),nrow=N)
          }
        }
        if (length(vardycovariates)>0)
        {
          for (vi in 1:length(vardycovariates))
          {
            v<-vardycovariates[[vi]]
            upper_indices <- upper.tri(v[[1]], diag = FALSE)
            shuffled_upper <- sample(v[[1]][upper_indices])
            newmat <- matrix(0, nrow = nrow(v[[1]]), ncol = nrow(v[[1]]))
            newmat[upper_indices] <- shuffled_upper
            newmat[t(upper_indices)] <- shuffled_upper
            vardycovariates[[vi]][[3]]<-array(c(v[[3]],newmat),c(N,N,2))
          }
        }
      }
    }

    dataf <- array( c( t1f, t2f ), dim = c( N, N, 2 ) )
  }else
  {
    dataf<-NULL
  }
  if(is.null(t1s)==FALSE)
  {
    t2s <- t1s
    x <- sample(1:N,(N/2))
    y <- sample(1:N,(N/2))

    for(i in 1:(N/2))
    {
      if (x[i]!=y[i])
      {
        if (t2s[x[i],y[i]]==0) t2s[x[i],y[i]] <- 1 else  t2s[x[i],y[i]] <- 0
        if (t2s[y[i],x[i]]==0) t2s[y[i],x[i]] <- 1 else  t2s[y[i],x[i]] <- 0
        if (length(varcovariates)>0)
        {
          for (vi in 1:length(varcovariates))
          {
            print("this")
            v<-varcovariates[[vi]]
            varcovariates[[vi]][[3]]<-matrix(cbind(t(v[[3]]),t(sample(v[[3]],N))),nrow=N)
          }
        }
        if (length(vardycovariates)>0)
        {
          for (vi in 1:length(vardycovariates))
          {
            v<-vardycovariates[[vi]]
            upper_indices <- upper.tri(v[[1]], diag = FALSE)
            shuffled_upper <- sample(v[[1]][upper_indices])
            newmat <- matrix(0, nrow = nrow(v[[1]]), ncol = nrow(v[[1]]))
            newmat[upper_indices] <- shuffled_upper
            newmat[t(upper_indices)] <- shuffled_upper
            vardycovariates[[vi]][[3]]<-array(c(v[[3]],newmat),c(N,N,2))
          }
        }
      }
    }

    datas <- array( c( t1s, t2s ), dim = c( N, N, 2 ) )
  }else
  {
    datas<-NULL
  }

  this <- DataSet(name,N,dataf,datas,covariates,varcovariates,dycovariates,vardycovariates)
  mynodes<-this[[1]]
  mydata<-this[[2]]
  names<-names(mydata$depvars)

  #These steps are made to create a time point two (because we need one in order to produce). This time point two is made by making a few random changes. It has no affect on the produced networks which are based on time point 1.
  #We also need to create viable options for the variable covariates so the values of the originals are shuffled. Again this will have no effect but should preserve the options and format of the covariates.

  myeff <- getEffects( mydata )
  myeff$initialValue[myeff$shortName=="Rate"]<-baserate
  myeff$include[myeff$shortName=="density"]=FALSE

  for (f in names(setfactors))
  {
    myeff$include[[intersect(intersect(which(myeff$name==paste0(substr(f,unlist(gregexpr(',',f))+1,nchar(f)),"_",name)),which(myeff$shortName==substr(f,1,unlist(gregexpr(',',f))-1))),which(myeff$type=="eval"))]]=TRUE
    myeff$initialValue[[intersect(intersect(which(myeff$name==paste0(substr(f,unlist(gregexpr(',',f))+1,nchar(f)),"_",name)),which(myeff$shortName==substr(f,1,unlist(gregexpr(',',f))-1))),which(myeff$type=="eval"))]]=setfactors[[f]]
  }

  print(myeff) #setting factors to their stated value.

  simulation.options <- sienaAlgorithmCreate(useStdInits=FALSE,
                                             projname="Test",cond=FALSE,
                                             nsub=0,n3=numnets)

  results<-siena07(simulation.options,
                   data=mydata,effects=myeff,returnDeps=TRUE,silent=TRUE,batch=TRUE,verbose=FALSE)

  TestNetworks <- list()
  net <- 1
  #borrowed this code from someone else but this extracts the produced networks from the algorithm results. Produced networks have the form of a vector of matrices.

  while (net<=numnets)
  {
    for (nam in names)
    {

      simnet <- results$sims[[net]]$Data1[[nam]]$`1`

      ncells <- attr(results$f,'numberNonMissingNetwork')+
        attr(results$f,'numberMissingNetwork')
      n<-N

      # make empty matrix of appropriate size:
      mat <- matrix(0,nr=n,nc=n)

      # put edgelist values where appropriate:
      for (r in 1:nrow(simnet)) {
        mat[simnet[r,1],simnet[r,2]] <- simnet[r,3]
      }

      TestNetworks[[nam]][[net]]<-mat
    }

    net <- net+1
  }
  return (TestNetworks)
}

ProduceNetworksfromResults <- function(N,name,numnets,t1,prevResult,covariates=list(),varcovariates=list(),dycovariates=list(),vardycovariates=list())
{
  # Not used by the procedure, and not working as written: DataSet is called without the
  # datas argument and siena07 is never run, so results is undefined.
  #This function produces networks based on a result of an estimation.
  # N <- number of nodes in the network
  # name <- the name of the test or the name of the participant
  # numnets <- the number of networks that you would like to produce
  # t1 <- matrix of the original time point adjacency matrix
  # prevResult <- this is the Rsiena object with the results of an estimation that we want to produce results from.
  # covariates is a list of lists each of the sublist contains two strings (name,'continuous' or 'categorical') and a vector of length N. The vectors are full of the covariate values for all the nodes.
  # varcovariates is a list of lists each of the sublist contains a string and a NxM matrix. The matrices contain the variable covariates for each node (rows) and each time point (columns)

  t2 <- t1
  x <- sample(1:N,(N/2))
  y <- sample(1:N,(N/2))

  for(i in 1:(N/2))
  {
    if (x[i]!=y[i])
    {
      if (t2[x[i],y[i]]==0) t2[x[i],y[i]] <- 1 else  t2[x[i],y[i]] <- 0
      if (t2[y[i],x[i]]==0) t2[y[i],x[i]] <- 1 else  t2[y[i],x[i]] <- 0
      for (vi in 1:length(varcovariates))
      {
        v<-varcovariates[[vi]]
        varcovariates[[vi]][[3]]<-matrix(cbind(t(v[[3]]),t(sample(v[[3]],N))),nrow=N)
      }
      for (vi in 1:length(vardycovariates))
      {
        v<-vardycovariates[[vi]]
        upper_indices <- upper.tri(v[[1]], diag = FALSE)
        shuffled_upper <- sample(v[[1]][upper_indices])
        newmat <- matrix(0, nrow = nrow(v[[1]]), ncol = nrow(v[[1]]))
        newmat[upper_indices] <- shuffled_upper
        newmat[t(upper_indices)] <- shuffled_upper
        vardycovariates[[vi]][[3]]<-array(c(v[[3]],newmat),c(N,N,2))
      }
    }
  }

  data <- array( c( t1, t2 ), dim = c( N, N, 2 ) )
  this <- DataSet(name,N,data,covariates,varcovariates,dycovariates,vardycovariates)
  mynodes<-this[[1]]
  mydata<-this[[2]]
  #These steps are made to create a time point two (because we need one in order to produce). This time point two is made by making a few random changes. It has no affect on the produced networks which are based on time point 1.
  #We also need to create viable options for the variable covariates so the values of the originals are shuffled. Again this will have no effect but should preserve the options and format of the covariates.

  myeff <- getEffects( mydata )
  myeff <- includeEffects( myeff, density, include=FALSE )
  myeff$initialValue[1] <- prevResult$theta[1]

  for (i in 2:length(prevResult$effects$shortName))
  {
    myeff$include[intersect(which(myeff$shortName==prevResult$effects$shortName[i]),which(myeff$type=='eval'))]<-TRUE
    myeff$initialValue[intersect(which(myeff$shortName==prevResult$effects$shortName[i]),which(myeff$type=='eval'))]<-prevResult$theta[i]
  }
  #Set values based on the theta from the prevResult

  simulation.options <- sienaAlgorithmCreate(useStdInits=FALSE,
                                             projname=name,cond=FALSE,
                                             nsub=0,n3=numnets)

  TestNetworks <- c()
  net <- 1
  #borrowed this code from someone else but this extracts the produced networks from the algorithm results. Produced networks have the form of a vector of matrices.
  while (net<=numnets)
  {

    simnet <- results$sims[[net]]$Data1[[name]]$`1`

    ncells <- attr(results$f,'numberNonMissingNetwork')+
      attr(results$f,'numberMissingNetwork')
    n <- (1+sqrt(4*ncells+1))/2

    # make empty matrix of appropriate size:
    mat <- matrix(0,nr=n,nc=n)

    # put edgelist values where appropriate:
    for (r in 1:nrow(simnet)) {
      mat[simnet[r,1],simnet[r,2]] <- simnet[r,3]
    }

    TestNetworks[[net]]<-mat

    net <- net+1
  }
  return (TestNetworks)
}
