#!/bin/bash

# Libvirt and Cockpit VM Management Setup Script
# This script configures libvirt for virtual machine management through Cockpit

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a vm_setup.log
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a vm_setup.log
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a vm_setup.log
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a vm_setup.log
}

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        error "This script should not be run as root for security reasons"
        error "Run as a regular user - sudo will be used when needed"
        exit 1
    fi
}

# Check system requirements
check_requirements() {
    log "Checking system requirements..."
    
    # Check for virtualization support
    if ! grep -E '(vmx|svm)' /proc/cpuinfo > /dev/null; then
        error "CPU virtualization support not detected"
        error "Please enable VT-x/AMD-V in BIOS/UEFI"
        exit 1
    fi
    
    # Check if KVM module is available
    if ! lsmod | grep -q kvm; then
        warning "KVM module not loaded, attempting to load..."
        sudo modprobe kvm
        if grep -q "Intel" /proc/cpuinfo; then
            sudo modprobe kvm_intel
        elif grep -q "AMD" /proc/cpuinfo; then
            sudo modprobe kvm_amd
        fi
    fi
    
    log "System requirements check passed"
}

# Install required packages
install_packages() {
    log "Installing libvirt and related packages..."
    
    # Update package database
    sudo pacman -Sy
    
    # Install libvirt and related packages
    sudo pacman -S --needed --noconfirm \
        libvirt \
        qemu-full \
        virt-manager \
        virt-viewer \
        dnsmasq \
        bridge-utils \
        openbsd-netcat \
        dmidecode \
        ebtables
    
    # Install additional useful packages
    sudo pacman -S --needed --noconfirm \
        virt-install \
        libguestfs \
        swtpm
    
    log "Package installation completed"
}

# Configure user permissions
setup_user_permissions() {
    log "Setting up user permissions for libvirt..."
    
    # Add current user to libvirt group
    sudo usermod -a -G libvirt $USER
    
    # Add user to kvm group if it exists
    if getent group kvm > /dev/null; then
        sudo usermod -a -G kvm $USER
    fi
    
    log "User $USER added to libvirt group"
    warning "You'll need to log out and log back in for group changes to take effect"
}

# Configure libvirt daemon
configure_libvirt() {
    log "Configuring libvirt daemon..."
    
    # Enable and start libvirtd service
    sudo systemctl enable libvirtd.service
    sudo systemctl start libvirtd.service
    
    # Enable and start virtlogd service
    sudo systemctl enable virtlogd.service
    sudo systemctl start virtlogd.service
    
    # Configure libvirt to allow access for cockpit
    sudo tee /etc/polkit-1/rules.d/50-libvirt.rules > /dev/null << 'EOF'
/* Allow users in libvirt group to manage the libvirt daemon without authentication */
polkit.addRule(function(action, subject) {
    if (action.id == "org.libvirt.unix.manage" &&
        subject.isInGroup("libvirt")) {
            return polkit.Result.YES;
    }
});
EOF
    
    log "Libvirt daemon configuration completed"
}

# Setup default network
setup_default_network() {
    log "Setting up default virtual network..."
    
    # Wait for libvirtd to be fully ready
    sleep 5
    
    # Define and start default network if it doesn't exist
    if ! sudo virsh net-list --all | grep -q "default"; then
        sudo virsh net-define /etc/libvirt/qemu/networks/default.xml
    fi
    
    # Start and autostart the default network
    sudo virsh net-start default 2>/dev/null || true
    sudo virsh net-autostart default
    
    log "Default network configuration completed"
}

# Configure storage pools
setup_storage_pools() {
    log "Setting up storage pools..."
    
    # Create default storage directory
    sudo mkdir -p /var/lib/libvirt/images
    sudo chown root:libvirt /var/lib/libvirt/images
    sudo chmod 775 /var/lib/libvirt/images
    
    # Define default storage pool if it doesn't exist
    if ! sudo virsh pool-list --all | grep -q "default"; then
        sudo virsh pool-define-as default dir --target /var/lib/libvirt/images
        sudo virsh pool-start default
        sudo virsh pool-autostart default
    fi
    
    log "Storage pool configuration completed"
}

# Verify Cockpit integration
verify_cockpit_integration() {
    log "Verifying Cockpit virtual machine integration..."
    
    # Check if cockpit-machines is installed
    if ! pacman -Q cockpit-machines > /dev/null 2>&1; then
        warning "cockpit-machines not found, installing..."
        sudo pacman -S --needed --noconfirm cockpit-machines
    fi
    
    # Restart cockpit to load the machines module
    sudo systemctl restart cockpit.socket
    
    log "Cockpit integration verified"
}

# Configure firewall for VMs
configure_firewall() {
    log "Configuring firewall for virtual machines..."
    
    # Allow libvirt to manage iptables
    sudo tee /etc/libvirt/qemu.conf.d/firewall.conf > /dev/null << 'EOF'
# Allow libvirt to manage firewall rules
firewall_backend = "iptables"
EOF
    
    # Restart libvirtd to apply firewall configuration
    sudo systemctl restart libvirtd
    
    log "Firewall configuration completed"
}

# Create VM management script
create_vm_helper_script() {
    log "Creating VM management helper script..."
    
    cat > vm_manager.sh << 'EOF'
#!/bin/bash

# VM Management Helper Script
# Provides common VM operations for use with Cockpit

VM_DIR="/var/lib/libvirt/images"

case "$1" in
    "list")
        echo "=== Running VMs ==="
        sudo virsh list
        echo ""
        echo "=== All VMs ==="
        sudo virsh list --all
        ;;
    "networks")
        echo "=== Virtual Networks ==="
        sudo virsh net-list --all
        ;;
    "pools")
        echo "=== Storage Pools ==="
        sudo virsh pool-list --all
        ;;
    "status")
        echo "=== Libvirt Service Status ==="
        sudo systemctl status libvirtd --no-pager
        echo ""
        echo "=== Cockpit Status ==="
        sudo systemctl status cockpit.socket --no-pager
        ;;
    "download-iso")
        if [ -z "$2" ]; then
            echo "Usage: $0 download-iso <URL>"
            echo "Example: $0 download-iso https://example.com/ubuntu.iso"
            exit 1
        fi
        echo "Downloading ISO to $VM_DIR..."
        sudo wget -P "$VM_DIR" "$2"
        ;;
    "create-vm")
        echo "Use Cockpit web interface at https://localhost:9090"
        echo "Navigate to Virtual Machines -> Create VM"
        ;;
    *)
        echo "VM Management Helper"
        echo "Usage: $0 {list|networks|pools|status|download-iso|create-vm}"
        echo ""
        echo "Commands:"
        echo "  list        - Show all virtual machines"
        echo "  networks    - Show virtual networks"
        echo "  pools       - Show storage pools"
        echo "  status      - Show service status"
        echo "  download-iso <url> - Download ISO image"
        echo "  create-vm   - Instructions for creating VMs"
        ;;
esac
EOF
    
    chmod +x vm_manager.sh
    log "VM helper script created: vm_manager.sh"
}

# Display summary
display_summary() {
    log "=== Virtual Machine Setup Summary ==="
    echo ""
    info "Libvirt and Cockpit VM management has been configured!"
    echo ""
    echo "Next steps:"
    echo "1. Log out and log back in (to apply group membership)"
    echo "2. Access Cockpit at: https://localhost:9090"
    echo "3. Navigate to 'Virtual Machines' in the left sidebar"
    echo "4. Use the VM helper script: ./vm_manager.sh"
    echo ""
    echo "Common tasks:"
    echo "- Create VMs through Cockpit web interface"
    echo "- Download ISO images to: /var/lib/libvirt/images"
    echo "- Manage VMs using: ./vm_manager.sh list"
    echo ""
    echo "Service status:"
    sudo systemctl is-active libvirtd && echo "✓ libvirtd: Active" || echo "✗ libvirtd: Inactive"
    sudo systemctl is-active cockpit.socket && echo "✓ cockpit: Active" || echo "✗ cockpit: Inactive"
    echo ""
    warning "Please log out and log back in for group changes to take effect!"
}

# Main execution
main() {
    log "Starting libvirt and Cockpit VM setup..."
    
    check_root
    check_requirements
    install_packages
    setup_user_permissions
    configure_libvirt
    setup_default_network
    setup_storage_pools
    verify_cockpit_integration
    configure_firewall
    create_vm_helper_script
    display_summary
    
    log "Setup completed successfully!"
}

# Run main function
main "$@"
