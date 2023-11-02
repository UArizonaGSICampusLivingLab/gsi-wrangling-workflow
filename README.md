# gsi-wrangling-workflow

[![Project Status: WIP -- Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

This repository contains code to automatically collect and wrangle data from the [GSI Living Lab](https://udallcenter.arizona.edu/news/campus-living-lab-creating-more-sustainable-campus-designing-building-and-monitoring-green) at University of Arizona.
The data set is available upon request.
<!-- eventually add a link to request form -->

### Contributing

To run the code in this repo locally, you'll need to set up access to Zentra Cloud and access to the Box API

#### `renv`

This project uses [`renv`](https://rstudio.github.io/renv/) for package management.
When you open this R Project, `renv` will bootstrap itself and should prompt you to run `renv::restore()` to install all dependencies.
If for some reason `renv::restore()` doesn't work for you, you can deactivate `renv` with `renv::deactivate()` and install packages the usual way.
`renv` is primarily used in this project for publishing to Posit Connect, and shouldn't be necessary for you to run any of the code locally.

#### Zentra Cloud

1.  Create a .Renviron file (e.g. with `usethis::edit_r_environ("project")`) and add an environment variable for the Zentra Cloud API token

```         
ZENTRACLOUD_TOKEN=<token>
```

2.  If for some reason `renv::restore()` didn't install the `zentracloud` R package, you can install it from r-universe or directly from GitLab

``` r
# r-universe installation
install.packages('zentracloud', repos = c('https://cct-datascience.r-universe.dev', 'https://cloud.r-project.org'))

# GitLab installation
pak::pkg_install("gitlab::meter-group-inc/pubpackages/zentracloud")
```

3.  The token in .Renviron is not automatically read in by `zentracloud`, so you'll find code to set options at the top of most scripts:

``` r
zentracloud::setZentracloudOptions(
  token = Sys.getenv("ZENTRACLOUD_TOKEN"),
  domain = "default"
)
```

#### Box

The Box API is accessed using the `boxr` package.
You'll find instructions on creating an "app" and authenticating on the [`boxr` website](https://r-box.github.io/boxr/articles/boxr.html).
This workflow uses a [service app](https://r-box.github.io/boxr/articles/boxr-app-service.html) to upload data to a shared box folder.
You may need to request access to this service app from the Buzzard lab or you can create your own [interactive app](https://r-box.github.io/boxr/articles/boxr-app-interactive.html) if you're just interested in downloading existing files that have been shared with you.

There is some code I used to set this up in `R/box_app_setup.R`.
This creates a `.boxr-auth` file containing JSON.
To get this to work with Posit Connect, however, I've copied the text of that file and added it to .Renviron as `BOX_TOKEN_TEXT`.

#### Posit Connect

The automated workflow can be found in `gsi_wrangling.Rmd` and is published on University of Arizona's [Posit Connect server](https://datascience.arizona.edu/analytics-powerhouse/rstudio-connect) where it runs daily as a scheduled report.

To publish `gsi_wrangling.Rmd` to Posit Connect and have it work, you need to add secret [environment variables](https://docs.posit.co/connect/user/content-settings/#content-vars) for `ZENTRACLOUD_TOKEN` and `BOX_TOKEN_TEXT`.

### Files

in `R/` you will find:

-   `box_app_setup.R`: some code I used when first setting up Box authentication. Not to be run again, but just as an example.
-   `estimate_data_size.R`: a script for extrapolating data size
-   `gsi_get_data.R`: a function, `gsi_get_data()`, for downloading and wrangling data from the Zentra Cloud API.

### Contributors

<!-- eventually add CITATION.cff -->

-   Eric Scott
-   Malcolm Barrios
