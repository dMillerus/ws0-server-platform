# Cockpit Web Console Setup

## Overview
Cockpit has been successfully installed and configured on this EndeavourOS system for remote web-based administration.

## Access Information
- **URL**: https://192.168.1.75:9090 or https://localhost:9090
- **Protocol**: HTTPS (self-signed certificate)
- **Port**: 9090
- **Authentication**: Use your system username and password

## Installed Modules
- **cockpit**: Core web console
- **cockpit-machines**: Virtual machine management ✅ **CONFIGURED**
- **cockpit-packagekit**: Package management interface

## Features Available
- System monitoring (CPU, memory, disk, network)
- Service management (systemd services)
- Storage management (disks, filesystems, RAID)
- Network configuration
- User account management
- **Virtual machine management (via cockpit-machines)** ✅ **ACTIVE**
- Package installation/updates (via cockpit-packagekit)
- Terminal access
- Log viewing
- Firewall management

## Virtual Machine Management
- **Libvirt Backend**: Configured and running
- **Default Network**: 192.168.122.0/24 (NAT)
- **Storage Pool**: /var/lib/libvirt/images
- **VM Console**: Web-based VNC access
- **Helper Script**: `./vm_manager.sh` for command-line operations

### VM Management Access:
1. Navigate to https://localhost:9090
2. Click "Virtual Machines" in left sidebar
3. Use "Create VM" to start new virtual machines
4. Supports ISO images, OS downloads, and disk imports

## Security Notes
1. Cockpit uses HTTPS with a self-signed certificate by default
2. Authentication is handled through PAM (system accounts)
3. The service runs on-demand (socket activation)
4. No firewall rules are blocking access (iptables policy is ACCEPT)

## Service Management
```bash
# Check status
sudo systemctl status cockpit.socket

# Start/stop
sudo systemctl start cockpit.socket
sudo systemctl stop cockpit.socket

# Enable/disable autostart
sudo systemctl enable cockpit.socket
sudo systemctl disable cockpit.socket
```

## Troubleshooting
- If you can't connect, check if the service is running: `sudo systemctl status cockpit.socket`
- Check firewall rules if connecting remotely
- Verify the correct IP address: `ip addr show`
- Check logs: `sudo journalctl -u cockpit.service`

## Configuration Files
- Main config: `/etc/cockpit/`
- Certificates: `/etc/cockpit/ws-certs.d/`

## First Login
1. Open your web browser
2. Navigate to https://192.168.1.75:9090
3. Accept the self-signed certificate warning
4. Login with your system username (dave) and password
5. You'll see the Cockpit dashboard with system overview

## Advanced Configuration
To customize Cockpit further, you can:
- Replace the self-signed certificate with a proper SSL certificate
- Configure additional authentication methods
- Install additional Cockpit modules
- Customize the interface theme
