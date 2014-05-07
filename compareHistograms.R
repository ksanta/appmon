# Loads 2 monitor log files and generates a histogram for each transaction type
compareHistorgrams <- function(file1, file2) {
        source("monitorLogFile.R")
        data1 <- monitorLogFile(file1)
        
        for(transaction in levels(data1$Transaction)) {
                print(transaction)
                png(filename=paste(transaction, ".png", sep=""))
                hist(data1$Duration[data1$Transaction == transaction])
                dev.off()
        }
}