```
████████╗███████╗████████╗███████╗██╗   ██╗ ██████╗ ███╗   ██╗ ██████╗ ██████╗ ███████╗
╚══██╔══╝██╔════╝╚══██╔══╝██╔════╝██║   ██║██╔═══██╗████╗  ██║██╔═══██╗██╔══██╗██╔════╝
   ██║   █████╗     ██║   ███████╗██║   ██║██║   ██║██╔██╗ ██║██║   ██║██║  ██║█████╗
   ██║   ██╔══╝     ██║   ╚════██║██║   ██║██║   ██║██║╚██╗██║██║   ██║██║  ██║██╔══╝
   ██║   ███████╗   ██║   ███████║╚██████╔╝╚██████╔╝██║ ╚████║╚██████╔╝██████╔╝███████╗
   ╚═╝   ╚══════╝   ╚═╝   ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝ ╚═════╝ ╚══════╝

                          DISTRIBUTED BLOCKCHAIN NODE
                            Join the decentralized network
```

# TETSUONODE - Run Your Own Node

> **The singularity begins with a single block** — Execute your node and become part of the TETSUO ecosystem

[![Build Status](https://img.shields.io/badge/status-active-brightgreen)](https://tetsuoarena.com)
[![Network](https://img.shields.io/badge/network-mainnet-blue)](https://tetsuoarena.com)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)
[![Nodes Running](https://img.shields.io/badge/nodes-500%2B-orange)](https://tetsuoarena.com)

---

## Table of Contents

- [Overview](#overview)
- [System Requirements](#system-requirements)
- [Quick Start](#quick-start)
  - [macOS](#macos)
  - [Linux](#linux)
  - [Windows](#windows)
- [Advanced Installation](#advanced-installation)
- [Configuration](#configuration)
- [Mining TETSUO](#mining-tetsuo)
- [Monitoring](#monitoring)
- [Troubleshooting](#troubleshooting)
- [Resources](#resources)

---

## Overview

**TETSUONODE** is your gateway to running a full node on the **TETSUO blockchain network**.

### What is a Node?

A TETSUO node is a peer in the decentralized network that:
- Downloads and validates the entire blockchain
- Relays transactions across the network
- Maintains network security and integrity
- (Optional) Mines new TETSUO blocks
- Strengthens network decentralization

### Why Run a Node?

| Benefit | Description |
|---------|-------------|
| **Security** | Help validate transactions and secure the network |
| **Mining** | Earn TETSUO by mining blocks (optional) |
| **Decentralization** | Make the network more resilient |
| **Control** | Full access to blockchain data |
| **Community** | Join the TETSUO ecosystem |

---

## System Requirements

### Minimum Requirements

```
CPU:        Dual-core (2+ cores recommended)
RAM:        2 GB minimum (4 GB recommended)
Storage:    5 GB free space (10 GB+ for full chain)
Bandwidth:  1 Mbps+ stable connection
OS:         macOS, Linux, or Windows
Uptime:     24/7 recommended
```

### Recommended Specifications

```
CPU:        Quad-core or better
RAM:        8 GB
Storage:    20 GB+ (SSD preferred)
Bandwidth:  10 Mbps+
Connection: Fiber or stable broadband
Uptime:     Always online
```

---

## Quick Start

### One-Command Installation

#### macOS

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-macos.sh)"
```

#### Linux (Ubuntu/Debian)

```bash
curl -fsSL https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-linux.sh | bash
```

#### Windows (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-windows.ps1 | iex
```

---

## macOS Installation

### Step 1: Install Homebrew (if not already installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: Install Dependencies

```bash
brew install git automake libtool boost openssl libevent
```

### Step 3: Clone Repository

```bash
git clone https://github.com/Pavelevich/tetsuonode.git
cd tetsuonode
```

### Step 4: Build TETSUO Core

```bash
cd tetsuo-core
./autogen.sh
./configure --disable-wallet
make -j$(sysctl -n hw.ncpu)
```

### Step 5: Configure Node

```bash
mkdir -p ~/.tetsuo
cat > ~/.tetsuo/tetsuo.conf << 'EOF'
server=1
listen=1
txindex=1
maxconnections=256
port=8338
rpcport=8336
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
fallbackfee=0.0001
addnode=tetsuoarena.com:8338
EOF
```

### Step 6: Start Node

```bash
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
```

### Step 7: Verify Installation

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockchaininfo
```

**Node is running!**

---

## Linux Installation

### Ubuntu/Debian

#### Step 1: Update System

```bash
sudo apt-get update && sudo apt-get upgrade -y
```

#### Step 2: Install Dependencies

```bash
sudo apt-get install -y \
    build-essential \
    libssl-dev \
    libboost-all-dev \
    libevent-dev \
    git \
    automake \
    libtool
```

#### Step 3: Clone Repository

```bash
git clone https://github.com/Pavelevich/tetsuonode.git
cd tetsuonode/tetsuo-core
```

#### Step 4: Build

```bash
./autogen.sh
./configure --disable-wallet
make -j$(nproc)
```

#### Step 5: Configure

```bash
mkdir -p ~/.tetsuo
cat > ~/.tetsuo/tetsuo.conf << 'EOF'
server=1
listen=1
txindex=1
maxconnections=256
port=8338
addnode=tetsuoarena.com:8338
fallbackfee=0.0001
EOF
```

#### Step 6: Start Node

```bash
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
```

#### Step 7: Verify

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount
```

**Node is running!**

---

## Windows Installation

### Prerequisites

- **Git**: https://git-scm.com/download/win
- **Visual Studio Build Tools** or **Microsoft C++ Build Tools**
- **Boost Libraries** (pre-compiled available)

### Step 1: Install Dependencies

#### Option A: Automated (Recommended)

```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-windows.ps1 | iex
```

#### Option B: Manual

1. Download and install **Git for Windows**
2. Install **Microsoft C++ Build Tools**
3. Download **Boost precompiled binaries**

### Step 2: Clone Repository

```powershell
git clone https://github.com/Pavelevich/tetsuonode.git
cd tetsuonode\tetsuo-core
```

### Step 3: Build

```powershell
# Run from Visual Studio Developer Command Prompt (as Administrator)
.\configure.bat
msbuild build_msvc\Bitcoin.sln /m /p:Configuration=Release
```

### Step 4: Create Data Directory

```powershell
mkdir $env:APPDATA\Tetsuo
mkdir $env:APPDATA\Tetsuo\.tetsuo
```

### Step 5: Configure Node

Create file: `%APPDATA%\Tetsuo\.tetsuo\tetsuo.conf`

```
server=1
listen=1
txindex=1
maxconnections=256
port=8338
addnode=tetsuoarena.com:8338
fallbackfee=0.0001
```

### Step 6: Start Node

```powershell
# Navigate to build directory
cd build_msvc\x64\Release

# Run daemon
.\tetsuod.exe -datadir="$env:APPDATA\Tetsuo\.tetsuo"

# Or run in background
Start-Process -WindowStyle Hidden -FilePath ".\tetsuod.exe" -ArgumentList "-datadir=$env:APPDATA\Tetsuo\.tetsuo"
```

### Step 7: Verify

```powershell
.\tetsuo-cli.exe -datadir="$env:APPDATA\Tetsuo\.tetsuo" getblockcount
```

**Node is running!**

---

## Advanced Configuration

### Enable Mining

Edit `~/.tetsuo/tetsuo.conf`:

```conf
# Mining Configuration
mine=1
mineraddress=YOUR_TETSUO_ADDRESS_HERE
threads=4
```

Restart node:

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo stop
sleep 3
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
```

### Optimize Performance

```conf
# Increase cache
dbcache=2048

# More connections
maxconnections=512

# Faster sync
banscore=100

# Listen on all interfaces
bind=0.0.0.0:8338
```

### Run as Service

#### macOS (LaunchAgent)

```bash
cat > ~/Library/LaunchAgents/com.tetsuo.node.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.tetsuo.node</string>
    <key>ProgramArguments</key>
    <array>
        <string>/path/to/tetsuod</string>
        <string>-daemon</string>
        <string>-datadir=/Users/username/.tetsuo</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF

launchctl load ~/Library/LaunchAgents/com.tetsuo.node.plist
```

#### Linux (systemd)

```bash
sudo tee /etc/systemd/system/tetsuod.service > /dev/null << 'EOF'
[Unit]
Description=TETSUO Node
After=network.target

[Service]
Type=simple
User=tetsuo
ExecStart=/usr/local/bin/tetsuod -daemon -datadir=/home/tetsuo/.tetsuo
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable tetsuod
sudo systemctl start tetsuod
```

---

## Monitoring Your Node

### Check Blockchain Height

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount
```

### View Connected Peers

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getpeerinfo | wc -l
```

### Monitor Mining

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getmininginfo
```

### View Network Info

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getnetworkinfo
```

### Real-time Logs

```bash
tail -f ~/.tetsuo/debug.log
```

### Dashboard (Web)

Visit: https://tetsuoarena.com

---

## Mining TETSUO

### Start Mining

```bash
# Enable mining in tetsuo.conf and restart
# OR start with mining flag
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo -mine=1 -mineraddress=YOUR_ADDRESS
```

### Monitor Mining Progress

```bash
watch -n 5 './build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getmininginfo'
```

### Check Mining Rewards

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo listtransactions
```

---

## Troubleshooting

### Problem: "Could not locate RPC credentials"

**Solution:**
```bash
# Make sure tetsuod is running
ps aux | grep tetsuod

# If not running:
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
```

### Problem: "Connection refused"

**Solution:**
```bash
# Check if port 8338 is available
lsof -i :8338  # macOS/Linux
netstat -ano | findstr :8338  # Windows

# If blocked, change port in tetsuo.conf:
port=8339
```

### Problem: "Not enough file descriptors"

**Solution:**
```bash
# Increase limit
ulimit -n 4096

# Then start daemon
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
```

### Problem: Slow sync

**Solution:**
```conf
# In tetsuo.conf:
dbcache=2048
maxconnections=256
par=4
```

### Problem: High memory usage

**Solution:**
```conf
# Reduce cache
dbcache=256
maxconnections=64
```

---

## Directory Structure

```
tetsuonode/
├── tetsuo-core/              # TETSUO core source code
├── scripts/
│   ├── install-macos.sh      # macOS installer
│   ├── install-linux.sh      # Linux installer
│   └── install-windows.ps1   # Windows installer
├── config/
│   ├── tetsuo.conf.example   # Example configuration
│   └── systemd/              # systemd service files
├── docs/
│   ├── MINING.md             # Mining guide
│   ├── CONFIG.md             # Configuration guide
│   └── API.md                # RPC API reference
├── README.md                 # This file
├── LICENSE                   # MIT License
└── .gitignore
```

---

## Useful Commands Reference

```bash
# Node Management
tetsuod -daemon -datadir=$HOME/.tetsuo        # Start node
tetsuo-cli -datadir=$HOME/.tetsuo stop        # Stop node
tetsuo-cli -datadir=$HOME/.tetsuo restart     # Restart node

# Blockchain Info
tetsuo-cli -datadir=$HOME/.tetsuo getblockcount
tetsuo-cli -datadir=$HOME/.tetsuo getblockchaininfo
tetsuo-cli -datadir=$HOME/.tetsuo getblock [hash]

# Network Info
tetsuo-cli -datadir=$HOME/.tetsuo getpeerinfo
tetsuo-cli -datadir=$HOME/.tetsuo getnetworkinfo
tetsuo-cli -datadir=$HOME/.tetsuo getnodeaddresses

# Mining Info
tetsuo-cli -datadir=$HOME/.tetsuo getmininginfo
tetsuo-cli -datadir=$HOME/.tetsuo setgenerate true 4

# RPC Help
tetsuo-cli -datadir=$HOME/.tetsuo help
tetsuo-cli -datadir=$HOME/.tetsuo help [command]
```

---

## Network Information

### Mainnet

- **Network**: TETSUO Mainnet
- **Genesis Block**: `000007c21fa4cce1c0fc25f4c5b44a43d0e19dd90c0f15d981d9ea3e763a52d5`
- **Default Port**: 8338
- **RPC Port**: 8336
- **Block Time**: ~5 seconds
- **Consensus**: Proof of Work (PoW)
- **Algorithm**: SHA-256

### Seed Nodes

```
tetsuoarena.com:8338
node1.tetsuo.network:8338
node2.tetsuo.network:8338
```

---

## Resources

- **Block Explorer**: https://tetsuoarena.com
- **GitHub**: https://github.com/Pavelevich/tetsuonode
- **Discord**: https://discord.gg/tetsuo
- **Documentation**: https://docs.tetsuoarena.com
- **API Reference**: https://api.tetsuoarena.com/docs

---

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

---

## Support & Community

- **Issues**: https://github.com/Pavelevich/tetsuonode/issues
- **Discussions**: https://github.com/Pavelevich/tetsuonode/discussions
- **Discord**: https://discord.gg/tetsuo
- **Twitter**: @TetsuoNetwork
- **Email**: support@tetsuoarena.com

---

## Roadmap

- [ ] GUI Node Manager
- [ ] Mobile Node Monitor
- [ ] Docker containerization
- [ ] Kubernetes deployment
- [ ] Advanced metrics dashboard
- [ ] Testnet support
- [ ] Hardware wallet integration

---

## Acknowledgments

- TETSUO Core Development Team
- Community Node Operators
- Contributors and Supporters

---

```
████████████████████████████████████████████████████████████████████████████████
█                                                                              █
█  "The singularity begins with a single block"                              █
█                                                                              █
█  Join the TETSUO Network. Run Your Node. Secure the Future.               █
█                                                                              █
████████████████████████████████████████████████████████████████████████████████
```

**Made for TETSUO Network**
*Last Updated: January 2026*
