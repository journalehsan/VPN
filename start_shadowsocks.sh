#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${SCRIPT_DIR}/.venv_shadowsocks"
CONFIG_FILE="${SCRIPT_DIR}/shadowsocks/config.json"
# Don't modify PATH - use system shadowsocks-rust which supports modern ciphers

# Start Shadowsocks Client
echo "🚀 Starting Shadowsocks client..."

# Check if shadowsocks is installed (prefer shadowsocks-rust)
if command -v sslocal >/dev/null 2>&1; then
    SSLOCAL_BIN="$(command -v sslocal)"
else
    echo "❌ Shadowsocks client not installed. Install with: sudo pacman -S shadowsocks-rust"
    exit 1
fi

# Check if config exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Config file not found. Run ./setup_shadowsocks.sh first"
    exit 1
fi

# Stop existing shadowsocks if running
if pgrep -f "sslocal" > /dev/null; then
    echo "🛑 Stopping existing Shadowsocks client..."
    pkill -f "sslocal"
    sleep 2
fi

# Start shadowsocks client
echo "🔌 Starting Shadowsocks client on port 1080..."
"$SSLOCAL_BIN" -c "$CONFIG_FILE" &
SHADOWSOCKS_PID=$!

# Wait for startup
sleep 3

# Check if it's running
if pgrep -f "sslocal" > /dev/null; then
    echo "✅ Shadowsocks client is running!"
    echo "📊 Process ID: $SHADOWSOCKS_PID"
    echo "🌐 HTTP/SOCKS proxy: 127.0.0.1:1080"
    echo ""
    echo "💡 Usage:"
    echo "   - HTTP proxy: 127.0.0.1:1080"
    echo "   - SOCKS proxy: 127.0.0.1:1080"
    echo "   - Torsocks: torsocks curl https://example.com"
    echo "   - Proxychains: proxychains curl https://example.com"
    echo ""
    echo "🛑 To stop: ./stop_shadowsocks.sh"
else
    echo "❌ Failed to start Shadowsocks client"
    exit 1
fi
