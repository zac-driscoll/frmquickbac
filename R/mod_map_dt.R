#' map_dt UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' map_dt UI Function
#'
#' @description A shiny Module.
#' @noRd
#' @importFrom shiny NS tagList 
#' map_dt UI Function
#'
#' @description A shiny Module.
#' @noRd
#' map_dt UI Function
#'
#' @description A shiny Module.
#' @noRd
mod_map_dt_ui <- function(id) {
  ns <- NS(id)
    bs4Dash::bs4Card(
      title = "",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      closable = FALSE,
      collapsible = TRUE,
      collapsed = FALSE,
      # ✨ Adjusted fixed height to account for filters above
      div(
        style = "
          height: calc(37vh - 74px);  /* half map height for balance */
          min-height: 250px;
          overflow-y: auto;
          overflow-x: auto;
          padding: 4px;
        ",
        shiny::uiOutput(ns("text")),
        DT::dataTableOutput(ns('map_dt'), width = "100%")
      )
    )
}

#' map_dt Server Function
#' @noRd 
#' map_dt Server Function
#' @noRd 
mod_map_dt_server <- function(id, dat_filt, map_inputs, map_selection) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  shiny::observe({
survey_dat <- unique(dat_filt()$Date)
params <- unique(dat_filt()$LabelName)
output$text <- renderUI({
  shiny::HTML(
    glue::glue("
      <div style='background-color: #dee6f2;
                  border-left:4px solid  #0B85BD;
                  padding:10px;
                  border-radius:6px;
                  margin-bottom:10px;'>
        <div style='font-size:18px; font-weight:bold; margin-bottom:4px;'>
          Survey Results for {params} on {survey_dat}
        </div>
        <div>
          <b style='color:#d9534f;'>Tip:</b>
          Click a point(s) in the table to highlight it on the map.
        </div>
      </div>
      <hr style='margin-top:10px; margin-bottom:10px;'>"
    )
  )
})
  })

      shiny::observe({
      df <- dat_filt()
      params <- unique(dat_filt()$LabelName)
      if (nrow(df) == 0) {
        output$map_dt <- DT::renderDataTable(
          DT::datatable(
            data.frame(Message = "No data available for this selection"),
            options = list(dom = 't')
          )
        )
      } else {
        # your color palette logic
        if (grepl("Oxygen", params)) {
          color_pal <- c("red", "orange", "blue")
        } else {
          color_pal <- rev(c("red", "orange", "blue"))
        }
        pal <- leaflet::colorNumeric(
          palette = color_pal,
          domain  = df$Result
        )
        output$map_dt <- DT::renderDataTable({
  rng <- range(df$Result, na.rm = TRUE)
  cuts <- seq(rng[1], rng[2], length.out = 6)   # 5 intervals
  colors <- pal(seq(rng[1], rng[2], length.out = 6))

  DT::datatable(
    dplyr::select(df, Site, Result, SiteDescription) |>
    dplyr::arrange(desc(Result)),
    rownames = FALSE,
    selection = "multiple",
    options = list(
      scrollX = TRUE,
      pageLength = 50,
      dom = 'T',
      scrollY = "calc(35vh - 100px)",
      paging = TRUE,
      autoWidth = TRUE,
      responsive = TRUE
    )
  ) |>
    DT::formatStyle(
      columns = c("Site", "Result", "SiteDescription"),
      color = DT::styleInterval(cuts[-length(cuts)], colors)
    )
})
observeEvent(input$map_dt_rows_selected, 
  { df <- dat_filt() 
    df <-  df |> dplyr::arrange(desc(Result))
    selected_sites <- df$Site[input$map_dt_rows_selected] 
    selected_sites <- selected_sites
    map_selection$sites <- selected_sites },
        ignoreNULL = FALSE
  )
      }
      })
  })
}