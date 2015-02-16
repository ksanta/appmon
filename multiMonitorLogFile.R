# Load multiple monitor log files, based on a filename as a regular expression.

# fileVector is a vector of strings.  Each element may contain wildcards, and multiple matches within 
# each element will be combined.

# combineFiles, if TRUE, will combine all elements in the vector as if it came from one file.

# Eg: c("monitor-*-2014-09-23.log")
# Combines all monitor log files for a day into one dataset

# Eg: c("monitor-online-*-2014-09-23.log")
# Combines online monitor log files for a day

# Eg: c("monitor-online-m1-2015-02-16.log", "monitor-online-m2-2015-02-16.log")
# Loads m1 and m2 into a dataset and keeps datasets seperate

multiMonitorLogFile <- function (fileVector, startHour = 0, endHour = 24, combineFiles = FALSE) {
  source("monitorLogFile.R")

  allMonitorLogFile <- NULL
  
  for(fileExpression in fileVector) {
    # Use Sys.glob to get get a list of matched files on Windows platforms, as Windows doesn't do
    # pattern matching well when listing files
    matchedFiles <- Sys.glob(fileExpression)
    
    # Stop when no files are matched
    if(length(matchedFiles) == 0) {
      stop(paste0("No files matched using '",fileExpression,"'"))
    }
    
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
    
    # Flatten data for each fileExpression
    multiMonitorLogFile$Filename <- fileExpression
    multiMonitorLogFile <- droplevels(multiMonitorLogFile)
    
    # Attach file element to allMonitorLogFile
    if(is.null(allMonitorLogFile)) {
      allMonitorLogFile <- multiMonitorLogFile
    } else {
      allMonitorLogFile <- rbind(allMonitorLogFile, multiMonitorLogFile)
    }
  }
  
  # Flatten the filenames if user wants to aggregate everything into one dataset
  if(combineFiles == TRUE) {
    combinedFilename <- paste(fileVector, collapse = ", ")
    allMonitorLogFile$Filename <- combinedFilename
    allMonitorLogFile <- droplevels(allMonitorLogFile)
  }
  
  # Return
  allMonitorLogFile
}
