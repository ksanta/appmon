compareVolumes <- function(file1, file2, startHour = 0, endHour = 24) {
  library(plyr)
  source("multiMonitorLogFile.R")
  
  # Read in the 2 monitor log files
  data1 <- multiMonitorLogFile(file1, startHour, endHour)
  data2 <- multiMonitorLogFile(file2, startHour, endHour)
  
  # Calculate counts and average durations per transaction type for each file
  calc1 <- data1[, list(count=length(Duration)), by=Transaction]
  calc2 <- data2[, list(count=length(Duration)), by=Transaction]
  
  # Merge them together
  merged <- merge(calc1, calc2)
  
  # Calculate the percentage shift
  merged$sumDiffPerc <- with(merged, round((count.y-count.x)/count.x*100, 2))
  
  # Sort and return the results
  arrange(merged, -count.x)
  
}
