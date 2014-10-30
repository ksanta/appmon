

extractCountsToFile <- function(filename, startHour = 0, endHour = 24) {
  source("multiMonitorLogFile.R")
  library(plyr)
  
  # Read the monitor log file
  data <- multiMonitorLogFile(filename, startHour, endHour)
  
  # Extract the counts
  summary.data <- data[,length(Duration),Transaction]
  
  # Sort by counts descending
  summary.data <- arrange(summary.data, -V1)
  
  # Save for easy import into Excel using Data -> From Text
  write.table(summary.data, paste0(filename, "-counts.csv"))
}
