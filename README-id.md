# Panduan Lengkap Instalasi Pterodactyl di Arch Linux (Dari Nol)

Panduan ini akan membimbing kamu langkah demi langkah, mulai dari server kosong hingga server Minecraft yang bisa dimainkan.

**Bahasa Lain:**
- [English](README.md)
- [日本語 (Japanese)](README-jp.md)

## 📋 Persyaratan Sebelum Mulai

1.  **Server/VPS** yang sudah terinstall **Arch Linux**.
2.  **IP Address** server kamu (contoh: `103.123.45.67`).
3.  **Domain**: Kalau belum punya domain, **PAKAI IP ADDRESS SAJA** tidak masalah. Nanti aksesnya lewat IP (contoh: `http://103.123.45.67`).
4.  Koneksi SSH ke server (sebagai `root`).

---

## 🚀 Langkah 1: Persiapan Server & File

Login ke server kamu menggunakan SSH/Terminal:
```bash
ssh root@ip-server-kamu
```

Setelah masuk, download skrip installer ini:
```bash
# Install Git jika belum ada
pacman -Sy --noconfirm git

# Download skrip (Cloning repo)
git clone https://github.com/username/repo-ini.git
cd repo-ini
chmod +x install_panel.sh install_wings.sh
```

---

## 💿 Langkah 2: Instalasi Panel (Web Interface)

Ini adalah tahap instalasi "Website" tempat kamu mengatur segalanya.

1.  Jalankan perintah:
    ```bash
    ./install_panel.sh
    ```
2.  Script akan meminta input. Isi sesuai dangan data kamu:
    *   **FQDN / URL**: Masukkan domain kamu (misal: `panel.domainku.com`). **Jika tidak punya domain, masukkan IP PUBLIC server kamu** (misal: `103.123.45.67`).
    *   **Email**: Masukkan email kamu (ini untuk login Admin nanti).
    *   **Admin Password**: Buat password untuk login Admin Dashboard.
    *   **Database Password**: Tekan *Enter* aja (biar auto-generate).
    *   **Timezone**: Tekan *Enter* aja (default Asia/Jakarta).

3.  Tunggu proses instalasi selesai.

---

## 🛠️ Langkah 3: Konfigurasi Web (PENTING!)

**STOP!** Jangan jalankan script kedua dulu! Kita harus setting Panel via Browser.

1.  Buka browser (Chrome/Edge) di laptop kamu.
2.  Ketik alamat panel kamu (misal `http://103.123.45.67`).
3.  **Login** menggunakan Email dan Password yang kamu buat di Langkah 2.

### Registrasi "Node" (Mesin Server)
1.  Klik ikon **Gear (Gerigi)** di pojok kanan atas untuk masuk ke **Admin View**.
2.  Di menu kiri, pilih **Locations** -> klik **Create New**.
    *   Short Code: `home`
    *   Description: `Server Rumah`
    *   Klik **Create**.
3.  Di menu kiri, pilih **Nodes** -> klik **Create New**.
    *   **Name**: `LocalNode`
    *   **Location**: Pilih `home`.
    *   **FQDN**: Tulis `127.0.0.1` (**PENTING**: Gunakan `127.0.0.1` karena Wings dan Panel ada di satu server yang sama).
    *   **Communicate Over SSL**: Pilih `Use HTTP Connection` (Kecuali kamu pakai SSL).
    *   **Daemon Port**: `8080`, **SFTP Port**: `2022`.
    *   **Total Memory / Disk**: Isi `0` (unlimited).
    *   Klik **Create Node**.

### Ambil Kode Konfigurasi
1.  Setelah Node jadi, klik tab **Configuration**.
2.  **Copy** semua teks YAML yang muncul.

---

## 🦋 Langkah 4: Instalasi Wings (Mesin Game)

Kembali ke terminal server kamu.

1.  Jalankan perintah:
    ```bash
    ./install_wings.sh
    ```
2.  Script akan bertanya: **"Do you have the Configuration YAML ready?"**
    *   Ketik `y` lalu tekan *Enter*.
    *   **Paste** kode yang tadi kamu copy dari browser.
    *   Tekan `Ctrl + D` untuk menyimpan.

3.  Jika sukses, indikator Node di browser kamu akan berubah jadi **HIJAU**.

---

## 🎮 Langkah 5: Buat Server Minecraft

1.  Di Panel Admin, klik menu **Servers** -> **Create New**.
2.  Isi data:
    *   **Server Name**: `Survival SMP`.
    *   **Owner**: Pilih user admin kamu.
    *   **Nest/Egg**: Pilih `Minecraft` -> `Vanilla Minecraft`.
3.  Klik **Create Server**.

Server akan otomatis diinstall. Selamat bermain!
