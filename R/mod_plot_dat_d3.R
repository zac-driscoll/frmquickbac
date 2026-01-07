#' plot_dat UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_plot_dat_d3_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
  title = "Site Map",
  status = "primary",       # 💙 keeps the header color
  solidHeader = TRUE,
  width = 12,
  collapsible = TRUE,
  closable = FALSE,
  collapsed = FALSE,
  div(
    #style = "background-color:#F1F9FF; border:1px solid #A9CCE3; border-radius:8px; padding:10px;",
    r2d3::d3Output(ns("ts_plot"), height = '1000px')

  )
)
)
}


#' plot_dat Server Functions
#'
#' @noRd 
mod_plot_dat_d3_server <- function(id, dat){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    output$ts_plot <-  r2d3::renderD3({
    r2d3::r2d3(
      data = dat() |> dplyr::mutate(DatStr = format(as.Date(dat()$Date), "%Y-%m-%d")),
      script =  "inst/app/www/ts_plot.js",
      d3_version = "5"
    )
  })
  })
}
