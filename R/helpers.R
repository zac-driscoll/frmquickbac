load_parquet_dataset <- function(filename) {
  data_dir <- Sys.getenv("FRMQUICKBAC_DATA_DIR", unset = "")
  path <- paste0("data/", filename)
#
#   if (nzchar(data_dir)) {
#     path <- file.path(data_dir, filename)
#   } else {
#     path <- system.file("extdata", filename, package = "FRMQuickBac")
#
#     if (path == "") {
#       path <- file.path("inst", "extdata", filename)
#     }
#   }
#
#   if (!file.exists(path)) {
#     stop("Could not find file: ", filename, " at: ", path, call. = FALSE)
#   }

  arrow::open_dataset(path)
}

load_survey_data <- function() {
  load_parquet_dataset("survey_dat.parquet")
}

load_precip_data <- function() {
  load_parquet_dataset("precip_data.parquet")
}




custom_theme <- function() {
  ggplot2::theme_minimal(base_size = 20) +
    ggplot2::theme(
      # Plot background (outer area)
      plot.background = ggplot2::element_rect(
        fill = "#F1F9FF",
        color = "#A9CCE3",
        linewidth = 1,
        linetype = 'solid'
      ),

      # Panel background (the plotting area itself)
      panel.background = ggplot2::element_rect(
        fill = "#E6ECF4",
        color = "#A9CCE3",
        linewidth = 1
      ),

      # Add a visible border around the panel
      panel.border = ggplot2::element_rect(
        color = "#A9CCE3",
        fill = NA,
        linewidth = 1
      ),

      # Grid Lines
      panel.grid.major = ggplot2::element_line(color = "#C0C7CD"),
      panel.grid.minor = ggplot2::element_line(color = "#E5E9ED"),

      # Axes
      axis.text = ggplot2::element_text(color = "#064789"),
      axis.title = ggplot2::element_text(color = "#0A2B43", size = 17, face = "bold"),
      axis.line = ggplot2::element_line(color = "#0A2B43"),

      # Legend
      legend.position = "none",

      # Titles
      plot.title = ggplot2::element_text(
        color = "#0A2B43",
        face = "bold",
        size = 22,
        hjust = 0.5
      ),
      plot.caption = ggplot2::element_text(color = "#345A88", size = 10),

      # Strip (for facets)
      strip.background = ggplot2::element_rect(
        fill = "#96AEC7",
        color = "#064789"
      ),
      strip.text = ggplot2::element_text(
        color = "#F1F9FF",
        face = "bold",
        size = 10
      )
    )
}

plot_param <- function(df, label_name) {
if (is.null(df)) {
  ggplot2::ggplot() +
    ggplot2::theme_void() +
    ggplot2::geom_text(
      ggplot2::aes(0.5, 0.5, label = "No data available for this selection"),
      size = 6,
      color = "gray40"
    ) +
    ggplot2::xlim(0, 1) +
    ggplot2::ylim(0, 1)
} else {

  # Ensure we have a valid year
  df <- dplyr::filter(df, LabelName == label_name)
  year <- na.omit(unique(df$Year))[1]
  req(!is.na(year))

  # Date range for limits
  start <- as.Date(paste0(year, "-01-01"))
  end   <- as.Date(paste0(year, "-12-31"))

  # Dynamic label for legend
  year_fac <- paste(year, "Results")
  units <- unique(df$Units)

  # Define month breaks and labels (first of each month)
  month_breaks <- seq(start, end, by = "1 month")
  month_labels <- function(x) format(x, "%b") |> substr(1, 1)


  df <-
    df |>
    dplyr::mutate(
      Color = dplyr::if_else(grepl("Historic",type),"#219E63","#064789"),
      DisplayDate = dplyr::if_else(
        grepl("Historic",type), lubridate::month(Date, label = TRUE),as.character(Date)),
        DisplayDateLabel = dplyr::if_else(grepl("Historic",type),"Month:", "Date:"))


  # Build ggplot and convert to plotly
p <- df |>
  ggplot2::ggplot(
    ggplot2::aes(
      x = Date,
      y = ReadingNum,
      color = type,
      group = 1,
      text = glue::glue("
<b style='font-size:20px; color:{Color};'>{type}</b><br>
<b style='font-size:18px; color:black;'> {DisplayDateLabel} </b> {DisplayDate}<br>
<b style='font-size:18px; color:black;'>Result:</b> {scales::comma(round(ReadingNum, 2))}")
    )
  ) +
  ggplot2::geom_line(linewidth = 1.1)+
  ggplot2::labs(x = "", y = units, title = label_name) +
  ggplot2::scale_x_date(
    limits = c(start, end),
    breaks = month_breaks,
    labels = month_labels,
    expand = c(0.01, 0.01)
  ) +
  ggplot2::scale_y_continuous(
    labels = scales::comma,
    expand = ggplot2::expansion(mult = c(0.1, 0.1))
  ) +
  ggplot2::scale_color_manual(
    values = setNames(
      c("#064789", "#219E63"),
      c(year_fac, "Historic Monthly Average")
    )
  ) +
  custom_theme()

# Add points only when not Precip
if (!grepl("Precip", label_name)) {
  p <- p + ggplot2::geom_point(size = 3)
}

plotly::ggplotly(p, tooltip = "text") |>
  plotly::layout(
    margin = list(l = 40, r = 50, t = 60, b = 10),
    hoverlabel = list(
      bgcolor = "white",
      font = list(size = 16, color = "black"),
      bordercolor = "#A9CCE3"
    )
  )
}
}

# utils-template.R
get_template_path <- function(file_name) {
  # Try installed path first
  pkg_path <- system.file("app/templates", package = "FRMQuickBac")

  if (nzchar(pkg_path)) {
    full_path <- file.path(pkg_path, file_name)
    if (file.exists(full_path)) return(full_path)
  }

  # Fallback: development mode (when using devtools::load_all())
  dev_path <- file.path("inst/app/templates", file_name)
  if (file.exists(dev_path)) return(dev_path)

  stop(glue::glue("Template file '{file_name}' not found in either installed or dev paths."))
}

render_template <- function(name, ...) {
  path <- get_template_path(paste0(name, ".html"))
  args <- list(...)
  content <- readr::read_file(path)
  glue::glue(content, .envir = list2env(args, parent = environment()))
}


#build leaflet legend
build_leaflet_legend <- function(watersheds) {

  # palette
  watershed_levels <- c(
    "Cedar Creek",
    "Menomonee River",
    "Kinnickinnic River",
    "Lower Milwaukee River"
  )

  pal2 <- leaflet::colorFactor(
    palette = "viridis",
    domain  = watershed_levels
  )

  # ---- shared styles ----
  item_style <- "
    display:flex;
    align-items:center;
    gap:10px;
    margin:4px 0;
  "

  label_style <- "
    font-weight:600;
    line-height:1.2;
  "

  swatch_base <- "
    width:16px;
    height:16px;
    display:inline-block;
    flex-shrink:0;
    font-size:0.7rem;
  "

  section_title <- function(txt) {
    glue::glue("
      <div style='
        margin-top:10px;
        margin-bottom:4px;
        font-size:0.7rem;
        font-weight:700;
        text-transform:uppercase;
        letter-spacing:0.04em;
        color:#345A88;
      '>{txt}</div>
    ")
  }

  # ---- watershed items ----
  watershed_items <- purrr::map2_chr(
    watershed_levels,
    pal2(watershed_levels),
    ~ glue::glue("
      <div style='{item_style}'>
        <span style='
          {swatch_base}
          background:{.y};
          border-radius:3px;
        '></span>
        <span style='{label_style}'>{.x}</span>
      </div>
    ")
  ) |> paste(collapse = "")

  # ---- weather stations ----
  weather_station <- glue::glue("
    <div style='{item_style}'>
      <span style='
        {swatch_base}
        background:#979ea8;
        border-radius:50%;
      '></span>
      <span style='{label_style}'>Rain Gauges</span>
    </div>
  ")

  # ---- sample sites ----
  sample_sites <- glue::glue("
    <div style='{item_style}'>
      <span style='
        {swatch_base}
        background:#651010ff;
        border-radius:50%;
      '></span>
      <span style='{label_style}'>Exceeds Standard</span>
    </div>

    <div style='{item_style}'>
      <span style='
        {swatch_base}
        background:#1d0e81ff;
        border-radius:50%;
      '></span>
      <span style='{label_style}'>Meets Standard</span>
    </div>
  ")

  # ---- outer container ----
  legend_html <- glue::glue("
    <div style='
      background: rgba(255,255,255,0.92);
      border: 1px solid #4b7591ff;
      border-radius: 12px;
      padding: 10px 12px;
      font-family: Poppins, Arial, sans-serif;
      font-size: 0.7rem;
      color: #0A2B43;
      min-width: 140px;
    '>

      {section_title('Monitoring Sites')}
      {sample_sites}

      {section_title('Rain Gauges')}
      {weather_station}

      {section_title('Watersheds')}
      {watershed_items}

    </div>
  ")

  legend_html
}



wrangle_download_data <- function(yrs){
        dat <- load_survey_data()
        dat |>
          dplyr::collect() |>
          dplyr::filter(Year %in% yrs) |>
          dplyr::select(SiteCode, LabelName, WaterBody, Date, ReadingVal,  HoursDry, Precip72Hr) |>
          tidyr::pivot_wider(names_from = LabelName, values_from = ReadingVal) |>
          dplyr::relocate(HoursDry, .after = dplyr::last_col()) |>
          dplyr::relocate(Precip72Hr, .after = dplyr::last_col()) |>
          dplyr::select(
            SiteCode,
            WaterBody,
            Date,
            "Dissolved Oxygen (mg/L)" = "Dissolved Oxygen",
            "E. coli (CFU/100mL)" = "E. coli",
            "Fecal Coliform (CFU/100mL)" = "Fecal Coliform",
            HoursDry,
            Precip72Hr)
}
