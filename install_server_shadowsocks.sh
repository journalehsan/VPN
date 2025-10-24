#!/bin/bash

# Install Shadowsocks on VPS Server
echo "🚀 Installing Shadowsocks on VPS server..."
echo "📡 Server: ubuntu@130.185.123.86"
echo ""

# Generate secure password
PASSWORD=$(openssl rand -base64 32)
echo "🔐 Generated password: $PASSWORD"
echo ""

# Create server setup script
cat > /tmp/setup_shadowsocks_server.sh <<EOF
#!/bin/bash

echo "📦 Updating system packages..."
sudo apt update

echo "📦 Installing Shadowsocks server..."
sudo apt install -y shadowsocks-libev

echo "🔧 Creating Shadowsocks config..."
sudo mkdir -p /etc/shadowsocks-libev

# Create config file
sudo tee /etc/shadowsocks-libev/config.json > /dev/null <<CONFIG
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "$PASSWORD",
    "timeout": 300,
    "method": "aes-256-gcm",
    "fast_open": true,
    "mode": "tcp_and_udp"
}
CONFIG

echo "🔧 Starting Shadowsocks service..."
sudo systemctl enable shadowsocks-libev
sudo systemctl restart shadowsocks-libev

echo "📊 Checking service status..."
sudo systemctl status shadowsocks-libev --no-pager

echo "🔍 Checking if port 8388 is listening..."
sudo netstat -tlnp | grep 8388

echo "✅ Shadowsocks server setup complete!"
echo "🔐 Password: $PASSWORD"
echo "🌐 Server: 0.0.0.0:8388"
EOF

# Make script executable
chmod +x /tmp/setup_shadowsocks_server.sh

echo "📤 Uploading setup script to server..."
scp /tmp/setup_shadowsocks_server.sh ubuntu@130.185.123.86:/tmp/

echo "🚀 Running setup script on server..."
sshpass -p 'Trk@#1403' ssh ubuntu@130.185.123.86 'bash /tmp/setup_shadowsocks_server.sh'

# Save password for local client
echo "💾 Saving password for local client..."
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

echo ""
echo "✅ Server setup complete!"
echo "🔐 Password saved to: /home/ehsator/Documents/VPN/shadowsocks/config.json"
echo "🌐 Local proxy will be: 127.0.0.1:1080"
echo ""
echo "🎯 Next steps:"
echo "1. Start local client: ./start_shadowsocks.sh"
echo "2. Test connection: ./check_shadowsocks.sh"
echo "3. Install torsocks: ./install_torsocks.sh"

# Cleanup
rm /tmp/setup_shadowsocks_server.sh
