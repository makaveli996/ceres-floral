# PrestaShop 8.2.3 — Local Development Setup (WSL + Docker)

This document describes **exactly** how to set up and run this project on a completely new computer, including all issues we encountered and how to avoid them.

The goal is simple:

➡️ **clone project → run ONE command → start coding**

---

## 🧱 STACK

- Windows 10 / 11
- WSL2 (Ubuntu)
- Docker Desktop (WSL integration)
- PrestaShop 8.2.3 (Docker)
- Local domain via Windows hosts
- Webpack running on separate port (optional)

---

## 1️⃣ FIRST TIME SETUP (NEW COMPUTER)

### 1. Install WSL2

Open **PowerShell as Administrator**:

```powershell
wsl --install
```

Restart Windows if asked.

After reboot:

- Install **Ubuntu** from Microsoft Store (if not installed automatically).
- Launch it once and create your Linux user.

---

### 2. Update Ubuntu

Inside WSL terminal:

```bash
sudo apt update && sudo apt upgrade -y
```

---

### 3. Install Docker Desktop (Windows)

Download:

https://www.docker.com/products/docker-desktop/

During install:

- ✅ Use WSL2 backend

---

### 4. Enable Docker ↔ WSL Integration

Open Docker Desktop:

**Settings → Resources → WSL Integration**

Enable:

- ✅ Enable integration with default WSL distro
- ✅ Your Ubuntu distro (e.g. Ubuntu-24.04)

---

### 5. Docker permissions in WSL (IMPORTANT)

After installing Docker Desktop and enabling WSL Integration:

Open WSL and run:

```bash
sudo groupadd docker 2>/dev/null || true
sudo usermod -aG docker $USER
```

Then:

➡️ **Restart WSL completely**

From Windows terminal:

```powershell
wsl --shutdown
```

Open WSL again.

---

### 6. Verify Docker works inside WSL

```bash
docker version
docker compose version
```

If both commands work — setup is correct.

---

## 2️⃣ PROJECT FOLDER STRUCTURE

Inside WSL:

```bash
cd ~
mkdir -p projects
cd projects

mkdir -p ~/projects/nazwaprojektu
cd ~/projects/nazwaprojektu
```

Now clone your repository here.

---

## 3️⃣ CLONE PROJECT

```bash
cd ~/projects
git clone <repo-url>
cd meblowosk
```

---

## 4️⃣ ONE-COMMAND PROJECT SETUP (IMPORTANT)

Install:

sudo apt update && sudo apt install -y make

Run:

```bash
make init
```

This command automatically:

- creates `.env` from `.env.example` (if missing)
- adds local domain to Windows hosts
- starts Docker containers
- runs **`make overlay-repo`** — restores `prestashop/themes`, `prestashop/modules`, `prestashop/override` from the repo so **your custom code overwrites** whatever the PrestaShop Docker image may have copied into the volume

After first `make init`, run **once**: `make perms-once` and log out/in so you can edit files (see “Permissions” below).

You DO NOT need to remember anything else.

---

## 5️⃣ OPEN STORE

Store:

```
http://meblowosk.test:8080
```

phpMyAdmin:

```
http://localhost:8081
```

---

## 6️⃣ FIND ADMIN PANEL URL

Presta generates random admin folder name.

```bash
make admin-path
```

Example:

```
prestashop/admin123xyz
```

Admin URL:

```
http://meblowosk.test:8080/admin123xyz
```

Default login:

```
admin@local.test
admin12345
```

---

## 7️⃣ DAILY WORKFLOW

Start containers:

```bash
make up
```

Stop containers:

```bash
make down
```

Logs:

```bash
make logs
```

Status:

```bash
make ps
```

---

## 8️⃣ FILE PERMISSIONS (WHY THIS EXISTS)

Presta installs files as root inside Docker.

**Permissions (once and for all):** The container runs an entrypoint that makes `prestashop/` writable by the web server (www-data). So that you can also edit files on the host, do this **once**:

```bash
make perms-once
```

Then follow the printed command (`sudo usermod -aG www-data $USER`) and **log out and back in** (or run `newgrp www-data` in the same terminal). After that, both the container and you can read/write without further `make perms`.

If you ever get permission denied only in specific cache dirs, you can still run `make perms-cache` as a fallback.

---

## 9️⃣ CACHE MANAGEMENT

Clear Prestashop cache:

```bash
make cache-clear
```

Hard cache clear:

```bash
make cache-clear-hard
```

---

## 🔟 DATABASE

Create DB dump:

```bash
make db-dump
```

Import DB dump:

```bash
make db-import
```

---

## 1️⃣1️⃣ FULL RESET (START FROM ZERO)

⚠️ Deletes database + files.

```bash
make reset
make up
```

`make reset` removes the whole `prestashop/` folder, then restores **`prestashop/override`** from the repo. After `make up`, run **`make overlay-repo`** to restore themes, modules and override from the repo again (or run `make init` once — it does `up` + `overlay-repo`).

Use when:

- install broke
- database corrupted
- you want clean setup

---

## 1️⃣2️⃣ WEBPACK / DEV SERVER NOTES

Store runs on:

```
http://meblowosk.test:8080
```

If webpack runs on another port:

### Recommended setup

- Webpack serves ONLY JS/CSS assets
- AJAX/cart requests go to Prestashop domain

### Avoid

- API calls directly to webpack domain
- Mixing domains → CORS/session issues

Use devServer proxy if needed.

---

## 1️⃣3️⃣ TROUBLESHOOTING

### ❌ Stuck in logs (cannot type)

Exit logs:

```
CTRL + C
```

This DOES NOT stop containers.

---

### ❌ Permission denied / Directory not writable (cache, logs, themes)

Do the one-time group setup so you and the container can both write:

```bash
make perms-once
```

Then run the command it prints (`sudo usermod -aG www-data $USER`) and **log out and log in** (or `newgrp www-data`). Restart containers so the entrypoint runs again: `docker compose down && docker compose up -d`.

---

### ❌ Unknown database 'prestashop'

```bash
make reset
make up
```

---

### ❌ Container exits during install

```bash
docker compose logs web
```

---

### ❌ In prestashop/ I only see themes, modules, override (no core: app/, config/, admin*, etc.)

The bind mount `./prestashop:/var/www/html` can hide the image’s core on first run. Copy the core from the image once:

```bash
make copy-core
make overlay-repo
make up
```

Then open http://meblowosk.test:8080 again.

---

### ❌ Design > Themes shows two "Classic" (no "Meblowosk")

The theme list comes from `prestashop/config/themes/`, which is **not in the repo** (generated at runtime). On a new machine or after reset, PrestaShop can create the meblowosk theme config with Classic’s metadata, so the BO shows two "Classic".

Fix (run after `make up` if you see it):

```bash
make perms
make fix-theme-config
```

Then refresh **Design > Themes** in the Back Office. Keep `scripts/meblowosk-shop1-fixed.json` in the repo so this fix works on every clone.

---

### ❌ Port 80 already in use

This project intentionally uses:

```
8080 → container:80
```

Do not change unless you know what you’re doing.

---

## 1️⃣4️⃣ USEFUL COMMANDS (CHEATSHEET)

```bash
make init
make perms-once   # once, then log out/in
make up
make down
make overlay-repo  # restore themes/modules/override from repo (if Docker overwrote them)
make copy-core     # copy core from image into ./prestashop (when you only have repo files)
make ps
make logs
make cache-clear
make admin-path
make db-dump
make reset
```

---

## ⭐ REPO VS DOCKER (WHAT LIVES WHERE)

On a **new computer** after `git clone` you only have from the repo:

- `prestashop/themes/` — theme meblowosk (and classic if tracked)
- `prestashop/modules/` — custom modules (e.g. tc_stickybar)
- `prestashop/override/` — PrestaShop class/template overrides

The rest of `prestashop/` (core, config, var, etc.) is **not** in git. When you run **`make up`**, the PrestaShop Docker image installs the full core into the mounted `./prestashop` and may copy its default themes/modules too — so your repo content could be overwritten.

To keep **repo as source of truth** for custom code:

- **`make init`** runs **`make overlay-repo`** after `make up`: it restores `themes`, `modules`, `override` from git, so **repo overwrites** what Docker copied.
- If you only run `make up` (e.g. later) and something got overwritten, run **`make overlay-repo`** to restore those three from the repo again.
- **`make reset`** deletes `prestashop/`, then restores only `prestashop/override` from the repo. After `make up`, run **`make overlay-repo`** to restore themes, modules and override (or run `make init` once after reset: it does `up` + `overlay-repo`).

Summary: **Docker installs core; themes, modules, override come from the repo and win over Docker’s copy** thanks to `overlay-repo` in init (and manually when needed).

---

## ⭐ IMPORTANT PROJECT NOTES

- `.env` is NOT stored in git.
- It is auto-created from `.env.example`.
- Docker automatically creates database.
- Presta **core** is installed by the Docker image into `./prestashop`. **Themes, modules, override** are from the repo and are restored by `make init` / `make overlay-repo` so they are not overwritten by the image.
- Database lives in Docker volume.
- `prestashop/config/themes/` is **not** in the repo (generated at runtime). If Design > Themes shows two "Classic" on a new clone, run `make perms` then `make fix-theme-config`. **Do not remove** `scripts/meblowosk-shop1-fixed.json` — it is the fix applied on each machine.
- `PS_ERASE_DB` must stay:

```
PS_ERASE_DB: 0
```

---

## 🔥 OPTIONAL (FUTURE UPGRADE)

For multiple projects you may later switch to:

- Reverse proxy (Traefik / Caddy)
- Domains without ports:
  - meblowosk.test
  - red-iris.test

Current setup is stable and production-like for development.

---
