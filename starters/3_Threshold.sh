#!/bin/sh

. ./global_config.sh

EXPERIMENT='3_Threshold'

# Decision rule 1: LAC
# Decision rule 2: W-MSR
DECISIONRULE=$1
PERCENT_BLACKS=(25)
EPSILONS=(0.01 0.02 0.03 0.04 0.05)
NUMBYZANTINE=(0)
LENGTHOFRUNS=(5000)

DETERMINECONSENSUS="true"
BYZANTINESWARMSTYLES=(0)
SUBSWARMCONSENSUS=false # Determines if all N robots have to agree or
		       # only the beneficial subswarm.

. ./run_experiment.sh
