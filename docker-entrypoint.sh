#!/bin/bash
set -e

echo "🚀 Starting AceStream Engine..."
cd /opt/acestream
/opt/acestream/start-engine --client-console --live-cache-type memory &

# Ждём, пока AceStream поднимется
for i in $(seq 1 20); do
  if curl -s http://127.0.0.1:6878/webui/api/service > /dev/null; then
    echo "✅ AceStream Engine is ready!"
    break
  fi
  echo "⏳ Waiting for AceStream Engine..."
  sleep 1
done

echo "🚀 Starting TorrServer..."
cd /opt/torrserver
/opt/torrserver/TorrServer --port 8090 --torrentaddr 127.0.0.1:6878
