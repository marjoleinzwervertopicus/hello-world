#!/bin/bash
cd "$(dirname "$0")"

dump_db() {
    local db="$1"
    shift
    local excludes=()
    for table in "$@"; do
        excludes+=(--exclude-table="$table")
    done
    pg_dump "${excludes[@]}" -d "$db" -f "dumps/${db}.dump" -Fc -U postgres
}


dump_db kwaliteitskaderapp user_info client_info user_dashboard
dump_db hap_hcdo