#!/bin/bash
set -euo pipefail

# Usage: restore_dumps.sh <mode> [db_name ...]
#   all      drop the dumped tables and restore every dump
#   missing  drop nothing; only restore dumps into databases that have no tables yet
#   db_name  only restore these databases (default: every *.dump in this directory)
MODE="${1:-}"
if [[ "$MODE" != "all" && "$MODE" != "missing" ]]; then
    echo "Usage: $0 all|missing [db_name ...]" >&2
    exit 1
fi
shift

DB_DIR="$(dirname "$0")"

if [[ $# -gt 0 ]]; then
    DUMPS=()
    for db in "$@"; do
        if [[ ! -f "$DB_DIR/$db.dump" ]]; then
            echo "No dump found for $db: $DB_DIR/$db.dump" >&2
            exit 1
        fi
        DUMPS+=("$DB_DIR/$db.dump")
    done
else
    DUMPS=("$DB_DIR"/*.dump)
fi

# Count user tables, ignoring system schemas and tables that belong to an extension (e.g. PostGIS spatial_ref_sys)
count_tables() {
    psql -U postgres -d "$1" -Atc "
        SELECT count(*)
        FROM pg_class c
        JOIN pg_namespace n ON n.oid = c.relnamespace
        WHERE c.relkind IN ('r', 'p')
          AND n.nspname NOT IN ('pg_catalog', 'information_schema')
          AND n.nspname NOT LIKE 'pg_toast%'
          AND NOT EXISTS (
            SELECT 1 FROM pg_depend d
            WHERE d.classid = 'pg_class'::regclass AND d.objid = c.oid AND d.deptype = 'e'
          );"
}

for dump in "${DUMPS[@]}"; do
    DB_NAME="$(basename "$dump" .dump)"

    if [[ "$MODE" == "all" ]]; then
        echo "Restoring $dump into $DB_NAME (clean)..."
        pg_restore --exit-on-error --clean --if-exists --no-owner --no-privileges -U postgres -d "$DB_NAME" "$dump"
    else
        TABLE_COUNT="$(count_tables "$DB_NAME")"
        if [[ "$TABLE_COUNT" -gt 0 ]]; then
            echo "Skipping $DB_NAME: already has $TABLE_COUNT table(s)"
            continue
        fi
        echo "Restoring $dump into $DB_NAME..."
        pg_restore --exit-on-error --no-owner --no-privileges -U postgres -d "$DB_NAME" "$dump"
    fi
done
