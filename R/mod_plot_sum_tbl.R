#' plot_sum_tbl UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_plot_sum_tbl_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
      title = "Summary Stats",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
    shiny::tabsetPanel(
      shiny::tabPanel(
        HTML("<span style='font-size: 24px; font-weight: 700;'>E. coli</span>"),
        shiny::uiOutput(ns('ecoli'))),
      shiny::tabPanel(
        HTML("<span style='font-size: 24px; font-weight: 700;'>DO</span>"), 
        shiny::uiOutput(ns('do'))),
      shiny::tabPanel(
        HTML("<span style='font-size: 24px; font-weight: 700;'>Fecal Coliform</span>"),
        shiny::uiOutput(ns('fecal')))
      )
  ))
}
    
#' plot_sum_tbl Server Functions
#'
#' @noRd 
mod_plot_sum_tbl_server <- function(id, ecoli_dat, do_dat, fecal_dat){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    # E. coli table
    output$ecoli <-  
      shiny::renderUI(
        HTML(
          mod_plot_create_html_tbl_server(
            "plot_create_html_tbl_1", 
            ecoli_dat(),
            "E. coli"
          )))
    #DO Table
    output$do <-  
      shiny::renderUI(
        HTML(
          mod_plot_create_html_tbl_server(
            "plot_create_html_tbl_2", 
            do_dat(),
            "Dissolved Oxygen"
          )))
    #Fecal Table

    output$fecal <-  
      shiny::renderUI(
        HTML(
          mod_plot_create_html_tbl_server(
            "plot_create_html_tbl_3", 
            fecal_dat(),
            "Fecal Coliform"
          )))
    

  })
}
    
## To be copied in the UI
# mod_plot_sum_tbl_ui("plot_sum_tbl_1")
    
## To be copied in the server
# mod_plot_sum_tbl_server("plot_sum_tbl_1")
