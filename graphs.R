#Create Protorype graphs for the shiny app 
#Load up packages 
library(readr)
library(ggplot2)
library(lubridate)
library(dplyr)

#Import variables1.csv from the github files 
variables <- read_csv("variables1.csv")

View(variables)

atm_port1 <-
  variables |> 
  filter(port == 1) |> 
  filter(sensor == "ATM-410008161")

ggplot(atm_port1)

#start making graphs! 
ggplot(data = variables, aes(x = datetime)) + 
  geom_line(aes(y = water_content.value, color = device_sn)) +
  facet_grid(port~device_sn)

#issues with this 
#ask about pulling the right practice data because this is not going to wokr most of the values are N?A's 



mean(cleandata$air_temperature.value[5:24]) #the brackets pull out a data frame, the column is called with the filename$column 

#rows then columns in the brackets if not specified with $

c(1,6,8:10) #create vector then use this for indicated rows or columns 

summary(cleandata$air_temperature.value[5:24])

