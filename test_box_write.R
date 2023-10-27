zentracloud::setZentracloudOptions(
  token = Sys.getenv("ZENTRACLOUD_TOKEN"),
  domain = "default"
)

library(boxr)
library(tidyverse)
library(zentracloud)
source("R/gsi_get_data.R")

# fs::dir_create("~/.boxr-auth")
# fs::file_chmod("~/.boxr-auth", mode = "u=wrx")

# box_auth_service()
#need to wait for app to be authorized
# https://arizona.app.box.com/developers/console/app/2140371/authorization

# reads client ID and client secret from .Renviron and finds OAuth2 token.  Requires interactive use.
box_auth()

# id of test folder: https://arizona.app.box.com/folder/231499521564
dir_id <- "231499521564"

box_setwd(dir_id)

#list current files
files <- box_ls() |> as_tibble()

#does example_data.csv exist already?
if ("example_data.csv" %in% files$name) {
  old_dat <- files |> 
    filter(name == "example_data.csv") |> 
    pull(id) |> 
    box_read_csv() |> 
    as_tibble()
  prev_end <- max(old_dat$datetime) |> with_tz("America/Phoenix")
} else {
  old_dat <- tibble()
  prev_end <- ymd("2023-01-01") #or whatever the first date is
}

# Get the data and wrangle it

all_df <- gsi_get_data(start = prev_end)

# bind old to new and write back to box
bind_rows(old_dat, all_df) |> 
  distinct() |> #remove duplicate rows
  box_write("example_data.csv")
