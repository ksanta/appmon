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
                # prep data
                transactionType <- transactionTypes[index]
                logDurations1 <- data1[transactionType, log10(Duration)]$V1
                logDurations2 <- data2[transactionType, log10(Duration)]$V1
                
                # skip if have less than 3 samples, as density function won't work otherwise
                if(length(logDurations1) <= 2 || length(logDurations2) <= 2) {
                        print(paste(index, "= (SKIPPED) ", transactionType))
                        next()
                }
                
                # build up the graph
                print(paste(index, "=", transactionType))
                png(filename=paste("histograms/", index, ".png", sep=""), width=600, height=600)
                plot(density(logDurations1), xlab="Log Duration (millisecs)", main=transactionType, col="red", type="n", xlim=c(0,5))
                lines(density(logDurations1), col="red")
                lines(density(logDurations2), col="blue")
                
                legend("topright", lty=1, c(file1, file2), col=c("red", "blue"))
                dev.off()
        }
}
