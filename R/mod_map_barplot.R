#' map_barplot UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_map_barplot_ui <- function(id) {
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
      shiny::uiOutput(ns('text')),
      plotly::plotlyOutput(ns('plot'), height = '900px')
    )
  )
}

#' map_barplot Server Functions
#'
#' @noRd
mod_map_barplot_server <- function(id, dat) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # ------------------------------
    # Heading Text
    # ------------------------------
    output$text <- renderUI({
      survey_dat <- unique(dat()$Date)
      param <- unique(dat()$LabelName)

      shiny::HTML(
        glue::glue(
          "
      <div style='background-color: #dee6f2;
                  border-left:4px solid  #0B85BD;
                  padding:10px;
                  border-radius:6px;
                  margin-bottom:10px;'>
        <div style='font-size:18px; font-weight:bold; margin-bottom:4px;'>
          Survey Results for {param} on {survey_dat}
        </div>
        <div>
          <b style='color:#d9534f;'>Tip:</b>
          Hover over a bar to see more information and exact values.
        </div>
      </div>
      <hr style='margin-top:10px; margin-bottom:10px;'>"
        )
      )
    })


    # ------------------------------
    # Plot
    # ------------------------------
    output$plot <- plotly::renderPlotly({

      df <- dat()
      param <- unique(df$LabelName)
      units <- unique(df$Units)

      # Palette selection depends on DO or not
      if (grepl("DO", param)) {
        color_pal <- c("red", "orange", "blue")
      } else {
        color_pal <- rev(c("red", "orange", "blue"))
      }

      pal <- leaflet::colorNumeric(palette = color_pal, domain = df$Result)

      # Add all needed columns BEFORE plotting
      df <- df |>
        dplyr::mutate(
          Color = pal(Result),
          Site_ordered = if (!grepl("DO", param)) {
            reorder(Site, Result)
          } else {
            reorder(Site, dplyr::desc(Result))
          },
          Text = glue::glue("
            <span style='font-size:24px; color:{Color};'><b>{Site}</b></span><br>
            <span style='font-size:20px; color:black;'><b>Location:</b> {SiteDescription}</span><br>
            <b>Result:</b> {scales::comma(round(Result, 2))}<br>
            <b>72-Hr Precip:</b> {scales::comma(Precip72Hr)} in<br>
            <b>Hours Dry:</b> {scales::comma(HoursDry)}
          ")
        )

      # ------------------------------
      # Build ggplot using ONLY df columns
      # ------------------------------
      p <- ggplot2::ggplot(
        df,
        ggplot2::aes(
          x = Result,
          y = Site_ordered,
          fill = Color,
          text = Text
        )
      ) +
        ggplot2::geom_col(
          alpha = 0.85,
          color = "#030c13ff"
        ) +
        ggplot2::scale_fill_identity() +
        ggplot2::scale_x_continuous(
          labels = scales::comma,
          expand = ggplot2::expansion(mult = c(0, 0.1))
        ) +
        ggplot2::labs(
          title = NULL,
          x = units,
          y = NULL
        ) +
        custom_theme()

      # ------------------------------
      # Convert to plotly safely
      # ------------------------------
      plotly::ggplotly(p, tooltip = "text") |>
        plotly::layout(
          margin = list(l = 40, r = 50, t = 40, b = 70),
          hoverlabel = list(
            bgcolor = "white",
            font = list(size = 16, color = "black")
          )
        )

    })
  })
}

## To be copied in the UI
# mod_map_barplot_ui("map_barplot_1")

## To be copied in the server
# mod_map_barplot_server("map_barplot_1")
