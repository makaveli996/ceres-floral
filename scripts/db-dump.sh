#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

if [[ -f .env ]]; then
  set -a
  # shellcheck source=/dev/null
  source .env
  set +a
fi

: "${DB_NAME:?DB_NAME not set (add to .env)}"
: "${DB_USER:?DB_USER not set (add to .env)}"
: "${DB_PASS:?DB_PASS not set (add to .env)}"

FILE="${1:-backups/db.sql}"
mkdir -p "$(dirname "$FILE")"
docker compose exec -T db mariadb-dump -u "${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" > "$FILE"
echo "OK: dumped to $FILE"
