#!/bin/bash

DB_DIR="$(dirname "$0")"

for dump in "$DB_DIR"/*.dump; do
    DB_NAME="$(basename "$dump" .dump)"
    echo "Restoring $dump into $DB_NAME..."
    pg_restore --no-owner --no-privileges --clean --if-exists -d "$DB_NAME" "$dump"
done