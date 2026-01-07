#' nph_summary UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_map_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::fluidRow(
      shiny::column(3,
        shiny::fluidRow(
          mod_selection_pane1_ui("selection_pane1_1")),
        shiny::fluidRow(
          mod_map_dt_ui("map_dt_1"))),
      shiny::column(5, 
          mod_leaflet_map_ui("leaflet_map_1")),
      shiny::column(4,
        mod_map_barplot_d3_ui("map_barplot_d3_1")
      ))
    )
}

#' nph_summary Server Functions
#'
#' @noRd
mod_map_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

})
}


## To be copied in the UI
# mod_map_ui("map_1")

## To be copied in the server
# mod_map_server("map_1")