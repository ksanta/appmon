# Creates a set of graphs, grouped by user
# Given filename can be a regular expression so that it matches multiple files.
# Default grouping of transaction counts is a 5 minute interval, though this can be changed with binPeriod

graphsByUser <- function(file, startHour = 0, endHour = 24, quantile=0.95, binPeriod = "5 min", combineFiles = FALSE, filterByTransaction = NULL) {
  source("multiMonitorLogFile.R")
  source("commonFunctions.R")
  library(ggplot2)
  library(scales)
  library(reshape2)
  
  # Directory where the images will be saved (no trailing slash)
  directory <- "graphsByUser"
  
  # Read in the monitor log file into a data table
  data <- multiMonitorLogFile(file, startHour, endHour, combineFiles)

  # Optionally filter down to one transaction type
  if(!is.null(filterByTransaction)) {
    data <- data[data$Transaction == filterByTransaction]
    data <- droplevels(data)
  }
  
  # Ignore the date portion - hardcode all to same value, will be hidden when graphing
  tempTimes <- as.POSIXlt(data$Start.Time)
  tempTimes$year <- 100
  tempTimes$mon <- 0
  tempTimes$mday <- 1
  data$Start.Time <- as.POSIXct(tempTimes)
  
  tempTimes <- as.POSIXlt(data$End.Time)
  tempTimes$year <- 100
  tempTimes$mon <- 0
  tempTimes$mday <- 1
  data$End.Time <- as.POSIXct(tempTimes)
  
  # Create a time sequence to group all transactions by start time
  minStartTime <- min(data[,Start.Time])
  maxStartTime <- max(data[,Start.Time])
  timeBreaks <- seq.POSIXt(from=minStartTime, to=maxStartTime, by=binPeriod)
  
  # Create a vector of factors which will be used to "bin" each transaction
  timeSlots <- cut(data$Start.Time, timeBreaks)
  
  # Attach the grouping factors to the data table
  data[,Time:=timeSlots]
  
  # Require keying of data table for grouping
  setkey(data, Filename, User, Time)
  
  # Group counts by Filename, User & TimeSlot
  # Quick refresher on data.table[i, j, by]:
  # i - selects the rows
  # j - calculated columns
  # by - grouping columns
  groupedDataIncomplete <- data[, list(Count=length(Duration), GoS=quantile(Duration, quantile, na.rm=TRUE), Median=as.double(median(Duration, na.rm=TRUE))), by=list(Filename,User,Time)]
  
  # Grouped data does not have values for all time samples, for example some low volume transactions 
  # do not have transactions coming in for every time period.
  
  # To fix, will create a data table with all combinations of keys, then merge with groupedData
  allCombinations <- expand.grid(Filename=unique(groupedDataIncomplete$Filename), User=unique(groupedDataIncomplete$User), Time=as.factor(timeBreaks))
  allCombinationsTable <- data.table(allCombinations)
  groupedData <- merge(groupedDataIncomplete, allCombinationsTable, all=TRUE)
  
  # Set NA values to zero so they plot as a zero
  groupedData$Count[is.na(groupedData$Count)] <- 0
  groupedData$GoS[is.na(groupedData$GoS)] <- 0
  groupedData$Median[is.na(groupedData$Median)] <- 0

  # Convert the x-axis data series from factors to time, so they plot much better.
  groupedData[,Time:=as.POSIXct(as.character(Time))]
  
  # Delete all existing graphs if they exist
  createOrEmptyDirectory(directory)
  
  users <- levels(groupedData$User)
  
  for(index in seq_along(users)) {
    user <- users[index]
    print(paste(index, "=", user))
    
    # Subset only for the user
    graphData <- groupedData[User == user]
    
    # Exclude data sets which don't have a minimum number of time samples
    # This is a preference, not a technical limitation.  Otherwise can generate lots of empty graphs.
    if(nrow(graphData) < 5) {
      print("Skipping this one because there are not enough time samples to plot")
      next
    }
    
    # Melt the Count and GoS columns into variables for easier graphing
    meltedData <- melt(graphData, measure.vars = c("Count", "GoS", "Median"))
    
    ggp <- ggplot(data=meltedData, mapping=aes(x=Time, y=value, colour=Filename))
    
    # Plot multiple graphs per image
    facets <- facet_grid(variable ~ ., scales="free")
    
    labels <- labs(title=user, y="", x="Time")
    
    theme <- theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
                   plot.title = element_text(size = rel(0.75)), legend.position="bottom",
                   legend.direction="vertical")
    
    timescale <- scale_x_datetime(breaks=date_breaks("1 hour"), minor_breaks=date_breaks("10 min"), labels=date_format("%H:%M"))
    
    plot <- ggp + facets + geom_line() + labels + theme + expand_limits(y = 0) + timescale
    
    ggsave(plot=plot, filename=paste0(directory, "/", index, ".png"))
  }
}