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
      title = "Download Data",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      closable = FALSE,
      collapsible = TRUE,
      collapsed = FALSE,
      shiny::uiOutput(ns("text")),
    shiny::uiOutput(ns("years")),
    shiny::br(),
    shiny::uiOutput(ns("dates")),
    shiny::br(),
    shiny::hr(),
    shiny::br(), 
    shiny::fluidRow(
      shiny::column(5, offset = 1,
        shiny::actionButton(ns("get_data"), "Get Selected Dates")),
      shiny::column(6,  
    tags$span(id = ns("download_ns"), `data-ns` = ns(""), style="display:none;"),
    shiny::downloadButton(ns("downloadData"), "Download Full Year"))
    )
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
                  <div>
            <b style='color:#d9534f;'>Tip:</b>
            Select specific dates or download an entire year of data 
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


  #download selected year
 output$downloadData <- downloadHandler(
  filename = function() {
    req(input$years)
    paste0(input$years, " MMSD Bacteria Data.csv")
  },
  content = function(file) {
    req(input$years)
    df <- wrangle_download_data(input$years)  # <- your function call
    readr::write_csv(df, file, na = "")
  }
)
    
observeEvent(input$download_clicked, {
  req(input$years)
  showNotification(
    paste0("Download started: ", input$years, " MMSD Bacteria Data.csv"),
    type = "message",
    duration = 3
  )
})


    
  #filter by date
  shiny::eventReactive(input$get_data, {
    dat <- wrangle_download_data(input$years)
    dat |> dplyr::filter( Date %in% input$dates)
  })

  })
}
    
## To be copied in the UI
# mod_selection_pane_table_ui("selection_pane_table_1")
    
## To be copied in the server
# mod_selection_pane_table_server("selection_pane_table_1")
