# Pterodactyl Panel & Wings Auto-Installer for Arch Linux

This repository contains scripts to automate the installation of **Pterodactyl Panel** and **Wings** on Arch Linux, specifically tailored for running a **Minecraft Server**.

## Installation Flow

To get a working Minecraft server, you need to run **both** scripts in order.

### Step 1: Install the Panel
This installs the web interface where you manage your servers.

1.  Make the scripts executable:
    ```bash
    chmod +x install_panel.sh install_wings.sh
    ```
2.  Run the panel installer:
    ```bash
    ./install_panel.sh
    ```
3.  Follow the prompts. At the end, you will be able to log in to your panel (e.g., `http://panel.yourdomain.com`).

### Step 2: Install Wings (Required for Minecraft)
This installs Docker and the Daemon that actually runs Minecraft.

1.  Run the wings installer:
    ```bash
    ./install_wings.sh
    ```
2.  **Configuration (Crucial)**:
    *   Log in to your new Panel.
    *   Go to **Settings** (Gear Icon) -> **Locations** -> Create a Location (e.g. "Home").
    *   Go to **Nodes** -> **Create New**.
    *   Fill in details:
        *   **Use SSL**: `Use HTTP Connection` (unless you set up SSL).
        *   **FQDN**: `127.0.0.1` (if running panel & wings on same machine) or your Pubic IP.
    *   **Click Create**.
    *   Click on the **Configuration** tab of your new Node.
    *   **Copy** the YAML code block.
    *   **Paste** it into `/etc/pterodactyl/config.yml` on your server.
3.  Start Wings:
    ```bash
    systemctl start wings
    ```
    (Check status with `systemctl status wings`. It should say "Active (running)").

### Step 3: Create Minecraft Server
1.  In the Panel, go to **Servers** -> **Create New**.
2.  Select "Minecraft" as the game.
3.  Select the Node you just created.
4.  Follow the prompts to finish!

## Requirements
*   Fresh Arch Linux Installation.
*   Root privileges (`sudo` or root user).
*   Internet connection.

## Troubleshooting
*   **Composer Errors**: If Step 1 fails at `composer install`, check that your PHP extensions are enabled in `/etc/php/php.ini`. The script attempts to do this, but Arch updates frequently.
*   **Docker not starting**: Run `systemctl status docker` to debug.
*   **Wings not connecting**: Ensure your Node FQDN matches the IP/Domain you are trying to reach. If running locally/lan, `127.0.0.1` or LAN IP is best.
