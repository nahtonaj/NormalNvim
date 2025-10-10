#!/bin/bash
# Stop the LLM HTTP server

PID_FILE="/tmp/llm-server.pid"

if [ ! -f "$PID_FILE" ]; then
    echo "LLM server is not running (no PID file found)"
    exit 0
fi

PID=$(cat "$PID_FILE")

if ps -p $PID > /dev/null 2>&1; then
    echo "Stopping LLM server (PID: $PID)..."
    kill $PID
    sleep 1

    if ps -p $PID > /dev/null 2>&1; then
        echo "Server didn't stop gracefully, force killing..."
        kill -9 $PID
    fi

    rm -f "$PID_FILE"
    echo "LLM server stopped"
else
    echo "LLM server is not running (stale PID file)"
    rm -f "$PID_FILE"
fi
