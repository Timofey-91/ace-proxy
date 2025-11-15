FROM trexx/docker-acestream-engine:3.2.11-py3.10

# Устанавливаем Python зависимости для API
RUN pip install flask flask-cors requests

# Создаем директорию для приложения
WORKDIR /app

# Копируем API сервер
COPY api_server.py .

# Открываем порты
EXPOSE 8000 6878 8621

# Запускаем AceStream Engine и наш API сервер
CMD ace-stream --live-cache-type memory --live-cache-size 2048 --stats-report-interval 1 & \
    python api_server.py
