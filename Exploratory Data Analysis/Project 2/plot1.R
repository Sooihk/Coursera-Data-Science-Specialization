source("PMZIPfile")

NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

#sum emissions per year
emissions_per_year <- aggregate(Emissions ~ year, NEI, FUN=sum)
png("plot1.png")
barplot(emissions_per_year$Emissions/1000, names.arg=emissions_per_year$year, xlab="Year", 
        ylab=expression('PM'[2.5]*' in Kilotons'), main=expression('Annual PM'[2.5]*' Emission from 1999 to 2008'),
        col=as.factor(emissions_per_year$year))
dev.off()
