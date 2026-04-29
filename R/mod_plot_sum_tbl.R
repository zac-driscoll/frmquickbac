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
  ns <- shiny::NS(id)

  tab_title <- function(txt) {
    tags$span(style = "font-size: 0.9rem; font-weight: 700;", txt)
  }

  shiny::tagList(
    bs4Dash::bs4Card(
      title = "Summary Statistics",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
    div(
      style = "height: 34vh; min-height: 100px;",
      shiny::tabsetPanel(
        type = "tabs",

        shiny::tabPanel(
          title = tab_title("E. coli"),
          tags$div(
            style = "max-height: 31vh; overflow-y: auto;",
           shiny::uiOutput(ns("ecoli"))
          )
        ),

        shiny::tabPanel(
          title = tab_title("DO"),
          tags$div(
            style = "max-height: 31vh; overflow-y: auto;",
            shiny::uiOutput(ns("do"))
          )
        ),

        shiny::tabPanel(
          title = tab_title("Fecal Coliform"),
          tags$div(
            style = "max-height: 31vh; overflow-y: auto;",
            shiny::uiOutput(ns("fecal"))
          )
        )
      )
    )
  )
)
}

#' plot_sum_tbl Server Functions
#'
#' @noRd
mod_plot_sum_tbl_server <- function(id, ecoli_dat, do_dat, fecal_dat) {
  shiny::moduleServer(id, function(input, output, session) {
    output$ecoli <-  shiny::renderUI({
    shiny::HTML(
        mod_plot_create_html_tbl_server(
          "plot_create_html_tbl_1",
          ecoli_dat()[-3,],
          "E. coli",
          0
        )
      )
    })

    output$do <- shiny::renderUI({
      shiny::HTML(
        mod_plot_create_html_tbl_server(
          "plot_create_html_tbl_2",
          do_dat()[-3,],
          "Dissolved Oxygen",
          1
        )
      )
    })

    output$fecal <- shiny::renderUI({
      shiny::HTML(
        mod_plot_create_html_tbl_server(
          "plot_create_html_tbl_3",
          fecal_dat()[-3,],
          "Fecal Coliform",
          0
        )
      )
    })

  })
}

## To be copied in the UI
# mod_plot_sum_tbl_ui("plot_sum_tbl_1")
    
## To be copied in the server
# mod_plot_sum_tbl_server("plot_sum_tbl_1")
