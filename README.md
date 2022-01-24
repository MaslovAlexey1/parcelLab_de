# parcelLab DE position
[Task Data Engineer](https://parcellab.notion.site/Task-Data-Engineer-b38c3fe6c6f14881b10fcd5bdf57bc2f)

## Data sources
* [holidayapi.com for holidays](https://holidayapi.com)
* [openweathermap.org for weather](https://openweathermap.org)

## Stack
* Python
* Postgres
* Docker compose
* Github 


## How to start
```sh
docker compose up -d
```
```sh
docker exec -it app sh
```

## What can we do
* extract GB holidays from holidayapi.com and load to holidays_raw postgres table
```sh
python pullHolidays.py GB
```
* extract GB, DE and FR holidays from holidayapi.com and load to holidays_raw postgres table
```sh
python pullHolidays.py GB,DE,FR
```
* extract London,GB current weather from openweathermap.org and load to weather_raw postgres table
```sh
python pullWeather.py London,GB
```
* extract London,GB, Paris,FR and Munich,DE current weather from openweathermap.org and load to weather_raw postgres table
```sh
python pullWeather.py 'London,GB;Paris,FR;Munich,DE'
```
* get the last available weather from postgres for Munich,DE
```sh
python getWeather.py Munich,DE
```


## Cron
Cron is already started with jobs:
```sh
*       *       *       *       *       /usr/local/bin/python /code/app/pullWeather.py "Munich,DE;London,GB;Paris,FR"
*       *       *       *       *       /usr/local/bin/python /code/app/pullHolidays.py "DE,GB,FR,RU,IT"
*       *       *       *       *       /usr/local/bin/python /code/app/getWeather.py "Munich,DE"
```

Check result of last job:
```sh
tail -f /code/app/log/weather.txt 
```

