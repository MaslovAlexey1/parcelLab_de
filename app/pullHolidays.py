import sys
import requests
import datetime
import psycopg2
import json
import os
from config import config

HOLIDAYS_TOKEN = os.environ.get('HOLIDAYS_TOKEN')

def pull_holidays(contry_codes):
    for country_code in contry_codes.split(','):
        pull_country_holidays(country_code)

def pull_country_holidays(country_code):
    now = datetime.datetime.now()
    year = str(now.year-1) # Free accounts are limited to last year's historical data only.
    req = "https://holidayapi.com/v1/holidays?pretty&key="+HOLIDAYS_TOKEN+"&country="+country_code+"&year="+year
    response = requests.get(req)
    
    insert_raw_holidays(country_code, response.json())
    # print(response.json())

def insert_raw_holidays(country_code, holidays_json):
    sql = """ insert into holidays_raw(country_code, holidays_json, created_at, updated_at) values(%s, %s, %s, %s)  """
    conn = None
    try:
        params = config()
        conn = psycopg2.connect(**params)
        cur = conn.cursor()
        cur.execute(sql, (country_code, 
                        json.dumps(holidays_json), 
                        datetime.datetime.now(), 
                        datetime.datetime.now()))

        conn.commit()
        cur.close()
        print("{} holidays loaded".format(country_code))
    except (Exception, psycopg2.DatabaseError) as error:
        print("{} holidays - {}".format(country_code,error))
    finally:
        if conn is not None:
            conn.close()

if __name__== "__main__":
    pull_holidays(sys.argv[1])
