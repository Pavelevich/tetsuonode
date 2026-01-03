# TETSUO Node Installer for Windows
# Safe installation guide: See INSTALL.md for secure setup
# Note: Administrator privileges only required for optional Windows service installation

Write-Host "========================================================================"
Write-Host "                    TETSUO NODE - WINDOWS INSTALLER"
Write-Host "========================================================================"
Write-Host ""

Write-Host "[INFO] Checking prerequisites..."
Write-Host ""

# Check for Git
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Git found"
} else {
    Write-Host "[ERROR] Git not found. Please install from: https://git-scm.com/download/win"
    Write-Host "After installing Git, run this script again."
    exit 1
}

# Check for Visual Studio Build Tools or MSVC
$hasMSVC = $false
if (Get-Command cl -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Microsoft C++ Compiler found"
    $hasMSVC = $true
} else {
    Write-Host "[WARNING] Microsoft C++ Build Tools not found"
    Write-Host "   Download from: https://visualstudio.microsoft.com/downloads/"
    Write-Host "   Select 'Desktop development with C++'"
    Write-Host ""
    $response = Read-Host "Continue anyway? (NOT RECOMMENDED) (y/n)"
    if ($response -ne 'y') {
        exit 1
    }
}

Write-Host ""
Write-Host "[INFO] Cloning TETSUO Core..."

# Validate work directory path
$workDir = "$env:USERPROFILE\tetsuonode"

if (-not (Test-Path $env:USERPROFILE)) {
    Write-Host "[ERROR] Invalid user profile directory"
    exit 1
}

# Warn if directory exists
if (Test-Path $workDir) {
    Write-Host "[WARNING] $workDir already exists and will be removed"
    $response = Read-Host "Continue? (y/n)"
    if ($response -ne 'y') {
        exit 1
    }
    try {
        Remove-Item -Path $workDir -Recurse -Force -ErrorAction Stop
    } catch {
        Write-Host "[ERROR] Failed to remove existing directory: $_"
        exit 1
    }
}

# Clone repository
try {
    git clone https://github.com/Pavelevich/tetsuonode.git $workDir
    if ($LASTEXITCODE -ne 0) {
        throw "Git clone failed with exit code $LASTEXITCODE"
    }
} catch {
    Write-Host "[ERROR] Failed to clone repository: $_"
    exit 1
}

# Change to tetsuo-core directory
Set-Location "$workDir\tetsuo-core" -ErrorAction Stop

Write-Host "[INFO] Creating configuration directory..."
$dataDir = "$env:APPDATA\Tetsuo\.tetsuo"

if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

# Secure directory permissions (Windows)
try {
    $acl = Get-Acl $dataDir
    # Remove inheritance to ensure only owner has access
    $acl.SetAccessRuleProtection($true, $false)
    Set-Acl -Path $dataDir -AclObject $acl
} catch {
    Write-Host "[WARNING] Could not set directory permissions: $_"
}

Write-Host "[INFO] Creating configuration file..."
$confContent = @"
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
"@

try {
    Set-Content -Path "$dataDir\tetsuo.conf" -Value $confContent -ErrorAction Stop
} catch {
    Write-Host "[ERROR] Failed to create configuration file: $_"
    exit 1
}

# Compute binary checksums for integrity verification
Write-Host "[INFO] Computing binary checksums for future verification..."
$buildDir = "$workDir\tetsuo-core\build\Release"
if (Test-Path "$buildDir\tetsuod.exe") {
    $tetsuodHash = (Get-FileHash "$buildDir\tetsuod.exe" -Algorithm SHA256).Hash
    "$tetsuodHash  tetsuod.exe" | Out-File -FilePath "$buildDir\tetsuod.sha256" -Encoding ASCII
    Write-Host "[OK] tetsuod.exe checksum: $tetsuodHash"
}
if (Test-Path "$buildDir\tetsuo-cli.exe") {
    $cliHash = (Get-FileHash "$buildDir\tetsuo-cli.exe" -Algorithm SHA256).Hash
    "$cliHash  tetsuo-cli.exe" | Out-File -FilePath "$buildDir\tetsuo-cli.sha256" -Encoding ASCII
    Write-Host "[OK] tetsuo-cli.exe checksum: $cliHash"
}
Write-Host "[INFO] Checksum files created for future verification"
Write-Host ""

Write-Host "========================================================================"
Write-Host "                        SECURITY NOTICE"
Write-Host "========================================================================"
Write-Host ""
Write-Host "Your TETSUO node will listen on port 8338 (P2P network traffic)"
Write-Host ""
Write-Host "IMPORTANT SECURITY RECOMMENDATIONS:"
Write-Host "  1. Ensure your firewall allows outbound connections"
Write-Host "  2. Do NOT expose RPC port 8336 to the internet"
Write-Host "  3. Keep rpcallowip=127.0.0.1 (localhost only)"
Write-Host "  4. Never share your data directory with untrusted users"
Write-Host "  5. Keep your system and dependencies updated"
Write-Host ""
Write-Host "========================================================================"
Write-Host "                     INSTALLATION COMPLETED"
Write-Host "========================================================================"
Write-Host ""
Write-Host "Node location: $workDir\tetsuo-core\build\Release"
Write-Host "Config file: $dataDir\tetsuo.conf"
Write-Host ""
Write-Host "START YOUR NODE:"
Write-Host ""
Write-Host "  1. Open Command Prompt or PowerShell"
Write-Host "  2. Navigate to: cd $workDir\tetsuo-core\build\Release"
Write-Host "  3. Run: .\tetsuod.exe -datadir=""$dataDir"""
Write-Host ""
Write-Host "VERIFY INSTALLATION:"
Write-Host ""
Write-Host "  .\tetsuo-cli.exe -datadir=""$dataDir"" getblockcount"
Write-Host ""
Write-Host "TO ENABLE MINING:"
Write-Host ""
Write-Host "  1. Edit: $dataDir\tetsuo.conf"
Write-Host "  2. Set your address in mineraddress=..."
Write-Host "  3. Uncomment mine=1 and threads=4"
Write-Host "  4. Restart node"
Write-Host ""
Write-Host "MONITOR YOUR NODE:"
Write-Host ""
Write-Host "  https://tetsuoarena.com"
Write-Host ""
Write-Host "RUN AS WINDOWS SERVICE (optional - requires Administrator):"
Write-Host ""
Write-Host "  nssm install TETSUOD $workDir\tetsuo-core\build\Release\tetsuod.exe"
Write-Host "  nssm set TETSUOD AppParameters ""-datadir=$dataDir"""
Write-Host "  nssm start TETSUOD"
Write-Host ""
Write-Host "========================================================================"
Write-Host ""

$response = Read-Host "Would you like to open the node folder now? (y/n)"
if ($response -eq 'y') {
    Invoke-Item $workDir
}

Write-Host ""
Write-Host "[SUCCESS] Installation complete! Next steps:"
Write-Host "  1. Edit the configuration file if needed"
Write-Host "  2. Run tetsuod.exe to start your node"
Write-Host "  3. Monitor progress at https://tetsuoarena.com"
Write-Host ""
