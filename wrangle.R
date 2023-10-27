zentracloud::setZentracloudOptions(
  token = Sys.getenv("ZENTRACLOUD_TOKEN"),
  domain = "default"
)
library(zentracloud)
library(tidyverse)
library(fs)
source("R/gsi_get_data.R")

# Read in already saved data ----------------------------------------------

if (file_exists("example_data.csv")) {
  old_dat <- read_csv("example_data.csv")
  prev_end <- max(old_dat$datetime) |> with_tz("America/Phoenix")
} else {
  #this should only have to run the first time or if the file goes missing
  # prev_end <- first_date_on_zentracloud
  old_dat <- tibble()
  prev_end <- today() - days(10)
}


# Download and wrangle new data---------------------------------------------

all_df <- gsi_get_data(start = prev_end)

# Append saved data -------------------------------------------------------

bind_rows(old_dat, all_df) |> 
  distinct() |> #remove duplicate rows
  write_csv("example_data.csv")

