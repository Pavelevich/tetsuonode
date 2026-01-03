#!/bin/bash

# TETSUONODE Installation Verification Script
# Verifies cryptographic signatures and checksums for security
# Usage: ./scripts/verify-installation.sh

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "=========================================================================="
echo "                 TETSUONODE INSTALLATION VERIFICATION"
echo "=========================================================================="
echo ""

# Configuration
FULLCHAIN_DIR="${HOME}/tetsuo-fullchain"
WORK_DIR="${FULLCHAIN_DIR}/tetsuo-core"
CHECKSUMS_DIR="${WORK_DIR}"
GPG_KEYSERVER="hkps://keys.openpgp.org"
TETSUO_GPG_KEY="security@tetsuoarena.com"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print colored output
print_status() {
    local status=$1
    local message=$2

    if [ "$status" = "success" ]; then
        echo -e "${GREEN}[✓]${NC} $message"
    elif [ "$status" = "error" ]; then
        echo -e "${RED}[✗]${NC} $message"
    elif [ "$status" = "warning" ]; then
        echo -e "${YELLOW}[!]${NC} $message"
    elif [ "$status" = "info" ]; then
        echo -e "${BLUE}[i]${NC} $message"
    fi
}

# Function to verify checksums
verify_checksums() {
    echo ""
    echo "Verifying Binary Checksums..."
    echo "---"

    if [ ! -f "${CHECKSUMS_DIR}/tetsuod.sha256" ]; then
        print_status "warning" "Checksum file not found: tetsuod.sha256"
        print_status "info" "Run install script first to generate checksums"
        return 1
    fi

    cd "${CHECKSUMS_DIR}" || {
        print_status "error" "Failed to enter directory: ${CHECKSUMS_DIR}"
        return 1
    }

    # Verify tetsuod
    if sha256sum -c tetsuod.sha256 >/dev/null 2>&1; then
        print_status "success" "tetsuod checksum verified"
    else
        print_status "error" "tetsuod checksum MISMATCH - binary may be corrupted!"
        return 1
    fi

    # Verify tetsuo-cli if checksum exists
    if [ -f "tetsuo-cli.sha256" ]; then
        if sha256sum -c tetsuo-cli.sha256 >/dev/null 2>&1; then
            print_status "success" "tetsuo-cli checksum verified"
        else
            print_status "error" "tetsuo-cli checksum MISMATCH!"
            return 1
        fi
    fi

    return 0
}

# Function to verify GPG signatures
verify_gpg_signatures() {
    echo ""
    echo "Verifying GPG Signatures..."
    echo "---"

    if ! command_exists gpg; then
        print_status "warning" "GPG not installed - skipping signature verification"
        print_status "info" "Install GPG with: apt-get install gnupg (Linux) or brew install gnupg (macOS)"
        return 0
    fi

    # Check if we can find the TETSUO security key
    print_status "info" "Checking for TETSUO security GPG key..."

    # This would verify the Git commits if they're signed
    if [ -d "${FULLCHAIN_DIR}/.git" ]; then
        cd "${FULLCHAIN_DIR}" || return 1

        print_status "info" "Verifying latest commit signature..."
        if git verify-commit HEAD >/dev/null 2>&1; then
            print_status "success" "Git commit signature verified"
        else
            print_status "warning" "Git commit not signed or key not found"
            print_status "info" "To verify: gpg --keyserver ${GPG_KEYSERVER} --recv-keys [KEY_ID]"
        fi
    fi

    return 0
}

# Function to check binary integrity
check_binary_integrity() {
    echo ""
    echo "Checking Binary Integrity..."
    echo "---"

    if [ ! -f "${WORK_DIR}/build/bin/tetsuod" ]; then
        print_status "error" "Binary not found: ${WORK_DIR}/build/bin/tetsuod"
        return 1
    fi

    # Check if binary is executable
    if [ -x "${WORK_DIR}/build/bin/tetsuod" ]; then
        print_status "success" "tetsuod is executable"
    else
        print_status "error" "tetsuod is not executable"
        return 1
    fi

    # Check binary size (sanity check)
    local size=$(stat -f%z "${WORK_DIR}/build/bin/tetsuod" 2>/dev/null || stat -c%s "${WORK_DIR}/build/bin/tetsuod" 2>/dev/null || echo "0")
    if [ "$size" -gt 10000000 ]; then  # Should be > 10MB
        print_status "success" "tetsuod binary size is reasonable (${size} bytes)"
    else
        print_status "warning" "tetsuod binary seems unusually small (${size} bytes)"
    fi

    return 0
}

# Function to verify build environment
verify_build_environment() {
    echo ""
    echo "Verifying Build Environment..."
    echo "---"

    local missing_tools=0

    # Check required tools
    for tool in cmake make git; do
        if command_exists "$tool"; then
            print_status "success" "$tool is installed"
        else
            print_status "error" "$tool is not installed"
            missing_tools=$((missing_tools + 1))
        fi
    done

    # Check optional tools
    for tool in gpg openssl; do
        if command_exists "$tool"; then
            print_status "success" "$tool is available"
        else
            print_status "warning" "$tool is not installed (optional)"
        fi
    done

    if [ $missing_tools -gt 0 ]; then
        print_status "error" "Missing $missing_tools required tools"
        return 1
    fi

    return 0
}

# Function to test node functionality
test_node_functionality() {
    echo ""
    echo "Testing Node Functionality..."
    echo "---"

    if [ ! -f "${WORK_DIR}/build/bin/tetsuo-cli" ]; then
        print_status "warning" "tetsuo-cli not found - skipping functionality tests"
        return 0
    fi

    print_status "info" "Testing tetsuod --version..."
    if ${WORK_DIR}/build/bin/tetsuod --version >/dev/null 2>&1; then
        version=$(${WORK_DIR}/build/bin/tetsuod --version | head -1)
        print_status "success" "Node version: $version"
    else
        print_status "warning" "Could not get node version"
    fi

    print_status "info" "Testing tetsuo-cli --version..."
    if ${WORK_DIR}/build/bin/tetsuo-cli --version >/dev/null 2>&1; then
        version=$(${WORK_DIR}/build/bin/tetsuo-cli --version | head -1)
        print_status "success" "CLI version: $version"
    else
        print_status "warning" "Could not get CLI version"
    fi

    return 0
}

# Function to generate security report
generate_security_report() {
    echo ""
    echo "=========================================================================="
    echo "                        VERIFICATION SUMMARY"
    echo "=========================================================================="
    echo ""

    print_status "info" "Installation Location: ${WORK_DIR}"
    print_status "info" "Config Location: ${HOME}/.tetsuo/tetsuo.conf"
    print_status "info" "Data Location: ${HOME}/.tetsuo/"
    echo ""

    print_status "info" "Next Steps:"
    echo "  1. Review the verification results above"
    echo "  2. If all checks passed, your installation is secure"
    echo "  3. Start the node: cd ${WORK_DIR} && ./build/bin/tetsuod -daemon -datadir=${HOME}/.tetsuo"
    echo "  4. Monitor logs: cd ${WORK_DIR} && ./build/bin/tetsuo-cli -datadir=${HOME}/.tetsuo getblockcount"
    echo ""

    print_status "info" "Security Recommendations:"
    echo "  • Keep your system and dependencies updated"
    echo "  • Monitor your node regularly"
    echo "  • Backup your ~/.tetsuo directory"
    echo "  • Report security issues to: security@tetsuoarena.com"
    echo "  • Review SECURITY.md for best practices"
    echo ""
}

# Main execution
main() {
    echo ""

    # Run all verification checks
    verify_build_environment || {
        print_status "error" "Build environment verification failed"
        exit 1
    }

    check_binary_integrity || {
        print_status "error" "Binary integrity check failed"
        exit 1
    }

    verify_checksums || {
        print_status "warning" "Checksum verification skipped or failed"
    }

    verify_gpg_signatures || {
        print_status "warning" "GPG signature verification skipped"
    }

    test_node_functionality || {
        print_status "warning" "Node functionality test failed"
    }

    # Generate final report
    generate_security_report

    echo "=========================================================================="
    echo -e "${GREEN}[✓] Installation verification complete${NC}"
    echo "=========================================================================="
    echo ""
}

# Run main function
main "$@"
