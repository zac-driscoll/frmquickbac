# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
#
########################################
#### CURRENT FILE: ON START SCRIPT #####
########################################

## Fill the DESCRIPTION ----
## Add meta data about your application and set some default {golem} options
##
## /!\ Note: if you want to change the name of your app during development,
## either re-run this function, call golem::set_golem_name(), or don't forget
## to change the name in the app_sys() function in app_config.R /!\
##
golem::fill_desc(
  pkg_name = "frmquickbac", # lowercase, no underscores or periods
  pkg_title = "FRM Bacteria Data Visualization", 
  pkg_description = "A Shiny application for visualizing FRM's bacteria monitoring data. 
  The app is designed for use by external organizations, including the Milwaukee Water Works.",
  authors = person(
    given = "Zac",
    family = "Driscoll",
    email = "zdriscoll@mmsd.com",
    role = c("aut", "cre")
    # comment = c(ORCID = "0000-0000-0000-0000") # optional
  ),
  repo_url = NULL, # can fill in when GitHub repo is ready
  pkg_version = "0.0.0.9000",
  set_options = TRUE
)

renv::init()
golem::install_dev_deps()
renv::install("MMSDGIT/mmsd.sql")


## Create Common Files ----
## See ?usethis for more information
usethis::use_mit_license("Golem User") # You can set another license here
golem::use_readme_rmd(open = FALSE)
devtools::build_readme()
# Note that `contact` is required since usethis version 2.1.5
# If your {usethis} version is older, you can remove that param
usethis::use_code_of_conduct(contact = "Golem User")
usethis::use_lifecycle_badge("Experimental")
usethis::use_news_md(open = FALSE)

## Init Testing Infrastructure ----


## Favicon ----
# If you want to change the favicon (default is golem's one)
golem::use_favicon() # path = "path/to/ico". Can be an online file.
# golem::remove_favicon() # Uncomment to remove the default favicon


## Use git ----
usethis::use_git()
## Sets the remote associated with 'name' to 'url'
usethis::use_git_remote(
  name = "origin",
  url = "https://github.com/zac-driscoll/frmquickbac.git"
)

# You're now set! ----
# go to dev/02_dev.R
rstudioapi::navigateToFile("dev/02_dev.R")
