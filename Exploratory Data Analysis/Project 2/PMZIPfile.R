NEIfile <- "NEI_data.zip"

if (!file.exists(NEIfile)) {
  download_url <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  download.file(download_url, destfile = NEIfile)
}

if(!(file.exists("summarySCC_PM25.rds") && file.exists("Source_Classification_Code.rds"))) { 
    unzip(NEIfile) 
}
