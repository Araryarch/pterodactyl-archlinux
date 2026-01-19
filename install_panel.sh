#!/bin/bash

# Pterodactyl Panel Auto-Installer for Arch Linux
# This script automates the installation of Pterodactyl Panel on Arch Linux.
# It assumes a clean installation.

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run as root.${NC}"
   exit 1
fi

echo -e "${GREEN}Welcome to the Pterodactyl Panel Installer for Arch Linux!${NC}"
echo -e "${YELLOW}Please note: This script is designed for a fresh Arch Linux installation.${NC}"
echo ""

# --- RESET OPTION ---
read -p "Do you want to COMPLETELY RESET (WIPE) any existing Pterodactyl data before installing? (y/N): " DO_RESET

if [[ "$DO_RESET" =~ ^[Yy]$ ]]; then
    echo -e "${RED}!!! DANGER ZONE !!!${NC}"
    echo -e "${RED}This will DELETE your database, all servers, settings, and configuration.${NC}"
    read -p "Are you ABSOLUTELY SURE? Type 'LETSGO' to confirm: " CONFIRM_RESET
    
    if [[ "$CONFIRM_RESET" == "LETSGO" ]]; then
        echo -e "${RED}Wiping Pterodactyl...${NC}"
        
        # Stop Services
        echo "Stopping services..."
        systemctl stop pteroq wings nginx php-fpm || true
        
        # Remove Files
        echo "Removing files..."
        rm -rf /var/www/pterodactyl
        rm -rf /etc/pterodactyl
        rm -f /etc/systemd/system/pteroq.service
        rm -f /etc/systemd/system/wings.service
        rm -f /etc/nginx/conf.d/pterodactyl.conf
        systemctl daemon-reload
        
        # Drop DB (Try mariadb first, fallback to mysql if specific version issues, but mariadb command is standard now)
        echo "Dropping database..."
        mariadb -u root -e "DROP DATABASE IF EXISTS panel;" || true
        mariadb -u root -e "DROP USER IF EXISTS 'pterodactyl'@'127.0.0.1';" || true
        
        echo -e "${GREEN}Wipe Complete. Starting fresh installation...${NC}"
        echo ""
    else
        echo -e "${GREEN}Reset cancelled. Continuing with normal installation...${NC}"
    fi
fi
# --------------------


# Gather Information
read -p "Enter your FQDN (e.g., panel.example.com): " PANEL_URL
# Sanitize URL: Remove http:// or https:// if user typed it
PANEL_URL=${PANEL_URL#http://}
PANEL_URL=${PANEL_URL#https://}
PANEL_URL=${PANEL_URL%/}
read -p "Enter an email address for the admin user: " EMAIL
read -s -p "Enter a password for the admin user: " ADMIN_PASSWORD
echo ""
read -p "Enter a database password for the 'pterodactyl' user (randomly generated if empty): " DB_PASSWORD
read -p "Enter your Timezone (default: Asia/Jakarta): " TIMEZONE
TIMEZONE=${TIMEZONE:-Asia/Jakarta}

if [[ -z "$DB_PASSWORD" ]]; then
    DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
    echo -e "${YELLOW}Generated Database Password: ${DB_PASSWORD}${NC}"
fi

# 1. Update System and Install Dependencies
echo -e "${GREEN}[1/8] Updating system and installing dependencies...${NC}"
pacman -Syu --noconfirm
# Essential packages
# php-sqlite is often needed for some internal laravel things or tests, but mysql is main.
# php-sodium is usually core or separate depending on repo state.
PACKAGES=(
    base-devel
    git
    curl
    wget
    unzip
    tar
    nginx
    mariadb
    redis
    php
    php-fpm
    php-gd
    php-intl
    php-sodium
    composer
)

# Try to install packages. Note: Arch php packages can vary. 
# We explicitly enable extensions later.
pacman -S --noconfirm --needed "${PACKAGES[@]}"

# VERIFICATION: Check if Composer and PHP are actually working
echo -e "${GREEN}Verifying Composer and PHP installation...${NC}"
if ! command -v composer &> /dev/null; then
    echo -e "${RED}Composer could not be found. Installation failed.${NC}"
    exit 1
fi

PHP_VER=$(php -v | head -n 1 | awk '{print $2}')
echo -e "${GREEN}PHP Version detected: $PHP_VER${NC}"
# Warn if PHP is very new (Arch is rolling)
if [[ "$PHP_VER" == 8.4* ]] || [[ "$PHP_VER" == 8.5* ]]; then
    echo -e "${YELLOW}WARNING: Arch Linux often has very new PHP versions ($PHP_VER). Pterodactyl might have compatibility issues.${NC}"
    echo -e "${YELLOW}If installation fails, consider using a Docker-based install or downgrading PHP.${NC}"
fi

# 2. Configure PHP
echo -e "${GREEN}[2/8] Configuring PHP...${NC}"
PHP_INI="/etc/php/php.ini"

# Backup original php.ini
cp "$PHP_INI" "$PHP_INI.bak"

# Uncomment extensions
# Extensions: bcmath, curl, gd, intl, mbstring, mysqli, openssl, pdo_mysql, sodium, zip, iconv, exif
EXTENSIONS=("bcmath" "curl" "gd" "intl" "mbstring" "mysqli" "openssl" "pdo_mysql" "sodium" "zip" "iconv" "exif")

for ext in "${EXTENSIONS[@]}"; do
    sed -i "s/;extension=$ext/extension=$ext/" "$PHP_INI"
done

# Set verify_ssl if needed (usually default is fine)
# Increase upload limits recommended for panel
sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' "$PHP_INI"
sed -i 's/post_max_size = .*/post_max_size = 100M/' "$PHP_INI"
sed -i 's/memory_limit = .*/memory_limit = 512M/' "$PHP_INI"

# 3. Start and Configure Services
echo -e "${GREEN}[3/8] Starting services...${NC}"

# Redis
# Handle possible "linked unit file" errors from previous bad states
if [[ -L "/etc/systemd/system/redis.service" ]]; then
    echo -e "${YELLOW}Removing conflicting redis.service symlink...${NC}"
    rm "/etc/systemd/system/redis.service"
    systemctl daemon-reload
fi
systemctl enable --now redis

# MariaDB
echo -e "${YELLOW}Initializing MariaDB...${NC}"

if [[ -d "/var/lib/mysql/mysql" ]]; then
    echo -e "${YELLOW}MariaDB data directory exists. Running upgrade instead of install...${NC}"
    systemctl enable --now mariadb
    # Wait for MariaDB to start before upgrading
    sleep 5
    mariadb-upgrade -u root --force || echo "MariaDB upgrade not needed or failed (non-critical if DB works)."
else
    echo -e "${GREEN}Installing fresh MariaDB data directory...${NC}"
    mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
    systemctl enable --now mariadb
    sleep 5
fi

# Create Database and User
echo -e "${GREEN}[4/8] Setting up Database...${NC}"
mariadb -u root -e "CREATE DATABASE IF NOT EXISTS panel;"
mariadb -u root -e "CREATE USER IF NOT EXISTS 'pterodactyl'@'127.0.0.1' IDENTIFIED BY '$DB_PASSWORD';"
mariadb -u root -e "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION;"
mariadb -u root -e "FLUSH PRIVILEGES;"

# 4. Install Pterodactyl Panel
echo -e "${GREEN}[5/8] Downloading and Installing Pterodactyl Panel...${NC}"
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl

curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage bootstrap/cache

# 5. Configure Panel Environment
echo -e "${GREEN}[6/8] Configuring Environment...${NC}"
cp .env.example .env
composer install --no-dev --optimize-autoloader

# Generate App Key
php artisan key:generate --force

# Fill .env variables manually to avoid interactive setup
sed -i "s|APP_URL=http://localhost|APP_URL=http://$PANEL_URL|g" .env
sed -i "s|DB_HOST=127.0.0.1|DB_HOST=127.0.0.1|g" .env
sed -i "s|DB_PORT=3306|DB_PORT=3306|g" .env
sed -i "s|DB_DATABASE=panel|DB_DATABASE=panel|g" .env
sed -i "s|DB_USERNAME=pterodactyl|DB_USERNAME=pterodactyl|g" .env
sed -i "s|DB_PASSWORD=|DB_PASSWORD=$DB_PASSWORD|g" .env
sed -i "s|APP_TIMEZONE=UTC|APP_TIMEZONE=$TIMEZONE|g" .env
sed -i "s|CACHE_DRIVER=file|CACHE_DRIVER=redis|g" .env
sed -i "s|SESSION_DRIVER=file|SESSION_DRIVER=redis|g" .env
sed -i "s|QUEUE_CONNECTION=sync|QUEUE_CONNECTION=redis|g" .env

# Run Migrations
echo -e "${YELLOW}Running Database Migrations...${NC}"
php artisan migrate --seed --force

# Check if user already exists to avoid "email taken" errors on re-runs
USER_EXISTS=$(mariadb -u root -s -N -e "SELECT EXISTS(SELECT 1 FROM panel.users WHERE email = '$EMAIL')")

if [[ "$USER_EXISTS" -eq 0 ]]; then
    echo -e "${YELLOW}Creating Admin User...${NC}"
    php artisan p:user:make --email="$EMAIL" --username="admin" --name-first="Admin" --name-last="User" --password="$ADMIN_PASSWORD" --admin=1
else
    echo -e "${YELLOW}User with email $EMAIL already exists. Skipping creation.${NC}"
fi

# Set Permissions
# On Arch, web user is 'http'
chown -R http:http /var/www/pterodactyl

# 6. Queue Listener
echo -e "${GREEN}[7/8] configuring Queue Listener...${NC}"
cat <<EOF > /etc/systemd/system/pteroq.service
# Pterodactyl Queue Worker File
# ----------------------------------

[Unit]
Description=Pterodactyl Queue Worker
After=redis.service

[Service]
# On some systems the user and group might be different.
# Some distributions use 'www-data' or 'apache' or 'nginx' as the www-data user.
User=http
Group=http
Restart=always
ExecStart=/usr/bin/php /var/www/pterodactyl/artisan queue:work --queue=high,standard,low --sleep=3 --tries=3
StartLimitInterval=180
StartLimitBurst=30
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now pteroq.service

# 7. Nginx Configuration
echo -e "${GREEN}[8/8] Configuring Nginx...${NC}"
# Backup the default Arch nginx config which contains the conflicting "Welcome" server block
if [[ ! -f /etc/nginx/nginx.conf.bak ]]; then
    mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
fi

# Stop Nginx if it's running to prevent "Address already in use" errors during config changes
if systemctl is-active --quiet nginx; then
    echo -e "${YELLOW}Stopping Nginx to apply new changes...${NC}"
    systemctl stop nginx
fi

# Create a clean main configuration file
cat <<EOF > /etc/nginx/nginx.conf
user http;
worker_processes auto;
pcre_jit on;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;
    
    # Fix "could not build optimal types_hash" warning
    types_hash_max_size 2048;
    types_hash_bucket_size 128;
    
    sendfile on;
    keepalive_timeout 65;
    client_max_body_size 100m;
    
    # Include our Pterodactyl config
    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
}
EOF

mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled

# Write the Pterodactyl server block
# We use 'server_name _;' as a fallback to ensure it works on IP address access too


cat <<EOF > /etc/nginx/conf.d/pterodactyl.conf
server {
    listen 80;
    server_name $PANEL_URL;
    root /var/www/pterodactyl/public;
    index index.php;

    access_log /var/log/nginx/pterodactyl.app-access.log;
    error_log  /var/log/nginx/pterodactyl.app-error.log error;

    # allow larger file uploads and longer script runtimes
    client_max_body_size 100m;
    client_body_timeout 120s;

    sendfile off;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param PHP_VALUE "upload_max_filesize = 100M \n post_max_size = 100M";
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param HTTP_PROXY "";
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        fastcgi_connect_timeout 300;
        fastcgi_send_timeout 300;
        fastcgi_read_timeout 300;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF

# Restart Nginx and PHP-FPM
systemctl restart php-fpm
systemctl enable --now nginx

# Test Nginx Config first
echo -e "${YELLOW}Testing Nginx Configuration...${NC}"
nginx -t

systemctl restart nginx

echo -e "${GREEN}Installation Complete!${NC}"
echo -e "${YELLOW}You can now access your Pterodactyl Panel at $PANEL_URL${NC}"
echo -e "${YELLOW}Don't forget to configure SSL (e.g., using certbot)!${NC}"
echo ""
echo -e "${GREEN}FOR MINECRAFT SERVERS:${NC}"
read -p "Do you want to install Wings (Daemon) too? (y/N): " INSTALL_WINGS
if [[ "$INSTALL_WINGS" =~ ^[Yy]$ ]]; then
    ./install_wings.sh
else
    echo -e "Okay. You can run './install_wings.sh' manually later."
fi

# --- Health Check Integration ---
echo ""
echo -e "${GREEN}[9/8] Running System Health Check...${NC}"

# Helper function for health check (re-defined locally to ensure availability)
check_status() {
    if systemctl is-active --quiet "$1"; then
        echo -e "[ ${GREEN}OK${NC} ] Service $1 is active."
    else
        echo -e "[${RED}FAIL${NC}] Service $1 is NOT active!"
    fi
}

check_status "nginx"
check_status "php-fpm"
check_status "mariadb"
check_status "redis"
check_status "pteroq.service"

# Check HTTP
if curl -s --head --request GET http://localhost | grep "200 OK" > /dev/null; then
     echo -e "[ ${GREEN}OK${NC} ] HTTP (Port 80) is responding 200 OK."
else
     echo -e "[${YELLOW}WARN${NC}] HTTP (Port 80) did not return 200 OK (Check Nginx logs)."
fi
echo ""
