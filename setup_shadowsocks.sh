#!/bin/bash

set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_CONFIG_DIR="${SCRIPT_DIR}/shadowsocks"
VENV_DIR="${SCRIPT_DIR}/.venv_shadowsocks"
SSLOCAL_BIN=""
SHADOWSOCKS_METHOD="aes-256-cfb"

patch_shadowsocks_py() {
    if [[ ! -x "${VENV_DIR}/bin/python" ]]; then
        return
    fi

    "${VENV_DIR}/bin/python" - <<'PY' || true
import site
from pathlib import Path

targets = []
for site_dir in site.getsitepackages():
    base = Path(site_dir) / "shadowsocks"
    if not base.exists():
        continue
    lru = base / "lru_cache.py"
    openssl = base / "crypto" / "openssl.py"
    if lru.exists():
        targets.append(lru)
    if openssl.exists():
        targets.append(openssl)

def patch_lru(path: Path):
    text = path.read_text()
    updated = text.replace("collections.MutableMapping",
                           "collections.abc.MutableMapping")
    if updated != text:
        path.write_text(updated)

def patch_openssl(path: Path):
    text = path.read_text()
    if "ctx_cleanup = None" not in text:
        text = text.replace(
            "loaded = False\n",
            "loaded = False\nctx_cleanup = None\nctx_reset = None\n",
            1,
        )
    cleanup_block = (
        "    libcrypto.EVP_CIPHER_CTX_cleanup.argtypes = (c_void_p,)\n"
        "    libcrypto.EVP_CIPHER_CTX_free.argtypes = (c_void_p,)\n"
    )
    replacement_block = (
        "    global ctx_cleanup, ctx_reset\n"
        "    ctx_cleanup = getattr(libcrypto, 'EVP_CIPHER_CTX_cleanup', None)\n"
        "    ctx_reset = getattr(libcrypto, 'EVP_CIPHER_CTX_reset', None)\n"
        "    if ctx_cleanup:\n"
        "        ctx_cleanup.argtypes = (c_void_p,)\n"
        "    if ctx_reset:\n"
        "        ctx_reset.argtypes = (c_void_p,)\n"
        "    libcrypto.EVP_CIPHER_CTX_free.argtypes = (c_void_p,)\n"
    )
    if cleanup_block in text and replacement_block not in text:
        text = text.replace(cleanup_block, replacement_block, 1)
    clean_block = (
        "        if self._ctx:\n"
        "            libcrypto.EVP_CIPHER_CTX_cleanup(self._ctx)\n"
        "            libcrypto.EVP_CIPHER_CTX_free(self._ctx)\n"
    )
    new_clean_block = (
        "        if self._ctx:\n"
        "            cleaned = False\n"
        "            global ctx_cleanup, ctx_reset\n"
        "            if ctx_cleanup:\n"
        "                ctx_cleanup(self._ctx)\n"
        "                cleaned = True\n"
        "            elif ctx_reset:\n"
        "                ctx_reset(self._ctx)\n"
        "                cleaned = True\n"
        "            if not cleaned:\n"
        "                pass\n"
        "            libcrypto.EVP_CIPHER_CTX_free(self._ctx)\n"
    )
    if clean_block in text and new_clean_block not in text:
        text = text.replace(clean_block, new_clean_block, 1)
    path.write_text(text)

for target in targets:
    if target.name == "lru_cache.py":
        patch_lru(target)
    elif target.name == "openssl.py":
        patch_openssl(target)
PY
}

detect_pkg_manager() {
    if command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v apt >/dev/null 2>&1; then
        echo "apt"
    else
        echo ""
    fi
}

PKG_MANAGER="$(detect_pkg_manager)"
APT_UPDATED=0

install_package() {
    local package="$1"

    case "$PKG_MANAGER" in
        pacman)
            sudo pacman -Sy --noconfirm "$package"
            ;;
        apt)
            if [[ $APT_UPDATED -eq 0 ]]; then
                sudo apt update
                APT_UPDATED=1
            fi
            sudo apt install -y "$package"
            ;;
        *)
            echo "⚠️  Package manager not detected. Please install '$package' manually."
            return 1
            ;;
    esac
}

ensure_dependency() {
    local binary="$1"
    local package="${2:-$1}"

    if command -v "$binary" >/dev/null 2>&1; then
        return 0
    fi

    if [[ -n "$PKG_MANAGER" ]]; then
        echo "📦 '$binary' not found. Attempting to install '$package'..."
        install_package "$package"
    else
        echo "⚠️  Missing required command '$binary'. Please install '$package' manually and re-run."
        exit 1
    fi
}

ensure_dependency openssl openssl

case "$PKG_MANAGER" in
    pacman)
        ensure_dependency python3 python
        ensure_dependency pip3 python-pip
        ;;
    apt)
        ensure_dependency python3 python3
        ensure_dependency pip3 python3-pip
        ensure_dependency python3-venv python3-venv
        ;;
    *)
        ensure_dependency python3 python3
        ensure_dependency pip3 pip3
        ;;
esac

install_shadowsocks_client() {
    if command -v sslocal >/dev/null 2>&1; then
        SSLOCAL_BIN="$(command -v sslocal)"
        return 0
    fi

    if [[ "$PKG_MANAGER" == "apt" ]]; then
        install_package shadowsocks-libev
        SSLOCAL_BIN="$(command -v sslocal || true)"
    else
        echo "📦 Installing Shadowsocks client inside virtual environment..."
        python3 -m venv "$VENV_DIR"
        "${VENV_DIR}/bin/pip" install --upgrade pip >/dev/null
        "${VENV_DIR}/bin/pip" install shadowsocks >/dev/null
        patch_shadowsocks_py
        SSLOCAL_BIN="${VENV_DIR}/bin/sslocal"
    fi

    if [[ -z "${SSLOCAL_BIN}" || ! -x "${SSLOCAL_BIN}" ]]; then
        if command -v sslocal >/dev/null 2>&1; then
            SSLOCAL_BIN="$(command -v sslocal)"
        else
            echo "⚠️  'sslocal' still not available. Install Shadowsocks manually and re-run."
            exit 1
        fi
    fi

    echo "✅ Shadowsocks client available at: ${SSLOCAL_BIN}"
}

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

# Generate random password
PASSWORD=$(openssl rand -base64 32)

cat <<CONFIG
{
    "server": "0.0.0.0",
    "server_port": 8388,
    "password": "$PASSWORD",
    "timeout": 300,
    "method": "$SHADOWSOCKS_METHOD",
    "fast_open": true
}
CONFIG

echo "EOF"
echo ""
echo "# Start shadowsocks service:"
echo "sudo systemctl enable shadowsocks-libev"
echo "sudo systemctl start shadowsocks-libev"
echo "sudo systemctl status shadowsocks-libev"
echo ""

echo "🔐 Generated password: $PASSWORD"
echo ""

# Create local shadowsocks config
mkdir -p "$LOCAL_CONFIG_DIR"
cat > "$LOCAL_CONFIG_DIR/config.json" <<EOF
{
    "server": "130.185.123.86",
    "server_port": 8388,
    "local_address": "127.0.0.1",
    "local_port": 1080,
    "password": "$PASSWORD",
    "timeout": 300,
    "method": "$SHADOWSOCKS_METHOD",
    "fast_open": true
}
EOF

echo "✅ Local Shadowsocks config created:"
echo "   📁 Config: $LOCAL_CONFIG_DIR/config.json"
echo "   🔌 Local proxy: 127.0.0.1:1080"
echo "   🌐 Server: 130.185.123.86:8388"
echo ""

# Install shadowsocks client locally
echo "📦 Ensuring Shadowsocks client (sslocal) is installed..."
install_shadowsocks_client

echo ""
echo "🎯 Next steps:"
echo "1. Run the server commands on your VPS"
echo "2. Start local client: ./start_shadowsocks.sh"
echo "3. Use HTTP proxy: 127.0.0.1:1080"
