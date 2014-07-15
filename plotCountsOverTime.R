# TODO: write a version which compares the transaction arrival rate per transaction
# between 2 monitor log files

plotCountsOverTime <- function(file, startHour = 0, endHour = 24) {
  source("monitorLogFile.R")
  library(ggplot2)
  
  # Read in the monitor log file into a data table
  data <- monitorLogFile(file, startHour, endHour)
  
  # Create a per minute time sequence from start to end
  startTime <- data[1]$Start.Time
  endTime <- data[nrow(data)]$Start.Time
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
  
    ggp <- ggplot(data=groupedData, mapping=aes(x=Time, y=Count))
    labels <- labs(title=transactionType, y="Count", x="Time")
    theme <- theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
        plot.title = element_text(size = rel(0.75)))
    
    plot <- ggp + labels + geom_point() + theme
    
    ggsave(plot=plot, filename=paste("arrivalRates/", index, ".png", sep=""))
  }
}
