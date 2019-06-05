source("aggregate_runs.R")
source("myplothelpers.R")

report.dir <- "../plots/"



## Uniformly random distributed tiles

## Laplacian-based consensus

decision <- 1
byzstyle <- 1
dates.exp3 <- c("29-05-2019")

df3.lac <- create.df.exp3(dates.exp3, byzstyle=byzstyle, mixing="true", diff=10,
                          dec=decision) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using LAC
plot.MAE.by.byz.gg(df3.lac,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("mixing_true/MAE_exp3-LAC-byzstyle%d.pdf", byzstyle),
                  report.dir)


## W-MSR
decision <- 2
byzstyle <- 1
dates.exp3 <- c("29-05-2019")

df3.wmsr <- create.df.exp3(dates.exp3, byzstyle=byzstyle, mixing="true", diff=10,
                           dec=decision) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using W-MSR
plot.MAE.by.byz.gg(df3.wmsr,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("mixing_true/MAE_exp3-WMSR-byzstyle%d.pdf", byzstyle),
                  report.dir)

## Binary distribution of black and white tiles

decision <- 1
byzstyle <- 1
dates.exp3 <- c("29-05-2019")

df3.lac <- create.df.exp3(dates.exp3, byzstyle=byzstyle, mixing="false", diff=10,
                          dec=decision) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using LAC
plot.MAE.by.byz.gg(df3.lac,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("mixing_false/MAE_exp3-LAC-byzstyle%d.pdf", byzstyle),
                  report.dir)


## W-MSR
decision <- 2
byzstyle <- 1
dates.exp3 <- c("29-05-2019")

df3.wmsr <- create.df.exp3(dates.exp3, byzstyle=byzstyle, mixing="false", diff=10,
                           dec=decision) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using W-MSR
plot.MAE.by.byz.gg(df3.wmsr,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("mixing_false/MAE_exp3-WMSR-byzstyle%d.pdf", byzstyle),
                  report.dir)


## Sybil attack with uniformly random distributed tiles

## Laplacian-based consensus

decision <- 1
byzstyle <- 11
dates.exp3 <- c("29-05-2019")

df3.lac <- create.df.exp3(dates.exp3, byzstyle=byzstyle, mixing="true", diff=10,
                          dec=decision) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using LAC
plot.MAE.by.byz.gg(df3.lac,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("sybil_attack/MAE_exp3-LAC-byzstyle%d.pdf", byzstyle),
                  report.dir)


## W-MSR
decision <- 2
byzstyle <- 11
dates.exp3 <- c("29-05-2019")

df3.wmsr <- create.df.exp3(dates.exp3, byzstyle=byzstyle, mixing="true", diff=10,
                           dec=decision) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using W-MSR
plot.MAE.by.byz.gg(df3.wmsr,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("sybil_attack/MAE_exp3-WMSR-byzstyle%d.pdf", byzstyle),
                  report.dir)
