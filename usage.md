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

Generate graphs
---------------
To generate probability density graphs for each transaction type:
```
compareHistograms(firstFilename, secondFilename, startHour, endHour)
```
* File names strings so they are quoted.
* startHour and endHour are optional.  They should not be quoted.  They limit the transactions to just those between those hours.  The hours are given in 24 hour time.  For example: 15 = 3pm.
* compareHistograms() will create a "histograms" directory if not found and generate a PNG for each transaction type.

Compare volumes
---------------
To quickly compare the volumes between 2 monitor log files at the transaction level:
```
compareVolumes(firstFilename, secondFilename, startHour, endHour)
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
Would be great to be able to answer these questions:
* What is the SessionId for a sample long running transaction type?
* What does the grade of service look like over time of day for a transaction type?
  * Function takes file, transaction type, GoS percentage
* Can we plot transaction volumes over time with one line per transaction type?

Bugs:
* Legend is wrong in the compareHistogram() graphs
