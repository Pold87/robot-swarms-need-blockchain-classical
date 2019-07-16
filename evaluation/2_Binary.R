## 2 - Binary distribution: Increasing the number of black cells
source("aggregate_runs.R")
source("myplothelpers.R")

report.dir <- "../plots/"


## Binary distribution of black and white tiles

decision <- 1
byzstyle <- 0

df.1 <- create.df(folder="2_Binary",
                  byzstyle=byzstyle,
                  mixing="false",
                  diffs=seq(0, 100, 10),
                  dec=decision) ## Iterate over runs and create big df


plot.error.gg(df.1,
              xlab=expression("Actual % of black cells"),
              ylab=expression("Predicted % of black cells"),
              out.name="AvP_1.pdf",
              sprintf("%s/2_Binary/", report.dir))

plot.MAE.error(df.1,
              xlab=expression("Actual % of black cells"),
              ylab=expression("Mean absolute error"),
              out.name="MAE_1.pdf",
              sprintf("%s/2_Binary/", report.dir))


## W-MSR
decision <- 2
byzstyle <- 0

df.2 <- create.df(folder="2_Binary",
                  byzstyle=byzstyle,
                  mixing="false",
                  diffs=seq(0, 100, 10),
                  dec=decision) ## Iterate over runs and create big df

plot.error.gg(df.2,
              xlab=expression("Actual % of black cells"),
              ylab=expression("Predicted % of black cells"),
              out.name="AvP_2.pdf",
              sprintf("%s/2_Binary/", report.dir))

plot.MAE.error(df.2,
              xlab=expression("Actual % of black cells"),
              ylab=expression("Mean absolute error"),
              out.name="MAE_2.pdf",
              sprintf("%s/2_Binary/", report.dir))
