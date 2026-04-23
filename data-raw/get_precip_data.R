library(mmsd.sql)

ws_daily_vars <- 
  tibble::tribble(
    ~varnum, ~varid, ~station_id,
    25862, 16382, "WS1202",
    25882, 16383, "WS1203",
    25902, 16384, "WS1204",
    25962, 16387, "WS1207",
    26002, 16389, "WS1209",
    26032, 16391, "WS1211",
    26082, 16394, "WS1214",
    26152, 16396, "WS1218",
    26212, 16399, "WS1221",
    26257, 16401, "WS1224",
    26277, 18284, "WS1225",
    26307, 20423, "WS1228",
    26317, 26223, "WS1229"
  )

query <- 
paste("SELECT 
  YEAR(DATESTAMP) [Year],
	DATESTAMP [Date],
	CURVALUE [ReadingNum],
	varid
FROM
DATATBL WHERE VARID IN (SELECT VARID FROM VARDESC WHERE VARNUM IN", format_for_sql(ws_daily_vars$varnum), ")")

precip_data <- pass_query(query = query, database = "wims_cv")


precip_dat <- precip_data|> dplyr::left_join(ws_daily_vars)

arrow::write_parquet(precip_dat, "inst/extdata/precip_data.parquet")

