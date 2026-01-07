
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
LEFT JOIN [MMSD].[FreshwaterMonitoring].[Sampl
eReview].[SurveySites] e ON a.SURVEY_NUM = e.SURVEY_NUM AND a.SITECODE = e.SITE_CODE
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

arrow::write_parquet(dat, "inst/extdata/survey_dat.parquet")
usethis::use_data(max_values, overwrite = TRUE)



