#!/bin/sh

TEMPLATE='experiments/epuck_EC_locale_template.argos'
OUTFILE="experiments/epuck.argos"
SCTEMPLATE='contracts/smart_contract_template.sol'
SCOUT='contracts/smart_contract_threshold.sol'
BASEDIR="$HOME/Documents/mypapers/2019-frontiers/code/linear_consensus/controllers/epuck_environment_classification/"
NUMROBOTS=(20)
REPETITIONS=30

NUMRUNS=1
THREADS=0
NOW=`date +"%d-%m-%Y"`

REALTIME="false"
FAKEIDENTITIES=(0)
MIXINGS=(1) # mix or tiles, have a binary field, or a regular distribution

ARENASIZEDIM="2.0"
CELLDIMENSION="0.1"
# Cell dimension should be ARENASIZE / 20 for 400 tiles
# The cell dimension can be changed, this will result in more or less tiles
# HOWEVER!!: Then you also have to change header file value for TOTAL_CELLS
ARENASIZEPLUSLARGE=`echo $ARENASIZEDIM + 0.1 | bc`
ARENASIZEPLUSSMALL=`echo $ARENASIZEDIM + 0.0075 | bc`
ARENASIZEHALF=`echo $ARENASIZEDIM / 2 | bc`
ARENASIZEMINUS=`echo $ARENASIZEDIM - 0.1 | bc`



## Byzantine styles
# 1: Always send 0.0 as value
# 2: Always send 1.0 as value
# 3: Send 0.0 with probabiity 0.5, send 1.0 else
# 4: Send a random number between 0.0 and 1.0
# 5: Send the true value but apply Gaussian noise to the sensor readings
# 11: Perform a Sybil and flooding attack, always send 0.0 as value
# 12: Perform a Sybil and flooding attack, always send 1.0 as value
# 13: Perform a Sybil and flooding attack, send 0.0 with probabiity 0.5, send 1.0 else
# 14: Perform a Sybil and flooding attack, send a random number between 0.0 and 1.0
# 15: Perform a Sybil and flooding attack, send the true value but with some Gaussian noise
# 20: Perform a jamming attack
