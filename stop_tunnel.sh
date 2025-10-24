#!/bin/bash

# Stop SSH Tunnel Script
echo "🛑 Stopping SSH tunnel..."

# Find and kill the SSH tunnel process
TUNNEL_PID=$(pgrep -f "ssh.*130.185.123.86")

if [ -n "$TUNNEL_PID" ]; then
    echo "📊 Found tunnel process: $TUNNEL_PID"
    kill $TUNNEL_PID
    sleep 2
    
    # Check if it's still running
    if pgrep -f "ssh.*130.185.123.86" > /dev/null; then
        echo "⚠️  Process still running, force killing..."
        pkill -9 -f "ssh.*130.185.123.86"
    fi
    
    echo "✅ SSH tunnel stopped successfully!"
else
    echo "ℹ️  No SSH tunnel process found."
fi

# Check if port is free
if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "⚠️  Port 8080 is still in use. You may need to manually stop the process."
else
    echo "✅ Port 8080 is now free."
fi
