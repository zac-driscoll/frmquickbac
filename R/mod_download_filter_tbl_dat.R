#' download_filter_tbl_dat UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_download_filter_tbl_dat_ui <- function(id) {
  ns <- NS(id)
  tagList(
 
  )
}
    
#' download_filter_tbl_dat Server Functions
#'
#' @noRd 
mod_download_filter_tbl_dat_server <- function(id, tbl_inputs){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    
    dat <- load_survey_data()

    return(
    shiny::reactive({
        vals <- tbl_inputs()
        req(vals$years, vals$dates)

        years <- vals$years
        dates <- vals$dates

        # base dataset
        dat |>
          dplyr::collect() |>
          dplyr::filter(
            Year %in% years,
            Date %in% dates
          ) |>
          dplyr::select(SiteCode, LabelName, WaterBody, Date, ReadingVal,  HoursDry, Precip72Hr) |>
          tidyr::pivot_wider(names_from = LabelName, values_from = ReadingVal) |>
          dplyr::relocate(HoursDry, .after = dplyr::last_col()) |>
          dplyr::relocate(Precip72Hr, .after = dplyr::last_col()) 

      
    })
    )

  })
}
    
## To be copied in the UI
# mod_download_filter_tbl_dat_ui("download_filter_tbl_dat_1")
    
## To be copied in the server
# mod_download_filter_tbl_dat_server("download_filter_tbl_dat_1")
