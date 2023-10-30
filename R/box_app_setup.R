library(boxr)
if (FALSE) { #one time setup.  Don't run this again!
  
  fs::dir_create("~/.boxr-auth")
  
  # reads client ID and client secret from .Renviron and finds OAuth2 token.  Requires interactive use.
  box_auth()
  user_id <- "20074571292" #printed when box_auth() is run
  
  # reads OAuth2 (JWT) token to authenticate service app
  box_auth_service()
  
  # Create a folder in the service app's working directory (which is not the same as my working directory)
  box_dir_create("GSI_living_lab")
  box_ls()
  dir_id <- "233031886906"
  
  # Share that folder from the service app with myself as a co-owner
  box_collab_create(dir_id = dir_id, login = "ericrscott@arizona.edu", role = "co-owner")
}


