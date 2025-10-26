# syntax=docker/dockerfile:1
FROM debian:bullseye-slim

# Устанавливаем системные зависимости
RUN apt-get update && apt-get install -y \
    wget curl python3 python3-flask libssl1.1 libffi7 \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем и распаковываем AceStream Engine (ValdikSS версия)
RUN mkdir -p /opt/acestream && \
    cd /opt/acestream && \
    wget -q https://github.com/ValdikSS/acestream-linux/releases/download/3.1.74/acestream-engine_3.1.74_debian_11_amd64.tar.gz && \
    tar -xzf acestream-engine_3.1.74_debian_11_amd64.tar.gz && \
    rm acestream-engine_3.1.74_debian_11_amd64.tar.gz && \
    chmod +x /opt/acestream/start-engine

# Копируем сервер
WORKDIR /app
COPY server.py /app/server.py

# Порт API
EXPOSE 8090

# Запуск Flask API
CMD ["python3", "server.py"]
