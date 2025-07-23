# Virtual Machine Setup Complete - Summary

## 🎉 Libvirt and Cockpit Virtual Machine Management Successfully Configured!

### What Was Installed and Configured:

#### Core Virtualization Components:
- **libvirt**: Virtualization management library
- **QEMU/KVM**: Full virtualization platform with hardware acceleration
- **virt-manager**: Desktop application for VM management
- **virt-viewer**: VNC/SPICE client for VM console access
- **virt-install**: Command-line VM installation tool

#### Cockpit Integration:
- **cockpit-machines**: Web-based VM management module
- Integration with existing Cockpit web console

#### Supporting Tools:
- **libguestfs**: Guest filesystem tools
- **swtpm**: Software TPM emulation
- **dnsmasq**: DHCP/DNS services for virtual networks
- **bridge-utils**: Network bridging utilities

### System Configuration:

#### User Permissions:
- ✅ User 'dave' added to 'libvirt' group
- ✅ PolicyKit rules configured for libvirt access

#### Services:
- ✅ libvirtd.service: Active and enabled
- ✅ virtlogd.service: Active and enabled  
- ✅ cockpit.socket: Active and enabled

#### Virtual Networks:
- ✅ Default NAT network (192.168.122.0/24): Active and autostart enabled
- ✅ Firewall configured with libvirt zone

#### Storage:
- ✅ Default storage pool: /var/lib/libvirt/images (Active and autostart enabled)

### Access Information:

#### Cockpit Web Interface:
- **URL**: https://localhost:9090 or https://192.168.1.75:9090
- **VM Management**: Navigate to "Virtual Machines" in left sidebar
- **Authentication**: Use your system credentials (dave/password)

#### Command Line Tools:
- **VM Helper Script**: `./vm_manager.sh` (Available commands: list, networks, pools, status, download-iso, create-vm)
- **Direct libvirt**: `sudo virsh list --all`

### Next Steps:

#### 1. Log Out and Back In
⚠️ **IMPORTANT**: You must log out and log back in for group membership changes to take effect!

#### 2. Create Your First VM:
1. Open web browser: https://localhost:9090
2. Navigate to "Virtual Machines"
3. Click "Create VM"
4. Choose installation method (ISO, download OS, etc.)
5. Configure VM settings (name, memory, storage, CPU)

#### 3. Download ISO Images:
```bash
# Example: Download Ubuntu 22.04 LTS
./vm_manager.sh download-iso https://releases.ubuntu.com/22.04/ubuntu-22.04.3-desktop-amd64.iso

# ISOs will be stored in: /var/lib/libvirt/images/
```

#### 4. Common VM Operations:
```bash
# List all VMs
./vm_manager.sh list

# Check service status
./vm_manager.sh status

# View networks and storage
./vm_manager.sh networks
./vm_manager.sh pools
```

### Virtual Machine Creation Options:

#### Through Cockpit Web Interface (Recommended):
1. **Local install media (ISO image)**: Upload or use downloaded ISO
2. **Download an OS**: Cockpit can download common OS images
3. **Network install (URL)**: Install from network location
4. **Import existing disk image**: Use existing VM disk files

#### Through Command Line:
```bash
# Example: Create Ubuntu VM
sudo virt-install \
    --name ubuntu-vm \
    --ram 2048 \
    --disk path=/var/lib/libvirt/images/ubuntu-vm.qcow2,size=20 \
    --vcpus 2 \
    --os-variant ubuntu22.04 \
    --network bridge=virbr0 \
    --graphics vnc \
    --cdrom /var/lib/libvirt/images/ubuntu-22.04.3-desktop-amd64.iso
```

### Performance Recommendations:

#### For VMs:
- **Memory**: Allocate 2-4GB for desktop OS, 1-2GB for server OS
- **Storage**: Use qcow2 format for efficient disk usage
- **CPU**: Don't over-allocate vCPUs (max 1-2 per physical core)
- **Network**: Use virtio drivers for best performance

#### Host System:
- Keep host system updated
- Monitor resource usage during VM operation
- Consider SSD storage for better VM performance

### Troubleshooting:

#### If VMs won't start:
1. Check virtualization enabled: `lscpu | grep Virtualization`
2. Verify services: `./vm_manager.sh status`
3. Check logs: `sudo journalctl -u libvirtd`

#### If network issues:
1. Restart network: `sudo virsh net-destroy default && sudo virsh net-start default`
2. Check firewall: `sudo firewall-cmd --list-all-zones`

#### If Cockpit doesn't show VMs:
1. Refresh browser page
2. Check user is in libvirt group: `groups`
3. Restart cockpit: `sudo systemctl restart cockpit.socket`

### File Locations:

- **VM Storage**: `/var/lib/libvirt/images/`
- **libvirt Configuration**: `/etc/libvirt/`
- **VM Definitions**: `/etc/libvirt/qemu/`
- **Log Files**: `/var/log/libvirt/`
- **Helper Script**: `./vm_manager.sh`

### Security Notes:

- VMs are isolated by KVM hypervisor
- Default network provides NAT isolation
- Cockpit uses HTTPS with system authentication
- Regular updates recommended for host and guest systems

---

**Setup completed successfully!** 🚀

Remember to log out and back in, then access Cockpit at https://localhost:9090 to start creating virtual machines!
