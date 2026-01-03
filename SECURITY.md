# Security Policy

## Reporting Security Issues

**DO NOT** open public GitHub issues for security vulnerabilities.

Instead, please email: **security@tetsuoarena.com**

When reporting a security issue, please include:
- Description of the vulnerability
- Steps to reproduce the issue
- Potential impact and severity
- Suggested fix (if available)
- Your contact information (optional)

All security reports are treated confidentially and will be investigated promptly.

## Security Contacts

| Role | Contact | Availability |
|------|---------|--------------|
| **Primary Security** | security@tetsuoarena.com | 24/7 |
| **Incident Response** | security@tetsuoarena.com | 24/7 |

## Supported Versions

| Version | Supported | EOL Date |
|---------|-----------|----------|
| 1.x     | ✅ Yes    | 2027-01-01 |
| 0.x     | ❌ No     | 2024-01-01 |

## Security Update Policy

- Security patches are released as soon as possible after disclosure and testing
- Critical vulnerabilities receive priority
- All updates are signed and verified
- Users are strongly encouraged to update immediately upon release

## Known Security Best Practices

### Installation Security

1. **Download Securely**
   ```bash
   # 1. Download the installation script
   curl -O https://raw.githubusercontent.com/Pavelevich/tetsuonode/main/scripts/install-linux.sh

   # 2. Review the script carefully
   less install-linux.sh

   # 3. Execute the reviewed script
   bash install-linux.sh
   ```

2. **Verify Repository Authenticity**
   After cloning, verify the commit signatures:
   ```bash
   cd fullchain
   git verify-commit HEAD
   ```

### Running the Node

1. **RPC Port Security**
   - Never expose RPC port 8336 to the internet
   - Keep `rpcallowip=127.0.0.1` (localhost only)
   - Use a firewall to block RPC port

2. **Firewall Configuration**
   ```bash
   # Linux (ufw)
   ufw default deny incoming
   ufw default allow outgoing
   ufw allow out to any port 8338 comment "P2P outbound"
   ufw allow in to any port 8338 comment "P2P inbound"
   ufw deny in to any port 8336 comment "Deny RPC"

   # Linux (iptables)
   iptables -A INPUT -p tcp --dport 8336 -j DROP
   iptables -A OUTPUT -p tcp --sport 8336 -j DROP
   ```

3. **File Permissions**
   - Configuration directory: 700 (rwx------)
   - Configuration file: 600 (rw-------)
   - Data directory: 700 (rwx------)

4. **Key Management**
   - Never share wallet keys or seed phrases
   - Backup configuration files securely
   - Keep backups offline

### Network Security

1. **Peer Connections**
   - Monitor peer connections regularly
   - Be cautious of connections from unknown IPs
   - TETSUO automatically implements peer banning for malicious behavior

2. **Update Policy**
   - Enable security update notifications
   - Update immediately for critical vulnerabilities
   - Test updates in a controlled environment first

## Vulnerability Disclosure Timeline

We follow a responsible disclosure timeline:

1. **Immediate (0-24 hours)**: Acknowledge receipt of report
2. **Investigation (1-7 days)**: Investigate and confirm vulnerability
3. **Fix Development (7-14 days)**: Develop and test fix
4. **Release Preparation (1-3 days)**: Prepare security release
5. **Public Disclosure (1-7 days after release)**: Publish security advisory

## Security Audit History

### 2026 Security Audit (January)
- **Auditor:** Claude Code Security Audit System
- **Date:** January 3, 2026
- **Status:** COMPLETE
- **Findings:**
  - No critical vulnerabilities found
  - RPC authentication: SECURE ✅
  - Network security: GOOD ✅
  - Installation security: Improved with checksums and verification
- **Report:** See SECURITY_AUDIT_PLAN.md

## Compliance Standards

This project follows security best practices from:
- **Bitcoin Core Security Guidelines**
- **NIST Cybersecurity Framework**
- **CWE Top 25 Most Dangerous Software Weaknesses**
- **OWASP Top 10**

## PGP Public Key

For encrypted communication, use our PGP key:

```
-----BEGIN PGP PUBLIC KEY BLOCK-----

[Public key to be added upon security setup]

-----END PGP PUBLIC KEY BLOCK-----
```

## Incident Response Procedure

1. **Report received** → Acknowledge within 24 hours
2. **Triage** → Assess severity and impact
3. **Investigation** → Reproduce and understand vulnerability
4. **Fix development** → Create patch with tests
5. **QA testing** → Verify fix works correctly
6. **Release preparation** → Build security release
7. **Coordinate disclosure** → Notify users and partners
8. **Public disclosure** → Publish advisory and update

## Security Recommendations for Users

### Regular Maintenance
- [ ] Keep TETSUO node updated
- [ ] Monitor disk space (blockchain grows over time)
- [ ] Review logs for errors or suspicious activity
- [ ] Backup configuration and data regularly
- [ ] Verify firewall rules are in place
- [ ] Subscribe to security announcements

### Operational Security
- [ ] Use strong, unique passwords
- [ ] Enable system-level firewall
- [ ] Keep operating system and dependencies updated
- [ ] Use trusted DNS servers
- [ ] Consider running node on dedicated hardware
- [ ] Monitor system resources (CPU, memory, network)

### Network Security
- [ ] Use VPN when accessing RPC locally over network
- [ ] Never expose RPC to public internet
- [ ] Consider using reverse proxy with authentication
- [ ] Enable network monitoring and logging
- [ ] Document your network topology

## Questions?

For security questions that are not vulnerabilities:
- GitHub Issues: https://github.com/Pavelevich/tetsuonode/issues
- Email: security@tetsuoarena.com
- Documentation: https://github.com/Pavelevich/tetsuonode/blob/main/docs/

---

**Last Updated:** January 3, 2026
**Status:** ACTIVE
**Version:** 1.0
