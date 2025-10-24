#!/bin/bash

# Start Both SSH Tunnel and Shadowsocks
echo "🚀 Starting both SSH tunnel and Shadowsocks..."
echo ""

# Start SSH tunnel
echo "📡 Starting SSH tunnel..."
cd /home/ehsator/Documents/VPN
./start_tunnel.sh

# Wait a moment
sleep 2

# Start Shadowsocks
echo "🔌 Starting Shadowsocks..."
./start_shadowsocks.sh

echo ""
echo "✅ Both services started!"
echo "🌐 SSH Tunnel: 127.0.0.1:8080"
echo "🌐 Shadowsocks: 127.0.0.1:1080"
echo ""
echo "💡 Check status: ./check_all.sh"
echo "🛑 Stop all: ./stop_all.sh"
