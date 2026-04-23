#' plot_page UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_plot_page_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::fluidRow(
    shiny::column(3, 
      shiny::fluidRow(
      mod_selection_panel_plot_ui("plot_select1"),
      mod_plot_sum_tbl_ui("plot_sum_tbl_1"))),
    shiny::column(9,  mod_plot_dat_d3_ui("plot_dat_d3_1"))
    #shiny::column(9,  mod_plot_dat_ui("plot_dat_1"))
    )
  )
}

#' plot_page Server Functions
#'
#' @noRd 
mod_plot_page_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_plot_page_ui("plot_page_1")
    
## To be copied in the server
# mod_plot_page_server("plot_page_1")
