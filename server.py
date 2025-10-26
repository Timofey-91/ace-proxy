from flask import Flask, request, jsonify
import subprocess, os

app = Flask(__name__)

@app.route("/ace/getstream")
def getstream():
    stream_id = request.args.get("id")
    if not stream_id:
        return jsonify({"error": "Missing id"}), 400

    # Команда запуска AceStream
    cmd = ["/opt/acestream/start-engine", "--client-console", f"acestream://{stream_id}"]
    subprocess.Popen(cmd)
    return jsonify({
        "status": "ok",
        "message": f"Stream started for id={stream_id}"
    })

@app.route("/")
def index():
    return "✅ AceStream API is running"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8090)
