source("myplothelpers.R")

## June 2019
## Volker Strobel
## This script creates the plots for the frontiers paper

difficulties <- c(10)
num.byz <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

do.experiment1 <- FALSE
do.experiment2 <- FALSE
do.experiment3 <- FALSE

dates.exp1 <- c("23-05-2019")
data.base <- "../raw_data/"
report.dir <- "../plots/"
N = 20

# Experiment 1 (Increasing difficulty)
create.df.exp1 <- function(max.trials=10, dec=1, mixing="true", byzstyle=0) {
    df.1 <- data.frame()
    a <- list()
        for (dat in dates.exp1) {
            for (i in 1:max.trials) {
                for (d in difficulties) {

                        trials.name <- sprintf("%s/experiment1_decision%d_mixing%s_byzstyle%d-%s/num20_black%d_byz%d_run%d.RUN1", data.base, dec, mixing, byzstyle, dat, d, i)
                    print(trials.name)
                       
                        if (file.exists(trials.name)) {
                            print("existing")
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
create.df.exp3 <- function(dates, max.trials=10, dec=1, mixing="true", byzstyle=0, diff=40) {
    ## Ignore the first 100 lines in the csv since not all the data is
    ## there yet in the beginning of the experiment
    skipped.lines <- 100 
    N <- 15
    df <- data.frame(matrix(ncol = 5, nrow = 0))
    colnames(df) <- c("byz", "difficulty", "actual", "predicted", "cons.time")
        for (dat in dates) {
            for (i in 1:max.trials) {
                for (b in num.byz) {

                        trials.name <- sprintf("%s/experiment1_decision%d_mixing%s_byzstyle%d-%s/num20_black%d_byz%d_run%d.RUN1", data.base, dec, mixing, byzstyle, dat, diff, b, i)

                        if (file.exists(trials.name)) {

                            X <- tryCatch(read.table(trials.name, sep=",", skip = skipped.lines, header=F), error=function(e) NULL)
                            if (nrow(X) != 0 && !is.null(X)){

                                ## extract last row
                                last.row <- X[nrow(X), ]
                                ab <- b
                                ad <- round(diff / (100 - diff), 2)
                                ae <- diff / 100
                                up <-  ncol(X)
                                af <- 1 - mean(as.numeric(last.row[2:up]))
                                ag <- nrow(X) + skipped.lines
                                my.list <- c(ab, ad, ae, af, ag)
                                             
                                df <- rbind(df, my.list)
                                
                        }
                    }
                }
            }
        }
    colnames(df) <- c("byz", "difficulty", "actual", "predicted", "cons.time")

    df$error <- df$actual - df$predicted
    df$absError <- abs(df$error)
    df$squaredError <- df$error * df$error
    df$consWhite <- df$predicted < 0.5

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

add_stats <- function(df) {
    df <- data_summary(df3, varname="cons.time", groupnames = c("byz"))
    return(df)
    }
