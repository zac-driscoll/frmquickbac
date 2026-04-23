# UI
mod_selection_pane1_ui <- function(id, date_input = TRUE, param_input = TRUE, watershed_input = TRUE) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
      title = "Select Inputs",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      closable = FALSE,
      collapsible = TRUE,
      collapsed = FALSE,
      shiny::fluidRow(
        shiny::column(
          width = 12,
          # only show if TRUE
          shiny::uiOutput(ns("title")),
          if (date_input) shiny::uiOutput(ns("survey_date")),
          if (param_input) shiny::uiOutput(ns("parameter")),
          if (watershed_input) shiny::uiOutput(ns("watershed")),
          mod_filter_map_dat_ui("filter_map_dat_1")
        )
      )
    )
  )
}

# Server
mod_selection_pane1_server <- function(id, date_input = TRUE, param_input = TRUE, watershed_input = TRUE) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    dat <- load_survey_data()
  output$title <- renderUI({
    shiny::HTML(
      glue::glue("
        <div style='background-color: #dee6f2;
                    border-left:4px solid  #0B85BD;
                    padding:10px;
                    border-radius:6px;
                    margin-bottom:10px;'>
          <div style='font-size:1rem; font-weight:bold; margin-bottom:4px;'>
          Select Values in the dropdown to get started.
          </div>
          <div style='font-size:0.75rem;'>
            <b style='color:#d9534f;'>Tip:</b>
            Click points on the map to see more information. 
          </div>
        </div>
        <hr style='margin-top:10px; margin-bottom:10px;'>"
      )
  )})

    #date input
    if (date_input) {
      output$survey_date <- shiny::renderUI({
        survey_dates <- dat |>
          dplyr::distinct(Date) |>
          dplyr::collect() |>
          dplyr::pull() |>
          sort() |>
          rev()

        shiny::selectInput(
          ns("survey_date"),
          "Select Survey Date",
          choices = survey_dates
        )
      })
    }

  #parameter input
    if (param_input) {
      output$parameter <- shiny::renderUI({
        parameters <- dat |>
          dplyr::distinct(LabelName) |>
          dplyr::arrange(LabelName) |>
          dplyr::collect() |>
          dplyr::pull() |>
          rev()

        shiny::selectInput(
          ns("parameter"),
          "Select Parameter",
          choices = parameters
        )
      })
    }


  #watershed 
    if (watershed_input) {
      output$watershed <- shiny::renderUI({
        water_body <- dat |>
          dplyr::distinct(Watershed) |>
          dplyr::collect() |>
          dplyr::pull() |>
          sort() 

      shiny::checkboxGroupInput(
        ns("watershed"),
        "Select Watershed",
        choices = water_body,
        selected = water_body,
        inline = TRUE,
        )
      })
    }
    
return(
  shiny::reactive({
    mod_output <- list()
    if(param_input){mod_output[["parameter"]] <- input$parameter}
    if(date_input){mod_output[["survey_date"]] <- input$survey_date}
    if(watershed_input){mod_output[["watershed"]] <- input$watershed}
    mod_output[["get_data"]] <- input$get_data
    mod_output  
  })
)
  })
}


    
## To be copied in the UI
# mod_selection_pane1_ui("selection_pane1_1")
    
## To be copied in the server
# mod_selection_pane1_server("selection_pane1_1")
