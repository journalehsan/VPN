#!/bin/bash

# Stop SSH Tunnel Script
echo "🛑 Stopping SSH tunnel..."

# Find and kill the SSH tunnel process
TUNNEL_PIDS=$(pgrep -f "ssh.*130.185.123.86")

if [ -n "$TUNNEL_PIDS" ]; then
    for pid in $TUNNEL_PIDS; do
        echo "📊 Found tunnel process: $pid"
        kill $pid 2>/dev/null || true
    done
    sleep 2
    
    # Check if any are still running
    if pgrep -f "ssh.*130.185.123.86" > /dev/null; then
        echo "⚠️  Process still running, force killing..."
        pkill -9 -f "ssh.*130.185.123.86"
        sleep 1
    fi
    
    echo "✅ SSH tunnel stopped successfully!"
else
    echo "ℹ️  No SSH tunnel process found."
fi

# Check if port is free
if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "⚠️  Port 8080 is still in use by another process."
else
    echo "✅ Port 8080 is now free."
fi

# Clean up any leftover debug log
rm -f /tmp/ssh_debug.log
