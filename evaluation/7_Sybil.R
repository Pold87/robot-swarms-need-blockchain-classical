## 7_Sybil
source("aggregate_runs.R")
source("myplothelpers.R")

report.dir <- "../plots/"

# Sybil attack with randomly distributed tiles

## LAC
decision <- 1
byzstyle <- 11

df.1 <- create.df(folder="7_Sybil",
                  byzstyle=byzstyle,
                  mixing="true",
                  diff=25,
                  dec=decision,
                  num.byz = seq(0, 10, 1)) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using LAC
plot.MAE.by.byz.gg(df.1,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("7_Sybil/MAE-LAC-byzstyle%d.pdf", byzstyle),
                  report.dir)


## WMSR
decision <- 2
byzstyle <- 11

df.2 <- create.df(folder="7_Sybil",
                  byzstyle=byzstyle,
                  mixing="true",
                  diff=25,
                  dec=decision,
                  num.byz = seq(0, 10, 1)) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using W-MSR
plot.MAE.by.byz.gg(df.2,
                   xlab=expression("Number of Byzantine robots (k)"),
                   ylab=expression("Mean absolute error"),
                   sprintf("7_Sybil/MAE-WMSR-byzstyle%d.pdf", byzstyle),
                   report.dir)
