#!/usr/bin/env bash
#
# Database backup for PrestaShop (Docker). Creates timestamped .sql.gz in backups/.
# Uses: .env (DB_NAME, DB_USER, DB_PASS), docker compose exec db mariadb-dump.
# Usage: ./scripts/backup-database.sh [--keep N]
#   --keep N: keep only the last N backups (default: keep all)
# Can be run via: make backup-db [KEEP=N]
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

# Load .env so DB_* are set (same as db-dump.sh / Makefile context)
if [[ -f .env ]]; then
  set -a
  # shellcheck source=/dev/null
  source .env
  set +a
fi

: "${DB_NAME:?DB_NAME not set (add to .env or export)}"
: "${DB_USER:?DB_USER not set}"
: "${DB_PASS:?DB_PASS not set}"

BACKUP_DIR="${BACKUP_DIR:-$REPO_ROOT/backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/db_backup_${TIMESTAMP}.sql.gz"

KEEP_BACKUPS=""
if [[ "${1:-}" == "--keep" ]] && [[ -n "${2:-}" ]]; then
  KEEP_BACKUPS="$2"
fi

mkdir -p "$BACKUP_DIR"

if ! docker compose exec -T db mariadb-dump --version &>/dev/null; then
  echo "Error: mariadb-dump in container not available (is 'db' running?)" >&2
  exit 1
fi

if ! command -v gzip &>/dev/null; then
  echo "Error: gzip not installed or not in PATH" >&2
  exit 1
fi

echo "Starting database backup..."
echo "Database: $DB_NAME"
echo "Backup file: $BACKUP_FILE"

docker compose exec -T db mariadb-dump -u "$DB_USER" -p"$DB_PASS" \
  --single-transaction \
  --quick \
  --lock-tables=false \
  --routines \
  --triggers \
  --events \
  "$DB_NAME" 2>/dev/null | gzip > "$BACKUP_FILE"

if [[ $? -eq 0 ]] && [[ -f "$BACKUP_FILE" ]] && [[ -s "$BACKUP_FILE" ]]; then
  BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
  echo "✓ Backup completed successfully!"
  echo "  File: $BACKUP_FILE"
  echo "  Size: $BACKUP_SIZE"

  if [[ -n "$KEEP_BACKUPS" ]] && [[ "$KEEP_BACKUPS" -gt 0 ]]; then
    cd "$BACKUP_DIR" || exit 1
    BACKUP_COUNT=$(ls -t db_backup_*.sql.gz 2>/dev/null | wc -l)
    if [[ "$BACKUP_COUNT" -gt "$KEEP_BACKUPS" ]]; then
      REMOVED=$((BACKUP_COUNT - KEEP_BACKUPS))
      # shellcheck disable=SC2010
      ls -t db_backup_*.sql.gz | tail -n +$((KEEP_BACKUPS + 1)) | xargs -r rm -f
      echo "  Removed $REMOVED old backup(s), kept last $KEEP_BACKUPS"
    fi
  fi
else
  echo "✗ Backup failed!" >&2
  [[ -f "$BACKUP_FILE" ]] && rm -f "$BACKUP_FILE"
  exit 1
fi
