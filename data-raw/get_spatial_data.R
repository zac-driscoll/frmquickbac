#get_survey_data needs to be run first to create ws_lookup 


url <- "https://services5.arcgis.com/Ul9AyFFeFTjf08DW/arcgis/rest/services/EN_WBD_HUC10_AR_VAR_gdb/FeatureServer/0"

mke_basin_sf <- arcpullr::get_spatial_layer(
  url = url,
  where = "HUC10_CODE IN ('0404000304', '0404000305', '0404000306', '0404000303')"
)

# Force/repair geometry column once, right after import
geom_col <- attr(mke_basin_sf, "sf_column")
if (is.null(geom_col) || !geom_col %in% names(mke_basin_sf)) {
  sfc_cols <- names(mke_basin_sf)[vapply(mke_basin_sf, inherits, logical(1), "sfc")]
  geom_col <- sfc_cols[1]
}
sf::st_geometry(mke_basin_sf) <- geom_col

# Now mutate safely
mke_basin_sf <- mke_basin_sf |>
  dplyr::mutate(
    HUC10_NAME = dplyr::if_else(
      grepl("Milwaukee", HUC10_NAME),
      "Lower Milwaukee River",
      HUC10_NAME
    )
  )


url <- "https://dnrmaps.wi.gov/arcgis2/rest/services/TS_AGOL_STAGING_SERVICES/EN_AGOL_STAGING_SurfaceWater_WTM/MapServer/2"

hydro1 <- arcpullr::get_layer_by_poly(url, mke_basin_sf[,1])
hydro2 <- arcpullr::get_layer_by_poly(url, mke_basin_sf[,2])
hydro3 <- arcpullr::get_layer_by_poly(url, mke_basin_sf[,3])
hydro4 <- arcpullr::get_layer_by_poly(url, mke_basin_sf[,4])

mke_rivers <- rbind(hydro1,hydro2,hydro3,hydro4)
mke_rivers_sf <- 
  dplyr::filter(mke_rivers, STREAM_ORDER > 2) |>
dplyr::select(RIVER_SYS_WBIC, RIVER_SYS_NAME, ROW_NAME, STREAM_ORDER, geoms) |>
  sf::st_join(
  mke_basin_sf["HUC10_NAME"],   # only bring the watershed name column
  join = sf::st_within,
  left = TRUE
)

#ws lookup - assign hucs
if(!exists("ws_lookup")){
stop("Run get_survey_data to init ws_lookup before running this code!")
}
ws_lookup_sf <-
  ws_lookup |>
  sf::st_as_sf(coords = c("Long", "Lat"), crs = 4326) |>
  sf::st_join(
  mke_basin_sf["HUC10_NAME"],   # only bring the watershed name column
  join = sf::st_within,
  left = TRUE)


usethis::use_data(mke_rivers_sf,overwrite = TRUE)
usethis::use_data(mke_basin_sf,overwrite = TRUE)
usethis::use_data(ws_lookup_sf,overwrite = TRUE)




