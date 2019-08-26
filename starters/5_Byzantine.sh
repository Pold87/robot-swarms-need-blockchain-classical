#!/bin/sh

. ./global_config.sh

EXPERIMENT='5_Byzantine'

# Decision rule 1: LAC
# Decision rule 2: W-MSR
DECISIONRULE=$1
PERCENT_BLACKS=(25)
EPSILONS=(0.01)
NUMBYZANTINE=(0 1 2 3 4 5 6 7 8 9)
LENGTHOFRUNS=(1000)

DETERMINECONSENSUS="false"
BYZANTINESWARMSTYLES=(1)
MIXINGS=("true") # mix or tiles or just have a binary field
SUBSWARMCONSENSUS=false # Determines if all N robots have to agree or
		       # only the beneficial subswarm.

. ./run_experiment.sh
