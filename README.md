# VPN SSH Tunnel & Shadowsocks Scripts

This directory contains scripts to manage SSH tunnels and Shadowsocks for bypassing network filtering.

## Installation

### Fresh Arch Linux System

If you're setting this up on a fresh Arch Linux system, first install all required dependencies:

```bash
cd ~/Documents/VPN
./install_dependencies_arch.sh
```

This will install:
- shadowsocks-libev (Shadowsocks client)
- openssh (SSH client)
- sshpass (automated SSH authentication)
- net-tools (netstat)
- openbsd-netcat (network testing)
- openssl (password generation)
- curl (connection testing)
- torsocks (SOCKS proxy wrapper)
- proxychains-ng (proxy chains)

**For detailed dependency information, see [DEPENDENCIES.md](DEPENDENCIES.md)**

### Manual Installation

```bash
sudo pacman -S shadowsocks-libev openssh sshpass net-tools openbsd-netcat openssl curl torsocks proxychains-ng
```

## Server Details
- **Host**: ubuntu@130.185.123.86
- **Password**: Trk@#1403
- **SSH Tunnel**: SOCKS5://127.0.0.1:8080
- **Shadowsocks**: HTTP/SOCKS5://127.0.0.1:1080

## SSH Tunnel Scripts

### 🚀 start_tunnel.sh
Starts the SSH tunnel and sets up the SOCKS5 proxy on port 8080.

```bash
./start_tunnel.sh
```

### 🛑 stop_tunnel.sh
Stops the running SSH tunnel.

```bash
./stop_tunnel.sh
```

### 🔍 check_tunnel.sh
Checks the status of the SSH tunnel and tests the proxy connection.

```bash
./check_tunnel.sh
```

## Shadowsocks Scripts (Better Compatibility)

### 📦 setup_shadowsocks.sh
Sets up Shadowsocks on VPS and configures local client.

```bash
./setup_shadowsocks.sh
```

### 🚀 start_shadowsocks.sh
Starts the Shadowsocks client on port 1080.

```bash
./start_shadowsocks.sh
```

### 🛑 stop_shadowsocks.sh
Stops the Shadowsocks client.

```bash
./stop_shadowsocks.sh
```

### 🔍 check_shadowsocks.sh
Checks Shadowsocks status and tests connectivity.

```bash
./check_shadowsocks.sh
```

### 🔧 install_torsocks.sh
Installs and configures Torsocks and Proxychains for better proxy support.

```bash
./install_torsocks.sh
```

## Usage

### SSH Tunnel (Simple)
1. **Start the tunnel**:
   ```bash
   cd ~/Documents/VPN
   ./start_tunnel.sh
   ```

2. **Configure applications**:
   - **VS Code**: Already configured in settings.json
   - **Browser**: Set SOCKS5 proxy to 127.0.0.1:8080
   - **Terminal**: `export http_proxy=socks5://127.0.0.1:8080`

### Shadowsocks (Better Compatibility)
1. **Setup Shadowsocks** (run once):
   ```bash
   ./setup_shadowsocks.sh
   # Follow instructions to configure VPS
   ```

2. **Start Shadowsocks**:
   ```bash
   ./start_shadowsocks.sh
   ```

3. **Install Torsocks/Proxychains** (for apps that don't support SOCKS):
   ```bash
   ./install_torsocks.sh
   ```

4. **Use with applications**:
   ```bash
   # For command line tools
   torsocks curl https://example.com
   proxychains curl https://example.com
   
   # For GUI applications
   torsocks firefox
   proxychains firefox
   ```

### Check Status
```bash
./check_tunnel.sh      # SSH tunnel status
./check_shadowsocks.sh  # Shadowsocks status
```

### Stop Services
```bash
./stop_tunnel.sh       # Stop SSH tunnel
./stop_shadowsocks.sh  # Stop Shadowsocks
```

## VS Code Configuration

The following settings are already configured in `~/.config/Code/User/settings.json`:

```json
{
    "http.proxy": "socks5://127.0.0.1:8080",
    "http.proxyStrictSSL": false,
    "http.proxySupport": "on"
}
```

## Security Notes

- Credentials are stored in plain text in the scripts
- Consider using SSH keys for better security
- Make sure the server is trustworthy
- The tunnel forwards all traffic through the remote server

## Troubleshooting

- If port 8080 is in use, the script will automatically stop existing tunnels
- Check connection with `./check_tunnel.sh`
- Restart with `./stop_tunnel.sh && ./start_tunnel.sh`
