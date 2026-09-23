##########################################################################################
# Factor Selection Procedure - configuration
#
# Every setting the procedure uses is defined here. The values are the ones used for the
# original runs. Every job loads this file before anything else.
##########################################################################################

cfg <- list()

###################PATHS###############################
cfg$paths <- list(
  data_dir    = "~",        # holds the network folders and reference files listed below
  results_dir = "~",        # results folders (DTIRealDataResults/, fMRIIndividualModelSetResults/, ...) are created here
  scratch_dir = "/scratch"  # each job works in <scratch_dir>/<JOBID>; RSiena writes its log files there
)

# Folders inside data_dir with one sub-folder per participant containing Window*.mat files
cfg$networks <- list(
  fMRI = "fMRIOriginal",
  DTI  = "DTIOriginal"
)

# Reference files inside data_dir
cfg$files <- list(
  subnetworks        = "FunctionalSystems.txt", # region number -> subnetwork (1-7), tab separated
  distance_matrix    = "DistanceMatrix.csv",    # region x region distances
  factor_weights     = "factorweights.mat"      # candidate weights for each factor when simulating networks
)

###################BRAIN REGIONS###############################
cfg$num_regions <- 100
cfg$subnetworks <- c("Vis", "SomMot", "DorsAttn", "SalVentAttn", "Limbic", "Cont", "Default")

###################FACTORS###############################
# Candidate RSiena effects the procedure chooses between. Whole-brain runs use the larger
# sets; runs on a single subnetwork use the smaller ones. The "combined" sets are
# used when fMRI and DTI are modelled together and include cross-network effects.
cfg$factors <- list(
  whole_brain          = c("density", "transTriads", "between", "nbrDist2", "cycle4", "outInAss", "X", "XWX",
                           "sameX", "sameXTransTrip", "jumpXTransTrip", "sameXCycle4", "sameEgoDist2"),
  whole_brain_combined = c("density", "transTriads", "between", "nbrDist2", "cycle4", "outInAss", "X", "XWX",
                           "sameX", "sameXTransTrip", "jumpXTransTrip", "sameXCycle4", "sameEgoDist2",
                           "closure", "sameWWClosure", "covNetNet", "allDifCovNetNet", "to", "sameWXClosure",
                           "jumpWXClosure", "crprod", "sharedTo"),
  subnetwork           = c("density", "transTriads", "between", "nbrDist2", "cycle4", "outInAss", "X", "XWX"),
  subnetwork_combined  = c("density", "transTriads", "between", "nbrDist2", "cycle4", "outInAss", "X", "XWX",
                           "closure", "to", "crprod", "sharedTo")
)

# Factors whose weights are stored under a different name in the factor weights file
# (cycle4ND was renamed cycle4 in recent RSiena versions)
cfg$factor_weight_names <- list(cycle4 = "cycle4ND")

###################RSIENA ESTIMATION###############################
cfg$siena <- list(
  # Standard estimation
  n3         = 1000,  # phase 3 iterations
  nsub       = 4,     # phase 2 subphases
  n2start    = 1,     # multiplier on the default phase 2 subphase length
  firstg     = 0.1,   # initial gain
  thetabound = Inf,

  n3_search  = 800,   # n3 used from the start of the Factor Selection Procedure onwards
  n3_final   = 1000,  # n3 for the estimate of the final model

  # Convergence reduction: re-estimation of the final model until it converges well
  reduction = list(n3 = 5000, nsub = 1, n2start = 2, firstg = 0.01),
  target_convergence = 0.2  # keep re-estimating while the maximum convergence t-ratio is above this
)

###################FACTOR SELECTION PROCEDURE###############################
cfg$procedure <- list(
  p_threshold       = 0.1,  # a factor enters (and stays in) the model if its score test p-value is below this
  reps              = 2,    # estimations per model; the one with the best convergence is kept
  search_repeats    = 1,    # score tests averaged per factor
  search_attempts   = 2,    # tries per score test estimation before a last try without the time limit
  subnet_attempts   = 1,    # search_attempts for the subnetwork runs that follow a whole-brain run
  all_factors_tries = 4,    # tries for the all-factors estimate and the final model estimate
  time_limit        = NULL, # optional time limit per estimation (seconds); NULL for none
  job_hours         = 160   # pause and checkpoint before this many hours (168 h walltime minus an 8 h buffer)
)

###################SIMULATED DATASETS###############################
# Both simulated datasets draw random models with a known set of factors, simulate time
# point 2 from a real time point 1, and check whether the procedure recovers the factors.
cfg$simulation <- list(
  rates = c(5, 20, 35, 50, 65),  # base rates used for simulated networks

  # Individual model set: one model per simulated window
  individual_model_set = list(
    models = 200,  # instances 1-200, each with its own model
    bias   = 5     # lower = more biased towards models with few factors
  ),

  # Group model set: a few models, each producing many simulated windows
  group_model_set = list(
    windows           = 350,  # models = windows / windows_per_model (7), each also has its first window
    windows_per_model = 50,   # windows simulated from each model after the first (instances 1-357 in total)
    bias              = 1
  ),
  subnetwork_repeats = 1  # whole-brain group model set runs also re-run each subnetwork this many times
)
