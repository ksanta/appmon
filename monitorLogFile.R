## Loads a modified monitor log file:
## 1) Remove all keys so only comma seperated values remain
## 2) Add a header line:  "Start.Time,End.Time,Session.Id,Servlet.Path,User.Id"
monitorLogFile <- function(filename) {
        data <- read.csv(file=filename, header=TRUE, 
                         colClasses=c("character", "character", "character", "factor", "character"))
        
        # convert times
        data$Start.Time <- strptime(data$Start.Time, "%Y-%m-%d %H:%M:%OS")
        data$End.Time <- strptime(data$End.Time, "%Y-%m-%d %H:%M:%OS")
        
        # calculate duration vector
        dateDiffs <- difftime(data$End.Time, data$Start.Time, units = "secs")
        
        # attach Duration to data and set column name
        data <- cbind(data, as.double(dateDiffs))
        names(data)[6] <- "Duration"
        
        # return
        data
}