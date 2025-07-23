#!/bin/bash

#===============================================================================
# Script Name: backup_status_checker.sh
# Description: Check backup status for VMs, containers, and system configs
# Usage: ./backup_status_checker.sh [--verify] [--schedule]
#===============================================================================

set -euo pipefail

OUTPUT_FILE="backup_status_$(date +%Y%m%d_%H%M%S).md"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
alert() { echo -e "${RED}[ALERT]${NC} $1"; }

main() {
    log "Backup Status Checker"
    
    cat > "$OUTPUT_FILE" << EOF
# Backup Status Report

**Generated:** $(date)
**Hostname:** $(hostname)

## Backup Overview

EOF

    # VM backups
    echo "### Virtual Machine Backups" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    
    if command -v virsh >/dev/null 2>&1; then
        echo "VM Storage Locations:" >> "$OUTPUT_FILE"
        virsh pool-list --all 2>/dev/null >> "$OUTPUT_FILE" || echo "Cannot access libvirt pools" >> "$OUTPUT_FILE"
        
        echo "" >> "$OUTPUT_FILE"
        echo "VM Disk Images:" >> "$OUTPUT_FILE"
        if [ -d "/var/lib/libvirt/images" ]; then
            ls -lh /var/lib/libvirt/images/ | head -10 >> "$OUTPUT_FILE"
        else
            echo "Default VM image directory not found" >> "$OUTPUT_FILE"
        fi
        
        echo "" >> "$OUTPUT_FILE"
        echo "VM Snapshots:" >> "$OUTPUT_FILE"
        for vm in $(virsh list --all --name 2>/dev/null); do
            if [ -n "$vm" ]; then
                echo "=== $vm ===" >> "$OUTPUT_FILE"
                virsh snapshot-list "$vm" 2>/dev/null >> "$OUTPUT_FILE" || echo "No snapshots or cannot access" >> "$OUTPUT_FILE"
            fi
        done
    else
        echo "libvirt not available" >> "$OUTPUT_FILE"
    fi
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Container backups
    echo "### Container Backups" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    
    if command -v docker >/dev/null 2>&1; then
        echo "Docker Images:" >> "$OUTPUT_FILE"
        docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" 2>/dev/null | head -10 >> "$OUTPUT_FILE" || echo "Cannot access Docker images" >> "$OUTPUT_FILE"
        
        echo "" >> "$OUTPUT_FILE"
        echo "Docker Volumes:" >> "$OUTPUT_FILE"
        docker volume ls 2>/dev/null >> "$OUTPUT_FILE" || echo "Cannot access Docker volumes" >> "$OUTPUT_FILE"
    fi
    
    if command -v podman >/dev/null 2>&1; then
        echo "" >> "$OUTPUT_FILE"
        echo "Podman Images:" >> "$OUTPUT_FILE"
        podman images 2>/dev/null | head -5 >> "$OUTPUT_FILE" || echo "Cannot access Podman images" >> "$OUTPUT_FILE"
    fi
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # System configuration backups
    echo "### System Configuration Backups" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    
    echo "Important Config Files:" >> "$OUTPUT_FILE"
    for config in /etc/ssh/sshd_config /etc/fail2ban /etc/firewalld /etc/cockpit; do
        if [ -e "$config" ]; then
            echo "$config: $(stat -c '%y' "$config" | cut -d' ' -f1)" >> "$OUTPUT_FILE"
        fi
    done
    
    echo "" >> "$OUTPUT_FILE"
    echo "User Data Locations:" >> "$OUTPUT_FILE"
    echo "/home size: $(du -sh /home 2>/dev/null | cut -f1)" >> "$OUTPUT_FILE"
    echo "/var/lib/docker size: $(du -sh /var/lib/docker 2>/dev/null | cut -f1 || echo "N/A")" >> "$OUTPUT_FILE"
    echo "/var/lib/libvirt size: $(du -sh /var/lib/libvirt 2>/dev/null | cut -f1 || echo "N/A")" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Backup tools detection
    echo "### Backup Tools Detection" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    
    backup_tools=("rsync" "borg" "duplicity" "restic" "tar" "rsnapshot")
    echo "Available Backup Tools:" >> "$OUTPUT_FILE"
    for tool in "${backup_tools[@]}"; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✓ $tool: $(which $tool)" >> "$OUTPUT_FILE"
        else
            echo "✗ $tool: not installed" >> "$OUTPUT_FILE"
        fi
    done
    
    echo "" >> "$OUTPUT_FILE"
    echo "Scheduled Backups (cron/systemd):" >> "$OUTPUT_FILE"
    
    # Check for backup-related cron jobs
    if [ -f /etc/crontab ]; then
        grep -i backup /etc/crontab 2>/dev/null | head -3 >> "$OUTPUT_FILE" || echo "No backup cron jobs in /etc/crontab" >> "$OUTPUT_FILE"
    fi
    
    # Check systemd timers for backups
    systemctl list-timers 2>/dev/null | grep -i backup >> "$OUTPUT_FILE" || echo "No backup systemd timers found" >> "$OUTPUT_FILE"
    
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Backup recommendations
    echo "### Backup Recommendations" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "Critical Data to Backup:" >> "$OUTPUT_FILE"
    echo "1. VM Disk Images: /var/lib/libvirt/images/" >> "$OUTPUT_FILE"
    echo "2. VM Configurations: virsh dumpxml for each VM" >> "$OUTPUT_FILE"
    echo "3. Docker Volumes: docker volume backup" >> "$OUTPUT_FILE"
    echo "4. Container Images: docker save for important images" >> "$OUTPUT_FILE"
    echo "5. System Configs: /etc/, /home/, custom scripts" >> "$OUTPUT_FILE"
    echo "6. Cockpit configs: /etc/cockpit/" >> "$OUTPUT_FILE"
    echo "7. Network configs: firewall rules, network definitions" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Suggested Backup Commands:" >> "$OUTPUT_FILE"
    echo "# VM backup: virsh dumpxml vmname > vmname.xml && cp /var/lib/libvirt/images/vmname.qcow2 backup/" >> "$OUTPUT_FILE"
    echo "# Docker backup: docker save imagename > imagename.tar" >> "$OUTPUT_FILE"
    echo "# Config backup: tar -czf configs_\$(date +%Y%m%d).tar.gz /etc/ssh /etc/fail2ban /etc/firewalld" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    
    log "Backup status report saved to: $OUTPUT_FILE"
    
    # Quick alerts
    if ! command -v rsync >/dev/null 2>&1 && ! command -v borg >/dev/null 2>&1; then
        warn "No common backup tools detected - consider installing rsync or borg"
    fi
    
    vm_count=$(virsh list --all --name 2>/dev/null | wc -l || echo "0")
    if [ "$vm_count" -gt 0 ]; then
        log "Found $vm_count VMs - ensure regular backups are configured"
    fi
}

main "$@"
