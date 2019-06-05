
df3.safe <- create.df.exp3(dates=dates.bc.exp3.secure, dec=2, byzstyle=byzstyle, mixing="true") ## Iterate over runs and create big df

                                        #df3.safe <- read.csv("/Users/volkerstrobel/Documents/mypapers/2018-ANTS/data/experiment3_secure_ants2018.csv")
df3.safe.agg <- data_summary(df3.safe, varname="cons.time", groupnames = c("byz"))
#df3.safe <- df3.safe[df3.safe$byz < 10, ]
df3.safe$error <- df3.safe$actual - df3.safe$predicted
df3.safe$absError <- abs(df3.safe$error)
df3.safe$squaredError <- df3.safe$error * df3.safe$error
df3.safe$consWhite <- df3.safe$predicted < 0.5


df$error <- df$actual - df$predicted
#df2 <- create.df.exp2() ## Iterate over runs and create big df


df2$error <- df2$actual - df2$predicted
df2$absError <- abs(df2$error)
df2$squaredError <- df2$error * df2$error


dates.bc.exp3.secure <- c("10-09-2018") ## uniformly random field
byzstyle=1
report.dir <- "MIT_data_W-MSR_mixingtrue/"
df3.safe <- create.df.exp3(dates=dates.bc.exp3.secure, dec=2, byzstyle=byzstyle, mixing="true") ## Iterate over runs and create big df

                                        #df3.safe <- read.csv("/Users/volkerstrobel/Documents/mypapers/2018-ANTS/data/experiment3_secure_ants2018.csv")
df3.safe.agg <- data_summary(df3.safe, varname="cons.time", groupnames = c("byz"))
#df3.safe <- df3.safe[df3.safe$byz < 10, ]
df3.safe$error <- df3.safe$actual - df3.safe$predicted
df3.safe$absError <- abs(df3.safe$error)
df3.safe$squaredError <- df3.safe$error * df3.safe$error
df3.safe$consWhite <- df3.safe$predicted < 0.5



df3.nonsafe <- create.df.exp3(dates=dates.bc.exp3.nonsecure, safe=F) ## Iterate over runs and create big df
df3.nonsafe <- df3.nonsafe[df3.nonsafe$byz < 10, ]
df3.nonsafe$error <- df3.nonsafe$actual - df3.nonsafe$predicted
df3.nonsafe$absError <- abs(df3.nonsafe$error)
df3.nonsafe$squaredError <- df3.nonsafe$error * df3.nonsafe$error
df3.nonsafe$consWhite <- df3.nonsafe$predicted < 0.5

df$consWhite <- df$predicted < 0.5
df$absError <- abs(df$error)


df$consWhite <- df$predicted < 0.5

df.agg <- data_summary(df, varname="consWhite", groupnames = c("actual"))
df.agg2 <- data_summary(df, varname=c("absError"), groupnames = c("actual"))
df.agg3 <- data_summary(df, varname=c("blockchain_size_kB"), groupnames = c("actual"))

write.csv(df, "../processed_data/experiment1_ants2018.csv", row.names = FALSE, quote=FALSE)
write.csv(df2, "../processed_data/experiment2_ants2018.csv", row.names = FALSE, quote=FALSE)
write.csv(df3.nonsafe, "../processed_data/experiment3_nonsafe_ants2018.csv", row.names = FALSE, quote=FALSE)
write.csv(df3.safe, "../processed_data/experiment3_safe_ants2018.csv", row.names = FALSE, quote=FALSE)

plot.error.gg(df1,
              xlab=expression("Actual ("* rho['b']*")"),
              ylab=expression("Predicted ("* hat(rho)['b']*")"),
              sprintf("exp1_error.pdf"),
              report.dir)  


plot.cons.gg(df,
              xlab=expression("Actual ("* rho['b']*")"),
              ylab=expression("Consensus Time"),
              sprintf("constime.pdf"),
              report.dir)  


plot.exit.prob.gg1(df.agg,
                  xlab=expression("Actual ("* rho['b']*")"),
                  ylab=expression("Exit probability"),
                  sprintf("exitprob.pdf"),
                  report.dir)  


plot.abs.error.gg(df,
                  xlab=expression("Actual ("* rho['b']*")"),
                  ylab=expression("Mean Absolute Error"),
                  sprintf("absMeanError.pdf"),
                  report.dir)  

## Experiment 2 


plot.error.by.tau.gg(df2,
                  xlab=expression("Threshold ("*tau*")"),
                  ylab=expression("Error"),
                  sprintf("error_tau.pdf"),
                  report.dir)  


plot.MAE.by.tau.gg(df2,
                  xlab=expression("Threshold ("*tau*")"),
                  ylab=expression("Mean absolute error"),
                  sprintf("MAE_tau.pdf"),
                  report.dir)  

plot.MSE.by.tau.gg(df2,
                   xlab=expression("Threshold ("*tau*")"),
                   ylab=expression("Mean squared error"),
                   sprintf("MSE_tau.pdf"),
                   report.dir)  

plot.cons.by.tau.gg(df2,
                    xlab=expression("Threshold ("*tau*")"),
                    ylab=expression("Consensus Time"),
                    sprintf("exp2-constime.pdf"),
                    report.dir)  


## Experiment 3 non-safe
plot.MAE.by.byz.gg(df3.nonsafe,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("MAE_byz-nonsecure.pdf"),
                  report.dir) 
