#Create Protorype graphs for the shiny app 
#Load up packages 
library(readr)
library(ggplot2)
library(lubridate)

#Import fvariables.csv from the github files 
variables <- read_csv("variables.csv")
#remove redundant number column I accidentally added when exporting the spreadsheet earlier
cleandata = subset(variables, select = -...1)

View(cleandata)


#start making graphs! 
ggplot(data = cleandata, aes(x = datetime)) + 
  geom_line(aes(y = atmospheric_pressure.value), color = "red") +
  geom_line(aes(y = solar_radiation.value), color = "blue")
