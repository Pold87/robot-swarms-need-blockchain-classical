# Usage: bash start_xyz.sh <node1> <node2> <decision_rule>
USERNAME=`whoami`
TEMPLATE='experiments/epuck_EC_locale_template.argos'
OUTFILE="experiments/epuck.argos"
SCTEMPLATE='contracts/smart_contract_template.sol'
SCOUT='contracts/smart_contract_threshold.sol'
BASEDIR="$HOME/Documents/mypapers/2019-frontiers/code/linear_consensus/controllers/epuck_environment_classification/"
NUMROBOTS=(20)
REPETITIONS=30
# Decision rule 1: LAC
# Decision rule 2: W-MSR
DECISIONRULE=$1
PERCENT_BLACKS=(25)
NUMRUNS=1
THREADS=0
NOW=`date +"%d-%m-%Y"`
NUMBYZANTINE=(0 1 2 3 4 5 6 7 8 9)
LENGTHOFRUNS=(1000)
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

DETERMINECONSENSUS="false"
BYZANTINESWARMSTYLES=(11)
MIXINGS=("true") # mix or tiles or just have a binary field
REPLAYATTACK="false"
SYBILATTACK="false"
FLOODINGATTACK="true"
SUBSWARMCONSENSUS=false # Determines if all N robots have to agree or
		       # only the beneficial subswarm.

REALTIME="false"

# Iterate over experimental settings and start experiments 
 for i in `seq 1 $REPETITIONS`; do
     for MIXING in "${MIXINGS[@]}"; do
	 for y in "${NUMBYZANTINE[@]}"; do

	     for BYZANTINESWARMSTYLE in "${BYZANTINESWARMSTYLES[@]}"; do

		 DATADIRBASE="raw_data/experiment1_decision${DECISIONRULE}_mixing${MIXING}_byzstyle${BYZANTINESWARMSTYLE}-${NOW}/"

		 DATADIR="${DATADIRBASE}${THRESHOLD}/"
		 mkdir -p $DATADIR
	     
 
		 for k in "${NUMROBOTS[@]}"; do
		     
		     R0=$k
		     B0=0

		     for p in "${PERCENT_BLACKS[@]}"; do

			 PERCENT_BLACK=$p
			 PERCENT_WHITE=$(expr 100 - $PERCENT_BLACK)
		
			 RADIX=$(printf 'num%d_black%d_byz%d_run%d' $k $PERCENT_BLACK $y $i)
	
	# Create template
	sed -e "s|BASEDIR|$BASEDIR|g" -e "s|NUMRUNS|$NUMRUNS|g" -e "s|DATADIR|$DATADIR|g" -e "s|RADIX|$RADIX|g" -e "s|NUMROBOTS|$k|g" -e "s|R0|$R0|g" -e "s|B0|$B0|g" -e "s|PERCENT_BLACK|$PERCENT_BLACK|g" -e "s|PERCENT_WHITE|$PERCENT_WHITE|g" -e "s|DECISIONRULE|$DECISIONRULE|g" -e "s|USEMULTIPLENODES|$USEMULTIPLENODES|g" -e "s|THREADS|$THREADS|g" -e "s|NUMBYZANTINE|$y|g" -e "s|BYZANTINESWARMSTYLE|$BYZANTINESWARMSTYLE|g" -e "s|SUBSWARMCONSENSUS|$SUBSWARMCONSENSUS|g" -e "s|REALTIME|$REALTIME|g" -e "s|MIXING|$MIXING|g" -e "s|SYBILATTACK|$SYBILATTACK|g" -e "s|FLOODINGATTACK|$FLOODINGATTACK|g" -e "s|REPLAYATTACK|$REPLAYATTACK|g" -e "s|DETERMINECONSENSUS|$DETERMINECONSENSUS|g" $TEMPLATE > $OUTFILE
	
	# Start experiment
	argos3 -c $OUTFILE
		
		     done
		 done		 
	     done	     
	 done	 
     done     
done
