#!/bin/bash

# Setup Shadowsocks on VPS and configure local client
echo "🚀 Setting up Shadowsocks for better proxy compatibility..."

# Server setup commands (run these on your VPS: ubuntu@130.185.123.86)
echo "📋 Commands to run on VPS (130.185.123.86):"
echo ""
echo "sudo apt update"
echo "sudo apt install -y shadowsocks-libev"
echo ""
echo "# Create config file:"
echo "sudo tee /etc/shadowsocks-libev/config.json > /dev/null <<EOF"
echo "{"
echo "    \"server\": \"0.0.0.0\","
echo "    \"server_port\": 8388,"
echo "    \"password\": \"$(openssl rand -base64 32)\","
echo "    \"timeout\": 300,"
echo "    \"method\": \"aes-256-gcm\","
echo "    \"fast_open\": true"
echo "}"
echo "EOF"
echo ""
echo "# Start shadowsocks service:"
echo "sudo systemctl enable shadowsocks-libev"
echo "sudo systemctl start shadowsocks-libev"
echo "sudo systemctl status shadowsocks-libev"
echo ""

# Generate random password
PASSWORD=$(openssl rand -base64 32)
echo "🔐 Generated password: $PASSWORD"
echo ""

# Create local shadowsocks config
mkdir -p /home/ehsator/Documents/VPN/shadowsocks
cat > /home/ehsator/Documents/VPN/shadowsocks/config.json <<EOF
{
    "server": "130.185.123.86",
    "server_port": 8388,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "$PASSWORD",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": true
}
EOF

echo "✅ Local Shadowsocks config created:"
echo "   📁 Config: /home/ehsator/Documents/VPN/shadowsocks/config.json"
echo "   🔌 Local proxy: 127.0.0.1:1080"
echo "   🌐 Server: 130.185.123.86:8388"
echo ""

# Install shadowsocks client locally
echo "📦 Installing Shadowsocks client locally..."
if command -v pacman >/dev/null 2>&1; then
    sudo pacman -S shadowsocks-libev --noconfirm
elif command -v apt >/dev/null 2>&1; then
    sudo apt update && sudo apt install -y shadowsocks-libev
else
    echo "⚠️  Please install shadowsocks-libev manually"
fi

echo ""
echo "🎯 Next steps:"
echo "1. Run the server commands on your VPS"
echo "2. Start local client: ./start_shadowsocks.sh"
echo "3. Use HTTP proxy: 127.0.0.1:1080"
