#!/bin/bash
set -euo pipefail

DB_DIR="$(dirname "$0")"

for dump in "$DB_DIR"/*.dump; do
    DB_NAME="$(basename "$dump" .dump)"
    echo "Restoring $dump into $DB_NAME..."
    pg_restore --exit-on-error --clean --if-exists --no-owner --no-privileges -U postgres -d "$DB_NAME" "$dump"
done
