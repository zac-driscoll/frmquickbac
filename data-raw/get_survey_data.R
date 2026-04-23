
query <- "  
  SELECT 
	a.SAMPLE_SID SampleSID,
	a.SURVEY_NUM SurveyNum,
	a.COLLECTION_DATE [Date],
	YEAR(a.COLLECTION_DATE) [Year], 
	CAST(a.COLLECTION_DATE AS datetime) + CAST(a.COLLECTION_TIME AS datetime)  [DateTime],
	a.SITECODE SiteCode,
	RIGHT(a.SITE_CODE,1) Depth,
	c.OP_NAME Parameter,
	c.LABEL_NAME LabelName,
	d.WaterBody,
  d.SiteDescription,
  d.InactiveDate,
  d.Latitude,
  d.Longitude,
  d.SiteType,
	a.ReadingNum,
	a.ReadingVal,
	a.RESULT_FLAG ResultFlag,
	a.ReadingRaw,
	a.UNIT_OF_MEASURE_NAME Units,
	a.LOQ,
	a.MDL,
	e.[Precip72Hr],
  e.[HoursDry],
	a.QA_CODE_DESCRIPTION QADescription
FROM [dbo].[fFreshwaterMonitoringDetailOpSID_UOM](NULL, '2014-01-01', '2025-12-31',0,0,1,0) a
LEFT JOIN SOURCE_CODE b ON a.SOURCE_CODE_SID = b.SOURCE_CODE_SID
LEFT JOIN dbo.OPERATION c ON a.OP_SID = c.OP_SID 
LEFT JOIN [MMSD].[FreshwaterMonitoring].[Main].[Sites] d ON a.SiteCode = d.[Site]
LEFT JOIN [MMSD].[FreshwaterMonitoring].[SampleReview].[SurveySites] e ON a.SURVEY_NUM = e.SURVEY_NUM AND a.SITECODE = e.SITE_CODE
WHERE a.OP_SID IN (182, 213, 880) AND a.SOURCE_CODE_SID IN (1004, 992, 901) AND 	RIGHT(a.SITE_CODE,1) = 'S'
"

dat <- mmsd.sql::pass_query(query, database = 'LIMS')
dat <- 
	dat |> 
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
	dat |>
	dplyr::group_by(Watershed, Date, LabelName) |>
	dplyr::summarise(max_val = max(ReadingNum, na.rm = TRUE)) |>
	dplyr::collect()


#add weather station by survey used to get 72-hr precip
query <- 
	"WITH ranked AS (
    SELECT
        SiteLocationCode,
        PrecipVarID,
        Weight,
        Effective,
        ROW_NUMBER() OVER (
            PARTITION BY SiteLocationCode, Effective
            ORDER BY Weight DESC
        ) AS rn
    FROM [FreshwaterMonitoring].[SampleReview].[SitePrecipStations]
    WHERE Inactive IS NULL
)
SELECT
    SiteLocationCode,
    Effective,
    PrecipVarID,
    Weight AS MaxWeight
FROM ranked
WHERE rn = 1
ORDER BY SiteLocationCode, Effective;"

mmsd.sql::pass_query(query = query, database = "freshwater")
arrow::write_parquet(dat, "inst/extdata/survey_dat.parquet")
usethis::use_data(max_values, overwrite = TRUE)



query <- "
WITH winner AS (
    SELECT
        SiteLocationCode,
        Effective,
        PrecipVarID,
        Weight AS MaxWeight,
        ROW_NUMBER() OVER (
            PARTITION BY SiteLocationCode, Effective
            ORDER BY Weight DESC
        ) AS rn
    FROM [MMSD].[FreshwaterMonitoring].[SampleReview].[SitePrecipStations]
    WHERE Inactive IS NULL
),
winner_one AS (
    SELECT
        SiteLocationCode,
        Effective,
        PrecipVarID,
        MaxWeight
    FROM winner
    WHERE rn = 1
)
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
    a.QA_CODE_DESCRIPTION AS QADescription,
    wx.PrecipVarID AS VARID,
    wx.MaxWeight   AS PrecipStationWeight,
    wx.Effective   AS PrecipStationEffective

FROM [dbo].[fFreshwaterMonitoringDetailOpSID_UOM](NULL, '2014-01-01', '2025-12-31', 0, 0, 1, 0) a
LEFT JOIN SOURCE_CODE b ON a.SOURCE_CODE_SID = b.SOURCE_CODE_SID
LEFT JOIN dbo.OPERATION c ON a.OP_SID = c.OP_SID
LEFT JOIN [MMSD].[FreshwaterMonitoring].[Main].[Sites] d ON a.SiteCode = d.[Site]
LEFT JOIN [MMSD].[FreshwaterMonitoring].[SampleReview].[SurveySites] e
    ON a.SURVEY_NUM = e.SURVEY_NUM AND a.SITECODE = e.SITE_CODE

OUTER APPLY (
    SELECT TOP (1)
        w.PrecipVarID,
        w.MaxWeight,
        w.Effective
    FROM winner_one w
    WHERE w.SiteLocationCode = a.SITECODE
      AND w.Effective <= (CAST(a.COLLECTION_DATE AS datetime) + CAST(a.COLLECTION_TIME AS datetime))
    ORDER BY w.Effective DESC
) wx

WHERE a.OP_SID IN (182, 213, 880)
  AND a.SOURCE_CODE_SID IN (1004, 992, 901)
  AND RIGHT(a.SITE_CODE, 1) = 'S';
"

dat2 <- mmsd.sql::pass_query(query = query, database = "LIMS")
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

precip_vars <-
	dat2 |> 
	dplyr::select(VARID) |>
	dplyr::distinct() |>
	dplyr::filter(!is.na(VARID)) |>
    dplyr::pull()
	

query <- paste("SELECT VARNUM, VARID, NAME, SHORTNAME, Description FROM [OPSCONV].[dbo].[VARDESC] WHERE varid IN", mmsd.sql::format_for_sql(precip_vars))
ws_stations <- mmsd.sql::pass_query(query = query, database = "wims_cv")
ws_stations <- dplyr::mutate(ws_stations, WeatherStation = gsub("_PrecipHr|_PrecHr","", SHORTNAME))

query <- paste(
	"SELECT [SiteCode] WeatherStation, [Lat], [Long] FROM [dbo].[vSitesWGS84] WHERE SiteCode IN",
	mmsd.sql::format_for_sql(ws_stations$WeatherStation))

wsWGS84 <- mmsd.sql::pass_query(query = query, database = "sm")
ws_lookup <- 
    ws_stations |> 
    dplyr::left_join(wsWGS84) |>
    dplyr::mutate(Description = stringr::str_replace(Description, "- MMSD", ""))

dat2 <- dplyr::left_join(dat2, ws_lookup  |> dplyr::select(VARID, WeatherStation)) 
arrow::write_parquet(dat2, "inst/extdata/survey_dat.parquet")
usethis::use_data(max_values, ws_lookup, overwrite = TRUE)
