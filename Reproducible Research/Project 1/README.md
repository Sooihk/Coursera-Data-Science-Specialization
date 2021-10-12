
## Introduction

It is now possible to collect a large amount of data about personal
movement using activity monitoring devices such as a
[Fitbit](http://www.fitbit.com), [Nike
Fuelband](http://www.nike.com/us/en_us/c/nikeplus-fuelband), or
[Jawbone Up](https://jawbone.com/up). These type of devices are part of
the "quantified self" movement -- a group of enthusiasts who take
measurements about themselves regularly to improve their health, to
find patterns in their behavior, or because they are tech geeks. But
these data remain under-utilized both because the raw data are hard to
obtain and there is a lack of statistical methods and software for
processing and interpreting the data.

This assignment makes use of data from a personal activity monitoring
device. This device collects data at 5 minute intervals through out the
day. The data consists of two months of data from an anonymous
individual collected during the months of October and November, 2012
and include the number of steps taken in 5 minute intervals each day.

## Data

The data for this assignment can be downloaded from the course web
site:

* Dataset: [Activity monitoring data](https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip) [52K]

The variables included in this dataset are:

* **steps**: Number of steps taking in a 5-minute interval (missing
    values are coded as `NA`)

* **date**: The date on which the measurement was taken in YYYY-MM-DD
    format

* **interval**: Identifier for the 5-minute interval in which
    measurement was taken




The dataset is stored in a comma-separated-value (CSV) file and there
are a total of 17,568 observations in this
dataset.


## Assignment

This assignment will be described in multiple parts. You will need to
write a report that answers the questions detailed below. Ultimately,
you will need to complete the entire assignment in a **single R
markdown** document that can be processed by **knitr** and be
transformed into an HTML file.

Throughout your report make sure you always include the code that you
used to generate the output you present. When writing code chunks in
the R markdown document, always use `echo = TRUE` so that someone else
will be able to read the code. **This assignment will be evaluated via
peer assessment so it is essential that your peer evaluators be able
to review the code for your analysis**.

For the plotting aspects of this assignment, feel free to use any
plotting system in R (i.e., base, lattice, ggplot2)

Fork/clone the [GitHub repository created for this
assignment](http://github.com/rdpeng/RepData_PeerAssessment1). You
will submit this assignment by pushing your completed files into your
forked repository on GitHub. The assignment submission will consist of
the URL to your GitHub repository and the SHA-1 commit ID for your
repository state.

NOTE: The GitHub repository also contains the dataset for the
assignment so you do not have to download the data separately.



### Loading and preprocessing the data

Show any code that is needed to

1. Load the data (i.e. `read.csv()`)

2. Process/transform the data (if necessary) into a format suitable for your analysis

```{r importData}
library("ggplot2")
library("dplyr")
library(lubridate)
#set directory
setwd("C:/Users/aduro/Desktop/Coding/Data Science Coursera/Data Science Specialization/5 Reproducible Research/Module 2/")
activityFile <- "repdata_data_activity"
#if zip file does not exist, download from web
if(!file.exists(activityFile)) {
    download_url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2Factivity.zip"
    download.file(download_url, destfile = activityFile)
}
#if csv file not exist, unzip
if(!file.exists("activity")) {
    unzip(activityFile)
}
activity <- read.csv("activity.csv")
activity$date<-ymd(activity$date)
```


### What is mean total number of steps taken per day?  
For this part of the assignment, you can ignore the missing values in the dataset.

1. Calculate the total number of steps taken per day  

```{r totalSteps}
stepsPerDay <- activity %>% group_by(date) %>% summarise(steps=sum(steps))
colnames(stepsPerDay) <- c("Date", "Steps")
stepsPerDay
```

2. If you do not understand the difference between a histogram and a barplot, research the difference between them. Make a histogram of the total number of steps taken each day  

```{r barplot}
ggplot(stepsPerDay, aes(x=Date, y=Steps)) + geom_bar(stat="identity", fill="steelblue") +
    labs(x="Date", y="Steps", title="Number of steps taken each day") + theme_bw() 
```
![plot1.png](./plot1.png)

```{r histogram}
ggplot(stepsPerDay, aes(Steps)) + geom_histogram(binwidth=2000, fill = "steelblue", alpha=0.7) + labs(x="Total Steps", y="Frequency", title = "Historgram of total steps per day") + theme(plot.title = element_text(hjust = 0.5), axis.title.x = element_text(face="bold"), axis.title.y = element_text(face = "bold"))
```
![plot2.png](./plot2.png)

3. Calculate and report the mean and median of the total number of steps taken per day  


```{r medianMean}
meanSteps <- activity %>% group_by(date) %>% summarise(steps=mean(steps))
colnames(meanSteps) <- c("Date", "Mean Steps")
meanSteps
medianSteps <- activity %>% group_by(date) %>% summarise(steps=median(unique(steps)))
colnames(medianSteps) <- c("Date", "Median Steps")
medianSteps
```

### What is the average daily activity pattern?  

1. Make a time series plot (i.e. type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all days (y-axis)  

```{r averagePattern}
interval_average_steps <- aggregate(steps~interval, activity, FUN = mean, na.action = na.omit)
interval_average_steps$time <- interval_average_steps$interval/100
ggplot(interval_average_steps, aes(time, steps)) + geom_line(colour="steelblue", size = 1) +  labs(x = "Time", y = "Average number of steps", title = "Average steps per time") + theme(plot.title = element_text(face="bold", hjust = 0.5), axis.title.x = element_text(face = "bold"), axis.text.y = element_text(face = "bold"))
```
![plot3.png](./plot3.png)

2. Which 5-minute interval, on average across all the days in the dataset, contains the maximum number of steps?  

``` {r maxInterval}
maxInterval <- interval_average_steps %>% select(interval, steps) %>% filter(steps == max(steps))
maxInterval
```

### Imputing missing values  
Note that there are a number of days/intervals where there are missing values (coded as NA). The presence of missing days may introduce bias into some calculations or summaries of the data.   

1. Calculate and report the total number of missing values in the dataset (i.e. the total number of rows with NAs)  

```{r missing}
countMissing <- activity %>% filter(is.na(steps)) %>% summarise(total_missing_steps = n())
countMissing
```

2. Devise a strategy for filling in all of the missing values in the dataset. The strategy does not need to be sophisticated. For example, you could use the mean/median for that day, or the mean for that 5-minute interval, etc.  

3. Create a new dataset that is equal to the original dataset but with the missing data filled in.  

Chose to replace missing step values with the average step value for that interval.  

```{r fillMissing}
# fill mean for that missing interval step value
fill_in_missing <- activity %>% mutate(steps = ifelse(is.na(activity$steps), round(interval_average_steps$steps[match(activity$interval, interval_average_steps$interval)],0), activity$steps))
```

4. Make a histogram of the total number of steps taken each day and Calculate and report the mean and median total number of steps taken per day. Do these values differ from the estimates from the first part of the assignment? What is the impact of imputing missing data on the estimates of the total daily number of steps?

- Imputing missing data has little impact on the median and mean number daily number of steps. The main difference between the datasets are their histograms in the total steps between 9,000 and 12,000 where the frequency jumped from 12 to 20.   

``` {r histogramtotalSteps}
new_steps_day <- fill_in_missing %>% group_by(date) %>% summarise(steps=sum(steps))
colnames(new_steps_day) <- c("Date", "TotalSteps")
ggplot(new_steps_day, aes(TotalSteps)) + geom_histogram(binwidth=2000, fill = "steelblue", alpha=0.7) + labs(x="Total Steps", y="Frequency", title = "Historgram of total steps per day") + theme(plot.title = element_text(hjust = 0.5), axis.title.x = element_text(face="bold"), axis.title.y = element_text(face = "bold"))
```
![plot4.png](./plot4.png)

``` {r newmeanMedian}
#obtain mean for each day
meanSteps2 <- fill_in_missing %>% group_by(date) %>% summarise(steps=mean(steps))
colnames(meanSteps2) <- c("Date", "Mean Steps")
meanSteps2
#obtain median for each day
medianSteps2 <- fill_in_missing %>% group_by(date) %>% summarise(steps=median(unique(steps)))
colnames(medianSteps2) <- c("Date", "Median Steps")
medianSteps2
```

### Are there differences in activity patterns between weekdays and weekends?
For this part the weekdays()function may be of some help here. Use the dataset with the filled-in missing values for this part.

1. Create a new factor variable in the dataset with two levels – “weekday” and “weekend” indicating whether a given date is a weekday or weekend day.  

```{r weekdaysWeekend}
#make date column in correct format
fill_in_missing$date <- as.Date(fill_in_missing$date, format="%Y/%m/%d")
#create new variable stating day of the week for each row
fill_in_missing$weekday <- weekdays(fill_in_missing$date)
#group each row being in either a weekday or weekend type
fill_in_missing$dayType <- ifelse(fill_in_missing$weekday == "Saturday" | fill_in_missing$weekday == "Sunday", "weekend", "weekday")
```


2. Make a panel plot containing a time series plot (type = "l") of the 5-minute interval (x-axis) and the average number of steps taken, averaged across all weekday days or weekend days (y-axis). See the README file in the GitHub repository to see an example of what this plot should look like using simulated data.

```{r weekdayweekendPlot}
#create table
weekDT <- aggregate(steps ~ interval + dayType, data=fill_in_missing, FUN=mean, na.action = na.omit)
weekDT$hour <- weekDT$interval/100
ggplot(weekDT, aes(hour, steps)) + geom_line(col="steelblue", size = 0.8) + labs(x = "Hour of day", y = "Steps", title = "Average number of steps per interval: Weekday vs Weekend") + facet_grid(dayType ~ .) + theme(plot.title = element_text(hjust = 0.5), axis.title.x = element_text(face="bold"), axis.title.y = element_text(face="bold")) 
```

![plot5.png](./plot5.png)
