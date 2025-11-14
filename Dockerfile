FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Установка системных зависимостей
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    wget \
    xz-utils \
    libssl1.1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/acestream

# Скачать AceStream
RUN wget -O acestream.tar.xz \
    https://github.com/OpenAceStream/acestream-builds/releases/download/3.1.49/acestream-engine_3.1.49_ubuntu_20.04_x86_64.tar.xz

# Распаковать и очистить
RUN tar -xf acestream.tar.xz && rm acestream.tar.xz
RUN chmod +x ./acestreamengine

# Установить Python зависимости
COPY requirements.txt .
RUN pip3 install -r requirements.txt

# Скопировать Python скрипт
COPY app.py .

# Открыть порты
EXPOSE 6878 8000

# Запустить AceStream и веб-сервер
CMD ["sh", "-c", "/opt/acestream/acestreamengine --client-console & python3 /opt/acestream/app.py"]
