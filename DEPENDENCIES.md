# TETSUO Node Dependencies

This document lists all external dependencies required to build and run TETSUO nodes.

## Build Dependencies

### Required Versions

| Dependency | Minimum | Recommended | Maximum | Notes |
|------------|---------|-------------|---------|-------|
| **CMake** | 3.22.0 | 3.26.0+ | - | Build configuration |
| **GCC/Clang** | 10.0 | 12.0+ | - | C++20 support required |
| **GNU Make** | 4.2 | 4.3+ | - | Build system |
| **Boost** | 1.70.0 | 1.80.0+ | 2.0.0 | C++ utilities |
| **OpenSSL** | 1.1.0 | 1.1.1+ | 3.0.0 | Cryptography |
| **libevent** | 2.1.8 | 2.1.12+ | 3.0.0 | Event handling |
| **capnproto** | 0.9.0 | 1.0.0+ | - | Serialization format |

### Linux Dependencies

#### Ubuntu 20.04 LTS / 22.04 LTS
```bash
build-essential
cmake (>= 3.22)
libssl-dev
libboost-all-dev
libevent-dev
git
automake
libtool
pkg-config
capnproto
libcapnp-dev
```

#### Fedora / RHEL / CentOS
```bash
gcc
gcc-c++
make
cmake (>= 3.22)
openssl-devel
boost-devel
libevent-devel
git
automake
libtool
pkgconfig
capnproto-devel
```

#### Arch Linux
```bash
base-devel
openssl
boost
libevent
git
```

### macOS Dependencies (via Homebrew)

```bash
cmake
boost
openssl
libevent
capnp
automake
libtool
```

### Windows Dependencies

- **Visual Studio 2019** or **MinGW-w64**
- **CMake 3.22+** for Windows
- **Boost** (pre-compiled for Windows)
- **OpenSSL** (Windows distribution)
- **libevent** (pre-compiled for Windows)

## Runtime Dependencies

### Linux Runtime Libraries
- libssl.so (from openssl)
- libboost_*.so (from boost)
- libevent.so (from libevent)
- libcapnp.so (from capnproto)

### macOS Runtime Libraries
- openssl (via Homebrew)
- boost (via Homebrew)
- libevent (via Homebrew)

### Windows Runtime Libraries
- MSVC runtime library (vcruntime140.dll)
- openssl DLLs
- boost DLLs
- libevent DLLs

## Optional Dependencies

### GPU Mining Support
- **CUDA 11.0+** (for NVIDIA GPUs)
- **AMD GPU Driver** (for AMD GPUs)

### Development Tools
- **Git** (for source management)
- **clang-format** (for code formatting)
- **clang-tidy** (for static analysis)
- **valgrind** (for memory profiling)

## Dependency Security Notes

### OpenSSL
- Provides TLS/SSL and cryptographic functions
- Critical security component
- Regularly updated for vulnerabilities
- **Recommendation:** Keep to latest 1.1.1 or 3.0.x series

### Boost
- C++ utility library
- Multiple sublibraries used
- **Recommendation:** Use stable release versions (1.70.0+)

### libevent
- Asynchronous event notification library
- Used for network I/O
- **Recommendation:** Use latest 2.1.x series

### capnproto
- Serialization framework
- Used for efficient data encoding
- **Recommendation:** Use versions 0.9.0+

## Dependency Vulnerabilities

To check for known vulnerabilities in dependencies:

```bash
# Ubuntu/Debian
apt-get update
apt-cache policy libssl-dev  # Check for security updates

# Alpine (if using containers)
apk update
apk info -e libssl

# Manual check
curl https://nvd.nist.gov/vuln/
```

## Building Without Internet

For air-gapped or offline builds:

1. Pre-download all dependencies on a system with internet
2. Create a local mirror or tarball
3. Configure build system to use local versions
4. Copy sources to build machine
5. Build with offline CMake configuration

## Dependency Compatibility Matrix

| Platform | CMake | Boost | OpenSSL | libevent | Status |
|----------|-------|-------|---------|----------|--------|
| Ubuntu 20.04 | 3.16✓ | 1.71✓ | 1.1.1✓ | 2.1.11✓ | ✅ Tested |
| Ubuntu 22.04 | 3.22✓ | 1.74✓ | 1.1.1✓ | 2.1.12✓ | ✅ Tested |
| Fedora 36+ | 3.22✓ | 1.78✓ | 1.1.1✓ | 2.1.12✓ | ✅ Tested |
| macOS 12+ | 3.23✓ | 1.80✓ | 1.1.1✓ | 2.1.12✓ | ✅ Tested |
| Windows 10+ | 3.22✓ | 1.78✓ | 1.1.1✓ | 2.1.12✓ | ✅ Tested |

## Updating Dependencies

### Safe Update Procedure

1. **Test in development environment first**
   ```bash
   cd $WORK_DIR
   ./build/bin/tetsuod --version  # Note current version
   ```

2. **Update dependencies**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install libboost-all-dev=1.78.0.1ubuntu1  # Specific version

   # Or for latest
   sudo apt-get install --only-upgrade libboost-all-dev
   ```

3. **Rebuild TETSUO**
   ```bash
   cd $WORK_DIR
   rm -rf build
   mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   make clean
   make -j$(nproc)
   ```

4. **Verify build**
   ```bash
   ./bin/tetsuod --version
   ./bin/tetsuo-cli --version
   ```

5. **Test on testnet first** (if available)
   ```bash
   ./bin/tetsuod -testnet -daemon
   sleep 5
   ./bin/tetsuo-cli -testnet getblockcount
   ```

6. **Update production**
   ```bash
   # Stop node safely
   ./bin/tetsuo-cli stop
   sleep 5

   # Update and restart
   ./bin/tetsuod -daemon -datadir=$HOME/.tetsuo
   ```

## Troubleshooting Dependency Issues

### CMake not found
```bash
# Ubuntu
sudo apt-get install cmake

# macOS
brew install cmake

# Verify
cmake --version
```

### OpenSSL version mismatch
```bash
# Find OpenSSL location
openssl version
find /usr -name "libssl.so*" 2>/dev/null

# Update CMake flags
cmake .. -DOPENSSL_ROOT_DIR=/usr/local/opt/openssl
```

### Build fails with Boost
```bash
# Check Boost installation
dpkg -l | grep boost  # Ubuntu
brew list boost       # macOS

# Rebuild Boost from source if needed
cd ~/boost_1_80_0
./bootstrap.sh
./b2 install
```

## Support

For dependency-related issues:
- **GitHub Issues:** https://github.com/Pavelevich/tetsuonode/issues
- **Security Contact:** security@tetsuoarena.com
- **Documentation:** See INSTALL.md for platform-specific instructions

---

**Last Updated:** January 3, 2026
**Version:** 1.0
**Status:** ACTIVE
