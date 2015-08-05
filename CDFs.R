CDFs <- function(file, startHour = 0, endHour = 24, filterByUser = NULL, singleChart = FALSE) {
  source("multiMonitorLogFile.R")
  source("commonFunctions.R")
  library(ggplot2)
  library(gridExtra)
  
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
  
  # Since we use logarithmic scale, remove all zero durations
  data <- data[Duration != 0]
  
  # Set key for fast lookups later on
  setkey(data, Transaction)
  
  # Delete all existing graphs if they exist
  createOrEmptyDirectory("CDFs")
  
  # Sort by highest counts first (can't use summary() as it creates an "other" group)
  transCounts <- data[,length(Duration),by=Transaction]
  transactionTypes <- transCounts[order(-V1)]$Transaction
  
  for(index in seq_along(transactionTypes)) {
    transactionType <- as.character(transactionTypes[index])
    
    print(paste0(index, "/",length(transactionTypes) , " = ", transactionType))
    
    # Build up the graph
    ggp <- ggplot(data=data[transactionType], mapping=aes(x=Duration, fill=Filename, colour=Filename))
    
    title <- transactionType
    subtitle <- paste0("From ", startHour, ":00 till ",endHour, ":00")
    titleExpression <- bquote(atop(.(title), italic(.(subtitle))))
    labels <- labs(title=titleExpression, y="Percentile", x="Duration (milliseconds)")
    
    theme <- theme(legend.position="bottom", legend.direction="vertical", plot.title = element_text(size = rel(0.75)))
    plot <- ggp + stat_ecdf() + scale_x_log10() + labels + theme + annotation_logticks(sides = "b")

    labels2 <- labs(title=titleExpression, y="Volume", x="Transaction")
    theme2 <- theme(legend.position="bottom", legend.direction="vertical", plot.title = element_text(size = rel(0.75)))
    plot2 <- ggp + geom_bar(mapping = aes(x=Transaction, fill=Filename, colour=Filename), width=0.4, position=position_dodge(width=0.5)) + theme2 + labels2

    # Use old style of plotting and I can't seem to save using ggsave()    
    png(filename = paste("CDFs/", index, ".png", sep=""), width = 1200, height = 900)
    grid.arrange(plot, plot2, ncol=2, widths=c(3,2))
    dev.off()
  }
}
