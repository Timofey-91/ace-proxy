from flask import Flask, request, jsonify, Response
import requests
import time
import logging

# Настройка логирования
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
ACESTREAM_API = "http://127.0.0.1:6878"

def wait_for_acestream():
    """Ждать запуска AceStream"""
    logger.info("Waiting for AceStream engine to start...")
    for i in range(30):
        try:
            response = requests.get(f"{ACESTREAM_API}/server/api", timeout=5)
            if response.status_code == 200:
                logger.info("✓ AceStream engine is ready!")
                return True
        except Exception as e:
            logger.info(f"⏳ Attempt {i+1}/30: AceStream not ready yet...")
            time.sleep(2)
    logger.error("❌ Failed to connect to AceStream engine")
    return False

@app.route('/ace/getstream', methods=['GET'])
def get_stream():
    """Получить стрим по infohash"""
    infohash = request.args.get('infohash')
    
    if not infohash:
        return jsonify({'error': 'Missing infohash parameter'}), 400
    
    if len(infohash) != 40:
        return jsonify({'error': 'Invalid infohash format'}), 400
    
    logger.info(f"Requested stream for infohash: {infohash}")
    
    try:
        # Пробуем запустить стрим через AceStream API
        response = requests.get(
            f"{ACESTREAM_API}/ace/getstream",
            params={'infohash': infohash},
            timeout=30
        )
        
        if response.status_code == 200:
            stream_url = f"http://{request.host}/ace/play/{infohash}"
            logger.info(f"Stream started successfully: {stream_url}")
            
            return jsonify({
                'status': 'success',
                'infohash': infohash,
                'stream_url': stream_url,
                'acestream_url': f"acestream://{infohash}",
                'direct_url': f"{ACESTREAM_API}/ace/getstream?infohash={infohash}"
            })
        else:
            logger.error(f"AceStream API returned status: {response.status_code}")
            return jsonify({
                'error': 'Failed to start stream',
                'acestream_status': response.status_code
            }), 500
            
    except requests.exceptions.Timeout:
        logger.error("AceStream API timeout")
        return jsonify({'error': 'AceStream engine timeout'}), 500
    except Exception as e:
        logger.error(f"AceStream API error: {str(e)}")
        return jsonify({'error': f'Internal server error: {str(e)}'}), 500

@app.route('/ace/play/<infohash>')
def play_stream(infohash):
    """Прокси для воспроизведения стрима"""
    logger.info(f"Stream playback requested: {infohash}")
    
    try:
        # Проксируем запрос к AceStream
        acestream_url = f"{ACESTREAM_API}/ace/getstream?infohash={infohash}"
        response = requests.get(acestream_url, stream=True, timeout=60)
        
        logger.info(f"Stream proxy status: {response.status_code}")
        
        return Response(
            response.iter_content(chunk_size=8192),
            content_type=response.headers.get('Content-Type', 'video/mp4'),
            status=response.status_code
        )
    except Exception as e:
        logger.error(f"Stream proxy error: {str(e)}")
        return jsonify({'error': f'Stream proxy failed: {str(e)}'}), 500

@app.route('/health')
def health():
    """Проверка здоровья сервиса"""
    try:
        response = requests.get(f"{ACESTREAM_API}/server/api", timeout=5)
        return jsonify({
            'status': 'healthy',
            'acestream': 'running',
            'timestamp': time.time()
        })
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'acestream': 'not responding',
            'error': str(e)
        }), 500

@app.route('/')
def home():
    """Главная страница с информацией о API"""
    return jsonify({
        'service': 'AceStream HTTP Proxy',
        'version': '1.0',
        'endpoints': {
            'get_stream': '/ace/getstream?infohash=YOUR_INFOHASH',
            'play_stream': '/ace/play/INFOHASH',
            'health_check': '/health'
        },
        'example': {
            'url': 'http://' + request.host + '/ace/getstream?infohash=ac1af534d9413abee090607cd87954d964d2fd91',
            'description': 'Get stream URL for infohash'
        }
    })

if __name__ == '__main__':
    logger.info("🚀 Starting AceStream HTTP Proxy...")
    if wait_for_acestream():
        logger.info("🌐 Starting web server on port 8000")
        app.run(host='0.0.0.0', port=8000, debug=False)
    else:
        logger.error("💥 Failed to start: AceStream engine not available")
