## 1 - Plain experiment: Increasing the number of black cells
source("aggregate_runs.R")
source("myplothelpers.R")

report.dir <- "../plots/"

## Laplacian-based consensus

decision <- 1
byzstyle <- 0

df.1 <- create.df(folder="1_Plain",
                  byzstyle=byzstyle,
                  mixing="true",
                  diffs=seq(0, 100, 10),
                  dec=decision) ## Iterate over runs and create big df

plot.error.gg(df.1,
              xlab=expression("Actual % of black cells"),
              ylab=expression("Predicted % of black cells"),
              out.name="AvP_1.pdf",
              sprintf("%s/1_Plain/", report.dir))

plot.MAE.error(df.1,
              xlab=expression("Actual % of black cells"),
              ylab=expression("Mean absolute error"),
              out.name="MAE_1.pdf",
              sprintf("%s/1_Plain/", report.dir))


## W-MSR
decision <- 2
byzstyle <- 0

df.2 <- create.df(folder="1_Plain",
                  byzstyle=byzstyle,
                  mixing="true",
                  diffs=seq(0, 100, 10),
                  dec=decision) ## Iterate over runs and create big df

plot.error.gg(df.2,
              xlab=expression("Actual % of black cells"),
              ylab=expression("Predicted % of black cells"),
              out.name="AvP_2.pdf",
              sprintf("%s/1_Plain/", report.dir))

plot.MAE.error(df.2,
              xlab=expression("Actual % of black cells"),
              ylab=expression("Mean absolute error"),
              out.name="MAE_2.pdf",
              sprintf("%s/1_Plain/", report.dir))
