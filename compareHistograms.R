# Loads 2 monitor log files and generates a histogram for each transaction type
compareHistograms <- function(file1, file2, startHour = 0, endHour = 24) {
        source("monitorLogFile.R")
        library(ggplot2)
        
        # Read in the 2 monitor log files
        data1 <- monitorLogFile(file1, startHour, endHour)
        data2 <- monitorLogFile(file2, startHour, endHour)

        # TODO: Optimise using data.table features
        data1$Filename <- file1
        data2$Filename <- file2
        data <- rbind(data1, data2)
        setkey(x=data, Transaction)
        
        # Delete all existing graphs if they exist
        if(file.exists("histograms")) {
                graphs <- list(list.files("histograms", full.names=TRUE))
                do.call(file.remove,graphs)
        } else {
                dir.create("histograms")
        }
        
        transactionTypes <- levels(data1$Transaction)
        for(index in seq_along(transactionTypes)) {
                transactionType <- transactionTypes[index]
                
                print(paste(index, "=", transactionType))
                
                # build up the graph
                histogram <- geom_histogram(data=data[transactionType], mapping=aes(x=Duration, fill=Filename), binwidth=0.05)
                labels <- labs(title=transactionType, y="Count")
                
                plot <- ggplot() + histogram + scale_x_log10() + labels
                
                ggsave(plot=plot, filename=paste("histograms/", index, ".png", sep=""))
        }
}
