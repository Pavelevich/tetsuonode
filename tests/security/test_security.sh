#!/bin/bash

# TETSUONODE Security Test Suite
# Run: ./tests/security/test_security.sh
# All tests should pass before deployment

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test result functions
pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    TESTS_FAILED=$((TESTS_FAILED + 1))
}

skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    TESTS_SKIPPED=$((TESTS_SKIPPED + 1))
}

echo "=========================================================================="
echo "                 TETSUONODE SECURITY TEST SUITE"
echo "=========================================================================="
echo ""
echo "Date: $(date)"
echo ""

# =============================================================================
# TEST CATEGORY: Script Security
# =============================================================================

echo "--- Script Security Tests ---"
echo ""

# Test 1: Install scripts use set -e
test_set_e() {
    for script in scripts/install-*.sh; do
        if grep -q "^set -e" "$script"; then
            pass "Script $script uses 'set -e'"
        else
            fail "Script $script missing 'set -e'"
        fi
    done
}
test_set_e

# Test 2: Install scripts use set -u
test_set_u() {
    for script in scripts/install-*.sh; do
        if grep -q "^set -u" "$script"; then
            pass "Script $script uses 'set -u'"
        else
            fail "Script $script missing 'set -u'"
        fi
    done
}
test_set_u

# Test 3: HOME validation exists
test_home_validation() {
    for script in scripts/install-macos.sh scripts/install-linux.sh; do
        if grep -q 'if \[ -z "\${HOME:-}"' "$script"; then
            pass "Script $script validates HOME"
        else
            fail "Script $script missing HOME validation"
        fi
    done
}
test_home_validation

# Test 4: WORK_DIR path validation
test_workdir_validation() {
    for script in scripts/install-macos.sh scripts/install-linux.sh; do
        if grep -q 'if \[\[ ! "\$WORK_DIR" =~ ^\$HOME \]\]' "$script"; then
            pass "Script $script validates WORK_DIR path"
        else
            fail "Script $script missing WORK_DIR validation"
        fi
    done
}
test_workdir_validation

# Test 5: No shell injection in variable usage
test_shell_injection() {
    local issues=0
    for script in scripts/*.sh; do
        # Check for unquoted variables in dangerous contexts (actual execution, not echo/print)
        # Exclude lines that are just echo/print statements showing commands
        if grep -E '^[^#]*rm -rf \$[A-Z]' "$script" | grep -v 'echo' | grep -v '"\$' | grep -v '"\${' >/dev/null 2>&1; then
            fail "Script $script has unquoted variable in rm -rf"
            issues=$((issues + 1))
        fi
    done
    if [ $issues -eq 0 ]; then
        pass "No obvious shell injection vulnerabilities"
    fi
}
test_shell_injection

echo ""

# =============================================================================
# TEST CATEGORY: Configuration Security
# =============================================================================

echo "--- Configuration Security Tests ---"
echo ""

# Test 6: RPC is localhost only in default config
test_rpc_localhost() {
    for script in scripts/install-macos.sh scripts/install-linux.sh; do
        if grep -q "rpcallowip=127.0.0.1" "$script" && grep -q "rpcbind=127.0.0.1" "$script"; then
            pass "Script $script sets RPC to localhost only"
        else
            fail "Script $script may expose RPC to network"
        fi
    done
}
test_rpc_localhost

# Test 7: Config file permissions are secure
test_config_permissions() {
    for script in scripts/install-macos.sh scripts/install-linux.sh; do
        if grep -q "chmod 600.*tetsuo.conf" "$script"; then
            pass "Script $script sets secure config permissions (600)"
        else
            fail "Script $script may have insecure config permissions"
        fi
    done
}
test_config_permissions

# Test 8: Data directory permissions are secure
test_datadir_permissions() {
    for script in scripts/install-macos.sh scripts/install-linux.sh; do
        if grep -q "chmod 700.*\.tetsuo" "$script"; then
            pass "Script $script sets secure data directory permissions (700)"
        else
            fail "Script $script may have insecure data directory permissions"
        fi
    done
}
test_datadir_permissions

echo ""

# =============================================================================
# TEST CATEGORY: Cryptographic Verification
# =============================================================================

echo "--- Cryptographic Verification Tests ---"
echo ""

# Test 9: Checksums are generated
test_checksum_generation() {
    for script in scripts/install-macos.sh scripts/install-linux.sh; do
        if grep -q "sha.*sum.*tetsuod" "$script" || grep -q "shasum.*tetsuod" "$script"; then
            pass "Script $script generates checksums"
        else
            fail "Script $script does not generate checksums"
        fi
    done
}
test_checksum_generation

# Test 10: Verify script exists
test_verify_script() {
    if [ -f "scripts/verify-installation.sh" ]; then
        pass "Verification script exists"
    else
        fail "Verification script missing"
    fi
}
test_verify_script

# Test 11: Verify script is executable
test_verify_executable() {
    if [ -x "scripts/verify-installation.sh" ]; then
        pass "Verification script is executable"
    else
        fail "Verification script is not executable"
    fi
}
test_verify_executable

echo ""

# =============================================================================
# TEST CATEGORY: Documentation
# =============================================================================

echo "--- Documentation Security Tests ---"
echo ""

# Test 12: SECURITY.md exists
test_security_md() {
    if [ -f "SECURITY.md" ]; then
        pass "SECURITY.md exists"
    else
        fail "SECURITY.md missing"
    fi
}
test_security_md

# Test 13: HARDENING.md exists
test_hardening_md() {
    if [ -f "HARDENING.md" ]; then
        pass "HARDENING.md exists"
    else
        fail "HARDENING.md missing"
    fi
}
test_hardening_md

# Test 14: Security contact is documented
test_security_contact() {
    if grep -q "security@tetsuoarena.com" SECURITY.md 2>/dev/null; then
        pass "Security contact email documented"
    else
        fail "Security contact email not found in SECURITY.md"
    fi
}
test_security_contact

# Test 15: SBOM.json exists (supply chain)
test_sbom() {
    if [ -f "SBOM.json" ]; then
        pass "SBOM.json exists for supply chain transparency"
    else
        skip "SBOM.json not found (optional)"
    fi
}
test_sbom

echo ""

# =============================================================================
# TEST CATEGORY: Network Security
# =============================================================================

echo "--- Network Security Tests ---"
echo ""

# Test 16: Default ports are reasonable
test_default_ports() {
    local p2p_port=$(grep -o "port=8338" scripts/install-linux.sh)
    local rpc_port=$(grep -o "rpcport=8336" scripts/install-linux.sh)

    if [ -n "$p2p_port" ] && [ -n "$rpc_port" ]; then
        pass "Default ports are standard (P2P: 8338, RPC: 8336)"
    else
        fail "Default ports not found or incorrect"
    fi
}
test_default_ports

# Test 17: Multiple seed nodes or fallback
test_seed_nodes() {
    local count=$(grep -c "addnode=" scripts/install-linux.sh 2>/dev/null || echo "0")
    if [ "$count" -ge 1 ]; then
        if [ "$count" -ge 2 ]; then
            pass "Multiple seed nodes configured ($count nodes)"
        else
            skip "Only $count seed node (recommend 2+)"
        fi
    else
        fail "No seed nodes configured"
    fi
}
test_seed_nodes

echo ""

# =============================================================================
# TEST CATEGORY: Windows Script
# =============================================================================

echo "--- Windows Script Tests ---"
echo ""

# Test 18: Windows script exists
test_windows_script() {
    if [ -f "scripts/install-windows.ps1" ]; then
        pass "Windows installer script exists"
    else
        fail "Windows installer script missing"
    fi
}
test_windows_script

# Test 19: Windows script clones correct repo
test_windows_repo() {
    if grep -q "fullchain.git" scripts/install-windows.ps1 2>/dev/null; then
        pass "Windows script clones fullchain repo"
    else
        fail "Windows script may clone wrong repo (should be fullchain)"
    fi
}
test_windows_repo

echo ""

# =============================================================================
# SUMMARY
# =============================================================================

echo "=========================================================================="
echo "                           TEST SUMMARY"
echo "=========================================================================="
echo ""
echo -e "Passed:  ${GREEN}$TESTS_PASSED${NC}"
echo -e "Failed:  ${RED}$TESTS_FAILED${NC}"
echo -e "Skipped: ${YELLOW}$TESTS_SKIPPED${NC}"
echo ""

TOTAL=$((TESTS_PASSED + TESTS_FAILED))
if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All $TOTAL tests passed!${NC}"
    exit 0
else
    echo -e "${RED}$TESTS_FAILED of $TOTAL tests failed!${NC}"
    exit 1
fi
