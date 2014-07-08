plotCountsOverTime <- function(file, startHour = 0, endHour = 24) {
  source("monitorLogFile.R")
  
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
  
  plot(data[, length(Duration), by=grouping])
}
