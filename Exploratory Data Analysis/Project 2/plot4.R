source("PMZIPfile.R")

NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

library("dplyr")
library("ggplot2")
#Question #4: Across the United States, how have emissions from coal combustion-related sources changed from 1999 
#to 2008? filter out SCC numbers containing coal in their short.name 
coal_SCC <- SCC[grep("coal", SCC$Short.Name, ignore.case=TRUE), "SCC"]
#Using SCC numbers matching coal, subset NEI SCC numbers matching coal_SCC SCC numbers
coal_nEI <- NEI %>% filter(SCC %in% coal_SCC) %>% group_by(year) %>% summarise(Emissions=sum(Emissions)) 

png("plot4.png")
#ggplot coal emissions
coal_plot <- ggplot(coal_nEI, aes(x=factor(year), y=Emissions/1000, fill=year)) + geom_bar(stat="identity") +
  labs(x="Year", y=expression('PM'[2.5]*' Emissions in Kilotons'), title="Coal Combustion Emissions from 1999-2008") +
  theme_bw() + theme(legend.position = "none")

print(coal_plot)
dev.off()
