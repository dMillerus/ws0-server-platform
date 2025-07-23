#!/bin/bash

# Complete the documentation where the original script left off
set -euo pipefail
OUTPUT_FILE="SERVER_DOCUMENTATION.md"

# Check if file exists and what's the last section
if [ -f "$OUTPUT_FILE" ]; then
    echo "Continuing documentation from where it left off..."
    
    # Add the remaining sections
    cat >> "$OUTPUT_FILE" << 'EOF'
... (showing first 50 packages, total: 722)
```

## 5. Running Services & Processes

### Systemd Services Status
```
EOF
    systemctl list-units --type=service --no-pager --state=running | head -20 >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

### Top 10 Processes by CPU Usage
```
EOF
    ps aux --sort=-%cpu | head -11 >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

## 6. Open Ports & Firewall Rules

### Open TCP/UDP Ports
```
EOF
    ss -tulpn | head -20 >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

## 7. User Accounts

### Local Users
```
EOF
    awk -F: '$3 >= 1000 || $3 == 0 {printf "%-20s %-10s\n", $1, $3}' /etc/passwd >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

## 8. Security Configuration

### SSH Configuration
```
EOF
    if [ -f /etc/ssh/sshd_config ]; then
        grep -E "^[^#]*(Port|PermitRootLogin|PasswordAuthentication)" /etc/ssh/sshd_config >> "$OUTPUT_FILE" 2>/dev/null || echo "Default SSH configuration" >> "$OUTPUT_FILE"
    else
        echo "SSH configuration file not found" >> "$OUTPUT_FILE"
    fi
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

## 9. Containers & Virtualization

### Docker Status
```
EOF
    if command -v docker >/dev/null 2>&1; then
        docker --version >> "$OUTPUT_FILE" 2>/dev/null || echo "Docker installed but not accessible" >> "$OUTPUT_FILE"
    else
        echo "Docker not installed" >> "$OUTPUT_FILE"
    fi
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

## 10. System Health Summary

### Disk Usage Warnings
```
EOF
    df -h | awk '$5 > 80 {print "WARNING: " $6 " is " $5 " full"}' >> "$OUTPUT_FILE" || echo "No disk space warnings" >> "$OUTPUT_FILE"
    
    cat >> "$OUTPUT_FILE" << 'EOF'
```

---

**Documentation completed:** $(date)
EOF
    
    # Replace the date placeholder
    sed -i "s/\$(date)/$(date)/" "$OUTPUT_FILE"
    
    echo "Documentation completed successfully!"
    echo "File: $OUTPUT_FILE"
    wc -l "$OUTPUT_FILE"
else
    echo "Original documentation file not found!"
fi
