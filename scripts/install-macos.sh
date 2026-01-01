#!/bin/bash

# TETSUO Node Installer for macOS
# Run with: bash <(curl -fsSL https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-macos.sh)

set -e

echo "════════════════════════════════════════════════════════════════════════════════"
echo "                    🚀 TETSUO NODE - macOS INSTALLER"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

# Check if macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo "📦 Installing dependencies..."
brew install git automake libtool boost openssl libevent

echo ""
echo "📥 Cloning TETSUO Core..."
WORK_DIR="$HOME/tetsuonode"
rm -rf "$WORK_DIR"
git clone https://github.com/Pavelevich/tetsuonode.git "$WORK_DIR"
cd "$WORK_DIR/tetsuo-core"

echo "🏗️  Building TETSUO Core..."
./autogen.sh
./configure --disable-wallet
make -j$(sysctl -n hw.ncpu)

echo ""
echo "⚙️  Configuring node..."
mkdir -p ~/.tetsuo

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

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo "                     ✅ INSTALLATION COMPLETED"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "📍 Node location: $WORK_DIR/tetsuo-core/build/bin/tetsuod"
echo "📍 Config file: ~/.tetsuo/tetsuo.conf"
echo ""
echo "🚀 START YOUR NODE:"
echo ""
echo "  cd $WORK_DIR/tetsuo-core"
echo "  ./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo"
echo ""
echo "✅ VERIFY INSTALLATION:"
echo ""
echo "  cd $WORK_DIR/tetsuo-core"
echo "  ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount"
echo ""
echo "⛏️  TO ENABLE MINING:"
echo ""
echo "  1. Edit: ~/.tetsuo/tetsuo.conf"
echo "  2. Set your address in mineraddress=..."
echo "  3. Uncomment mine=1 and threads=4"
echo "  4. Restart node"
echo ""
echo "📊 MONITOR YOUR NODE:"
echo ""
echo "  https://tetsuoarena.com"
echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
read -p "Would you like to start the node now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$WORK_DIR/tetsuo-core"
    ./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
    sleep 2
    echo "✅ Node started!"
    echo ""
    ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount
    echo ""
    echo "Node is syncing... Check progress with:"
    echo "  cd $WORK_DIR/tetsuo-core"
    echo "  ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount"
fi
