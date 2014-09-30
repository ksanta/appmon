countsOverDuration <- function(file1, startHour = 0, endHour = 24, percentile = 95) {
  source("multiMonitorLogFile.R")
  library(ggplot2)
  
  # Read in the monitor log file
  data <- multiMonitorLogFile(file1, startHour, endHour)
  
  # Set key for fast lookups later on
  setkey(x=data, Transaction)
  
  # Delete all existing graphs if they exist
  if(file.exists("histograms")) {
    graphs <- list(list.files("histograms", full.names=TRUE))
    do.call(file.remove,graphs)
  } else {
    dir.create("histograms")
  }
  
  # Make sure to filter out transaction types which might have no counts as part of time filtering
  transactionCounts <- summary(data$Transaction)
  transactionTypes <- names(transactionCounts[transactionCounts > 0])
  
  for(index in seq_along(transactionTypes)) {
    transactionType <- transactionTypes[index]
    
    print(paste(index, "=", transactionType))
    
    #median1 <- quantile(data[Filename==file1 & Transaction==transactionType]$Duration, probs = percentile/100)
    
    # Build up the graph
    ggp <- ggplot(data=data[transactionType], mapping=aes(x=Duration, fill=Filename))
    histogram <- geom_histogram(alpha=0.5, binwidth=0.05, position="identity")
    labels <- labs(title=transactionType, y="Count", x="Duration (milliseconds)")
    theme <- theme(legend.position="bottom", legend.direction="vertical", plot.title = element_text(size = rel(0.5)))
    #vline.data <- data.frame(xint=c(median1), grp=letters[1])
    #median.lines <- geom_vline(data=vline.data, mapping=aes(xintercept = xint,colour = grp), size=2)
    # annotation_logticks
    
    plot <- ggp + histogram + scale_x_log10() + labels + theme #+ median.lines
    
    ggsave(plot=plot, filename=paste("histograms/", index, ".png", sep=""))
  }
}
