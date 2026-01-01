#!/bin/bash

# TETSUO Node Installer for Linux
# Run with: curl -fsSL https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-linux.sh | bash

set -e

echo "════════════════════════════════════════════════════════════════════════════════"
echo "                    TETSUO NODE - LINUX INSTALLER"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "[ERROR] Unable to detect Linux distribution"
    exit 1
fi

echo "[INFO] Detected: $PRETTY_NAME"
echo ""

# Install dependencies based on distribution
case "$OS" in
    ubuntu|debian)
        echo "[INFO] Installing dependencies..."
        sudo apt-get update
        sudo apt-get install -y \
            build-essential \
            libssl-dev \
            libboost-all-dev \
            libevent-dev \
            git \
            automake \
            libtool \
            pkg-config
        ;;
    fedora|rhel|centos)
        echo "[INFO] Installing dependencies..."
        sudo dnf install -y \
            gcc \
            gcc-c++ \
            make \
            openssl-devel \
            boost-devel \
            libevent-devel \
            git \
            automake \
            libtool \
            pkgconfig
        ;;
    arch)
        echo "[INFO] Installing dependencies..."
        sudo pacman -Sy --noconfirm \
            base-devel \
            openssl \
            boost \
            libevent \
            git
        ;;
    *)
        echo "[ERROR] Unsupported Linux distribution: $OS"
        echo "Please install dependencies manually:"
        echo "  - build-essential (or gcc, make)"
        echo "  - libssl-dev"
        echo "  - libboost-all-dev"
        echo "  - libevent-dev"
        echo "  - git, automake, libtool"
        exit 1
        ;;
esac

echo ""
echo "[INFO] Cloning TETSUO Core..."
WORK_DIR="$HOME/tetsuonode"
rm -rf "$WORK_DIR"
git clone https://github.com/Pavelevich/tetsuonode.git "$WORK_DIR"
cd "$WORK_DIR/tetsuo-core"

echo "[INFO] Building TETSUO Core..."
./autogen.sh
./configure --disable-wallet
make -j$(nproc)

echo ""
echo "[INFO] Configuring node..."
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
echo "                     INSTALLATION COMPLETED"
echo "════════════════════════════════════════════════════════════════════════════════"
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
echo "RUN AS SYSTEMD SERVICE (optional):"
echo ""
echo "  sudo tee /etc/systemd/system/tetsuod.service > /dev/null << 'UNIT'"
echo "  [Unit]"
echo "  Description=TETSUO Node"
echo "  After=network.target"
echo "  [Service]"
echo "  Type=simple"
echo "  User=$USER"
echo "  ExecStart=$WORK_DIR/tetsuo-core/build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo"
echo "  Restart=always"
echo "  RestartSec=10"
echo "  [Install]"
echo "  WantedBy=multi-user.target"
echo "  UNIT"
echo ""
echo "  sudo systemctl daemon-reload"
echo "  sudo systemctl enable tetsuod"
echo "  sudo systemctl start tetsuod"
echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
read -p "Would you like to start the node now? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cd "$WORK_DIR/tetsuo-core"
    ./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
    sleep 2
    echo "[SUCCESS] Node started!"
    echo ""
    ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount
    echo ""
    echo "Node is syncing... Check progress with:"
    echo "  cd $WORK_DIR/tetsuo-core"
    echo "  ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount"
fi
