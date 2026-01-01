# TETSUO Security Policy & Guidelines

> **Security is everyone's responsibility. This document outlines best practices for running TETSUO nodes.**

---

## Table of Contents

- [Security Policy](#security-policy)
- [Installation Security](#installation-security)
- [Node Security](#node-security)
- [Network Security](#network-security)
- [Configuration Security](#configuration-security)
- [Operational Security](#operational-security)
- [Incident Reporting](#incident-reporting)
- [Security Updates](#security-updates)
- [FAQ](#faq)

---

## Security Policy

### Our Commitment

TETSUO takes security seriously. We:

1. **Review code before releases** - Security audits for critical paths
2. **Respond to reports quickly** - Security issues are prioritized
3. **Provide transparency** - Public disclosure after patches
4. **Keep dependencies updated** - Regular security updates
5. **Document best practices** - Help users secure their nodes

### Your Responsibilities

As a node operator, you must:

1. **Keep your system updated** - Apply security patches immediately
2. **Follow best practices** - Use this guide for secure operation
3. **Monitor your node** - Watch for suspicious activity
4. **Report issues** - Inform us of any security concerns
5. **Maintain operational security** - Protect your keys and data

---

## Installation Security

### DO's

✅ **Download the installer, review it, then execute:**
```bash
curl -fsSL -o install.sh https://raw.githubusercontent.com/.../install-linux.sh
cat install.sh  # Review the code
sha256sum install.sh  # Verify checksum
bash install.sh  # Execute
```

✅ **Verify checksums before execution**
- GitHub provides official checksums
- Compare with your downloaded file
- Use `sha256sum` or `shasum` command

✅ **Review the installation script**
- Look for suspicious commands
- Check that code builds from source
- Ensure dependencies are from official repos
- Verify error handling

✅ **Keep your system updated**
- Install OS security patches
- Update build tools
- Update package managers

### DON'Ts

❌ **Never pipe remote scripts to shell:**
```bash
# DANGEROUS - DO NOT DO THIS
curl ... | bash
irm ... | iex
```

❌ **Don't trust HTTPS alone**
- HTTPS prevents tampering in transit
- But can't verify code authenticity
- Always review code before execution

❌ **Don't disable security checks for speed**
- Don't skip configuration security
- Don't skip dependency verification
- Don't skip file permission verification

❌ **Don't run as Administrator unnecessarily**
- Windows: Only needed for service installation
- Linux: Only use sudo for dependency installation
- macOS: Never required for normal installation

---

## Node Security

### File Permissions

**Critical:** Only you should access your data directory.

```bash
# Set correct permissions
chmod 700 ~/.tetsuo/
chmod 600 ~/.tetsuo/tetsuo.conf
chmod 700 ~/tetsuonode/

# Verify permissions
ls -la ~/.tetsuo/
# Output should show: drwx------ (700)
# and: -rw------- (600) for tetsuo.conf
```

### Directory Ownership

Ensure your user owns all TETSUO directories:

```bash
# Check ownership
ls -l ~/.tetsuo
ls -l ~/tetsuonode

# Should show your username, not root
# If wrong, fix it:
chown -R $USER:$USER ~/.tetsuo
chown -R $USER:$USER ~/tetsuonode
```

### Binary Verification

Verify binaries are executable and legitimate:

```bash
# Check if binaries are executable
file ~/tetsuonode/tetsuo-core/build/bin/tetsuod

# Should show: ELF 64-bit executable
# Or on macOS: Mach-O 64-bit executable
# Or on Windows: PE32+ executable

# Check file size (approximate)
ls -lh ~/tetsuonode/tetsuo-core/build/bin/tetsuod
# Should be a reasonable size (not 1KB)
```

### Isolate Node User (Linux Advanced)

For maximum security, run the node as a dedicated user:

```bash
# Create dedicated user
sudo useradd -m -s /bin/false tetsuo

# Install node as dedicated user
sudo -u tetsuo bash install-linux.sh

# Set secure permissions
sudo chmod 750 /home/tetsuo/.tetsuo
sudo chmod 640 /home/tetsuo/.tetsuo/tetsuo.conf

# Run as dedicated user
sudo -u tetsuo ~/tetsuonode/tetsuo-core/build/bin/tetsuod -daemon -datadir=/home/tetsuo/.tetsuo
```

---

## Network Security

### RPC Configuration (Critical)

**Never expose RPC port to the internet!**

```conf
# CORRECT - Localhost only
server=1
rpcport=8336
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
```

```conf
# WRONG - Do NOT do this
rpcallowip=0.0.0.0/0  # Dangerous!
rpcbind=0.0.0.0       # Dangerous!
```

### P2P Network Security

```conf
# Safe P2P settings
port=8338
maxconnections=256
listen=1
```

Your node will:
- Listen on port 8338 for peers
- Accept up to 256 connections
- Only relay legitimate transactions

### Firewall Configuration

**Recommended firewall rules:**

**Linux (ufw):**
```bash
# Allow outbound P2P traffic (automatic)
# Block RPC from outside
ufw allow out from any to any port 8338
ufw deny in to any port 8336  # Block RPC
```

**macOS (pf):**
```bash
# Allow P2P traffic
# Block RPC port 8336
sudo pfctl -e
# Edit /etc/pf.conf as needed
```

**Windows (Windows Defender):**
```powershell
# Block inbound RPC traffic
New-NetFirewallRule -DisplayName "Block TETSUO RPC" `
  -Direction Inbound -Action Block -Protocol TCP -LocalPort 8336
```

### Port Forwarding

**DO NOT port forward RPC port 8336!**

You may forward P2P port 8338 if desired for better connectivity, but:
- Use UPnP if available (safer)
- Or port forward manually to port 8338
- Never forward RPC port 8336

---

## Configuration Security

### Sensitive Settings

Protect these settings:

```conf
# Keep these secrets
# Never share your mineraddress publicly
mineraddress=YOUR_ADDRESS

# RPC credentials (if set)
rpcuser=tetsuouser
rpcpassword=STRONG_PASSWORD_HERE
```

### Configuration File Access

```bash
# Verify only you can read the config
ls -l ~/.tetsuo/tetsuo.conf
# Should show: -rw------- (600)

# If accessible by others, fix it
chmod 600 ~/.tetsuo/tetsuo.conf
```

### Secure Defaults

Our installation provides secure defaults:

- RPC localhost only: `rpcallowip=127.0.0.1`
- P2P open for connectivity: `port=8338`
- Database indexed: `txindex=1`
- Reasonable connections: `maxconnections=256`

### Custom Configurations

If you modify config, ensure:

1. RPC remains localhost: `rpcallowip=127.0.0.1`
2. Port is not exposed (firewall)
3. File permissions are correct (600)
4. No plaintext credentials in files

---

## Operational Security

### Regular Monitoring

```bash
# Daily checks
tail -50 ~/.tetsuo/debug.log  # Any errors?

# Weekly checks
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getpeerinfo | wc -l  # Enough peers?
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount  # Synced?

# Monthly checks
df -h ~/  # Still have disk space?
free -h  # Memory usage normal?
ps aux | grep tetsuod  # Process running?
```

### Security Updates

1. **Monitor for updates**
   - Check GitHub repository regularly
   - Subscribe to releases: https://github.com/Pavelevich/tetsuonode/releases

2. **When updates available**
   - Review the changelog
   - Check if it's a security update
   - Stop your node if critical
   - Re-run installation to update

3. **System updates**
   - Always apply OS security patches
   - Keep build tools updated
   - Update package managers

### Backup Strategy

**What to backup:**

```bash
# Configuration (essential)
cp ~/.tetsuo/tetsuo.conf ~/tetsuo-backup.conf

# Do NOT backup private keys unless you have them locally
# The blockchain data will re-sync automatically
```

**Where to backup:**

- Secure external drive (encrypted)
- Cloud storage with strong encryption
- Multiple locations (redundancy)

### Disaster Recovery

If your node is compromised:

1. **Stop the node immediately:**
   ```bash
   ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo stop
   ```

2. **Preserve evidence:**
   ```bash
   # Copy logs for forensics
   cp ~/.tetsuo/debug.log ~/tetsuo-debug-backup.log
   ```

3. **Wipe and reinstall:**
   ```bash
   # Remove compromised installation
   rm -rf ~/.tetsuo/
   rm -rf ~/tetsuonode/

   # Follow installation guide from scratch
   ```

4. **Report the incident:**
   - GitHub: https://github.com/Pavelevich/tetsuonode/issues
   - Email: security@tetsuoarena.com

---

## Incident Reporting

### Security Vulnerability Reporting

**If you discover a security issue:**

1. **Do NOT post publicly** - This gives attackers time to exploit

2. **Report privately:**
   - Email: security@tetsuoarena.com
   - GitHub Security Advisory: Contact maintainers privately
   - Twitter DM: @tetsuoarena

3. **Include in report:**
   - Detailed description of the issue
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)
   - Your contact information

4. **What we do:**
   - Acknowledge receipt within 24 hours
   - Assess severity
   - Work on fix
   - Coordinate disclosure timeline
   - Credit you (if desired)

### Expected Timeline

- **Critical** - Fixed within 24 hours, released immediately
- **High** - Fixed within 1 week, released in next update
- **Medium** - Fixed within 2 weeks, released in next update
- **Low** - Fixed in next regular release

---

## Security Best Practices Summary

### System Level

- [ ] OS is fully updated
- [ ] Firewall is enabled
- [ ] SSH is secured (if applicable)
- [ ] Only necessary services running
- [ ] Regular system backups

### Application Level

- [ ] Installer reviewed before execution
- [ ] Installation from verified source
- [ ] Checksums verified
- [ ] File permissions correct (600 config, 700 directory)
- [ ] Binary verification complete

### Network Level

- [ ] RPC port not exposed (firewall blocks)
- [ ] P2P port open for connectivity
- [ ] Firewall rules configured
- [ ] No port forwarding of RPC port
- [ ] HTTPS-only connections

### Operational Level

- [ ] Node monitored regularly
- [ ] Logs reviewed for errors
- [ ] Peers connected (8+ recommended)
- [ ] Blockchain syncing
- [ ] Updates applied promptly

### Security Level

- [ ] Backups in secure location
- [ ] Disaster recovery plan
- [ ] Incident response plan
- [ ] Know how to report security issues
- [ ] Stay informed about updates

---

## FAQ

### Is it safe to run TETSUO on my personal computer?

Yes, with caution:
- Your node doesn't store wallets (no private keys)
- The data directory contains blockchain data (public info)
- Your RPC port is localhost-only (not exposed)
- Risk is low if you follow security practices

**Not safe:**
- Exposing RPC port to internet
- Running as Administrator
- Using weak firewall rules

### What if my computer is stolen?

The blockchain data is public, so:
- Attacker can't steal funds (no keys stored)
- Your node configuration is exposed (mineraddress is known)
- Your network activity might be exposed
- Mitigation: Run on dedicated hardware, not laptop

### How often should I update?

- **Security updates** - Immediately
- **Regular updates** - Monthly or quarterly
- **Critical bugs** - Within 24 hours
- **Features** - When convenient

Check releases: https://github.com/Pavelevich/tetsuonode/releases

### Can I run multiple nodes?

Yes, but:
- Each needs separate data directory
- Each needs different configuration
- Not required for TETSUO network
- Useful for redundancy or dedicated mining

### What's the minimum security setup?

1. Download and review installer
2. Run installer (not as Administrator)
3. Keep RPC localhost-only
4. Monitor logs occasionally
5. Apply security updates promptly

### Is macOS/Linux/Windows secure?

All platforms are equally secure if:
- You follow the installation guide
- You set file permissions correctly
- You keep your OS updated
- You maintain good operational security

Relative security: **Linux ≥ macOS ≥ Windows** (but all are fine)

### Should I run a node behind a VPN?

Optional trade-offs:

**With VPN:**
- ✅ More privacy
- ✅ IP not directly exposed to peers
- ❌ Slightly slower
- ❌ VPN provider can see traffic

**Without VPN:**
- ✅ Fastest performance
- ✅ Direct connectivity
- ❌ IP exposed to peers (normal)
- ❌ Less privacy

**Recommendation:** Not necessary for node operators, only if you value privacy.

### Can hackers access my node through P2P port?

Unlikely if:
- You're using the latest version (patches security bugs)
- Your OS is updated (patches kernel exploits)
- You follow this guide

P2P protocol is designed to be:
- Robust against attacks
- Resistant to DoS
- Safe even when exposed

---

## Additional Resources

- **Installation Guide**: docs/INSTALL.md
- **Mining Guide**: docs/MINING.md
- **Configuration Guide**: docs/CONFIG.md
- **GitHub Issues**: https://github.com/Pavelevich/tetsuonode/issues
- **Block Explorer**: https://tetsuoarena.com
- **Twitter**: @tetsuoarena

---

## Security Checklist

```bash
#!/bin/bash
# Run this script regularly to verify security

echo "TETSUO Security Checklist"
echo "=========================="

echo ""
echo "1. File Permissions:"
PERM=$(stat -f %A ~/.tetsuo/tetsuo.conf 2>/dev/null || stat -c %a ~/.tetsuo/tetsuo.conf)
if [ "$PERM" = "600" ]; then
    echo "✓ Config file permissions correct (600)"
else
    echo "✗ Config file permissions incorrect: $PERM (should be 600)"
fi

echo ""
echo "2. Node Status:"
if pgrep tetsuod > /dev/null; then
    echo "✓ Node is running"
else
    echo "✗ Node is not running"
fi

echo ""
echo "3. RPC Configuration:"
if grep -q "rpcallowip=127.0.0.1" ~/.tetsuo/tetsuo.conf; then
    echo "✓ RPC is localhost-only"
else
    echo "✗ RPC may be exposed"
fi

echo ""
echo "4. Disk Space:"
SPACE=$(df ~/.tetsuo | tail -1 | awk '{print $4}')
if [ "$SPACE" -gt 2000000 ]; then
    echo "✓ Sufficient disk space available"
else
    echo "✗ Low disk space"
fi

echo ""
echo "5. Recent Logs:"
if tail -1 ~/.tetsuo/debug.log | grep -q "ERROR"; then
    echo "✗ Recent errors in logs"
    tail -5 ~/.tetsuo/debug.log
else
    echo "✓ No recent errors"
fi

echo ""
echo "Security checklist complete!"
```

Save as `security-check.sh`, make executable, run regularly:
```bash
chmod +x security-check.sh
./security-check.sh
```

---

**Security is a journey, not a destination. Stay informed, stay safe.**
