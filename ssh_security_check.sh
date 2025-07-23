#!/bin/bash
# SSH Security Monitoring Script
# Check the status of SSH hardening measures

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_header "SSH Security Status Report"

# Check SSH service status
echo ""
echo -e "${BLUE}SSH Service Status:${NC}"
if systemctl is-active --quiet sshd; then
    print_status "SSH daemon is running"
    SSH_PORT=$(grep "^Port" /etc/ssh/sshd_config | awk '{print $2}')
    if [ "$SSH_PORT" != "22" ]; then
        print_status "SSH running on non-standard port: $SSH_PORT"
    else
        print_warning "SSH still running on default port 22"
    fi
else
    print_error "SSH daemon is not running"
fi

# Check root login
echo ""
echo -e "${BLUE}Root Login Status:${NC}"
if grep -q "^PermitRootLogin no" /etc/ssh/sshd_config; then
    print_status "Root login disabled"
else
    print_warning "Root login may be enabled"
fi

# Check password authentication
echo ""
echo -e "${BLUE}Authentication Status:${NC}"
if grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
    print_status "Password authentication disabled"
else
    print_warning "Password authentication may be enabled"
fi

if grep -q "^PubkeyAuthentication yes" /etc/ssh/sshd_config; then
    print_status "Public key authentication enabled"
else
    print_warning "Public key authentication may be disabled"
fi

# Check fail2ban status
echo ""
echo -e "${BLUE}Fail2Ban Status:${NC}"
if systemctl is-active --quiet fail2ban; then
    print_status "Fail2ban is running"
    BANNED_IPS=$(fail2ban-client status sshd 2>/dev/null | grep "Banned IP list" | cut -d: -f2 | tr -d ' ')
    if [ -n "$BANNED_IPS" ]; then
        print_warning "Currently banned IPs: $BANNED_IPS"
    else
        print_status "No currently banned IPs"
    fi
else
    print_warning "Fail2ban is not running"
fi

# Check firewall status
echo ""
echo -e "${BLUE}Firewall Status:${NC}"
if systemctl is-active --quiet nftables; then
    print_status "nftables is active"
    if nft list ruleset | grep -q "tcp dport.*limit rate"; then
        print_status "SSH rate limiting is configured"
    else
        print_warning "SSH rate limiting not found in rules"
    fi
else
    print_warning "nftables is not active"
fi

# Check SSH attempts
echo ""
echo -e "${BLUE}Recent SSH Activity:${NC}"
echo "Recent successful logins:"
journalctl -u sshd --since "1 hour ago" | grep "Accepted" | tail -5

echo ""
echo "Recent failed attempts:"
journalctl -u sshd --since "1 hour ago" | grep "Failed\|Invalid" | tail -5

# Check system resources
echo ""
echo -e "${BLUE}System Resources:${NC}"
echo "Load average: $(uptime | awk -F'load average:' '{print $2}')"
echo "Memory usage: $(free -h | grep '^Mem:' | awk '{print $3"/"$2}')"
echo "Disk usage: $(df -h / | tail -1 | awk '{print $5}')"

# Check for updates
echo ""
echo -e "${BLUE}System Updates:${NC}"
UPDATES=$(checkupdates 2>/dev/null | wc -l)
if [ "$UPDATES" -gt 0 ]; then
    print_warning "$UPDATES packages available for update"
else
    print_status "System is up to date"
fi

# Check SSH configuration
echo ""
echo -e "${BLUE}SSH Configuration Test:${NC}"
if sshd -t 2>/dev/null; then
    print_status "SSH configuration is valid"
else
    print_error "SSH configuration has errors"
fi

print_header "End of Report"
