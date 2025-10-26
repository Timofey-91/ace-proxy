# syntax=docker/dockerfile:1

FROM python:3.10-slim

WORKDIR /app

COPY app.py /app/

RUN pip install flask gunicorn

EXPOSE 10000

CMD ["gunicorn", "--bind", "0.0.0.0:10000", "app:app"]
