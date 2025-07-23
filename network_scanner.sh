#!/bin/bash

#===============================================================================
# Script Name: network_scanner.sh
# Description: Comprehensive network configuration scanner for dynamic environments
# Author: System Documentation Assistant
# Version: 1.0
# Date: $(date +"%Y-%m-%d")
#
# Purpose: Scans and documents network interfaces, bridges, tunnels, VPNs,
#          and virtualization networks that may change over time
#
# Usage: ./network_scanner.sh [--output FILE] [--format json|markdown|text]
#===============================================================================

set -euo pipefail

# Configuration
DEFAULT_OUTPUT="network_scan_$(date +%Y%m%d_%H%M%S).md"
OUTPUT_FILE="${1:-$DEFAULT_OUTPUT}"
FORMAT="markdown"
TEMP_DIR=$(mktemp -d)

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

# Logging functions
log() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Initialize output file
init_output() {
    log "Initializing network scan report: $OUTPUT_FILE"
    cat > "$OUTPUT_FILE" << EOF
# Network Configuration Scan Report

**Generated:** $(date)  
**Hostname:** $(hostname)  
**Scan Type:** Comprehensive Network Discovery

---

## Table of Contents

1. [Physical Interfaces](#1-physical-interfaces)
2. [Virtual Interfaces](#2-virtual-interfaces)
3. [Bridge Networks](#3-bridge-networks)
4. [Tunnel Interfaces](#4-tunnel-interfaces)
5. [Virtualization Networks](#5-virtualization-networks)
6. [Container Networks](#6-container-networks)
7. [VPN Connections](#7-vpn-connections)
8. [Routing Configuration](#8-routing-configuration)
9. [Network Services](#9-network-services)
10. [Firewall Configuration](#10-firewall-configuration)
11. [Changes Detection](#11-changes-detection)

---

EOF
}

# Scan physical interfaces
scan_physical_interfaces() {
    log "Scanning physical network interfaces..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 1. Physical Interfaces

### Interface Overview
```
EOF
    ip link show | grep -E "^[0-9]+:" | while read -r line; do
        interface=$(echo "$line" | awk '{print $2}' | sed 's/://')
        state=$(echo "$line" | grep -o '<[^>]*>' | tr -d '<>')
        # Get type from the interface name pattern or set as "unknown"
        if [[ $interface == lo ]]; then
            type="loopback"
        elif [[ $interface =~ ^(eth|enp|eno|ens) ]]; then
            type="ethernet"
        elif [[ $interface =~ ^(wlan|wlp) ]]; then
            type="wireless"
        elif [[ $interface =~ ^(virbr|docker|br-) ]]; then
            type="bridge"
        else
            type="virtual"
        fi
        echo "Interface: $interface | Type: $type | State: $state"
    done >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Physical Interface Details
EOF
    
    # Get all physical interfaces (exclude virtual ones)
    for iface in $(ip link show | grep -E "^[0-9]+:" | awk '{print $2}' | sed 's/://' | grep -E "^(eth|enp|eno|ens|wlan|wlp)"); do
        cat >> "$OUTPUT_FILE" << EOF

#### $iface
\`\`\`
EOF
        ip addr show "$iface" 2>/dev/null >> "$OUTPUT_FILE" || echo "Interface $iface not found" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # Get driver info if available
        if [ -d "/sys/class/net/$iface/device" ]; then
            driver=$(readlink "/sys/class/net/$iface/device/driver" 2>/dev/null | xargs basename)
            echo "Driver: $driver" >> "$OUTPUT_FILE"
        fi
        cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
    done
}

# Scan virtual interfaces
scan_virtual_interfaces() {
    log "Scanning virtual interfaces..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 2. Virtual Interfaces

### Virtual Interface Types
```
EOF
    
    # Detect different types of virtual interfaces
    for iface in $(ip link show | grep -E "^[0-9]+:" | awk '{print $2}' | sed 's/://'); do
        if [[ "$iface" =~ ^(lo|virbr|docker|br-|veth|tap|tun|wg) ]]; then
            type="unknown"
            case "$iface" in
                lo) type="loopback" ;;
                virbr*) type="libvirt-bridge" ;;
                docker*) type="docker-bridge" ;;
                br-*) type="docker-network" ;;
                veth*) type="virtual-ethernet" ;;
                tap*) type="tap-interface" ;;
                tun*) type="tunnel-interface" ;;
                wg*) type="wireguard" ;;
            esac
            echo "$iface: $type"
        fi
    done >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Virtual Interface Details
EOF
    
    for iface in $(ip link show | awk '/^[0-9]+:/ {print $2}' | sed 's/://' | grep -E "^(virbr|docker|br-|veth|tap|tun|wg)"); do
        cat >> "$OUTPUT_FILE" << EOF

#### $iface
\`\`\`
EOF
        ip addr show "$iface" 2>/dev/null >> "$OUTPUT_FILE"
        cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
    done
}

# Scan bridge networks
scan_bridges() {
    log "Scanning bridge networks..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 3. Bridge Networks

EOF
    
    if command_exists brctl; then
        cat >> "$OUTPUT_FILE" << 'EOF'
### Bridge Control Information
```
EOF
        brctl show 2>/dev/null >> "$OUTPUT_FILE" || echo "No bridges found via brctl" >> "$OUTPUT_FILE"
        cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
    fi
    
    # Modern bridge info via ip
    cat >> "$OUTPUT_FILE" << 'EOF'

### Bridge Interface Details
```
EOF
    ip link show type bridge 2>/dev/null >> "$OUTPUT_FILE" || echo "No bridge interfaces found" >> "$OUTPUT_FILE"
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Bridge Members
EOF
    
    for bridge in $(ip link show type bridge 2>/dev/null | grep -o '^[0-9]*: [^:]*' | cut -d' ' -f2); do
        cat >> "$OUTPUT_FILE" << EOF

#### Bridge: $bridge
\`\`\`
EOF
        if [ -d "/sys/class/net/$bridge/brif" ]; then
            ls /sys/class/net/$bridge/brif/ 2>/dev/null | while read -r member; do
                echo "Member: $member"
            done >> "$OUTPUT_FILE"
        fi
        cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
    done
}

# Scan tunnel interfaces
scan_tunnels() {
    log "Scanning tunnel interfaces..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 4. Tunnel Interfaces

### Tunnel Overview
```
EOF
    
    # Look for various tunnel types
    for iface in $(ip link show | awk '/^[0-9]+:/ {print $2}' | sed 's/://'); do
        if ip link show "$iface" 2>/dev/null | grep -q -E "(gre|vxlan|geneve|sit|ipip|ip6tnl|ip6gre)"; then
            tunnel_type=$(ip link show "$iface" | grep -o -E "(gre|vxlan|geneve|sit|ipip|ip6tnl|ip6gre)")
            echo "$iface: $tunnel_type tunnel"
        fi
    done >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Tunnel Details
EOF
    
    # Get detailed tunnel information
    for iface in $(ip link show | awk '/^[0-9]+:/ {print $2}' | sed 's/://'); do
        if ip link show "$iface" 2>/dev/null | grep -q -E "(gre|vxlan|geneve|sit|ipip|ip6tnl|ip6gre)"; then
            cat >> "$OUTPUT_FILE" << EOF

#### $iface
\`\`\`
EOF
            ip addr show "$iface" >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            ip -d link show "$iface" >> "$OUTPUT_FILE"
            cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
        fi
    done
}

# Scan virtualization networks
scan_virtualization_networks() {
    log "Scanning virtualization networks..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 5. Virtualization Networks

EOF
    
    # libvirt networks
    if command_exists virsh; then
        cat >> "$OUTPUT_FILE" << 'EOF'
### libvirt Networks
```
EOF
        virsh net-list --all 2>/dev/null >> "$OUTPUT_FILE" || echo "libvirt not accessible or no networks defined" >> "$OUTPUT_FILE"
        cat >> "$OUTPUT_FILE" << 'EOF'
```

### libvirt Network Details
EOF
        for net in $(virsh net-list --name 2>/dev/null); do
            cat >> "$OUTPUT_FILE" << EOF

#### Network: $net
\`\`\`
EOF
            virsh net-info "$net" 2>/dev/null >> "$OUTPUT_FILE"
            echo "" >> "$OUTPUT_FILE"
            virsh net-dumpxml "$net" 2>/dev/null | grep -E "(bridge|ip|dhcp|forward)" >> "$OUTPUT_FILE"
            cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
        done
    fi
    
    # VirtualBox networks (if present)
    if command_exists VBoxManage; then
        cat >> "$OUTPUT_FILE" << 'EOF'

### VirtualBox Networks
```
EOF
        VBoxManage list hostonlyifs 2>/dev/null >> "$OUTPUT_FILE" || echo "No VirtualBox host-only interfaces" >> "$OUTPUT_FILE"
        cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
    fi
}

# Scan container networks
scan_container_networks() {
    log "Scanning container networks..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 6. Container Networks

EOF
    
    # Docker networks
    if command_exists docker; then
        cat >> "$OUTPUT_FILE" << 'EOF'
### Docker Networks
```
EOF
        docker network ls 2>/dev/null >> "$OUTPUT_FILE" || echo "Docker not accessible" >> "$OUTPUT_FILE"
        cat >> "$OUTPUT_FILE" << 'EOF'
```

### Docker Network Details
EOF
        for net in $(docker network ls --format "{{.Name}}" 2>/dev/null); do
            cat >> "$OUTPUT_FILE" << EOF

#### Docker Network: $net
\`\`\`
EOF
            docker network inspect "$net" 2>/dev/null | jq -r '.[] | "Subnet: \(.IPAM.Config[0].Subnet // "N/A")\nGateway: \(.IPAM.Config[0].Gateway // "N/A")\nDriver: \(.Driver)"' 2>/dev/null >> "$OUTPUT_FILE" || \
            docker network inspect "$net" 2>/dev/null >> "$OUTPUT_FILE"
            cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
        done
    fi
    
    # Podman networks
    if command_exists podman; then
        cat >> "$OUTPUT_FILE" << 'EOF'

### Podman Networks
```
EOF
        podman network ls 2>/dev/null >> "$OUTPUT_FILE" || echo "Podman not accessible" >> "$OUTPUT_FILE"
        cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
    fi
}

# Scan VPN connections
scan_vpn_connections() {
    log "Scanning VPN connections..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 7. VPN Connections

### WireGuard Interfaces
```
EOF
    
    if command_exists wg; then
        wg show 2>/dev/null >> "$OUTPUT_FILE" || echo "No WireGuard interfaces active" >> "$OUTPUT_FILE"
    else
        echo "WireGuard not installed" >> "$OUTPUT_FILE"
    fi
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### OpenVPN Connections
```
EOF
    
    if pgrep openvpn >/dev/null; then
        ps aux | grep openvpn | grep -v grep >> "$OUTPUT_FILE"
    else
        echo "No OpenVPN processes running" >> "$OUTPUT_FILE"
    fi
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### VPN Interfaces
```
EOF
    
    for iface in $(ip link show | awk '/^[0-9]+:/ {print $2}' | sed 's/://'); do
        if [[ "$iface" =~ ^(tun|tap|wg|ppp) ]]; then
            echo "VPN Interface: $iface"
            ip addr show "$iface" 2>/dev/null | grep -E "(inet|inet6)" | head -2
            echo ""
        fi
    done >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
}

# Scan routing configuration
scan_routing() {
    log "Scanning routing configuration..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 8. Routing Configuration

### IPv4 Routing Table
```
EOF
    ip route show >> "$OUTPUT_FILE"
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### IPv6 Routing Table
```
EOF
    ip -6 route show >> "$OUTPUT_FILE"
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Policy Routing
```
EOF
    ip rule show >> "$OUTPUT_FILE"
    cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
}

# Scan network services
scan_network_services() {
    log "Scanning network services..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 9. Network Services

### Listening Ports
```
EOF
    ss -tulpn | head -20 >> "$OUTPUT_FILE"
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Network-Related Services
```
EOF
    systemctl list-units --type=service --state=running | grep -E "(network|dhcp|dns|bridge|libvirt|docker)" >> "$OUTPUT_FILE"
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### DNS Configuration
```
EOF
    cat /etc/resolv.conf >> "$OUTPUT_FILE"
    cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
}

# Scan firewall configuration
scan_firewall() {
    log "Scanning firewall configuration..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 10. Firewall Configuration

EOF
    
    if command_exists firewall-cmd; then
        cat >> "$OUTPUT_FILE" << 'EOF'
### firewalld Status
```
EOF
        firewall-cmd --state 2>/dev/null >> "$OUTPUT_FILE"
        firewall-cmd --get-active-zones 2>/dev/null >> "$OUTPUT_FILE"
        cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
    fi
    
    if command_exists iptables; then
        cat >> "$OUTPUT_FILE" << 'EOF'

### iptables Rules (Summary)
```
EOF
        iptables -L -n | head -20 >> "$OUTPUT_FILE" 2>/dev/null || echo "Cannot access iptables rules" >> "$OUTPUT_FILE"
        cat >> "$OUTPUT_FILE" << 'EOF'
```
EOF
    fi
}

# Generate change detection info
generate_change_detection() {
    log "Generating change detection information..."
    cat >> "$OUTPUT_FILE" << 'EOF'

## 11. Changes Detection

### Network Interface Summary
```
EOF
    
    # Create a summary for easy comparison
    echo "=== INTERFACE SUMMARY ===" >> "$OUTPUT_FILE"
    ip link show | grep -E "^[0-9]+:" | awk '{print $2 $3}' | sort >> "$OUTPUT_FILE"
    
    echo "" >> "$OUTPUT_FILE"
    echo "=== IP ADDRESS SUMMARY ===" >> "$OUTPUT_FILE"
    ip addr show | grep -E "inet " | awk '{print $2 " on " $7}' | sort >> "$OUTPUT_FILE"
    
    echo "" >> "$OUTPUT_FILE"
    echo "=== ROUTE SUMMARY ===" >> "$OUTPUT_FILE"
    ip route show | grep -E "^(default|[0-9])" | sort >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Baseline for Comparison
```
EOF
    
    # Generate checksums for comparison
    echo "Interface checksum: $(ip link show | md5sum | cut -d' ' -f1)" >> "$OUTPUT_FILE"
    echo "Address checksum: $(ip addr show | md5sum | cut -d' ' -f1)" >> "$OUTPUT_FILE"
    echo "Route checksum: $(ip route show | md5sum | cut -d' ' -f1)" >> "$OUTPUT_FILE"
    echo "Scan timestamp: $(date +%s)" >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << EOF

### Usage Notes
To detect changes, run this script again and compare:
1. Interface names and types
2. IP address assignments
3. Routing table entries
4. Bridge configurations
5. Virtual network definitions

Previous scan: $OUTPUT_FILE
Next scan: network_scan_\$(date +%Y%m%d_%H%M%S).md

### Quick Comparison Command
\`\`\`bash
# Compare two scan files
diff -u previous_scan.md current_scan.md | grep -E "^[+-]"
\`\`\`
EOF
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

---

**Network scan completed:** $(date)  
**Report file:** $OUTPUT_FILE
EOF
    
    # Replace variables
    sed -i "s/\$(date)/$(date)/" "$OUTPUT_FILE"
    sed -i "s/\$OUTPUT_FILE/$OUTPUT_FILE/" "$OUTPUT_FILE"
}

# Main execution
main() {
    log "Starting comprehensive network scan..."
    
    init_output
    scan_physical_interfaces
    scan_virtual_interfaces
    scan_bridges
    scan_tunnels
    scan_virtualization_networks
    scan_container_networks
    scan_vpn_connections
    scan_routing
    scan_network_services
    scan_firewall
    generate_change_detection
    
    log "Network scan completed successfully!"
    log "Report saved to: $OUTPUT_FILE"
    log "File size: $(du -h "$OUTPUT_FILE" | cut -f1)"
    
    # Show summary
    echo ""
    echo -e "${BLUE}=== QUICK SUMMARY ===${NC}"
    echo "Physical interfaces: $(ip link show | grep -c -E "^[0-9]+:.*(eth|enp|eno|ens|wlan|wlp)")"
    echo "Virtual interfaces: $(ip link show | grep -c -E "^[0-9]+:.*(virbr|docker|br-|veth|tun|tap)")"
    echo "Active addresses: $(ip addr show | grep -c "inet ")"
    echo "Bridge interfaces: $(ip link show type bridge 2>/dev/null | grep -c "^[0-9]*:" || echo "0")"
    
    if command_exists virsh; then
        echo "libvirt networks: $(virsh net-list --name 2>/dev/null | wc -l)"
    fi
    
    if command_exists docker; then
        echo "Docker networks: $(docker network ls --quiet 2>/dev/null | wc -l || echo "0")"
    fi
}

# Execute main function
main "$@"
