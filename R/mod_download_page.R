#' nph_summary UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_download_page_ui <- function(id) {
  ns <- NS(id)
  tagList(
    shiny::fluidRow(
      shiny::column(3,
        shiny::fluidRow(mod_selection_pane_table_ui("selection_pane_table_1")),
        shiny::fluidRow()),
      shiny::column(9,
        mod_download_table_dt_ui("download_table_dt_1")
      )))
}

#' nph_summary Server Functions
#'
#' @noRd
mod_download_page_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

})
}


## To be copied in the UI
# mod_download_page_ui("download_page_1")

## To be copied in the server
# mod_download_page_server("download_page_1")