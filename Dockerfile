# syntax=docker/dockerfile:1
FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

# Устанавливаем зависимости
RUN apt-get update && apt-get install -y \
    wget curl python3 python3-flask libssl1.1 libffi7 \
    && rm -rf /var/lib/apt/lists/*

# --- AceStream Engine (ValdikSS build) ---
RUN mkdir -p /opt/acestream && \
    cd /opt/acestream && \
    wget -q https://mirror.yandex.ru/mirrors/valdikss/acestream/acestream-engine_3.1.74_debian_11_amd64.tar.gz -O acestream.tar.gz && \
    tar -xzf acestream.tar.gz && \
    rm acestream.tar.gz && \
    chmod +x /opt/acestream/start-engine

# --- TorrServer ---
RUN mkdir -p /opt/torrserver
RUN wget -q https://github.com/YouROK/TorrServer/releases/latest/download/TorrServer-linux-amd64 -O /opt/torrserver/TorrServer && \
    chmod +x /opt/torrserver/TorrServer

# Копируем entrypoint
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 8090 8091 8621 6878

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
