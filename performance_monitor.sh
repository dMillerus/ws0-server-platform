#!/bin/bash

#===============================================================================
# Script Name: performance_monitor.sh
# Description: System performance monitoring and alerting
# Usage: ./performance_monitor.sh [--continuous] [--interval SECONDS]
#===============================================================================

set -euo pipefail

INTERVAL="${2:-300}"  # 5 minutes default
CONTINUOUS="${1:-false}"
OUTPUT_FILE="performance_$(date +%Y%m%d_%H%M%S).md"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
alert() { echo -e "${RED}[ALERT]${NC} $1"; }

get_performance_snapshot() {
    local timestamp=$(date)
    
    cat >> "$OUTPUT_FILE" << EOF

## Performance Snapshot - $timestamp

### CPU Usage
\`\`\`
EOF
    
    # CPU info
    echo "Load Average: $(uptime | awk '{print $(NF-2) " " $(NF-1) " " $NF}')" >> "$OUTPUT_FILE"
    echo "CPU Count: $(nproc)" >> "$OUTPUT_FILE"
    
    # Top CPU processes
    echo "" >> "$OUTPUT_FILE"
    echo "Top CPU Processes:" >> "$OUTPUT_FILE"
    ps aux --sort=-%cpu | head -6 | awk '{printf "%-10s %6s %6s %s\n", $1, $3, $4, $11}' >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Memory Usage
```
EOF
    
    free -h >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    echo "Top Memory Processes:" >> "$OUTPUT_FILE"
    ps aux --sort=-%mem | head -6 | awk '{printf "%-10s %6s %6s %s\n", $1, $3, $4, $11}' >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Disk I/O
```
EOF
    
    if command -v iostat >/dev/null 2>&1; then
        iostat -x 1 1 2>/dev/null | tail -n +4 >> "$OUTPUT_FILE"
    else
        echo "iostat not available (install sysstat package)" >> "$OUTPUT_FILE"
    fi
    
    echo "" >> "$OUTPUT_FILE"
    echo "Disk Usage:" >> "$OUTPUT_FILE"
    df -h | grep -E "(Filesystem|/dev/)" >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Network Activity
```
EOF
    
    echo "Active Connections:" >> "$OUTPUT_FILE"
    ss -s >> "$OUTPUT_FILE"
    
    echo "" >> "$OUTPUT_FILE"
    echo "Network Interface Statistics:" >> "$OUTPUT_FILE"
    for iface in $(ip link show | awk '/^[0-9]+:/ {print $2}' | sed 's/://' | grep -v lo | head -3); do
        echo "=== $iface ===" >> "$OUTPUT_FILE"
        cat "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null | awk '{printf "RX: %.2f MB\n", $1/1024/1024}' >> "$OUTPUT_FILE"
        cat "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null | awk '{printf "TX: %.2f MB\n", $1/1024/1024}' >> "$OUTPUT_FILE"
    done
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### System Resources
```
EOF
    
    echo "Uptime: $(uptime -p)" >> "$OUTPUT_FILE"
    echo "Users: $(who | wc -l) active sessions" >> "$OUTPUT_FILE"
    echo "Processes: $(ps aux | wc -l) total" >> "$OUTPUT_FILE"
    
    # Check for resource alerts
    echo "" >> "$OUTPUT_FILE"
    echo "Resource Alerts:" >> "$OUTPUT_FILE"
    
    # CPU load check
    load_avg=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
    cpu_count=$(nproc)
    if (( $(echo "$load_avg > $cpu_count * 2" | bc -l 2>/dev/null || echo "0") )); then
        echo "⚠️  HIGH CPU LOAD: $load_avg (CPUs: $cpu_count)" >> "$OUTPUT_FILE"
        alert "High CPU load detected: $load_avg"
    fi
    
    # Memory check
    mem_usage=$(free | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}')
    if [ "$mem_usage" -gt 90 ]; then
        echo "⚠️  HIGH MEMORY USAGE: ${mem_usage}%" >> "$OUTPUT_FILE"
        alert "High memory usage detected: ${mem_usage}%"
    fi
    
    # Disk space check
    df -h | awk '$5 > 90 {print "⚠️  DISK FULL: " $6 " is " $5 " full"}' >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

---

EOF
}

main() {
    log "Performance Monitor Starting"
    
    cat > "$OUTPUT_FILE" << EOF
# System Performance Monitor Report

**Generated:** $(date)
**Hostname:** $(hostname)
**Monitoring Mode:** $([ "$CONTINUOUS" = "--continuous" ] && echo "Continuous (${INTERVAL}s intervals)" || echo "Single snapshot")

EOF
    
    if [ "$CONTINUOUS" = "--continuous" ]; then
        log "Continuous monitoring mode - Press Ctrl+C to stop"
        while true; do
            get_performance_snapshot
            log "Snapshot captured - sleeping ${INTERVAL}s"
            sleep "$INTERVAL"
        done
    else
        get_performance_snapshot
        log "Performance snapshot saved to: $OUTPUT_FILE"
    fi
}

main "$@"
