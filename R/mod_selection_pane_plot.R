#' selection_pane_plot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_selection_panel_plot_ui <- function(id) {
ns <- NS(id)
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
      shiny::uiOutput(ns("watershed")),
      shiny::uiOutput(ns("site")),
      shiny::uiOutput(ns("depth")),
      shiny::actionButton(ns("get_data"), "Get Data")
    )
  )
}
# Server
mod_selection_panel_plot_server <- function(id) {
  moduleServer(id, function(input, output, session) {
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

    # ---- WATERSHED SELECT ----
    output$watershed <- shiny::renderUI({
      water_body <- dat |>
        dplyr::distinct(WaterBody) |>
        dplyr::collect() |>
        dplyr::pull() |>
        sort()
      shiny::selectInput(ns("watershed"), "Select Water Body", choices = water_body)
    })

    # ---- SITE SELECT ----
    output$site <- shiny::renderUI({
      req(input$watershed, input$years)  # ✅ wait until both exist
      site <- dat |>
        dplyr::collect() |>
        dplyr::filter(WaterBody %in% input$watershed,
                      Year %in% input$years) |>
        dplyr::distinct(SiteCode) |>
        dplyr::pull() |>
        sort()
      shiny::selectInput(ns("site"), "Select Site", choices = site)
    })

    # ---- DEPTH SELECT ----
    output$depth <- shiny::renderUI({
      req(input$site)  # ✅ wait until site is chosen
      depth <- dat |>
        dplyr::collect() |>
        dplyr::filter(SiteCode %in% input$site) |>
        dplyr::distinct(Depth) |>
        dplyr::pull() |>
        sort()
      shiny::selectInput(ns("depth"), "Select Depth", choices = depth)
    })

return(
  shiny::eventReactive(input$get_data, {
    mod_output <- list()
    mod_output[["years"]] <- input$years
    mod_output[["site"]] <- input$site
    mod_output[["depth"]] <- input$depth
    mod_output  
  })
)
  })
  }
  

