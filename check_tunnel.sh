#!/bin/bash

# Check SSH Tunnel Status
echo "🔍 Checking SSH tunnel status..."
echo ""

# Check if tunnel process is running
TUNNEL_PID=$(pgrep -f "ssh.*130.185.123.86")
if [ -n "$TUNNEL_PID" ]; then
    echo "✅ SSH tunnel is running"
    echo "📊 Process ID: $TUNNEL_PID"
else
    echo "❌ SSH tunnel is not running"
fi

# Check if port 8080 is listening
if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "✅ Port 8080 is listening"
    echo "🌐 SOCKS5 proxy: 127.0.0.1:8080"
else
    echo "❌ Port 8080 is not listening"
fi

# Test proxy connection
echo ""
echo "🧪 Testing proxy connection..."
if curl --socks5 127.0.0.1:8080 -s --max-time 10 -I https://httpbin.org/ip > /dev/null 2>&1; then
    echo "✅ Proxy connection test successful!"
else
    echo "❌ Proxy connection test failed"
fi

echo ""
echo "💡 Commands:"
echo "   Start: ./start_tunnel.sh"
echo "   Stop:  ./stop_tunnel.sh"
echo "   Check: ./check_tunnel.sh"
