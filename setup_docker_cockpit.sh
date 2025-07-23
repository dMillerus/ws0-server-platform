#!/bin/bash

# Docker and Cockpit Integration Setup Script
# This script configures Docker for container management through Cockpit

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a docker_setup.log
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a docker_setup.log
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a docker_setup.log
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a docker_setup.log
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
    
    # Check if system is Arch Linux
    if ! grep -q "Arch Linux" /etc/os-release; then
        warning "This script is optimized for Arch Linux"
    fi
    
    # Check available disk space
    available_space=$(df / | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 5000000 ]]; then
        warning "Less than 5GB available disk space detected"
        warning "Docker images can be large - consider freeing up space"
    fi
    
    log "System requirements check completed"
}

# Install Docker
install_docker() {
    log "Installing Docker..."
    
    # Update package database
    sudo pacman -Sy
    
    # Install Docker
    sudo pacman -S --needed --noconfirm docker
    
    # Install Docker Compose
    sudo pacman -S --needed --noconfirm docker-compose
    
    # Install additional useful tools
    sudo pacman -S --needed --noconfirm \
        docker-buildx \
        ctop
    
    log "Docker installation completed"
}

# Configure Docker daemon
configure_docker_daemon() {
    log "Configuring Docker daemon..."
    
    # Create Docker daemon configuration directory
    sudo mkdir -p /etc/docker
    
    # Configure Docker daemon with security and performance settings
    sudo tee /etc/docker/daemon.json > /dev/null << 'EOF'
{
    "log-driver": "json-file",
    "log-opts": {
        "max-size": "100m",
        "max-file": "3"
    },
    "storage-driver": "overlay2",
    "userland-proxy": false,
    "experimental": false,
    "live-restore": true,
    "default-ulimits": {
        "nofile": {
            "Name": "nofile",
            "Hard": 64000,
            "Soft": 64000
        }
    }
}
EOF
    
    log "Docker daemon configuration completed"
}

# Setup user permissions
setup_user_permissions() {
    log "Setting up user permissions for Docker..."
    
    # Add current user to docker group
    sudo usermod -a -G docker $USER
    
    log "User $USER added to docker group"
    warning "You'll need to log out and log back in for group changes to take effect"
}

# Enable and start Docker service
start_docker_service() {
    log "Enabling and starting Docker service..."
    
    # Enable Docker service to start on boot
    sudo systemctl enable docker.service
    sudo systemctl enable containerd.service
    
    # Start Docker service
    sudo systemctl start docker.service
    sudo systemctl start containerd.service
    
    # Wait for Docker to be ready
    sleep 5
    
    log "Docker service started successfully"
}

# Install Cockpit Docker integration
install_cockpit_docker() {
    log "Installing Cockpit Docker integration..."
    
    # Install cockpit-podman (which also provides container management)
    sudo pacman -S --needed --noconfirm cockpit-podman
    
    # Check if cockpit is installed, install if not
    if ! pacman -Q cockpit > /dev/null 2>&1; then
        log "Installing Cockpit..."
        sudo pacman -S --needed --noconfirm cockpit
        sudo systemctl enable --now cockpit.socket
    fi
    
    # Restart cockpit to load the container module
    sudo systemctl restart cockpit.socket
    
    log "Cockpit Docker integration installed"
}

# Configure Docker for Cockpit
configure_cockpit_docker() {
    log "Configuring Docker for Cockpit integration..."
    
    # Create systemd override directory for docker
    sudo mkdir -p /etc/systemd/system/docker.service.d
    
    # Configure Docker to be accessible via socket
    sudo tee /etc/systemd/system/docker.service.d/override.conf > /dev/null << 'EOF'
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://127.0.0.1:2375 --containerd=/run/containerd/containerd.sock
EOF
    
    # Reload systemd and restart Docker
    sudo systemctl daemon-reload
    sudo systemctl restart docker.service
    
    log "Docker configured for Cockpit access"
}

# Setup Docker security
configure_docker_security() {
    log "Configuring Docker security settings..."
    
    # Create Docker security configuration
    sudo mkdir -p /etc/docker/seccomp
    
    # Download default seccomp profile if not exists
    if [[ ! -f /etc/docker/seccomp/default.json ]]; then
        sudo curl -o /etc/docker/seccomp/default.json \
            https://raw.githubusercontent.com/moby/moby/master/profiles/seccomp/default.json
    fi
    
    # Create AppArmor profile directory
    sudo mkdir -p /etc/apparmor.d/docker
    
    log "Docker security configuration completed"
}

# Create Docker management script
create_docker_helper_script() {
    log "Creating Docker management helper script..."
    
    cat > docker_manager.sh << 'EOF'
#!/bin/bash

# Docker Management Helper Script
# Provides common Docker operations for use with Cockpit

case "$1" in
    "status")
        echo "=== Docker Service Status ==="
        sudo systemctl status docker --no-pager
        echo ""
        echo "=== Docker Version ==="
        docker --version
        docker-compose --version
        ;;
    "info")
        echo "=== Docker System Information ==="
        docker system df
        echo ""
        echo "=== Docker System Info ==="
        docker info
        ;;
    "containers")
        echo "=== Running Containers ==="
        docker ps
        echo ""
        echo "=== All Containers ==="
        docker ps -a
        ;;
    "images")
        echo "=== Docker Images ==="
        docker images
        ;;
    "networks")
        echo "=== Docker Networks ==="
        docker network ls
        ;;
    "volumes")
        echo "=== Docker Volumes ==="
        docker volume ls
        ;;
    "cleanup")
        echo "=== Docker System Cleanup ==="
        docker system prune -f
        echo "Cleanup completed"
        ;;
    "stats")
        echo "=== Container Resource Usage ==="
        docker stats --no-stream
        ;;
    "logs")
        if [ -z "$2" ]; then
            echo "Usage: $0 logs <container_name_or_id>"
            exit 1
        fi
        docker logs "$2"
        ;;
    "exec")
        if [ -z "$2" ]; then
            echo "Usage: $0 exec <container_name_or_id> [command]"
            echo "Example: $0 exec mycontainer bash"
            exit 1
        fi
        command="${3:-bash}"
        docker exec -it "$2" "$command"
        ;;
    "compose-up")
        if [ -f "docker-compose.yml" ]; then
            docker-compose up -d
        else
            echo "No docker-compose.yml found in current directory"
        fi
        ;;
    "compose-down")
        if [ -f "docker-compose.yml" ]; then
            docker-compose down
        else
            echo "No docker-compose.yml found in current directory"
        fi
        ;;
    *)
        echo "Docker Management Helper"
        echo "Usage: $0 {command}"
        echo ""
        echo "Commands:"
        echo "  status      - Show Docker service status"
        echo "  info        - Show Docker system information"
        echo "  containers  - List containers"
        echo "  images      - List images"
        echo "  networks    - List networks"
        echo "  volumes     - List volumes"
        echo "  cleanup     - Clean up unused resources"
        echo "  stats       - Show container resource usage"
        echo "  logs <name> - Show container logs"
        echo "  exec <name> [cmd] - Execute command in container"
        echo "  compose-up  - Start docker-compose services"
        echo "  compose-down - Stop docker-compose services"
        echo ""
        echo "Access Docker through Cockpit: https://localhost:9090"
        ;;
esac
EOF
    
    chmod +x docker_manager.sh
    log "Docker helper script created: docker_manager.sh"
}

# Test Docker installation
test_docker() {
    log "Testing Docker installation..."
    
    # Test Docker with hello-world
    if sudo docker run --rm hello-world > /dev/null 2>&1; then
        log "Docker test successful"
    else
        error "Docker test failed"
        return 1
    fi
    
    # Clean up test container
    sudo docker system prune -f > /dev/null 2>&1
    
    log "Docker installation test completed"
}

# Configure Docker networking for containers
configure_docker_networking() {
    log "Configuring Docker networking..."
    
    # Create custom bridge network for better isolation
    sudo docker network create --driver bridge docker-bridge 2>/dev/null || true
    
    # Configure Docker to use custom DNS
    sudo tee -a /etc/docker/daemon.json.tmp > /dev/null << 'EOF'
{
    "dns": ["8.8.8.8", "8.8.4.4"],
    "bridge": "docker0",
    "iptables": true,
    "ip-forward": true
}
EOF
    
    # Merge with existing daemon.json
    if [[ -f /etc/docker/daemon.json ]]; then
        sudo jq -s '.[0] * .[1]' /etc/docker/daemon.json /etc/docker/daemon.json.tmp | sudo tee /etc/docker/daemon.json.new > /dev/null
        sudo mv /etc/docker/daemon.json.new /etc/docker/daemon.json
        sudo rm /etc/docker/daemon.json.tmp
    else
        sudo mv /etc/docker/daemon.json.tmp /etc/docker/daemon.json
    fi
    
    log "Docker networking configuration completed"
}

# Setup Docker registry mirror (optional)
setup_registry_mirror() {
    log "Setting up Docker registry configuration..."
    
    # Create registry configuration
    sudo mkdir -p /etc/docker/certs.d
    
    # Note: Users can configure registry mirrors here if needed
    info "Registry mirror configuration ready (configure manually if needed)"
    
    log "Registry configuration completed"
}

# Display summary
display_summary() {
    log "=== Docker Setup Summary ==="
    echo ""
    info "Docker and Cockpit integration has been configured!"
    echo ""
    echo "Next steps:"
    echo "1. Log out and log back in (to apply group membership)"
    echo "2. Access Cockpit at: https://localhost:9090"
    echo "3. Navigate to 'Podman containers' in the left sidebar"
    echo "4. Use the Docker helper script: ./docker_manager.sh"
    echo ""
    echo "Common tasks:"
    echo "- Manage containers through Cockpit web interface"
    echo "- Run containers: docker run -d nginx"
    echo "- Check status: ./docker_manager.sh status"
    echo "- View containers: ./docker_manager.sh containers"
    echo ""
    echo "Service status:"
    sudo systemctl is-active docker && echo "✓ Docker: Active" || echo "✗ Docker: Inactive"
    sudo systemctl is-active containerd && echo "✓ Containerd: Active" || echo "✗ Containerd: Inactive"
    sudo systemctl is-active cockpit.socket && echo "✓ Cockpit: Active" || echo "✗ Cockpit: Inactive"
    echo ""
    echo "Docker version:"
    docker --version 2>/dev/null || echo "Docker not accessible (group membership required)"
    echo ""
    warning "Please log out and log back in for group changes to take effect!"
    echo ""
    info "After logging back in, test with: docker run --rm hello-world"
}

# Main execution
main() {
    log "Starting Docker and Cockpit setup..."
    
    check_root
    check_requirements
    install_docker
    configure_docker_daemon
    setup_user_permissions
    start_docker_service
    install_cockpit_docker
    configure_cockpit_docker
    configure_docker_security
    configure_docker_networking
    setup_registry_mirror
    create_docker_helper_script
    test_docker
    display_summary
    
    log "Setup completed successfully!"
}

# Run main function
main "$@"
