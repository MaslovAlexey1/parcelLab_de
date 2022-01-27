CREATE TABLE "holidays_raw" (
  "id" SERIAL PRIMARY KEY,
  "country_code" varchar(2),
  "holidays_json" json,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE INDEX holidays_raw_country_code_idx ON public.holidays_raw (country_code);
CREATE INDEX holidays_raw_updated_at_idx ON public.holidays_raw (updated_at);


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


CREATE TABLE "weather_raw" (
  "id" SERIAL PRIMARY KEY,
  "city" varchar,
  "weather_json" json,
  "created_at" timestamp NOT NULL,
  "updated_at" timestamp NOT NULL
);

CREATE INDEX weather_raw_updated_at_idx ON public.weather_raw (updated_at);

CREATE VIEW vw_city_weather as
WITH weather_raw_rn AS (
     SELECT wr.id,
        wr.weather_json,
        row_number() OVER (PARTITION BY wr.weather_json -> 'sys' ->> 'country', wr.weather_json ->> 'name'  ORDER BY wr.updated_at DESC) AS rn,
        wr.created_at,
        wr.updated_at
       FROM weather_raw wr
      WHERE (wr.weather_json ->> 'cod'::text) = '200'::text
    ),
 city_weather_json AS (
	 SELECT
		concat(wrr.weather_json ->> 'name', ',', wrr.weather_json -> 'sys' ->> 'country') AS city,
		wrr.weather_json->'coord' AS coord,
		wrr.weather_json->'weather'->>0 AS weather,
		wrr.weather_json->'main' AS main,
		wrr.weather_json->'visibility' AS visibility,
		wrr.weather_json->'wind' AS wind,
		wrr.weather_json->'clouds' AS clouds,
		wrr.created_at,
		wrr.updated_at
	FROM
		weather_raw_rn wrr
	WHERE
		rn = 1)
SELECT 
cwj.city,
cwj.main->'temp' AS temp,
cwj.main->'feels_like' AS temp_feels_like,
cwj.main->'temp_min' AS temp_min,
cwj.main->'temp_max' AS temp_max,
cwj.main->'pressure' AS pressure,
cwj.main->'humidity' AS humidity,
cwj.visibility,
cwj.wind->'speed' AS wind_speed,
cwj.created_at,
cwj.updated_at
FROM city_weather_json cwj
;