## Loads a monitor log file
monitorLogFile <- function(filename) {
        print("Reading file")
        data <- read.csv(file=filename, header=FALSE, stringsAsFactors=FALSE)
        
        numberOfRecords <- nrow(data)
        startTime <- character(numberOfRecords)
        endTime <- character(numberOfRecords)
        sessionId <- character(numberOfRecords)
        transaction <- character(numberOfRecords)
        user <- character(numberOfRecords)
        
        collectValues = function(element) {
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
        
        print("Processing")
        
        for(lineIndex in 1:numberOfRecords) {
                # This is the most efficient way I could find to read a line from the data frame
                line <- c(data[lineIndex,1], data[lineIndex,2], data[lineIndex,3],
                                data[lineIndex,4], data[lineIndex,5], data[lineIndex,6])
                
                # split returns a LIST of key/value paired VECTORS
                keyValuePairList <- strsplit(line, "=")
                
                lapply(keyValuePairList, collectValues)
        }

        print("Converting")
        
        # convert times to time types
        startTime <- strptime(startTime, "%Y-%m-%d %H:%M:%OS")
        endTime <- strptime(endTime, "%Y-%m-%d %H:%M:%OS")
        
        # calculate duration vector
        dateDiffs <- difftime(endTime, startTime, units = "secs")
        dateDiffs <- as.double(dateDiffs)
        
        # convert Transaction and User to factors
        transaction <- as.factor(transaction)
        user <- as.factor(user)
        
        print("Building data frame")
        
        result <- data.frame(Start.Time=startTime, End.Time=endTime,Session.Id=sessionId,Transaction=transaction,
                             User=user, Duration=dateDiffs, stringsAsFactors=FALSE)

        # return
        result
}