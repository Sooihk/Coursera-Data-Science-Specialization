source("PMZIPfile.R")

NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

library("dplyr")
library("ggplot2")

#Filter out Baltimore emissions and group by year and type of source
Baltimore_type_emissions <- NEI %>% filter(fips=="24510") %>% group_by(year, type) %>% summarise(Emissions=sum(Emissions))
png("plot3.png")

b_t_plot <- ggplot(data=Baltimore_type_emissions, mapping=aes(x=factor(year), y=Emissions, fill=type)) +
  geom_bar(stat="identity") + facet_grid(.~type) + labs(x="Year",y=expression('PM'[2.5]*' Emission'), 
  title=expression('PM'[2.5]*' Emissions in Baltimore City From 1999-2008 By Source Type')) + theme_bw() + 
  theme(legend.position="none")

print(b_t_plot)
dev.off()
