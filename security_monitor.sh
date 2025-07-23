#!/bin/bash

#===============================================================================
# Script Name: security_monitor.sh
# Description: Real-time security status and threat monitoring
# Usage: ./security_monitor.sh [--alerts-only] [--last-hours N]
#===============================================================================

set -euo pipefail

# Configuration
HOURS_BACK="${2:-24}"
ALERTS_ONLY="${1:-false}"
OUTPUT_FILE="security_status_$(date +%Y%m%d_%H%M%S).md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
alert() { echo -e "${RED}[ALERT]${NC} $1"; }

main() {
    log "Security Status Monitor - Last $HOURS_BACK hours"
    
    cat > "$OUTPUT_FILE" << EOF
# Security Status Report

**Generated:** $(date)
**Monitoring Period:** Last $HOURS_BACK hours
**Hostname:** $(hostname)

## Security Alerts Summary

EOF

    # Failed SSH attempts
    echo "### Failed SSH Login Attempts" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    journalctl --since="${HOURS_BACK} hours ago" | grep -i "failed password\|authentication failure" | tail -20 >> "$OUTPUT_FILE" 2>/dev/null || echo "No failed SSH attempts found" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Firewall blocks
    echo "### Firewall Activity" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    journalctl --since="${HOURS_BACK} hours ago" | grep -i firewall | tail -10 >> "$OUTPUT_FILE" 2>/dev/null || echo "No firewall activity" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # fail2ban activity
    echo "### fail2ban Status" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    if command -v fail2ban-client >/dev/null; then
        fail2ban-client status >> "$OUTPUT_FILE" 2>/dev/null
        echo "" >> "$OUTPUT_FILE"
        fail2ban-client status sshd 2>/dev/null >> "$OUTPUT_FILE" || echo "SSH jail not active" >> "$OUTPUT_FILE"
    else
        echo "fail2ban not installed" >> "$OUTPUT_FILE"
    fi
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # Current connections
    echo "### Active Network Connections" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    ss -tuln | head -15 >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # System resource alerts
    echo "### System Resource Alerts" >> "$OUTPUT_FILE"
    echo '```' >> "$OUTPUT_FILE"
    
    # Check for high CPU load
    load_avg=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
    cpu_count=$(nproc)
    if (( $(echo "$load_avg > $cpu_count * 1.5" | bc -l 2>/dev/null || echo "0") )); then
        alert "High CPU load: $load_avg (CPUs: $cpu_count)"
        echo "ALERT: High CPU load: $load_avg (CPUs: $cpu_count)" >> "$OUTPUT_FILE"
    fi
    
    # Check memory usage
    mem_usage=$(free | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}')
    if [ "$mem_usage" -gt 85 ]; then
        alert "High memory usage: ${mem_usage}%"
        echo "ALERT: High memory usage: ${mem_usage}%" >> "$OUTPUT_FILE"
    fi
    
    # Check disk usage
    df -h | awk '$5 > 85 {print "ALERT: " $6 " is " $5 " full"}' >> "$OUTPUT_FILE"
    
    echo '```' >> "$OUTPUT_FILE"
    
    log "Security report saved to: $OUTPUT_FILE"
}

main "$@"
