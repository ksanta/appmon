# Loads and graphs a queue depth log file

queueDepths <- function(file) {
  library(ggplot2)
  library(reshape2)
  
  # Read in data from file
  data <- read.csv(file, header = TRUE)
  
  # Convert time column to time type
  data$TIME <- as.POSIXct(as.character(data$TIME))
  
  # Melt the data so columns become new rows
  longData <- melt(data=data, id.vars="TIME")
  
  # Plot
  plot <- ggplot(data=longData, aes(x=TIME, y=value, colour=variable)) + geom_line()
  
  ggsave(plot=plot, filename="queueDepths.png")
}
