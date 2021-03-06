#' Power simulations for cluster-randomized trials: Difference in Difference, Binary Outcome.
#'
#' @description 
#' \loadmathjax
#'
#' This function utilizes iterative simulations to determine 
#' approximate power for cluster-randomized controlled trials. Users 
#' can modify a variety of parameters to suit the simulations to their
#' desired experimental situation.
#' 
#' Runs the power simulation for difference in difference RCTs with binary outcomes.
#' 
#' Users must specify the desired number of simulations, number of subjects per 
#' cluster, number of clusters per arm, pre-treatment between-cluster variance, 
#' and two of the following three terms: 
#' expected probability of outcome in arm 1, expected probability of 
#' outcome in arm 2, expected difference in probabilities between groups
#' ; post-treatment between-cluster variance, significance level, analytic method, progress updates, 
#' and simulated data set output may also be specified.
#' 
#' The following equations are used to estimate intra-cluster correlation coefficients:
#' 
#' P_h: \mjsdeqn{ICC = \frac{\sigma_{b}}{\sigma_{b} + \pi^{2}/3}}
#' P_c: \mjsdeqn{ICC = \frac{P(Y_{ij} = 1, Y_{ih} = 1) - \pi_{j}\pi_{h}}{\sqrt{\pi_{j}(1 - \pi_{j})\pi_{h}(1 - \pi_{h})}}}
#' P_lmer: \mjsdeqn{ICC = \frac{\sigma_{b}}{\sigma_{b} + \sigma_{w}}}
#' 
#' @param nsim Number of datasets to simulate; accepts integer (required).
#' 
#' @param nsubjects Number of subjects per cluster; accepts integer (required). 
#' 
#' @param nclusters Number of clusters per arm; accepts integer (required).
#' 
#' @param p1t0 Required. Expected outcome proportion in arm 1 at baseline.
#' Default is 0.
#' @param p2t0 Optional. Expected outcome proportion in arm 2 at baseline. If 
#' no quantity is provided, p2t0 = p1t0 is assumed.
#' @param p1t1 Optional. Expected outcome proportion in arm 1 at follow-up. 
#' If no quantity is provided, p1t1 = p1t0 is assumed.
#' @param p2t1 Required. Expected outcome proportion in arm 2 at follow-up.
#' @param p.diff Optional if p1t1 and p2t0 are provided. Expected difference 
#' in outcome proportion between groups, defined as 
#' p.diff = (p1t1 - p1t0) - (p2t1 - p2t0).
#' 
#' 
#' At least 2 of the following 3 arguments must be specified when using 
#' expected odds ratios:
#' @param or1 Expected odds ratio for outcome in arm 1
#' @param or2 Expected odds ratio for outcome in arm 2
#' @param or.diff Expected difference in odds ratio for outcome between groups, 
#' defined as or.diff = or1 - or2.
#' 
#' @param sigma_b_sq0 Pre-treatment (time == 0) between-cluster variance; 
#' accepts numeric scalar (indicating equal between-cluster variances for 
#' both arms) or a vector of length 2 specifying treatment-specific 
#' between-cluster variances.
#' 
#' @param sigma_b_sq1 Post-treatment (time == 1) between-cluster variance; 
#' accepts numeric scalar (indicating equal between-cluster variances for 
#' both arms) or a vector of length 2 specifying treatment-specific 
#' between-cluster variances. If not provided by the user, 
#' sigma_b_sq1 = sigma_b_sq0.
#' 
#' @param alpha Significance level. Default = 0.05
#' 
#' @param method Analytical method, either Generalized Linear Mixed 
#' Effects Model (GLMM) or Generalized Estimating Equation (GEE). 
#' Accepts c('glmm', 'gee') (required); default = 'glmm'.
#' 
#' @param quiet When set to FALSE, displays simulation start time and 
#' completion time. Default is TRUE.
#' 
#' @param allSimData Option to output list of all simulated datasets. 
#' Default = FALSE.
#' 
#' @param poorFitOverride Option to override \code{stop()} if more than 25\%
#' of fits fail to converge; default = FALSE.
#' 
#' @param lowPowerOverride Option to override \code{stop()} if the power
#' is less than 0.5 after the first 50 simulations and every ten simulations
#' thereafter. On function execution stop, the actual power is printed in the
#' stop message. Default = FALSE. When TRUE, this check is ignored and the
#' calculated power is returned regardless of value.
#' 
#' @param timelimitOverride Logical. When FALSE, stops execution if the 
#' estimated completion time is more than 2 minutes. Defaults to TRUE.
#' 
#' @param nofit Option to skip model fitting and analysis and only return 
#' the simulated data. Default = \code{FALSE}.
#' 
#' @param seed Option to set the seed. Default is NA.
#'  
#' @return A list with the following components
#' \itemize{
#'   \item Character string indicating total number of simulations, simulation type, 
#'   and number of convergent models
#'   \item Number of simulations
#'   \item Data frame with columns "Power" (Estimated statistical power), 
#'                "lower.95.ci" (Lower 95% confidence interval bound), 
#'                "upper.95.ci" (Upper 95% confidence interval bound)
#'   \item Analytic method used for power estimation
#'   \item Significance level
#'   \item Vector containing user-defined cluster sizes
#'   \item Vector containing user-defined number of clusters
#'   \item Data frame reporting sigma_b_sq for each group at each time point
#'   \item Vector containing expected difference in probabilities based on user inputs
#'   \item Data frame with columns: 
#'                   "Period" (Pre/Post-treatment indicator), 
#'                   "Arm" (Arm indicator), 
#'                   "Value" (Mean response value)
#'   \item Data frame containing three estimates of ICC
#'   \item Data frame with columns: 
#'                   "Estimate" (Estimate of treatment effect for a given simulation), 
#'                   "Std.err" (Standard error for treatment effect estimate), 
#'                   "Test.statistic" (z-value (for GLMM) or Wald statistic (for GEE)), 
#'                   "p.value", 
#'                   "converge" (Did simulated model converge?), 
#'                   "sig.val" (Is p-value less than alpha?)
#'   \item If \code{allSimData = TRUE}, a list of data frames, each containing: 
#'                   "y" (Simulated response value), 
#'                   "trt" (Indicator for arm), 
#'                   "clust" (Indicator for cluster), 
#'                   "period" (Indicator for time point)
#'   \item List of warning messages produced by non-convergent models. 
#'                       Includes model number for cross-referencing against 
#'                       \code{model.estimates}
#' }
#' If \code{nofit = T}, a data frame of the simulated data sets, containing:
#' \itemize{
#'   \item "arm" (Indicator for treatment arm)
#'   \item "cluster" (Indicator for cluster)
#'   \item "y1" ... "yn" (Simulated response value for each of the \code{nsim} data sets).
#'   }
#' 
#' @examples 
#' 
#' # Estimate power for a trial with 10 clusters in both arms, those clusters having
#' # 20 subjects each, with sigma_b_sq0 = 1. We have estimated arm proportions of 0.2
#' # and 0.3 in the first and second arms, respectively, and we use
#' # 100 simulated data sets analyzed by the GLMM method. The resulting estimated power 
#' # (if you set seed = 123) should be about 0.78.
#' 
#' \dontrun{
#' did.binary.sim = cps.did.binary(nsim = 100, nsubjects = 20, nclusters = 10, 
#'                                 p1t0 = 0.1, p2t0 = 0.1,  
#'                                 p1t1 = 0.2, p2t1 = 0.45, sigma_b_sq0 = 1, 
#'                                 sigma_b_sq1 = 1, alpha = 0.05,
#'                                 method = 'glmm', allSimData = FALSE, seed = 123)
#' }
#'
#' @author Alexander R. Bogdan 
#' 
#' @author Alexandria C. Sakrejda (\email{acbro0@@umass.edu}
#' 
#' @author Ken Kleinman (\email{ken.kleinman@@gmail.com})
#'
#' @references Snjiders, T. & Bosker, R. Multilevel Analysis: an Introduction to Basic and 
#' Advanced Multilevel Modelling. London, 1999: Sage.
#' 
#' @references Elridge, S., Ukoumunne, O. & Carlin, J. The Intra-Cluster Correlation 
#' Coefficient in Cluster Randomized Trials: A Review of Definitions. International 
#' Statistical Review (2009), 77, 3, 378-394. doi: 10.1111/j.1751-5823.2009.00092.x
#' 
#' @export

# Define function


cps.did.binary = function(nsim = NULL,
                          nsubjects = NULL,
                          nclusters = NULL,
                          p.diff = NULL,
                          p1t0 = 0,
                          p2t0 = NULL,
                          p1t1 = NULL,
                          p2t1 = NULL,
                          or1 = NULL,
                          or2 = NULL,
                          or.diff = NULL,
                          sigma_b_sq0 = NULL,
                          sigma_b_sq1 = NULL,
                          alpha = 0.05,
                          method = 'glmm',
                          quiet = TRUE,
                          allSimData = FALSE,
                          poorFitOverride = FALSE,
                          lowPowerOverride = FALSE, 
                          timelimitOverride = TRUE,
                          seed = NA,
                          nofit = FALSE) {
  if (!is.na(seed)) {
    set.seed(seed = seed)
  }
  
  # Create objects to collect iteration-specific values
  est.vector = vector("numeric", length = nsim)
  se.vector = vector("numeric", length = nsim)
  stat.vector = vector("numeric", length = nsim)
  pval.vector = vector("numeric", length = nsim)
  converge = vector("logical", length = nsim)
  icc2.vector = vector("numeric", length = nsim)
  lmer.icc.vector = vector("numeric", length = nsim)
  values.vector = cbind(c(0, 0, 0, 0))
  simulated.datasets = list()
  
  # Create progress bar
  prog.bar =  progress::progress_bar$new(
    format = "(:spin) [:bar] :percent eta :eta",
    total = nsim,
    clear = FALSE,
    width = 100
  )
  prog.bar$tick(0)
  
  # Define wholenumber function
  is.wholenumber = function(x, tol = .Machine$double.eps ^ 0.5)
    abs(x - round(x)) < tol
  
  # Define expit function
  expit = function(x)
    1 / (1 + exp(-x))
  
  # Validate NSIM, NSUBJECTS, NCLUSTERS, sigma_b_sq, ALPHA
  sim.data.arg.list = list(nsim, nsubjects, nclusters)
  sim.data.args = unlist(lapply(sim.data.arg.list, is.null))
  if (sum(sim.data.args) > 0) {
    stop("NSIM, NSUBJECTS & NCLUSTERS must all be specified. Please review your input values.")
  }
  min1.warning = " must be an integer greater than or equal to 1"
  if (!is.wholenumber(nsim) || nsim < 1) {
    stop(paste0("NSIM", min1.warning))
  }
  if (!is.wholenumber(nsubjects) || nsubjects < 1) {
    stop(paste0("NSUBJECTS", min1.warning))
  }
  if (!is.wholenumber(nclusters) || nclusters < 1) {
    stop(paste0("NCLUSTERS", min1.warning))
  }
  if (length(nclusters) > 2) {
    stop(
      "NCLUSTERS can only be a vector of length 1 (equal # of clusters per group) or 2 (unequal # of clusters per group)"
    )
  }
  # Set cluster sizes for arm 1 arm (if not already specified)
  if (length(nclusters) == 1) {
    nclusters[2] = nclusters[1]
  }
  # Set sample sizes for each cluster (if not already specified)
  if (length(nsubjects) == 1) {
    nsubjects[1:sum(nclusters)] = nsubjects
  }
  if (length(nsubjects) == 2) {
    nsubjects = c(rep(nsubjects[1], nclusters[1]), rep(nsubjects[2], nclusters[2]))
  }
  if (nclusters[1] == nclusters[2] &&
      length(nsubjects) == nclusters[1]) {
    nsubjects = rep(nsubjects, 2)
  }
  if (length(nclusters) == 2 &&
      length(nsubjects) != 1 &&
      length(nsubjects) != sum(nclusters)) {
    stop(
      "A cluster size must be specified for each cluster. If all cluster sizes are equal, please provide a single value for NSUBJECTS"
    )
  }
  
  # Validate p1t0, p2t1, P.DIFF & OR1, OR2, OR.DIFF
  parm1.arg.list = list(p1t0, p2t1, p.diff)
  parm1.args = unlist(lapply(parm1.arg.list, is.null))
  parm2.arg.list = list(or1, or2, or.diff)
  parm2.args = unlist(lapply(parm2.arg.list, is.null))
  if (sum(parm1.args) < 3 && sum(parm2.args) < 3) {
    stop(
      "Only one set of parameters may be supplied: Expected probabilities OR expected odds ratios"
    )
  }
  if (sum(parm2.args) == 3 && sum(parm1.args) > 1) {
    stop("At least two of the following terms must be specified: p1t0, p2t1, P.DIFF")
  }
  if (sum(parm1.args) == 3 && sum(parm2.args) > 1) {
    stop("At least two of the following terms must be specified: OR1, OR2, OR.DIFF")
  }
  if (sum(parm1.args) == 0 && p.diff != abs(p1t0 - p2t1)) {
    stop("At least one of the following terms has been misspecified: p1t0, p2t1, P.DIFF")
  }
  if (sum(parm2.args) == 0 && or.diff != abs(or1 - or2)) {
    stop("At least one of the following terms has been misspecified: OR1, OR2, OR.DIFF")
  }
  # Calculate any probabilities/odds ratios not specified by user
  if (sum(parm2.args) == 3) {
    if (is.null(p1t0)) {
      p1t0 = abs(p.diff - p2t1)
    }
    if (is.null(p2t1)) {
      p2t1 = abs(p1t0 - p.diff)
    }
    if (is.null(p.diff)) {
      p.diff = abs((p1t1 - p1t0) - (p2t1 - p2t0))
    }
  }

  if (sum(parm1.args) == 3) {
    if (is.null(or1)) {
      or1 = abs(or.diff - or2)
    }
    if (is.null(or2)) {
      or2 = abs(or1 - or.diff)
    }
    if (is.null(or.diff)) {
      or.diff = or1 - or2
    }
    p1t0 = or1 / (1 + or1)
    p2t1 = or2 / (1 + or2)
    p.diff = abs(p1t0 - p2t1)
  }
  
  if (is.null(p1t1)) {
    p1t1 = p1t0
  }
  if (is.null(p2t0)) {
    p2t0 = p1t0
  }
  
  # if sigma_b_sq1 isn't specified, assume equal to sigma_b_sq0
  if (is.null(sigma_b_sq1)) {
    sigma_b_sq1 <- sigma_b_sq0
  }
  
  # Validate sigma_b_sq0 & sigma_b_sq1
  sigma_b_sq.warning = " must be a scalar (equal between-cluster variance for both arms) or a vector of length 2,
         specifying between-cluster variances for each arm"
  if (!is.numeric(sigma_b_sq0) || any(sigma_b_sq0 < 0)) {
    stop("All values supplied to sigma_b_sq0 must be numeric values > 0")
  }
  if (!length(sigma_b_sq0) %in% c(1, 2)) {
    stop("sigma_b_sq0", sigma_b_sq.warning)
  }
  if (!length(sigma_b_sq1) %in% c(1, 2)) {
    stop("sigma_b_sq1", sigma_b_sq.warning)
  }
  if (!is.numeric(sigma_b_sq1) || any(sigma_b_sq1 < 0)) {
    stop("All values supplied to sigma_b_sq1 must be numeric values >= 0")
  }
  # Set sigma_b_sq0 & sigma_b_sq1 (if not already specified)
  if (length(sigma_b_sq0) == 1) {
    sigma_b_sq0[2] = sigma_b_sq0
  }
  if (length(sigma_b_sq1) == 1) {
    sigma_b_sq1[2] = sigma_b_sq1
  }
  
  # Validate ALPHA, METHOD, QUIET, allSimData
  if (!is.numeric(alpha) || alpha < 0 || alpha > 1) {
    stop("ALPHA must be a numeric value between 0 - 1")
  }
  if (!is.element(method, c('glmm', 'gee'))) {
    stop(
      "METHOD must be either 'glmm' (Generalized Linear Mixed Model)
         or 'gee'(Generalized Estimating Equation)"
    )
  }
  if (!is.logical(quiet)) {
    stop(
      "QUIET must be either TRUE (No progress information shown) or FALSE (Progress information shown)"
    )
  }
  if (!is.logical(allSimData)) {
    stop(
      "allSimData must be either TRUE (Output all simulated data sets) or FALSE (No simulated data output"
    )
  }
  
  # Calculate ICC1 at baseline (_0) and tx period (_1) (sigma_b_sq / (sigma_b_sq + pi^2/3))
  icc1_0 = mean(sapply(1:2, function(x)
    sigma_b_sq0[x] / (sigma_b_sq0[x] + pi ^ 2 / 3)))
  icc1_1 = mean(sapply(1:2, function(x)
    sigma_b_sq1[x] / (sigma_b_sq1[x] + pi ^ 2 / 3)))
  
  # Create indicators for PERIOD, TRT & CLUSTER
  period = rep(0:1, each = sum(nsubjects))
  trt = c(rep(1, length.out = sum(nsubjects[1:nclusters[1]])),
          rep(2, length.out = sum(nsubjects[(nclusters[1] + 1):(nclusters[1] + nclusters[2])])))
  clust = unlist(lapply(1:sum(nclusters), function(x)
    rep(x, length.out = nsubjects[x])))
  
  # Calculate log odds for each group
  logit.p1t0 = log(p1t0 / (1 - p1t0))
  logit.p2t0 = log(p2t0 / (1 - p2t0))
  logit.p1t1 = log(p1t1 / (1 - p1t1))
  logit.p2t1 = log(p2t1 / (1 - p2t1))
  
  # Set warnings to OFF
  options(warn = -1)
  
  start.time = Sys.time()
  
  ### Create simulation loop
  for (i in 1:nsim) {
    ## TIME == 0
    # Generate between-cluster effects for arm 1 and arm 2
    randint.ntrt.0 = stats::rnorm(nclusters[1], mean = 0, sd = sqrt(sigma_b_sq0[1]))
    randint.trt.0 = stats::rnorm(nclusters[2], mean = 0, sd = sqrt(sigma_b_sq0[2]))
    
    # Create arm 1 y-value
    y0.ntrt.intercept = unlist(lapply(1:nclusters[1], function(x)
      rep(randint.ntrt.0[x], length.out = nsubjects[x])))
    y0.ntrt.linpred = y0.ntrt.intercept + logit.p1t0
    y0.ntrt.prob = expit(y0.ntrt.linpred)
    y0.ntrt = unlist(lapply(y0.ntrt.prob, function(x)
      stats::rbinom(1, 1, x)))
    
    # Create arm 2 y-value
    y0.trt.intercept = unlist(lapply(1:nclusters[1], function(x)
      rep(randint.trt.0[x], length.out = nsubjects[nclusters[1] + x])))
    y0.trt.linpred = y0.trt.intercept + logit.p2t0
    y0.trt.prob = expit(y0.trt.linpred)
    y0.trt = unlist(lapply(y0.trt.prob, function(x)
      stats::rbinom(1, 1, x)))
    
    ## TIME == 1
    # Generate between-cluster effects for arm 1 and arm 2
    randint.ntrt.1 = stats::rnorm(nclusters[1], mean = 0, sd = sqrt(sigma_b_sq1[1]))
    randint.trt.1 = stats::rnorm(nclusters[2], mean = 0, sd = sqrt(sigma_b_sq1[2]))
    
    # Create arm 1 y-value
    y1.ntrt.intercept = unlist(lapply(1:nclusters[1], function(x)
      rep(randint.ntrt.1[x], length.out = nsubjects[x])))
    y1.ntrt.linpred = y1.ntrt.intercept + logit.p1t1
    y1.ntrt.prob = expit(y1.ntrt.linpred)
    y1.ntrt = unlist(lapply(y1.ntrt.prob, function(x)
      stats::rbinom(1, 1, x)))
    
    # Create arm 2 y-value
    y1.trt.intercept = unlist(lapply(1:nclusters[1], function(x)
      rep(randint.trt.1[x], length.out = nsubjects[nclusters[1] + x])))
    y1.trt.linpred = y1.trt.intercept + logit.p2t1
    y1.trt.prob = expit(y1.trt.linpred)
    y1.trt = unlist(lapply(y1.trt.prob, function(x)
      stats::rbinom(1, 1, x)))
    
    # Create single response vector
    y = c(y0.ntrt, y0.trt, y1.ntrt, y1.trt)
    
    # Create and store data frame for simulated dataset
    sim.dat = data.frame(
      y = y,
      trt = as.factor(trt),
      period = as.factor(period),
      clust = as.factor(clust)
    )
    if (allSimData == TRUE) {
      simulated.datasets[[i]] = list(sim.dat)
    }
    
    # option to return simulated data only
    if (nofit == TRUE) {
      if (!exists("nofitop")) {
        nofitop <- data.frame(
          period = sim.dat['period'],
          cluster = sim.dat['clust'],
          arm = sim.dat['trt'],
          y1 = sim.dat["y"]
        )
      } else {
        nofitop[, length(nofitop) + 1] <- sim.dat["y"]
      }
      if (length(nofitop) == (nsim + 3)) {
        temp1 <- seq(1:nsim)
        temp2 <- paste0("y", temp1)
        colnames(nofitop) <- c('period', 'cluster', 'arm', temp2)
      }
      if (length(nofitop) != (nsim + 3)) {
        next()
      }
      return(nofitop)
    }
    
    # Calculate mean values for given simulation
    iter.values = cbind(stats::aggregate(y ~ trt + period, data = sim.dat, mean)[, 3])
    values.vector = values.vector + iter.values
    
    # Calculate ICC2 ([P(Yij = 1, Yih = 1)] - pij * pih) / sqrt(pij(1 - pij) * pih(1 - pih))
    icc2 = (mean(c(mean(y0.ntrt), mean(y1.ntrt))) - p1t1) * 
      (mean(c(mean(y0.trt), mean(y1.trt))) - p2t1) / 
      sqrt((p1t1 * (1 - p1t1)) * p2t1 * (1 - p2t1))
    icc2.vector[i] = icc2
    
    # Calculate LMER.ICC (lmer: sigma_b_sq / (sigma_b_sq + sigma))
    lmer.mod = lme4::lmer(y ~ trt + period + trt:period + (1 |
                                                             clust), data = sim.dat)
    lmer.vcov = as.data.frame(lme4::VarCorr(lmer.mod))[, 4]
    lmer.icc.vector[i] =  lmer.vcov[1] / (lmer.vcov[1] + lmer.vcov[2])
    
    # Set warnings to OFF
    # Note: Warnings will still be stored in 'warning.list'
    options(warn = -1)
    
    # Fit GLMM (lmer)
    if (method == 'glmm') {
      my.mod = lme4::glmer(
        y ~ trt + period + trt:period + (1 |
                                           clust),
        data = sim.dat,
        family = stats::binomial(link = 'logit')
      )
      glmm.values = summary(my.mod)$coefficient
      est.vector[i] = glmm.values['trt2:period1', 'Estimate']
      se.vector[i] = glmm.values['trt2:period1', 'Std. Error']
      stat.vector[i] = glmm.values['trt2:period1', 'z value']
      pval.vector[i] = glmm.values['trt2:period1', 'Pr(>|z|)']
      converge[i] = is.null(my.mod@optinfo$conv$lme4$messages)
    }
    
    # Set warnings to ON
    options(warn = 0)
    
    # Fit GEE (geeglm)
    if (method == 'gee') {
      sim.dat = dplyr::arrange(sim.dat, clust)
      my.mod = geepack::geeglm(
        y ~ trt + period + trt:period,
        data = sim.dat,
        family = stats::binomial(link = 'logit'),
        id = clust,
        corstr = "exchangeable"
      )
      gee.values = summary(my.mod)$coefficients
      est.vector[i] = gee.values['trt2:period1', 'Estimate']
      se.vector[i] = gee.values['trt2:period1', 'Std.err']
      stat.vector[i] = gee.values['trt2:period1', 'Wald']
      pval.vector[i] = gee.values['trt2:period1', 'Pr(>|W|)']
      converge[i] <- ifelse(summary(my.mod)$error == 0, TRUE, FALSE)
    }
    
    # option to stop the function early if fits are singular
    if (poorFitOverride == FALSE && converge[i] == FALSE && i > 50) {
      if (sum(converge == FALSE, na.rm = TRUE) > (nsim * .25)) {
        stop(
          "more than 25% of simulations are singular fit: check model specifications"
        )
      }
    }
    
    # stop the loop if power is <0.5
    if (lowPowerOverride == FALSE && i > 50 && (i %% 10 == 0)) {
      sig.val.temp <-
        ifelse(pval.vector < alpha, 1, 0)
      pval.power.temp <- sum(sig.val.temp, na.rm = TRUE) / i
      if (pval.power.temp < 0.5) {
        stop(
          paste(
            "Calculated power is < ",
            pval.power.temp,
            ". Set lowPowerOverride == TRUE to run the simulations anyway.",
            sep = ""
          )
        )
      }
    }
    
    # Update progress information
      # Print simulation start message
      if (i == 1) {
        avg.iter.time = as.numeric(difftime(Sys.time(), start.time, units = 'secs'))
        time.est = avg.iter.time * (nsim - 1) / 60
        hr.est = time.est %/% 60
        min.est = round(time.est %% 60, 3)
        if (min.est > 2 && timelimitOverride == FALSE){
          stop(paste0("Estimated completion time: ",
                      hr.est,
                      'Hr:',
                      min.est,
                      'Min'
          ))
        }
        if (quiet == FALSE) {
        message(
          paste0(
            'Begin simulations :: Start Time: ',
            Sys.time(),
            ' :: Estimated completion time: ',
            hr.est,
            'Hr:',
            min.est,
            'Min'
          )
        )
      }
      # Print simulation complete message
      if (sum(converge == TRUE) == nsim) {
        message(paste0("Simulations Complete! Time Completed: ", Sys.time()))
      }
    }
    # Iterate progress bar
    prog.bar$update(sum(converge == TRUE) / nsim)
    Sys.sleep(1 / 100)
  }
  
  ## Output objects
  # Create object containing summary statement
  summary.message = paste0(
    "Monte Carlo Power Estimation based on ",
    nsim,
    " Simulations: Difference in Difference Design, Binary Outcome."
  )
  
  # Create method object
  long.method = switch(method, glmm = 'Generalized Linear Mixed Model',
                       gee = 'Generalized Estimating Equation')
  
  # Store model estimate output in data frame
  cps.model.est = data.frame(
    Estimate = as.vector(unlist(est.vector)),
    Std.err = as.vector(unlist(se.vector)),
    Test.statistic = as.vector(unlist(stat.vector)),
    p.value = as.vector(unlist(pval.vector)),
    converge = as.vector(unlist(converge))
  )
  cps.model.est[, 'sig.val'] = ifelse(cps.model.est[, 'p.value'] < alpha, 1, 0)
  
  # Calculate and store power estimate & confidence intervals
  # pval.data = subset(cps.model.est, converge == TRUE)
  cps.model.temp <- dplyr::filter(cps.model.est, converge == TRUE)
  power.parms <- confintCalc(nsim = nsim,
                             alpha = alpha,
                             p.val = cps.model.temp[, 'p.value'])

  # Create object containing inputs
  p1.p2.or = round(p1t1 / (1 - p1t1) / (p2t1 / (1 - p2t1)), 3)
  p2.p1.or = round(p2t1 / (1 - p2t1) / (p1t1 / (1 - p1t1)), 3)
  inputs = t(data.frame(
    'Arm.1' = c("probability" = p1t1, "odds.ratio" = p1.p2.or),
    'Arm.2' = c("probability" = p2t1, 'odds.ratio' = p2.p1.or),
    'Difference' = c(
      "probability" = p.diff,
      'odds.ratio' = p2.p1.or - p1.p2.or
    )
  ))
  
  # Create object containing arm & time-specific differences
  values.vector = values.vector / nsim
  differences = data.frame(
    Period = c(0, 0, 1, 1),
    Arm.2 = c(0, 1, 0, 1),
    Values = round(values.vector, 3)
  )
  
  # Create object containing group-specific cluster sizes
  cluster.sizes = list('Arm.1' = nsubjects[1:nclusters[1]],
                       'Arm.2' = nsubjects[(nclusters[1] + 1):(nclusters[1] + nclusters[2])])
  
  # Create object containing number of clusters
  n.clusters = t(data.frame(
    "Arm.1" = c("n.clust" = nclusters[1]),
    "Arm.2" = c("n.clust" = nclusters[2])
  ))
  
  # Create object containing estimated ICC values
  ICC = round(t(data.frame(
    'P_h_0' = c('ICC' = icc1_0),
    'P_h_1' = c('ICC' = icc1_1),
    'P_c' = c('ICC' = mean(icc2.vector)),
    'lmer' = c('ICC' = mean(lmer.icc.vector))
  )), 3)
  # Create object containing all ICC values
  # Note: P_h is a single calculated value. No vector to be appended.
  icc.list = data.frame('P_c' = icc2.vector,
                        'lmer' = lmer.icc.vector)
  
  # Create object containing group-specific variance parameters
  var.parms = list(
    "Time.Point.0" = data.frame(
      'Arm.1' = c("sigma_b_sq" = sigma_b_sq0[1]),
      'Arm.2' = c("sigma_b_sq" = sigma_b_sq0[2])
    ),
    "Time.Point.1" = data.frame(
      'Arm.1' = c("sigma_b_sq" = sigma_b_sq1[1]),
      'Arm.2' = c("sigma_b_sq" = sigma_b_sq1[2])
    )
  )
  
  # Check & governor for inclusion of simulated datasets
  if (allSimData == FALSE &&
      (sum(converge == FALSE) < sum(converge == TRUE) * 0.05)) {
    simulated.datasets = NULL
  }
  
  # Create list containing all output (class 'crtpwr') and return
  complete.output = structure(
    list(
      "overview" = summary.message,
      "nsim" = nsim,
      "power" = power.parms,
      "method" = long.method,
      "alpha" = alpha,
      "cluster.sizes" = cluster.sizes,
      "n.clusters" = n.clusters,
      "variance.parms" = var.parms,
      "inputs" = inputs,
      "differences" = differences,
      "ICC" = ICC,
      "icc.list" = icc.list,
      "model.estimates" = cps.model.est,
      "sim.data" = simulated.datasets
    ),
    class = 'crtpwr'
  )
  return(complete.output)
}
