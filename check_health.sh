#!/bin/bash

# Pterodactyl Health Check Script for Arch Linux
# This script verifies that all components of the Pterodactyl Panel and Wings are running correctly.

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
dBLUE='\033[1;34m' # Docker Blue :D
NC='\033[0m'

echo -e "${dBLUE}=========================================${NC}"
echo -e "${dBLUE}   PTERODACTYL SYSTEM HEALTH CHECK       ${NC}"
echo -e "${dBLUE}=========================================${NC}"
echo ""

# Helper function to check service status
check_service() {
    local SERVICE=$1
    local DISPLAY_NAME=$2
    
    if systemctl is-active --quiet "$SERVICE"; then
        echo -e "[ ${GREEN}OK${NC} ] $DISPLAY_NAME ($SERVICE) is running."
    else
        echo -e "[${RED}FAIL${NC}] $DISPLAY_NAME ($SERVICE) is NOT running!"
        # Attempt to show reason
        systemctl status "$SERVICE" --no-pager | grep "Active:" | xargs
    fi
}

echo -e "${YELLOW}--- Core Web Services ---${NC}"
check_service "nginx" "Web Server"
check_service "php-fpm" "PHP Process Manager"
check_service "mariadb" "Database Server"
check_service "redis" "Redis Cache"
echo ""

echo -e "${YELLOW}--- Pterodactyl Components ---${NC}"
check_service "pteroq.service" "Queue Worker"
check_service "docker" "Docker Engine"
check_service "wings" "Wings Daemon (Node)"
echo ""

echo -e "${YELLOW}--- Network & Ports ---${NC}"

# Check HTTP (Panel)
if curl -s --head  --request GET http://localhost | grep "200 OK" > /dev/null; then
     echo -e "[ ${GREEN}OK${NC} ] Localhost HTTP (Port 80) is responding (200 OK)."
else
     echo -e "[${RED}WARN${NC}] Localhost HTTP (Port 80) did not return 200 OK. (Might be 301/404 or down)"
fi

# Check Wings Port (8080)
if lsof -i :8080 >/dev/null 2>&1 || ss -lnt | grep :8080 >/dev/null; then
    echo -e "[ ${GREEN}OK${NC} ] Wings Port (8080) is open."
else
    echo -e "[${RED}FAIL${NC}] Wings Port (8080) is NOT open. Is Wings running?"
fi

# Check SFTP Port (2022)
if lsof -i :2022 >/dev/null 2>&1 || ss -lnt | grep :2022 >/dev/null; then
    echo -e "[ ${GREEN}OK${NC} ] SFTP Port (2022) is open."
else
    echo -e "[${RED}FAIL${NC}] SFTP Port (2022) is NOT open."
fi

echo ""
echo -e "${dBLUE}=========================================${NC}"
echo -e "Diagnostic Complete."
echo -e "If everything is Green, your server is healthy!"
echo -e "${dBLUE}=========================================${NC}"
