# Creates a graph per transaction type showing arrival rate over time.
# Given filename can be a regular expression so that it matches multiple files.
# Default grouping of transaction counts is a 5 minute interval, though this can be changed with binPeriod

arrivalRateOverTime <- function(file, startHour = 0, endHour = 24, binPeriod = "5 min", combineFiles = FALSE) {
  source("multiMonitorLogFile.R")
  library(ggplot2)
  library(scales)
  
  # Read in the monitor log file into a data table
  data <- multiMonitorLogFile(file, startHour, endHour)

  # Flatten the filenames if we don't want to split by filenames
  # Must flatten filenames BEFORE grouping
  if(combineFiles == TRUE) {
    data$Filename <- file
  }
  
  # Create a time sequence from start to end
  startTime <- min(data[,Start.Time])
  endTime <- max(data[,Start.Time])
  timeBreaks <- seq.POSIXt(from=startTime, to=endTime, by=binPeriod)
  
  # Create a vector of factors which will be used to "bin" each transaction
  timeSlots <- cut(data$Start.Time, timeBreaks)
  
  # Attach the grouping factors to the data table
  data[,Time:=timeSlots]

  # Require keying of data table for grouping
  setkey(data, Filename, Transaction, Time)
  
  # Group counts by Filename, Transaction & TimeSlot
  groupedData <- data[, length(Duration), by=list(Filename,Transaction,Time)]
  setnames(groupedData, "V1", "Count")
  
  # Convert the x-axis data series from factors to time, so they plot much better.
  groupedData[,DateTime:=as.POSIXct(as.character(Time))]

  # TODO: improve this by making it a function call
  # Delete all existing graphs if they exist
  if(file.exists("arrivalRates")) {
    graphs <- list(list.files("arrivalRates", full.names=TRUE))
    do.call(file.remove,graphs)
  } else {
    dir.create("arrivalRates")
  }
  
  transactionTypes <- levels(groupedData$Transaction)
  
  for(index in seq_along(transactionTypes)) {
    transactionType <- transactionTypes[index]
    print(paste(index, "=", transactionType))
    
    # Subset only for the transaction type
    graphData <- groupedData[Transaction == transactionType]
        
    # Exclude transaction types which don't have a minimum number of time samples
    # This is a preference, not a technical limitation.  Otherwise can generate lots of empty graphs.
    if(nrow(graphData) < 5) {
      print("Skipping this one because there are not enough time samples to plot")
      next
    }
    
    ggp <- ggplot(data=graphData, mapping=aes(x=DateTime, y=Count, colour=Filename))
    
    labels <- labs(title=transactionType, y="Count", x="Time")
    
    theme <- theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
                   plot.title = element_text(size = rel(0.75)), legend.position="bottom",
                   legend.direction="vertical")
    
    timescale <- scale_x_datetime(breaks=date_breaks("1 hour"), minor_breaks=date_breaks("10 min"))
    
    plot <- ggp + geom_line() + labels + theme + expand_limits(y = 0) + timescale
    
    ggsave(plot=plot, filename=paste("arrivalRates/", index, ".png", sep=""))
  }
}
