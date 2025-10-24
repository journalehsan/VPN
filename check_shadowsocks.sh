#!/bin/bash

# Check Shadowsocks Status
echo "🔍 Checking Shadowsocks status..."
echo ""

# Check if shadowsocks client is running
SHADOWSOCKS_PID=$(pgrep -f "sslocal")
if [ -n "$SHADOWSOCKS_PID" ]; then
    echo "✅ Shadowsocks client is running"
    echo "📊 Process ID: $SHADOWSOCKS_PID"
else
    echo "❌ Shadowsocks client is not running"
fi

# Check if port 1080 is listening
if netstat -tlnp 2>/dev/null | grep -q ":1080 "; then
    echo "✅ Port 1080 is listening"
    echo "🌐 HTTP/SOCKS proxy: 127.0.0.1:1080"
else
    echo "❌ Port 1080 is not listening"
fi

# Test proxy connection
echo ""
echo "🧪 Testing Shadowsocks proxy connection..."
if curl --socks5 127.0.0.1:1080 -s --max-time 10 -I https://httpbin.org/ip > /dev/null 2>&1; then
    echo "✅ Shadowsocks proxy connection test successful!"
else
    echo "❌ Shadowsocks proxy connection test failed"
fi

# Test with torsocks if available
if command -v torsocks >/dev/null 2>&1; then
    echo ""
    echo "🧪 Testing with torsocks..."
    if timeout 10 torsocks curl -s -I https://httpbin.org/ip > /dev/null 2>&1; then
        echo "✅ Torsocks integration working!"
    else
        echo "❌ Torsocks integration failed"
    fi
fi

echo ""
echo "💡 Commands:"
echo "   Start: ./start_shadowsocks.sh"
echo "   Stop:  ./stop_shadowsocks.sh"
echo "   Check: ./check_shadowsocks.sh"
echo ""
echo "🔧 Usage examples:"
echo "   torsocks curl https://example.com"
echo "   proxychains curl https://example.com"
echo "   curl --socks5 127.0.0.1:1080 https://example.com"
