import sys
import requests
import datetime
import psycopg2
import json
import os
from config import config

WEATHER_TOKEN = os.environ.get('WEATHER_TOKEN')

def pull_weather(cities):
    for city in cities.split(';'):
        pull_city_weather(city)

def pull_city_weather(city):
    req = "https://api.openweathermap.org/data/2.5/weather?q="+city+"&units=metric&appid="+WEATHER_TOKEN
    response = requests.get(req)
    insert_raw_weather(city, response.json())
    # print(response.json())

def insert_raw_weather(city, weather_json):
    sql = """ insert into weather_raw(city, weather_json, created_at, updated_at) values(%s, %s, %s, %s)  """
    conn = None
    try:
        params = config()
        conn = psycopg2.connect(**params)
        cur = conn.cursor()
        cur.execute(sql, (city, 
                        json.dumps(weather_json), 
                        datetime.datetime.now(), 
                        datetime.datetime.now()))

        conn.commit()
        cur.close()
        print("{} weather loaded".format(city))
    except (Exception, psycopg2.DatabaseError) as error:
        print("{} weather - {}".format(city, error))
    finally:
        if conn is not None:
            conn.close()

if __name__== "__main__":
    pull_weather(sys.argv[1])
