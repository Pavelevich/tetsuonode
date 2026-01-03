# TETSUONODE Security Hardening Guide

**Version:** 1.0
**Date:** January 3, 2026
**Status:** PRODUCTION READY

This guide provides detailed security hardening recommendations for operators running TETSUO nodes in production environments.

---

## Table of Contents

1. [System Hardening](#system-hardening)
2. [Network Security](#network-security)
3. [Node Configuration](#node-configuration)
4. [Monitoring & Alerting](#monitoring--alerting)
5. [Backup & Recovery](#backup--recovery)
6. [Incident Response](#incident-response)
7. [Compliance Checklist](#compliance-checklist)

---

## System Hardening

### Operating System Security

#### Linux (Ubuntu/Debian)

**1. Keep System Updated**
```bash
sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get autoremove -y

# Enable automatic security updates
sudo apt-get install -y unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades
```

**2. SSH Hardening**
```bash
# Edit /etc/ssh/sshd_config
sudo nano /etc/ssh/sshd_config

# Recommended settings:
Port 2222                              # Non-standard port
PermitRootLogin no                     # Disable root SSH
PubkeyAuthentication yes               # Use key-based auth only
PasswordAuthentication no              # Disable password auth
X11Forwarding no                       # Disable X11
MaxAuthTries 3                         # Limit login attempts
ClientAliveInterval 60                 # Timeout idle connections
ClientAliveCountMax 2

# Restart SSH
sudo systemctl restart sshd
```

**3. Firewall Configuration (UFW)**
```bash
# Enable UFW
sudo ufw enable

# Default policies
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (change port if using non-standard)
sudo ufw allow 2222/tcp comment "SSH"

# Allow P2P (TETSUO)
sudo ufw allow 8338/tcp comment "TETSUO P2P"
sudo ufw allow 8338/udp comment "TETSUO P2P UDP"

# Deny RPC (never expose)
sudo ufw deny 8336/tcp comment "Deny RPC"
sudo ufw deny 8336/udp comment "Deny RPC UDP"

# Show rules
sudo ufw status verbose
```

**4. Disable Unnecessary Services**
```bash
# List enabled services
systemctl list-unit-files --type=service | grep enabled

# Disable services you don't need
sudo systemctl disable avahi-daemon
sudo systemctl disable cups
sudo systemctl disable bluetooth

# Services to keep enabled:
# - ssh (with hardening)
# - tetsuod (your node)
# - ufw (firewall)
# - fail2ban (if installed)
```

**5. Install Fail2Ban (Intrusion Prevention)**
```bash
sudo apt-get install -y fail2ban

# Configure SSH protection
sudo nano /etc/fail2ban/jail.local

# Add:
[sshd]
enabled = true
port = 2222
maxretry = 3
findtime = 600
bantime = 3600
```

#### macOS Hardening

**1. System Updates**
```bash
# Enable automatic updates
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
defaults write com.apple.SoftwareUpdate AutomaticDownload -bool true

# Check for updates manually
softwareupdate -l
softwareupdate -ia
```

**2. Firewall Configuration**
```bash
# Enable macOS Firewall
sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1

# Verify
sudo cat /Library/Preferences/com.apple.alf/com.apple.alf.plist
```

**3. Disable Unnecessary Features**
```bash
# Disable Bluetooth
defaults write com.apple.BluetoothAudioUnitPreferences ignore_ctl_alt_activate -bool true

# Disable remote login
sudo systemsetup -setremotelogin off

# Disable remote events
sudo defaults write /Library/Preferences/com.apple.Remote-Events.plist enabled 0
```

#### Windows Hardening

**1. Windows Update**
```powershell
# Enable automatic updates
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name NoAutoUpdate -Value 0
```

**2. Windows Defender**
```powershell
# Enable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false

# Update definitions
Update-MpSignature
```

**3. Firewall Configuration**
```powershell
# Enable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Add inbound rule for TETSUO P2P
New-NetFirewallRule -DisplayName "TETSUO P2P" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8338

# Block RPC port
New-NetFirewallRule -DisplayName "Block TETSUO RPC" -Direction Inbound -Action Block -Protocol TCP -LocalPort 8336
```

### File System Security

**1. Encrypt Data Directory**

Linux (LUKS):
```bash
# Create encrypted container
sudo fallocate -l 1G /tetsuo.img
sudo cryptsetup luksFormat /tetsuo.img
sudo cryptsetup luksOpen /tetsuo.img tetsuo-enc
sudo mkfs.ext4 /dev/mapper/tetsuo-enc
sudo mount /dev/mapper/tetsuo-enc /mnt/tetsuo

# Add to /etc/crypttab for auto-mount
echo "tetsuo-enc /tetsuo.img none luks" | sudo tee -a /etc/crypttab

# Add to /etc/fstab
echo "/dev/mapper/tetsuo-enc /mnt/tetsuo ext4 defaults 0 2" | sudo tee -a /etc/fstab
```

macOS (FileVault):
```bash
# Enable FileVault
diskutil secureErase freespace 0 -secureRandom 32G /Volumes/ExternalDrive

# Or via Settings → Security & Privacy → FileVault
```

**2. File Permissions**
```bash
# Tighten TETSUO data directory
chmod 700 ~/.tetsuo
chmod 600 ~/.tetsuo/tetsuo.conf
chmod 700 ~/.tetsuo/chaindata

# Verify
ls -la ~/.tetsuo/
```

---

## Network Security

### VPN & Network Access

**1. Use VPN for Remote Management**
```bash
# When accessing RPC remotely, use VPN
# Install WireGuard or OpenVPN
sudo apt-get install -y wireguard wireguard-tools

# Generate keys
wg genkey | tee privatekey | wg pubkey > publickey

# Configure VPN tunnel before RPC access
```

**2. IP Whitelisting (Application Level)**

If you must expose RPC (NOT RECOMMENDED):
```bash
# Edit ~/.tetsuo/tetsuo.conf
rpcallowip=192.168.1.100
rpcallowip=10.0.0.0/8
rpcallowip=::1

# Only allow from trusted IPs
```

**3. Reverse Proxy with Authentication**

Using Nginx with HTTP Basic Auth:
```nginx
server {
    listen 8336;
    server_name localhost;

    location / {
        auth_basic "TETSUO RPC";
        auth_basic_user_file /etc/nginx/.htpasswd;

        proxy_pass http://127.0.0.1:8336;
    }
}
```

### DDoS Protection

**1. Rate Limiting (UFW)**
```bash
# Limit connection attempts
sudo ufw limit 8338/tcp comment "TETSUO P2P Rate Limit"
```

**2. Fail2Ban for P2P**
```bash
# /etc/fail2ban/jail.local

[tetsuo-p2p]
enabled = true
port = 8338
filter = tetsuo-p2p
maxretry = 10
findtime = 600
bantime = 86400
```

---

## Node Configuration

### Secure Configuration

**1. Minimal Configuration**
```conf
# ~/.tetsuo/tetsuo.conf - PRODUCTION SETTINGS

# Network
server=1
listen=1
port=8338

# RPC (LOCALHOST ONLY)
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
rpcport=8336

# Security
txindex=1
maxconnections=128
maxinboundconnections=64

# Timeout
timeout=5000

# Logging
logtimestamps=1
logips=0  # Don't log IPs for privacy

# Do NOT use these in production:
# - wallet=1 (use separate wallet)
# - regtest/testnet (unless testing)
# - printtoconsole=1 (use proper logging)
```

**2. Secure Start Script**
```bash
#!/bin/bash
# start-node.sh - Secure node startup

set -e
set -u

# Security variables
WORK_DIR="/path/to/tetsuo-core"
DATA_DIR="${HOME}/.tetsuo"
LOG_DIR="/var/log/tetsuo"

# Create log directory with secure permissions
mkdir -p "$LOG_DIR"
chmod 700 "$LOG_DIR"

# Verify configuration
if [ ! -f "$DATA_DIR/tetsuo.conf" ]; then
    echo "ERROR: Configuration file not found"
    exit 1
fi

# Verify permissions
if [ "$(stat -c%A "$DATA_DIR/tetsuo.conf")" != "-rw-------" ]; then
    echo "ERROR: Configuration file has insecure permissions"
    exit 1
fi

# Start node with proper logging
cd "$WORK_DIR"
ulimit -n 4096  # File descriptor limit

./build/bin/tetsuod \
    -datadir="$DATA_DIR" \
    -logips=0 \
    -logtimestamps=1 \
    -daemon

echo "Node started. Check logs: tail -f $LOG_DIR/debug.log"
```

---

## Monitoring & Alerting

### Health Checks

**1. Node Sync Status**
```bash
#!/bin/bash
# check-sync.sh - Monitor blockchain sync

WORK_DIR="/path/to/tetsuo-core"
DATA_DIR="${HOME}/.tetsuo"

# Get current block count
current=$(${WORK_DIR}/build/bin/tetsuo-cli -datadir=${DATA_DIR} getblockcount)
expected=$(${WORK_DIR}/build/bin/tetsuo-cli -datadir=${DATA_DIR} getblockchaininfo | jq .blocks)

echo "Current: $current / Expected: $expected"

# Alert if behind
if [ $((expected - current)) -gt 100 ]; then
    echo "WARNING: Node is more than 100 blocks behind"
    # Send alert (email, webhook, etc.)
fi
```

**2. Peer Monitoring**
```bash
#!/bin/bash
# check-peers.sh - Monitor peer connections

WORK_DIR="/path/to/tetsuo-core"
DATA_DIR="${HOME}/.tetsuo"

peers=$(${WORK_DIR}/build/bin/tetsuo-cli -datadir=${DATA_DIR} getconnectioncount)

echo "Connected peers: $peers"

if [ "$peers" -lt 1 ]; then
    echo "WARNING: Node has no peer connections"
    # Send alert
fi
```

**3. Disk Space Monitoring**
```bash
#!/bin/bash
# check-disk.sh - Monitor disk usage

DATA_DIR="${HOME}/.tetsuo"
usage=$(du -sh "$DATA_DIR" | cut -f1)
available=$(df -h "$DATA_DIR" | tail -1 | awk '{print $4}')

echo "TETSUO data: $usage / Available: $available"

# Get percentage
percent=$(df "$DATA_DIR" | tail -1 | awk '{print $5}' | sed 's/%//')

if [ "$percent" -gt 80 ]; then
    echo "WARNING: Disk usage above 80%"
    # Send alert
fi
```

### Automated Monitoring with Cron

```bash
# /etc/cron.d/tetsuo-monitoring

# Check sync every 5 minutes
*/5 * * * * root /opt/tetsuo/scripts/check-sync.sh >> /var/log/tetsuo/monitoring.log 2>&1

# Check peers every 10 minutes
*/10 * * * * root /opt/tetsuo/scripts/check-peers.sh >> /var/log/tetsuo/monitoring.log 2>&1

# Check disk space every hour
0 * * * * root /opt/tetsuo/scripts/check-disk.sh >> /var/log/tetsuo/monitoring.log 2>&1
```

### Log Monitoring

```bash
# Monitor for errors in real-time
tail -f ~/.tetsuo/debug.log | grep -i "error\|warning\|critical"

# Count errors per hour
cat ~/.tetsuo/debug.log | grep "error" | cut -d: -f1-2 | uniq -c

# Rotate logs
cat > /etc/logrotate.d/tetsuo << EOF
~/.tetsuo/debug.log {
    daily
    rotate 30
    compress
    delaycompress
    missingok
    notifempty
    create 0600 user user
}
EOF
```

---

## Backup & Recovery

### Regular Backups

**1. Configuration Backup**
```bash
#!/bin/bash
# backup-config.sh

BACKUP_DIR="/backups/tetsuo"
DATA_DIR="${HOME}/.tetsuo"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Backup configuration
tar -czf "$BACKUP_DIR/config_${DATE}.tar.gz" "$DATA_DIR/tetsuo.conf"

# Keep only last 30 days
find "$BACKUP_DIR" -name "config_*.tar.gz" -mtime +30 -delete

echo "Configuration backed up to $BACKUP_DIR/config_${DATE}.tar.gz"
```

**2. Full State Backup (Periodic)**
```bash
#!/bin/bash
# backup-full.sh - Full blockchain backup

BACKUP_DIR="/backups/tetsuo"
DATA_DIR="${HOME}/.tetsuo"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

# Stop node safely
tetsuo-cli stop
sleep 10

# Backup entire state
tar -czf "$BACKUP_DIR/full_backup_${DATE}.tar.gz" "$DATA_DIR"

# Restart node
tetsuod -daemon -datadir="$DATA_DIR"

echo "Full backup completed: $BACKUP_DIR/full_backup_${DATE}.tar.gz"
```

**3. Encrypted Off-Site Backup**
```bash
#!/bin/bash
# backup-offsite.sh

# Encrypt backup
gpg --symmetric --cipher-algo AES256 /backups/tetsuo/config_latest.tar.gz

# Upload to cloud storage (example)
# aws s3 cp /backups/tetsuo/config_latest.tar.gz.gpg s3://backup-bucket/tetsuo/

echo "Encrypted backup uploaded"
```

### Recovery Procedures

**1. Configuration Recovery**
```bash
# Extract configuration backup
tar -xzf /backups/tetsuo/config_YYYYMMDD_HHMMSS.tar.gz -C ~

# Verify
ls -la ~/.tetsuo/tetsuo.conf

# Restart node
tetsuod -daemon -datadir=~/.tetsuo
```

**2. Full State Recovery**
```bash
# Stop node
tetsuo-cli stop

# Remove current data
rm -rf ~/.tetsuo/chaindata
rm ~/.tetsuo/blk0001.dat

# Extract from backup
tar -xzf /backups/tetsuo/full_backup_YYYYMMDD_HHMMSS.tar.gz -C ~

# Restart node
tetsuod -daemon -datadir=~/.tetsuo
```

---

## Incident Response

### Security Incident Procedure

**1. Detection**
- Monitor logs for suspicious activity
- Track unexpected high CPU/memory usage
- Monitor peer connections for anomalies

**2. Initial Response**
```bash
# Gather evidence
tetsuo-cli getpeerinfo > /tmp/incident_peers.json
tetsuo-cli getblockcount > /tmp/incident_blockcount.txt
top -b -n 1 > /tmp/incident_processes.txt
netstat -an > /tmp/incident_connections.txt

# Stop node (if severe)
tetsuo-cli stop

# Preserve logs
cp ~/.tetsuo/debug.log /tmp/incident_debug.log
```

**3. Reporting**
```bash
# Email security team
To: security@tetsuoarena.com
Subject: INCIDENT REPORT: TETSUONODE Potential Security Issue

Description: [Detailed description]
Date/Time: [When discovered]
Severity: [Critical/High/Medium/Low]
Evidence: [Attached files]
Timeline: [What led to discovery]
Actions Taken: [Steps taken so far]
```

**4. Recovery**
```bash
# After incident is resolved:

# Check node integrity
./build/bin/tetsuod -verifychain -datadir=~/.tetsuo

# Restart node
./build/bin/tetsuod -daemon -datadir=~/.tetsuo

# Verify sync
tetsuo-cli getblockcount
```

---

## Compliance Checklist

### Pre-Production Security Checklist

- [ ] **Operating System**
  - [ ] Latest patches and updates applied
  - [ ] Unnecessary services disabled
  - [ ] SSH hardened (non-standard port, key-based auth)
  - [ ] Firewall enabled and configured

- [ ] **Network**
  - [ ] P2P port (8338) open for inbound/outbound
  - [ ] RPC port (8336) blocked for inbound
  - [ ] UFW or iptables rules verified
  - [ ] DDoS protection configured (fail2ban)

- [ ] **File System**
  - [ ] Data directory encrypted (LUKS/FileVault)
  - [ ] File permissions set correctly (700/600)
  - [ ] Sufficient disk space allocated (100GB+)
  - [ ] Backups tested and verified

- [ ] **Node Configuration**
  - [ ] tetsuo.conf reviewed for security
  - [ ] RPC limited to localhost only
  - [ ] Logging enabled with proper rotation
  - [ ] Configuration file permissions (600)

- [ ] **Monitoring**
  - [ ] Health check scripts deployed
  - [ ] Log monitoring configured
  - [ ] Disk space alerts active
  - [ ] Peer connection monitoring active

- [ ] **Incident Response**
  - [ ] Contact information documented
  - [ ] Incident response plan reviewed
  - [ ] Evidence collection procedures understood
  - [ ] Recovery procedures tested

- [ ] **Backup**
  - [ ] Configuration backup strategy in place
  - [ ] Full backups tested monthly
  - [ ] Encrypted off-site backup configured
  - [ ] Recovery procedures documented

### Post-Deployment Security

- [ ] Weekly log review
- [ ] Monthly backup verification
- [ ] Quarterly penetration testing
- [ ] Annual security audit
- [ ] Immediate action on security updates

---

## Additional Resources

### Security Tools

- **Audit**: `aide`, `tripwire` (file integrity monitoring)
- **Monitoring**: `prometheus`, `grafana` (metrics)
- **Logging**: `ELK Stack` (centralized logging)
- **Encryption**: `gpg`, `openssl` (data protection)

### Documentation

- See [SECURITY.md](SECURITY.md) for vulnerability reporting
- See [DEPENDENCIES.md](DEPENDENCIES.md) for dependency updates
- See [SBOM.json](SBOM.json) for supply chain information

### Support

- **Security Contact:** security@tetsuoarena.com
- **GitHub Issues:** https://github.com/Pavelevich/tetsuonode/issues
- **Documentation:** https://github.com/Pavelevich/tetsuonode

---

**This guide should be reviewed and updated quarterly to address new security threats and industry best practices.**

