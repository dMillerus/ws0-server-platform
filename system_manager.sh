#!/bin/bash

#===============================================================================
# Script Name: system_manager.sh
# Description: Main menu-driven system management and monitoring interface
# Author: System Documentation Assistant
# Version: 1.0
# Date: $(date +"%Y-%m-%d")
#
# Purpose: Unified interface for all system monitoring, documentation,
#          and management scripts
#===============================================================================

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERSION="1.0"
HOSTNAME=$(hostname)

# Colors for beautiful output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Box drawing characters
BOX_H="─"
BOX_V="│"
BOX_TL="┌"
BOX_TR="┐"
BOX_BL="└"
BOX_BR="┘"
BOX_ML="├"
BOX_MR="┤"

# Logging functions
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }

# Function to draw a box around text
draw_box() {
    local text="$1"
    local width=${2:-60}
    local padding=2
    
    # Calculate actual width needed
    local text_length=${#text}
    local total_width=$((text_length + padding * 2))
    
    if [ $total_width -gt $width ]; then
        width=$total_width
    fi
    
    local content_width=$((width - 2))
    local text_padding=$(( (content_width - text_length) / 2 ))
    
    # Top border
    echo -e "${CYAN}${BOX_TL}$(printf "%*s" $content_width | tr ' ' "$BOX_H")${BOX_TR}${NC}"
    
    # Text line
    printf "${CYAN}${BOX_V}${NC}"
    printf "%*s" $text_padding
    echo -e "${WHITE}${BOLD}$text${NC}\c"
    printf "%*s" $((content_width - text_length - text_padding))
    echo -e "${CYAN}${BOX_V}${NC}"
    
    # Bottom border
    echo -e "${CYAN}${BOX_BL}$(printf "%*s" $content_width | tr ' ' "$BOX_H")${BOX_BR}${NC}"
}

# Function to display header
show_header() {
    clear
    echo ""
    draw_box "SYSTEM MANAGER v$VERSION"
    echo ""
    echo -e "${BLUE}${BOLD}Hostname:${NC} $HOSTNAME"
    echo -e "${BLUE}${BOLD}Date:${NC} $(date)"
    echo -e "${BLUE}${BOLD}User:${NC} $(whoami)"
    echo -e "${BLUE}${BOLD}Directory:${NC} $SCRIPT_DIR"
    echo ""
    
    # Quick system status
    local load_avg=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
    local mem_usage=$(free | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}')
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    echo -e "${PURPLE}${BOLD}Quick Status:${NC}"
    echo -e "  ${CYAN}Load:${NC} $load_avg  ${CYAN}Memory:${NC} ${mem_usage}%  ${CYAN}Disk:${NC} ${disk_usage}%"
    echo ""
}

# Function to show main menu
show_main_menu() {
    echo -e "${YELLOW}${BOLD}╔══════════════════ MAIN MENU ══════════════════╗${NC}"
    echo -e "${YELLOW}${BOLD}║                                                ║${NC}"
    echo -e "${YELLOW}║  ${WHITE}1.${NC} ${CYAN}System Documentation & Reports${NC}          ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${WHITE}2.${NC} ${CYAN}Real-time Monitoring${NC}                    ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${WHITE}3.${NC} ${CYAN}Security & Health Checks${NC}                ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${WHITE}4.${NC} ${CYAN}Network Management${NC}                      ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${WHITE}5.${NC} ${CYAN}Container & VM Management${NC}               ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${WHITE}6.${NC} ${CYAN}System Setup & Configuration${NC}           ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${WHITE}7.${NC} ${CYAN}Backup & Recovery${NC}                       ${YELLOW}║${NC}"
    echo -e "${YELLOW}║  ${WHITE}8.${NC} ${CYAN}Script Management${NC}                       ${YELLOW}║${NC}"
    echo -e "${YELLOW}║                                                ║${NC}"
    echo -e "${YELLOW}║  ${WHITE}q.${NC} ${RED}Quit${NC}                                    ${YELLOW}║${NC}"
    echo -e "${YELLOW}${BOLD}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to check if script exists and is executable
check_script() {
    local script="$1"
    if [ -f "$SCRIPT_DIR/$script" ]; then
        chmod +x "$SCRIPT_DIR/$script" 2>/dev/null || true
        return 0
    else
        error "Script $script not found in $SCRIPT_DIR"
        return 1
    fi
}

# Function to run script with status
run_script() {
    local script="$1"
    local description="$2"
    local args="${3:-}"
    
    echo ""
    log "Running: $description"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if check_script "$script"; then
        if bash "$SCRIPT_DIR/$script" $args; then
            success "$description completed successfully"
        else
            error "$description failed or was interrupted"
        fi
    fi
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "Press Enter to continue..."
}

# Submenu 1: Documentation & Reports
submenu_documentation() {
    while true; do
        show_header
        echo -e "${BLUE}${BOLD}╔════════ DOCUMENTATION & REPORTS ════════╗${NC}"
        echo -e "${BLUE}║                                           ║${NC}"
        echo -e "${BLUE}║  ${WHITE}1.${NC} Generate Full Server Documentation  ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${WHITE}2.${NC} Generate Network Configuration Scan  ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${WHITE}3.${NC} Security Status Report              ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${WHITE}4.${NC} Performance Report                  ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${WHITE}5.${NC} Container Health Report             ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${WHITE}6.${NC} Backup Status Report                ${BLUE}║${NC}"
        echo -e "${BLUE}║  ${WHITE}7.${NC} Quick Health Check                  ${BLUE}║${NC}"
        echo -e "${BLUE}║                                           ║${NC}"
        echo -e "${BLUE}║  ${WHITE}b.${NC} Back to Main Menu                   ${BLUE}║${NC}"
        echo -e "${BLUE}╚═══════════════════════════════════════════╝${NC}"
        echo ""
        
        read -p "Select option [1-7, b]: " choice
        
        case $choice in
            1) run_script "generate_server_docs.sh" "Full Server Documentation" ;;
            2) run_script "network_scanner.sh" "Network Configuration Scan" ;;
            3) run_script "security_monitor.sh" "Security Status Report" ;;
            4) run_script "performance_monitor.sh" "Performance Report" ;;
            5) run_script "container_health_monitor.sh" "Container Health Report" ;;
            6) run_script "backup_status_checker.sh" "Backup Status Report" ;;
            7) run_script "quick_health_check.sh" "Quick Health Check" "--full" ;;
            b|B) break ;;
            *) warn "Invalid option. Please select 1-7 or b." ;;
        esac
    done
}

# Submenu 2: Real-time Monitoring
submenu_monitoring() {
    while true; do
        show_header
        echo -e "${GREEN}${BOLD}╔═════════ REAL-TIME MONITORING ═════════╗${NC}"
        echo -e "${GREEN}║                                         ║${NC}"
        echo -e "${GREEN}║  ${WHITE}1.${NC} Continuous Performance Monitor     ${GREEN}║${NC}"
        echo -e "${GREEN}║  ${WHITE}2.${NC} Live System Stats (htop)            ${GREEN}║${NC}"
        echo -e "${GREEN}║  ${WHITE}3.${NC} Network Activity Monitor            ${GREEN}║${NC}"
        echo -e "${GREEN}║  ${WHITE}4.${NC} Container Resource Monitor          ${GREEN}║${NC}"
        echo -e "${GREEN}║  ${WHITE}5.${NC} Live Log Monitoring                 ${GREEN}║${NC}"
        echo -e "${GREEN}║  ${WHITE}6.${NC} Disk I/O Monitor                    ${GREEN}║${NC}"
        echo -e "${GREEN}║                                         ║${NC}"
        echo -e "${GREEN}║  ${WHITE}b.${NC} Back to Main Menu                   ${GREEN}║${NC}"
        echo -e "${GREEN}╚═════════════════════════════════════════╝${NC}"
        echo ""
        
        read -p "Select option [1-6, b]: " choice
        
        case $choice in
            1) run_script "performance_monitor.sh" "Continuous Performance Monitor" "--continuous --interval 60" ;;
            2) 
                echo ""
                log "Starting htop (press 'q' to quit)"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                htop 2>/dev/null || echo "htop not installed"
                ;;
            3)
                echo ""
                log "Network connections (press Ctrl+C to stop)"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                watch -n 2 'ss -tuln' || echo "Monitoring stopped"
                ;;
            4)
                echo ""
                log "Container resource usage (press Ctrl+C to stop)"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                if command -v docker >/dev/null 2>&1; then
                    watch -n 3 'docker stats --no-stream' || echo "Monitoring stopped"
                else
                    error "Docker not available"
                fi
                ;;
            5)
                echo ""
                log "Live system logs (press Ctrl+C to stop)"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                journalctl -f || echo "Log monitoring stopped"
                ;;
            6)
                echo ""
                log "Disk I/O monitoring (press Ctrl+C to stop)"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                if command -v iotop >/dev/null 2>&1; then
                    sudo iotop || echo "iotop monitoring stopped"
                else
                    iostat -x 2 || echo "iostat not available"
                fi
                ;;
            b|B) break ;;
            *) warn "Invalid option. Please select 1-6 or b." ;;
        esac
        
        if [ "$choice" != "b" ] && [ "$choice" != "B" ]; then
            echo ""
            read -p "Press Enter to continue..."
        fi
    done
}

# Submenu 3: Security & Health
submenu_security() {
    while true; do
        show_header
        echo -e "${RED}${BOLD}╔══════ SECURITY & HEALTH CHECKS ══════╗${NC}"
        echo -e "${RED}║                                       ║${NC}"
        echo -e "${RED}║  ${WHITE}1.${NC} Complete Health Check             ${RED}║${NC}"
        echo -e "${RED}║  ${WHITE}2.${NC} Security Status Check             ${RED}║${NC}"
        echo -e "${RED}║  ${WHITE}3.${NC} SSH Security Audit                ${RED}║${NC}"
        echo -e "${RED}║  ${WHITE}4.${NC} Firewall Status                   ${RED}║${NC}"
        echo -e "${RED}║  ${WHITE}5.${NC} Failed Login Attempts             ${RED}║${NC}"
        echo -e "${RED}║  ${WHITE}6.${NC} System Resource Alerts            ${RED}║${NC}"
        echo -e "${RED}║                                       ║${NC}"
        echo -e "${RED}║  ${WHITE}b.${NC} Back to Main Menu                 ${RED}║${NC}"
        echo -e "${RED}╚═══════════════════════════════════════╝${NC}"
        echo ""
        
        read -p "Select option [1-6, b]: " choice
        
        case $choice in
            1) run_script "quick_health_check.sh" "Complete Health Check" "--full" ;;
            2) run_script "security_monitor.sh" "Security Status Check" ;;
            3) run_script "ssh_security_check.sh" "SSH Security Audit" ;;
            4)
                echo ""
                log "Firewall Status Check"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                if command -v firewall-cmd >/dev/null 2>&1; then
                    echo "Firewalld Status:"
                    firewall-cmd --state 2>/dev/null || echo "Firewalld not running"
                    echo ""
                    echo "Active Zones:"
                    firewall-cmd --get-active-zones 2>/dev/null || echo "No active zones"
                else
                    echo "Firewalld not installed"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                echo ""
                log "Recent Failed Login Attempts"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                journalctl --since="24 hours ago" | grep -i "failed password\|authentication failure" | tail -10 || echo "No failed login attempts found"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            6)
                echo ""
                log "System Resource Alerts"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                
                # Check load
                load_avg=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
                cpu_count=$(nproc)
                echo "CPU Load: $load_avg (CPUs: $cpu_count)"
                
                # Check memory
                mem_usage=$(free | awk '/^Mem:/ {printf "%.0f", ($3/$2)*100}')
                echo "Memory Usage: ${mem_usage}%"
                
                # Check disk
                echo "Disk Usage:"
                df -h | grep -E "/dev/" | awk '{print $6 ": " $5}'
                
                echo ""
                read -p "Press Enter to continue..."
                ;;
            b|B) break ;;
            *) warn "Invalid option. Please select 1-6 or b." ;;
        esac
    done
}

# Submenu 4: Network Management
submenu_network() {
    while true; do
        show_header
        echo -e "${CYAN}${BOLD}╔═════════ NETWORK MANAGEMENT ═════════╗${NC}"
        echo -e "${CYAN}║                                       ║${NC}"
        echo -e "${CYAN}║  ${WHITE}1.${NC} Network Configuration Scan        ${CYAN}║${NC}"
        echo -e "${CYAN}║  ${WHITE}2.${NC} Current Network Status             ${CYAN}║${NC}"
        echo -e "${CYAN}║  ${WHITE}3.${NC} Bridge & Virtual Networks         ${CYAN}║${NC}"
        echo -e "${CYAN}║  ${WHITE}4.${NC} Active Connections                 ${CYAN}║${NC}"
        echo -e "${CYAN}║  ${WHITE}5.${NC} Routing Table                      ${CYAN}║${NC}"
        echo -e "${CYAN}║  ${WHITE}6.${NC} Firewall Rules                     ${CYAN}║${NC}"
        echo -e "${CYAN}║                                       ║${NC}"
        echo -e "${CYAN}║  ${WHITE}b.${NC} Back to Main Menu                 ${CYAN}║${NC}"
        echo -e "${CYAN}╚═══════════════════════════════════════╝${NC}"
        echo ""
        
        read -p "Select option [1-6, b]: " choice
        
        case $choice in
            1) run_script "network_scanner.sh" "Network Configuration Scan" ;;
            2)
                echo ""
                log "Current Network Status"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo "Network Interfaces:"
                ip addr show | grep -E "^[0-9]+:|inet " | head -20
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                echo ""
                log "Bridge & Virtual Networks"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo "Bridge Interfaces:"
                ip link show type bridge 2>/dev/null || echo "No bridge interfaces"
                echo ""
                if command -v virsh >/dev/null 2>&1; then
                    echo "libvirt Networks:"
                    virsh net-list --all 2>/dev/null || echo "libvirt not accessible"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                echo ""
                log "Active Network Connections"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                ss -tuln | head -15
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                echo ""
                log "Routing Table"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo "IPv4 Routes:"
                ip route show
                echo ""
                read -p "Press Enter to continue..."
                ;;
            6)
                echo ""
                log "Firewall Rules"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                if command -v firewall-cmd >/dev/null 2>&1; then
                    firewall-cmd --list-all 2>/dev/null || echo "Cannot access firewall rules"
                else
                    iptables -L -n | head -20 2>/dev/null || echo "Cannot access iptables"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            b|B) break ;;
            *) warn "Invalid option. Please select 1-6 or b." ;;
        esac
    done
}

# Submenu 5: Container & VM Management
submenu_containers() {
    while true; do
        show_header
        echo -e "${PURPLE}${BOLD}╔═══ CONTAINER & VM MANAGEMENT ═══╗${NC}"
        echo -e "${PURPLE}║                                   ║${NC}"
        echo -e "${PURPLE}║  ${WHITE}1.${NC} Container Health Check        ${PURPLE}║${NC}"
        echo -e "${PURPLE}║  ${WHITE}2.${NC} Docker Status & Management    ${PURPLE}║${NC}"
        echo -e "${PURPLE}║  ${WHITE}3.${NC} VM Status & Management        ${PURPLE}║${NC}"
        echo -e "${PURPLE}║  ${WHITE}4.${NC} Podman Status                 ${PURPLE}║${NC}"
        echo -e "${PURPLE}║  ${WHITE}5.${NC} Open Cockpit Web Interface    ${PURPLE}║${NC}"
        echo -e "${PURPLE}║                                   ║${NC}"
        echo -e "${PURPLE}║  ${WHITE}b.${NC} Back to Main Menu             ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚═══════════════════════════════════╝${NC}"
        echo ""
        
        read -p "Select option [1-5, b]: " choice
        
        case $choice in
            1) run_script "container_health_monitor.sh" "Container Health Check" ;;
            2) run_script "docker_manager.sh" "Docker Management" ;;
            3) run_script "vm_manager.sh" "VM Management" ;;
            4)
                echo ""
                log "Podman Status"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                if command -v podman >/dev/null 2>&1; then
                    echo "Podman Containers:"
                    podman ps -a 2>/dev/null || echo "Cannot access Podman"
                    echo ""
                    echo "Podman Images:"
                    podman images 2>/dev/null | head -5 || echo "Cannot access Podman images"
                else
                    echo "Podman not installed"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                echo ""
                log "Opening Cockpit Web Interface"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo "Cockpit should be available at: https://localhost:9090"
                echo "Opening in default browser..."
                
                if command -v xdg-open >/dev/null 2>&1; then
                    xdg-open "https://localhost:9090" 2>/dev/null &
                elif command -v firefox >/dev/null 2>&1; then
                    firefox "https://localhost:9090" 2>/dev/null &
                else
                    echo "Please open https://localhost:9090 in your browser"
                fi
                
                echo ""
                read -p "Press Enter to continue..."
                ;;
            b|B) break ;;
            *) warn "Invalid option. Please select 1-5 or b." ;;
        esac
    done
}

# Submenu 6: Setup & Configuration
submenu_setup() {
    while true; do
        show_header
        echo -e "${YELLOW}${BOLD}╔═══ SETUP & CONFIGURATION ═══╗${NC}"
        echo -e "${YELLOW}║                               ║${NC}"
        echo -e "${YELLOW}║  ${WHITE}1.${NC} Setup Docker & Cockpit    ${YELLOW}║${NC}"
        echo -e "${YELLOW}║  ${WHITE}2.${NC} Setup libvirt & Cockpit   ${YELLOW}║${NC}"
        echo -e "${YELLOW}║  ${WHITE}3.${NC} SSH Hardening             ${YELLOW}║${NC}"
        echo -e "${YELLOW}║  ${WHITE}4.${NC} Setup 2FA Authentication  ${YELLOW}║${NC}"
        echo -e "${YELLOW}║  ${WHITE}5.${NC} View Setup Guides         ${YELLOW}║${NC}"
        echo -e "${YELLOW}║                               ║${NC}"
        echo -e "${YELLOW}║  ${WHITE}b.${NC} Back to Main Menu         ${YELLOW}║${NC}"
        echo -e "${YELLOW}╚═══════════════════════════════╝${NC}"
        echo ""
        
        read -p "Select option [1-5, b]: " choice
        
        case $choice in
            1) run_script "setup_docker_cockpit.sh" "Docker & Cockpit Setup" ;;
            2) run_script "setup_libvirt_cockpit.sh" "libvirt & Cockpit Setup" ;;
            3) run_script "harden_ssh.sh" "SSH Hardening" ;;
            4) run_script "setup_2fa.sh" "2FA Authentication Setup" ;;
            5)
                echo ""
                log "Available Setup Guides"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo "Available documentation files:"
                ls -la "$SCRIPT_DIR"/*.md 2>/dev/null | awk '{print "  " $9}' | grep -E "\.(md)$"
                echo ""
                echo "Use 'cat filename.md' or 'less filename.md' to view content"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            b|B) break ;;
            *) warn "Invalid option. Please select 1-5 or b." ;;
        esac
    done
}

# Submenu 7: Backup & Recovery
submenu_backup() {
    while true; do
        show_header
        echo -e "${GREEN}${BOLD}╔═════ BACKUP & RECOVERY ═════╗${NC}"
        echo -e "${GREEN}║                              ║${NC}"
        echo -e "${GREEN}║  ${WHITE}1.${NC} Backup Status Check      ${GREEN}║${NC}"
        echo -e "${GREEN}║  ${WHITE}2.${NC} Manual VM Backup         ${GREEN}║${NC}"
        echo -e "${GREEN}║  ${WHITE}3.${NC} Manual Config Backup     ${GREEN}║${NC}"
        echo -e "${GREEN}║  ${WHITE}4.${NC} Docker Image Backup      ${GREEN}║${NC}"
        echo -e "${GREEN}║  ${WHITE}5.${NC} List Backup Locations    ${GREEN}║${NC}"
        echo -e "${GREEN}║                              ║${NC}"
        echo -e "${GREEN}║  ${WHITE}b.${NC} Back to Main Menu        ${GREEN}║${NC}"
        echo -e "${GREEN}╚══════════════════════════════╝${NC}"
        echo ""
        
        read -p "Select option [1-5, b]: " choice
        
        case $choice in
            1) run_script "backup_status_checker.sh" "Backup Status Check" ;;
            2)
                echo ""
                log "Manual VM Backup"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                if command -v virsh >/dev/null 2>&1; then
                    echo "Available VMs:"
                    virsh list --all 2>/dev/null || echo "No VMs found"
                    echo ""
                    echo "To backup a VM:"
                    echo "1. virsh dumpxml vmname > vmname.xml"
                    echo "2. cp /var/lib/libvirt/images/vmname.qcow2 /backup/location/"
                else
                    echo "libvirt not available"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                echo ""
                log "Manual Configuration Backup"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo "Creating config backup..."
                backup_file="config_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
                if tar -czf "$backup_file" /etc/ssh /etc/fail2ban /etc/firewalld "$SCRIPT_DIR" 2>/dev/null; then
                    success "Configuration backup created: $backup_file"
                else
                    error "Backup creation failed"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                echo ""
                log "Docker Image Backup"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                if command -v docker >/dev/null 2>&1; then
                    echo "Available Docker Images:"
                    docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}" 2>/dev/null || echo "Cannot access Docker"
                    echo ""
                    echo "To backup images:"
                    echo "docker save imagename > imagename.tar"
                else
                    echo "Docker not available"
                fi
                echo ""
                read -p "Press Enter to continue..."
                ;;
            5)
                echo ""
                log "Backup Locations"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                echo "VM Images: /var/lib/libvirt/images/"
                echo "Docker Data: /var/lib/docker/"
                echo "User Data: /home/"
                echo "System Configs: /etc/"
                echo "Current Directory: $SCRIPT_DIR"
                echo ""
                echo "Disk Usage:"
                du -sh /var/lib/libvirt 2>/dev/null | head -5 || echo "libvirt directory not accessible"
                du -sh /var/lib/docker 2>/dev/null | head -5 || echo "Docker directory not accessible"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            b|B) break ;;
            *) warn "Invalid option. Please select 1-5 or b." ;;
        esac
    done
}

# Submenu 8: Script Management
submenu_scripts() {
    while true; do
        show_header
        echo -e "${PURPLE}${BOLD}╔═══════ SCRIPT MANAGEMENT ═══════╗${NC}"
        echo -e "${PURPLE}║                                  ║${NC}"
        echo -e "${PURPLE}║  ${WHITE}1.${NC} List All Scripts             ${PURPLE}║${NC}"
        echo -e "${PURPLE}║  ${WHITE}2.${NC} Check Script Permissions     ${PURPLE}║${NC}"
        echo -e "${PURPLE}║  ${WHITE}3.${NC} Update Script Permissions    ${PURPLE}║${NC}"
        echo -e "${PURPLE}║  ${WHITE}4.${NC} View Script Documentation    ${PURPLE}║${NC}"
        echo -e "${PURPLE}║  ${WHITE}5.${NC} Edit Script (nano)           ${PURPLE}║${NC}"
        echo -e "${PURPLE}║                                  ║${NC}"
        echo -e "${PURPLE}║  ${WHITE}b.${NC} Back to Main Menu            ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════╝${NC}"
        echo ""
        
        read -p "Select option [1-5, b]: " choice
        
        case $choice in
            1)
                echo ""
                log "Available Scripts"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                ls -la "$SCRIPT_DIR"/*.sh 2>/dev/null | awk '{printf "%-8s %-20s %s\n", $1, $9, $5" bytes"}' || echo "No scripts found"
                echo ""
                echo "Documentation files:"
                ls -la "$SCRIPT_DIR"/*.md 2>/dev/null | awk '{printf "%-20s %s\n", $9, $5" bytes"}' || echo "No documentation found"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            2)
                echo ""
                log "Script Permissions Check"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                for script in "$SCRIPT_DIR"/*.sh; do
                    if [ -f "$script" ]; then
                        filename=$(basename "$script")
                        if [ -x "$script" ]; then
                            echo -e "✅ $filename (executable)"
                        else
                            echo -e "❌ $filename (not executable)"
                        fi
                    fi
                done
                echo ""
                read -p "Press Enter to continue..."
                ;;
            3)
                echo ""
                log "Updating Script Permissions"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null && success "All scripts made executable" || error "Failed to update permissions"
                echo ""
                read -p "Press Enter to continue..."
                ;;
            4)
                echo ""
                log "Available Documentation"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                ls "$SCRIPT_DIR"/*.md 2>/dev/null | while read -r doc; do
                    echo "$(basename "$doc")"
                done || echo "No documentation found"
                echo ""
                read -p "Enter filename to view (or press Enter to continue): " doc_file
                if [ -n "$doc_file" ] && [ -f "$SCRIPT_DIR/$doc_file" ]; then
                    less "$SCRIPT_DIR/$doc_file"
                fi
                ;;
            5)
                echo ""
                log "Available Scripts for Editing"
                echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
                ls "$SCRIPT_DIR"/*.sh 2>/dev/null | while read -r script; do
                    echo "$(basename "$script")"
                done || echo "No scripts found"
                echo ""
                read -p "Enter script filename to edit (or press Enter to continue): " script_file
                if [ -n "$script_file" ] && [ -f "$SCRIPT_DIR/$script_file" ]; then
                    nano "$SCRIPT_DIR/$script_file"
                fi
                ;;
            b|B) break ;;
            *) warn "Invalid option. Please select 1-5 or b." ;;
        esac
    done
}

# Main program loop
main() {
    # Check if running in proper terminal
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        error "This script requires an interactive terminal"
        exit 1
    fi
    
    # Main menu loop
    while true; do
        show_header
        show_main_menu
        
        read -p "Select option [1-8, q]: " choice
        
        case $choice in
            1) submenu_documentation ;;
            2) submenu_monitoring ;;
            3) submenu_security ;;
            4) submenu_network ;;
            5) submenu_containers ;;
            6) submenu_setup ;;
            7) submenu_backup ;;
            8) submenu_scripts ;;
            q|Q|quit|exit)
                echo ""
                success "Thank you for using System Manager!"
                echo ""
                exit 0
                ;;
            *)
                warn "Invalid option. Please select 1-8 or q to quit."
                sleep 1
                ;;
        esac
    done
}

# Start the program
main "$@"
