## Loads a monitor log file.  Attempts to load a .processed file first, to speed things up
monitorLogFile <- function(filename, startHour = 0, endHour = 24) {
  library(data.table)
  
  # End hour must be higher than start hour - easy mistake to NOT use 24hr time!
  if(endHour <= startHour) {
    stop("The end hour must be larger than the start hour.  Did you forget to use 24hr time?")
  }
  
  # Check if processed file already exists and try loading that - for speed
  processedFileName <- paste(filename, ".processed", sep="")
  if(file.exists(processedFileName)) {
    print(paste("Loading processed file:", filename))
    
    data <- read.csv(file=processedFileName, header=TRUE, 
                     colClasses=c("POSIXct", "POSIXct", "character", "factor", "factor", "numeric", "factor"))
    
    data <- subset(data, hour(Start.Time) >= startHour & hour(Start.Time) < endHour)
    
    # Easier to work with data.tables downstream
    DT <- data.table(data)
    setkey(DT, Transaction)
    
    return(DT)
  }
  
  print(paste("Reading and processing file:", filename))
  data <- read.csv(file=filename, header=FALSE, stringsAsFactors=FALSE, fill=TRUE,
                   colClasses=c("character","character","character","character","character","character"))
  
  numberOfRecords <- nrow(data)
  startTime <- character(numberOfRecords)
  endTime <- character(numberOfRecords)
  sessionId <- character(numberOfRecords)
  transaction <- character(numberOfRecords)
  user <- character(numberOfRecords)
  
  # This function will identify the key and set the value in the correct vector
  collectValues = function(element, lineIndex) {
    key <- element[1]
    value <- element[2]
    if(is.na(key)) {
      # skip if missing value
    } else if(key == "Start Time") {
      startTime[lineIndex] <<- value
    } else if(key == "End Time") {
      endTime[lineIndex] <<- value
    } else if(key == "Session Id") {
      sessionId[lineIndex] <<- value
    } else if(key == "Servlet Path") {
      transaction[lineIndex] <<- value
    } else if(key == "User Id") {
      user[lineIndex] <<- value
    }
  }
  
  for(lineIndex in 1:numberOfRecords) {
    # This is the most efficient way I could find to read a line from the data frame
    line <- c(data[lineIndex,1], data[lineIndex,2], data[lineIndex,3],
              data[lineIndex,4], data[lineIndex,5], data[lineIndex,6])
    
    # split returns a LIST of key/value paired VECTORS
    keyValuePairList <- strsplit(line, "=")
    
    lapply(keyValuePairList, collectValues, lineIndex)
  }
  
  # convert times to time types
  startTime <- strptime(startTime, "%Y-%m-%d %H:%M:%OS")
  endTime <- strptime(endTime, "%Y-%m-%d %H:%M:%OS")
  
  # calculate duration in milliseconds
  dateDiffs <- difftime(endTime, startTime, units = "secs")
  durationsAsSeconds <- as.double(dateDiffs)
  durationsAsMillis <- as.integer(durationsAsSeconds * 1000)
  
  # convert Transaction and User to factors
  transaction <- as.factor(transaction)
  user <- as.factor(user)
  
  result <- data.frame(Start.Time=startTime, End.Time=endTime,Session.Id=sessionId,Transaction=transaction,
                       User=user, Duration=durationsAsMillis, stringsAsFactors=FALSE)
  
  # Tried and failed to create data.table directly. Don't know why it fails??
  result <- data.table(result)
  setkey(result, Transaction)

  # Add filename column. Create as factor for easier grouping later on.
  result[,Filename:=as.factor(filename)]
    
  # Write to file so it's quicker to load next time
  print("Saving processed file for faster loading next time")
  write.csv(result, file = processedFileName, row.names = FALSE)

  # Filter by hour and return
  subset(result, hour(Start.Time) >= startHour & hour(Start.Time) < endHour)
}
