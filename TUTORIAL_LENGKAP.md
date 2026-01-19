# Panduan Lengkap Instalasi Pterodactyl di Arch Linux (Dari Nol)

Panduan ini akan membimbing kamu langkah demi langkah, mulai dari server kosong hingga server Minecraft yang bisa dimainkan.

## 📋 Persyaratan Sebelum Mulai

1.  **Server/VPS** yang sudah terinstall **Arch Linux**.
2.  **IP Address** server kamu (contoh: `103.123.45.67`).
3.  **Domain** (opsional tapi disarankan, contoh `panel.namadomain.com`) yang sudah diarahkan ke IP server.
4.  Koneksi SSH ke server (sebagai `root`).

---

## 🚀 Langkah 1: Persiapan Server & File

Login ke server kamu menggunakan SSH/Terminal:
```bash
ssh root@ip-server-kamu
```

Setelah masuk, download skrip installer kita:
```bash
# Install Git jika belum ada
pacman -Sy --noconfirm git

# Download skrip (Ganti URL ini dengan repo kamu nanti jika di upload, atau buat file manual)
# Anggap kita membuat filenya sekarang:
# (Kamu bisa copy-paste isi file install_panel.sh dan install_wings.sh ke server)

# Berikan izin eksekusi
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
    *   **FQDN / URL**: Masukkan domain kamu (misal: `panel.domainku.com`). Jika tidak punya domain, masukkan IP server saja (misal: `103.123.45.67`).
    *   **Email**: Masukkan email kamu (ini untuk login Admin nanti).
    *   **Admin Password**: Buat password untuk login Admin Dashboard.
    *   **Database Password**: Tekan Enter aja (biar auto-generate).
    *   **Timezone**: Tekan Enter aja (default Asia/Jakarta).

3.  Tunggu proses instalasi selesai (bisa 5-10 menit tergantung internet server).
4.  Jika sukses, akan muncul pesan:
    **"Installation Complete! You can now access your Pterodactyl Panel..."**

---

## 🛠️ Langkah 3: Login & Konfigurasi Awal (PENTING!)

Disini banyak orang bingung. Jangan jalankan script kedua dulu! Kita harus setting Panel via Browser.

1.  Buka browser (Chrome/Edge) di laptop kamu.
2.  Ketik alamat panel kamu (sesuai yang diinput tadi, misal `http://103.123.45.67` atau domain).
3.  **Login** menggunakan Email dan Password yang kamu buat di Langkah 2.

### Registrasi "Node" (Mesin Server)
Agar panel bisa mengontrol server ini, kita harus mendaftarkannya sebagai "Node".

1.  Klik ikon **Gear (Gerigi)** di pojok kanan atas untuk masuk ke **Admin View**.
2.  Di menu kiri, pilih **Locations** -> klik **Create New**.
    *   Short Code: `home`
    *   Description: `Server Rumah`
    *   Klik **Create**.
3.  Di menu kiri, pilih **Nodes** -> klik **Create New**.
    *   **Name**: `LocalNode`
    *   **Location**: Pilih `home`.
    *   **FQDN**: Tulis `127.0.0.1` (Penting: Gunakan ini karena Wings dan Panel ada di satu server yang sama).
    *   **Communicate Over SSL**: Pilih `Use HTTP Connection` (Kecuali kamu sudah pasang SSL/HTTPS).
    *   **Behind Proxy**: Pilih `Not behind Proxy`.
    *   **Daemon Port**: `8080`.
    *   **SFTP Port**: `2022`.
    *   **Total Memory**: Isi `0` (untuk unlimited) atau sesuai RAM server.
    *   **Total Disk Space**: Isi `0` (untuk unlimited).
    *   Klik **Create Node**.

### Ambil Kode Konfigurasi
1.  Setelah Node jadi, kamu akan melihat tab menu diatasnya: **Settings**, **Configuration**, **Allocation**.
2.  Klik tab **Configuration**.
3.  Kamu akan melihat kotak kode `YAML` (teks yang dimulai dengan `debug: false`...).
4.  **Copy** semua teks itu. Kita butuh ini untuk Langkah 4.

---

## 🦋 Langkah 4: Instalasi Wings (Mesin Game)

Kembali ke terminal/SSH server kamu.

1.  Jalankan perintah:
    ```bash
    ./install_wings.sh
    ```
2.  Script akan bertanya:
    *   **"Do you have the Configuration YAML ready?"**: Ketik `y` lalu Enter.
    *   **Paste**: Paste kode yang tadi kamu copy dari browser.
    *   **Simpan**: Setelah paste, tekan `Ctrl + D` (Di Windows kadang perlu Enter dulu baru Ctrl+D).

3.  Script akan menginstall Docker dan menjalankan Wings.
4.  Jika sukses, script akan bilang **"Wings should now be running!"**.

**Cek Status:**
Kembali ke Browser -> Menu **Nodes**. Lihat indikator di sebelah nama Node kamu. Jika warnanya **HIJAU** (berdetak), artinya sukses!

---

## 🎮 Langkah 5: Buat Server Minecraft

Sekarang semuanya sudah siap. Waktunya membuat server game.

1.  Di Panel Admin, klik menu **Servers** -> **Create New**.
2.  **Core Details**:
    *   **Server Name**: `Survival SMP` (bebas).
    *   **Server Owner**: Ketik email kamu (admin) lalu pilih user yang muncul.
3.  **Allocation Management**:
    *   Pilih IP dan Port yang tersedia (biasanya sudah otomatis terpilih).
4.  **Application Feature Limits**:
    *   Tentukan RAM (misal `2048` untuk 2GB).
5.  **Nest Configuration**:
    *   **Nest**: Pilih `Minecraft`.
    *   **Egg**: Pilih `Vanilla Minecraft` (atau Paper/Spigot jika mau plugin).
6.  **Docker Configuration**:
    *   Biarkan default.
7.  Klik tombol **Create Server** di paling bawah.

Server akan mulai proses "Installing". Klik nama servernya untuk melihat Console. Tunggu sampai selesai download jar, dan **Start** servernya.

**Selamat! Kamu sudah punya server Minecraft sendiri!**
