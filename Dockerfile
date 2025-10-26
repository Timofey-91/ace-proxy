# syntax=docker/dockerfile:1
FROM python:3.10-slim

# Устанавливаем нужные пакеты
RUN apt-get update && apt-get install -y wget tar && apt-get clean

# --- Устанавливаем AceStream Engine (ValdikSS mirror) ---
RUN mkdir -p /opt/acestream && \
    cd /opt/acestream && \
    wget -q http://mirror.valdikss.org.ru/acestream/3.1.74/acestream-engine_3.1.74_debian_11_amd64.tar.gz -O acestream.tar.gz && \
    tar -xzf acestream.tar.gz && \
    rm acestream.tar.gz && \
    chmod +x /opt/acestream/start-engine

# --- Копируем Python-приложение ---
WORKDIR /app
COPY app.py /app/app.py

# --- Открываем порт для API ---
EXPOSE 8090

# --- Запуск AceStream и API ---
CMD /opt/acestream/start-engine --client-console --bind-all & \
    python3 /app/app.py
