# Docker and Cockpit Management Guide

This guide covers setting up Docker with Cockpit web interface for container management on your system.

## Quick Start

1. **Run the setup script:**
   ```bash
   ./setup_docker_cockpit.sh
   ```

2. **Log out and log back in** (required for group membership changes)

3. **Access Cockpit:** https://localhost:9090

4. **Navigate to containers:** Click "Podman containers" in the left sidebar

## What Gets Installed

### Core Components
- **Docker Engine** - Container runtime
- **Docker Compose** - Multi-container application management
- **Docker Buildx** - Extended build capabilities
- **Cockpit-Podman** - Web interface for container management
- **ctop** - Container resource monitoring

### Security Features
- User group permissions (docker group)
- Seccomp security profiles
- AppArmor integration
- Resource limits and logging

## Cockpit Docker Features

### Container Management
- **Create Containers** - Deploy from images with custom settings
- **Start/Stop/Restart** - Container lifecycle management
- **View Logs** - Real-time and historical container logs
- **Resource Monitoring** - CPU, memory, and network usage
- **Shell Access** - Execute commands inside containers

### Image Management
- **Pull Images** - Download from Docker Hub and other registries
- **Build Images** - Create custom images from Dockerfiles
- **Image History** - View image layers and metadata
- **Remove Images** - Clean up unused images

### Network Management
- **Custom Networks** - Create isolated container networks
- **Port Mapping** - Expose container services
- **Network Inspection** - View network configuration

### Volume Management
- **Data Persistence** - Create and manage Docker volumes
- **Bind Mounts** - Mount host directories
- **Volume Inspection** - View usage and configuration

## Command Line Helper

The setup creates `docker_manager.sh` with useful commands:

```bash
# View system status
./docker_manager.sh status

# List containers
./docker_manager.sh containers

# View images
./docker_manager.sh images

# System cleanup
./docker_manager.sh cleanup

# Container stats
./docker_manager.sh stats

# View container logs
./docker_manager.sh logs container_name

# Execute commands in container
./docker_manager.sh exec container_name bash

# Docker Compose operations
./docker_manager.sh compose-up
./docker_manager.sh compose-down
```

## Common Docker Operations

### Running Containers

#### Web Server (Nginx)
```bash
docker run -d --name web-server -p 80:80 nginx:latest
```

#### Database (PostgreSQL)
```bash
docker run -d --name postgres-db \
  -e POSTGRES_PASSWORD=mypassword \
  -e POSTGRES_DB=myapp \
  -p 5432:5432 postgres:15
```

#### Development Environment (Node.js)
```bash
docker run -it --name node-dev \
  -v $(pwd):/app \
  -w /app \
  -p 3000:3000 node:18 bash
```

### Docker Compose Example

Create `docker-compose.yml`:
```yaml
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"
    volumes:
      - ./html:/usr/share/nginx/html
  
  app:
    image: node:18
    working_dir: /app
    volumes:
      - ./app:/app
    ports:
      - "3000:3000"
    command: npm start
  
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password
      POSTGRES_DB: myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
```

## Cockpit Access and Navigation

### Accessing Cockpit
1. Open browser to: https://localhost:9090
2. Login with your system user account
3. Click "Podman containers" in left sidebar

### Creating Containers via Cockpit
1. Click "Create container"
2. Enter image name (e.g., `nginx:latest`)
3. Configure ports, volumes, and environment variables
4. Click "Create and run"

### Managing Running Containers
- **Start/Stop:** Use action buttons next to container names
- **View Logs:** Click container name → Logs tab
- **Terminal Access:** Click container name → Terminal tab
- **Resource Usage:** Monitor in the Overview tab

## Security Considerations

### Container Security
- Run containers as non-root users when possible
- Use official images from trusted registries
- Regularly update images for security patches
- Limit container resources (CPU, memory)
- Use secrets management for sensitive data

### Network Security
- Use custom networks for container isolation
- Avoid exposing unnecessary ports
- Configure firewall rules appropriately
- Use reverse proxies for web services

### Data Security
- Use named volumes instead of bind mounts when possible
- Backup important container data regularly
- Encrypt sensitive data at rest
- Use proper file permissions on host

## Troubleshooting

### Docker Service Issues
```bash
# Check Docker status
sudo systemctl status docker

# View Docker logs
sudo journalctl -u docker.service

# Restart Docker
sudo systemctl restart docker
```

### Permission Issues
```bash
# Verify group membership
groups $USER

# Re-add to docker group if needed
sudo usermod -a -G docker $USER
```

### Container Issues
```bash
# View container logs
docker logs container_name

# Inspect container configuration
docker inspect container_name

# Check resource usage
docker stats
```

### Cockpit Issues
```bash
# Restart Cockpit
sudo systemctl restart cockpit.socket

# Check Cockpit status
sudo systemctl status cockpit.socket

# View Cockpit logs
sudo journalctl -u cockpit.socket
```

## Performance Optimization

### Docker Daemon
- Configure appropriate storage driver
- Set log rotation limits
- Optimize memory and CPU usage
- Use multi-stage builds for smaller images

### Container Optimization
- Use Alpine-based images when possible
- Minimize image layers
- Remove unnecessary packages
- Use .dockerignore files

### System Resources
- Monitor disk space usage
- Clean up unused containers and images regularly
- Use Docker system prune commands
- Consider using external storage for large volumes

## Best Practices

### Development
- Use version tags instead of `latest`
- Create multi-stage Dockerfiles
- Use environment variables for configuration
- Implement health checks

### Production
- Use orchestration tools (Docker Swarm, Kubernetes)
- Implement monitoring and logging
- Use secrets management
- Regular security scanning

### Maintenance
- Regular cleanup of unused resources
- Update images and containers regularly
- Monitor resource usage
- Backup important data

## Integration with Other Services

### Reverse Proxy (Nginx)
Configure Nginx to proxy requests to containers:
```nginx
upstream app {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name example.com;
    
    location / {
        proxy_pass http://app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### Systemd Integration
Create systemd services for critical containers:
```ini
[Unit]
Description=My App Container
After=docker.service
Requires=docker.service

[Service]
ExecStart=/usr/bin/docker run --name myapp -p 3000:3000 myapp:latest
ExecStop=/usr/bin/docker stop myapp
ExecStopPost=/usr/bin/docker rm myapp
Restart=always

[Install]
WantedBy=multi-user.target
```

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Cockpit Documentation](https://cockpit-project.org/documentation.html)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Container Security Best Practices](https://docs.docker.com/engine/security/)

## Support and Updates

This setup provides a solid foundation for Docker container management through Cockpit. For updates or issues:

1. Check the Docker and Cockpit documentation
2. Use the helper script for common operations
3. Monitor system logs for troubleshooting
4. Keep Docker and system packages updated

The Cockpit web interface provides an intuitive way to manage containers without requiring extensive command-line knowledge, while still providing full Docker functionality.
