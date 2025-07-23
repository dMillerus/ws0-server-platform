# Virtual Machine Management with Libvirt and Cockpit

## Overview
This guide covers the complete setup and management of virtual machines using libvirt as the virtualization backend and Cockpit as the web-based management interface.

## Prerequisites
- CPU with virtualization support (VT-x for Intel, AMD-V for AMD)
- Sufficient RAM (recommended: 8GB+ for host + VMs)
- Adequate disk space for VM images
- EndeavourOS (Arch-based) system
- Cockpit already installed and configured

## Installation and Setup

### Automated Setup
Run the provided setup script:
```bash
chmod +x setup_libvirt_cockpit.sh
./setup_libvirt_cockpit.sh
```

### Manual Setup Steps
If you prefer manual installation:

1. **Install required packages:**
```bash
sudo pacman -S libvirt qemu-full virt-manager virt-viewer dnsmasq bridge-utils
sudo pacman -S virt-install libguestfs cockpit-machines
```

2. **Add user to libvirt group:**
```bash
sudo usermod -a -G libvirt $USER
```

3. **Enable services:**
```bash
sudo systemctl enable --now libvirtd
sudo systemctl enable --now virtlogd
```

## Cockpit Virtual Machine Interface

### Accessing VM Management
1. Open web browser and navigate to: `https://localhost:9090`
2. Login with your system credentials
3. Click on "Virtual Machines" in the left sidebar

### Creating Virtual Machines

#### Method 1: Through Cockpit Web Interface
1. Click "Create VM" button
2. Choose installation method:
   - **Local install media (ISO image)**
   - **Download an OS**
   - **Network install (URL)**
   - **Import existing disk image**

3. Configure VM settings:
   - **Name**: Descriptive name for the VM
   - **Memory**: RAM allocation (MB)
   - **Storage**: Disk size (GB)
   - **CPU**: Number of virtual CPUs
   - **Network**: Network interface

4. Start installation process

#### Method 2: Command Line VM Creation
```bash
# Example: Creating Ubuntu 22.04 VM
sudo virt-install \
    --name ubuntu-22.04 \
    --ram 2048 \
    --disk path=/var/lib/libvirt/images/ubuntu-22.04.qcow2,size=20 \
    --vcpus 2 \
    --os-variant ubuntu22.04 \
    --network bridge=virbr0 \
    --graphics vnc,listen=0.0.0.0 \
    --console pty,target_type=serial \
    --cdrom /var/lib/libvirt/images/ubuntu-22.04.iso
```

### VM Management Operations

#### Starting/Stopping VMs
- **Start**: Click the play button or "Run" in VM details
- **Shutdown**: Click "Shut down" for graceful shutdown
- **Force off**: Click "Force off" for immediate shutdown
- **Restart**: Click "Restart" to reboot the VM

#### Accessing VM Console
1. Click on the VM name to open details
2. Click "Console" tab
3. Use the web-based VNC console to interact with the VM

#### Managing VM Settings
- **Memory**: Adjust RAM allocation (requires VM shutdown)
- **CPUs**: Change virtual CPU count
- **Disks**: Add/remove virtual disks
- **Networks**: Configure network interfaces
- **Boot order**: Change boot priority

## Storage Management

### Storage Pools
Default storage pool location: `/var/lib/libvirt/images`

#### Creating Additional Storage Pools
```bash
# Create directory-based pool
sudo virsh pool-define-as mypool dir --target /path/to/storage
sudo virsh pool-start mypool
sudo virsh pool-autostart mypool
```

### VM Disk Images
- **qcow2**: QEMU's copy-on-write format (recommended)
- **raw**: Raw disk image format
- **vmdk**: VMware disk format

#### Managing Disk Images
```bash
# Create new disk image
sudo qemu-img create -f qcow2 /var/lib/libvirt/images/newdisk.qcow2 10G

# Resize existing disk
sudo qemu-img resize /var/lib/libvirt/images/vm-disk.qcow2 +5G

# Convert disk formats
sudo qemu-img convert -f raw -O qcow2 input.img output.qcow2
```

## Networking Configuration

### Default Network (NAT)
- Network: `192.168.122.0/24`
- Gateway: `192.168.122.1`
- DHCP range: `192.168.122.2-254`

### Bridge Networking
For VMs to appear on the local network:

1. **Create bridge interface:**
```bash
# Create bridge configuration
sudo tee /etc/systemd/network/br0.netdev > /dev/null << EOF
[NetDev]
Name=br0
Kind=bridge
EOF

sudo tee /etc/systemd/network/br0.network > /dev/null << EOF
[Match]
Name=br0

[Network]
DHCP=yes
EOF
```

2. **Configure in libvirt:**
```bash
# Define bridge network
sudo virsh net-define /dev/stdin << EOF
<network>
  <name>bridge-network</name>
  <forward mode="bridge"/>
  <bridge name="br0"/>
</network>
EOF

sudo virsh net-start bridge-network
sudo virsh net-autostart bridge-network
```

## Performance Optimization

### CPU Configuration
- Enable CPU passthrough for better performance
- Use host-model or host-passthrough
- Allocate appropriate number of vCPUs

### Memory Management
- Enable KSM (Kernel Same-page Merging) for memory deduplication
- Use memory ballooning for dynamic allocation
- Consider huge pages for memory-intensive VMs

### Storage Optimization
- Use virtio drivers for better I/O performance
- Consider SSD storage for VM images
- Use qcow2 format with appropriate cluster size

## Security Considerations

### VM Isolation
- VMs are isolated by default through KVM
- Network isolation through virtual networks
- Use separate storage pools for different security levels

### Access Control
- Cockpit uses PAM authentication
- libvirt group membership controls VM management access
- Consider additional access controls for production environments

### Updates and Patches
- Keep host system updated
- Regularly update QEMU/KVM components
- Maintain guest operating systems

## Troubleshooting

### Common Issues

#### VM Won't Start
1. Check virtualization support: `lscpu | grep Virtualization`
2. Verify KVM modules: `lsmod | grep kvm`
3. Check libvirtd status: `sudo systemctl status libvirtd`

#### Network Issues
1. Verify default network: `sudo virsh net-list --all`
2. Check firewall rules: `sudo iptables -L`
3. Restart network: `sudo virsh net-destroy default && sudo virsh net-start default`

#### Performance Problems
1. Check resource allocation (CPU, RAM)
2. Verify virtio drivers in guest
3. Monitor host resources: `htop`, `iotop`

### Log Files
- libvirt logs: `/var/log/libvirt/`
- VM logs: `/var/log/libvirt/qemu/`
- Cockpit logs: `journalctl -u cockpit`

## Useful Commands

### VM Management
```bash
# List all VMs
sudo virsh list --all

# VM operations
sudo virsh start vm-name
sudo virsh shutdown vm-name
sudo virsh destroy vm-name  # Force stop
sudo virsh undefine vm-name  # Delete VM

# VM information
sudo virsh dominfo vm-name
sudo virsh domstats vm-name
```

### Network Management
```bash
# List networks
sudo virsh net-list --all

# Network operations
sudo virsh net-start network-name
sudo virsh net-destroy network-name
```

### Storage Management
```bash
# List storage pools
sudo virsh pool-list --all

# Pool operations
sudo virsh pool-start pool-name
sudo virsh pool-destroy pool-name

# List volumes in pool
sudo virsh vol-list pool-name
```

## Backup and Migration

### VM Backup
```bash
# Backup VM configuration
sudo virsh dumpxml vm-name > vm-name.xml

# Backup disk image
sudo cp /var/lib/libvirt/images/vm-disk.qcow2 /backup/location/
```

### VM Migration
```bash
# Export VM
sudo virsh dumpxml vm-name > vm-name.xml
sudo cp /var/lib/libvirt/images/vm-disk.qcow2 /export/location/

# Import VM on target system
sudo virsh define vm-name.xml
sudo virsh start vm-name
```

## Best Practices

1. **Resource Planning**: Don't over-allocate resources
2. **Regular Backups**: Backup VM configurations and important data
3. **Monitoring**: Monitor host and guest performance
4. **Security**: Keep systems updated and use appropriate isolation
5. **Documentation**: Document VM purposes and configurations
6. **Testing**: Test backup and recovery procedures

## Support and Resources

- **Cockpit Documentation**: https://cockpit-project.org/
- **libvirt Documentation**: https://libvirt.org/
- **QEMU Documentation**: https://www.qemu.org/docs/master/
- **Arch Wiki**: https://wiki.archlinux.org/title/Libvirt
