# Helper functions for the app

# "safe" versions of functions to catch errors
cpa.normal.safe <- function(alpha,power,nclusters,nsubjects,sigma_sq,sigma_b_sq,CV,d,ICC,vart,method){
  # make safe version
  fun <- safely(cpa.normal, otherwise = NA)
  # store result
  res <- fun(alpha,power,nclusters,nsubjects,sigma_sq,sigma_b_sq,CV,d,ICC,vart,method)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}

cpa.did.normal.safe <- function(alpha,power,nclusters,nsubjects,d,ICC,rho_c,rho_s,vart){
  # make safe version
  fun <- safely(cpa.did.normal, otherwise = NA)
  # store result
  res <- fun(alpha,power,nclusters,nsubjects,d,ICC,rho_c,rho_s,vart)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}

cpa.sw.normal.safe <- function(alpha,power,nclusters,nsubjects,ntimes,d,icc,rho_c,rho_s,vart){
  # make safe version
  fun <- safely(cpa.sw.normal, otherwise = NA)
  # store result
  res <- fun(alpha,power,nclusters,nsubjects,ntimes,d,icc,rho_c,rho_s,vart)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}


crtpwr.2meanD.ltf.safe <- function(alpha,power,nclusters,nsubjects,d,icc,rho_c,rho_s,vart,ltf.0,ltf.1,replace){
  # make safe version
  fun <- safely(crtpwr.2meanD.ltf, otherwise = NA)
  # store result
  res <- fun(alpha,power,nclusters,nsubjects,d,icc,rho_c,rho_s,vart,ltf.0,ltf.1,replace)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}

crtpwr.2meanM.safe <- function(alpha,power,nclusters,nsubjects,d,icc,vart,rho_m){
  # make safe version
  fun <- safely(crtpwr.2meanM, otherwise = NA)
  # store result
  res <- fun(alpha,power,nclusters,nsubjects,d,icc,vart,rho_m)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}

cpa.ma.normal.safe <- function(alpha,power,narms,nclusters,nsubjects,vara,varc,vare){
  # make safe version
  fun <- safely(cpa.ma.normal, otherwise = NA)
  # store result
  res <- fun(alpha,power,narms,nclusters,nsubjects,vara,varc,vare)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}

cpa.binary.safe <- function(alpha,power,nclusters,nsubjects,cv,p1,p2,ICC,pooled,p1inc,ttest){
  # make safe version
  fun <- safely(cpa.binary, otherwise = NA)
  # store result
  res <- fun(alpha,power,nclusters,nsubjects,cv,p1,p2,ICC,pooled,p1inc,ttest)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}

cpa.did.binary.safe <- function(alpha,power,nclusters,nsubjects,p,d,ICC,rho_c,rho_s){
  # make safe version
  fun <- safely(cpa.did.binary, otherwise = NA)
  # store result
  res <- fun(alpha,power,nclusters,nsubjects,p,d,ICC,rho_c,rho_s)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}

crtpwr.2propM.safe <- function(alpha,power,nclusters,nsubjects,p1,p2,cvm,p1inc){
  # make safe version
  fun <- safely(crtpwr.2propM, otherwise = NA)
  # store result
  res <- fun(alpha,power,nclusters,nsubjects,p1,p2,cvm,p1inc)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}

cpa.count.safe <- function(alpha,power,nclusters,py,r1,r2,CVB,r1inc){
  # make safe version
  fun <- safely(cpa.count, otherwise = NA)
  # store result
  res <- fun(alpha,power,nclusters,py,r1,r2,CVB,r1inc)
  # if res$error NULL, set to NA, otherwise set to message
  if(is.null(res$error)){
    res$error = 'None'
  } else {
    res$error <- res$error$message
  }
  res
}

# function to shorten error messages
shorten_error <- function(err, target){
  ifelse(err == "did not succeed extending the interval endpoints for f(lower) * f(upper) <= 0",
         paste0("No value of '", target, "' can be found for the given inputs."),
         err)
  ifelse(err == "f() values at end points not of opposite sign",
         paste0("No value of '", target, "' can be found for the given inputs."),
         err)
}

# function to convert app input into numeric vectors
make_sequence <- function(x){
  # trim any spaces before and after the supplied string
  x <- str_trim(x)
  if(x == ""){
    # if x is an empty string, just return NA
    return(as.numeric(x))
  } 
  
  # split x based on commas or space
  y <- str_split(x, "[,\\s]", simplify = TRUE)
  
  if(length(y) == 5 & y[2] == "to" & y[4] == "by"){
    # check if in "X to Y by Z" format
    temp <- as.numeric(str_split(x,"[^0-9.\\-]",simplify=TRUE))
    temp <- temp[!is.na(temp)]
    return(seq(temp[1], temp[2], by = temp[3]))
  } else {
    temp <- as.numeric(str_split(x,"[^0-9.\\-]",simplify=TRUE))
    return(temp[!is.na(temp)])
  }
}


# function to add equal sign into facet labels
label_both_equals <- function(labels) label_both(labels, sep = " = ")
