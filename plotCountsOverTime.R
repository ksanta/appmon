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
  timeBreaks <- seq(from=startTime, to=endTime, by="min")

  # Create a vector of factors which will be used to "bin" each transaction
  groupingFactors <- cut(data$Start.Time, timeBreaks)

  # Attach the grouping factors to the data table
  data[,grouping:=groupingFactors]
  
  # Create table of counts per time interval
  groupedData <- data[, length(Duration), by=grouping]
  setnames(groupedData, c("grouping", "V1"), c("Time", "Count"))
  
  ggplot(data=groupedData, mapping=aes(x=Time, y=Count)) + geom_point() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
}
