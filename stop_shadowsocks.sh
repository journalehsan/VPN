#!/bin/bash

# Stop Shadowsocks Client
echo "🛑 Stopping Shadowsocks client..."

# Find and kill shadowsocks process
SHADOWSOCKS_PID=$(pgrep -f "sslocal")

if [ -n "$SHADOWSOCKS_PID" ]; then
    echo "📊 Found Shadowsocks process: $SHADOWSOCKS_PID"
    kill $SHADOWSOCKS_PID
    sleep 2
    
    # Check if it's still running
    if pgrep -f "sslocal" > /dev/null; then
        echo "⚠️  Process still running, force killing..."
        pkill -9 -f "sslocal"
    fi
    
    echo "✅ Shadowsocks client stopped successfully!"
else
    echo "ℹ️  No Shadowsocks client process found."
fi

# Check if port is free
if netstat -tlnp 2>/dev/null | grep -q ":1080 "; then
    echo "⚠️  Port 1080 is still in use. You may need to manually stop the process."
else
    echo "✅ Port 1080 is now free."
fi
