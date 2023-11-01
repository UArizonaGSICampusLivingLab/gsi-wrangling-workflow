#Create Protorype graphs for the shiny app 
#Load up packages 
library(readr)
library(ggplot2)
library(lubridate)

#Import fvariables.csv from the github files 
variables <- read_csv("variables1.csv")

View(variables)





#start making graphs! 
ggplot(data = variables, aes(x = datetime)) + 
  geom_line(aes(y = atmospheric_pressure.value), color = "red") +
  geom_line(aes(y = solar_radiation.value), color = "blue")









mean(cleandata$air_temperature.value[5:24]) #the brackets pull out a data frame, the column is called with the filename$column 

#rows then columns in the brackets if not specified with $

c(1,6,8:10) #create vector then use this for indicated rows or columns 

summary(cleandata$air_temperature.value[5:24])

