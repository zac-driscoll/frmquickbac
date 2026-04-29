#' plot_filter_plot_dat UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_plot_filter_plot_dat_ui <- function(id) {
  ns <- NS(id)
  tagList()
}
    
#' plot_filter_plot_dat Server Functions
#'
#' @noRd 
mod_plot_filter_plot_dat_server <- function(id, plot_inputs) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    dat <- load_survey_data()
    precip_dat <- load_precip_data()

    return(
    shiny::reactive({
        vals <- plot_inputs()
        req(vals$site, vals$years, vals$depth)

        site  <- vals$site
        years <- vals$years
        depth <- vals$depth

        # base datasetn
        base_df <- dat |>
          dplyr::collect() |>
          dplyr::filter(
            SiteCode %in% site,
            Year %in% years,
            Depth %in% depth
          ) |>
          dplyr::select(LabelName, Date, ReadingNum, Year, SiteCode, Depth, Units, WeatherStation, Latitude, Longitude, SiteDescription ) |>
          dplyr::mutate(type = paste(years, "Results"))
        # historic averages
        hist_df <- dat |>
          dplyr::collect() |>
          dplyr::filter(
            SiteCode %in% site,
            Depth %in% depth
          ) |>
          dplyr::mutate(Date = lubridate::month(Date)) |>
          dplyr::group_by(LabelName, Date, Units) |>
          dplyr::summarise(
            ReadingNum = mean(ReadingNum, na.rm = TRUE),
            .groups = "drop"
          ) |>
          dplyr::mutate(
            Date = as.Date(paste(years, Date, 15, sep = "-")),
            type = "Historic Monthly Average",
            SiteCode = site,
            Depth = depth,
            Year = NA
          )
        # filter precip data
        years_i <- as.integer(years)
      station_val <- as.character(unique(base_df$WeatherStation)[1])
        precip_dat_filt <- 
          precip_dat |>
          dplyr::filter(
            Year %in% years_i,
            station_id %in% station_val) |>
          dplyr::collect() |> 
          dplyr::mutate(
            LabelName = paste("Daily Precipitation:", station_val),
            type = paste("Precip"),
            Units = "Inches",
            SiteCode = site
          ) |>
          dplyr::left_join(
        ws_lookup |> dplyr::select(station_id = WeatherStation, Latitude = Lat, Longitude =  Long, SiteDescription = Description)
          )
        dplyr::bind_rows(base_df, hist_df, precip_dat_filt)
    })
    )
  })
}

## To be copied in the UI
# mod_plot_filter_plot_dat_ui("plot_filter_plot_dat_1")
    
## To be copied in the server
# mod_plot_filter_plot_dat_server("plot_filter_plot_dat_1")
