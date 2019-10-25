#!/bin/sh

. ./global_config.sh

EXPERIMENT='10_Binary_Big'

# Decision rule 1: LAC
# Decision rule 2: W-MSR
DECISIONRULE=$1
PERCENT_BLACKS=(0 10 20 30 40 50 60 70 80 90 100)
EPSILONS=(0.01)
NUMBYZANTINE=(0)
LENGTHOFRUNS=(1000)
# An explanation of the Byzantine styles can be found in global config

DETERMINECONSENSUS="false"
BYZANTINESWARMSTYLES=(0)
MIXINGS=(2) # mix or tiles or just have a binary field
SUBSWARMCONSENSUS=false # Determines if all N robots have to agree or
		       # only the beneficial subswarm.

ARENASIZEDIM="10.0"
CELLDIMENSION="0.5"
# Cell dimension should be ARENASIZE / 20 for 400 tiles
# The cell dimension can be changed, this will result in more or less tiles
# HOWEVER!!: Then you also have to change header file value for TOTAL_CELLS
ARENASIZEPLUSLARGE=`echo $ARENASIZEDIM + 0.1 | bc`
ARENASIZEPLUSSMALL=`echo $ARENASIZEDIM + 0.0075 | bc`
ARENASIZEHALF=`echo $ARENASIZEDIM / 2 | bc`
ARENASIZEMINUS=`echo $ARENASIZEDIM - 0.1 | bc`

# Iterate over experimental settings and start experiments 
. ./run_experiment.sh
