Usage
========================================================

Pre-requisites
--------------
Download and install R, RStudio.
Download a copy of a few monitor log files.
Use setwd() to set the working directory to where the R files are kept.

Generate graphs
---------------
To generate probability density graphs for each transaction type:
```
compareHistograms(firstFilename, secondFilename)
```
File names strings so they are quoted.
compareHistograms() will create a "histograms" directory if not found and generate a PNG for each transaction type.

Loading monitor log files
-------------------------
To load a monitor log file into memory for adhoc analysis:
```
monitorLogFile(filename)
```

Further work
------------
Would be great to be able to answer these questions:
* What is the SessionId for a sample long running transaction type?
* What does the grade of service look like over time of day for a transaction type?
  * Function takes file, transaction type, GoS percentage
* Can we generate the histogram graphs for particular times in the day?
