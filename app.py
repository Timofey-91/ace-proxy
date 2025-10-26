import os
import requests
from flask import Flask, request, Response, stream_with_context

ACE_URL = "http://127.0.0.1:6878"

app = Flask(__name__)

@app.route("/")
def home():
    return "✅ Local AceStream Engine Proxy (works with /ace/getstream?id= or infohash=)"

@app.route("/ace/<path:subpath>")
def ace_proxy(subpath):
    """Прокси всех /ace/* запросов на локальный AceStream Engine"""
    upstream_url = f"{ACE_URL}/ace/{subpath}"
    if request.query_string:
        upstream_url += f"?{request.query_string.decode()}"
    print("→", upstream_url)

    try:
        upstream = requests.get(upstream_url, stream=True, timeout=30)
    except Exception as e:
        return f"Upstream error: {e}", 502

    def generate():
        for chunk in upstream.iter_content(chunk_size=8192):
            if chunk:
                yield chunk

    headers = dict(upstream.headers)
    return Response(stream_with_context(generate()), status=upstream.status_code, headers=headers)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 10000)))
