# SSH Hardening Quick Reference

## Files Created

1. **harden_ssh.sh** - Main hardening script
2. **setup_2fa.sh** - Optional 2FA setup
3. **ssh_security_check.sh** - Security status monitoring
4. **SSH_HARDENING_GUIDE.md** - This reference guide

## Execution Order

### ⚠️ CRITICAL: Before Running Any Scripts

1. **Ensure you have SSH key access:**
   ```bash
   ls -la ~/.ssh/
   ```
   If no SSH key exists, generate one:
   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519
   ```

2. **Add your public key to authorized_keys:**
   ```bash
   cat ~/.ssh/id_ed25519.pub >> ~/.ssh/authorized_keys
   chmod 600 ~/.ssh/authorized_keys
   ```

3. **Test SSH key authentication on current port:**
   ```bash
   ssh -i ~/.ssh/id_ed25519 dave@localhost
   ```

### Step 1: Run Main Hardening Script
```bash
sudo ./harden_ssh.sh
```

This script will:
- Update the system
- Backup current SSH config
- Apply hardened SSH configuration
- Set up systemd sandboxing
- Install and configure fail2ban
- Configure nftables firewall
- Generate SSH keys if needed

### Step 2: Test New Configuration
```bash
# From another terminal or machine:
ssh -p 2222 dave@your_server_ip

# Check status:
./ssh_security_check.sh
```

### Step 3: Optional 2FA Setup
```bash
sudo ./setup_2fa.sh
google-authenticator  # Run as each user
```

## Key Changes Made

### SSH Configuration (/etc/ssh/sshd_config)
- **Port changed to 2222** (from 22)
- **Root login disabled**
- **Password authentication disabled**
- **Key-only authentication enforced**
- **Connection limits**: 3 auth tries, 2 max sessions
- **Idle timeout**: 5 minutes
- **Strong crypto**: ChaCha20-Poly1305, AES256-GCM
- **Verbose logging enabled**

### Firewall (nftables)
- SSH rate limiting: 4 connections/minute, burst of 8
- Drop policy with explicit allows
- Only SSH port 2222 and essential traffic allowed

### Fail2Ban
- SSH jail enabled on port 2222
- 3 max retries before 1-hour ban
- 10-minute detection window

### Systemd Hardening
- Process sandboxing enabled
- File system protections
- Capability restrictions
- Network namespace limitations

## Commands for Monitoring

### Check SSH Status
```bash
systemctl status sshd
journalctl -u sshd -f  # Follow logs
```

### Check Fail2Ban
```bash
fail2ban-client status
fail2ban-client status sshd
```

### Check Firewall
```bash
nft list ruleset
systemctl status nftables
```

### Run Security Check
```bash
./ssh_security_check.sh
```

## Emergency Recovery

### If Locked Out
1. **Console access** (physical or virtual console)
2. **Restore backup:**
   ```bash
   sudo cp /etc/ssh/sshd_config.bak.$(date +%F) /etc/ssh/sshd_config
   sudo systemctl restart sshd
   ```

### If SSH Won't Start
```bash
# Check configuration
sudo sshd -t

# Check logs
journalctl -u sshd

# Restore backup and restart
sudo cp /etc/ssh/sshd_config.bak.* /etc/ssh/sshd_config
sudo systemctl restart sshd
```

## Additional Security Measures

### Regular Maintenance
- Update system weekly: `sudo pacman -Syu`
- Review SSH logs: `journalctl -u sshd`
- Check fail2ban status: `fail2ban-client status`
- Monitor for security updates

### Enhanced Security (Optional)
- Set up SSH certificate authority
- Use hardware security keys (FIDO2/U2F)
- Implement jump/bastion hosts
- Set up centralized logging
- Regular security audits

### User Key Rotation
```bash
# Generate new key
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_new

# Test new key
ssh -i ~/.ssh/id_ed25519_new -p 2222 user@server

# Update authorized_keys
# Remove old key, add new key

# Remove old key file
rm ~/.ssh/id_ed25519
mv ~/.ssh/id_ed25519_new ~/.ssh/id_ed25519
mv ~/.ssh/id_ed25519_new.pub ~/.ssh/id_ed25519.pub
```

## Troubleshooting

### Common Issues

1. **Can't connect on port 2222**
   - Check firewall: `nft list ruleset`
   - Verify SSH is running: `systemctl status sshd`
   - Check SSH config: `sudo sshd -t`

2. **Key authentication fails**
   - Check key permissions: `ls -la ~/.ssh/`
   - Verify authorized_keys: `cat ~/.ssh/authorized_keys`
   - Check SSH logs: `journalctl -u sshd`

3. **Fail2ban blocking legitimate IPs**
   - Unban IP: `sudo fail2ban-client set sshd unbanip IP_ADDRESS`
   - Check jail status: `fail2ban-client status sshd`

4. **2FA not working**
   - Verify PAM config: `/etc/pam.d/sshd`
   - Check user has run: `google-authenticator`
   - Verify SSH config: `AuthenticationMethods publickey,keyboard-interactive`

Remember: Always test changes incrementally and maintain console access!
