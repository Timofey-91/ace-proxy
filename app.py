from flask import Flask, request, redirect

app = Flask(__name__)

@app.route('/ace/getstream')
def get_stream():
    infohash = request.args.get('infohash') or request.args.get('id')
    if not infohash:
        return "Missing id or infohash", 400

    # AceStream Engine слушает на 6878
    return redirect(f"http://127.0.0.1:6878/ace/getstream?id={infohash}", code=302)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8090)
