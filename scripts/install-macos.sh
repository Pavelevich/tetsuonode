#!/bin/bash

# TETSUO Node Installer for macOS
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
echo "                    TETSUO NODE - macOS INSTALLER"
echo "=========================================================================="
echo ""

# Validate HOME environment
if [ -z "${HOME:-}" ] || [ "$HOME" = "/" ]; then
    echo -e "${RED}[ERROR] Invalid HOME directory${NC}"
    echo "HOME is not set correctly. Please check your environment."
    exit 1
fi

# Check if macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}[ERROR] This script is for macOS only${NC}"
    echo "Detected OS: $OSTYPE"
    exit 1
fi

echo "[INFO] System: $(sw_vers -productName) $(sw_vers -productVersion)"
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "[INFO] Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "[INFO] Installing dependencies..."
REQUIRED_PACKAGES="git automake libtool boost openssl libevent"
brew install $REQUIRED_PACKAGES

# Verify dependencies were installed
echo "[INFO] Verifying dependencies..."
for pkg in git automake libtool; do
    if ! command -v $pkg &> /dev/null; then
        echo -e "${RED}[ERROR] Dependency '$pkg' not found after installation${NC}"
        exit 1
    fi
done

echo ""
echo "[INFO] Cloning TETSUO Core..."
WORK_DIR="$HOME/tetsuonode"

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

# Clone repository
if ! git clone https://github.com/Pavelevich/tetsuonode.git "$WORK_DIR"; then
    echo -e "${RED}[ERROR] Failed to clone repository${NC}"
    exit 1
fi

cd "$WORK_DIR/tetsuo-core" || {
    echo -e "${RED}[ERROR] Failed to enter tetsuo-core directory${NC}"
    exit 1
}

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

if ! make -j$(sysctl -n hw.ncpu); then
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
echo "Node location: $WORK_DIR/tetsuo-core/build/bin/tetsuod"
echo "Config file: ~/.tetsuo/tetsuo.conf"
echo ""
echo "START YOUR NODE:"
echo ""
echo "  cd $WORK_DIR/tetsuo-core"
echo "  ./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo"
echo ""
echo "VERIFY INSTALLATION:"
echo ""
echo "  cd $WORK_DIR/tetsuo-core"
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
    cd "$WORK_DIR/tetsuo-core" || {
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
    echo "  cd $WORK_DIR/tetsuo-core"
    echo "  ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount"
fi
