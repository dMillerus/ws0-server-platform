# 🖥️ Server Management & Monitoring Suite

A comprehensive collection of Bash scripts for Linux server documentation, monitoring, and management. This suite provides everything needed to document, monitor, and maintain a modern Linux server infrastructure.

## 🚀 Quick Start

**The main entry point is the wrapper script:**

```bash
./system_manager.sh
```

This provides a beautiful menu-driven interface to access all monitoring tools and system management functions.

---

## 📋 Table of Contents

1. [Main Wrapper Script](#main-wrapper-script)
2. [Core Documentation Scripts](#core-documentation-scripts)
3. [Monitoring Scripts](#monitoring-scripts)
4. [System Management Scripts](#system-management-scripts)
5. [Generated Reports](#generated-reports)
6. [Installation & Setup](#installation--setup)
7. [Usage Examples](#usage-examples)
8. [System Requirements](#system-requirements)

---

## 🎯 Main Wrapper Script

### `system_manager.sh` ⭐ **[PRIMARY INTERFACE]**

The **master wrapper script** that provides a unified, menu-driven interface to all system management tools.

**Features:**
- Beautiful ASCII art interface with box drawing characters
- Real-time system status display (load, memory, disk usage)
- 8 organized menu categories for easy navigation
- Professional terminal UI with color coding
- Integration with all monitoring and management scripts

**Menu Categories:**
1. **System Documentation & Reports** - Generate comprehensive system docs
2. **Real-time Monitoring** - Live system performance and health monitoring  
3. **Security & Health Checks** - Security scans and system health validation
4. **Network Management** - Network configuration and connectivity tools
5. **Container & VM Management** - Docker, Podman, and virtualization tools
6. **System Setup & Configuration** - SSH hardening, 2FA, service setup
7. **Backup & Recovery** - Backup status and recovery tools
8. **Script Management** - Manage and execute individual monitoring scripts

```bash
# Launch the main interface
./system_manager.sh
```

---

## 📄 Core Documentation Scripts

### `generate_server_docs.sh`
Comprehensive system documentation generator that creates a detailed Markdown report.

**Generates:** `SERVER_DOCUMENTATION.md` (19,640 bytes typical)

**Sections Covered:**
1. System Overview (OS, kernel, hardware)
2. Hardware Details (CPU, memory, storage)
3. Network Configuration (interfaces, routing, DNS)
4. Installed Packages (complete inventory)
5. Running Services & Processes
6. Open Ports & Firewall Rules
7. User Accounts & Permissions
8. Scheduled Tasks (cron jobs)
9. Security Configuration
10. Containers & Virtualization
11. Logs Summary
12. Backup & Monitoring Agents
13. Known Issues & Notes

```bash
# Generate comprehensive server documentation
./generate_server_docs.sh
```

---

## 🔍 Monitoring Scripts

### `quick_health_check.sh`
Master health check script that provides rapid system status overview.

**Features:**
- Quick system metrics (load, memory, disk, users)
- Basic health alerts and warnings
- Integration with all monitoring tools
- Summary status reporting
- Available scripts listing with usage examples

```bash
# Quick health check
./quick_health_check.sh

# Full detailed health check
./quick_health_check.sh --full
```

### `network_scanner.sh`
Comprehensive network configuration scanner and change detector.

**Features:**
- Physical and virtual interface discovery
- Bridge and tunnel network analysis
- Container network mapping
- VPN connection detection
- Routing and firewall configuration
- Change detection and baseline comparison

**Generates:** `network_scan_YYYYMMDD_HHMMSS.md`

```bash
# Scan current network configuration
./network_scanner.sh

# Generate change detection baseline
./network_scanner.sh --baseline
```

### `performance_monitor.sh`
System performance monitoring and resource usage analysis.

**Features:**
- CPU, memory, and disk performance metrics
- Process monitoring and resource consumption
- Load average trending
- System bottleneck identification
- Performance snapshot generation

**Generates:** `performance_YYYYMMDD_HHMMSS.md`

```bash
# Performance snapshot
./performance_monitor.sh --summary

# Continuous monitoring
./performance_monitor.sh --continuous
```

### `security_monitor.sh`
Security monitoring and threat detection.

**Features:**
- Failed login attempt analysis
- SSH security monitoring
- Intrusion detection alerts
- Security log analysis
- User activity monitoring

```bash
# Security check for last 24 hours
./security_monitor.sh

# Check last hour only
./security_monitor.sh --last-hours 1
```

### `container_health_monitor.sh`
Container and virtualization platform health monitoring.

**Features:**
- Docker container health and status
- Podman container monitoring
- Virtual machine status (libvirt/QEMU)
- Container resource usage
- Service availability checks

```bash
# Check all container platforms
./container_health_monitor.sh

# Docker-only health check
./container_health_monitor.sh --docker-only
```

### `backup_status_checker.sh`
Backup system status and recommendations.

**Features:**
- Backup job status monitoring
- Storage space analysis
- Backup schedule validation
- Recovery point objectives
- Backup system health

```bash
# Check backup status
./backup_status_checker.sh

# Generate backup recommendations
./backup_status_checker.sh --recommendations
```

---

## ⚙️ System Management Scripts

### SSH & Security Setup
- `harden_ssh.sh` - SSH security hardening
- `setup_2fa.sh` - Two-factor authentication setup
- `ssh_security_check.sh` - SSH configuration validation

### Container & Virtualization Setup
- `setup_docker_cockpit.sh` - Docker + Cockpit web management
- `setup_libvirt_cockpit.sh` - Libvirt + Cockpit VM management
- `docker_manager.sh` - Docker container management
- `vm_manager.sh` - Virtual machine management

---

## 📊 Generated Reports

### Server Documentation
- `SERVER_DOCUMENTATION.md` - Complete system documentation
- `ssh_hardening.log` - SSH security configuration log
- `vm_setup.log` - Virtual machine setup log
- `docker_setup.log` - Docker installation log

### Monitoring Reports
- `network_scan_YYYYMMDD_HHMMSS.md` - Network configuration snapshots
- `performance_YYYYMMDD_HHMMSS.md` - Performance monitoring reports
- `health_reports_YYYYMMDD_HHMMSS/` - Comprehensive health check reports

### Setup Guides
- `COCKPIT_SETUP.md` - Cockpit web interface setup guide
- `DOCKER_COCKPIT_GUIDE.md` - Docker + Cockpit integration guide
- `LIBVIRT_COCKPIT_GUIDE.md` - Virtualization + Cockpit guide
- `SSH_HARDENING_GUIDE.md` - SSH security implementation guide
- `VM_SETUP_COMPLETE.md` - Virtual machine setup completion guide

---

## 🛠️ Installation & Setup

### Prerequisites
- Modern Linux distribution (Arch, Ubuntu, CentOS, etc.)
- Bash 4.0 or higher
- Standard system utilities (ip, ss, systemctl, etc.)
- Root or sudo access for system configuration

### Quick Installation

```bash
# Clone or download the scripts
git clone <repository> server-management-suite
cd server-management-suite

# Make all scripts executable
chmod +x *.sh

# Launch the main interface
./system_manager.sh
```

### Package Dependencies

**Core utilities (usually pre-installed):**
- `ip`, `ss`, `systemctl`, `journalctl`
- `lscpu`, `free`, `df`, `ps`, `top`
- `awk`, `sed`, `grep`, `cut`

**Optional for enhanced features:**
- `docker` - Container monitoring
- `libvirt` - Virtual machine monitoring
- `fail2ban` - Security monitoring
- `firewalld` - Firewall management
- `cockpit` - Web-based management

---

## 💡 Usage Examples

### Daily System Check
```bash
# Quick morning health check
./quick_health_check.sh

# Or use the menu interface
./system_manager.sh
# → Select: "3. Security & Health Checks"
# → Select: "1. Quick Health Check"
```

### Weekly Documentation Update
```bash
# Generate fresh server documentation
./generate_server_docs.sh

# Network configuration review
./network_scanner.sh
```

### Security Monitoring
```bash
# Check security status
./security_monitor.sh

# Monitor failed login attempts
./security_monitor.sh --last-hours 24
```

### Performance Analysis
```bash
# Performance snapshot
./performance_monitor.sh --summary

# Continuous monitoring (background)
./performance_monitor.sh --continuous &
```

### Complete System Audit
```bash
# Use the wrapper for comprehensive audit
./system_manager.sh
# → Select: "1. System Documentation & Reports"
# → Select: "1. Generate Complete Server Documentation"
# → Select: "2. Real-time Monitoring"
# → Select: "1. Performance Monitor"
```

---

## 🖥️ System Requirements

### Tested Platforms
- **EndeavourOS** (Arch-based) ✅
- **Ubuntu 20.04+** ✅
- **CentOS 8+** ✅
- **Debian 11+** ✅
- **Fedora 35+** ✅

### Hardware Requirements
- **CPU:** Any modern x86_64 processor
- **Memory:** 1GB+ RAM (for script execution)
- **Storage:** 100MB+ free space (for reports)
- **Network:** Active network interface (for network scanning)

### Software Stack Support
- **Containers:** Docker, Podman, containerd
- **Virtualization:** QEMU/KVM, libvirt, Xen
- **Web Management:** Cockpit, Webmin
- **Security:** fail2ban, firewalld, iptables
- **Package Managers:** pacman, apt, yum, dnf

---

## 🔧 Configuration

### Environment Variables
```bash
# Optional: Customize report output directory
export MONITORING_REPORTS_DIR="/var/log/monitoring"

# Optional: Set default monitoring interval
export MONITORING_INTERVAL="300"  # 5 minutes

# Optional: Email notifications
export ALERT_EMAIL="admin@example.com"
```

### Customization
- Edit script variables at the top of each file
- Modify report templates in the documentation functions
- Adjust monitoring thresholds in health check scripts
- Customize menu options in `system_manager.sh`

---

## 📈 Features Overview

| Feature | Script | Status | Description |
|---------|--------|--------|-------------|
| **Menu Interface** | `system_manager.sh` | ✅ | Unified wrapper with beautiful terminal UI |
| **Server Documentation** | `generate_server_docs.sh` | ✅ | Complete system inventory and configuration |
| **Health Monitoring** | `quick_health_check.sh` | ✅ | Rapid system health assessment |
| **Network Scanning** | `network_scanner.sh` | ✅ | Comprehensive network discovery and changes |
| **Performance Monitoring** | `performance_monitor.sh` | ✅ | System performance and resource usage |
| **Security Monitoring** | `security_monitor.sh` | ✅ | Security threats and intrusion detection |
| **Container Health** | `container_health_monitor.sh` | ✅ | Docker/Podman/VM health monitoring |
| **Backup Status** | `backup_status_checker.sh` | ✅ | Backup system health and recommendations |
| **SSH Hardening** | `harden_ssh.sh` | ✅ | SSH security configuration |
| **2FA Setup** | `setup_2fa.sh` | ✅ | Two-factor authentication implementation |
| **Docker Setup** | `setup_docker_cockpit.sh` | ✅ | Docker + Cockpit integration |
| **VM Setup** | `setup_libvirt_cockpit.sh` | ✅ | Virtualization + Cockpit setup |

---

## 🎯 Use Cases

### System Administrators
- Daily server health monitoring
- Comprehensive system documentation
- Security threat detection
- Performance bottleneck identification
- Infrastructure change tracking

### DevOps Engineers
- Container and VM health monitoring
- Automated system documentation
- Infrastructure as Code validation
- Performance baseline establishment
- Security compliance checking

### IT Support Teams
- Quick system status overview
- Troubleshooting system issues
- User activity monitoring
- Service availability checking
- System configuration validation

### Security Teams
- Security posture assessment
- Intrusion detection monitoring
- Access control validation
- Security configuration auditing
- Incident response preparation

---

## 🤝 Contributing

This suite is designed to be easily extensible. To add new monitoring capabilities:

1. Create new script following the existing naming convention
2. Add logging and error handling using the established patterns
3. Update `system_manager.sh` menu to include new functionality
4. Update this README with new script documentation
5. Test on multiple Linux distributions

---

## 📝 License

This server management suite is designed for system administration and monitoring purposes. Modify and distribute according to your organization's requirements.

---

## 🆘 Support & Troubleshooting

### Common Issues

**Permission Denied:**
```bash
chmod +x *.sh
```

**Missing Dependencies:**
- Install required packages for your distribution
- Check script output for specific missing commands

**Network Scanner Errors:**
- Ensure script has network access
- Verify ip command is available

**Performance Monitor Issues:**
- Check system load during monitoring
- Verify sufficient disk space for reports

### Debug Mode
Run any script with debug output:
```bash
bash -x ./script_name.sh
```

---

**Generated:** July 23, 2025  
**Version:** 1.0  
**Maintainer:** System Administrator  
**Last Updated:** July 23, 2025

---

> 💡 **Quick Tip:** Start with `./system_manager.sh` for the best experience! This wrapper script provides easy access to all tools with a professional menu interface.
