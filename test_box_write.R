library(boxr)


fs::dir_create("~/.boxr-auth")
fs::file_chmod("~/.boxr-auth", mode = "u=wrx")

box_auth_service()
#need to wait for app to be authorized
# https://arizona.app.box.com/developers/console/app/2140371/authorization