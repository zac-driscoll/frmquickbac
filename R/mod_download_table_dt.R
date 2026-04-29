#' download_table_dt UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_download_table_dt_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
      title = "",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      closable = FALSE,
      collapsible = TRUE,
      collapsed = FALSE,
      DT::dataTableOutput(ns("tbl"))
  )
)
}
    
#' download_table_dt Server Functions
#'
#' @noRd 
mod_download_table_dt_server <- function(id, tbl_dat) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    output$tbl <- DT::renderDataTable(
      DT::datatable(
        tbl_dat(),
        rownames = FALSE,
        filter = "top",
        extensions = c("Buttons", "Scroller"),
        options = list(
          autoWidth = TRUE,
          dom = "Bfrtip",
          buttons = list(
            list(
              extend = "csv",
              text = "Download Data",
              filename = "MMSD Surface Water Bacteria Data",
              exportOptions = list(
                modifier = list(page = "all")
              )
            )
          ),
          deferRender = TRUE,
          scrollY = "65vh",
          scroller = TRUE
        )
      )
    )
  })
}

    
## To be copied in the UI
# mod_download_table_dt_ui("download_table_dt_1")
    
## To be copied in the server
# mod_download_table_dt_server("download_table_dt_1")
