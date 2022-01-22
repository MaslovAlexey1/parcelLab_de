CREATE TABLE "holidays_raw" (
  "id" SERIAL PRIMARY KEY,
  "country_code" varchar(2),
  "holidays_json" json,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE VIEW "vw_holidays" as 
WITH holidays_raw_rn AS (
	SELECT 
		id,
		country_code,
		holidays_json,
		ROW_NUMBER() OVER(PARTITION BY country_code
	ORDER BY
		updated_at DESC) rn,
		created_at,
		updated_at 
	FROM
		holidays_raw hr
	WHERE
		holidays_json::json->>'status' = '200'
	),
country_holidays AS (
	SELECT
		country_code,
		json_array_elements(holidays_json::json->'holidays') holiday,
		created_at,
		updated_at 
	FROM
		holidays_raw_rn
	WHERE
		rn = 1),
holidays_stage as(
	SELECT
		country_code,
		holiday::json->>'name' AS name,
		to_date(holiday::json->>'date', 'YYYY-MM-DD') AS date,
    to_date(holiday::json->>'observed', 'YYYY-MM-DD') AS observed,
		CAST(holiday::json->>'public' AS BOOLEAN) AS public,
		CAST(holiday::json->>'uuid' AS UUID) AS uuid,
		created_at,
		updated_at 
	FROM
		country_holidays)
SELECT
  country_code,
  name,
  date,
  observed,
  EXTRACT(YEAR FROM observed) AS observed_year,
  EXTRACT(MONTH FROM observed) AS observed_month_of_year,
  EXTRACT(DAY FROM observed) AS observed_day_of_month,
  EXTRACT(ISODOW FROM observed) AS observed_isodow,
  public,
  uuid,
  created_at,
  updated_at 
FROM holidays_stage
;