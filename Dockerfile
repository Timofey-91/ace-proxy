FROM wafy80/acestream

# Устанавливаем nginx
RUN apt-get update && apt-get install -y nginx

# Копируем конфиг nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Копируем скрипт запуска
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Открываем порты
EXPOSE 80

# Запускаем
CMD ["/start.sh"]
