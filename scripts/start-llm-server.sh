#!/bin/bash
# Start the LLM HTTP server for avante.nvim

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="/tmp/llm-server.pid"
LOG_FILE="/tmp/llm-server.log"
PORT=8765

# Check if server is already running
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
        echo "LLM server is already running (PID: $PID)"
        exit 0
    else
        rm -f "$PID_FILE"
    fi
fi

# Start the server in the background
echo "Starting LLM server on port $PORT..."
python3 "$SCRIPT_DIR/llm-server.py" --port $PORT > "$LOG_FILE" 2>&1 &
SERVER_PID=$!

# Save PID
echo $SERVER_PID > "$PID_FILE"

# Wait a moment and check if it started successfully
sleep 1
if ps -p $SERVER_PID > /dev/null 2>&1; then
    echo "LLM server started successfully (PID: $SERVER_PID)"
    echo "Log file: $LOG_FILE"
    echo "To stop: kill $SERVER_PID or run stop-llm-server.sh"
else
    echo "Failed to start LLM server. Check log: $LOG_FILE"
    rm -f "$PID_FILE"
    exit 1
fi
