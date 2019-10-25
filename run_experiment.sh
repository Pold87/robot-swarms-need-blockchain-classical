echo "${EXPERIMENT}"

# Iterate over experimental settings and start experiments 
for i in `seq 1 $REPETITIONS`; do
    for MIXING in "${MIXINGS[@]}"; do
	for y in "${NUMBYZANTINE[@]}"; do

	    for BYZANTINESWARMSTYLE in "${BYZANTINESWARMSTYLES[@]}"; do
		for EPSILON in "${EPSILONS[@]}"; do

		    DATADIRBASE="data/${EXPERIMENT}_${DECISIONRULE}/"

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
			    sed -e "s|BASEDIR|$BASEDIR|g"\
				-e "s|NUMRUNS|$NUMRUNS|g"\
				-e "s|DATADIR|$DATADIR|g"\
				-e "s|RADIX|$RADIX|g"\
				-e "s|NUMROBOTS|$k|g"\
				-e "s|R0|$R0|g"\
				-e "s|B0|$B0|g"\
				-e "s|PERCENT_BLACK|$PERCENT_BLACK|g"\
				-e "s|PERCENT_WHITE|$PERCENT_WHITE|g"\
				-e "s|DECISIONRULE|$DECISIONRULE|g"\
				-e "s|USEMULTIPLENODES|$USEMULTIPLENODES|g"\
				-e "s|THREADS|$THREADS|g"\
				-e "s|NUMBYZANTINE|$y|g"\
				-e "s|BYZANTINESWARMSTYLE|$BYZANTINESWARMSTYLE|g"\
				-e "s|SUBSWARMCONSENSUS|$SUBSWARMCONSENSUS|g"\
				-e "s|REALTIME|$REALTIME|g"\
				-e "s|MIXING|$MIXING|g"\
				-e "s|SYBILATTACK|$SYBILATTACK|g"\
				-e "s|FLOODINGATTACK|$FLOODINGATTACK|g"\
				-e "s|REPLAYATTACK|$REPLAYATTACK|g"\
				-e "s|DETERMINECONSENSUS|$DETERMINECONSENSUS|g"\
				-e "s|EPSILON|$EPSILON|g"\
				-e "s|LENGTHOFRUNS|$LENGTHOFRUNS|g"\
				-e "s|FAKEIDENTITIES|$FAKEIDENTITIES|g"\
				-e "s|ARENASIZEDIM|$ARENASIZEDIM|g"\
				-e "s|ARENASIZEPLUSLARGE|$ARENASIZEPLUSLARGE|g"\
				-e "s|ARENASIZEPLUSSMALL|$ARENASIZEPLUSSMALL|g"\
				-e "s|ARENASIZEHALF|$ARENASIZEHALF|g"\
				-e "s|ARENASIZEMINUS|$ARENASIZEMINUS|g"\
				-e "s|CELLDIMENSION|$CELLDIMENSION|g"\
				$TEMPLATE > $OUTFILE
			    
			    # Start experiment
			    argos3 -c $OUTFILE
			done
		    done
		done		 
	    done	     
	done	 
    done     
done

