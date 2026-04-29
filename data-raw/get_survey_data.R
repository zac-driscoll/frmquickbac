query <- "
SELECT
    a.SAMPLE_SID AS SampleSID,
    a.SURVEY_NUM AS SurveyNum,
    a.COLLECTION_DATE AS [Date],
    YEAR(a.COLLECTION_DATE) AS [Year],
    CAST(a.COLLECTION_DATE AS datetime) + CAST(a.COLLECTION_TIME AS datetime) AS [DateTime],
    a.SITECODE AS SiteCode,
    RIGHT(a.SITE_CODE, 1) AS Depth,
    c.OP_NAME AS Parameter,
    c.LABEL_NAME AS LabelName,
    d.WaterBody,
    d.SiteDescription,
    d.InactiveDate,
    d.Latitude,
    d.Longitude,
    d.SiteType,
    a.ReadingNum,
    a.ReadingVal,
    a.RESULT_FLAG AS ResultFlag,
    a.ReadingRaw,
    a.UNIT_OF_MEASURE_NAME AS Units,
    a.LOQ,
    a.MDL,
    e.[Precip72Hr],
    e.[HoursDry],
    a.QA_CODE_DESCRIPTION AS QADescription

FROM [dbo].[fFreshwaterMonitoringDetailOpSID_UOM](NULL, '2014-01-01', '2025-12-31', 0, 0, 1, 0) a
LEFT JOIN SOURCE_CODE b ON a.SOURCE_CODE_SID = b.SOURCE_CODE_SID
LEFT JOIN dbo.OPERATION c ON a.OP_SID = c.OP_SID
LEFT JOIN [MMSD].[FreshwaterMonitoring].[Main].[Sites] d 
    ON a.SiteCode = d.[Site]
LEFT JOIN [MMSD].[FreshwaterMonitoring].[SampleReview].[SurveySites] e
    ON a.SURVEY_NUM = e.SURVEY_NUM 
   AND a.SITECODE = e.SITE_CODE

WHERE a.OP_SID IN (182, 213, 880)
  AND a.SOURCE_CODE_SID IN (1004, 992, 901)
  AND RIGHT(a.SITE_CODE, 1) = 'S';
"


dat2 <- mmsd.sql::pass_query(query = query, database = "lims_exc")
dat2 <-
    dat2 |> 
	dplyr::mutate(
		LabelName = 
			dplyr::case_when(
				grepl("DO", LabelName) ~ "Dissolved Oxygen",
				grepl("FCMF", LabelName) ~ "Fecal Coliform",
				grepl("E.coli", LabelName) ~ "E. coli"),
		Date = as.Date(Date),
		Watershed = 
			dplyr::case_when(
				grepl("Menomonee", WaterBody) ~ "Menomonee River",
				grepl("Milwaukee", WaterBody) ~ "Lower Milwaukee River",
				TRUE  ~ WaterBody),
		Precip72Hr = round(Precip72Hr, digits = 2))

max_values <- 
	dat2 |>
	dplyr::group_by(Watershed, Date, LabelName) |>
	dplyr::summarise(max_val = max(ReadingNum, na.rm = TRUE)) |>
	dplyr::collect()




###find_closest_weather_station
dat2_sf <- dat2 |> 
    dplyr::select(SiteCode, Latitude, Longitude) |>
    dplyr::distinct() |>
    sf::st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

nearest_idx <- sf::st_nearest_feature(dat2_sf, ws_lookup_sf)

dat2_nearest_ws <- 
dat2_sf |>
  sf::st_drop_geometry() |> 
  dplyr::mutate(nearest_row = nearest_idx) |>
  dplyr::bind_cols(
    ws_lookup_sf |>
      sf::st_drop_geometry() |>
      dplyr::slice(nearest_idx) |>
      dplyr::select(WeatherStation)
  )  |>
    dplyr::select(-nearest_row)

dat2 <- dplyr::left_join(dat2, dat2_nearest_ws) 

#calc 48 hour precip

    
precip_cum <- 
precip_data_raw |>
  dplyr::rename(WeatherStation = station_id) |> 
  dplyr::arrange(WeatherStation, Date) |>
  dplyr::group_by(WeatherStation) |>
  dplyr::mutate(cum_precip = cumsum(dplyr::coalesce(ReadingNum, 0))) |>
  dplyr::ungroup()

sample_times <- dat2 |>
  dplyr::select(SampleSID, SiteCode, WeatherStation, DateTime) |>
  dplyr::distinct() |>
  dplyr::mutate(prev48 = DateTime - lubridate::hours(48))

library(data.table)

precip_cum_dt <- as.data.table(precip_cum)
sample_times_dt <- as.data.table(sample_times)

sample_times_dt[, end_time := DateTime]
sample_times_dt[, start_time := prev48]

setkey(precip_cum_dt, WeatherStation, Date)

end_cum <- precip_cum_dt[
  sample_times_dt,
  on = .(WeatherStation, Date <= end_time),
  mult = "last"
][
  , .(
    SampleSID,
    SiteCode,
    WeatherStation,
    DateTime,
    end_cum = cum_precip
  )
]

start_cum <- precip_cum_dt[
  sample_times_dt,
  on = .(WeatherStation, Date <= start_time),
  mult = "last"
][
  , .(
    SampleSID,
    start_cum = cum_precip
  )
]



dat48 <- end_cum |>
  dplyr::left_join(start_cum, by = "SampleSID") |>
  dplyr::mutate(
    start_cum = dplyr::coalesce(start_cum, 0),
    precip48 = end_cum - start_cum
  )

dat2 <- dat2 |>
    dplyr::select(-Precip72Hr) |>
    dplyr::left_join( dat48 |> dplyr::select(SampleSID, Precip72Hr = precip48)) |>
    dplyr::mutate(
        Precip72Hr = round(Precip72Hr, digits = 2),
        Time = format(DateTime, "%l:%M %p"))

#save data
arrow::write_parquet(dat2, "inst/extdata/survey_dat.parquet")
usethis::use_data(max_values, overwrite = TRUE)

