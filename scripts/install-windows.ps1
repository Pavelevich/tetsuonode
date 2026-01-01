# TETSUO Node Installer for Windows
# Run with: irm https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-windows.ps1 | iex

Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host "                    🚀 TETSUO NODE - WINDOWS INSTALLER" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
if (-not $isAdmin) {
    Write-Host "❌ This script must be run as Administrator" -ForegroundColor Red
    Write-Host "Please run PowerShell as Administrator and try again"
    exit 1
}

Write-Host "📦 Checking prerequisites..."
Write-Host ""

# Check for Git
if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Host "✅ Git found"
} else {
    Write-Host "❌ Git not found. Please install from: https://git-scm.com/download/win"
    exit 1
}

# Check for Visual Studio Build Tools or MSVC
$hasMSVC = $false
if (Get-Command cl -ErrorAction SilentlyContinue) {
    Write-Host "✅ Microsoft C++ Compiler found"
    $hasMSVC = $true
} else {
    Write-Host "⚠️  Microsoft C++ Build Tools not found"
    Write-Host "   Download from: https://visualstudio.microsoft.com/downloads/"
    Write-Host "   Select 'Desktop development with C++'"
    Write-Host ""
    $response = Read-Host "Continue anyway? (y/n)"
    if ($response -ne 'y') {
        exit 1
    }
}

Write-Host ""
Write-Host "📥 Cloning TETSUO Core..."
$workDir = "$env:USERPROFILE\tetsuonode"
if (Test-Path $workDir) {
    Remove-Item -Path $workDir -Recurse -Force
}
git clone https://github.com/Pavelevich/tetsuonode.git $workDir

cd "$workDir\tetsuo-core"

Write-Host ""
Write-Host "⚙️  Creating configuration directory..."
$dataDir = "$env:APPDATA\Tetsuo\.tetsuo"
if (-not (Test-Path $dataDir)) {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
}

Write-Host "📝 Creating configuration file..."
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

Set-Content -Path "$dataDir\tetsuo.conf" -Value $confContent

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host "                     ✅ INSTALLATION COMPLETED" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "📍 Node location: $workDir\tetsuo-core\build\Release"
Write-Host "📍 Config file: $dataDir\tetsuo.conf"
Write-Host ""
Write-Host "🚀 START YOUR NODE:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Open Command Prompt or PowerShell"
Write-Host "  2. Navigate to: cd $workDir\tetsuo-core\build\Release"
Write-Host "  3. Run: .\tetsuod.exe -datadir=""$dataDir"""
Write-Host ""
Write-Host "✅ VERIFY INSTALLATION:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  .\tetsuo-cli.exe -datadir=""$dataDir"" getblockcount"
Write-Host ""
Write-Host "⛏️  TO ENABLE MINING:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Edit: $dataDir\tetsuo.conf"
Write-Host "  2. Set your address in mineraddress=..."
Write-Host "  3. Uncomment mine=1 and threads=4"
Write-Host "  4. Restart node"
Write-Host ""
Write-Host "📊 MONITOR YOUR NODE:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  https://tetsuoarena.com"
Write-Host ""
Write-Host "🪟 RUN AS WINDOWS SERVICE (optional):" -ForegroundColor Yellow
Write-Host ""
Write-Host "  nssm install TETSUOD $workDir\tetsuo-core\build\Release\tetsuod.exe"
Write-Host "  nssm set TETSUOD AppParameters ""-datadir=$dataDir"""
Write-Host "  nssm start TETSUOD"
Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════════════════════"
Write-Host ""

$response = Read-Host "Would you like to open the node folder now? (y/n)"
if ($response -eq 'y') {
    Invoke-Item $workDir
}

Write-Host ""
Write-Host "✨ Installation complete! Next steps:"
Write-Host "  1. Edit the configuration file if needed"
Write-Host "  2. Run tetsuod.exe to start your node"
Write-Host "  3. Monitor progress at https://tetsuoarena.com"
Write-Host ""
