# 3_Threshold

source("aggregate_runs.R")
source("myplothelpers.R")

report.dir <- "../plots/"

## Binary distribution of black and white tiles

decision <- 1
byzstyle <- 0

df.1 <- create.df(folder="4_Threshold_Byzantine",
                  byzstyle=byzstyle,
                  mixing="true",
                  diffs=25,
                  dec=decision,
                  thresholds = c(.02),
                  num.byz = seq(0, 10, 1)) ## Iterate over runs and create big df


## Increasing the number of Byzantine robots using LAC
plot.MAE.by.byz.gg(df.1,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("4_Threshold_Byzantine/MAE-LAC-byzstyle%d.pdf", byzstyle),
                  report.dir)


## Binary distribution of black and white tiles

decision <- 2
byzstyle <- 0

df.2 <- create.df(folder="4_Threshold_Byzantine",
                  byzstyle=byzstyle,
                  mixing="true",
                  diffs=25,
                  dec=decision,
                  thresholds = c(.02),
                  num.byz = seq(0, 10, 1)) ## Iterate over runs and create big df


## Increasing the number of Byzantine robots using LAC
plot.MAE.by.byz.gg(df.2,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("4_Threshold_Byzantine/MAE-WMSR-byzstyle%d.pdf", byzstyle),
                  report.dir)
