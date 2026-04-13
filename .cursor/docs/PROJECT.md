# Project Overview

## Local URLs

- **Shop:** http://meblowosk.test:8080  
- **phpMyAdmin:** http://localhost:8081  

## Repository & services

- **Repo path:** `/home/rafal/projects/meblowosk` (or your local clone path).
- **Docker services:** `web` (PrestaShop 8.2.3 Apache), `db` (MariaDB 10.11), `pma` (phpMyAdmin).

## Key notes

- **PS_ERASE_DB=0** — DB is not wiped on container start; safe for repeated `make up`.
- **Port 8080** — Shop is on `WEB_PORT` (default 8080); override via `.env`.
- **Permissions:** Fix ownership after clone or reset with `make perms`.
- **Environment:** `.env` is generated from `.env.example` if missing (e.g. by `make init`).

## Workflow

1. Clone repo.
2. Run `make init` (creates `.env`, adds host, starts containers, fixes perms).
3. Open http://meblowosk.test:8080 — ready to work.

## Placeholders (fill as needed)

- **Theme name:** _e.g. `classic` or custom theme folder name_
- **Webpack output folder:** _e.g. `themes/your_theme/assets/dist`_
- **Custom modules list:** _e.g. `mymodule`, `anothermodule`_
