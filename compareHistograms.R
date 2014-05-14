# Loads 2 monitor log files and generates a histogram for each transaction type
compareHistograms <- function(file1, file2) {
        source("monitorLogFile.R")
        data1 <- monitorLogFile(file1)
        data2 <- monitorLogFile(file2)
        
        if(file.exists("histograms")) {
                graphs <- list(list.files("histograms", full.names=TRUE))
                do.call(file.remove,graphs)
        } else {
                dir.create("histograms")
        }
        
        transactionTypes <- levels(data1$Transaction)
        for(index in seq_along(transactionTypes)) {
                # prep data, taking log10's of durations
                transactionType <- transactionTypes[index]
                logDurations1 <- data1[transactionType, log10(Duration)]$V1
                logDurations2 <- data2[transactionType, log10(Duration)]$V1
                
                # skip if have less than 3 samples, as histogram won't work otherwise
                if(length(logDurations1) <= 2 || length(logDurations2) <= 2) {
                        print(paste(index, "= (SKIPPED) ", transactionType))
                        next()
                }
                
                hist1 <- hist(logDurations1, plot=FALSE)
                hist2 <- hist(logDurations2, plot=FALSE)

                maxCounts <- max(hist1$counts, hist2$counts)
                
                # open PNG graphics device
                print(paste(index, "=", transactionType))
                png(filename=paste("histograms/", index, ".png", sep=""), width=600, height=600)
                
                # build up the graph
                plot(hist1, col=rgb(1,0,0,1/4), main=transactionType, xlab="Log Duration (millisecs)", 
                     xlim=c(0,5), ylim=c(0, maxCounts), type="n")
                lines(hist1, col=rgb(1,0,0,1/4))
                lines(hist2, col=rgb(0,0,1,1/4))
                legend("topright", lty=1, c(file1, file2), col=c("red", "blue"))
                
                # TODO: Use try/catch to ensure device is closed
                dev.off()
        }
}
