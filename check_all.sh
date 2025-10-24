#!/bin/bash

# Check Both SSH Tunnel and Shadowsocks
echo "🔍 Checking both SSH tunnel and Shadowsocks status..."
echo ""

# Check SSH tunnel
echo "📡 SSH Tunnel Status:"
./check_tunnel.sh

echo ""
echo "🔌 Shadowsocks Status:"
./check_shadowsocks.sh

echo ""
echo "💡 Commands:"
echo "   Start all: ./start_all.sh"
echo "   Stop all:  ./stop_all.sh"
echo "   Check all: ./check_all.sh"
