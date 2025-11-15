FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Установка зависимостей
RUN apt-get update && apt-get install -y \
    wget \
    xz-utils \
    python3 \
    python3-pip \
    libssl1.1 \
    libpython2.7 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Скачиваем и устанавливаем AceStream Engine
RUN wget -O acestream.tar.xz "https://github.com/jonian/acestream-builds/raw/main/acestream_3.1.49_ubuntu_20.04_x86_64.tar.xz" && \
    tar -xf acestream.tar.xz && \
    rm acestream.tar.xz && \
    chmod +x acestreamengine

# Устанавливаем Flask для health checks
RUN pip3 install flask

# Создаем health check endpoint
RUN cat > health.py << 'EOF'
from flask import Flask, jsonify
import requests
import threading
import subprocess
import time
import os

app = Flask(__name__)

class AceStreamManager:
    def __init__(self):
        self.engine_path = "/app/acestreamengine"
        self.port = 6878
        self.process = None
        self.is_running = False
    
    def start_engine(self):
        if not os.path.exists(self.engine_path):
            return False
            
        try:
            self.process = subprocess.Popen([
                self.engine_path,
                "--client-console",
                "--bind-all",
                "--port", str(self.port)
            ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            self.is_running = True
            return True
        except:
            return False

engine_manager = AceStreamManager()

@app.route('/health')
def health():
    engine_status = "running" if engine_manager.is_running else "stopped"
    engine_available = os.path.exists(engine_manager.engine_path)
    
    return jsonify({
        'status': 'healthy',
        'engine_available': engine_available,
        'engine_running': engine_manager.is_running,
        'engine_port': engine_manager.port,
        'service': 'AceStream Engine Backend'
    })

@app.route('/')
def home():
    return jsonify({
        'service': 'AceStream Engine Backend',
        'endpoints': {
            'health': '/health',
            'engine_api': 'http://your-render-url.onrender.com:6878'
        }
    })

if __name__ == '__main__':
    # Запускаем engine в фоне
    print("🚀 Starting AceStream Engine on Render...")
    if engine_manager.start_engine():
        print("✅ AceStream Engine started successfully")
    else:
        print("❌ Failed to start AceStream Engine")
    
    app.run(host='0.0.0.0', port=5000)
EOF

# Открываем порты
# 5000 - для health checks
# 6878 - для AceStream Engine
EXPOSE 5000 6878

# Запускаем health check сервер
CMD ["python3", "health.py"]
