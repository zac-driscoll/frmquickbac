#' selection_pane_table UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_selection_pane_table_ui <- function(id) {
  ns <- NS(id)
  tagList(
      tagList(
    bs4Dash::bs4Card(
      title = "Select Input",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      closable = FALSE,
      collapsible = TRUE,
      collapsed = FALSE,
      shiny::uiOutput(ns("text")),
    shiny::uiOutput(ns("years")),
    shiny::uiOutput(ns("dates")),
    shiny::actionButton(ns("get_data"), "Get Data")
    )
  )
  )
}
    
#' selection_pane_table Server Functions
#'
#' @noRd 
mod_selection_pane_table_server <- function(id){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    dat <- load_survey_data()
    output$text <- renderUI({
      shiny::HTML(
        glue::glue("
      <div style='background-color: #dee6f2;
                  border-left:4px solid  #0B85BD;
                  padding:10px;
                  border-radius:6px;
                  margin-bottom:10px;'>
        <div style='font-size:18px; font-weight:bold; margin-bottom:4px;'>
          Select Values in the dropdown to get started.
        </div>
                  <div>
            <b style='color:#d9534f;'>Tip:</b>
            Hover over points on the plot to see more information. 
          </div>
      </div>
      <hr style='margin-top:10px; margin-bottom:10px;'>"
    )
  )
})

    # ---- YEAR SELECT ----
    output$years <- shiny::renderUI({
      years <- dat |>
        dplyr::distinct(Year) |>
        dplyr::collect() |>
        dplyr::pull() |>
        sort(decreasing = TRUE)
      shiny::selectInput(ns("years"), "Select Year", choices = years)
    })


    # ---- SITE SELECT ----
    output$dates <- 
    shiny::renderUI({
      req(input$years)  # ✅ wait until both exist
      dates <- 
        dat |>
        dplyr::collect() |> 
        dplyr::filter(Year %in% input$years) |>
        dplyr::distinct(Date) |>
        dplyr::arrange(desc(Date)) |>
        dplyr::pull() 
      
      shiny::selectInput(ns("dates"), "Select Date(s)", multiple = TRUE,  choices = dates)
    })


return(
  shiny::eventReactive(input$get_data, {
    mod_output <- list()
    mod_output[["years"]] <- input$years
    mod_output[["dates"]] <- input$dates
    mod_output  
  })
)
  })
}
    
## To be copied in the UI
# mod_selection_pane_table_ui("selection_pane_table_1")
    
## To be copied in the server
# mod_selection_pane_table_server("selection_pane_table_1")
