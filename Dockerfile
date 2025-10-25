# Берём готовый образ AceStream
FROM wafy80/acestream:latest

# Устанавливаем Python и pip
RUN apt-get update && apt-get install -y python3 python3-pip curl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Устанавливаем зависимости Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем код Flask
COPY app.py .

# Пробрасываем порт Flask
EXPOSE 5000

CMD ["python3", "app.py"]
