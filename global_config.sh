#!/bin/sh

TEMPLATE='experiments/epuck_EC_locale_template.argos'
OUTFILE="experiments/epuck.argos"
SCTEMPLATE='contracts/smart_contract_template.sol'
SCOUT='contracts/smart_contract_threshold.sol'
BASEDIR="$HOME/Documents/mypapers/2019-frontiers/code/linear_consensus/controllers/epuck_environment_classification/"
NUMROBOTS=(20)
REPETITIONS=100

NUMRUNS=1
THREADS=0
NOW=`date +"%d-%m-%Y"`

REALTIME="false"
FAKEIDENTITIES=(0)
MIXINGS=(1) # mix or tiles, have a binary field, or a regular distribution

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
