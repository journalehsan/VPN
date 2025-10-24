#!/bin/bash

# Install Torsocks and Proxychains for better proxy support
echo "📦 Installing Torsocks and Proxychains..."

# Install packages
if command -v pacman >/dev/null 2>&1; then
    echo "🔧 Installing via pacman..."
    sudo pacman -S torsocks proxychains-ng --noconfirm
elif command -v apt >/dev/null 2>&1; then
    echo "🔧 Installing via apt..."
    sudo apt update
    sudo apt install -y torsocks proxychains
else
    echo "⚠️  Please install torsocks and proxychains manually"
    exit 1
fi

# Configure proxychains
echo "⚙️  Configuring Proxychains..."
PROXYCHAINS_CONFIG="/etc/proxychains.conf"
if [ -f "$PROXYCHAINS_CONFIG" ]; then
    # Backup original config
    sudo cp "$PROXYCHAINS_CONFIG" "$PROXYCHAINS_CONFIG.backup"
    
    # Create new config for Shadowsocks
    sudo tee "$PROXYCHAINS_CONFIG" > /dev/null <<EOF
# Proxychains config for Shadowsocks
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
localnet 127.0.0.0/255.0.0.0
quiet_mode

[ProxyList]
socks5 127.0.0.1 1080
EOF
    
    echo "✅ Proxychains configured for Shadowsocks (127.0.0.1:1080)"
else
    echo "⚠️  Proxychains config not found"
fi

# Configure torsocks
echo "⚙️  Configuring Torsocks..."
TORSOCKS_CONFIG="/etc/torsocks.conf"
if [ -f "$TORSOCKS_CONFIG" ]; then
    # Backup original config
    sudo cp "$TORSOCKS_CONFIG" "$TORSOCKS_CONFIG.backup"
    
    # Create new config for Shadowsocks
    sudo tee "$TORSOCKS_CONFIG" > /dev/null <<EOF
# Torsocks config for Shadowsocks
server = 127.0.0.1
server_type = socks5
server_port = 1080
EOF
    
    echo "✅ Torsocks configured for Shadowsocks (127.0.0.1:1080)"
else
    echo "⚠️  Torsocks config not found"
fi

echo ""
echo "🎯 Installation complete!"
echo ""
echo "💡 Usage examples:"
echo "   torsocks curl https://example.com"
echo "   proxychains curl https://example.com"
echo "   torsocks firefox"
echo "   proxychains firefox"
echo ""
echo "🔧 Make sure Shadowsocks is running first:"
echo "   ./start_shadowsocks.sh"
