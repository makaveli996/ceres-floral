#!/bin/bash
# PrestaShop cache clear for webpack watch. Runs from repo root.
# Prefer: make cache-clear-fast (file wipe in container, no PHP). Fallback: make cache-clear, then host.

set -e
ROOT="$(cd "$(dirname "$0")" && pwd)"
cd "$ROOT"

if command -v make >/dev/null 2>&1; then
  echo "  → Using make cache-clear-fast (Docker, no PHP)..."
  if make cache-clear-fast 2>/dev/null; then
    echo "  ✓ Cache cleared (fast)"
    exit 0
  fi
  echo "  → Fallback: make cache-clear..."
  if make cache-clear 2>/dev/null; then
    echo "  ✓ Cache cleared via make cache-clear"
    exit 0
  fi
fi

# Fallback: clear on host (works if cache dir is writable by current user)
echo "  → Clearing cache on host (prestashop/var/cache, config/themes)..."
CACHE_DIR="$ROOT/prestashop/var/cache"
THEMES_CONFIG="$ROOT/prestashop/config/themes"

if [ -d "$CACHE_DIR" ]; then
  find "$CACHE_DIR" -mindepth 1 -maxdepth 1 ! -name '.' -exec rm -rf {} + 2>/dev/null || true
fi
if [ -d "$THEMES_CONFIG" ]; then
  find "$THEMES_CONFIG" -name "*.json" -type f -delete 2>/dev/null || true
fi
echo "  ✓ Cache cleared (host fallback)"
echo "  If using Docker and you see 'Unable to persist data in cache', run: make fix-cache"
