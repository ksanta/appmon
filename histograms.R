histograms <- function(file, startHour = 0, endHour = 24, filterByUser = NULL, singleChart = FALSE) {
  source("multiMonitorLogFile.R")
  source("commonFunctions.R")
  library(ggplot2)
  
  print("Please visit https://github.com/ksanta/appmon for latest version of this script")
  
  # Read in the monitor log file
  data <- multiMonitorLogFile(file, startHour, endHour)
  
  # Optionally filter down to one user
  if(!is.null(filterByUser)) {
    data <- data[User == filterByUser]
  }
  
  # Optionally flatten the transaction types
  if(singleChart == TRUE) {
    data$Transaction <- "All Transactions"
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
    
    title <- transactionType
    subtitle <- paste0("From ", startHour, ":00 till ",endHour, ":00")
    titleExpression <- bquote(atop(.(title), italic(.(subtitle))))
    labels <- labs(title=titleExpression, y="Count", x="Duration (milliseconds)")
    
    theme <- theme(legend.position="bottom", legend.direction="vertical", plot.title = element_text(size = rel(0.75)))
    
    plot <- ggp + histogram + scale_x_log10() + labels + theme + annotation_logticks(sides = "b")
    
    ggsave(plot=plot, filename=paste("histograms/", index, ".png", sep=""))
  }
}
