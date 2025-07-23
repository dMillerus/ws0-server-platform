#!/bin/bash

#===============================================================================
# Script Name: container_health_monitor.sh
# Description: Monitor health and status of all containers and VMs
# Usage: ./container_health_monitor.sh [--json] [--alerts-only]
#===============================================================================

set -euo pipefail

OUTPUT_FILE="container_health_$(date +%Y%m%d_%H%M%S).md"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
alert() { echo -e "${RED}[ALERT]${NC} $1"; }

main() {
    log "Container and VM Health Monitor"
    
    cat > "$OUTPUT_FILE" << EOF
# Container & VM Health Report

**Generated:** $(date)
**Hostname:** $(hostname)

EOF

    # Docker containers
    if command -v docker >/dev/null 2>&1; then
        echo "## Docker Containers" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        
        if docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null; then
            docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" >> "$OUTPUT_FILE" 2>/dev/null
            echo "" >> "$OUTPUT_FILE"
            
            # Check for unhealthy containers
            unhealthy=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" 2>/dev/null)
            if [ -n "$unhealthy" ]; then
                alert "Unhealthy containers found: $unhealthy"
                echo "ALERT: Unhealthy containers: $unhealthy" >> "$OUTPUT_FILE"
            fi
            
            # Check for exited containers
            exited=$(docker ps -a --filter "status=exited" --format "{{.Names}}" 2>/dev/null)
            if [ -n "$exited" ]; then
                warn "Exited containers: $exited"
                echo "WARNING: Exited containers: $exited" >> "$OUTPUT_FILE"
            fi
        else
            echo "Docker not accessible" >> "$OUTPUT_FILE"
        fi
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # Docker resource usage
        echo "### Docker Resource Usage" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}" 2>/dev/null >> "$OUTPUT_FILE" || echo "Cannot get Docker stats" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
    
    # Podman containers
    if command -v podman >/dev/null 2>&1; then
        echo "## Podman Containers" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        podman ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null >> "$OUTPUT_FILE" || echo "Podman not accessible" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
    
    # libvirt VMs
    if command -v virsh >/dev/null 2>&1; then
        echo "## Virtual Machines (libvirt)" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        virsh list --all 2>/dev/null >> "$OUTPUT_FILE" || echo "libvirt not accessible" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # VM resource usage
        echo "### VM Resource Allocation" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        for vm in $(virsh list --name 2>/dev/null); do
            if [ -n "$vm" ]; then
                echo "=== $vm ===" >> "$OUTPUT_FILE"
                virsh dominfo "$vm" 2>/dev/null | grep -E "(Used memory|Max memory|CPU)" >> "$OUTPUT_FILE"
                echo "" >> "$OUTPUT_FILE"
            fi
        done >> "$OUTPUT_FILE" 2>/dev/null || echo "No running VMs or cannot access" >> "$OUTPUT_FILE"
        echo '```' >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
    
    # System services that support containers/VMs
    echo "## Container/VM Services Status" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    for service in docker podman libvirtd containerd; do
        if systemctl is-active "$service" >/dev/null 2>&1; then
            echo "$service: $(systemctl is-active $service)" >> "$OUTPUT_FILE"
        fi
    done
    echo '```' >> "$OUTPUT_FILE"
    
    log "Container health report saved to: $OUTPUT_FILE"
}

main "$@"
