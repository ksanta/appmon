Usage
=====

Learning R?
-----------
A great interactive tutorial is SWIRL. It will lead you through data types in R, common functions, etc.

http://www.swirlstats.com

Pre-requisites
--------------
Download and install R, RStudio.
Install required packages.
```
install.packages("data.table")
install.packages("ggplot2")
```

Download a copy of a few monitor log files.
Use setwd() to set the working directory to where the R files are kept.

To make a function available to be run (for example, graphsByTransaction):

* Click on the _files_ tab in the bottom right window pane.
* Click on the file for the function you want to run. It will open in the top left editor window.
* Click on the _source_ button to load it into the environment, seen in the top right window.

Generate histograms
-------------------
Histograms are a great way to compare the transaction duration distribution. It gives much more information than average and standard deviation.
```
histograms(fileVector, startHour, endHour)
```

* fileVector: see section on files for more information on this, with examples
* startHour and endHour are optional.  They are not quoted.  They limit the transactions to just those between those hours.  The hours are given in 24 hour time.  For example: 3pm = 15.
* This script will create a "histograms" directory if not found and generate a PNG for each transaction type.

Generate arrival rate and grade of service graphs
-------------------------------------------------
There are two scripts which will generate graphs.  These two scripts will generate graphs which are split up by either transaction type or user.
```
graphsByTransaction(fileVector, startHour, endHour, quantile, binPeriod, filterByUser)
graphsByUser(fileVector, startHour, endHour, quantile, binPeriod, filterByUser)
```

fileVector
----------
fileVector is a flexible way to define the data series to be used in the graphs.

General rules on the syntax:

* A vector is defined by the c() function, with each element being one data series.
* If there is one data series in the vector, the c() is optional.
* Asterix can be used as a wildcard to match multiple files. This will create one data series from the matched files.

**Examples**

Assume we have the following files:

* monitor-trans-2015-03-10.log
* monitor-batch-2015-03-10.log
* monitor-trans-2015-03-11.log
* monitor-batch-2015-03-11.log

To load data from one file:
```
"monitor-trans-2015-03-10.log"
```

To load data from two files and keep them seperate:
```
c("monitor-trans-2015-03-10.log", "monitor-trans-2015-03-11.log")
```

To load data from two files as one data series:
```
"monitor-*-2015-03-10.log"
```

To load data from multiple files and compare between different days:
```
c("monitor-*-2015-03-10.log", "monitor-*-2015-03-11.log")
```

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

