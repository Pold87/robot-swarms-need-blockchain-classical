######### 6_Byzantine_Binary

## LAC
decision <- 1
byzstyle <- 1

df.1 <- create.df(folder="6_Byzantine_Binary",
                  byzstyle=byzstyle,
                  mixing="false",
                  diff=25,
                  dec=decision,
                  num.byz = seq(0, 10, 1)) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using LAC
plot.MAE.by.byz.gg(df.1,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("6_Byzantine_Binary/MAE-LAC-byzstyle%d.pdf", byzstyle),
                  report.dir)


## WMSR
decision <- 2
byzstyle <- 1

df.2 <- create.df(folder="6_Byzantine_Binary",
                  byzstyle=byzstyle,
                  mixing="false",
                  diff=25,
                  dec=decision,
                  num.byz = seq(0, 10, 1)) ## Iterate over runs and create big df

## Increasing the number of Byzantine robots using W-MSR
plot.MAE.by.byz.gg(df.2,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("6_Byzantine_Binary/MAE-WMSR-byzstyle%d.pdf", byzstyle),
                  report.dir)
