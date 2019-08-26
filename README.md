# Run experiments
* Too run /all/ experiments:
** `./run_all.sh`
** The results are saved in `data/`.
* To run a single experiment:
** `bash starters/<experiment>.sh <decision_rule>


# Folder structure
* The folder `starters` contains the settings for the seven experiments. Each experiment script sources the files `global_config.sh` (contains variables like the number of robots) and the file `run_experiment.sh` (contains the main loop that iterates over all combinations of settings).
* To add a new experiments, create a new file in `starters`