# Creates a set of graphs, grouped by user
# Given filename can be a regular expression so that it matches multiple files.
# Default grouping of transaction ArrivalRates is a 5 minute interval, though this can be changed with resolution

graphsByUser <- function(file, startHour = 0, endHour = 24, resolution = "5 min", quantile1=0.95, quantile2=0.5, filterByTransaction = NULL, singleChart = FALSE) {
  source("multiMonitorLogFile.R")
  source("commonFunctions.R")
  library(ggplot2)
  library(scales)
  library(reshape2)
  
  print("Please visit https://github.com/ksanta/appmon for latest version of this script")
  
  # Directory where the images will be saved (no trailing slash)
  directory <- "graphsByUser"
  
  # Read in the monitor log file into a data table
  data <- multiMonitorLogFile(file, startHour, endHour)

  # Optionally filter down to one transaction type
  if(!is.null(filterByTransaction)) {
    data <- data[data$Transaction == filterByTransaction]
  }
  
  # Optionally flatten the users
  if(singleChart == TRUE) {
    data$User <- "All Users"
  }

  data <- droplevels(data)
  
  # Ignore the date portion - hardcode all to same value, will be hidden when graphing
  # TODO: there MAY be a problem here with daylight savings time
  data$Start.Time <- as.POSIXct(as.numeric(data$Start.Time) %% 86400, origin = "2000-06-01")
  data$End.Time <- as.POSIXct(as.numeric(data$End.Time) %% 86400, origin = "2000-06-01")
  
  # Create factors which will be used to group each transaction into time intervals
  timeSlots <- cut(data$Start.Time, resolution)
  data[,Time:=timeSlots]
  
  # Require keying of data table for grouping
  setkey(data, Filename, User, Time)
  
  # Group ArrivalRates by Filename, User & TimeSlot
  # Quick refresher on data.table[i, j, by]:
  # i - selects the rows
  # j - calculated columns
  # by - grouping columns
  groupedDataIncomplete <- data[, list(ArrivalRate=length(Duration), quantile1=quantile(Duration, quantile1, na.rm=TRUE), quantile2=quantile(Duration, quantile2, na.rm=TRUE)), by=list(Filename,User,Time)]
  
  # Grouped data does not have values for all time samples, for example some low volume transactions 
  # do not have transactions coming in for every time period.
  
  # To fix, will create a data table with all combinations of keys, then merge with groupedData
  allCombinations <- expand.grid(Filename=unique(groupedDataIncomplete$Filename), User=unique(groupedDataIncomplete$User), Time=levels(groupedDataIncomplete$Time))
  allCombinationsTable <- data.table(allCombinations)
  groupedData <- merge(groupedDataIncomplete, allCombinationsTable, all=TRUE)
  
  # Set NA values to zero so they plot as a zero
  groupedData$ArrivalRate[is.na(groupedData$ArrivalRate)] <- 0
  groupedData$quantile1[is.na(groupedData$quantile1)] <- 0
  groupedData$quantile2[is.na(groupedData$quantile2)] <- 0

  # Convert the x-axis data series from factors to time, so they plot much better.
  groupedData[,Time:=as.POSIXct(as.character(Time))]
  
  # Delete all existing graphs if they exist
  createOrEmptyDirectory(directory)
  
  # Melt data for easier faceting when graphing
  meltedData <- melt(groupedData, measure.vars = c("ArrivalRate", "quantile1", "quantile2"))

  # Rename variable names so they are easier to understand
  meltedData[variable == "quantile1"]$variable <- paste(quantile1, "Quantile")
  meltedData[variable == "quantile2"]$variable <- paste(quantile2, "Quantile")
  
  users <- levels(meltedData$User)
  
  for(index in seq_along(users)) {
    # Subsetting
    user <- users[index]
    graphData <- meltedData[User == user]
    
    print(paste(index, "=", user))
    
    # Plotting
    ggp <- ggplot(data=graphData, mapping=aes(x=Time, y=value, colour=Filename))
    
    facets <- facet_grid(variable ~ ., scales="free")
    
    title <- user
    subtitle <- paste0("Resolution: ", resolution)
    if(!is.null(filterByTransaction)) {
      subtitle <- paste0(subtitle, ", Transaction: ", filterByTransaction)
    }
    titleExpression <- bquote(atop(.(title), italic(.(subtitle))))
    labels <- labs(title=titleExpression, y="", x="Time")
    
    theme <- theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1), 
                   plot.title = element_text(size = rel(0.75)), legend.position="bottom",
                   legend.direction="vertical")
    
    timescale <- scale_x_datetime(breaks=date_breaks("1 hour"), minor_breaks=date_breaks("10 min"), labels=date_format("%H:%M", Sys.timezone()))
    
    plot <- ggp + facets + geom_line(alpha=0.5) + labels + theme + expand_limits(y = 0) + timescale
    
    #print(plot)
    
    ggsave(plot=plot, filename=paste0(directory, "/", index, ".png"))
  }
}
