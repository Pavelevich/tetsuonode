# TETSUO Configuration Guide

> **Customize your TETSUO node exactly how you need it.**

---

## Table of Contents

- [Configuration File Location](#configuration-file-location)
- [Quick Start Config](#quick-start-config)
- [Network Settings](#network-settings)
- [Mining Settings](#mining-settings)
- [Database & Performance](#database--performance)
- [RPC Settings](#rpc-settings)
- [Logging & Debug](#logging--debug)
- [Advanced Settings](#advanced-settings)
- [Common Configurations](#common-configurations)
- [Troubleshooting](#troubleshooting)

---

## Configuration File Location

### macOS & Linux

```bash
~/.tetsuo/tetsuo.conf
```

**Edit it:**
```bash
nano ~/.tetsuo/tetsuo.conf
```

### Windows

```
%APPDATA%\Tetsuo\.tetsuo\tetsuo.conf
```

**Edit it:**
```powershell
notepad "$env:APPDATA\Tetsuo\.tetsuo\tetsuo.conf"
```

---

## Quick Start Config

Copy and paste this minimal config, then customize:

```conf
# Basic Node Configuration
server=1
listen=1
txindex=1

# Network
port=8338
maxconnections=256

# RPC (for local commands only)
rpcport=8336
rpcallowip=127.0.0.1
rpcbind=127.0.0.1

# Fees
fallbackfee=0.0001

# Seed node
addnode=tetsuoarena.com:8338
```

**After editing:**
```bash
# Restart your node
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo stop
sleep 3
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
```

---

## Network Settings

### Basic Network

```conf
# Enable server mode (required for node)
server=1

# Listen for incoming connections
listen=1

# Network port (default: 8338)
port=8338

# Maximum peer connections
maxconnections=256
```

### Connecting to Peers

```conf
# Add seed nodes to connect to
addnode=tetsuoarena.com:8338
addnode=node1.tetsuo.network:8338
addnode=node2.tetsuo.network:8338

# Connect only to specific peers (advanced)
connect=tetsuoarena.com:8338

# Only listen, don't connect outbound
# onlynet=ipv4
```

### Custom Port (if 8338 is blocked)

```conf
# Use different port
port=8339

# Update seed node with custom port
addnode=tetsuoarena.com:8339
```

### IPv6 Support

```conf
# Enable IPv6
onlynet=ipv4
# onlynet=ipv6

# Or allow both:
# (just omit onlynet entirely)
```

---

## Mining Settings

### Enable Mining

```conf
# Activate mining
mine=1

# Your mining address (REQUIRED if mine=1)
mineraddress=YOUR_TETSUO_ADDRESS

# Number of threads (match your CPU cores)
threads=4
```

### Get Your Address

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getnewaddress
```

### Disable Mining

```conf
# Turn off mining
mine=0
```

### Mining Examples

**4-core CPU:**
```conf
mine=1
mineraddress=TBGq2N525Qu7kXGA4pp3CvMChDZuauQpeJ
threads=4
```

**8-core CPU:**
```conf
mine=1
mineraddress=TBGq2N525Qu7kXGA4pp3CvMChDZuauQpeJ
threads=8
```

**High-end server (16-core):**
```conf
mine=1
mineraddress=TBGq2N525Qu7kXGA4pp3CvMChDZuauQpeJ
threads=16
```

---

## Database & Performance

### Cache Settings

```conf
# Database cache in MB (default: 300)
# Higher = faster sync but more RAM usage
dbcache=2048  # 2 GB cache (good for 8+ GB RAM)
dbcache=512   # 512 MB (conservative, low RAM)
dbcache=256   # 256 MB (minimal, 2 GB systems)
```

### Parallel Processing

```conf
# Number of script validation threads (default: 0 = auto)
# Increases block validation speed
par=4
```

### Block Sync Optimization

```conf
# Ban score threshold (higher = less aggressive banning)
banscore=100

# Timeout for slow peers
timeout=5000
```

### Full Example (Performance Tuning)

```conf
# Faster sync
dbcache=2048
par=4
maxconnections=256
banscore=100

# Validation
txindex=1
```

---

## RPC Settings

### Local RPC Only (Recommended for security)

```conf
# Enable RPC server
server=1

# RPC port (default: 8336)
rpcport=8336

# Only allow local connections (127.0.0.1)
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
```

### Allow Remote RPC (Advanced - Use with caution!)

```conf
# Allow specific IP
rpcallowip=192.168.1.100

# Allow all IPs (NOT RECOMMENDED - Use firewall instead!)
# rpcallowip=0.0.0.0/0
```

### RPC Authentication

```conf
# Auto-generate credentials
# (cookie file created at ~/.tetsuo/.cookie)

# Or set manually
rpcuser=tetsuouser
rpcpassword=YOUR_SECURE_PASSWORD_HERE
```

### RPC Examples

**Localhost only:**
```conf
server=1
rpcport=8336
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
```

**Specific network IP:**
```conf
server=1
rpcport=8336
rpcallowip=192.168.1.0/24
rpcbind=192.168.1.10
```

---

## Logging & Debug

### Basic Logging

```conf
# Enable debug logging
debug=1

# Log category
debug=net
debug=rpc
debug=miner
```

### View Logs

```bash
# All logs
tail -f ~/.tetsuo/debug.log

# Mining logs only
tail -f ~/.tetsuo/debug.log | grep -i miner

# Network logs
tail -f ~/.tetsuo/debug.log | grep -i "net\|peer"

# RPC logs
tail -f ~/.tetsuo/debug.log | grep -i rpc
```

### Log File Settings

```conf
# Maximum log file size in MB
maxlogsize=100

# Shrink log file when exceeding max size
shrinkdebugfile=1
```

---

## Advanced Settings

### Blockchain Settings

```conf
# Verify blocks on startup
checkblocks=6

# Verify transactions on startup
checklevel=3

# Index all transactions
txindex=1

# Maintain a full unspent output set
# (required for many features)
# utxoindex=1
```

### Mempool Settings

```conf
# Maximum mempool size in MB (default: 300)
maxmempool=512

# Minimum fee relay rate (satoshis per byte)
minrelaytxfee=0.00001
```

### Wallet Settings (if enabled)

```conf
# Unlock wallet on startup
# walletpassphrase=YOUR_PASSWORD TIMEOUT_SECONDS

# Disable wallet entirely
disablewallet=1
```

### Zero Knowledge Proof (Advanced)

```conf
# Enable ZK proofs (if supported)
# experimentalfeatures=1
```

---

## Common Configurations

### Minimal Node (Low Resources)

```conf
server=1
listen=1
port=8338
maxconnections=32
dbcache=256
addnode=tetsuoarena.com:8338
rpcallowip=127.0.0.1
```

### Full Node (Recommended)

```conf
server=1
listen=1
txindex=1
port=8338
maxconnections=256
dbcache=1024
par=4
addnode=tetsuoarena.com:8338
rpcport=8336
rpcallowip=127.0.0.1
fallbackfee=0.0001
```

### Mining Node

```conf
server=1
listen=1
txindex=1
port=8338
maxconnections=256
dbcache=2048
par=4
addnode=tetsuoarena.com:8338

# Mining
mine=1
mineraddress=YOUR_ADDRESS_HERE
threads=4

# RPC for monitoring
rpcport=8336
rpcallowip=127.0.0.1
```

### High-Performance Node

```conf
server=1
listen=1
txindex=1
port=8338
maxconnections=512
dbcache=4096
par=8
maxmempool=1024
timeout=3000

# Network optimization
banscore=100
addnode=tetsuoarena.com:8338

# Mining (optional)
mine=1
mineraddress=YOUR_ADDRESS_HERE
threads=16

# RPC
rpcport=8336
rpcallowip=127.0.0.1
```

### Privacy-Focused Node

```conf
server=1
listen=1
port=8338

# Reduce connections
maxconnections=64

# Don't relay memory pool
mempoolfullrbf=0

# Disable RPC
server=0

# Good peers only
banscore=100
```

---

## Environment Variables

Set environment variables before starting:

```bash
# Increase file descriptors
export ULIMIT=4096
ulimit -n 4096

# Start with custom datadir
./build/bin/tetsuod -datadir=/custom/path -daemon

# Start with multiple config files
./build/bin/tetsuod -conf=/path/to/main.conf -confupdate
```

---

## Troubleshooting

### Node Won't Start

**Check config syntax:**
```bash
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo -printtoconsole
```

**Common errors:**
- `Unknown option` - Typo in config
- `Cannot parse monetary amount` - Invalid number format
- `Invalid port` - Port already in use

**Fix:** Check config file for syntax errors and restart.

### Slow Sync

**Current config:**
```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockchaininfo | grep "blocks\|headers"
```

**Optimize:**
```conf
dbcache=2048
par=4
maxconnections=256
```

### High Memory Usage

**Reduce cache:**
```conf
dbcache=512
maxmempool=300
```

### RPC Connection Refused

**Check if running:**
```bash
ps aux | grep tetsuod
```

**Check config:**
```bash
cat ~/.tetsuo/tetsuo.conf | grep rpc
```

**Verify settings:**
- `rpcport` matches your connection
- `rpcallowip` includes your IP
- `rpcbind` is set correctly

### Port Already in Use

**Find what's using port:**
```bash
# macOS/Linux
lsof -i :8338

# Windows
netstat -ano | findstr :8338
```

**Change port in config:**
```conf
port=8339
addnode=tetsuoarena.com:8339
```

### High CPU Usage

**Reduce threads:**
```conf
threads=2  # Instead of 4 or 8
par=2      # Reduce parallel processing
```

### Mining Not Working

**Check config:**
```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getmininginfo
```

**Verify settings:**
- `mine=1` is set
- `mineraddress` is a valid address
- `threads` is > 0

**Restart:**
```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo stop
sleep 3
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
```

---

## Configuration Commands

### Reload Config Without Restart

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo reloadconfig
```

### View Current Config

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo -getinfo
```

### Test Config

```bash
./build/bin/tetsuod -datadir=$HOME/.tetsuo -testnet
```

### Get Default Config

```bash
./build/bin/tetsuod -datadir=$HOME/.tetsuo -printdefaultconfig > default.conf
```

---

## Tips & Best Practices

1. **Start Simple** - Use the Quick Start config, then customize
2. **Monitor Changes** - Restart and check if performance improves
3. **Use Comments** - Add `# comments` to remember why you changed things
4. **Backup Config** - Keep a copy of working configs
5. **Test First** - Test changes on `-testnet` before mainnet
6. **Resource Aware** - Match settings to your hardware
7. **Security First** - Keep RPC local (127.0.0.1) when possible
8. **Update Gradually** - Change one setting, test, then change another

---

## Resources

- **Block Explorer:** https://tetsuoarena.com
- **Mining Guide:** See MINING.md
- **Full Node Guide:** See README.md
- **Twitter:** @tetsuoarena

---

**Questions?** Check the logs:
```bash
tail -f ~/.tetsuo/debug.log
```

**Happy configuring!**
