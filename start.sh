#!/bin/bash
echo "Starting AceStream engine..."
./start-engine --client-console &

echo "Waiting for AceStream to start..."
sleep 20

echo "Starting nginx..."
nginx -g "daemon off;"
