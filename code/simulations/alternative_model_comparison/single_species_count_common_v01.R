# code to run single-species count-only models for common species
library(tidyverse)
library(nimble)
library(parallel)
library(MCMCvis)
library(here)

# see main simulation script for comments
sim_icm <- function(
    nsp = 15,          # number of species
    mu_alpha0 = 0.87,
    sigma_alpha0 = 1.95,
    mu_alpha1 = 0.05,    # community average for covariate effect
    sigma_alpha1 = 0.25,   # standard deviation among species for covariate effect
    mu_gamma0_ds = 5.5,
    mu_gamma0_c = 5.0,
    sigma_gamma0_ds = 0.25,
    sigma_gamma0_c = 0.25,
    nsites = 50,       # number of sites for distance sampling
    nrep = 1,          # number of temporal replicates
    b = 1000,          # distance to which animals are counted
    width = 25,        # width of distance classes
    nsites_tc_fact = 2 # multiplication factor of how much more count data sites there are
){
  
  nsites_tc <- nsites * nsites_tc_fact
  
  # abundance - intercept & covariate coefficient
  alpha0 <- rnorm( nsp, mean = mu_alpha0, sd = sigma_alpha0 )
  alpha1 <- rnorm( nsp, mean = mu_alpha1, sd = sigma_alpha1 )
  
  # intercept for scale parameter
  gamma0_c <- rnorm( nsp, mean = mu_gamma0_c, sd = sigma_gamma0_c )
  
  sp_df <- tibble::tibble(
    sp = 1:nsp,
    alpha0 = alpha0,
    alpha1 = alpha1, 
    gamma0_c = gamma0_c)
  
  com_truth <- tibble::tribble(
    ~param, ~truth,
    "mu_gamma0_c", mu_gamma0_c,
    "sd_gamma0_c", sigma_gamma0_c,
    "mu_alpha0", mu_alpha0,
    "sd_alpha0", sigma_alpha0,
    "mu_alpha1", mu_alpha1,
    "sd_alpha1", sigma_alpha1) 
  
  get_unique_integers <- function(n, ng){
    mat <- rmultinom(n, size = 1, prob = c(runif(ng, 0, 0.5)))
    rows <- apply(mat, 1, sum)
    return( rows )
  }
  
  site_covs_c <- tibble::tibble(
    site = 1:nsites_tc,
    x = runif(nsites_tc, -2, 2)) |> 
    dplyr::mutate(x = as.numeric(scale(x)))
  
  n_df_c <- expand.grid(sp = 1:nsp,
                        site =  1:nsites_tc,
                        rep =  1:nrep) |> 
    tibble::as_tibble() |> 
    dplyr::full_join(sp_df) |>
    dplyr::full_join(site_covs_c) |>
    dplyr::rename( xvar = x) |> 
    ( function(x) dplyr::mutate(x,
                                en = exp( alpha0 + alpha1 * xvar),
                                n = rpois(nrow(x), en)))() |> 
    dplyr::rowwise()  |>  
    # how many groups were there? (For assigning distance measurements)
    dplyr::mutate( ng = ifelse(n > 0, sample(1:n, 1), 0))  |> 
    dplyr::ungroup()
  
  n_vector_c <- c()
  site_vector_c <- c()
  rep_vector_c <- c()
  sp_vector_c <- c()
  for(i in 1 : nrow( n_df_c )) {
    if( n_df_c[[i, "n"]] == 0){
      n_vector_c <- c(n_vector_c, 0)
      site_vector_c <- c(site_vector_c, n_df_c[[i, "site"]])
      rep_vector_c <- c(rep_vector_c, n_df_c[[i, "rep"]])
      sp_vector_c <- c(sp_vector_c, n_df_c[[i, "sp"]])
    } else {
      n_vector_c <- c(n_vector_c, rep(1, n_df_c[[i, "ng"]]))
      site_vector_c <- c(site_vector_c, rep(n_df_c[[i, "site"]], n_df_c[[i, "ng"]]))
      rep_vector_c <- c(rep_vector_c, rep(n_df_c[[i, "rep"]], n_df_c[[i, "ng"]]))
      sp_vector_c <- c(sp_vector_c, rep(n_df_c[[i, "sp"]], n_df_c[[i, "ng"]]))
    }
  }
  
  # expanded df so each group can have a dclass :)
  n_df_expanded_c <- tibble::tibble(
    site = site_vector_c, 
    rep = rep_vector_c, 
    sp = sp_vector_c, 
    group = n_vector_c) |> # group is just a placeholder - means yes, there is a group
    dplyr::full_join(n_df_c) |> 
    dplyr::group_by(sp, site, rep) |> 
    dplyr::mutate(gs = ifelse(ng == 0, 0, 
                              get_unique_integers(n = n, ng = ng)))  |> 
    dplyr::ungroup()
  
  # assign distances to each group and simulate observation process, based on distance
  sigmaC <- exp(sp_df$gamma0_c)
  data_c <- NULL
  for( i in 1 : nrow(n_df_expanded_c) ) {
    if(n_df_expanded_c[[i, "ng"]] == 0){
      data_c <- tibble::as_tibble(
        rbind(data_c,
              cbind(
                site = n_df_expanded_c[[i, "site"]],
                rep = n_df_expanded_c[[i, "rep"]],
                sp = n_df_expanded_c[[i, "sp"]],
                group = n_df_expanded_c[[i, "group"]],
                eng = n_df_expanded_c[[i, "eng"]],
                n = n_df_expanded_c[[i, "n"]],
                ng = n_df_expanded_c[[i, "ng"]],
                gs = n_df_expanded_c[[i, "gs"]],
                group_obs = 0, 
                dclass = NA)))
    } else {
      d <- runif( 1, 0, b) # animals distributed uniformly
      dclass <- d %/% width + 1 # grab the dclass that it falls into
      # detection probability is a function of distance and the scale parameter
      p <- exp( -d * d / (2 * sigmaC[n_df_expanded_c[[i, "sp"]]] ^ 2))
      # was or was not the group observed?
      group_obs <- rbinom(n_df_expanded_c[[i, "group"]], 1, p)
      
      data_c <- tibble::as_tibble(
        rbind(data_c,
              cbind(
                site = n_df_expanded_c[[i, "site"]],
                rep = n_df_expanded_c[[i, "rep"]],
                sp = n_df_expanded_c[[i, "sp"]],
                group = n_df_expanded_c[[i, "group"]],
                eng = n_df_expanded_c[[i, "eng"]],
                n = n_df_expanded_c[[i, "n"]],
                ng = n_df_expanded_c[[i, "ng"]],
                gs = n_df_expanded_c[[i, "gs"]],
                group_obs = group_obs, 
                dclass = dclass)))
    }
  }
  
  # select out common species, defined as species with highest sum of observed counts
  transect_counts <- data_c |> 
    dplyr::filter( gs > 0) |> 
    dplyr::filter(group_obs == 1) |> 
    dplyr::group_by(sp, site, rep) |> 
    dplyr::summarise( count = sum(gs)) |> 
    dplyr::ungroup() |> 
    dplyr::full_join(
      dplyr::select( n_df_c, sp, site, rep, true_n = n)
    ) |> 
    dplyr::arrange(sp, site, rep) |> 
    dplyr::mutate(count = tidyr::replace_na(count, 0)) |> 
    dplyr::full_join(site_covs_c) |> 
    dplyr::group_by(sp) |> 
    dplyr::mutate(num_obs = sum(count)) |> 
    dplyr::filter( num_obs > 0 ) |> 
    dplyr::ungroup() |> 
    dplyr::filter( num_obs == max(num_obs)) |> 
    dplyr::arrange(sp, site, rep) |> 
    dplyr::slice(1:nsites_tc) |> 
    dplyr::select(sp, site, rep, true_n, count, x_tc = x)
  
  data <- list(
    MIDPOINT = seq(from = 12.5, to = 987.5, by = 25),
    V = 25, 
    B = 1000,
    HAB_TC = transect_counts$x_tc,
    yN_TC = transect_counts$count,
    true_n_tc = transect_counts$true_n)
  
  constants <- list(
    NSPECIES = length(unique(transect_counts$sp)),
    NBINS = length(data$MIDPOINT), 
    NCOUNTS = nrow(transect_counts), 
    SP_TC = transect_counts$sp - (unique(transect_counts$sp) - 1) )
  
  sp_info <- transect_counts |>
    dplyr::group_by(sp) |>
    dplyr::summarise(totTC = sum(true_n)) |>
    dplyr::left_join(sp_df)
  
  return(list(data = data,
              constants = constants,
              sp_info = sp_info,
              com_truth = com_truth))
}

# see main simulation code for comments
# here, community-level parameters are omitted, distance sampling loops are omitted, and species loop is length 1
model.code <- nimble::nimbleCode({
  
  for(s in 1:NSPECIES){
    gamma0_c[s] ~ dunif(0, 10)
    alpha0[s] ~ dnorm(0, sd = 2)
    alpha1[s] ~ dnorm(0, sd = 2)
    omega_c[s] <- exp(gamma0_c[s])
    pie_sp_c[s] <- sum( pie_c[1:NBINS, s])
    for (k in 1:NBINS ) {
      log(g_c[k,s]) <- -MIDPOINT[k] * MIDPOINT[k]/(2 * omega_c[s] * omega_c[s] )
      pie_c[k,s] <- g_c[k,s] * (V/B)
    }
  }
  for(i in 1:NCOUNTS) {
    log(lambda_tc[i]) <- alpha0[SP_TC[i]] + alpha1[SP_TC[i]] * HAB_TC[i]
    N_TC[i] ~ dpois( lambda_tc[i] )
    yN_TC[i] ~ dbin( pie_sp_c[SP_TC[i]], N_TC[i] )
  }
})

params <- c(
  "gamma0_c",
  "alpha0",
  "alpha1",
  "pie_sp_c",
  "N_TC")

make_inits <- function(data, constants) { 
  inits <- list(
    gamma0_c = rnorm(1, 5.5, 0.5),
    alpha0 = rnorm(1, 0, 1), 
    alpha1 = rnorm(1, 0, 1),
    N_TC =  data$yN_TC + 1)
  return(inits)
}

nburn <- 100000
ni <- nburn + 100000
nt <- 100
nc <- 3

min_simrep <- 1
max_simrep <- 1000

simrep_rank <- rank(min_simrep:max_simrep)
simrep_raw <- min_simrep:max_simrep

for( i in min(simrep_rank):max(simrep_rank)){
  
  simdat <- sim_icm()
  data <- simdat$data
  constants <- simdat$constants
  sp_info <- simdat$sp_info
  com_truth <- simdat$com_truth
  print(paste( "Starting rep", simrep_rank[i], "of", max(simrep_rank))) 
  start <- Sys.time()
  cl <- parallel::makeCluster(nc)
  
  parallel::clusterExport(cl, c("model.code",
                                "make_inits", 
                                "data", 
                                "constants", 
                                "params", 
                                "nburn", 
                                "ni", 
                                "nt"))
  
  for(j in seq_along(cl)) {
    set.seed(j)
    init <- make_inits(data, constants)
    set.seed(NULL)
    parallel::clusterExport(cl[j], "init")
  }
  
  out <- parallel::clusterEvalQ(cl, {
    library(nimble)
    library(coda)
    
    model <- nimble::nimbleModel(code = model.code,
                                 name = "model.code",
                                 constants = constants,
                                 data = data,
                                 inits = init)
    
    Cmodel <- nimble::compileNimble(model)
    modelConf <- nimble::configureMCMC(model)
    modelConf$addMonitors(params)
    modelMCMC <- nimble::buildMCMC(modelConf)
    CmodelMCMC <- nimble::compileNimble(modelMCMC, project = model)
    out1 <- nimble::runMCMC(CmodelMCMC, 
                            nburnin = nburn, 
                            niter = ni, 
                            thin = nt)
    
    return(as.mcmc(out1))
  })
  end <- Sys.time()
  time <- difftime(end, start, units = "hours")
  parallel::stopCluster(cl)
  
  outsum <- MCMCvis::MCMCsummary( out ) |> 
    as_tibble(rownames = "param")
  
  res <- sp_info |> 
    tidyr::pivot_longer(c("gamma0_c",
                          "alpha0",
                          "alpha1"), 
                        names_to = "param", values_to = "truth") |>
    dplyr::mutate(sp = sp - ( min(sp) - 1)) |> 
    dplyr::mutate(param = paste0(param, '[', sp, ']')) |> 
    dplyr::select(param, totTC, truth) |> 
    dplyr::full_join(
      dplyr::full_join( dplyr::mutate( dplyr::select( sp_info, sp, totTC), sp = sp - (min(sp) - 1)),
                        tibble::tibble(
                          sp = constants$SP_TC,
                          param = paste0("N_TC[", 1:length(data$true_n_tc), "]"),
                          truth = data$true_n_tc)
      )
    ) |> 
    dplyr::left_join(outsum) |> 
    tibble::add_column(simrep = simrep_raw[i])
  
  readr::write_csv(res, paste0("ssc_common_no_od_simrep_", formatC(simrep_raw[i], width = 4, format = "d", flag = "0"), "_results.csv"))
  print(paste("Rep", simrep_rank[i], "took", round(time[[1]], 3), "hours"))
  rm( cl, com_truth, constants, data, init, out, outsum, res, simdat, sp_info, end, start, time)
}
