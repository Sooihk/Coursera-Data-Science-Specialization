source("PMZIPfile.R")

NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")


library("dplyr")
library("ggplot2")
#Question #6: Compare emissions from motor vehicle sources in Baltimore City with emissions from motor vehicle sources
#in Los Angeles County, California ( == “”). Which city has seen greater changes over time in motor vehicle emissions?
                     
#Obtain SCC motor vehicle codes from SCC db
vehicle_SCC <- SCC[grep("vehicle", SCC$Short.Name, ignore.case=TRUE), "SCC"]
#Filter out NEI motor vehicle
vehicle_emission <- NEI %>% filter(SCC %in% vehicle_SCC & fips %in% c("24510", "06037")) %>% group_by(fips, year) %>%
  summarise(Emissions=sum(Emissions)) 

#insert new variable (county) into database
vehicle_emission$county <- "Baltimore City"
vehicle_emission[grep("06037", vehicle_emission$fips),]$county <- "Los Angeles"

png("plot6.png")
county_plot <- ggplot(vehicle_emission, aes(x=factor(year), y=Emissions/1000, fill=year)) + geom_bar(stat="identity") +
  facet_grid(.~county) + labs(x="Year", y=expression('PM'[2.5]*' Emissions in Kiloton', title="Los Angeles vs Baltimore
  Vehicle Emissions")) + theme_bw() + theme(legend.position="none")
print(county_plot)
dev.off()
