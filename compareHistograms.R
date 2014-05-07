# Loads 2 monitor log files and generates a histogram for each transaction type
compareHistograms <- function(file1, file2) {
        source("monitorLogFile.R")
        data1 <- monitorLogFile(file1)
        
        if(!file.exists("histograms")) {
                dir.create("histograms")
        }
        
        transactions <- levels(data1$Transaction)
        for(index in seq_along(transactions)) {
                transaction <- transactions[index]
                print(paste(index, "=", transaction))
                png(filename=paste("histograms/", index, ".png", sep=""))
                hist(data1$Duration[data1$Transaction == transaction], breaks=100, xlab="Duration (secs)",
                     main=transaction)
                
                dev.off()
        }
}