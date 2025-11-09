# Dependencies for Shadowsocks Scripts on Arch Linux

This document lists all dependencies required to run the shadowsocks and VPN scripts on a fresh Arch Linux system.

## Core Dependencies

### System Packages (via pacman)

1. **shadowsocks-libev** - Shadowsocks client/server
   - Used by: `setup_shadowsocks.sh`, `start_shadowsocks.sh`, `check_shadowsocks.sh`
   - Provides: `sslocal` command
   ```bash
   sudo pacman -S shadowsocks-libev
   ```

2. **openssh** - SSH client for tunneling
   - Used by: `start_tunnel.sh`, `check_tunnel.sh`, `install_server_shadowsocks.sh`
   - Provides: `ssh`, `scp` commands
   ```bash
   sudo pacman -S openssh
   ```

3. **sshpass** - Non-interactive SSH password authentication
   - Used by: `start_tunnel.sh`, `install_server_shadowsocks.sh`
   - Required for automated SSH connections
   ```bash
   sudo pacman -S sshpass
   ```

4. **net-tools** - Network utilities
   - Used by: All check/start scripts
   - Provides: `netstat` command
   ```bash
   sudo pacman -S net-tools
   ```

5. **openbsd-netcat** - TCP/IP swiss army knife
   - Used by: `start_tunnel.sh` (for port checking with `nc`)
   - Provides: `nc` command
   ```bash
   sudo pacman -S openbsd-netcat
   ```

6. **openssl** - SSL/TLS toolkit
   - Used by: `setup_shadowsocks.sh`, `install_server_shadowsocks.sh` (for password generation)
   - Provides: `openssl` command
   ```bash
   sudo pacman -S openssl
   ```

7. **curl** - Command line HTTP client
   - Used by: `check_shadowsocks.sh`, `check_tunnel.sh` (for testing connections)
   - Provides: `curl` command
   ```bash
   sudo pacman -S curl
   ```

8. **torsocks** - Transparent SOCKS proxy wrapper
   - Used by: `install_torsocks.sh`, `check_shadowsocks.sh`
   - Provides: `torsocks` command
   ```bash
   sudo pacman -S torsocks
   ```

9. **proxychains-ng** - Proxy chains tool
   - Used by: `install_torsocks.sh`
   - Provides: `proxychains` command
   ```bash
   sudo pacman -S proxychains-ng
   ```

10. **coreutils** - Basic file, shell and text manipulation utilities
    - Used by: All scripts (provides `timeout`, `sleep`, `mkdir`, `cat`, `rm`, etc.)
    - Usually pre-installed on Arch
    ```bash
    sudo pacman -S coreutils
    ```

11. **grep** - Pattern matching tool
    - Used by: All scripts for status checking
    - Usually pre-installed on Arch
    ```bash
    sudo pacman -S grep
    ```

12. **procps-ng** - Process monitoring utilities
    - Used by: All scripts (provides `pgrep`, `pkill`, `ps`)
    - Usually pre-installed on Arch
    ```bash
    sudo pacman -S procps-ng
    ```

13. **bash** - Bourne Again SHell
    - Used by: All scripts run with bash
    - Usually pre-installed on Arch
    ```bash
    sudo pacman -S bash
    ```

## Summary of All Required Packages

```bash
# Essential packages (required)
sudo pacman -S shadowsocks-libev openssh sshpass net-tools openbsd-netcat openssl curl torsocks proxychains-ng

# Usually pre-installed (verify)
sudo pacman -S coreutils grep procps-ng bash
```

## Configuration Files

The scripts create and modify the following configuration files:

1. **Shadowsocks client config**: `~/Documents/VPN/shadowsocks/config.json`
   - Created by: `setup_shadowsocks.sh`, `install_server_shadowsocks.sh`

2. **Proxychains config**: `/etc/proxychains.conf`
   - Modified by: `install_torsocks.sh`
   - Requires: sudo access

3. **Torsocks config**: `/etc/torsocks.conf`
   - Modified by: `install_torsocks.sh`
   - Requires: sudo access

## Port Requirements

The scripts use the following local ports:

- **1080**: Shadowsocks SOCKS5 proxy
- **8080**: SSH tunnel SOCKS5 proxy

Make sure these ports are available and not blocked by firewall.

## Remote Server Requirements

For the server side (Ubuntu VPS), the scripts expect:

- **shadowsocks-libev** (Ubuntu package: `shadowsocks-libev`)
- **systemd** (for service management)
- **Port 8388** open for Shadowsocks server

## Permission Requirements

- **sudo access** required for:
  - Installing packages
  - Modifying `/etc/proxychains.conf`
  - Modifying `/etc/torsocks.conf`
  
- **User permissions** required for:
  - Creating directories in `~/Documents/VPN/`
  - Running SSH/shadowsocks client
  - Binding to local ports 1080 and 8080

## Quick Installation

Run the provided installation script:

```bash
cd ~/Documents/VPN
./install_dependencies_arch.sh
```

Or install manually:

```bash
# Install all required packages
sudo pacman -Syu --needed shadowsocks-libev openssh sshpass net-tools \
    openbsd-netcat openssl curl torsocks proxychains-ng

# Verify installations
command -v sslocal && echo "✅ shadowsocks-libev"
command -v ssh && echo "✅ openssh"
command -v sshpass && echo "✅ sshpass"
command -v netstat && echo "✅ net-tools"
command -v nc && echo "✅ netcat"
command -v openssl && echo "✅ openssl"
command -v curl && echo "✅ curl"
command -v torsocks && echo "✅ torsocks"
command -v proxychains && echo "✅ proxychains-ng"
```

## Verification

After installation, verify all dependencies:

```bash
# Check shadowsocks
sslocal --version

# Check SSH
ssh -V

# Check network tools
netstat --version
nc -h
curl --version

# Check proxy tools
torsocks --version
proxychains --version

# Check utilities
openssl version
```

## Troubleshooting

### Package Not Found

If a package is not found in official repositories, you may need to enable additional repositories or install from AUR:

```bash
# Update package database
sudo pacman -Sy

# If shadowsocks-libev not found, try AUR
yay -S shadowsocks-libev
# or
paru -S shadowsocks-libev
```

### Permission Denied

If you get permission errors:

```bash
# Add user to necessary groups
sudo usermod -aG network $USER

# Re-login for changes to take effect
```

### Port Already in Use

If ports 1080 or 8080 are already in use:

```bash
# Find what's using the port
sudo netstat -tlnp | grep :1080
sudo netstat -tlnp | grep :8080

# Kill the process if needed
sudo pkill -f sslocal  # for shadowsocks
sudo pkill -f "ssh.*130.185.123.86"  # for ssh tunnel
```
