##########################################################################################
# Factor Selection Procedure
#
# Finds which network formation factors (RSiena effects) explain how a network changed
# between time point 1 and time point 2:
#
#   1. All-Pairs Initialization  test every pair of factors and add up to two
#   2. Motion to Reconsider      drop factors that no longer meet the threshold
#                                (after every factor added)
#   3. Factor Addition           keep adding the factor with the lowest p-value while it
#                                is below the threshold
#
# Before it, a preparation step sets up the networks and the effects object the score
# tests work in (0_preparation/). Afterwards the chosen model is estimated and its results
# saved (after_factor_selection/).
#
# Runs once on the network chosen by TYPE3. Whole-brain group model set runs first run each
# functional system (groups 1-7) and finish with the whole brain (group 0).
##########################################################################################

# The networks are chosen: save them so a continuing job uses the same ones
if (INIT==FALSE && Pause==FALSE)
{
  INIT<-TRUE
  h<-1
  save.image(CheckpointFile(0))
}

while (h<=length(groups) && Pause==FALSE)
{
  g<-groups[h]

  ###################PREPARATION###############################
  Step("factor_selection_procedure/0_preparation/1_prepare_networks")
  Step("factor_selection_procedure/0_preparation/2_all_factors_estimate")
  Step("factor_selection_procedure/0_preparation/3_start_or_continue")

  ###################1. ALL-PAIRS INITIALIZATION###############################
  Step("factor_selection_procedure/1_all_pairs_initialization/1_score_all_pairs")
  Step("factor_selection_procedure/1_all_pairs_initialization/2_first_and_second_factor")
  Step("factor_selection_procedure/1_all_pairs_initialization/3_motion_to_reconsider")

  ###################3. FACTOR ADDITION###############################
  # One factor per round, each followed by a Motion to Reconsider, until none qualifies
  if (searching)
  {
    while(exit==FALSE && Pause==FALSE)
    {
      Step("factor_selection_procedure/3_factor_addition/1_score_remaining_factors")
      Step("factor_selection_procedure/3_factor_addition/2_add_best_factor")
      Step("factor_selection_procedure/3_factor_addition/3_motion_to_reconsider")
    }
    if (exit==TRUE)
    {
      PP<-TRUE
    }
  }

  ###################AFTER THE FACTOR SELECTION PROCEDURE###############################
  Step("after_factor_selection/1_final_model")
  Step("after_factor_selection/2_convergence_reduction")
  Step("after_factor_selection/3_save_results")
  Step("after_factor_selection/4_next_group")
}

file.remove(paste0(as.character(n),".txt"))

timetaken<-Now()-timer$start
print(timetaken)
