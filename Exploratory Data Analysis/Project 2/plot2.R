source("PMZIPfile.R")

NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

library("dplyr")

#Filter out Balitmore City Emissions 
Baltimore_emissions <- NEI %>% filter(fips=="24510") %>% group_by(year) %>% summarise(Emissions=sum(Emissions))
png("plot2.png")
barplot(Baltimore_emissions$Emissions/1000, names.arg=Baltimore_emissions$year, xlab="Year",
        ylab=expression('PM'[2.5]*' in Kiltotons'), main=expression('Annual Emissions of PM'[2.5]*' from 1999 to 2008'),
        col=as.factor(Baltimore_emissions$year))
dev.off()
