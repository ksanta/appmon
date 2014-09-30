# Load multiple monitor log files, based on a filename as a regular expression.
# A single data.frame is returned with an additional column containing the filename the data was loaded from.
# The additional column with filename is of type "factor"

# Eg: to find all files for a day: "monitor-*-2014-09-23.log"
# Eg: to find online logs for a day: "monitor-online-*-2014-09-23.log"

multiMonitorLogFile <- function (fileRegExp, startHour = 0, endHour = 24) {
  source("monitorLogFile.R")

  # Use Sys.glob to get get a list of matched files on Windows platforms, as Windows doesn't do
  # pattern matching well when listing files
  matchedFiles <- Sys.glob(fileRegExp)

  print(paste("Matched:", matchedFiles))
  
  multiMonitorLogFile <- NULL

  for(matchedFile in matchedFiles) {
    newMonitorLogFile <- monitorLogFile(matchedFile, startHour, endHour)
    
    if(is.null(multiMonitorLogFile)) {
      multiMonitorLogFile <- newMonitorLogFile
    } else {
      multiMonitorLogFile <- rbind(multiMonitorLogFile, newMonitorLogFile)
    }
  }
  
  # Return
  multiMonitorLogFile
}