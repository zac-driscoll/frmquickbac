library(fresh)
library(bs4Dash)

bs4DashTheme <- bs4Dash_theme(
  primary   = "#0B85BD",  # mid blue
  secondary = "#219e63",  # green mid
  success   = "#6CBE4B",  # bright green
  info      = "#00A4DB",  # light blue
  warning   = "#D1733D",  # orange accent
  danger    = "#d9534f",  # fallback red

  # Sidebar
  "sidebar-light-bg"    = "#142b41",  # dark navy background
  "sidebar-light-color" = "#E5E9ED",  # light gray text

  # Main content
  "main-bg"    = "#F1F9FF",  # very light blue from JSON
  "body-color" = "#142b41",  # navy text for contrast

  # Cards / Boxes
  "card-bg"    = "#FFFFFF",   # clean white card background
  "info-box-bg"= "#E6ECF4",   # light neutral from JSON
  "white"      = "#FFFFFF",   # ensures consistency

  # Navbar / dark UI elements
  dark = "#143e62",   # deep blue for dark navbar
  "gray-600" = "#C0C7CD"  # light gray accent
)
