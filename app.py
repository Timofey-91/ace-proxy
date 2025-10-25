from flask import Flask, request, redirect
import os

app = Flask(__name__)

# Адрес AceStream/TorrServer (по умолчанию localhost:6878)
TORRSERVER_URL = os.getenv("TORRSERVER_URL", "http://127.0.0.1:6878")

@app.route("/")
def home():
    return "✅ AceStream Proxy работает! Используй /ace/getstream?infohash=..."

@app.route("/ace/getstream")
def get_stream():
    infohash = request.args.get("infohash")
    if not infohash:
        return {"error": "infohash missing"}, 400
    # Проксируем запрос
    return redirect(f"{TORRSERVER_URL}/ace/getstream?infohash={infohash}&.mp4", code=302)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000)
