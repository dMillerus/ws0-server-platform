# Server Documentation

**Generated on:** Wed Jul 23 01:07:18 AM CDT 2025  
**Hostname:** ws0  
**Generated by:** generate_server_docs.sh

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Hardware](#2-hardware)
3. [Network](#3-network)
4. [Installed Packages](#4-installed-packages)
5. [Running Services & Processes](#5-running-services--processes)
6. [Open Ports & Firewall Rules](#6-open-ports--firewall-rules)
7. [User Accounts](#7-user-accounts)
8. [Scheduled Tasks](#8-scheduled-tasks)
9. [Security Configuration](#9-security-configuration)
10. [Containers & Virtualization](#10-containers--virtualization)
11. [Logs Summary](#11-logs-summary)
12. [Backup & Monitoring Agents](#12-backup--monitoring-agents)
13. [Known Issues & Notes](#13-known-issues--notes)

---


## 1. System Overview

| Attribute | Value |
|-----------|-------|
| **Date/Time of Run** | Wed Jul 23 01:07:18 AM CDT 2025 |
| **Hostname** | ws0 |
| **FQDN** | ws0 |
| **Operating System** | EndeavourOS Linux |
| **Kernel Version** | 6.15.7-arch1-1 |
| **Architecture** | x86_64 |
| **Uptime** | up 1 hour, 50 minutes |


## 2. Hardware

### CPU Information
```
CPU(s):                                  32
On-line CPU(s) list:                     0-31
Model name:                              13th Gen Intel(R) Core(TM) i9-13900F
Thread(s) per core:                      2
Core(s) per socket:                      24
Socket(s):                               1
CPU(s) scaling MHz:                      22%
NUMA node0 CPU(s):                       0-31
```

### Memory Information
```
               total        used        free      shared  buff/cache   available
Mem:            31Gi       2.0Gi        26Gi        10Mi       3.4Gi        29Gi
Swap:          511Mi          0B       511Mi
```

### Disk Layout
```
NAME                                          MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINTS
sda                                             8:0    0 119.2G  0 disk  
nvme1n1                                       259:0    0 476.9G  0 disk  
├─nvme1n1p1                                   259:1    0     2G  0 part  /efi
└─nvme1n1p2                                   259:2    0 474.9G  0 part  
  └─luks-ffc8300a-bd83-46ad-a295-008abe96d2e0 253:0    0 474.9G  0 crypt /var/lib/containers/storage/overlay
                                                                         /
nvme0n1                                       259:3    0 476.9G  0 disk  
├─nvme0n1p1                                   259:4    0     2G  0 part  
└─nvme0n1p2                                   259:5    0 474.9G  0 part  
```

### Disk Usage
```
Filesystem      Size  Used Avail Use% Mounted on
/dev/dm-0       467G  7.6G  436G   2% /
devtmpfs         16G     0   16G   0% /dev
tmpfs            16G  168K   16G   1% /dev/shm
efivarfs        192K  128K   60K  69% /sys/firmware/efi/efivars
tmpfs           6.3G  2.1M  6.3G   1% /run
tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-cryptsetup@luks\x2dffc8300a\x2dbd83\x2d46ad\x2da295\x2d008abe96d2e0.service
tmpfs           1.0M     0  1.0M   0% /run/credentials/systemd-journald.service
tmpfs            16G  8.1M   16G   1% /tmp
/dev/nvme1n1p1  2.0G  135M  1.9G   7% /efi
tmpfs           3.2G   72K  3.2G   1% /run/user/1000
tmpfs           1.0M     0  1.0M   0% /run/credentials/getty@tty1.service
```


## 3. Network

### Network Interfaces
```
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute 
       valid_lft forever preferred_lft forever
2: enp2s0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc fq_codel state DOWN group default qlen 1000
    link/ether cc:96:e5:41:6a:8d brd ff:ff:ff:ff:ff:ff
    altname enxcc96e5416a8d
3: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether c0:a5:e8:73:16:8a brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.75/24 brd 192.168.1.255 scope global dynamic noprefixroute wlan0
       valid_lft 4234sec preferred_lft 4234sec
    inet6 2603:9002:204:9500:a81a:928a:14a0:c6dc/64 scope global dynamic noprefixroute 
       valid_lft 85968sec preferred_lft 13968sec
    inet6 fe80::4ea2:f0cb:f9b0:53a/64 scope link noprefixroute 
       valid_lft forever preferred_lft forever
6: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc htb state DOWN group default qlen 1000
    link/ether 52:54:00:f3:7b:d5 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever
7: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default 
    link/ether 46:11:57:ce:87:ea brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::4411:57ff:fece:87ea/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
```

### Routing Table
```
default via 192.168.1.1 dev wlan0 proto dhcp src 192.168.1.75 metric 600 
172.17.0.0/16 dev docker0 proto kernel scope link src 172.17.0.1 linkdown 
192.168.1.0/24 dev wlan0 proto kernel scope link src 192.168.1.75 metric 600 
192.168.122.0/24 dev virbr0 proto kernel scope link src 192.168.122.1 linkdown 
```

### DNS Configuration
```
# Generated by NetworkManager
search dwmiller.us
nameserver 192.168.1.1
```


## 4. Installed Packages

### Package Count
**Total Installed Packages (pacman):** 722

### Key Software Inventory

#### Development Tools
```
docker                         1:28.3.2-1
docker-buildx                  0.25.0-1
docker-compose                 2.38.2-1
gcc                            15.1.1+r7+gf36ec88aa85a-1
git                            2.50.1-3
```

#### System Services & Management
```
cockpit                        342-1               (Web-based server management)
cockpit-machines               335-1               (VM management via Cockpit)
cockpit-podman                 109-1               (Container management)
libvirt                        1:11.5.0-1          (Virtualization management)
openssh                        10.0p1-3            (SSH server)
firewalld                      2.3.1-1             (Firewall management)
fail2ban                       1.1.0-7             (Intrusion prevention)
```

#### Virtualization Stack (Complete QEMU/KVM)
```
qemu-full                      10.0.2-1            (Complete QEMU emulation)
qemu-system-x86                10.0.2-1            (x86 system emulation)
virt-manager                   5.0.0-1             (VM management GUI)
virt-install                   5.0.0-1             (VM installation tool)
libvirt-python                 1:11.5.0-1          (Python bindings)
```

#### Security & Access Control
```
sudo                           1.9.17.p1-1
polkit                         126-2
iptables-nft                   1:1.8.11-2
fail2ban                       1.1.0-7
```

**Total Installed Packages:** 722 (via pacman)

## 5. Running Services & Processes

### Systemd Services Status
```
  UNIT                                  LOAD   ACTIVE SUB     DESCRIPTION
  avahi-daemon.service                  loaded active running Avahi mDNS/DNS-SD Stack
  cockpit-session@7-22328-65109.service loaded active running Cockpit session 7/22328/65109 (PID 22328/UID 65109)
  cockpit-wsinstance-http.service       loaded active running Cockpit Web Service http instance
  cockpit.service                       loaded active running Cockpit Web Service
  containerd.service                    loaded active running containerd container runtime
  dbus-broker.service                   loaded active running D-Bus System Message Bus
  docker.service                        loaded active running Docker Application Container Engine
  fail2ban.service                      loaded active running Fail2Ban Service
  firewalld.service                     loaded active running firewalld - dynamic firewall daemon
  getty@tty1.service                    loaded active running Getty on tty1
  libvirt-dbus.service                  loaded active running Libvirt DBus Service
  libvirtd.service                      loaded active running libvirt legacy monolithic daemon
  NetworkManager.service                loaded active running Network Manager
  podman.service                        loaded active running Podman API Service
  polkit.service                        loaded active running Authorization Manager
  power-profiles-daemon.service         loaded active running Power Profiles daemon
  sshd.service                          loaded active running OpenSSH Daemon
  systemd-journald.service              loaded active running Journal Service
  systemd-logind.service                loaded active running User Login Management

## Summary Information for ws0 Server

### Key System Details:
- **OS**: EndeavourOS Linux (Arch-based)
- **Kernel**: 6.15.7-arch1-1  
- **CPU**: 13th Gen Intel Core i9-13900F (32 cores)
- **Memory**: 31GB total, 29GB available
- **Disk**: 467GB primary drive, 2% used
- **Packages**: 722 installed via pacman

### Network Configuration:
- **Primary Network**: WiFi (wlan0) - 192.168.1.75/24
- **Ethernet**: enp2s0 (no carrier/disconnected)
- **Virtualization Networks**: 
  - virbr0 (192.168.122.1/24) - libvirt default
  - docker0 (172.17.0.1/16) - Docker bridge
- **Gateway**: 192.168.1.1 via wlan0
- **DNS**: 192.168.1.1 (NetworkManager managed)

### Key Capabilities:
- **Container Platform**: Full Docker + Podman setup
- **Virtualization**: Complete QEMU/KVM/libvirt stack
- **Web Management**: Cockpit with VM/container modules
- **Security**: Firewalld + fail2ban + SSH hardening
- **Development**: GCC 15, Git 2.50, full development toolchain

### Active Services:
- SSH server, Docker, Podman, libvirt, Cockpit
- NetworkManager, firewalld, fail2ban
- Standard systemd services

---
**Documentation generated for GitHub Copilot reference**
**Date: Wed Jul 23 01:08:37 AM CDT 2025**

