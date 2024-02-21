library(boxr)
library(tidyverse)
library(units)

source("R/calc_hi.R")
source("R/calc_wind_chill.R")
# get data to test with ---------------------------------------------------
box_auth_service(token_text = Sys.getenv("BOX_TOKEN_TEXT"))
# box_auth() ## If you want to run locally use this instead of box_auth_service()
dir_id <- "233031886906"
box_setwd(dir_id)
#list current files
files <- box_ls() |> as_tibble()

data <- files |> 
  filter(name == "gsi_living_lab_data.csv") |> 
  pull(id) |> 
  box_read(read_fun = readr::read_csv)

site_info <- files |> 
  filter(name == "site_info.csv") |>
  pull(id) |>
  box_read(read_fun = readr::read_csv)

data_full <- left_join(data, site_info)

df_adj <- data_full |> 
  mutate(
    feels_like.value = calc_hi(air_temperature.value, vapor_pressure.value) |> 
      calc_wind_chill(wind_speed.value) |>
      round(digits = 1) #same number of digits as input temp
  )

df_adj |> 
  select(datetime, air_temperature.value, feels_like.value) |> 
  filter(air_temperature.value != feels_like.value) |> 
  count(date(datetime))
#13 days, all in winter, where the "feels like" temp is different than the real temp

df_adj |> 
  filter(air_temperature.value != feels_like.value) |> 
  ggplot(aes(x = air_temperature.value, y = feels_like.value, color = site)) +
  geom_point(alpha = 0.6) +
  geom_abline()
#mostly Gould Simpson that gets the wind chill!
