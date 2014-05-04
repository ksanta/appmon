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
        
        print("Processing file")
        
        for(lineIndex in seq_along(data[,1])) {
                # line is of type data.frame
                line <- data[lineIndex,]
                
                # transpose and convert line to a vector, ready for splitting
                lineVector <- as.vector(t(line))
                
                # split each element in lineVector
                keyValuePairList <- strsplit(lineVector, "=")
                
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
                
                lapply(keyValuePairList, collectValues)
        }

        # convert times to time types
        startTime <- strptime(startTime, "%Y-%m-%d %H:%M:%OS")
        endTime <- strptime(endTime, "%Y-%m-%d %H:%M:%OS")
        
        # calculate duration vector
        dateDiffs <- difftime(endTime, startTime, units = "secs")
        dateDiffs <- as.double(dateDiffs)
        
        # convert Transaction and User to factors
        transaction <- as.factor(transaction)
        user <- as.factor(user)
        
        result <- data.frame(Start.Time=startTime, End.Time=endTime,Session.Id=sessionId,Transaction=transaction,
                             User=user, Duration=dateDiffs, stringsAsFactors=FALSE)

        # return
        result
}