from flask import Flask, jsonify, request, Response
import requests
import time
import threading
from datetime import datetime

app = Flask(__name__)

# AceStream Engine API endpoints
ACE_API_BASE = "http://localhost:6878"
ACE_API_STREAM = f"{ACE_API_BASE}/ace/getstream"
ACE_API_STATS = f"{ACE_API_BASE}/server/api"

# Хранилище активных стримов
active_streams = {}

def check_stream_status(infohash):
    """Проверяет статус стрима в фоне"""
    while infohash in active_streams:
        try:
            response = requests.get(f"{ACE_API_STATS}?method=get_stream_info&infohash={infohash}")
            if response.status_code == 200:
                data = response.json()
                active_streams[infohash]['status'] = data.get('status', 'unknown')
                active_streams[infohash]['last_update'] = datetime.now().isoformat()
            
            # Ждем 10 секунд перед следующей проверкой
            time.sleep(10)
        except:
            active_streams[infohash]['status'] = 'error'
            break

@app.route('/health')
def health():
    """Health check endpoint"""
    return jsonify({"status": "healthy", "service": "acestream-backend"})

@app.route('/api/stream/<infohash>')
def start_stream(infohash):
    """Запускает стрим по infohash"""
    try:
        # Запускаем стрим в AceStream Engine
        stream_url = f"{ACE_API_STREAM}?infohash={infohash}"
        response = requests.get(stream_url, timeout=30)
        
        if response.status_code == 200:
            # Регистрируем активный стрим
            active_streams[infohash] = {
                'started_at': datetime.now().isoformat(),
                'status': 'starting',
                'stream_url': f"http://localhost:6878/ace/stream/{infohash}"
            }
            
            # Запускаем мониторинг статуса в отдельном потоке
            thread = threading.Thread(target=check_stream_status, args=(infohash,))
            thread.daemon = True
            thread.start()
            
            return jsonify({
                "success": True,
                "infohash": infohash,
                "stream_url": f"/proxy/stream/{infohash}",
                "status": "starting"
            })
        else:
            return jsonify({
                "success": False,
                "error": f"AceStream engine returned status {response.status_code}"
            }), 500
            
    except Exception as e:
        return jsonify({
            "success": False,
            "error": str(e)
        }), 500

@app.route('/api/status/<infohash>')
def stream_status(infohash):
    """Возвращает статус стрима"""
    if infohash in active_streams:
        return jsonify(active_streams[infohash])
    else:
        return jsonify({"error": "Stream not found"}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=False)
