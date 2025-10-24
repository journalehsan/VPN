#!/bin/bash

# Stop Both SSH Tunnel and Shadowsocks
echo "🛑 Stopping both SSH tunnel and Shadowsocks..."
echo ""

# Stop SSH tunnel
echo "📡 Stopping SSH tunnel..."
cd /home/ehsator/Documents/VPN
./stop_tunnel.sh

# Stop Shadowsocks
echo "🔌 Stopping Shadowsocks..."
./stop_shadowsocks.sh

echo ""
echo "✅ Both services stopped!"
