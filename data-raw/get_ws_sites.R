ws_daily_vars <- tribble(
  ~varnum, ~varid, ~station_id,
  26400, 27872, "WS1201",
  26401, 27873, "WS1202",
  26402, 27874, "WS1203",
  26403, 27875, "WS1204",
  26404, 27876, "WS1206",
  26405, 27877, "WS1207",
  26406, 27878, "WS1209",
  26407, 27879, "WS1211",
  26408, 27880, "WS1214",
  26409, 27881, "WS1216",
  26410, 27882, "WS1218",
  26411, 27883, "WS1220",
  26412, 27884, "WS1221",
  26413, 27885, "WS1222",
  26414, 27886, "WS1224",
  26415, 27887, "WS1225",
  26416, 27888, "WS1226",
  26417, 27889, "WS1227",
  26418, 27890, "WS1228",
  26419, 27891, "WS1229",
  26425, 28262, "WS1230"
)


query <- paste(
  "SELECT 
  VARNUM, 
  VARID,
  NAME FROM [OPSCONV].[dbo].[VARDESC] WHERE varid IN", mmsd.sql::format_for_sql(ws_daily_vars$varid))

ws_stations <- mmsd.sql::pass_query(query = query, database = "wims_cv")
ws_stations <- dplyr::mutate(ws_stations, WeatherStation = gsub(" Nearest Neighbor deaccum","", NAME))

query <- paste(
	"SELECT 
      a.[SiteCode] WeatherStation,
      a.[Lat],
      a.[Long],
	    b.Location Description
  FROM [dbo].[vSitesWGS84] a
  LEFT JOIN Sites b on a.SiteID = b.SiteID
  WHERE a.SiteCode IN",
	mmsd.sql::format_for_sql(ws_stations$WeatherStation))

wsWGS84 <- mmsd.sql::pass_query(query = query, database = "sm")
ws_lookup <- ws_stations |> dplyr::left_join(wsWGS84) 

usethis::use_data(ws_lookup, overwrite = TRUE)
