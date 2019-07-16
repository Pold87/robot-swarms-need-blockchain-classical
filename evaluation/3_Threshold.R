# 3_Threshold

source("aggregate_runs.R")
source("myplothelpers.R")

report.dir <- "../plots/"

## Binary distribution of black and white tiles

decision <- 1
byzstyle <- 0

df.1 <- create.df(folder="3_Threshold",
                  byzstyle=byzstyle,
                  mixing="true",
                  diffs=25,
                  dec=decision,
                  thresholds = c(.01, .02, .03, .04, .05),
                  num.byz = 0) ## Iterate over runs and create big df


plot.MAE.by.threshold(df.1,
                     xlab=expression("Threshold"),
                     ylab=expression("Mean absolute error"),
                     out.name="MAE_1.pdf",
                     sprintf("%s/3_Threshold/", report.dir))


## Binary distribution of black and white tiles

decision <- 2
byzstyle <- 0

df.2 <- create.df(folder="3_Threshold",
                  byzstyle=byzstyle,
                  mixing="true",
                  diffs=25,
                  dec=decision,
                  thresholds = c(.01, .02, .03, .04, .05),
                  num.byz = 0) ## Iterate over runs and create big df


plot.MAE.by.threshold(df.2,
                     xlab=expression("Threshold"),
                     ylab=expression("Mean absolute error"),
                     out.name="MAE_2.pdf",
                     sprintf("%s/3_Threshold/", report.dir))
