#' plot_dat UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_plot_dat_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
  title = "Time Series",
  status = "primary",   
  solidHeader = TRUE,
  width = 12,
  collapsible = TRUE,
  closable = FALSE,
  collapsed = FALSE,
  div(
    style = "background-color:#F1F9FF; border:1px solid #A9CCE3; border-radius:8px; padding:10px;",
    # --- card body content goes here ---
    shiny::fluidRow(
      shiny::column(12,
      shiny::htmlOutput(ns("title")))
    ),
    shiny::fluidRow(shiny::br()),
    shiny::fluidRow(
      shiny::column(6, plotly::plotlyOutput(ns('plot1'))),
      shiny::column(6, plotly::plotlyOutput(ns('plot2')))
    ),
    shiny::fluidRow(
      shiny::column(6, plotly::plotlyOutput(ns('plot3'))),
      shiny::column(6, plotly::plotlyOutput(ns('plot4')))
    )
  )))}
    
#' plot_dat Server Functions
#'
#' @noRd 
mod_plot_dat_server <- function(id, dat) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # HTML Title
    output$title <- shiny::renderUI({
      site <- unique(dat()$SiteCode)
      year <- unique(stats::na.omit(dat()$Year))[1]
      #template uses {site} / {year}, glue() will fill them
      shiny::HTML(glue::glue(
        readr::read_file("inst/app/templates/plot_title.html")
      ))
    })

    # Plots
    output$plot1 <- plotly::renderPlotly({ plot_param(dat(), "E. coli") })
    output$plot2 <- plotly::renderPlotly({ plot_param(dat(), "Dissolved Oxygen") })
    output$plot3 <- plotly::renderPlotly({ plot_param(dat(), "Fecal Coliform") })
    output$plot4 <- plotly::renderPlotly({ plot_param(dat(), "Average Basin Wide Precip") })
  })
}
# mod_plot_dat_ui("plot_dat_1")
    
## To be copied in the server
# mod_plot_dat_server("plot_dat_1")
