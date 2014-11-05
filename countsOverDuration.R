countsOverDuration <- function(file, startHour = 0, endHour = 24, percentile = 95, combineFiles = FALSE) {
  source("multiMonitorLogFile.R")
  source("commonFunctions.R")
  library(ggplot2)
  
  # Read in the monitor log file
  data <- multiMonitorLogFile(file, startHour, endHour)
  
  # Flatten the filenames if we don't want to split by filenames
  # Must flatten filenames BEFORE grouping
  if(combineFiles == TRUE) {
    data$Filename <- file
  }

  # Set key for fast lookups later on
  setkey(data, Transaction)
  
  # Delete all existing graphs if they exist
  createOrEmptyDirectory("histograms")
  
  # Make sure to filter out transaction types which might have no counts as part of time filtering
  transactionCounts <- summary(data$Transaction)
  transactionTypes <- names(transactionCounts[transactionCounts > 0])
  
  for(index in seq_along(transactionTypes)) {
    transactionType <- transactionTypes[index]
    
    print(paste(index, "=", transactionType))
    
    # Build up the graph
    ggp <- ggplot(data=data[transactionType], mapping=aes(x=Duration, fill=Filename))
    histogram <- geom_histogram(alpha=0.5, binwidth=0.05, position="identity")
    labels <- labs(title=transactionType, y="Count", x="Duration (milliseconds)")
    theme <- theme(legend.position="bottom", legend.direction="vertical", plot.title = element_text(size = rel(0.5)))
    
    #median1 <- quantile(data[Filename==file & Transaction==transactionType]$Duration, probs = percentile/100)
    #vline.data <- data.frame(xint=c(median1), grp=letters[1])
    #median.lines <- geom_vline(data=vline.data, mapping=aes(xintercept = xint,colour = grp), size=2)
    
    plot <- ggp + histogram + scale_x_log10() + labels + theme + annotation_logticks(sides = "b")
    
    ggsave(plot=plot, filename=paste("histograms/", index, ".png", sep=""))
  }
}
