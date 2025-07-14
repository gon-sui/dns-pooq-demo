# DNSpooq Vulnerability Demo

This repository contains a demonstration of the DNSpooq vulnerability (CVE-2020-25686) for educational purposes.

⚠️ **WARNING: This is for educational purposes only. Do not use in production environments or for malicious activities.**

## Repository Structure

```
dnspooq-demo/
├── containers/
│   ├── dnsmasq-forwarder/    # Vulnerable DNS forwarder container
│   ├── cache/                # DNS monitoring container
│   └── build_and_push.sh     # Docker build and push script
├── vm-setup/
│   ├── cloud-init-base.yaml  # Base cloud-init configuration
│   ├── setup-attacker.sh     # Attacker VM setup script
│   ├── setup-malicious-server.sh  # Malicious server setup script
│   └── setup-client.sh       # Client VM setup script
└── README.md
```

## What is DNSpooq?

DNSpooq is a collection of DNS vulnerabilities discovered in dnsmasq, a popular DNS forwarder. The vulnerability allows attackers to perform DNS cache poisoning attacks due to insufficient randomization of DNS query parameters.

## Components

### Containers
- **dnsmasq-forwarder**: Contains vulnerable dnsmasq 2.82 for demonstration
- **cache**: Monitoring tool to observe DNS traffic and cache behavior

### VM Setup Scripts
- **Attacker VM**: Contains exploit code for demonstration
- **Client VM**: Desktop environment with VNC for testing
- **Malicious Server**: Fake website to demonstrate successful poisoning

## Educational Use Only

This demonstration is designed for:
- Security education and awareness
- Understanding DNS security vulnerabilities
- Testing defensive measures

**Do not use this for unauthorized penetration testing or malicious activities.**