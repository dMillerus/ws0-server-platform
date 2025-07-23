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
