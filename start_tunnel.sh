#!/bin/bash

# SSH Tunnel Script for VPN Bypass
# Server: ubuntu@130.185.123.86
# Password: Trk@#1403

set -e  # Exit on any error

echo "🚀 Starting SSH tunnel for VPN bypass..."
echo "📡 Server: ubuntu@130.185.123.86"
echo "🔌 Local SOCKS5 proxy: 127.0.0.1:8080"
echo ""

# Check if required tools are available
if ! command -v sshpass >/dev/null 2>&1; then
    echo "❌ sshpass is not installed. Please install it first."
    echo "   Ubuntu/Debian: sudo apt install sshpass"
    exit 1
fi

if ! command -v ssh >/dev/null 2>&1; then
    echo "❌ ssh is not installed. Please install it first."
    echo "   Ubuntu/Debian: sudo apt install openssh-client"
    exit 1
fi

if ! command -v netstat >/dev/null 2>&1; then
    echo "❌ netstat is not installed. Please install it first."
    echo "   Ubuntu/Debian: sudo apt install net-tools"
    exit 1
fi

# Check if port 8080 is already in use
if netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
    echo "⚠️  Port 8080 is already in use. Stopping existing tunnel..."
    pkill -f "ssh.*130.185.123.86" 2>/dev/null || true
    sleep 2
fi

# Check if we can reach the server
echo "🔍 Testing server connectivity..."
if ! timeout 10 bash -c "</dev/tcp/130.185.123.86/22" 2>/dev/null; then
    echo "❌ Cannot connect to server 130.185.123.86:22. Check network connection."
    exit 1
fi

echo "🔐 Connecting to server with SSH tunnel..."

# Clean up any old debug log
rm -f /tmp/ssh_debug.log

# Start the SSH tunnel with better options for debugging
sshpass -p 'Trk@#1403' ssh -D 8080 -N \
  -o ConnectTimeout=15 \
  -o ServerAliveInterval=30 \
  -o ServerAliveCountMax=3 \
  -o StrictHostKeyChecking=no \
  -o UserKnownHostsFile=/dev/null \
  -o LogLevel=INFO \
  -v ubuntu@130.185.123.86 2>/tmp/ssh_debug.log &

TUNNEL_PID=$!

# Wait a bit for connection to establish
sleep 7

# Function to check if tunnel is properly working
check_tunnel_ready() {
    # Check if process is still alive
    if ! ps -p $TUNNEL_PID > /dev/null 2>&1; then
        return 1
    fi
    
    # Check if port is bound
    if ! netstat -tlnp 2>/dev/null | grep -q ":8080 "; then
        return 1
    fi
    
    # Try a simple connection test through the proxy
    if nc -z -w 5 127.0.0.1 8080 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if tunnel is ready
if check_tunnel_ready; then
    echo "✅ SSH tunnel is running successfully!"
    echo "📊 Process ID: $TUNNEL_PID"
    echo "🌐 SOCKS5 proxy: 127.0.0.1:8080"
    echo ""
    echo "💡 Usage:"
    echo "   - Browser: Configure SOCKS5 proxy to 127.0.0.1:8080"
    echo "   - VS Code: Already configured in settings.json"
    echo "   - Terminal: export http_proxy=socks5://127.0.0.1:8080"
    echo ""
    echo "🛑 To stop: kill $TUNNEL_PID or run ./stop_tunnel.sh"
    echo "🔄 To restart: ./start_tunnel.sh"
else
    # Give it more time and check again
    sleep 8
    if check_tunnel_ready; then
        echo "✅ SSH tunnel is running successfully!"
        echo "📊 Process ID: $TUNNEL_PID"
        echo "🌐 SOCKS5 proxy: 127.0.0.1:8080"
    else
        echo "❌ Failed to establish tunnel properly. SSH debug log:"
        cat /tmp/ssh_debug.log || echo "No debug log available"
        
        # Additional debugging: check if there are auth errors
        if [ -f /tmp/ssh_debug.log ]; then
            echo ""
            echo "🔍 Looking for authentication errors in log:"
            grep -i "Authentication\|permission\|denied\|error" /tmp/ssh_debug.log || echo "No authentication errors found"
        fi
        
        # Kill the process if it's still running
        if ps -p $TUNNEL_PID > /dev/null 2>&1; then
            kill $TUNNEL_PID 2>/dev/null || true
        fi
        
        exit 1
    fi
fi

# Clean up debug log
rm -f /tmp/ssh_debug.log
