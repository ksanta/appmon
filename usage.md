Usage
=====

Pre-requisites
--------------
Download and install R, RStudio.
Install some required packages.
```
install.packages("data.table")
install.packages("ggplot2")
```

Download a copy of a few monitor log files.
Use setwd() to set the working directory to where the R files are kept.

To make a function available to be run (for example, compareHistograms):
* Click on the _files_ tab in the bottom right window pane.
* Click on the file for the function you want to run. It will open in the top left editor window.
* Click on the _source_ button to load it into the environment, seen in the top right window.

Compare transaction duration histograms
---------------------------------------
This script generates graphs with duration along the bottom and counts going up. The graphs compare two transaction duration histograms, so you can see whether a particular transaction is running slower and how.
The script generates one graph per transaction type into a "histograms" folder.
```
compareHistograms(firstFilename, secondFilename, startHour = 0, endHour = 24, percentile)
```
* *firstFilename*: Mandatory. A regular expression matching a set of monitor log files to be used as a baseline. Quoted string.
* *secondFilename*: Mandatory. A regular expression matching a set of monitor log files to be used as a comparison. Quoted string.
* *startHour*: Optional. Hour of the earliest transaction in 24 hour time. Example: 15 = 3pm.
* *endHour*: Optional. Hour of the latest transaction in 24 hour time.
* *percentile*: The histograms contains a vertical line for the specified grade of service percentile. Optional, defaults to 0.95.

See how transaction arrival rate affects grade of service
---------------------------------------------------------
This script generates graphs showing the incoming arrival rate and grade of service on the same timeline.  So as the arrival rate changes through the day, you can see the impact on the grade of service also.
Grade of service is the time at which 95% (for example) percentage of transactions finish.
```
multiOverTime(file, startHour = 0, endHour = 24, quantile=0.95, binPeriod = "5 min", combineFiles = FALSE))
```
* *file*: Mandatory. A regular expression for a set of monitor log files.
* *startHour*: Optional. Hour of the earliest transaction in 24 hour time. Example: 15 = 3pm.
* *endHour*: Optional. Hour of the latest transaction in 24 hour time.
* *quantile*: The quantile to use for the grade of service.
* *combineFiles*: If TRUE, multiple monitor log files which were matched will be treated as if they were one big file.

Compare volumes
---------------
To quickly compare the volumes between 2 monitor log files at the transaction level:
```
compareVolumes(firstFilename, secondFilename, startHour = 0, endHour = 24)
```
* File names strings so they are quoted.
* startHour and endHour are optional.  They should not be quoted.  They limit the transactions to just those between those hours.  The hours are given in 24 hour time.  For example: 15 = 3pm.
* The output will be given in the console window ranked by descending transaction counts.

Loading monitor log files
-------------------------
To load a monitor log file into memory for adhoc analysis:
```
x <- monitorLogFile(filename)
```
You're on your own for the analysis.

Further work
------------
* Set the endpoint times on multiOverTime so that it matches the filter passed in, rather than automatically scaling to fit the available data.

