import sys
import requests
import datetime
import psycopg2
import json
import os

def get_city_weather(city):
    """Returns last available weather for city from database.

    Args:
        city (string): City name and country code divided by comma. Please, refer to ISO 3166 for the country codes.

    Returns:
        string: Current weather information divided by comma in metric format:

        * temp (float): Temperature. Celsius.
        * temp_feels_like (float): Temperature. This temperature parameter accounts for the human perception of weather. Celsius.
        * temp_min (float): Minimum temperature at the moment. This is minimal currently observed temperature. Celsius.
        * temp_max (float): Maximum temperature at the moment. This is maximal currently observed temperature. Celsius.
        * pressure (int): Atmospheric pressure, hPa.
        * humidity (float): Humidity, %.
        * visibility (int): Visibility, meter.
        * wind_speed (float): Wind speed. meter/sec.
    
    Example:
        -0.46    -0.46    -3.55    0.55    1034    92    10000    0.89
    """
    sql = """   SELECT 
                    temp,
                    temp_feels_like,
                    temp_min,
                    temp_max,
                    pressure,
                    humidity,
                    visibility,
                    wind_speed
                FROM vw_city_weather vcw 
                WHERE city = '{}'
                """
    conn = None
    try:
        conn = psycopg2.connect(
            host="postgres",
            port="5432",
            # host="localhost",
            # port="5438",
            database="postgres",
            user="postgres",
            password="postgres")
        cur = conn.cursor()
        cur.execute(sql.format(city))
        row = cur.fetchone()

        while row is not None:
            result_weather = '  '.join(map(str, row))
            print(result_weather)
            with open('/code/app/log/weather.txt', 'a') as the_file:
                the_file.write(result_weather+'\n')
            row = cur.fetchone()

        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print("{} weather - {}".format(city, error))
    finally:
        if conn is not None:
            conn.close()

if __name__== "__main__":
    get_city_weather(sys.argv[1])
