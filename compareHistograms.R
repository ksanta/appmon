# Loads 2 monitor log files and generates a histogram for each transaction type
compareHistograms <- function(file1, file2) {
        source("monitorLogFile.R")
        data1 <- monitorLogFile(file1)
        
        if(file.exists("histograms")) {
                graphs <- list(list.files("histograms", full.names=TRUE))
                do.call(file.remove,graphs)
        } else {
                dir.create("histograms")
        }
        
        transactions <- levels(data1$Transaction)
        for(index in seq_along(transactions)) {
                # prep data
                transaction <- transactions[index]
                logDurations <- log(data1$Duration[data1$Transaction == transaction] * 1000)
                if(length(logDurations) <= 2) {
                        print(paste("*", index, "*", "=", transaction))
                        next()
                }
                
                # create graph
                print(paste(index, "=", transaction))
                png(filename=paste("histograms/", index, ".png", sep=""))
                plot(density(logDurations), xlab="Duration (secs)", main=transaction, col="red", type="n")
                lines(density(logDurations), col="red")
                rug(logDurations)
                legend("topright", lty=1, c("data1"), col=c("red"))
                dev.off()
        }
}