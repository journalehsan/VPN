# 🚀 VPN Quick Reference

## 🎯 **One-Command Aliases**

```bash
# Start everything (SSH tunnel + Shadowsocks)
vpn-start

# Stop everything
vpn-stop

# Check status of both
vpn-check
vpn-status
```

## 🔧 **Individual Services**

```bash
# SSH tunnel only
ssh-tunnel

# Shadowsocks only  
shadowsocks
```

## 📊 **Manual Commands**

```bash
cd ~/Documents/VPN

# Start all
./start_all.sh

# Stop all
./stop_all.sh

# Check all
./check_all.sh
```

## 🌐 **Proxy Endpoints**

- **SSH Tunnel**: `socks5://127.0.0.1:8080`
- **Shadowsocks**: `socks5://127.0.0.1:1080`

## 💡 **Usage Examples**

```bash
# Direct proxy
curl --socks5 127.0.0.1:1080 https://example.com

# With Torsocks
torsocks curl https://example.com
torsocks firefox

# With Proxychains
proxychains curl https://example.com
proxychains firefox
```

## 🎯 **VS Code Configuration**

Already configured in `~/.config/Code/User/settings.json`:
```json
{
    "http.proxy": "socks5://127.0.0.1:8080",
    "http.proxyStrictSSL": false,
    "http.proxySupport": "on"
}
```

## 🚀 **Quick Start**

1. Open terminal
2. Type: `vpn-start`
3. Done! Both services running

## 🛑 **Quick Stop**

1. Type: `vpn-stop`
2. Done! All services stopped
