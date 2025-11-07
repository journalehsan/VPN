#!/bin/bash

# Check SSH Tunnel Status
echo "🔍 Checking SSH tunnel status..."
echo ""

# Check if tunnel process is running
TUNNEL_PIDS=$(pgrep -f "ssh.*130.185.123.86")
if [ -n "$TUNNEL_PIDS" ]; then
    for pid in $TUNNEL_PIDS; do
        echo "✅ SSH tunnel is running"
        echo "📊 Process ID: $pid"
        # Show process info
        ps -p $pid -o pid,ppid,cmd,etime 2>/dev/null || echo "   Could not get process details"
    done
else
    echo "❌ SSH tunnel is not running"
fi

# Check if port 8080 is listening
if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "✅ Port 8080 is listening"
    echo "🌐 SOCKS5 proxy: 127.0.0.1:8080"
    # Show which process is using the port
    netstat -tlnp 2>/dev/null | grep ":8080 " | head -1
else
    echo "❌ Port 8080 is not listening"
fi

# Test proxy connection
echo ""
echo "🧪 Testing proxy connection..."
if curl --socks5 127.0.0.1:8080 -s --max-time 10 -I https://httpbin.org/ip > /dev/null 2>&1; then
    echo "✅ Proxy connection test successful!"
    # Get IP to verify we're using the proxy
    PROXY_IP=$(curl --socks5 127.0.0.1:8080 -s --max-time 10 https://httpbin.org/ip 2>/dev/null | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1)
    if [ -n "$PROXY_IP" ]; then
        echo "🌐 Via proxy IP: $PROXY_IP"
    fi
else
    echo "❌ Proxy connection test failed"
    # Test direct connection to compare
    DIRECT_IP=$(curl -s --max-time 10 https://httpbin.org/ip 2>/dev/null | grep -oE '\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' | head -1)
    if [ -n "$DIRECT_IP" ]; then
        echo "🌐 Direct IP: $DIRECT_IP"
    fi
fi

echo ""
echo "💡 Commands:"
echo "   Start: ./start_tunnel.sh"
echo "   Stop:  ./stop_tunnel.sh"
echo "   Check: ./check_tunnel.sh"
