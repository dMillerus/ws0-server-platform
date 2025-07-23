#!/bin/bash
# SSH 2FA Setup Script for Arch Linux
# Run this script after the main hardening is complete

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root (use sudo)"
   exit 1
fi

print_status "Setting up 2FA for SSH..."

# Install Google Authenticator PAM module
print_status "Installing Google Authenticator PAM module..."
pacman -S --noconfirm google-authenticator-libpam

# Backup PAM SSH config
cp /etc/pam.d/sshd /etc/pam.d/sshd.bak.$(date +%F)

# Configure PAM for SSH
print_status "Configuring PAM for SSH 2FA..."
sed -i '1i auth required pam_google_authenticator.so nullok' /etc/pam.d/sshd

# Update SSH config for 2FA
print_status "Updating SSH configuration for 2FA..."
if ! grep -q "AuthenticationMethods" /etc/ssh/sshd_config; then
    echo "" >> /etc/ssh/sshd_config
    echo "# 2FA Configuration" >> /etc/ssh/sshd_config
    echo "AuthenticationMethods publickey,keyboard-interactive" >> /etc/ssh/sshd_config
else
    sed -i 's/^.*AuthenticationMethods.*/AuthenticationMethods publickey,keyboard-interactive/' /etc/ssh/sshd_config
fi

# Test SSH config
sshd -t
if [ $? -eq 0 ]; then
    print_status "SSH configuration test passed!"
else
    print_error "SSH configuration test failed! Check config manually."
    exit 1
fi

# Restart SSH
systemctl restart sshd

print_status "2FA setup completed!"
print_warning "Each user must now run 'google-authenticator' to set up their TOTP token"
print_warning "Users will need both their SSH key AND TOTP code to login"

echo ""
echo "User setup instructions:"
echo "1. Each user should run: google-authenticator"
echo "2. Scan the QR code with an authenticator app"
echo "3. Save the backup codes safely"
echo "4. Test login with both SSH key and TOTP code"
