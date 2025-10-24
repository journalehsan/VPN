#!/bin/bash

# SSH Tunnel Script for VPN Bypass
# Server: ubuntu@130.185.123.86
# Password: Trk@#1403

echo "🚀 Starting SSH tunnel for VPN bypass..."
echo "📡 Server: ubuntu@130.185.123.86"
echo "🔌 Local SOCKS5 proxy: 127.0.0.1:8080"
echo ""

# Check if port 8080 is already in use
if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "⚠️  Port 8080 is already in use. Stopping existing tunnel..."
    pkill -f "ssh.*130.185.123.86"
    sleep 2
fi

# Start the SSH tunnel
echo "🔐 Connecting to server..."
sshpass -p 'Trk@#1403' ssh -D 8080 -N ubuntu@130.185.123.86 &
TUNNEL_PID=$!

# Wait a moment for connection
sleep 3

# Check if tunnel is working
if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "✅ SSH tunnel is running successfully!"
    echo "📊 Process ID: $TUNNEL_PID"
    echo "🌐 SOCKS5 proxy: 127.0.0.1:8080"
    echo ""
    echo "💡 Usage:"
    echo "   - Browser: Configure SOCKS5 proxy to 127.0.0.1:8080"
    echo "   - VS Code: Already configured in settings.json"
    echo "   - Terminal: export http_proxy=socks5://127.0.0.1:8080"
    echo ""
    echo "🛑 To stop: kill $TUNNEL_PID or run ./stop_tunnel.sh"
    echo "🔄 To restart: ./start_tunnel.sh"
else
    echo "❌ Failed to establish tunnel. Check connection and credentials."
    exit 1
fi
