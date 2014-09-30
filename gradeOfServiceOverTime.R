# Charts the grade of service over time per transaction.
# File is a regular expression and multiple files can be picked up if there is a match

gradeOfServiceOverTime <- function(file, quantile=0.95, startHour = 0, endHour = 24, binPeriod = "5 min", combineFiles = FALSE) {
  source("multiMonitorLogFile.R")
  source("commonFunctions.R")
  library(ggplot2)
  library(scales)
  
  # Read in the monitor log file into a data table
  data <- multiMonitorLogFile(file, startHour, endHour)
  
  # Flatten the filenames if we don't want to split by filenames
  # Must flatten filenames BEFORE grouping
  if(combineFiles == TRUE) {
    data$Filename <- file
  }
  
  # Create a per minute time sequence from start to end
  startTime <- min(data[,Start.Time])
  endTime <- max(data[,Start.Time])
  timeBreaks <- seq.POSIXt(from=startTime, to=endTime, by=binPeriod)
  
  # Create a vector of factors which will be used to "bin" each transaction
  timeSlots <- cut(data$Start.Time, timeBreaks)
  
  # Attach the grouping factors to the data table
  data[,Time:=timeSlots]
  
  # Require keying of data table for grouping
  setkey(data, Filename, Transaction, Time)
  
  # Create table of quantiles per time interval
  groupedData <- data[, quantile(Duration, quantile, na.rm=TRUE), by=list(Filename,Transaction,Time)]
  setnames(groupedData, "V1", "Quantile")
  
  # Convert the x-axis data series from factors to time, so they plot much better.
  groupedData[,DateTime:=as.POSIXct(as.character(Time))]
  
  # Delete all existing graphs if they exist
  createOrEmptyDirectory("quantiles")
  
  transactionTypes <- levels(data$Transaction)
  
  for(index in seq_along(transactionTypes)) {
    transactionType <- transactionTypes[index]
    print(paste(index, "=", transactionType))
    
    # Subset only for the transaction type
    graphData <- groupedData[Transaction == transactionType]

    # Exclude transaction types which don't have a minimum number of time samples
    if(nrow(graphData) < 5) {
      print("Skipping this one because there are not enough time samples to plot")
      next
    }
    
    ggp <- ggplot(data=graphData, mapping=aes(x=DateTime, y=Quantile, colour=Filename))
    
    labels <- labs(title=transactionType, y=paste(quantile, "percentile (ms)"), x="Time")
    
    theme <- theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
                   plot.title = element_text(size = rel(0.75)), legend.position="bottom",
                   legend.direction="vertical")
    
    timescale <- scale_x_datetime(breaks=date_breaks("1 hour"), minor_breaks=date_breaks("10 min"))
    
    plot <- ggp + geom_line() + labels + theme + expand_limits(y = 0) + timescale
    
    ggsave(plot=plot, filename=paste("quantiles/", index, ".png", sep=""))
  }
}
