# syntax=docker/dockerfile:1
FROM python:3.8.0-alpine
WORKDIR /code
RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev busybox-initscripts
RUN apk add openrc --no-cache

COPY app/cronjob /etc/crontabs/root


COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . .

ENV HOLIDAYS_TOKEN 3c2dee44-7400-4606-9858-a904a4f9478a
ENV WEATHER_TOKEN 0ac84f4682ea563162493332e47110d8

CMD ["/bin/sh", "-c", "crond && tail -f /dev/null"]
