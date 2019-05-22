source("myplothelpers.R")

## April 2018
## Volker Strobel
## This script creates the plots for the ANTS 2018 paper

##difficulties <- c(34, 36, 38, 40, 42, 44, 46, 48)
difficulties <- c(10, 20, 30, 40, 50, 60, 70, 80, 90)
num.byz <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
style <- "blockchain"
nodes <- 0

do.experiment1 <- TRUE

dates.bc.exp1 <- c("09-09-2018")

dates.exp1 <- dates.bc.exp1
dates.exp2 <- dates.bc.exp2
dates.exp3 <- dates.bc.exp3

data.base <- "/Users/volkerstrobel/Documents/mygithub-software/blockchain-journal/data/"
report.dir <- "MIT_data/"
N = 20


# Experiment 1 (Increasing difficulty)
create.df.exp1 <- function(max.trials=10, dec=1, mixing="true", byzstyle=5) {
    df.1 <- data.frame()
    a <- list()
        for (dat in dates.exp1) {
            for (i in 1:max.trials) {
                for (d in difficulties) {
                    for (node in nodes){

                        trials.name <- sprintf("%s/experiment1_decision%d_mixing%s_byzstyle%d-node%d-%s/140000/num20_black%d_byz0_run%d.RUN1", data.base, dec, mixing, byzstyle, node, dat, d, i)

                       
                        if (file.exists(trials.name)) {

                            print(trials.name)
                            X <- tryCatch(read.table(trials.name, skip = 100, header=F, sep=","), error=function(e) NULL)

                            if (nrow(X) != 0 && !is.null(X)) {

                                ## extract last row
                                X <- X[nrow(X), ]
                                X$difficulty = round(d / (100 - d), 2)
                                X$actual = d / 100
                                up <- N + 1
                                X$predicted = 1 - mean(as.numeric(X[2:up]))
                                df.1 <- rbind(df.1, X)

                         }
                        }           
                    }
                }
            }
        }
    return(df.1)    
}

# Experiment 2 (Varying threshold)
create.df.exp2 <- function(max.trials=30) {
    d <- 40
    df <- data.frame()
        for (dat in dates.exp2) {
            for (i in 1:max.trials) {
                for (t in thresholds) {
                    for (node in nodes){

                        trials.name <- sprintf("%s/experiment1_decision2-node%d-%s/%d/num20_black%d_byz0_run%d-blockchain.RUN1", data.base, node, dat, t, d, i)
                        if (file.exists(trials.name)) {
                            print(trials.name)
                            X <- tryCatch(read.table(trials.name, header=T), error=function(e) NULL)
                            if (nrow(X) != 0 && !is.null(X)){

                                ## extract last row
                                X <- X[nrow(X), ]

                                
                                X$threshold <- t / 10^7
                                X$difficulty = round(d / (100 - d), 2)
                                X$actual = d / 100
                                X$predicted = 1 - X$mean / 10^7
                             if (nrow(df) == 0) {
                                 df <- X
                             } else  {
                                 df <- rbind(df, X)
                             }
                            }
                        }           
                    }
                }
            }
        }
    return(df)    
}


## Experiment 3 (Increasing the number of Byzantine robots)
create.df.exp3 <- function(dates, max.trials=10, dec=1, mixing="true", byzstyle=0) {
    d <- 40
    t <- 140000
    N <- 15
    df <- data.frame(matrix(ncol = 6, nrow = 0))
    colnames(df) <- c("byz", "threshold", "difficulty", "actual", "predicted", "cons.time")
        for (dat in dates) {
            for (i in 1:max.trials) {
                for (b in num.byz) {
                    for (node in nodes){
#                        trials.name <- sprintf("%s/experiment1_decision1-node%d-%s/140000/num20_black%d_byz%d_run%d.RUN1", data.base, node, dat, d, b, i)
                        trials.name <- sprintf("%s/experiment1_decision%d_mixing%s_byzstyle%d-node%d-%s/140000/num20_black%d_byz%d_run%d.RUN1", data.base, dec, mixing, byzstyle, node, dat, d, b, i)
                        print(trials.name)

                        if (file.exists(trials.name)) {

#                            print(trials.name)
                            
                            X <- tryCatch(read.table(trials.name, sep=",", skip = 100, header=F), error=function(e) NULL)
                            if (nrow(X) != 0 && !is.null(X)){

                                ## extract last row
                                last.row <- X[nrow(X), ]
                                ab <- b
                                ac <- t / 10^7
                                ad <- round(d / (100 - d), 2)
                                ae <- d / 100
                                up <-  ncol(X)
                                af <- 1 - mean(as.numeric(last.row[2:up]))
                                ag <- nrow(X)
                                my.list <- c(ab, ac, ad, ae, af, ag)
                                             
                                df <- rbind(df, my.list)
                                
                            }
                        }
                    }
                }
            }
        }
    colnames(df) <- c("byz", "threshold", "difficulty", "actual", "predicted", "cons.time")
    return(df)    
}



data_summary <- function(data, varname, groupnames){
  require(plyr)
  summary_func <- function(x, col){
    c(mean = mean(x[[col]], na.rm=TRUE),
      sd = sd(x[[col]], na.rm=TRUE))
  }
  data_sum<-ddply(data, groupnames, .fun=summary_func,
                  varname)
  data_sum <- rename(data_sum, c("mean" = varname))
 return(data_sum)
}

df1 <- create.df.exp1() ## Iterate over runs and create big df

sum <- data_summary(df1, "predicted", "actual")
#df <- df[df$clock < 1000, ]

df$error <- df$actual - df$predicted
df2 <- create.df.exp2() ## Iterate over runs and create big df


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


## Experiment 3 safe
source("myplothelpers.R")
plot.MAE.by.byz.gg(df3.safe,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("MAE_byz-secure-byzstyle%d.pdf", byzstyle),
                  report.dir) 



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

write.csv(df, "experiment1_ants2018.csv", row.names = FALSE, quote=FALSE)
write.csv(df2, "experiment2_ants2018.csv", row.names = FALSE, quote=FALSE)
write.csv(df3.nonsafe, "experiment3_nonsafe_ants2018.csv", row.names = FALSE, quote=FALSE)
write.csv(df3.safe, "experiment3_safe_ants2018.csv", row.names = FALSE, quote=FALSE)



source("myplothelpers.R")
plot.error.gg(df1,
              xlab=expression("Actual ("* rho['b']*")"),
              ylab=expression("Predicted ("* hat(rho)['b']*")"),
              sprintf("exp1_error.pdf"),
              report.dir)  

source("myplothelpers.R")
plot.cons.gg(df,
              xlab=expression("Actual ("* rho['b']*")"),
              ylab=expression("Consensus Time"),
              sprintf("constime.pdf"),
              report.dir)  


source("myplothelpers.R")
plot.exit.prob.gg1(df.agg,
                  xlab=expression("Actual ("* rho['b']*")"),
                  ylab=expression("Exit probability"),
                  sprintf("exitprob.pdf"),
                  report.dir)  


source("myplothelpers.R")
plot.abs.error.gg(df,
                  xlab=expression("Actual ("* rho['b']*")"),
                  ylab=expression("Mean Absolute Error"),
                  sprintf("absMeanError.pdf"),
                  report.dir)  


source("myplothelpers.R")
plot.blockchain.size.gg(df,
                  xlab=expression("Actual ("* rho['b']*")"),
                  ylab=expression("Blockchain size (MB)"),
                  sprintf("blockchain_size.pdf"),
                  report.dir)  


## Experiment 2 
source("myplothelpers.R")
plot.blockchain.size.by.tau.gg(df2,
                  xlab=expression("Threshold ("*tau*")"),
                  ylab=expression("Blockchain size (MB)"),
                  sprintf("blockchain_size_tau.pdf"),
                  report.dir)  



source("myplothelpers.R")
plot.error.by.tau.gg(df2,
                  xlab=expression("Threshold ("*tau*")"),
                  ylab=expression("Error"),
                  sprintf("error_tau.pdf"),
                  report.dir)  

source("myplothelpers.R")
plot.MAE.by.tau.gg(df2,
                  xlab=expression("Threshold ("*tau*")"),
                  ylab=expression("Mean absolute error"),
                  sprintf("MAE_tau.pdf"),
                  report.dir)  

source("myplothelpers.R")
plot.MSE.by.tau.gg(df2,
                   xlab=expression("Threshold ("*tau*")"),
                   ylab=expression("Mean squared error"),
                   sprintf("MSE_tau.pdf"),
                   report.dir)  

source("myplothelpers.R")
plot.cons.by.tau.gg(df2,
                    xlab=expression("Threshold ("*tau*")"),
                    ylab=expression("Consensus Time"),
                    sprintf("exp2-constime.pdf"),
                    report.dir)  


## Experiment 3 non-safe
source("myplothelpers.R")
plot.MAE.by.byz.gg(df3.nonsafe,
                  xlab=expression("Number of Byzantine robots (k)"),
                  ylab=expression("Mean absolute error"),
                  sprintf("MAE_byz-nonsecure.pdf"),
                  report.dir) 


