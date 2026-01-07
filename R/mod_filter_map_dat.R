#' filter_map_dat UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_filter_map_dat_ui <- function(id) {
  ns <- NS(id)
  tagList( 
    shiny::sliderInput(ns("result_max"), "Select Max Result:", min = 0, max = 1, value = 1),
    shiny::actionButton(ns("apply_filters"), "Apply Filters", class = "btn-primary")
  )
}
    
#' filter_map_dat Server Functions
#'
#' @noRd 
mod_filter_map_dat_server <- function(id, map_inputs){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    dat <- load_survey_data()
    # --- update slider range when filters change ---
    observe({
      vals <- map_inputs()
      req(vals$survey_date, vals$parameter, vals$watershed)
      max_val <- max_values |>
        dplyr::filter(
          Date == vals$survey_date,
          LabelName == vals$parameter,
          Watershed %in% vals$watershed
        ) |>
        dplyr::pull(max_val) |>
        max(na.rm = TRUE)
      shiny::updateSliderInput(session, "result_max",
        min = 0, max = max_val, value = max_val)
    })
    # --- filter data only when button clicked ---
    dat_filt_out <- shiny::eventReactive(input$apply_filters, {
      vals <- shiny::isolate(map_inputs())
      req(vals$survey_date, vals$parameter, vals$watershed)
      shiny::isolate({
        dat |>
          dplyr::filter(
            Date == vals$survey_date,
            LabelName == vals$parameter,
            Watershed %in% vals$watershed,
            ReadingNum <= input$result_max
          ) |>
          dplyr::select(
            Site  = SiteCode, 
            Latitude, Longitude, 
            Result = ReadingNum, 
            WaterBody, 
            SiteDescription,
            Precip72Hr,
            HoursDry,
            LabelName,
            Watershed,
            Date,
            Units
          ) |>
          dplyr::collect()
      })
    })
    list(survey_data = dat_filt_out)
  })
}

    
## To be copied in the UI
# mod_filter_map_dat_ui("filter_map_dat_1")
    
## To be copied in the server
# mod_filter_map_dat_server("filter_map_dat_1")
