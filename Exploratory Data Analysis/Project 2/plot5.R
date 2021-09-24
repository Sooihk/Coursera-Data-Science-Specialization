source("PMZIPfile.R")

NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

library("dplyr")
library("ggplot2")
#Question #5: How have emissions from motor vehicle sources changed from 1999 to 2008 in Baltimore City?

#Filter out SCC numbers containing motor vehicle description in short.name
motor_vehicle_SCC <- SCC[grep("vehicle", SCC$Short.Name,ignore.case=TRUE), "SCC"]
#Filter out motor vehicles emissions from NEI using SCC numbers obtained from SCC db
motor_vehicle_NEI <- NEI %>% filter(SCC %in% motor_vehicle_SCC & fips == "24510") %>% group_by(year) %>%
  summarise(Emissions=sum(Emissions))

png("plot5.png")
#ggplot bar plots of emissions per year of Baltimore City
vehicle_plot <- ggplot(motor_vehicle_NEI, aes(x=factor(year), y=Emissions/1000, fill=year)) + geom_bar(stat="identity") +
  labs(x="Year", y=expression('PM'[2.5]*' Emissions in Kilotons'), title="Motor Vehicle Emissions in Baltimore City from 1999 to 2008") +
  theme_bw() + theme(legend.position = "none")
print(vehicle_plot)
dev.off()
