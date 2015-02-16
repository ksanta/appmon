# Loads 2 sets of monitor log files and compares the histograms for each transaction type
compareHistograms <- function(file1, file2, startHour = 0, endHour = 24, percentile = 95) {
  source("multiMonitorLogFile.R")
  source("commonFunctions.R")
  library(ggplot2)
  
  # Read in the 2 sets of monitor log files
  data1 <- multiMonitorLogFile(file1, startHour, endHour, combineFiles = TRUE)
  data2 <- multiMonitorLogFile(file2, startHour, endHour, combineFiles = TRUE)
  
  # Combine two data tables into one
  data <- rbind(data1, data2)
  setkey(x=data, Transaction)
  
  # Delete all existing graphs if they exist
  createOrEmptyDirectory("histograms")
  
  # Make sure to filter out transaction types which might have no counts as part of time filtering
  transactionCounts <- summary(data1$Transaction)
  transactionTypes <- names(transactionCounts[transactionCounts > 0])
  
  for(index in seq_along(transactionTypes)) {
    transactionType <- transactionTypes[index]
    
    print(paste(index, "=", transactionType))

    median1 <- quantile(data[Filename==file1 & Transaction==transactionType]$Duration, probs = percentile/100)
    median2 <- quantile(data[Filename==file2 & Transaction==transactionType]$Duration, probs = percentile/100)
    
    # Build up the graph
    ggp <- ggplot(data=data[transactionType], mapping=aes(x=Duration, fill=Filename))
    histogram <- geom_histogram(alpha=0.5, binwidth=0.05, position="identity")
    labels <- labs(title=transactionType, y="Count", x="Duration (milliseconds)")
    theme <- theme(legend.position="bottom", legend.direction="vertical", plot.title = element_text(size = rel(0.5)))
    vline.data <- data.frame(xint=c(median1, median2), grp=letters[1:2])
    median.lines <- geom_vline(data=vline.data, mapping=aes(xintercept = xint,colour = grp), size=2)
    
    plot <- ggp + histogram + scale_x_log10() + labels + theme + median.lines + annotation_logticks(sides = "b")
    
    ggsave(plot=plot, filename=paste0("histograms/", index, ".png"))
  }
}
