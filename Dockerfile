# syntax=docker/dockerfile:1
FROM python:3.8.0-alpine
WORKDIR /code
RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . .

ENV HOLIDAYS_TOKEN 3c2dee44-7400-4606-9858-a904a4f9478a
# CMD ["python", "load_data.py"]
# CMD ["sh"]
ENTRYPOINT ["tail"]
CMD ["-f","/dev/null"]