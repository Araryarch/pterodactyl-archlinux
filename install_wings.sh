#!/bin/bash

# Pterodactyl Wings (Daemon) Auto-Installer for Arch Linux
# This script installs Docker and Pterodactyl Wings to run game servers (like Minecraft).

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BBLUE='\033[1;34m'
NC='\033[0m'

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root.${NC}"
   exit 1
fi

echo -e "${GREEN}Welcome to the Pterodactyl Wings Installer for Arch Linux!${NC}"
echo ""

# --- INPUT SECTION ---
echo -e "${BBLUE}--- Configuration Input ---${NC}"
echo -e "To finish the installation automatically, you need the Configuration YAML from the Panel."
echo -e "(Panel -> Settings -> Nodes -> [Select Node] -> Configuration)"
echo ""
read -p "Do you have the Configuration YAML ready to paste? (y/N): " HAS_CONFIG

WINGS_CONFIG=""
if [[ "$HAS_CONFIG" =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Paste your YAML configuration below. Press Ctrl+D when finished:${NC}"
    WINGS_CONFIG=$(cat)
fi
echo ""
# ---------------------

# 1. Install Docker (Required for Minecraft/Wings)
echo -e "${GREEN}[1/4] Installing Docker...${NC}"
pacman -Syu --noconfirm --needed docker

echo -e "${GREEN}[2/4] Starting and Enabling Docker...${NC}"
systemctl enable --now docker

# Check if Docker is running
if systemctl is-active --quiet docker; then
    echo -e "${GREEN}Docker is running.${NC}"
else
    echo -e "${RED}Docker failed to start. Please check logs.${NC}"
    exit 1
fi

# 2. Configure Directory Structure
echo -e "${GREEN}[3/4] Installing Wings...${NC}"
mkdir -p /etc/pterodactyl
curl -Lo /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_amd64"
chmod u+x /usr/local/bin/wings

# 3. Systemd Service
echo -e "${GREEN}[4/4] Configuring Systemd Service...${NC}"
cat <<EOF > /etc/systemd/system/wings.service
[Unit]
Description=Pterodactyl Wings Daemon
After=docker.service
Requires=docker.service
PartOf=docker.service

[Service]
User=root
WorkingDirectory=/etc/pterodactyl
LimitNOFILE=4096
PIDFile=/var/run/wings/daemon.pid
ExecStart=/usr/local/bin/wings
Restart=on-failure
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl enable wings.service

# 4. Final Configuration
echo -e "${GREEN}Installation Steps Completed!${NC}"

if [[ -n "$WINGS_CONFIG" ]]; then
    echo -e "${GREEN}Writing configuration to /etc/pterodactyl/config.yml...${NC}"
    echo "$WINGS_CONFIG" > /etc/pterodactyl/config.yml
    
    echo -e "${GREEN}Starting Wings...${NC}"
    systemctl start wings
    
    echo -e "${BBLUE}Wings should now be running! Check status with 'systemctl status wings'.${NC}"
    echo -e "${BBLUE}Go back to your Panel, and the Node status should turn Green.${NC}"
else
    echo -e "${YELLOW}IMPORTANT NEXT STEPS:${NC}"
    echo "1. Log in to your Pterodactyl Panel."
    echo "2. Go to Admin Settings -> Locations -> Create a Location."
    echo "3. Go to Nodes -> Create New."
    echo "4. After creating the node, click on the 'Configuration' tab."
    echo "5. Copy the YAML Configuration block."
    echo "6. Paste it into: /etc/pterodactyl/config.yml"
    echo "7. Run 'systemctl start wings'"
fi
