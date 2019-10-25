#!/bin/sh

. ./global_config.sh

EXPERIMENT='2_Binary'

# Decision rule 1: LAC
# Decision rule 2: W-MSR
DECISIONRULE=$1
PERCENT_BLACKS=(90)
EPSILONS=(0.01)
NUMBYZANTINE=(0)
LENGTHOFRUNS=(1000)
# An explanation of the Byzantine styles can be found in global config

DETERMINECONSENSUS="false"
BYZANTINESWARMSTYLES=(0)
MIXINGS=(2) # mix or tiles or just have a binary field
SUBSWARMCONSENSUS=false # Determines if all N robots have to agree or
		       # only the beneficial subswarm.

# Iterate over experimental settings and start experiments 
. ./run_experiment.sh
