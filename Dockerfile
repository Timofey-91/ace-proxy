FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget curl python3 python3-flask python3-requests libssl1.1 libffi7 \
    && rm -rf /var/lib/apt/lists/*

# --- AceStream Engine (ValdikSS build) ---
RUN mkdir -p /opt/acestream && \
    cd /opt/acestream && \
    wget -q https://github.com/ValdikSS/acestream-linux/releases/download/3.1.74/acestream-engine_3.1.74_debian_11_amd64.tar.gz -O acestream.tar.gz && \
    tar -xzf acestream.tar.gz && \
    rm acestream.tar.gz && \
    chmod +x /opt/acestream/start-engine

# --- Flask proxy ---
WORKDIR /app
COPY app.py /app/app.py

EXPOSE 6878 10000

CMD bash -c "/opt/acestream/start-engine --client-console & python3 /app/app.py"
