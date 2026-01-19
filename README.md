# Arch Linux Minecraft Server (Pterodactyl) Auto-Installer

This project provides two scripts to automate the installation of a Minecraft Server Control Panel (Pterodactyl) on a fresh Arch Linux server.

**Goal:** Turn a clean Arch Linux installation into a fully functional Minecraft hosting server.

---

## 🚀 Quick Start

**Assumptions:**
*   You have a server with **Arch Linux** installed.
*   You are logged in as **root**.
*   You have a domain name pointing to your server's IP (e.g., `panel.example.com`).

### 1. Download the Scripts
Run this command to download the installer:
```bash
# Install git if missing
pacman -Sy --noconfirm git

# Clone this repo (or download the files manually)
# If you just have the files, skip to step 2.
chmod +x install_panel.sh install_wings.sh
```

### 2. Run Panel Installer (Web Interface)
This checks your PHP, installs the Database, Nginx, and the Panel itself.

```bash
./install_panel.sh
```
**Inputs Required:**
*   **Domain Name**: Your panel domain (e.g., `panel.myserver.com`).
*   **Email**: For the admin account.
*   **Password**: For the admin account.
*   **Timezone**: Defaults to `Asia/Jakarta`.

---

## ⏸️ STOP & CONFIGURE (Crucial Step)

Before running the next script, you **MUST** configure the panel in your browser to get the "Wings Configuration".

1.  **Open your Browser**: Go to `http://panel.yourdomain.com` (or your IP).
2.  **Login**: Use the Admin credentials you created in Step 2.
3.  **Create Location**:
    *   Click the **Gear Icon** (Admin) -> **Locations**.
    *   Click **Create New**.
    *   Short Code: `home`, Description: `Home`.
4.  **Create Node**:
    *   Click **Nodes** -> **Create New**.
    *   **Name**: `LocalNode`.
    *   **FQDN**: Use `127.0.0.1` (since Wings is on the same machine).
    *   **Use SSL Connection**: Select **"Use HTTP Connection"** (unless you already setup SSL).
    *   **Behind Proxy**: Select **"Not behind Proxy"**.
    *   **Daemon Port**: `8080`.
    *   **SFTP Port**: `2022`.
    *   **Total Memory/Disk**: Set to your server's limits (0 = unlimited).
    *   Click **Create Node**.
5.  **Get Configuration**:
    *   After creating, click on the **Configuration** tab.
    *   You will see a block of YAML code (starts with `debug: false`).
    *   **COPY THIS TEXT**.

---

## 3. Run Wings Installer (Game Engine)

This installs Docker and the Daemon that actually runs Minecraft.

```bash
./install_wings.sh
```

**Inputs Required:**
*   **"Do you have the Configuration YAML ready?"**: Type `y`.
*   **Paste**: Paste the YAML text you copied in the previous step.
*   Press **Ctrl+D** to save.

**Success!** If everything worked, the Node status in your web panel should turn **Green (Heartbeat)**.

---

## 🎮 How to Create a Minecraft Server

1.  Go to **Servers** -> **Create New**.
2.  **Core Details**: Name your server.
3.  **Allocation**: Select the default Port.
4.  **Application Feature Limits**: Set CPU/RAM/Disk limits.
5.  **Nest Configuration**:
    *   Select **Minecraft**.
    *   Select **Vanilla Minecraft** (or Paper/Spigot).
6.  **Docker Configuration**: Uncheck "OOM Killer" if possible.
7.  Click **Create Server**.
8.  The server will install. Click on it to view the console!

---

## 🔧 Frequently Asked Questions

### The Panel won't load?
*   Check Nginx: `systemctl status nginx`
*   Check PHP: `systemctl status php-fpm`
*   Did you point your Domain to the server IP?

### Wings failed to start?
*   Run: `systemctl status wings`
*   Check config: `cat /etc/pterodactyl/config.yml`
*   If you missed pasting the config, paste it manually into that file and run `systemctl restart wings`.

### Can't connect to Minecraft?
*   Ensure your firewall allows traffic on the game port (usually 255655).
*   Arch Linux firewall (iptables/ufw) might need configuration if installed.

### How to use SSL (HTTPS)?
The scripts set up HTTP by default to avoid errors. To secure it:
```bash
pacman -S certbot-nginx
certbot --nginx -d panel.yourdomain.com
```
Then update your Node settings in the Panel to "Use SSL" and restart Wings.
