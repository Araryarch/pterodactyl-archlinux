# Arch Linux Pterodactyl Installer (Step-by-Step)

This guide will walk you through setting up a Minecraft Server Panel on a fresh Arch Linux system.

**Other Languages:**
- [Bahasa Indonesia](README-id.md)
- [日本語 (Japanese)](README-jp.md)

## 📋 Prerequisites

1.  **Server/VPS** running **Arch Linux**.
2.  **IP Address** of your server (e.g., `103.123.45.67`).
3.  **Domain**: Recommended but not required. If you don't have one, **use your Server IP**.
4.  **Root Access** (SSH as `root`).

---

## 🚀 Step 1: Preparation

SSH into your server:
```bash
ssh root@your-server-ip
```

Download the scripts (Clone this repo or copy files manually):
```bash
pacman -Sy --noconfirm git
git clone https://github.com/your-username/your-repo.git
cd your-repo
chmod +x install_panel.sh install_wings.sh
```

---

## 💿 Step 2: Install Panel (Web Interface)

This installs the website where you manage your servers.

1.  Run the panel installer:
    ```bash
    ./install_panel.sh
    ```
2.  Enter the required details:
    *   **FQDN / URL**: Enter your domain (e.g., `panel.example.com`). **If you don't have a domain, enter your Public IP**.
    *   **Email**: For the admin login.
    *   **Password**: For the admin login.
    *   **Database Password**: Press Enter to auto-generate.
    *   **Timezone**: Press Enter for default.

3.  Wait for the installation to complete.

---

## 🛠️ Step 3: Web Configuration (CRITICAL!)

**STOP!** Do not run the second script yet. You must configure the panel in your browser first.

1.  Open your browser and visit your Panel URL (e.g. `http://103.123.45.67`).
2.  **Login** with the credentials created in Step 2.

### Create a "Node"
1.  Click the **Gear Icon** (top right) to enter Admin View.
2.  Go to **Locations** -> **Create New**.
    *   Short Code: `home`
    *   Description: `Home Server`
    *   Click **Create**.
3.  Go to **Nodes** -> **Create New**.
    *   **Name**: `LocalNode`
    *   **Location**: local
    *   **FQDN**: Enter `127.0.0.1` (**IMPORTANT**: Use 127.0.0.1 since Wings is on the same machine).
    *   **Communicate Over SSL**: Select `Use HTTP Connection`.
    *   **Daemon Port**: `8080`, **SFTP Port**: `2022`.
    *   **Memory/Disk**: Set to `0` (unlimited).
    *   Click **Create Node**.

### Get Configuration
1.  After creating the Node, click the **Configuration** tab.
2.  **Copy** the YAML code block shown there.

---

## 🦋 Step 4: Install Wings (Game Engine)

Back in your terminal:

1.  Run the wings installer:
    ```bash
    ./install_wings.sh
    ```
2.  The script will ask: **"Do you have the Configuration YAML ready?"**
    *   Type `y` and Enter.
    *   **Paste** the YAML code you copied from the browser.
    *   Press `Ctrl+D` to save.

3.  If successful, the Node indicator in your browser should turn **Green**.

---

## 🎮 Step 5: Create Minecraft Server

1.  In the Admin Panel, go to **Servers** -> **Create New**.
2.  Fill in the details:
    *   **Name**: `My Minecraft Server`
    *   **Owner**: Select your admin account.
    *   **Nest/Egg**: Select `Minecraft` -> `Vanilla Minecraft`.
3.  Click **Create Server**.

The server will install and you can inspect it via the Console. Enjoy!
