#' dashboard_body UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_dashboard_body_ui <- function(id) {
  ns <- NS(id)
  bs4Dash::bs4DashBody(
    bs4Dash::bs4TabItems(
      bs4Dash::bs4TabItem(tabName = "Landing", mod_landing_page_ui("landing_page")),
      bs4Dash::bs4TabItem(tabName = "Map", mod_map_ui("map_1")),
      bs4Dash::bs4TabItem(tabName = "Plot", mod_plot_page_ui("plot_1")),
      bs4Dash::bs4TabItem(tabName = "Table", mod_download_page_ui("download_page_1"))
    )
  )
}

#' dashboard_body Server Functions
#'
#' @noRd
mod_dashboard_body_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}

## To be copied in the UI
# mod_dashboard_body_ui("dashboard_body_1")

## To be copied in the server
# mod_dashboard_body_server("dashboard_body_1")