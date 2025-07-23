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
