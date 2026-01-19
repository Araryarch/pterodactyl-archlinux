# Arch Linux Pterodactyl インストールガイド

このガイドでは、Arch Linux サーバーに Minecraft サーバーパネル (Pterodactyl) をゼロから構築する手順を説明します。

**他の言語:**
- [English](README.md)
- [Bahasa Indonesia](README-id.md)

## 📋 事前準備

1.  **Arch Linux** がインストールされたサーバー/VPS。
2.  サーバーの **IPアドレス** (例: `103.123.45.67`)。
3.  **ドメイン**: 推奨ですが必須ではありません。持っていない場合は **サーバーのIPアドレス** を使用してください。
4.  **Root権限** (`root` としてSSH接続)。

---

## 🚀 ステップ 1: 準備

サーバーにSSH接続します:
```bash
ssh root@your-server-ip
```

スクリプトをダウンロードします:
```bash
pacman -Sy --noconfirm git
git clone https://github.com/your-username/your-repo.git
cd your-repo
chmod +x install_panel.sh install_wings.sh
```

---

## 💿 ステップ 2: パネルのインストール (Web管理画面)

サーバーを管理するためのWebインターフェースをインストールします。

1.  インストーラーを実行:
    ```bash
    ./install_panel.sh
    ```
2.  必要な情報を入力:
    *   **FQDN / URL**: ドメインを入力 (例: `panel.example.com`)。**ドメインがない場合は、サーバーのパブリックIPを入力してください**。
    *   **Email**: 管理者ログイン用。
    *   **Password**: 管理者ログイン用パスワード。
    *   **Database Password**: Enterキーを押して自動生成。
    *   **Timezone**: Enterキーを押してデフォルトを使用。

3.  インストールが完了するまで待ちます。

---

## 🛠️ ステップ 3: Web設定 (重要！)

**注意！** まだ2つ目のスクリプトを実行しないでください。先にブラウザで設定を行う必要があります。

1.  ブラウザを開き、パネルのURL (例: `http://103.123.45.67`) にアクセスします。
2.  ステップ2で作成した情報で **ログイン** します。

### "Node" (ノード) の作成
1.  右上の **歯車アイコン** をクリックして管理画面に入ります。
2.  左メニューの **Locations** -> **Create New** をクリック。
    *   Short Code: `home`
    *   Description: `Home Server`
    *   **Create** をクリック。
3.  左メニューの **Nodes** -> **Create New** をクリック。
    *   **Name**: `LocalNode`
    *   **Location**: local (作成したもの)
    *   **FQDN**: `127.0.0.1` と入力 (**重要**: Wingsは同じマシンにあるため、必ず 127.0.0.1 を使用してください)。
    *   **Communicate Over SSL**: `Use HTTP Connection` を選択。
    *   **Daemon Port**: `8080`, **SFTP Port**: `2022`。
    *   **Memory/Disk**: `0` (無制限) に設定。
    *   **Create Node** をクリック。

### 設定ファイルの取得
1.  ノード作成後、**Configuration** タブをクリックします。
2.  表示された YAML コードブロックを **コピー** してください。

---

## 🦋 ステップ 4: Wings のインストール (ゲームエンジン)

ターミナルに戻ります:

1.  Wingsインストーラーを実行:
    ```bash
    ./install_wings.sh
    ```
2.  スクリプトが質問します: **"Do you have the Configuration YAML ready?"**
    *   `y` を入力して Enter。
    *   ブラウザからコピーした YAML コードを **ペースト** します。
    *   `Ctrl+D` を押して保存します。

3.  成功すると、ブラウザ上のノードインジケーターが **緑色** に変わります。

---

## 🎮 ステップ 5: Minecraft サーバーの作成

1.  管理パネルで **Servers** -> **Create New** に移動します。
2.  詳細を入力:
    *   **Name**: サーバー名。
    *   **Owner**: 自分の管理者アカウントを選択。
    *   **Nest/Egg**: `Minecraft` -> `Vanilla Minecraft` を選択。
3.  **Create Server** をクリック。

サーバーのインストールが始まります。完了後、コンソールからサーバーを操作できます。楽しんでください！
