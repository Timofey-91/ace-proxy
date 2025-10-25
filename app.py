from flask import Flask, request, Response, jsonify, redirect
import requests
import os

app = Flask(__name__)

# AceStream engine внутри контейнера слушает 127.0.0.1:6878
ACESTREAM_URL = os.getenv("ACESTREAM_URL", "http://127.0.0.1:6878")

@app.route("/")
def index():
    return jsonify({"status": "online", "example": "/ace/getstream?infohash=<hash>&.mp4"})

@app.route("/ace/getstream")
def get_stream():
    infohash = request.args.get("infohash")
    if not infohash:
        return jsonify({"error": "missing infohash"}), 400

    # Проксируем поток от AceStream engine
    url = f"{ACESTREAM_URL}/ace/getstream?infohash={infohash}&.mp4"
    try:
        with requests.get(url, stream=True, timeout=10) as r:
            r.raise_for_status()
            return Response(
                r.iter_content(chunk_size=8192),
                content_type=r.headers.get("Content-Type", "video/mp4")
            )
    except Exception as e:
        return jsonify({"error": f"failed to connect to AceStream engine: {str(e)}"}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", 5000)))
