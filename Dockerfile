# syntax=docker/dockerfile:1
FROM debian:bullseye-slim

# Устанавливаем зависимости
RUN apt-get update && apt-get install -y \
    wget curl python3 python3-flask libssl1.1 libffi7 \
    && rm -rf /var/lib/apt/lists/*

# Скачиваем AceStream Engine (ValdikSS версия)
RUN mkdir -p /opt/acestream && \
    cd /opt/acestream && \
    wget -q https://github.com/ValdikSS/acestream-linux/releases/download/3.1.74/acestream-engine_3.1.74_debian_11_amd64.tar.gz && \
    tar -xzf acestream-engine_3.1.74_debian_11_amd64.tar.gz && \
    rm acestream-engine_3.1.74_debian_11_amd64.tar.gz && \
    chmod +x /opt/acestream/start-engine

# Flask сервер
WORKDIR /app
COPY <<EOF /app/server.py
from flask import Flask, request, jsonify
import subprocess, os

app = Flask(__name__)

@app.route("/ace/getstream")
def getstream():
    stream_id = request.args.get("id")
    if not stream_id:
        return jsonify({"error": "Missing id"}), 400
    cmd = ["/opt/acestream/start-engine", "--client-console", f"acestream://{stream_id}"]
    subprocess.Popen(cmd)
    return jsonify({"message": f"Stream started for {stream_id}"}), 200

@app.route("/")
def index():
    return "AceStream API is running"
EOF

EXPOSE 8090
CMD ["python3", "server.py"]
