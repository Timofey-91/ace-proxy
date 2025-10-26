from flask import Flask, redirect, request

app = Flask(__name__)

@app.route("/")
def home():
    return "✅ AceStream Proxy API is running"

@app.route("/ace/getstream")
def getstream():
    ace_id = request.args.get("id")
    if not ace_id:
        return "❌ Missing 'id' parameter", 400
    
    # Прокси через официальный mirror ValdikSS
    acestream_url = f"https://acestream.valdikss.org.ru/ace/manifest.m3u8?id={ace_id}"
    return redirect(acestream_url, code=302)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=10000)
