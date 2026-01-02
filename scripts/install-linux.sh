#!/bin/bash

# TETSUO Node Installer for Linux
# Safe installation guide: See INSTALL.md for secure setup

set -e
set -u

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Cleanup on error
cleanup() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[ERROR] Installation failed${NC}"
        echo "Partial installation may remain in: $WORK_DIR"
        echo "You can safely remove it with: rm -rf $WORK_DIR"
    fi
}
trap cleanup EXIT

echo "=========================================================================="
echo "                    TETSUO NODE - LINUX INSTALLER"
echo "=========================================================================="
echo ""

# Validate HOME environment
if [ -z "${HOME:-}" ] || [ "$HOME" = "/" ]; then
    echo -e "${RED}[ERROR] Invalid HOME directory${NC}"
    echo "HOME is not set correctly. Please check your environment."
    exit 1
fi

# Detect Linux distribution safely (without sourcing untrusted files)
echo "[INFO] Detecting Linux distribution..."
if [ -f /etc/os-release ]; then
    # Extract values without sourcing the file (safer)
    OS=$(grep "^ID=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
    PRETTY_NAME=$(grep "^PRETTY_NAME=" /etc/os-release | cut -d'=' -f2 | tr -d '"')
else
    echo -e "${RED}[ERROR] Unable to detect Linux distribution${NC}"
    echo "Could not find /etc/os-release"
    exit 1
fi

echo "[INFO] Detected: $PRETTY_NAME"
echo ""

# Install dependencies based on distribution
case "$OS" in
    ubuntu|debian)
        echo "[INFO] Installing dependencies for Debian/Ubuntu..."
        sudo apt-get update
        if ! sudo apt-get install -y \
            build-essential \
            libssl-dev \
            libboost-all-dev \
            libevent-dev \
            git \
            automake \
            libtool \
            pkg-config; then
            echo -e "${RED}[ERROR] Failed to install dependencies${NC}"
            exit 1
        fi
        ;;
    fedora|rhel|centos)
        echo "[INFO] Installing dependencies for Fedora/RHEL/CentOS..."
        if ! sudo dnf install -y \
            gcc \
            gcc-c++ \
            make \
            openssl-devel \
            boost-devel \
            libevent-devel \
            git \
            automake \
            libtool \
            pkgconfig; then
            echo -e "${RED}[ERROR] Failed to install dependencies${NC}"
            exit 1
        fi
        ;;
    arch)
        echo "[INFO] Installing dependencies for Arch Linux..."
        if ! sudo pacman -Sy --noconfirm \
            base-devel \
            openssl \
            boost \
            libevent \
            git; then
            echo -e "${RED}[ERROR] Failed to install dependencies${NC}"
            exit 1
        fi
        ;;
    *)
        echo -e "${RED}[ERROR] Unsupported Linux distribution: $OS${NC}"
        echo "Please install dependencies manually:"
        echo "  - build-essential (or gcc, make)"
        echo "  - libssl-dev"
        echo "  - libboost-all-dev"
        echo "  - libevent-dev"
        echo "  - git, automake, libtool"
        exit 1
        ;;
esac

# Verify critical dependencies
echo "[INFO] Verifying dependencies..."
for cmd in git automake libtool; do
    if ! command -v $cmd &> /dev/null; then
        echo -e "${RED}[ERROR] Dependency '$cmd' not found after installation${NC}"
        exit 1
    fi
done

echo ""
echo "[INFO] Cloning TETSUO Core..."
WORK_DIR="$HOME/tetsuo-core"

# Validate WORK_DIR path is safe
if [[ ! "$WORK_DIR" =~ ^$HOME ]]; then
    echo -e "${RED}[ERROR] Invalid work directory${NC}"
    exit 1
fi

# Warn if directory exists
if [ -d "$WORK_DIR" ]; then
    echo -e "${YELLOW}[WARNING] $WORK_DIR already exists and will be removed${NC}"
    read -p "Continue? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

rm -rf "$WORK_DIR"

# Clone the fullchain repository (contains tetsuo-core)
FULLCHAIN_DIR="$HOME/tetsuo-fullchain"
if ! git clone https://github.com/Pavelevich/fullchain.git "$FULLCHAIN_DIR"; then
    echo -e "${RED}[ERROR] Failed to clone fullchain repository${NC}"
    exit 1
fi

cd "$FULLCHAIN_DIR/tetsuo-core" || {
    echo -e "${RED}[ERROR] Failed to enter tetsuo-core directory${NC}"
    exit 1
}

WORK_DIR="$FULLCHAIN_DIR/tetsuo-core"

echo "[INFO] Building TETSUO Core..."
# Build with error checking
if ! ./autogen.sh; then
    echo -e "${RED}[ERROR] autogen.sh failed${NC}"
    exit 1
fi

if ! ./configure --disable-wallet; then
    echo -e "${RED}[ERROR] configure failed${NC}"
    exit 1
fi

# Increase file descriptors for build
ulimit -n 4096 2>/dev/null || true

if ! make -j$(nproc); then
    echo -e "${RED}[ERROR] make failed${NC}"
    exit 1
fi

# Verify build artifacts
echo "[INFO] Verifying build artifacts..."
if [ ! -f "./build/bin/tetsuod" ]; then
    echo -e "${RED}[ERROR] tetsuod binary not found${NC}"
    exit 1
fi

if [ ! -f "./build/bin/tetsuo-cli" ]; then
    echo -e "${RED}[ERROR] tetsuo-cli binary not found${NC}"
    exit 1
fi

if [ ! -x "./build/bin/tetsuod" ]; then
    echo -e "${RED}[ERROR] tetsuod is not executable${NC}"
    exit 1
fi

echo "[INFO] Configuring node..."
mkdir -p ~/.tetsuo
chmod 700 ~/.tetsuo

cat > ~/.tetsuo/tetsuo.conf << 'EOF'
# TETSUO Node Configuration
server=1
listen=1
txindex=1
maxconnections=256

# Network
port=8338
rpcport=8336
rpcallowip=127.0.0.1
rpcbind=127.0.0.1

# Fallback fee
fallbackfee=0.0001

# Seed nodes
addnode=tetsuoarena.com:8338

# Optional: Mining
# mine=1
# mineraddress=YOUR_TETSUO_ADDRESS
# threads=4
EOF

# Secure config file permissions
chmod 600 ~/.tetsuo/tetsuo.conf

echo ""
echo "=========================================================================="
echo "                        SECURITY NOTICE"
echo "=========================================================================="
echo ""
echo "Your TETSUO node will listen on port 8338 (P2P network traffic)"
echo ""
echo "IMPORTANT SECURITY RECOMMENDATIONS:"
echo "  1. Ensure your firewall allows outbound connections"
echo "  2. Do NOT expose RPC port 8336 to the internet"
echo "  3. Keep rpcallowip=127.0.0.1 (localhost only)"
echo "  4. Never share your data directory with untrusted users"
echo "  5. Keep your system and dependencies updated"
echo ""
echo "=========================================================================="
echo "                     INSTALLATION COMPLETED"
echo "=========================================================================="
echo ""
echo "Node location: $WORK_DIR/build/bin/tetsuod"
echo "Config file: ~/.tetsuo/tetsuo.conf"
echo ""
echo "START YOUR NODE:"
echo ""
echo "  cd $WORK_DIR"
echo "  ./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo"
echo ""
echo "VERIFY INSTALLATION:"
echo ""
echo "  cd $WORK_DIR"
echo "  ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount"
echo ""
echo "TO ENABLE MINING:"
echo ""
echo "  1. Edit: ~/.tetsuo/tetsuo.conf"
echo "  2. Set your address in mineraddress=..."
echo "  3. Uncomment mine=1 and threads=4"
echo "  4. Restart node"
echo ""
echo "MONITOR YOUR NODE:"
echo ""
echo "  https://tetsuoarena.com"
echo ""
echo "=========================================================================="
echo ""
read -p "Would you like to start the node now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$WORK_DIR" || {
        echo -e "${RED}[ERROR] Failed to change directory${NC}"
        exit 1
    }

    if [ ! -f "./build/bin/tetsuod" ]; then
        echo -e "${RED}[ERROR] tetsuod binary not found${NC}"
        exit 1
    fi

    ./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
    sleep 2
    echo -e "${GREEN}[SUCCESS] Node started!${NC}"
    echo ""
    ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount
    echo ""
    echo "Node is syncing... Check progress with:"
    echo "  cd $WORK_DIR"
    echo "  ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount"
fi
