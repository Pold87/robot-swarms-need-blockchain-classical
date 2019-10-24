#!/bin/sh

. ./global_config.sh

EXPERIMENT='1_Plain'
# Decision rule 1: LAC
# Decision rule 2: W-MSR
DECISIONRULE=$1
PERCENT_BLACKS=(10 20 30 40 50 60 70 80 90 100)
EPSILONS=(0.01)
NUMBYZANTINE=(0)
LENGTHOFRUNS=(1000)

DETERMINECONSENSUS="false"
BYZANTINESWARMSTYLES=(0)
SUBSWARMCONSENSUS=false # Determines if all N robots have to agree or
		       # only the beneficial subswarm.

. ./run_experiment.sh
