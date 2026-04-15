SHELL := /bin/bash

ENV_FILE := .env
ENV_EXAMPLE := .env.example

help:
	@echo "make init-fresh  -> env + host + copy-core + up + overlay-repo (first clone / empty prestashop/)"
	@echo "make init        -> env + host + up (then run make perms-once once)"
	@echo "make env         -> create .env from .env.example if missing"
	@echo "make host        -> add DOMAIN to Windows hosts (admin prompt)"
	@echo "make up          -> start containers"
	@echo "make down        -> stop containers"
	@echo "make ps          -> show containers"
	@echo "make logs        -> follow web logs"
	@echo "make perms       -> fix file ownership for ./prestashop"
	@echo "make perms-cache -> cache + modules writable (fix BO 'uprawnienia do zapisu')"
	@echo "make perms-once  -> one-time: add user to www-data group (then log out/in)"
	@echo "make admin-path  -> print admin folder path"
	@echo "make db-dump     -> backups/db.sql"
	@echo "make db-import   -> import backups/db.sql"
	@echo "make blog-clicks -> ps_ets_blog_post.click_number (licznik tc_etsblog_views)"
	@echo "make seed-bestsellers -> insert fake order so products 15–19 appear as bestsellers"
	@echo "make fill-product-sales -> rebuild bestsellers table (run after seed-bestsellers)"
	@echo "make backup-db   -> timestamped backup to backups/db_backup_*.sql.gz (optional: KEEP=N)"
	@echo "make fix-cache       -> fix missing appParameters.php (perms + cache:clear)"
	@echo "make cache-clear-fast -> wipe cache dirs in container only (no PHP, for watch)"
	@echo "make cache-clear     -> Symfony cache:clear (prod+dev)"
	@echo "make cache-clear-hard -> wipe cache dirs then rebuild"
	@echo "make fix-theme-config  -> fix ceres_floral theme name in BO (run make perms first if denied)"
	@echo "make overlay-repo -> restore themes/modules/override from repo (run after first up on new machine)"
	@echo "make copy-core    -> copy PrestaShop core from image into ./prestashop (when you only have repo files)"
	@echo "make reset       -> FULL RESET (down -v + remove prestashop) !!"
	@echo "make theme-build -> npm run build (compile _dev -> theme assets)"
	@echo "make theme-watch -> npm run watch"
	@echo "make theme-serve -> npm run serve (BrowserSync)"

# ---------- Internal helpers ----------
.PHONY: env-ensure check

env-ensure:
	@test -f $(ENV_EXAMPLE) || (echo "ERROR: missing $(ENV_EXAMPLE). Add it to repo." && exit 1)
	@test -f $(ENV_FILE) || (cp $(ENV_EXAMPLE) $(ENV_FILE) && echo "OK: created $(ENV_FILE) from $(ENV_EXAMPLE)")

check: env-ensure
	@command -v docker >/dev/null 2>&1 || (echo "ERROR: docker not found in PATH" && exit 1)
	@docker info >/dev/null 2>&1 || (echo "ERROR: Docker daemon not reachable (Docker Desktop / WSL integration?)" && exit 1)
	@test -f scripts/windows-add-host.ps1 || (echo "ERROR: missing scripts/windows-add-host.ps1" && exit 1)
	@echo "OK: check passed"

# ---------- Public commands ----------
env: env-ensure
	@echo "OK: env ready"

# Restore themes, modules, override from repo. Run after first 'make up' on new machine so repo
# overwrites whatever the PrestaShop image may have copied into the volume.
overlay-repo:
	@git checkout HEAD -- prestashop/themes prestashop/modules prestashop/override 2>/dev/null || true
	@echo "OK: prestashop/themes, modules, override restored from repo (repo wins over Docker copy)."

# Copy PrestaShop core from the Docker image into ./prestashop. Use when ./prestashop only has
# themes, modules, override from the repo (bind mount hid the image content). -n = no-clobber
# so existing dirs are not overwritten. Run once after clone if make init left you without core.
copy-core: env-ensure
	@echo "Copying PrestaShop core from image into ./prestashop (no-clobber)..."
	@docker run --rm -v "$$(pwd)/prestashop:/out" prestashop/prestashop:8.2.3-apache sh -c 'cp -an /var/www/html/. /out/'
	@echo "OK: core copied. Run: make overlay-repo  (then make up if containers are not running)"

# First-time setup when ./prestashop has only themes/modules/override from git (no core yet).
init-fresh: check host copy-core up overlay-repo
	@. $(ENV_FILE); echo "OK: init-fresh done -> open: http://$${DOMAIN}:$${WEB_PORT}"
	@echo "Next: make perms && make perms-cache && npm install && make theme-build"
	@echo "One-time: run 'make perms-once' and log out/in so you can edit files (container already has write via entrypoint)."

# One-command setup after git clone (use init-fresh if ./prestashop has no core files yet).
init: check host up overlay-repo
	@. $(ENV_FILE); echo "OK: init done -> open: http://$${DOMAIN}:$${WEB_PORT}"
	@echo "One-time: run 'make perms-once' and log out/in so you can edit files (container already has write via entrypoint)."

host: env-ensure
	@set -a; . $(ENV_FILE); set +a; \
	domain=$${DOMAIN:-ceres-floral.test}; \
	echo "Adding $$domain to Windows hosts..."; \
	powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/windows-add-host.ps1 -Domain $$domain

up: env-ensure
	docker compose up -d

down:
	docker compose down

ps:
	docker compose ps

logs:
	docker compose logs -f web

perms:
	@sudo chown -R $$(id -u):$$(id -g) prestashop || true
	@echo "OK: perms fixed (host user). Run 'make perms-cache' if container cannot write cache."

# One-time: add your user to group www-data (33) so you can edit files after entrypoint chowns to 33:33. Then log out and log in (or run newgrp www-data).
perms-once:
	@echo "Run: sudo usermod -aG www-data $$USER"
	@echo "Then log out and log in (or in this terminal: newgrp www-data)"

# Let container (www-data) write all dirs required by PrestaShop BO. Run after 'make perms' or if BO shows "uprawnienia do zapisu".
perms-cache:
	@mkdir -p prestashop/themes/classic/assets/cache prestashop/themes/ceres_floral/assets/cache prestashop/var/cache prestashop/var/logs prestashop/config/themes
	@mkdir -p prestashop/app/config prestashop/app/Resources/translations
	@mkdir -p prestashop/img/blog_extras_gallery
	@chmod -R 777 \
		prestashop/themes/classic/assets/cache prestashop/themes/ceres_floral/assets/cache \
		prestashop/var/cache prestashop/var/logs prestashop/config prestashop/modules prestashop/override \
		prestashop/img prestashop/translations prestashop/upload prestashop/download prestashop/mails \
		prestashop/app/config prestashop/app/Resources/translations \
		2>/dev/null || true
	@echo "OK: cache, logs, config, modules, img, translations, upload, download, mails, app writable by container"

admin-path:
	@ls -d prestashop/admin* 2>/dev/null | head -n 1 || echo "Admin folder not found yet"

db-dump: env-ensure
	@./scripts/db-dump.sh backups/db.sql

db-import: env-ensure
	@./scripts/db-import.sh backups/db.sql

# Liczniki odsłon wpisów ets_blog (moduł tc_etsblog_views); wymaga `make up`, czyta DB z .env
blog-clicks: env-ensure
	@set -a; . ./$(ENV_FILE); set +a; \
	docker compose exec -T db mariadb -u "$$DB_USER" -p"$$DB_PASS" "$$DB_NAME" \
		-e "SELECT id_post, click_number, enabled FROM ps_ets_blog_post ORDER BY click_number DESC, id_post ASC;"

# Insert fake order so products 15,16,17,18,19 appear as bestsellers (requires containers up)
seed-bestsellers: env-ensure
	@docker compose exec -T db mariadb -u "$${DB_USER:-prestashop}" -p"$${DB_PASS:-prestashop}" "$${DB_NAME:-prestashop}" < scripts/seed-bestsellers.sql && echo "OK: bestsellers seeded. Run: make fill-product-sales && make cache-clear"

# Rebuild ps_product_sale from orders so bestsellers and /best-sales work (run after seed-bestsellers)
fill-product-sales: env-ensure
	@docker compose exec -T web php /var/www/html/scripts/fill-product-sales.php

# Timestamped compressed backup; optionally keep only last N: make backup-db KEEP=5
backup-db: env-ensure
	@./scripts/backup-database.sh --keep $${KEEP:-0}

reset:
	@echo "RESET: stopping containers + removing volumes + deleting ./prestashop"
	@docker compose down -v || true
	@sudo rm -rf prestashop || true
	@mkdir -p prestashop
	@git checkout HEAD -- prestashop/override 2>/dev/null || true
	@echo "OK: reset done (override restored from repo if present). Now run: make up"

# Clear cache inside container (cache dir is owned by www-data, so host rm fails without sudo).
# Uses exec if web is running, else run --rm for a one-off container.
# Fix Design > Themes showing two "Classic": config/themes/ceres_floral/shop1.json had Classic metadata. Run make perms first if permission denied.
fix-theme-config:
	@cp scripts/ceres_floral-shop1-fixed.json prestashop/config/themes/ceres_floral/shop1.json && echo "OK: ceres_floral theme config fixed. Refresh Design > Themes in BO." || (echo "Permission denied: run 'make perms' then run this again." && exit 1)

# Ensure var/cache exists and is writable, then regenerate appParameters.php etc. Run this if you get "Failed to open appParameters.php".
# After cache:clear we chown var/cache to www-data (33) so Apache can create profiler/ and other subdirs.
fix-cache: perms-cache
	@echo "Regenerating Symfony cache in container..."
	@docker compose exec -u 33:33 web sh -c 'mkdir -p /var/www/html/var/cache/dev /var/www/html/var/cache/prod /var/www/html/var/logs && chmod -R 777 /var/www/html/var/cache /var/www/html/var/logs && cd /var/www/html && php bin/console cache:clear --env=dev && php bin/console cache:clear --env=prod' || \
	 docker compose run --rm -u 33:33 web sh -c 'mkdir -p /var/www/html/var/cache/dev /var/www/html/var/cache/prod /var/www/html/var/logs && chmod -R 777 /var/www/html/var/cache /var/www/html/var/logs && cd /var/www/html && php bin/console cache:clear --env=dev && php bin/console cache:clear --env=prod' || \
	 (echo "Failed. Ensure containers are up (make up) and run: make fix-cache" && exit 1)
	@echo "OK: cache regenerated as www-data (appParameters.php should exist now)"

# Fast cache clear: only delete cache dirs + theme JSON in container (no PHP/Symfony). Use from webpack watch.
# Does not regenerate container; run "make cache-clear" if you need full rebuild (e.g. after services.yml change).
cache-clear-fast:
	@docker compose exec -u 33:33 web sh -c 'rm -rf /var/www/html/var/cache/dev/* /var/www/html/var/cache/prod/* 2>/dev/null; find /var/www/html/config/themes -name "*.json" -type f -delete 2>/dev/null; mkdir -p /var/www/html/var/cache/dev /var/www/html/var/cache/prod /var/www/html/var/logs' || \
	 docker compose run --rm -u 33:33 web sh -c 'rm -rf /var/www/html/var/cache/dev/* /var/www/html/var/cache/prod/* 2>/dev/null; find /var/www/html/config/themes -name "*.json" -type f -delete 2>/dev/null; mkdir -p /var/www/html/var/cache/dev /var/www/html/var/cache/prod /var/www/html/var/logs' || \
	 (echo "Could not run cache-clear-fast (start containers: make up)" && exit 1)
	@echo "OK: cache cleared as www-data (fast, no PHP). For full rebuild use: make cache-clear"

# Symfony cache:clear (rebuilds cache; safe, never breaks the site). Use after config/template/service changes.
# chown to www-data (33) so Apache can write profiler/ and other runtime subdirs.
cache-clear:
	@docker compose exec -u 33:33 web sh -c 'mkdir -p /var/www/html/var/logs && cd /var/www/html && php bin/console cache:clear --env=prod && php bin/console cache:clear --env=dev' || \
	 docker compose run --rm -u 33:33 web sh -c 'mkdir -p /var/www/html/var/logs && cd /var/www/html && php bin/console cache:clear --env=prod && php bin/console cache:clear --env=dev' || \
	 (echo "Could not clear cache (start containers with: make up). If you see appParameters.php missing, run: make fix-cache" && exit 1)
	@echo "OK: cache cleared as www-data (Symfony prod + dev). If BO shows 'uprawnienia do zapisu', run: make perms-cache"

# Alias; same as cache-clear.
cache-clear-symfony: cache-clear

# Wipe var/cache and legacy cache/, then rebuild. Use only if cache-clear is not enough.
cache-clear-hard:
	@docker compose exec -u 33:33 web sh -c 'rm -rf /var/www/html/var/cache/* /var/www/html/cache/* 2>/dev/null; mkdir -p /var/www/html/var/logs; cd /var/www/html && php bin/console cache:clear --env=prod && php bin/console cache:clear --env=dev' || \
	 docker compose run --rm -u 33:33 web sh -c 'rm -rf /var/www/html/var/cache/* /var/www/html/cache/* 2>/dev/null; mkdir -p /var/www/html/var/logs; cd /var/www/html && php bin/console cache:clear --env=prod && php bin/console cache:clear --env=dev' || \
	 (echo "Could not clear cache (start containers with: make up). Run: make fix-cache" && exit 1)
	@echo "OK: cache wiped and rebuilt as www-data (var/cache + legacy cache)"

# ---------- Theme assets (run from repo root) ----------
theme-build:
	npm run build

theme-watch:
	npm run watch

theme-serve:
	npm run serve

theme-dev: theme-watch
	@echo "Run 'npm run serve' in another terminal for BrowserSync"
