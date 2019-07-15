source("myplothelpers.R")

## June 2019
## Volker Strobel
## This script creates the plots for the frontiers paper

difficulties <- c(10)
num.byz <- c(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

do.experiment1 <- FALSE
do.experiment2 <- FALSE
do.experiment3 <- FALSE

data.base <- "../raw_data/"
report.dir <- "../plots/"
N = 20

## Experiment 3 (Increasing the number of Byzantine robots)
create.df <- function(folder, max.trials=30, dec=1, mixing="true", byzstyle=0, diffs=40, thresholds=0, num.byz=0) {
    ## Ignore the first 100 lines in the csv since not all the data is
    ## there yet in the beginning of the experiment
    skipped.lines <- 100 
    N <- 15
    df <- data.frame(matrix(ncol = 6, nrow = 0))
    colnames(df) <- c("byz", "difficulty", "actual", "predicted", "cons.time", "threshold")
            for (i in 1:max.trials) {
                for (b in num.byz) {
                    for (diff in diffs) {
                        for (t in thresholds) {

                            if (t == 0) {
                                trials.name <- sprintf("%s/%s_%d/num20_black%d_byz%d_run%d.RUN1", data.base, folder, dec, diff, b, i)
                            } else {
                                trials.name <- sprintf("%s/%s_%d/num20_black%d_byz%d_eps%s_run%d.RUN1", data.base, folder, dec, diff, b, t, i)
                            }
                            
                            if (file.exists(trials.name)) {

                                print(trials.name)

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
                                ah <- t
                                my.list <- c(ab, ad, ae, af, ag, ah)
                                             
                                df <- rbind(df, my.list)
                                
                            }
                        }
                        }
                    }
                }
            }
    colnames(df) <- c("byz", "difficulty", "actual", "predicted", "cons.time", "threshold")

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
