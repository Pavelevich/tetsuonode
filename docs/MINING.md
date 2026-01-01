# TETSUO Mining Guide

> **Earn TETSUO while securing the network. It's that simple.**

---

## Table of Contents

- [Quick Start](#quick-start)
- [System Requirements](#system-requirements)
- [Mining Setup](#mining-setup)
- [Monitor Your Mining](#monitor-your-mining)
- [Optimize Performance](#optimize-performance)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)

---

## Quick Start

**Enable mining in 3 steps:**

### Step 1: Get Your Mining Address

First, you need a TETSUO address to receive mining rewards.

```bash
cd ~/tetsuonode/tetsuo-core
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getnewaddress
```

This returns something like: `TBGq2N525Qu7kXGA4pp3CvMChDZuauQpeJ`

**Copy this address - you'll need it next.**

### Step 2: Enable Mining in Config

Edit your config file:

```bash
nano ~/.tetsuo/tetsuo.conf
```

Add or uncomment these lines:

```conf
# Enable mining
mine=1
mineraddress=YOUR_ADDRESS_HERE
threads=4
```

Replace `YOUR_ADDRESS_HERE` with your actual address from Step 1.

**For number of threads:** Use the number of CPU cores you have. Check with:
```bash
# macOS/Linux
nproc

# Windows PowerShell
[Environment]::ProcessorCount
```

### Step 3: Restart Your Node

Stop your node:
```bash
cd ~/tetsuonode/tetsuo-core
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo stop
sleep 3
```

Start it again:
```bash
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo
sleep 2
```

**That's it! Your node is now mining.**

---

## System Requirements

### Minimum to Mine

```
CPU:        2+ cores
RAM:        2 GB
Storage:    10 GB
Bandwidth:  1 Mbps
Power:      Stable connection (24/7 recommended)
```

### Recommended for Better Mining

```
CPU:        4+ cores (faster = more blocks)
RAM:        8 GB
Storage:    20+ GB SSD
Bandwidth:  10 Mbps+
Power:      Dedicated machine or always-on computer
```

**Note:** More CPU threads = higher chance of finding blocks faster.

---

## Mining Setup

### Configuration Options

Your `~/.tetsuo/tetsuo.conf` mining settings:

```conf
# Enable/disable mining
mine=1

# Your mining address (REQUIRED)
mineraddress=YOUR_TETSUO_ADDRESS

# Number of threads (set to your CPU count)
threads=4

# (Optional) Difficulty target - leave default for auto
# difficulty=1
```

### Start Mining with Command Line (No Config)

If you prefer not to edit the config file:

```bash
cd ~/tetsuonode/tetsuo-core
./build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo -mine=1 -mineraddress=YOUR_ADDRESS -threads=4
```

### Mining on Different Devices

**Always-on Computer (Best):**
- Desktop or server running 24/7
- Maximizes block finding chances
- Consistent reward stream

**Laptop:**
- Works, but less efficient
- May generate heat
- Not ideal for 24/7 mining (battery drain)

**Home Server/NAS:**
- Great option
- Low power consumption
- Good performance

**Raspberry Pi / ARM:**
- Works but very slow
- Requires more time between blocks
- Good for supporting the network

---

## Monitor Your Mining

### Check Mining Status

See if mining is active:

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getmininginfo
```

**Output example:**
```json
{
  "blocks": 8542,
  "currentblockweight": 4000,
  "currentblocktx": 1,
  "difficulty": 12.45678901,
  "networkhashps": 524288000,
  "pooledtx": 0,
  "chain": "main",
  "generate": true,
  "genproclimit": 4
}
```

**What it means:**
- `generate: true` = Mining is active
- `genproclimit: 4` = Using 4 threads
- `difficulty` = Current mining difficulty
- `networkhashps` = Network hash rate

### View Your Blocks

List blocks you've mined:

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo listtransactions
```

### Check Balance

See your mining rewards:

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getbalance
```

### Real-Time Monitoring

Watch mining in real-time:

```bash
# macOS/Linux
watch -n 5 './build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getmininginfo'

# Windows PowerShell
while ($true) {
    .\tetsuo-cli.exe -datadir="$env:APPDATA\Tetsuo\.tetsuo" getmininginfo
    Start-Sleep -Seconds 5
}
```

### View Logs

Check detailed mining activity:

```bash
tail -f ~/.tetsuo/debug.log | grep -i "miner\|mining\|block"
```

---

## Optimize Performance

### Maximize Hash Rate

**Increase Thread Count:**

Use all available CPU cores:

```bash
# Get number of cores
nproc  # macOS/Linux

# Edit config and set threads to that number
nano ~/.tetsuo/tetsuo.conf
# Set: threads=NUMBER_OF_CORES
```

**Example:** If you have an 8-core CPU:
```conf
threads=8
```

### Increase Mining Speed

**Boost Database Cache:**

Edit `~/.tetsuo/tetsuo.conf`:

```conf
# Larger cache = faster block generation
dbcache=2048

# More connections = better network sync
maxconnections=256

# Thread pool for parallel processing
par=4
```

### Power Management

**Keep Node Cool:**

```conf
# Reduce heat by limiting threads to 75% of CPU
# If you have 8 cores:
threads=6
```

**Monitor CPU Temperature:**

```bash
# macOS
istats

# Linux
watch -n 1 'sensors'

# Windows PowerShell
Get-WmiObject Win32_OperatingSystem | Select SystemUptime
```

### Network Optimization

**Better Peer Connections:**

```conf
# Add more seed nodes in tetsuo.conf
addnode=tetsuoarena.com:8338
addnode=node1.tetsuo.network:8338
addnode=node2.tetsuo.network:8338
```

---

## Troubleshooting

### Mining Not Starting

**Problem:** `generate: false` in `getmininginfo`

**Solution:**
1. Check your address is valid
2. Make sure daemon is running: `ps aux | grep tetsuod`
3. Restart daemon: `tetsuo-cli stop` then `tetsuod -daemon ...`
4. Check logs: `tail -f ~/.tetsuo/debug.log`

### High CPU Usage

**Problem:** Mining is using 100% CPU

**Solution:** Reduce thread count in config:

```conf
# If you have 8 cores but want to use only 4:
threads=4
```

### Mining Too Slow

**Problem:** Not finding blocks frequently

**Note:** This is normal. Block time is ~5 seconds, but difficulty varies. On a single machine, you might find 1 block every few hours or days depending on:
- Your CPU power
- Network difficulty
- Your thread count

**To find blocks faster:**
1. Increase `threads` (use all CPU cores)
2. Increase `dbcache` for faster block generation
3. Use a dedicated/always-on machine

### Mining Crashes

**Problem:** Mining stops unexpectedly

**Solution:**
1. Check error logs: `tail -50 ~/.tetsuo/debug.log`
2. Increase file descriptors:
   ```bash
   ulimit -n 4096
   ```
3. Restart daemon and mining

### Low Hash Rate

**Problem:** Mining slower than expected

**Check:**
```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getmininginfo
# Look at: networkhashps (network hash rate)
```

Your contribution depends on your hash rate vs. network hash rate. More threads = higher hash rate = more blocks.

---

## FAQ

### How often do I find blocks?

**It depends on:**
- Your CPU power (threads)
- Network difficulty
- Current network hash rate

**Example:** On a 4-core machine, you might find 1 block every 4-12 hours.

### What's the block reward?

Check your node:
```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockchaininfo | grep reward
```

### Can I mine on multiple machines?

**Yes!** Each machine:
1. Runs its own node
2. Has its own mining address (or same address)
3. Mines independently
4. All rewards go to the address you specify

### Is mining profitable?

That depends on:
- Your electricity cost
- Your hardware
- TETSUO price
- Network difficulty

**Calculate:**
```
Blocks per day × Block reward - Electricity cost = Profit
```

### Can I mine with GPU?

Not yet. TETSUO uses CPU mining (SHA-256 PoW).

### Should I mine on my personal computer?

**Pros:**
- Easy setup
- Get TETSUO rewards
- Help secure the network

**Cons:**
- Uses CPU resources
- May slow other tasks
- Generates heat and uses power

**Solution:** Run a low-power device like a Raspberry Pi or home server instead.

### Can I stop mining anytime?

**Yes, instantly:**

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo setgenerate false
```

Or edit config and set `mine=0` then restart.

### Where do my rewards go?

All mining rewards go to the address in `mineraddress=` in your config file.

### How do I claim my rewards?

They're automatic! As soon as you mine a block, the reward goes to your address. Check balance with:

```bash
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getbalance
```

### Can I change my mining address?

Yes! Edit `~/.tetsuo/tetsuo.conf` and change `mineraddress=` to a different address. Restart the daemon.

### What if I want to mine with a pool?

Pool mining is not yet supported. You're mining solo, which means:
- 100% of rewards go to you (no pool fees)
- But less frequent block finding
- Still securing the network

---

## Next Steps

1. **Start mining:** Follow the [Quick Start](#quick-start) section
2. **Monitor:** Use commands in [Monitor Your Mining](#monitor-your-mining)
3. **Optimize:** Try settings in [Optimize Performance](#optimize-performance)
4. **Join community:** Share your mining progress at https://tetsuoarena.com

---

## Resources

- **Block Explorer:** https://tetsuoarena.com
- **RPC Commands:** `./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo help`
- **Full Node Guide:** See README.md
- **Community:** https://discord.gg/tetsuo

---

**Happy mining! Support TETSUO while earning rewards.**
