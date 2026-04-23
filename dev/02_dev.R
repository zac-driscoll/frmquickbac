# Building a Prod-Ready, Robust Shiny Application.
#
# README: each step of the dev files is optional, and you don't have to
# fill every dev scripts before getting started.
# 01_start.R should be filled at start.
# 02_dev.R should be used to keep track of your development during the project.
# 03_deploy.R should be used once you need to deploy your app.
#
#
###################################
#### CURRENT FILE: DEV SCRIPT #####
###################################

# Engineering

## Dependencies ----
## Amend DESCRIPTION with dependencies read from package code parsing
## install.packages('attachment') # if needed.
attachment::att_amend_desc()

## Add modules ----
## Create a Landing Page
golem::add_module(name = "landing_page", with_test = FALSE)

## Create a module infrastructure in R/
golem::add_module(name = "selection_pane1", with_test = TRUE) # Name of the module
golem::add_module(name = "map", with_test = TRUE) # Name of the module
golem::add_module(name = "leaflet_map", with_test = FALSE) # Name of the module
golem::add_module(name = "filter_map_dat", with_test = FALSE) # Name of the module
golem::add_module(name = "map_dt", with_test = FALSE) # Name of the module
golem::add_module(name = "map_barplot", with_test = FALSE) # Name of the module
golem::add_module(name = "map_barplot_d3", with_test = FALSE) # Name of the module
golem::add_module(name = 'highlight_map')

##plotting module
golem::add_module(name = "plot_page", with_test = FALSE) # Name of the module
golem::add_module(name = "selection_pane_plot", with_test = TRUE) # Name of the module
golem::add_module(name = "plot_filter_plot_dat", with_test = TRUE) # Name of the module
golem::add_module(name = "plot_dat", with_test = TRUE) # Name of the module
golem::add_module(name = "plot_dat_d3", with_test = FALSE) # Name of the module
golem::add_module(name = "plot_filter_sum_tbl", with_test = TRUE) # Name of the module
golem::add_module(name = "plot_create_html_tbl", with_test = TRUE) # Name of the module
golem::add_module(name = "plot_sum_tbl", with_test = TRUE) # Name of the module

#Download modlue
golem::add_module(name = "download_page", with_test = TRUE) # Name of the module
golem::add_module(name = "selection_pane_table", with_test = TRUE) # Name of the module
golem::add_module(name = "download_table_dt", with_test = TRUE) # Name of the module
golem::add_module(name = "download_filter_tbl_dat", with_test = TRUE) # Name of the module

## Add helper functions ----
## Creates fct_* and utils_*
golem::add_fct("helpers", with_test = TRUE)
golem::add_utils("helpers", with_test = TRUE)

## External resources
## Creates .js and .css files at inst/app/www
golem::add_js_file("script")
golem::add_js_handler("handlers")
golem::add_css_file("custom")

golem::add_css_file("custom2")
golem::add_sass_file("custom")
golem::add_any_file("file.json")

## Add internal datasets ----
## If you have data in your package
usethis::use_data_raw(name = "my_dataset", open = FALSE)

## Tests ----
## Add one line by test you want to create
usethis::use_test("app")

# Documentation

## Vignette ----
usethis::use_vignette("FRMQuickBac")
devtools::build_vignettes()

## Code Coverage----
## Set the code coverage service ("codecov" or "coveralls")
usethis::use_coverage()



## CI ----
## Use this part of the script if you need to set up a CI
## service for your application
##
## (You'll need GitHub there)
usethis::use_github()

# GitHub Actions
usethis::use_github_action()
# Chose one of the three
# See https://usethis.r-lib.org/reference/use_github_action.html
usethis::use_github_action_check_release()
usethis::use_github_action_check_standard()
usethis::use_github_action_check_full()
# Add action for PR
usethis::use_github_action_pr_commands()

# Circle CI
usethis::use_circleci()
usethis::use_circleci_badge()

# Jenkins
usethis::use_jenkins()

# GitLab CI
usethis::use_gitlab_ci()

# You're now set! ----
# go to dev/03_deploy.R
rstudioapi::navigateToFile("dev/03_deploy.R")
