#!/bin/bash

# Install all dependencies for Shadowsocks scripts on Arch Linux
# This script installs all required packages for running the VPN/Shadowsocks scripts

set -e  # Exit on any error

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Shadowsocks VPN Scripts - Dependency Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
    echo "⚠️  Warning: This script is designed for Arch Linux"
    echo "   You appear to be running a different distribution"
    read -p "   Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if pacman is available
if ! command -v pacman >/dev/null 2>&1; then
    echo "❌ Error: pacman not found. This script requires Arch Linux."
    exit 1
fi

# Check for sudo access
if ! sudo -v; then
    echo "❌ Error: sudo access required to install packages"
    exit 1
fi

echo "🔍 Checking existing installations..."
echo ""

# Function to check if a command exists
check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        echo "  ✅ $2 already installed"
        return 0
    else
        echo "  ⏳ $2 needs installation"
        return 1
    fi
}

# List of packages to check/install
declare -A PACKAGES=(
    ["sslocal"]="shadowsocks-libev"
    ["ssh"]="openssh"
    ["sshpass"]="sshpass"
    ["netstat"]="net-tools"
    ["nc"]="openbsd-netcat"
    ["openssl"]="openssl"
    ["curl"]="curl"
    ["torsocks"]="torsocks"
    ["proxychains"]="proxychains-ng"
)

# Check which packages need installation
MISSING_PACKAGES=()
for cmd in "${!PACKAGES[@]}"; do
    package="${PACKAGES[$cmd]}"
    if ! check_command "$cmd" "$package"; then
        MISSING_PACKAGES+=("$package")
    fi
done

# Check pre-installed utilities
echo ""
echo "🔍 Checking system utilities (usually pre-installed)..."
check_command "timeout" "coreutils" || MISSING_PACKAGES+=("coreutils")
check_command "grep" "grep" || MISSING_PACKAGES+=("grep")
check_command "pgrep" "procps-ng" || MISSING_PACKAGES+=("procps-ng")
check_command "bash" "bash" || MISSING_PACKAGES+=("bash")

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# If all packages are installed
if [ ${#MISSING_PACKAGES[@]} -eq 0 ]; then
    echo "✅ All dependencies are already installed!"
    echo ""
    echo "📋 Installed packages:"
    for package in "${PACKAGES[@]}"; do
        echo "   • $package"
    done
    echo ""
    echo "🎯 You can now run the shadowsocks scripts!"
    exit 0
fi

# Show packages to be installed
echo "📦 The following packages will be installed:"
for package in "${MISSING_PACKAGES[@]}"; do
    echo "   • $package"
done
echo ""

# Ask for confirmation
read -p "Proceed with installation? (Y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Installing packages..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Update package database
echo "📥 Updating package database..."
sudo pacman -Sy --noconfirm

# Install missing packages
echo ""
echo "📦 Installing missing packages..."
if sudo pacman -S --needed --noconfirm "${MISSING_PACKAGES[@]}"; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ All packages installed successfully!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ Some packages failed to install"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "🔧 Troubleshooting:"
    echo "   • Check your internet connection"
    echo "   • Run: sudo pacman -Sy"
    echo "   • Try installing packages manually"
    echo ""
    echo "📦 If shadowsocks-libev is not found, try AUR:"
    echo "   yay -S shadowsocks-libev"
    echo "   # or"
    echo "   paru -S shadowsocks-libev"
    exit 1
fi

echo ""
echo "🔍 Verifying installations..."
echo ""

# Verify installations
ALL_OK=true
for cmd in "${!PACKAGES[@]}"; do
    package="${PACKAGES[$cmd]}"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "  ✅ $package"
    else
        echo "  ❌ $package (verification failed)"
        ALL_OK=false
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$ALL_OK" = true ]; then
    echo "✅ Installation Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📚 Documentation:"
    echo "   Read DEPENDENCIES.md for detailed information"
    echo ""
    echo "🎯 Next Steps:"
    echo ""
    echo "   1. Setup Shadowsocks server (run once):"
    echo "      ./install_server_shadowsocks.sh"
    echo ""
    echo "   2. Start Shadowsocks client:"
    echo "      ./start_shadowsocks.sh"
    echo ""
    echo "   3. Install proxy wrappers (optional):"
    echo "      ./install_torsocks.sh"
    echo ""
    echo "   4. Check status:"
    echo "      ./check_shadowsocks.sh"
    echo ""
    echo "   Alternative: Use SSH tunnel"
    echo "      ./start_tunnel.sh"
    echo ""
    echo "📖 For more information, see README.md"
else
    echo "⚠️  Installation completed with some issues"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Some packages may not be working correctly."
    echo "Please verify and install missing packages manually."
    exit 1
fi
