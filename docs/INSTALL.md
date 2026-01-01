# Secure TETSUO Node Installation Guide

> **Installation done right - Verify everything, trust nothing.**

---

## Table of Contents

- [Security First](#security-first)
- [Safe Installation - macOS](#safe-installation---macos)
- [Safe Installation - Linux](#safe-installation---linux)
- [Safe Installation - Windows](#safe-installation---windows)
- [Verification Checklist](#verification-checklist)
- [Troubleshooting](#troubleshooting)

---

## Security First

### Why Secure Installation Matters

Installing a blockchain node requires downloading and executing code. This guide ensures:

1. **Code Authenticity** - You download the actual code, not a malicious variant
2. **Code Integrity** - The code hasn't been modified in transit
3. **Code Review** - You can inspect the code before execution
4. **Trust Verification** - You verify repository authenticity

### What We Don't Do

We **DO NOT** recommend:
- ❌ Piping remote scripts directly to shell: `curl ... | bash`
- ❌ Executing unsigned/unverified code
- ❌ Trusting HTTPS alone (no signature verification)
- ❌ Running installers as Administrator unnecessarily
- ❌ Disabling security checks for convenience

---

## Safe Installation - macOS

### Step 1: Download the Installer

```bash
# Create a temporary directory
mkdir -p ~/tetsuonode-install
cd ~/tetsuonode-install

# Download the macOS installer
curl -fsSL -o install-macos.sh \
  https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-macos.sh
```

### Step 2: Verify the Download

**Display the script to review it:**

```bash
cat install-macos.sh
```

**What to look for:**
- Code should match the repository on GitHub
- Look for malicious commands (especially `curl | bash` patterns)
- Verify it's building from source, not installing precompiled binaries
- Check that dependencies are from legitimate sources

**If the code looks good, continue. If anything looks suspicious, stop here.**

### Step 3: Verify Checksum (Optional but Recommended)

Get the checksum from the GitHub repository and verify:

```bash
# After reviewing the code, calculate its checksum
shasum -a 256 install-macos.sh

# Compare with the official checksum from:
# https://github.com/Pavelevich/tetsuonode/blob/main/CHECKSUMS.sha256
```

### Step 4: Execute the Installer

```bash
chmod +x install-macos.sh
./install-macos.sh
```

**The installer will:**
1. Validate your macOS environment
2. Install Homebrew (if needed)
3. Install build dependencies
4. Clone the TETSUO repository
5. Verify dependencies were installed
6. Build TETSUO Core from source
7. Verify build artifacts
8. Create secure configuration
9. Show security warnings
10. Optionally start your node

---

## Safe Installation - Linux

### Step 1: Download the Installer

```bash
# Create a temporary directory
mkdir -p ~/tetsuonode-install
cd ~/tetsuonode-install

# Download the Linux installer
curl -fsSL -o install-linux.sh \
  https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-linux.sh
```

### Step 2: Review the Code

```bash
# Display and review
cat install-linux.sh

# What to verify:
# - Distribution detection is safe (uses grep, not source)
# - Dependencies are from official repositories
# - Build from source, not precompiled binaries
# - Proper error handling and validation
```

### Step 3: Verify Checksum

```bash
# Calculate checksum
sha256sum install-linux.sh

# Verify against official checksums:
# https://github.com/Pavelevich/tetsuonode/blob/main/CHECKSUMS.sha256
```

### Step 4: Execute the Installer

```bash
chmod +x install-linux.sh
./install-linux.sh
```

**The installer:**
- Detects your Linux distribution safely
- Installs dependencies specific to your distro
- Verifies dependencies after installation
- Builds TETSUO Core from source
- Validates build artifacts
- Sets secure file permissions
- Creates configuration
- Shows security warnings

### Supported Distributions

- **Debian/Ubuntu** - apt-get based
- **Fedora/RHEL/CentOS** - dnf/yum based
- **Arch Linux** - pacman based

---

## Safe Installation - Windows

### Step 1: Prerequisites

**Install Git for Windows:**
- Download: https://git-scm.com/download/win
- Run the installer
- Use default settings

**Install Microsoft C++ Build Tools:**
- Download: https://visualstudio.microsoft.com/downloads/
- Select "Desktop development with C++"
- Run the installer

### Step 2: Download the Installer

```powershell
# Create a temporary directory
New-Item -ItemType Directory -Path "$env:USERPROFILE\tetsuonode-install" -Force
Set-Location "$env:USERPROFILE\tetsuonode-install"

# Download the Windows installer
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-windows.ps1" `
  -OutFile "install-windows.ps1"
```

### Step 3: Review the Code

```powershell
# Display and review
Get-Content install-windows.ps1

# What to verify:
# - Checks for Git and C++ compiler
# - No Administrator check (not required)
# - Builds from source
# - Proper error handling
# - Sets secure permissions
```

### Step 4: Run the Installer

**Do NOT run as Administrator** - it's not needed for the main installation.

```powershell
# Set execution policy for current user
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Run the installer
.\install-windows.ps1
```

### Step 5: Start Your Node

After installation completes:

```powershell
# Navigate to the installation directory
cd "$env:USERPROFILE\tetsuonode\tetsuo-core\build\Release"

# Start the node
.\tetsuod.exe -datadir="$env:APPDATA\Tetsuo\.tetsuo"
```

---

## Verification Checklist

After installation, verify everything worked correctly:

```bash
# 1. Check if node is running
ps aux | grep tetsuod

# 2. Check configuration file exists and is readable only by you
ls -la ~/.tetsuo/tetsuo.conf
# Should show: -rw------- (600 permissions)

# 3. Check binaries exist and are executable
ls -la ~/tetsuonode/tetsuo-core/build/bin/
# Should show x for owner

# 4. Verify blockchain is syncing
cd ~/tetsuonode/tetsuo-core
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount

# 5. Check for any suspicious logs
tail -50 ~/.tetsuo/debug.log

# 6. Verify network connections
./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getpeerinfo
```

---

## Security Best Practices

### Before Installation

- [ ] Review the installer script in your text editor
- [ ] Check the GitHub repository for the latest version
- [ ] Verify you're on a secure network
- [ ] Ensure your system is up to date
- [ ] Disable VPN/Proxy if possible for downloading

### During Installation

- [ ] Don't run unattended (monitor the process)
- [ ] Watch for any unusual messages or errors
- [ ] Don't provide unnecessary permissions
- [ ] Keep your terminal window visible

### After Installation

- [ ] Verify file permissions on configuration
- [ ] Check that only you have access to the data directory
- [ ] Review the configuration for security settings
- [ ] Enable firewall rules if applicable
- [ ] Keep your system updated
- [ ] Monitor for suspicious activity

---

## Troubleshooting

### "Command not found: curl"

macOS and Linux systems usually have `curl` pre-installed. If not:

```bash
# macOS
brew install curl

# Ubuntu/Debian
sudo apt-get install curl

# Fedora
sudo dnf install curl
```

### Installer Fails at Dependency Installation

**macOS:**
```bash
# Ensure Homebrew is up to date
brew update
brew upgrade
```

**Linux:**
```bash
# Ensure package lists are up to date
sudo apt-get update  # Ubuntu/Debian
sudo dnf update      # Fedora
```

### Build Fails

Common causes:
1. **Insufficient disk space** - Need at least 5 GB free
2. **Insufficient RAM** - Close other applications
3. **Compiler errors** - Ensure build tools are properly installed
4. **Missing dependencies** - Re-run installer or install manually

**Check available space:**
```bash
df -h ~/
```

**Check RAM:**
```bash
# macOS
vm_stat

# Linux
free -h

# Windows PowerShell
Get-WmiObject Win32_OperatingSystem | Select TotalVisibleMemorySize
```

### "Permission denied" on Configuration File

This shouldn't happen with the new installer, but if it does:

```bash
chmod 600 ~/.tetsuo/tetsuo.conf
chmod 700 ~/.tetsuo/
```

### Node Won't Start

```bash
# Check if binary exists
ls -la ~/tetsuonode/tetsuo-core/build/bin/tetsuod

# Check for errors
~/tetsuonode/tetsuo-core/build/bin/tetsuod -daemon -datadir=$HOME/.tetsuo -printtoconsole

# Check logs
tail -f ~/.tetsuo/debug.log
```

---

## Security Incident Response

If you suspect a security issue:

1. **Stop your node immediately:**
   ```bash
   ./build/bin/tetsuo-cli -datadir=$HOME/.tetsuo stop
   ```

2. **Check for unauthorized access:**
   ```bash
   ls -la ~/.tetsuo/
   ls -la ~/tetsuonode/
   ```

3. **Review recent logs:**
   ```bash
   tail -100 ~/.tetsuo/debug.log
   ```

4. **Report the issue:**
   - GitHub Issues: https://github.com/Pavelevich/tetsuonode/issues
   - Twitter: @tetsuoarena
   - Email: security@tetsuoarena.com

5. **Wipe and reinstall if compromised:**
   ```bash
   rm -rf ~/.tetsuo/
   rm -rf ~/tetsuonode/
   # Then reinstall following this guide
   ```

---

## Additional Resources

- **GitHub Repository**: https://github.com/Pavelevich/tetsuonode
- **Mining Guide**: docs/MINING.md
- **Configuration Guide**: docs/CONFIG.md
- **Security Policy**: docs/SECURITY.md
- **Block Explorer**: https://tetsuoarena.com

---

## Verification Commands Reference

```bash
# Full verification workflow
echo "=== Checking Installation ==="
echo "1. Node process:"
ps aux | grep tetsuod | grep -v grep

echo ""
echo "2. Configuration file permissions:"
ls -la ~/.tetsuo/tetsuo.conf

echo ""
echo "3. Data directory:"
ls -la ~/.tetsuo/

echo ""
echo "4. Blockchain status:"
~/tetsuonode/tetsuo-core/build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getblockcount

echo ""
echo "5. Network peers:"
~/tetsuonode/tetsuo-core/build/bin/tetsuo-cli -datadir=$HOME/.tetsuo getpeerinfo | wc -l

echo ""
echo "6. Recent logs:"
tail -20 ~/.tetsuo/debug.log
```

---

**Installation complete? See MINING.md to start earning TETSUO!**
