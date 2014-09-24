# TODO: write a version which compares the transaction arrival rate per transaction
# between 2 monitor log files

arrivalRateOverTime <- function(file, startHour = 0, endHour = 24) {
  source("monitorLogFile.R")
  library(ggplot2)
  library(scales)
  
  # Read in the monitor log file into a data table
  data <- monitorLogFile(file, startHour, endHour)
  
  # Create a per minute time sequence from start to end
  startTime <- min(data[,Start.Time])
  endTime <- max(data[,Start.Time])
  timeBreaks <- seq.POSIXt(from=startTime, to=endTime, by="5 min")
  
  # Create a vector of factors which will be used to "bin" each transaction
  groupingFactors <- cut(data$Start.Time, timeBreaks)
  
  # Attach the grouping factors to the data table
  data[,grouping:=groupingFactors]
  
  # TODO: improve this by making it a function call
  # Delete all existing graphs if they exist
  if(file.exists("arrivalRates")) {
    graphs <- list(list.files("arrivalRates", full.names=TRUE))
    do.call(file.remove,graphs)
  } else {
    dir.create("arrivalRates")
  }
  
  transactionTypes <- levels(data$Transaction)
  
  for(index in seq_along(transactionTypes)) {
    transactionType <- transactionTypes[index]
    print(paste(index, "=", transactionType))
    
    # Create table of counts per time interval
    groupedData <- data[transactionType, length(Duration), by=grouping]
    setnames(groupedData, c("grouping", "V1"), c("Time", "Count"))
    
    # Convert the x-axis data series from factors to time, so they plot much better.
    groupedData[,DateTime:=as.POSIXct(as.character(Time))]
    
    # Exclude transaction types which don't have a minimum number of time samples
    if(nrow(groupedData) < 5) {
      print("Skipping this one because there are not enough time samples to plot")
      next
    }
    
    ggp <- ggplot(data=groupedData, mapping=aes(x=DateTime, y=Count))
    
    labels <- labs(title=transactionType, y="Count", x="Time")
    
    theme <- theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
                   plot.title = element_text(size = rel(0.75)))
    
    timescale <- scale_x_datetime(breaks=date_breaks("1 hour"), minor_breaks=date_breaks("10 min"))
    
    plot <- ggp + geom_line(colour="blue") + labels + theme + expand_limits(y = 0) + timescale
    
    ggsave(plot=plot, filename=paste("arrivalRates/", index, ".png", sep=""))
  }
}
