#!/bin/bash

#===============================================================================
# Script Name: quick_health_check.sh
# Description: Master health check script that runs all monitoring scripts
# Usage: ./quick_health_check.sh [--full] [--alerts-only]
#===============================================================================

set -euo pipefail

# Global variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FULL_CHECK="${1:-false}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="health_reports_$TIMESTAMP"
alerts=0  # Global alerts counter

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
alert() { echo -e "${RED}[ALERT]${NC} $1"; }
header() { echo -e "${BLUE}=== $1 ===${NC}"; }

# Make scripts executable
make_executable() {
    for script in security_monitor.sh container_health_monitor.sh performance_monitor.sh backup_status_checker.sh network_scanner.sh; do
        if [ -f "$SCRIPT_DIR/$script" ]; then
            chmod +x "$SCRIPT_DIR/$script" 2>/dev/null || true
        fi
    done
}

# Quick system overview
quick_overview() {
    header "QUICK SYSTEM OVERVIEW"
    
    echo "Hostname: $(hostname)"
    echo "Date: $(date)"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime | awk '{print $3,$4}' | sed 's/,//')"
    echo "Load: $(uptime | awk '{print $(NF-2) " " $(NF-1) " " $NF}')"
    echo "Memory: $(free -h | grep '^Mem:' | awk '{print $3 "/" $2 " (" int($3/$2*100) "%)"}')"
    echo "Disk: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 ")"}')"
    echo "Users: $(who | wc -l) active sessions"
    echo ""
    
    # Quick alerts - use global variable
    alerts=0
    
    # Check load
    local load_avg=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
    local cpu_count=$(nproc)
    if (( $(echo "$load_avg > $cpu_count * 1.5" | bc -l 2>/dev/null || echo "0") )); then
        alert "High CPU load: $load_avg (CPUs: $cpu_count)"
        ((alerts++))
    fi
    
    # Check memory
    local mem_usage=$(free | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}')
    if [ "$mem_usage" -gt 90 ]; then
        alert "High memory usage: ${mem_usage}%"
        ((alerts++))
    fi
    
    # Check disk space
    while read -r line; do
        if echo "$line" | awk '$5 > 90 {exit 0} {exit 1}'; then
            alert "Disk space critical: $line"
            ((alerts++))
        fi
    done < <(df -h | grep -E "/dev/")
    
    # Check critical services
    for service in sshd fail2ban firewalld; do
        if ! systemctl is-active "$service" >/dev/null 2>&1; then
            warn "Service $service is not running"
            ((alerts++))
        fi
    done
    
    if [ $alerts -eq 0 ]; then
        log "No immediate alerts detected"
    else
        warn "Found $alerts potential issues"
    fi
    echo ""
}

# Run individual health checks
run_health_checks() {
    if [ "$FULL_CHECK" = "--full" ]; then
        header "RUNNING FULL HEALTH CHECKS"
        mkdir -p "$REPORT_DIR"
        cd "$REPORT_DIR"
        
        log "Running security monitor..."
        if [ -f "$SCRIPT_DIR/security_monitor.sh" ]; then
            bash "$SCRIPT_DIR/security_monitor.sh" || warn "Security monitor failed"
        fi
        
        log "Running container health monitor..."
        if [ -f "$SCRIPT_DIR/container_health_monitor.sh" ]; then
            bash "$SCRIPT_DIR/container_health_monitor.sh" || warn "Container monitor failed"
        fi
        
        log "Running performance monitor..."
        if [ -f "$SCRIPT_DIR/performance_monitor.sh" ]; then
            bash "$SCRIPT_DIR/performance_monitor.sh" || warn "Performance monitor failed"
        fi
        
        log "Running backup status checker..."
        if [ -f "$SCRIPT_DIR/backup_status_checker.sh" ]; then
            bash "$SCRIPT_DIR/backup_status_checker.sh" || warn "Backup checker failed"
        fi
        
        log "Running network scanner..."
        if [ -f "$SCRIPT_DIR/network_scanner.sh" ]; then
            bash "$SCRIPT_DIR/network_scanner.sh" || warn "Network scanner failed"
        fi
        
        cd ..
        log "Full health check reports saved in: $REPORT_DIR"
        log "Report files:"
        ls -la "$REPORT_DIR"/ | grep -E "\.(md|txt)$" | awk '{print "  " $9 " (" $5 " bytes)"}'
    else
        header "BASIC HEALTH CHECKS"
        
        # Basic container check
        if command -v docker >/dev/null 2>&1; then
            local running_containers=$(docker ps --format "{{.Names}}" 2>/dev/null | wc -l)
            local total_containers=$(docker ps -a --format "{{.Names}}" 2>/dev/null | wc -l)
            echo "Docker: $running_containers/$total_containers containers running"
            
            local unhealthy=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" 2>/dev/null)
            if [ -n "$unhealthy" ]; then
                alert "Unhealthy containers: $unhealthy"
            fi
        fi
        
        # Basic VM check
        if command -v virsh >/dev/null 2>&1; then
            local running_vms=$(virsh list --name 2>/dev/null | wc -l)
            local total_vms=$(virsh list --all --name 2>/dev/null | wc -l)
            echo "VMs: $running_vms/$total_vms virtual machines running"
        fi
        
        # Basic network check
        local interfaces=$(ip link show | grep -c "state UP")
        echo "Network: $interfaces interfaces up"
        
        # Basic security check
        if command -v fail2ban-client >/dev/null 2>&1; then
            local banned=$(fail2ban-client status 2>/dev/null | grep -o "Currently banned:.*" | awk '{print $3}' || echo "0")
            echo "Security: $banned currently banned IPs"
        fi
        
        echo ""
    fi
}

# Generate summary
generate_summary() {
    header "SYSTEM SUMMARY"
    
    cat << EOF
System Status: $([ $alerts -eq 0 ] && echo "✅ HEALTHY" || echo "⚠️  NEEDS ATTENTION")
Last Check: $(date)
Check Type: $([ "$FULL_CHECK" = "--full" ] && echo "Full Health Check" || echo "Quick Health Check")

Available Scripts:
✓ security_monitor.sh     - Security threats and login attempts
✓ container_health_monitor.sh - Docker/Podman/VM health
✓ performance_monitor.sh  - System performance metrics
✓ backup_status_checker.sh - Backup status and recommendations  
✓ network_scanner.sh      - Network configuration changes
✓ quick_health_check.sh   - This master health check

Usage Examples:
  ./quick_health_check.sh --full    # Run all detailed checks
  ./security_monitor.sh --last-hours 1  # Check last hour only
  ./performance_monitor.sh --continuous # Continuous monitoring
  ./network_scanner.sh              # Current network state

EOF
}

main() {
    log "Quick Health Check - $(hostname)"
    echo ""
    
    make_executable
    quick_overview
    run_health_checks
    generate_summary
    
    if [ "$FULL_CHECK" = "--full" ]; then
        log "Full health check completed. Reports in: $REPORT_DIR/"
    else
        log "Quick health check completed. Use '--full' for detailed reports."
    fi
}

main "$@"
