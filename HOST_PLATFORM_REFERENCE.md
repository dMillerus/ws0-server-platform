# Host Platform Reference - ws0

**Document Version:** 1.0  
**Generated:** July 23, 2025  
**Platform Status:** Production Ready - VM & Container Host  

> **Purpose:** This document serves as a reference for future projects requiring context about the host platform capabilities, configuration, and available resources.

---

## 📋 Quick Platform Summary

| Component | Status | Details |
|-----------|--------|---------|
| **OS** | ✅ Production | EndeavourOS Linux (Arch-based) |
| **Virtualization** | ✅ Ready | QEMU/KVM with libvirt |
| **Containers** | ✅ Ready | Docker + Podman |
| **Web Management** | ✅ Active | Cockpit (port 9090) |
| **Security** | ✅ Hardened | SSH, firewall, fail2ban |
| **Monitoring** | ✅ Available | Built-in health checks |

---

## 🖥️ Hardware Specifications

### Processing Power
- **CPU:** Intel Core i9-13900F (13th Gen)
- **Cores:** 24 physical cores / 32 threads
- **Architecture:** x86_64
- **Virtualization:** Intel VT-x/VT-d enabled

### Memory & Storage
- **RAM:** 32GB DDR4/5 (29GB available for workloads)
- **Primary Storage:** 467GB NVMe SSD (2% used)
- **Secondary Storage:** 476.9GB NVMe SSD (available)
- **Additional:** 119.2GB SATA SSD (available)

### Storage Layout
```
nvme1n1 (467GB) - Primary OS & Container Storage
├─ /efi (2GB) - UEFI boot partition
└─ / (465GB) - Root filesystem (LUKS encrypted)

nvme0n1 (477GB) - Available for VM storage
sda (119GB) - Available for additional storage
```

---

## 🌐 Network Configuration

### Active Interfaces
- **Primary:** WiFi (wlan0) - 192.168.1.75/24
- **Ethernet:** enp2s0 (available, currently unused)
- **Virtual:** virbr0 (192.168.122.0/24) - VM network
- **Container:** docker0 (172.17.0.0/16) - Docker bridge

### Network Services
- **Gateway:** 192.168.1.1 (home router)
- **DNS:** 192.168.1.1 (managed by NetworkManager)
- **Domain:** dwmiller.us

### Port Allocations
- **22:** SSH (custom port configured)
- **9090:** Cockpit web interface
- **53:** DNS (dnsmasq for VMs)
- **67/68:** DHCP (libvirt)

---

## 🐳 Container Platform

### Docker Configuration
- **Version:** 28.3.2
- **Runtime:** containerd
- **Compose:** v2.38.2
- **Build:** buildx 0.25.0

### Podman Integration
- **API Service:** Active
- **Cockpit Module:** Installed
- **Rootless Support:** Available

### Container Resources
- **Default Network:** 172.17.0.0/16
- **Storage Driver:** overlay2
- **Root Directory:** `/var/lib/docker`
- **Registry:** Docker Hub + custom registries

### Management Tools
- **Web Interface:** Cockpit containers module
- **CLI Helper:** `./docker_manager.sh`
- **Monitoring:** ctop + Cockpit dashboard

---

## 🖥️ Virtualization Platform

### QEMU/KVM Stack
- **Hypervisor:** QEMU 10.0.2 with KVM acceleration
- **Management:** libvirt 11.5.0
- **GUI Tools:** virt-manager, virt-viewer
- **CLI Tools:** virt-install, virsh

### Virtual Networks
- **Default NAT:** 192.168.122.0/24 (auto-start enabled)
- **DHCP Range:** 192.168.122.2-254
- **DNS:** dnsmasq integration
- **Firewall:** Integrated with firewalld

### Storage Configuration
- **Default Pool:** `/var/lib/libvirt/images`
- **Pool Type:** dir (filesystem-based)
- **Available Space:** 436GB
- **Image Formats:** qcow2, raw, vmdk

### VM Capabilities
- **Max vCPUs:** 24 (limited by physical cores)
- **Max RAM:** ~28GB (leaving 4GB for host)
- **Guest Support:** Linux, Windows, BSD
- **Features:** TPM 2.0, UEFI, GPU passthrough ready

### Management Tools
- **Web Interface:** Cockpit machines module
- **CLI Helper:** `./vm_manager.sh`
- **GUI:** virt-manager (local display)

---

## 🔒 Security Configuration

### SSH Hardening
- **Key-based Authentication:** Enforced
- **Custom Port:** Configured (non-standard)
- **Root Login:** Disabled
- **Password Auth:** Disabled
- **2FA Support:** Available

### Firewall Protection
- **Backend:** firewalld with nftables
- **Default Policy:** DROP
- **Zones:** public, libvirt, docker
- **Fail2ban:** Active with SSH protection

### Access Control
- **Sudo Access:** dave user
- **Group Memberships:** docker, libvirt, wheel
- **PolicyKit:** Configured for libvirt/cockpit

---

## 🔧 System Services

### Core Services (Always Running)
```
sshd.service          - SSH server
cockpit.service       - Web management interface
docker.service        - Docker engine
libvirtd.service      - Virtualization daemon
firewalld.service     - Firewall management
fail2ban.service      - Intrusion prevention
NetworkManager.service - Network management
```

### Management Services
```
cockpit-machines      - VM management via web
cockpit-podman        - Container management via web
libvirt-dbus         - DBus integration for VMs
podman.service       - Podman API service
```

---

## 📊 Resource Monitoring

### Built-in Health Checks
- **Performance Monitor:** `./performance_monitor.sh`
- **Container Health:** `./container_health_monitor.sh`
- **Security Status:** `./security_monitor.sh`
- **Network Scanner:** `./network_scanner.sh`
- **Backup Status:** `./backup_status_checker.sh`

### Quick Health Check
```bash
./quick_health_check.sh
```

### Cockpit Monitoring
- **System Metrics:** CPU, RAM, disk, network
- **Service Status:** All systemd services
- **Log Viewer:** Centralized log management
- **Performance Graphs:** Historical data

---

## 🛠️ Development Environment

### Programming Languages
- **System:** C/C++ (GCC 15.1.1)
- **Scripting:** Bash, Python 3
- **Version Control:** Git 2.50.1

### Container Development
- **Dockerfile Support:** Full
- **Multi-stage Builds:** buildx
- **Compose Files:** v2 format
- **Registry Push/Pull:** Configured

### VM Development
- **ISO Downloads:** Automated
- **Template Creation:** virt-install
- **Snapshot Support:** qcow2
- **Cloud Images:** cloud-init ready

---

## 📁 Helper Scripts & Tools

### Management Scripts
```
docker_manager.sh     - Docker operations helper
vm_manager.sh         - VM lifecycle management
system_manager.sh     - System administration
network_scanner.sh    - Network discovery
performance_monitor.sh - Resource monitoring
security_monitor.sh   - Security status checks
```

### Setup Scripts
```
setup_docker_cockpit.sh  - Container platform setup
setup_libvirt_cockpit.sh - VM platform setup
harden_ssh.sh           - SSH security hardening
setup_2fa.sh             - Two-factor authentication
```

### Documentation Scripts
```
generate_server_docs.sh  - Complete system documentation
complete_docs.sh         - Full documentation generation
test_docs.sh            - Documentation validation
```

---

## 🚀 Project Integration Guide

### For Container Projects
1. **Access:** SSH to ws0 or use Cockpit web interface
2. **Development:** Use Docker/Podman CLI or web management
3. **Resources:** Up to 28GB RAM, 24 cores available
4. **Storage:** 436GB available on fast NVMe
5. **Networking:** 172.17.0.0/16 for Docker, custom networks available

### For VM Projects
1. **Access:** SSH + virsh, virt-manager, or Cockpit
2. **Resources:** Up to 28GB RAM, 24 vCPUs per VM
3. **Storage:** 436GB available, qcow2 format recommended
4. **Networking:** 192.168.122.0/24 default, custom networks supported
5. **Templates:** ISO download and template creation automated

### For Hybrid Projects
1. **Use Case:** Microservices in containers + database in VM
2. **Networking:** Bridge containers and VMs via custom networks
3. **Management:** Unified monitoring through Cockpit
4. **Backup:** Automated health checks and status monitoring

---

## 📞 Support Information

### Access Methods
- **SSH:** Key-based authentication required
- **Web Console:** https://192.168.1.75:9090
- **Local Console:** Physical access available

### Troubleshooting
- **System Logs:** `journalctl -f`
- **Service Status:** `systemctl status <service>`
- **Health Check:** `./quick_health_check.sh`
- **Resource Usage:** Cockpit dashboard

### Documentation
- **Full System:** `SERVER_DOCUMENTATION.md`
- **VM Setup:** `VM_SETUP_COMPLETE.md`
- **Docker Guide:** `DOCKER_COCKPIT_GUIDE.md`
- **SSH Security:** `SSH_HARDENING_GUIDE.md`
- **Cockpit Setup:** `COCKPIT_SETUP.md`

---

## 🔄 Maintenance Notes

### Regular Tasks
- **System Updates:** Arch Linux rolling release
- **Container Images:** Regular updates recommended
- **VM Templates:** Periodic ISO refreshes
- **Security Scans:** Automated via scripts

### Backup Considerations
- **VM Storage:** `/var/lib/libvirt/images`
- **Container Data:** `/var/lib/docker`
- **Configs:** `/etc` directory
- **User Data:** `/home/dave`

### Capacity Planning
- **Current Usage:** 2% disk, minimal RAM/CPU
- **VM Headroom:** 28GB RAM, 24 vCPUs available
- **Container Headroom:** Nearly unlimited (within reason)
- **Storage Growth:** 436GB available for expansion

---

**📝 Note for Future Projects:**
This platform is production-ready for hosting virtual machines and containers. All security hardening, monitoring, and management tools are in place. The system can support multiple concurrent VMs and container workloads with comprehensive web-based management through Cockpit.

**🔗 Quick Start for New Projects:**
1. SSH to ws0 using your SSH key
2. Navigate to https://192.168.1.75:9090 for web management
3. Use `./vm_manager.sh` or `./docker_manager.sh` for CLI operations
4. Reference the specific setup guides for detailed procedures

---
*Generated for GitHub Copilot and future project reference*  
*Host: ws0 | Date: July 23, 2025*
