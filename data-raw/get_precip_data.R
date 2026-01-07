library(mmsd.sql)

query <- 
"SELECT 
  YEAR(DATESTAMP) [Year],
	DATESTAMP [Date],
	CURVALUE [ReadingNum],
	Variable = 'Daily Precip'
FROM
DATATBL WHERE VARID IN (SELECT VARID FROM VARDESC WHERE VARNUM = 26262)"

precip_data <- pass_query(query = query, database = "wims_cv")

usethis::use_data(precip_data,overwrite = TRUE)
